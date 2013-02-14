local Redis = require('resty.redis')
local say = ngx.say
local log = ngx.log
local null = ngx.null
local INFO = ngx.INFO
local ERR = ngx.ERR
local exit = ngx.exit
local SERVER_ERROR = ngx.HTTP_INTERNAL_SERVER_ERROR


local ok, err, res
local redis = Redis:new()
--redis:set_timeout(1000)

ok, err = redis:connect('127.0.0.1', 6379)
if not ok then
    log(ERR, 'failed to connect: ', err)
    exit(SERVER_ERROR)
end


local concurrency, err = redis:get('concurrency') 
if concurrency == null then
    concurrency = 3
else
    concurrency = tonumber(concurrency)
end

local num_processing, err = redis:get('num_processing')
if num_processing == null then
    num_processing = 0
else
    num_processing = tonumber(num_processing)
end

if num_processing >= concurrency then
    local num_waiting, err = redis:incr('num_waiting')
    if err then
        log(ERR, 'cannot increment number of waiting requests')
        exit(SERVER_ERROR)
    end

    local x, err = redis:blpop('waiting', 0)
    if err then
        log(ERR, 'cannot pop waiting')
        exit(SERVER_ERROR)
    end
end

num_processing, err = redis:incr('num_processing')
if err then
    log(ERR, 'cannot increment number of requests in processing')
    exit(SERVER_ERROR)
end

local Redis = require('resty.redis')
local say = ngx.say
local log = ngx.log
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
    return
end

local num_waiting, err = redis:get('num_waiting')
if err then
    log(ERR, 'failed to get number of requests waiting')
    return
end

if num_waiting > 0 then
    local x, err = redis:lpush('waiting', 1)
    if err then
        log(ERR, 'failed to notify a waiting request')
        return
    end
end

local num_processing, err = redis:decr('num_processing')
if err then
    log(ERR, 'failed to decrement number of requests in process')
    return
end


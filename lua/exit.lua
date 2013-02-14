local Redis = require('resty.redis')
local say = ngx.say
local log = ngx.log
local INFO = ngx.INFO
local ERR = ngx.ERR
local exit = ngx.exit
local SERVER_ERROR = ngx.HTTP_INTERNAL_SERVER_ERROR
local null = ngx.null

local path = '/proxyslowapp' .. ngx.var.request_uri
local response = ngx.location.capture(path)
ngx.status = response.status
for k,v in pairs(response.header) do
    ngx.header[k] = response.header[k]
end
ngx.say(response.body)


local ok, err, res
local redis = Redis:new()
--redis:set_timeout(1000)

ok, err = redis:connect('127.0.0.1', 6379)
if not ok then
    log(ERR, 'failed to connect: ', err)
    return
end

local num_waiting, err = redis:get('num_waiting')
if num_waiting == null then
    num_waiting = 0
else
    num_waiting = tonumber(num_waiting)
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
else
    num_processing = tonumber(num_processing)
end


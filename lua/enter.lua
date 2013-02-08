local Redis = require('resty.redis')
local say = ngx.say
local log = ngx.log
local INFO = ngx.INFO
local ERR = ngx.ERR
local json = require('cjson')


local ok, err, res
local redis = Redis:new()
--redis:set_timeout(1000)

ok, err = redis:connect('127.0.0.1', 6379)
if not ok then
    log(ERR, 'failed to connect: ', err)
    return
end

local res, err = redis:subscribe('Chan')
if not res then
    log(ERR, 'failed to subscribe: ', err)
    return
end

res, err = redis:read_reply()
if not res then
    log(ERR, 'failed to read reply: ', err)
    return
end
log(ERR, res[1], ' ', res[2], ' ', res[3])

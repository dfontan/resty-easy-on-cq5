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
    say('failed to connect: ', err)
    exit(SERVER_ERROR)
end

local num_processing, err = redis:get('num_processing')
say('num_processing: ', num_processing, '<br />')
local num_waiting, err = redis:get('num_waiting')
say('num_waiting: ', num_waiting)

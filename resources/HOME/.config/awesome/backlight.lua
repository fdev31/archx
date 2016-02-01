module = {}
awful = require 'awful'
-- use awful.util.spawn instead ?
local id="0"
local increment=4

local xb_fn = function(arg)
    local rarg = 'xbacklight -time 0 -steps 1 ' .. arg
    local fn = function()
        awful.util.spawn(rarg)
    end
    return fn
end

module.up = xb_fn('+'..increment)
module.down = xb_fn('-'..increment)
return module

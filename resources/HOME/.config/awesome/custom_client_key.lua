require('custom_conf')
local awful = require("awful")
local k = {
    awful.key({ modkey,           }, "s",      function (c) c.sticky = not c.sticky          end),
    awful.key({ modkey,           }, "c",      function (c) c:kill()                         end)
}
return {keys = k}

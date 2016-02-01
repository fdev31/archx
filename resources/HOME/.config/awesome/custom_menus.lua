local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
require('custom_conf')

local refresh_nic = timer({ timeout = 1 })

function nic_display()
    local refresh_limit = 30
    refresh_nic:connect_signal("timeout", function ()
        if nic or refresh_limit == 0 then
            refresh_nic:stop()
            if refresh_limit ~= 0 then
                naughty.notify({title='Connected using '..nic})
            end
            return
        end
        set_nic()
        refresh_limit = refresh_limit - 1
    end)
    refresh_nic:stop()
    refresh_nic:start()
end
nic_display()

-- sexec=GUI, texec=TERM

local app_items = {
    { "Inkscape", sexec('inkscape') },
    { "Blender", sexec('blender') },
    { "Gimp", sexec('gimp') },
    { "Office", sexec('libreoffice') },
    { "WeeChat", texec('weechat-curses') },
}
local screen_items = {
    {"WinInfo", texec("xproptitle")},
    {"Comp switch", sexec('comp-switch')},
    {"Shift switch", sexec('shift-switch')},
    {"DPMS ON", sexec('xset s on +dpms')},
    {"DPMS OFF", sexec('xset s off -dpms')}
}

menu_items = {
    { "applications", app_items, beautiful.sun},
    { "files", sexec(FILE_MANAGER) },
    { 'screen', screen_items},
    { "quit", awesome.quit },
}
mymainmenu = awful.menu({ items = menu_items })


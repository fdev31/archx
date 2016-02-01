module = {}
local awful = require('awful')
local mykeys = {}

local screen_flipped = false

local reset_default_scr = function() 
    screen_flipped = false
    os.execute('xinput set-prop 10 "Evdev Axes Swap" 0')
    os.execute('xinput set-prop 10 "Evdev Axis Inversion" 0 0')
    os.execute('xinput enable 11')
    os.execute('synclient TouchpadOff=0')
    os.execute('xrandr --output eDP1 --rotate normal')
end

if io.open('/etc/hostname'):read() == 'xps' then

    local screensitems = {
        {"Normal", reset_default_scr},
        {"Book", function() 
            os.execute('xinput set-prop 10 "Evdev Axes Swap" 1')
            os.execute('xinput set-prop 10 "Evdev Axis Inversion" 1 0')
            os.execute('synclient TouchpadOff=1')
            os.execute('xinput disable 11')
            os.execute('xrandr --output eDP1 --rotate left')
            screen_flipped = true
        end},
        {"Flipped", function() 
            os.execute('xrandr --output eDP1 --rotate inverted --auto')
            os.execute('xinput set-prop 10 "Evdev Axes Swap" 0')
            os.execute('xinput set-prop 10 "Evdev Axis Inversion" 1 1')
            os.execute('synclient TouchpadOff=1')
            os.execute('xinput disable 11')
            screen_flipped = true
        end},
    }

    local screensmenu = awful.menu({items = screensitems})

    mykeys = {
        awful.key({ modkey,           }, "u", 
        function ()
            if screen_flipped then reset_default_scr() else screensmenu:show({keygrabber=true}) end
        end)
    }

end

module.keys = mykeys
return module

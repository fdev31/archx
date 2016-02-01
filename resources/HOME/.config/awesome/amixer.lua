local id="0"
local increment=4

local control = "Master"

os.execute('kill `cat /tmp/amixer_ctl'..id..'.pid` >/dev/null 2>&1 ; mkfifo /tmp/amixer_ctl'..id..' && echo $! > /tmp/amixer_ctl'..id..'.pid')
os.execute('sync ; amixer -qsM < /tmp/amixer_ctl'..id..' &')

_fd = io.open('/tmp/amixer_ctl'..id, 'a')

local _mixer_send = function(cmd)
    _fd:write(cmd)
    _fd:flush()
end

local _up_vol = function(sense)
    local _cmd = 'sset '.. control .. " " ..increment..'%' .. sense .. '\n'
    return function()
        _mixer_send(_cmd)
    end
end

return {
    up = _up_vol('+'),
    down = _up_vol('-'),
    mute = function() _mixer_send('sset '.. control .. ' mute\n') end,
    unmute = function() _mixer_send('sset ' .. control .. ' unmute\n') end,
    toggle = function() _mixer_send('sset ' .. control .. ' toggle\n') end
}

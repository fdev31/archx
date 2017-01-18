local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
require('custom_conf')

local TRANS_LEVEL = 0.8

function ru(c,n,prop, callback)
        local p = {
            rule = {class=c, name=n},
            properties=prop,
        }
        if callback then
            p.callback = callback
        end
        return p
end

local rules = {
    ru(nil,nil,{ -- defaults
        focus            = true,
        size_hints_honor = false,
        keys             = clientkeys,
        buttons          = clientbuttons,
        border_width     = beautiful.border_width,
        border_color     = beautiful.border_normal
    }),
    -- standard rules --
    -- volume properties
    ru("[pP]avucontrol", ".* volume.*",         { floating=true, fullscreen=false}),
    ru(nil, "alsamixer",           { width=100, floating=true}, awful.placement.under_mouse),
    -- term
--    ru("terminology", nil,         { opacity=TRANS_LEVEL, fixed_trans=true }),
    -- www 
    ru("Chromium", nil,            { tag=awful.tag.gettags(S_MAIN)[tagidx.web] }),
    ru("Chromium", ".*- chat -.*", { tag=awful.tag.gettags(S_MAIN)[tagidx.im] }),
    ru("Chromium", "Floating YouTube.*", { opacity=1.0, fixed_trans=true, floating=true, sticky=true }),
    ru("Firefox", nil,             { tag=awful.tag.gettags(S_MAIN)[tagidx.web] }),
    ru("Midori", nil,              { tag=awful.tag.gettags(S_MAIN)[tagidx.web] }),
    ru("Pale moon", nil,           { tag=awful.tag.gettags(S_MAIN)[tagidx.web] }),
    -- chat
    ru("Xchat", nil,               { tag=awful.tag.gettags(S_SEC)[tagidx.im] } ),
    ru("Thunderbird", nil,         { tag=awful.tag.gettags(S_SEC)[tagidx.im] } ),
    -- medias
    ru("Audacious", nil,           { tag=awful.tag.gettags(S_SEC)[tagidx.media] } ),
    ru("Midori", ".* – Rdio",      { tag=awful.tag.gettags(S_SEC)[tagidx.web] } ),

    -- edit
    ru("Gvim", nil,                { tag=awful.tag.gettags(S_MAIN)[tagidx.edit] } ),
    ru("jetbrains-pycharm-ce", nil,{ tag=awful.tag.gettags(S_MAIN)[tagidx.edit] } ),
    ru("Snaked", nil,              { tag=awful.tag.gettags(S_MAIN)[tagidx.edit] } ),
    -- gfx
    ru("Blender", nil,             { tag=awful.tag.gettags(S_MAIN)[tagidx.gfx] } ),
    ru("Inkscape", nil,            { tag=awful.tag.gettags(S_MAIN)[tagidx.gfx] } ),
    ru("Gimp", nil,                { tag=awful.tag.gettags(S_MAIN)[tagidx.gfx] } ),
    -- sound
    ru("Rdio", nil,                { tag=awful.tag.gettags(S_SEC)[tagidx.media] } ),
    -- fs
    ru("Geeqie", nil,              { floating=true } ),
    ru("ROX-Filer", nil,           { floating=true }),
    -- hacks --
    -- flashplugin
    ru("Exe", "exe",               { floating=true, fullscreen=true } ),
    ru("Plugin-container", nil,    { floating=true, fullscreen=true } ),
    -- logging xterm
    ru('TermLog', nil, {tag=awful.tag.gettags(S_SEC)[tagidx.logs], opacity=0.7 } ),
}

--client.connect_signal("unfocus", function (c) c.opacity = TRANS_LEVEL end)
--client.connect_signal("focus", function (c) if not c.fixed_trans then c.opacity = 1.0 end end)

-- arrange handler

for s = 1, scount do screen[s]:connect_signal("arrange", function ()
    local clients = awful.client.visible(s)
    local layout = awful.layout.getname(awful.layout.get(s))

    for _, c in pairs(clients) do -- Floaters are always on top
        if   awful.client.floating.get(c) or layout == "floating"
        then if not c.fullscreen then c.above       =  true  end
        else                          c.above       =  false end
    end
  end)
end

awful.util.spawn('comp-switch')
awful.util.spawn('nm-applet')

return {
    rules = rules
}

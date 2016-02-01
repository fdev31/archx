local awful = require("awful")

-- some global modules:
vicious = require("vicious")
drop = require("drop")

home   = os.getenv("HOME")
screen_switched = false

scount = screen.count()

if (scount == 1) then
    S_MAIN = 1
    S_SEC = 1
else
    S_SEC = 2
    S_MAIN = 1
end


for k, v in pairs(require('my_conf')) do
    _G[k] = v
end

color = {red="#ec3780", green="#80ecac", blue="#80b5ec", yellow="#eaec80"}

-- SETUP COMPOSE KEY. see compose in /usr/share/X11/xkb/rules/base.lst
 if IS_LAPTOP then
     awful.util.spawn_with_shell('setxkbmap -option compose:prsc')
 else
     awful.util.spawn_with_shell('setxkbmap -option compose:menu')
 end

-- handy functions --
--
 -- shell exec
exec  = awful.util.spawn_with_shell

-- following returns pointer to functions, to use in menus/keys
--
 -- terminal exec
function texec(cmd, opts)
    local args = ' '
    if (opts) then
        local res = {}
        for k, v in pairs(opts) do
            table.insert(res, '-'..k..' '..v)
        end
        args = ' ' .. table.concat(res, ' ')
    end
    local t = function()
        exec(terminal_run .. cmd .. " " .. args)
    end
    return t
end

 -- editor exec
function eexec(w)
    local t = function()
        exec(editor_cmd .. " " .. w)
    end
    return t
end

 -- standard exec
function sexec(cmd)
    local t = function()
        exec(cmd)
    end
    return t
end

-- END OF CUSTO &  definitions
--
-- tagidx.tag_name == <index of the given tag>
--
tagidx = {}
local _tags = {
    names={},
    layout={},
    props={}
}

for i,t in ipairs(tags) do
    tagidx[t[1]] = i
    _tags.names[i] = t[1] or i
    _tags.layout[i] = t[2]
end

-- Create tags:
for s = 1, scount do -- for each screen
  local tag = awful.tag(_tags.names, s, _tags.layout) -- create tags
  for i, t in ipairs(tag) do -- set some properties
      awful.tag.setproperty(t , "mwfact" , 0.5)
      local props = tags[i][3]
      if props then
          if type(props) == 'function' then
              props(t)
          else -- table of properties
              for pname, pval in pairs(props) do
                  awful.tag.setproperty(t, pname, pval)
              end
          end
      end
  end
end

_tags = nil
tags = nil

awful.tag.viewidx(tagidx.web-1, 1)

if scount > 1 then
    awful.tag.viewidx(tagidx.im-1, 2)
end


function c_grabnext(screen)
    return c_viewidx(1, screen, true)
end
function c_grabprev(screen)
    return c_viewidx(-1, screen, true)
end
function c_viewnext(screen)
    return c_viewidx(1, screen)
end
function c_viewprev(screen)
    return c_viewidx(-1, screen)
end

function c_viewidx(i, screen_id, grab_client)
    local screen_id = screen_id or mouse.screen
    local tags = awful.tag.gettags(screen_id)
    local current = awful.tag.getidx()

    local all_tags = {}
    local last_visible = nil

    for k, t in ipairs(tags) do
        local h = awful.tag.getproperty(t, "hide")
        table.insert(all_tags, {hidden=h, left_visible=last_visible})
        if not h then
            last_visible = k
        end
    end
    local rightmost = all_tags[#all_tags].hidden and all_tags[#all_tags].left_visible or #all_tags
    for k, t in ipairs(all_tags) do
        if t.left_visible == nil then
            t.left_visible = rightmost
        end
    end

    last_visible = nil
    for k=#all_tags, 1, -1 do
        local t = all_tags[k]
        t.right_visible = last_visible
        if not t.hidden then
            last_visible = k
        end
    end

    local leftmost = all_tags[1].hidden and all_tags[1].right_visible or 1
    for k=#all_tags, 1, -1 do
        local t = all_tags[k]
        if t.right_visible == nil then
            t.right_visible = leftmost
        end
    end

    if i > 0 then
        i = all_tags[current].right_visible
    else
        i = all_tags[current].left_visible
    end

    if grab_client then
        awful.client.movetotag(tags[i])
    end

    awful.tag.viewnone(screen_id)
    tags[i].selected = true

    screen[screen_id]:emit_signal("tag::history::update")

end

function set_nic()
    nic = io.popen("netstat -rn |grep ^0.0.0.0 |awk '{print $8}'"):read()
end


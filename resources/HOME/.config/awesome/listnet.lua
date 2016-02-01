function exec(arg)
    return arg
end
netctl_menu = {}
netctl = io.popen('netctl list')
for line in netctl:lines() do
    line = line:sub(3)
    table.insert( netctl_menu, { line, exec('sudo netctl stop-all && sudo netctl start '..line) } )
end
netctl:close()


for i, line in pairs(netctl_menu) do
    print(line[1], line[2])
end

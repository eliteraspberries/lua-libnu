local function readfile(f)
    local x = ''
    for line in io.lines(f) do
        x = x .. line .. '\n'
    end
    return x
end
local function sub(subs, s)
    local out = s
    for _, x in ipairs(subs) do
        local pattern, replace = table.unpack(x)
        out = string.gsub(out, pattern, replace)
    end
    return out
end
local subs = {
    {'/%*.-%*/', ''},
    {'^#.*', ''},
    {'^(.+)', '    %1'},
    {'(.+)$', '%1\n'},
}
local tmpname = os.tmpname()
local tmp = io.open(tmpname, 'w')
io.output(tmp)
for line in io.lines('nu.h') do
    io.write(sub(subs, line))
end
io.close(tmp)
local h = readfile(tmpname)
subs = {
    {'{{nu.h}}', h},
    {'$', '\n'},
}
local out = io.open('libnu.lua', 'w')
io.output(out)
for line in io.lines('libnu.lua.in') do
    io.write(sub(subs, line))
end
io.close(out)

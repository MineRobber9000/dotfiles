local palPal = require("/palPal")
local t = palPal.storePalette(term)
local palCollection = require("/palCollection")
local function loadPalette(n)
	palPal.loadPalette(term,palCollection.palettes[n])
	local colors = {}
	for k,v in pairs(palCollection.colors[n]) do colors[k]=v end
	setmetatable(colors,{__index=_G.colors})
	return colors
end
local printError = _G.printError
local colors = loadPalette("c64")
setfenv(printError,setmetatable({colors=colors},{__index=_ENV}))
term.setBackgroundColor(colors.blue)
term.setTextColor(colors.purple)
term.clear()
term.setCursorPos(1,1)
print("COMPUTERCRAFT 1.80PR7")
print("LUA SYSTEM")
print()
local running = true
local function exit() running = false end
while running do
    write("> ")
    local prog = read()
    local chunk = load(prog)
    if chunk then
        setfenv(chunk,setmetatable({peripheral=setmetatable({},{__index=function(t,k) t[k]=function() error("Cannot use peripherals!") end return t[k] end}),colors=colors,exit=exit},{__index=_ENV}))
        local ok,res = pcall(chunk)
        if not ok then printError(res) end
        if ok then print(ok) end
    end
end
palPal.loadPalette(term,t)
colors = _G.colors
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.setCursorPos(1,1)
term.clear()

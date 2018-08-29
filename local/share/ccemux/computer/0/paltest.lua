local palPal = require("/palPal")
local t = palPal.storePalette(term)
local palCollection = require("/palCollection")
local name = "Commodore 64 Palette"
local pal = "c64"
local bgcolor = "blue"
local textcolor = "purple"
palPal.loadPalette(term,palCollection.palettes[pal])
term.setBackgroundColor(palCollection.colors[pal][bgcolor])
term.clear()
term.setCursorPos(1,1)
for i=1,16 do
    term.setCursorPos(1,i)
    term.setBackgroundColor(math.pow(2,i-1))
    term.clearLine()
end
term.setTextColor(palCollection.colors[pal][textcolor])
term.setBackgroundColor(palCollection.colors[pal][bgcolor])
term.setCursorPos(1,18)
print((name or pal)..' - palette "'..pal..'"')
write("Source: "..palCollection.sources[pal])
parallel.waitForAny(function() sleep(60) end,function() local kc repeat _,kc = os.pullEvent("key") until kc==keys.f1 end) 
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
palPal.loadPalette(term,t)
term.clear() term.setCursorPos(1,1)

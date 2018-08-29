local pal = ...
local q = ""
local palCollection = require("/palCollection")
local palPal = require("/palPal")
local backup = palPal.storePalette(term)
palPal.loadPalette(term,palCollection.palettes[pal])
term.setBackgroundColor(1)
term.clear()
local fucc = paintutils.loadImage("test"..q..".nfp")
paintutils.drawImage(fucc,1,1)
local kc
repeat
    _,kc = os.pullEvent("key")
until kc==keys.f1
palPal.loadPalette(term,backup)
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1,1)

pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--blazzle
--by minerobber9000
mapdata = {
	{x=0,y=0,e=2,triggers={{0,0,function() otextbox("fight   item\nrun",function() otextbox("penelope attacks!") end) end}}},
	{x=1,y=0,w=1,triggers={{4*8,5*8,function(m) otextbox("the switch clicks.",function() m.x = 2 end) m.triggers[1][3] = function() otextbox("nothing happens.") end m.e = 3 end}},onload=function(m) if not m.e then qtextbox({"oh no!","the path is flooded!","see that switch?","press it!"}) end end},
	{x=3,y=0,w=2,triggers={}}
}
x = 56
y = 56
f = 2
timer=0
delay=0
mapn = 1
textbox = {open=false,text="",cb=function() end}
function otextbox(t,cb)
	-- don't open a new textbox
	-- if there's already one
	-- open!
	if textbox.open then return end
	cb = cb and cb or function() end
	textbox.text = t
	textbox.cb = cb
	textbox.open = true
end
function qtextbox(l)
	t = l[1]
	del(l,t)
	otextbox(t,function() if #l>0 then qtextbox(l) end end)
end
function change_map(n)
	if not mapdata[n] then return end -- refuse to load invalid map
	mapn = n
	if mapdata[n].onload then mapdata[n].onload(mapdata[n]) end
end
function can_trigger(tx,ty,tf)
	tx = tx+(tf==2 and 8 or (tf==3 and -8 or 0))
	ty = ty+(tf==1 and 8 or (tf==0 and -8 or 0))
	t = mapdata[mapn].triggers
	for i=1,#t do
		if t[i][1]==tx and t[i][2]==ty then return true end
	end
	return false
end
function activate(tx,ty,tf)
	tx = tx+(tf==2 and 8 or (tf==3 and -8 or 0))
	ty = ty+(tf==1 and 8 or (tf==0 and -8 or 0))
	t = mapdata[mapn].triggers
	for i=1,#t do
		if t[i][1]==tx and t[i][2]==ty then
			t[i][3](mapdata[mapn])
		end
	end
end
function oob(tx,ty)
	if tx<0 or tx>120 or ty<0 or ty>120 then return true end
	return false
end
function solid(tx,ty)
	-- if oob(tx,ty) then return true end
	-- yes: if btn(5), treat every inbounds object as non-solid
	if btn(5) then return false end
	maploc = mapdata[mapn]
	return fget(mget(flr(tx/8)+(maploc.x*16),flr(ty/8)+(maploc.y*16)),0)
end
function move(dx,dy,df)
	f=df
	if solid(x+dx,y+dy) then return end
	if oob(x+dx,y+dy) then
 		if (y+dy)<0 then --north
 			if not mapdata[mapn].n then return end
 			change_map(mapdata[mapn].n)
 			y+=128
 		elseif (y+dy)>120 then --south
 			if not mapdata[mapn].s then return end
 			change_map(mapdata[mapn].s)
 			y-=128
 		elseif (x+dx)<0 then --west
 			if not mapdata[mapn].w then return end
 			change_map(mapdata[mapn].w)
 			x+=128
 		elseif (x+dx)>120 then --east
 			if not mapdata[mapn].e then return end
 			change_map(mapdata[mapn].e)
 			x-=128
 		end
	end
	x=x+dx
	y=y+dy
end
function _init()
	qtextbox({"hi! i'm minerobber!","welcome to blazzle!","this game has many puzzles!"})
end
function _draw()
	if delay>0 then rectfill(0,0,127,127,0) return end
	maploc = mapdata[mapn]
	rectfill(0,0,127,127,3)
	map(maploc.x*16,maploc.y%16)
	spr(f,x,y)
	if textbox.open then
	 rectfill(4,84,124,124,5)
		spr(112,0,80)
		for i=1,14 do spr(116,(i*8),80) spr(116,(i*8),120) end
		spr(113,120,80)
		spr(114,0,120)
		spr(115,120,120)
		for i=1,4 do spr(117,0,(80+(i*8))) spr(117,120,(80+(i*8))) end
		print(textbox.text,8,88,7)
	end
end
function _update()
	timer = (timer+1)
	if delay>0 then
 		delay-=1
 		return
	end
	if (not textbox.open) then
			if btnp(0) then move(-8,0,3) end --x-=8 f=3 end
			if btnp(1) then move(8,0,2) end --x+=8 f=2 end
			if btnp(2) then move(0,-8,0) end --y-=8 f=0 end
			if btnp(3) then move(0,8,1) end --y+=8 f=1 end
	end
	if btnp(4) then
 		if textbox.open then
 			textbox.open = false
 			textbox.cb()
		else
  			if can_trigger(x,y,f) then
  				activate(x,y,f)
			end
		end
	end
end
__gfx__
bbbbbbbbbbbbbbbb00bbbb0000bbbb00555555551111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbffffffb00bfff0000fffb00566666651111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbffffffff00ffff0000ffff00566666651111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbf7cffc7f00f7cf0000fc7f00566556651111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffff00ffff0000ffff00566556651111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888880088880000888800566666651111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888880088880000888800566666651111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddddddddddd00dddd0000dddd00555555551111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999555555559999999559999999999999959999999999999999999999995999999999999995599999995555555555555555000000000000000000000000
99999999999999999999999599999999999999999999999999999999999999995999999999999995599999999999999559999999000000000000000000000000
99999999999999999999999599999999999999999999999999999999999999995999999999999995599999999999999559999999000000000000000000000000
99999999999999999999999599999999999999999999999999999999999999995999999999999995599999999999999559999999000000000000000000000000
99999999999999999999999599999999999999999999999999999999999999995999999999999995599999999999999559999999000000000000000000000000
99999999999999999999999599999999999999999999999999999999999999995999999999999995599999999999999559999999000000000000000000000000
99999999999999999999999599999999999999999999999999999999999999995999999999999995599999999999999559999999000000000000000000000000
99999999999999999999999599999999999999995999999999999995555555555999999955555555555555559999999559999999000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000075570000755700000000000075570000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770077777700777777007777770000000000075570000000000000000000000000000000000000000000000000000000000000000000000000000000000
07555577775555700755557777555570777777770075570000000000000000000000000000000000000000000000000000000000000000000000000000000000
07577575575775700757757557577570555555550075570000000000000000000000000000000000000000000000000000000000000000000000000000000000
07577575575775700757757557577570555555550075570000000000000000000000000000000000000000000000000000000000000000000000000000000000
07555577775555700755557777555570777777770075570000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770077777700777777007777770000000000075570000000000000000000000000000000000000000000000000000000000000000000000000000000000
00755700007557000000000000000000000000000075570000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000050505000000000000000000000000000505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000050505000000000000000000000000000505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000050505000000000000000000000000000505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000050505000000000000000000000000000505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000050505000000000000000000000000000505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000040000000000050505000000000000000400000000000505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000001c11111111111111111111111111111111111111050505111111111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000001810101010101010101010101010101010101010050505101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000001810101010101010101010101010101010101010050505101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000001a17171717171717171717171717171717171717050505171717171717171717171717171717171717170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000050505000000000000000000000000000505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000050505000000000000000000000000000505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000050505000000000000000000000000000505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000050505000000000000000000000000000505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000050505000000000000000000000000000505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000050505000000000000000000000000000505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

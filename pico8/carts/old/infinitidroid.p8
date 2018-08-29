pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- pico-64 infinitroid
-- by dark griffin
//set to 64 pix
poke(0x5f2c,3)
//cart seed
trand=rnd(100)
gamestate="title"
ev_dir=0
ev_state=0
ev_y=0

wepsounds={17,19,20,23}

//time
mtime={0,0,0}
esct={0,0,0}
mpickups=0
//sec per room/ev
esc_roomt=4
esc_evt=10
escmode=false
gamewon=false
bosswon=false

debug=false

//game speed
g_delay=1 // < change this!
gdelay=0

//animation
gframe=0
gframe_max=4
ani_delay=4
adelay=0
as=4
//offset render
af={
{0,0},
{4,0},
{0,4},
{4,4}
}

//code entry
seed=0
code={}
code_sel=1
code_len=8
code_sym={
"⬅️","➡️","⬆️","⬇️"
}

// s= sprite index i=frm
// i of 0 = determine by x pos
//t values 0=empty 1=solid
// 2=ramp (index is slope)
//first s value is sky
tiles={
{s=0,i=0,t=0}, //empty
{s=64,i=0,t=1}, //ground
{s=65,i=1,t=1}, //ramps
{s=65,i=2,t=1},
{s=65,i=3,t=2},
{s=65,i=4,t=2},
{s=77,i=0,t=1} //no draw w col
}

areacolor={
1,0,2,0
}

//powerups
// 100-heat 101-jump 102-health
// 103-gun 2 104-gun 3 105-gun 4
// 106-exp
//index is f num
areapowers={
//surface
{101,102,103},
//caves
{101,103,103,102},
{103,102,103,100},
//lava
{103,104,102,101},
{102,104,104,103},
{101,102,104,105},
//depths
{103,104,104,105},
{102,104,104,105},
{103,103,104,105},
{103,105,101,102},
//boss, leave blank!
{}
}

//props
props={
	{
	//ship
		{s=192,o=1,xp=0,yp=0},
		{s=192,o=2,xp=1,yp=0},
		{s=192,o=3,xp=0,yp=1},
		{s=192,o=4,xp=1,yp=1},
		chunk=160,
		x=0,y=0,
		nodraw=true
	},
	//ev shaft
	{
		{s=196,o=1,xp=0,yp=0},
		{s=196,o=2,xp=1,yp=0},
		{s=196,o=1,xp=0,yp=1},
		{s=196,o=2,xp=1,yp=1},
		chunk=161,
		x=0,y=0
	},
	//ev bottom
	{
		{s=196,o=3,xp=0,yp=0},
		{s=196,o=4,xp=1,yp=0},
		chunk=162,
		x=0,y=0
	},
	//statue
	{
		{s=199,o=1,xp=0,yp=0},
		{s=199,o=2,xp=1,yp=0},
		{s=199,o=3,xp=0,yp=1},
		{s=199,o=4,xp=1,yp=1},
		chunk=163,
		x=0,y=0,
		nodraw=true
	},
	{
	},
	//boss
	{
		{s=98,o=1,xp=-1,yp=0},
		{s=98,o=2,xp=0,yp=0},
		{s=98,o=3,xp=-1,yp=1},
		{s=98,o=4,xp=0,yp=1},
		
		{s=99,o=1,xp=1,yp=0},
		{s=99,o=3,xp=1,yp=1},
		{s=99,o=4,xp=2,yp=1},
		
		{s=114,o=1,xp=-1,yp=2},
		{s=114,o=2,xp=0,yp=2},
		{s=114,o=3,xp=-1,yp=3},
		{s=114,o=4,xp=0,yp=3},
		
		chunk=166,
		x=0,y=0,nodraw=true
	}
}

//current room
// t=tile ids w= width
// h= height
// toffset=skin
room={
t={},h=12,w=16,toffset=0,
props={},dif=0
}

cp={
x=0,y=0,wx=0,wy=0,
etime={}
}
function respawn()
	p.x=cp.x
	p.y=cp.y
	w_px=cp.wx
	w_py=cp.wy
	p.health=100
	pickup_health(pickups.health*100)
	p.weap=0
	p.inv=30
	regen_room=true
	gamestate="play"
	escmode=false
	pickups.exp=0
	esct=tcopy(cp.etime)
end
function checkpoint()
	cp.x=p.x
	cp.y=p.y
	cp.wx=w_px
	cp.wy=w_py
	cp.etime=tcopy(esct)
end

//player obj var p
p={x=30,y=16,
flpx=false,
flpy=false,
sprite=0,
frm=1,
weap=0,
health=100,
res=0,
inv=0,
ammo={1,0,0,0}}

// index roomx..","..(roomy*mw)
collected={}
pickups={heat=0,jump=0,health=0,
gun2=0,gun3=0,gun4=0,exp=0}

function draw_pickup_hud()
	//weap
		spr(211+p.weap,56,48)
	//jump
	draw_small(224,1,43,49)
	rend_num(pickups.jump,48,48)
	//suit
	if pickups.heat>0 then
		draw_small(2,1,50,55)
	else
		draw_small(0,1,50,55)
	end
	//ammo
	if p.weap>0 then
		rend_num(p.ammo[p.weap+1],56,
		57,true)
	end
	//time
	if escmode then
		draw_small(25,gframe,43,55)
		rend_time(esct,10,48)
	else
		rend_time(mtime,10,48)
	end
	//player health
	draw_x=10
 tanks_full=flr(p.res/100)
	for i=1,pickups.health do
		if tanks_full>0 then
			draw_small(225,3,draw_x,56)
			tanks_full-=1
		else
			draw_small(226,4,draw_x,56)
		end
		draw_x+=4
	end
	rectfill(11,54,-flr((
		-p.health/3.5))+10,54,12)
	rect(10,53,-flr((-100/3.4))
		+10,55,5)
end

function _init()
	for i=0, room.h*room.w-1 do
		add(room.t,1)
	end
	regen_room=true
end

function _update()
	if gamestate=="title" then
		if btnp(5) then
			gamestate="code"
			sfx(27)
		end
		play_music(13)
	end

	if gamestate=="code" then
		if btnp(4) and #code==0 then
			gamestate="title"
		end
		if #code<code_len then
			if btnp "0" then
				add(code,0)
			end
			if btnp "1" then
				add(code,1)
			end
			if btnp "2" then
				add(code,2)
			end
			if btnp "3" then
				add(code,3)
			end
		else
			if btnp "5" then
				seed=0
				seed_step=1
				for v in all(code) do
					seed=seed+(v*seed_step)
					seed_step+=1
				end
				world_setup()
				gamestate="play"
				sfx(28)
				--world[wtoid(w_px-1,w_py)]=
			--w_new_room(106,0,w_px-1,w_py)
			end
		end
		if btnp "4" and #code>0 then
				code[#code]=nil
		end
		
	end

	if gamestate=="play" then
		gdelay-=1
		//h dam
		if world[wtoid(
			w_px,w_py)].d==2
		and world[wtoid(
			w_px,w_py)].t==0
		and pickups.heat==0 then
			if gframe==2 then
			p.health-=1
			end
			heatdeath=true
		else
			heatdeath=false
		end
		
		if gdelay==0 then
			update_p()
			update_world()
			update_pshoots()
			update_bullets()
			update_enemies()
			foreach(drops,update_drops)
			if p.health<0 then
			//game over
			ev_y=60
			music(-1)
			sfx "15"
			gamestate="result"
			end
		end

		if gdelay < 1 then
			gdelay = g_delay
		end
		
		if btn"2" then
		gamestate="map"
		end
	end
	
	if gamestate=="map" then
		if not btn"2" then
			gamestate="play"
		end
	end
	
	if gamestate=="result" then
		if ev_y>0 then ev_y-=1 end
		if ev_y==0
		and btnp "5" then
			if gamewon then
				run() //reset
			else
				respawn()
			end
		end
	end
	
	if gamestate=="ev_ride" then
	if escmode==false then
	play_music(14) end
	//scroll
		if ev_state==0 then
			if ev_dir==0 then
			 ev_y+=1
			 if ev_y > 63 then
			 	ev_state=1
			 end
			end
			if ev_dir==1 then
			 ev_y-=1
			 if ev_y < -63 then
			 	ev_state=1
			 end
			end
		end
		//shift pos
		if ev_state==1 then
			if ev_dir==0 then
				if ev_y==64 then
					w_py+=1
					regen_room=true
					room.dif=
						world[wtoid(w_px,w_py)].d
					gen_room(world[
						wtoid(w_px,w_py)].t,
						w_px+w_py+seed)
					ev_y=-64
					ev_state=2
				end
			end
			if ev_dir==1 then
				if ev_y==-64 then
					w_py-=1
					regen_room=true
					room.dif=
						world[wtoid(w_px,w_py)].d
					gen_room(world[
						wtoid(w_px,w_py)].t,
						w_px+w_py+seed)
					ev_y=64
					ev_state=2
				end
			end
		end
		//scroll new room
		if ev_state==2 then
			if ev_dir==0 then
			 ev_y+=1
			 if ev_y==0 then
			 	ev_state=3
			 end
			end
			if ev_dir==1 then
			 ev_y-=1
			 if ev_y==0 then
			 	ev_state=3
			 end
			end
		end
		//enable play
		if ev_state==3 then
			ev_y=0
			ev_state=0
			gamestate="play"
			regen_room=true
			if escmode==false then
			checkpoint()
			end
		end
	end
	-- state message
	if gamestate=="message" then
		if ev_y>0 then
			ev_y-=1
			//award
			if ev_y==1 then
				if ev_dir==0 then
					pickups.heat+=1
				end
				if ev_dir==1 then
					pickups.jump+=1
				end
				if ev_dir==2 then
					pickups.health+=1
					pickup_health(100)
				end
				if ev_dir==3 then
					pickups.gun2+=1
					p.ammo[2]+=5
				end
				if ev_dir==4 then
					pickups.gun3+=1
					p.ammo[3]+=5
				end
				if ev_dir==5 then
					pickups.gun4+=1
					p.ammo[4]+=5
				end
				if ev_dir==6 then
					pickups.exp+=1
				end
			end
		end
		//allow resume
		if ev_y==0 then
			
			if btn "5" then
			cur_music=99
				if messages[ev_dir+1].o then
					ev_dir=messages[ev_dir+1]
						.o-1
					ev_y=20
					gamestate="message"
				else
					//sd
					if messages[ev_dir+1].sd
					then
						ev_dir=0
						ev_y=0
						checkpoint()
						escmode=true
						gamestate="play"
					else
						gamestate="play"
					end -- sd
				end --o
			end-- btn
		end-- time
	end-- message
end

function _draw()
	cls()
	if gamestate=="title" then
		print("infinitroid",9,18)
		spr(187,16,28)
		spr(188,24,28)
		spr(186,35,28)
		spr(180,4,36)
		spr(181,12,36)
		spr(182,24,36)
		spr(183,32,36)
		spr(184,40,36)
		spr(185,48,36)
		print("press ❎",16,46)
	end
	
	if gamestate=="code" then
		print("enter a",19,12)
		print("mission code",
		12,18)
		disp_str=""
		disp_c=0
		for v in all(code) do
			disp_str=disp_str .. 
			code_sym[v+1]
			disp_c+=1
		end
		if disp_c==code_len then
			print("press ❎",16,42)
			print("to launch",
			14,50)
		end
		for i=disp_c,code_len do
			disp_str=disp_str .. "▒"
		end
		print(disp_str,0,32)
	end
	
	if gamestate=="play" then
		mtime_tick()
		draw_room()
		//animation
		a_tick()
		draw_enemies()
		foreach(drops,draw_drops)
		draw_player()
		draw_props()
		draw_bullets()
		//healing
		if healing then
			spr(200+gframe,28,36)
			healing=false
		end
		
		//draw hud
		rectfill(0,48,64,64,0)
		draw_w_grid()
		draw_pickup_hud()
		
		if heatdeath then
			print("heat warning!",6,24,
				7+gframe)
		end
	end
	
	if gamestate=="map" then
		a_tick()
		mtime_tick()
	 draw_world()
	 draw_w_grid()
	 draw_pickup_hud()
	end
	if gamestate=="result" then
		gframe=2
		//display code
		print("mission end",10,0,8)
		spr(250,24,17)
		spr(251,32,17)
		print(disp_str,0,23,7)
		//display result
		if escmode then
			//check death or victory
			if gamewon then
				//show win
				spr(218,9,9)
				spr(247,17,9)
				spr(248,25,9)
			 spr(249,33,9)
				spr(217,41,9)
			else
				//show esc fail
				spr(205,8,9)
				spr(206,16,9)
				spr(207,24,9)
				spr(189,32,9)
			 spr(190,40,9)
			 spr(191,48,9)
			end
		else
			//show death
			spr(219,8,9)
			spr(220,16,9)
			spr(221,24,9)
			spr(222,32,9)
			spr(223,40,9)
		end
		//show time
		spr(245,8,31)
		spr(246,16,31)
		rend_time(mtime,27,31)
		//percent
		spr(252,8,40)
		spr(253,16,40)
		spr(254,24,40)
		total=0
		total+=pickups.health
		total+=pickups.heat
		total+=pickups.jump
		total+=pickups.exp
		total+=pickups.gun2
		total+=pickups.gun3
		total+=pickups.gun4
		percent=flr((total/mpickups)*100)
		xdraw=rend_num(percent,36,40)
		spr(255,xdraw+36,40)
		//button
		if ev_y==0 then
			if gamewon then
			print("❎ new game",
			4,52,11)
			else
				print("❎ respawn",
				4,52,11)
			end
		end
	end
	
	if gamestate=="ev_ride" then
		camera(0,ev_y)
		draw_room()
		camera()
		draw_player()
		draw_enemies()
		//hud
		rectfill(0,48,64,64,0)
		draw_pickup_hud()
		draw_w_grid()
		//time if escmode
		if escmode then 
		mtime_tick()
		draw_pickup_hud()
		a_tick()
		end
	end
	
	--gamestate message
	if gamestate=="message" then
		print(messages[ev_dir+1][1],
		0,16,11)
		print(messages[ev_dir+1][2],
		0,24,7)
		print(messages[ev_dir+1][3],
		0,32,7)
		print(messages[ev_dir+1][4],
		0,40,7)
		if messages[ev_dir+1].s then
			spr(messages[ev_dir+1].s,
				30,4)
		end
		if ev_y==0 then
			print("❎ to continue",
			4,52,11)
		end
	end --end message
end
-->8
--rendering player and rooms

//render the player based on
// their actions
function draw_player()
	if pickups.heat==1 then
		suit_offset=2
	else
 	suit_offset=0
	end
	if pm.grounded then
		p.sprite=0+suit_offset
	else
		p.sprite=1+suit_offset
	end
		if p.inv==0 then
			draw_obj(p)
		else
			if gframe%2==0 then
				draw_obj(p)
			end
		end
end

//draw the active room tiles
function draw_room()
	x_index=0
	y_index=0
	//flood render area w t1 color
	rectfill(0,0,63,room.h*4-1,
	tiles[1].s)
	for v in all(room.t) do
		if(x_index >= room.w) do
			x_index=0
			y_index+=1
		end
			draw_tile(v,x_index,y_index)
		x_index+=1
	end
end

//draw a tile to screen
function draw_tile(id,x,y)
 //silent fail
 if id > 1 and id < 16 then
		if id==7 then
			offset=0
		else
			offset=room.toffset
		end
		i=0
		if tiles[id].i == 0 then
		 i=(x%4)+1
		 else
		 i=tiles[id].i
		end
		draw_small(tiles[id].s+offset,
			i,x*4,y*4)
	end
end

//render all props
function draw_props()
 for v in all(room.props) do
 	draw_prop(v,v.x+1,v.y)
 end
end

function draw_prop(prop,x,y)
	for p in all(prop) do
		if p.s then
			draw_small(p.s,p.o,
				x+(p.xp*4),y+(p.yp*4))
		end
	end
end

//draw a general game object
function draw_obj(obj)
	draw_obj_f(obj,gframe)
end

//draw object with frame x
function draw_obj_f(obj,f)
	draw_small(obj.sprite,
	f,obj.x,obj.y,obj.flpx)
end

//draw sprite num, offset
// x and y.
function draw_small(sprite,frame,
x,y,flpx)
	if not flpx then
		flpx=false
	end
	s_rowy=flr(sprite/16)
	s_rowx=(sprite%16)
	s_x1=(s_rowx*8)+
		af[frame][1]
	s_y1=(s_rowy*8)+
		af[frame][2]
	sspr(s_x1,s_y1,as,as,
	x,y,as,as,
	flpx,false)
end

//tick animation 1 time tick
// and update gframe if needed
function a_tick()
adelay-=1
if adelay < 1 then
	gframe+=1
		if gframe > gframe_max then
		gframe=1 end
	adelay = ani_delay
end
end
-->8
--gen room data functions
// the chunk ids are as follows
// 0 to 7 = floor chunks
// 8 to 15 = roof chunks
// 16 to 23 = middle fill
// 32, 33 = left door,wall
// 34, 35 = right door,wall
// some are props.

//generate room
function gen_room(t,s)
	tiles[1].s=areacolor[
		room.dif+1]
	srand(s)
	for x=0,room.w-1 do
		for y=0,room.h-1 do
			room.t[rxy_to_dex(x,y)]=
			1
		end
	end
	clear_enemies()
	clear_props()
	//normal room
	if t==0 then 
		
		build_strip(0,room.h-4,0,8)
		room.toffset=0
		if room.dif >0 then
			room.toffset=(room.dif*2)+2
		end
		if room.dif > 0 then
			build_strip(0,room.h-8,0,8,5)		
		end
		//if not top
		if w_py>0 then
			build_strip(0,0,8,8)
		end
		build_doorways()
		roomenemy=true
	end
	//power up room
	if t>99 then 
		room.toffset=2
		roomenemy=false
		build_strip(0,room.h-4,0,0)
		
		build_strip(0,0,8,0)
		add_prop(4,27,36)
		build_doorways()
	end
	//elevator room
	if t==1 then
		build_strip(0,room.h-4,0,0)
		build_strip(0,0,8,0)
		room.toffset=2
		roomenemy=false
		build_doorways()
		add_prop(2,27,40)
	end
	//starting room
	if t==2 then 
		build_strip(0,room.h-4,0,8)
		build_doorways()
		room.toffset=0
		roomenemy=false
		add_prop(1,27,36)
	end
	//elevator bottom
	if t==3 then
		build_strip(0,room.h-4,0,0)
		room.toffset=2
		roomenemy=false
		build_doorways()
		add_prop(3,27,40)
	end
	//boss
	if t==5 then
		build_strip(0,room.h-4,0,0)
		build_strip(0,0,8,0)
		room.toffset=10
		build_doorways()
		roomenemy=false
		if bosswon==false then
			add_prop(6,5,33)
		end
	end
		room_espawns()
	
	//change music
	if escmode==false then
	if t==0 then
		play_music(room.dif)
	else
		if t==1 or t==3 or t>99 then
			play_music(5)
		end
		if t==2 then
			play_music(4)
		end
		if t==5 and bosswon==false then
			play_music(6)
		end
		end
	end
end

function build_doorways()
	//walls
	for i=0,room.h-8,4 do
		gen_chunk(33,0,i)
		gen_chunk(35,room.w-4,i)
	end
	if w_grid[1]>-1 then
		//left
		gen_chunk(32,0,room.h-4)
	else
		//walls
		gen_chunk(33,0,room.h-4)
	end
	if w_grid[7]>-1 then
		//right
		gen_chunk(34,room.w-4,room.h-4)
	else
	 //walls
	 gen_chunk(35,room.w-4,room.h-4)
	end
end

function build_strip(xoff,y,
	cid,clen,hlen)
	for i=xoff,room.w-xoff-1,4 do
		choice=flr(rnd(clen))+cid
		hmod=flr(rnd(hlen))
		gen_chunk(choice,i,y-hmod)
	end
end

function clear_props()
	for i=1,#room.props do
		del(room.props,room.props[i])
	end
end

function add_prop(p_name,x,y)
	_prop=props[p_name]
	_prop.x=x
	_prop.y=y
	add(room.props,_prop)
		gen_chunk(props[p_name].chunk,
		flr(x/4)+flr(x%4)-3,
		flr(y/4)+flr(y%4)-2)
end

//this parses
// map data to room.
function gen_chunk(c_id,x,y)
	//get map area
	c_id=c_id*4
	c_x1=(c_id%128)
	c_y1=flr (c_id/128)*4
	//parse m chunk
	for px=0, 3 do
		for py=0, 3 do
			m_id=mget(c_x1+px,c_y1+py)
			if m_id==0 then
				m_id=128 //set empty
			end
			m_id-=128 //tile index
			dex = rxy_to_dex(x+px,y+py)
			if m_id==32 then
			else
					room.t[dex] = m_id+1
			end
		end
	end
	
end


-->8
--player movement functions

pm={
xspd=0,
yspd=0,
grav=1,
grounded=false,
override_g=false,
jp=10,
curj=0,
}

function update_p()
//hit
if p.inv>0 then
	p.inv-=1
else
h=check_for_hit(p.x-1,p.y-1,p.x+2,
	p.y+3,1)
	if h>0 then player_hurt(
	h+(h*w_py)) 
		p.inv=20
		sfx(26)
	end
end
//weapon swap
if btn(3) and btnp(4) then
	p.weap+=1
	sfx(30)
	if p.weap==1 and 
		pickups.gun2<1 then
		p.weap+=1
	end
	if p.weap==2 and 
		pickups.gun3<1 then
		p.weap+=1
	end
	if p.weap==3 and 
		pickups.gun4<1 then
		p.weap=0
	end
	if p.weap>3 then
		p.weap=0
	end
end

--ship interact
function p_ship_interact()
	if escmode==true then
		--escape in ship
		gamewon=true
		music(-1)
		sfx(14)
		gamestate="result"
	else
		--heal player
		pickup_health(1)
		healing=true
	end
end

if pm.override_g==false then
 //get bottom collision
	bottom=pixcol(p.x+1,p.y+4)
	if bottom > 0 then
				pm.yspd=0
				pm.grounded=true
	else pm.grounded=false end
else
	//no or for next frame
	pm.override_g=false
	pm.grounded=true
end
	//also check top for roof
		top=0
		if pm.curj>0 then
		 top=pixcol(p.x+1,p.y-1)
		else
			top=pixcol(p.x+1,p.y)
		end
		if top > 0 then
		pm.yspd=0
		pm.curj=0
		p.y+=1
	end
	//grav pulls down
	if pm.grounded==false 
	and pm.curj==0 then
	pm.yspd = pm.grav
	end
	
	//jump update
	if btn(4) and pm.curj==0 
	and pm.grounded==true and
	btn(3)==false then
		pm.curj=pm.jp
		--pickup jump calculation
		+(pickups.jump*4)
		sfx"22"
	end
	
	//push up if jumping
	if pm.curj > 0 then
		pm.grounded=false
		pm.yspd = -1
		pm.curj-=1
		if btn(4)==false then
			pm.curj=0
		end
	end
	
	//update y move
	if pm.grounded==false then
	p.y=p.y+pm.yspd
	end
	//if stuck in ground
	if pixcol(p.x+1,p.y+3)>0 then
		p.y-=1
	end
	//walk
	pm.xspd=0
	if btn"0" then
		pm.xspd-=1
		p.flpx=true
	end
	if btn"1" then
		pm.xspd+=1
		p.flpx=false
	end
	
	//check for limits
	//trace collision
	l=pixcol(p.x+1+pm.xspd,p.y)
	l2=pixcol(p.x+1+pm.xspd,p.y+3)
	if pm.xspd<-2 then 
	pm.xspd=-2 end
	if pm.xspd>2 then 
	pm.xspd=2 end
	if l==0 and l2==0 then
		p.x+=pm.xspd
	end
	//slopes
	if l2==2 then
		//walk up slope
		p.x+=pm.xspd
		p.y-=abs(pm.xspd)
	end
	
		--ship interact
	if world[
	wtoid(w_px,w_py)].t==2 then
		if p.x<35 and p.x>26
		and p.y==36 and btn"3" then
			p_ship_interact()
		end	
	end
end
-->8
--gen functions, music, dialog

//dialog
// format is 4 str
// s=99 show sprite 99
// undefined show none
messages={
{"flame suit",
"hot areas can",
"now be explored",
"without harm.",
s=208
},
{"jump boost",
"suit jump boost",
"power extended.",
"",
s=209
},
{"energy tank",
"energy capacity",
"increased by",
"one tank.",
s=210
},
{"missile pickup",
"missiles + 5",
"⬇️(down)+🅾️(z)",
"cycles weapons",
s=212
},
{"electric blast",
"energy gun + 5",
"⬇️(down)+🅾️(z)",
"cycles weapons",
s=213
},
{"bomb ammo",
"bomb gun + 5",
"⬇️(down)+🅾️(z)",
"cycles weapons",
s=214
},
{"bio experiment",
"warning!!!",
"self destruct",
"has activated!",
s=215,
o=8},
{"new objective",
"escape to your",
"ship with the",
"bio experiment.",
s=216,sd=true
}
}

function tcopy(orig)
 local orig_type = type(orig)
 local copy
 if orig_type == 'table' then
  copy = {}
  for orig_key, orig_value in 
  	pairs(orig) do
   copy[tcopy(orig_key)] = 
   	tcopy(orig_value)
  end
  setmetatable(copy, 
  	tcopy(getmetatable(orig)))
 else
  copy = orig
	end
 return copy
end

//player hit
--returns bool
function p_hit(x,y,x2,y2)
	if x<p.x+3 and x>p.x-3
	and y<p.y+4 and y>p.y-4
	then return true else
	return false end
end

// called to change music.
cur_music=99
function play_music(id)
if cur_music != id then
	music(id,1000,7)
	cur_music=id
end
end

//count room or ev to escape t
function add_esc_t(ev)
	if ev then
		esct[2]+=esc_evt
	else
		esct[2]+=esc_roomt
	end
	while esct[2] > 59 do
		esct[1]+=1
		esct[2]-=60
	end
end

//forward time 1 frame
function mtime_tick()
	mtime[3]+=2
	if mtime[3] > 59 then
		mtime[2]+=flr(mtime[3]/59)
		mtime[3]-=60
	end
	if mtime[2] > 59 then
		mtime[1]+=flr(mtime[2]/59)
		mtime[2]-=60
	end
	if mtime[1] > 99 then
		mtime[1]=99
	end
	//esc mode timer
	if escmode then
		play_music(9)
		esct[3]-=2
		if esct[3] < 0
		and (esct[2] > 0 
		or esct[1] > 0) then
			esct[2]-=1
			esct[3]+=60
		end
		if esct[2] < 0
		and esct[1] > 0 then
			esct[1]-=1
			esct[2]+=60
		end
		if esct[1] < 1
		and esct[2] < 1
		and esct[3] < 0 then
			//game over
			p.health=-1
		end
	end
end

//render a time to screen
function rend_time(t,x,y)
	t1=t[1]
	t2=t[2]
	t3=t[3]
	dx=x
	dx += rend_num(t1,dx,y,true)
	pset(dx+1,y+1,9)
	pset(dx+1,y+3,9)
	dx+=3
	dx += rend_num(t2,dx,y,true)
	pset(dx+1,y+1,9)
	pset(dx+1,y+3,9)
	dx+=3
	dx += rend_num(t3,dx,y,true)
end

//given a number and an
// x,y pos, render it
//returns pix lenth
function rend_num(num,x,y,
always2)
	numarray={}
	local tnum=num
	while tnum > 0 do
		add(numarray,flr(tnum%10))
		tnum=flr(tnum/10)
	end
	
	if always2 and #numarray <2
	then
		add(numarray,0)
	end
	if num==0 then
		add(numarray,0)
	end
	
	//invert array
	numarray2={}
	for i=#numarray,1,-1 do
		add(numarray2,numarray[i])
	end
	
	//for each entry, render
	// number
	local x_draw=x
	for v in all(numarray2) do
		//check number, draw
		// the sprite
		if escmode then
			s_id=225+((gframe-1)*5)
			s_id+=flr(v/2)
			frame=flr(v%2)+1
			if v==0 then
			frame=1
			s_id=225+((gframe-1)*5)
		end
		else
		 s_id=225
		 s_id+=flr(v/2)
			frame=flr(v%2)+1
			if v==0 then
			frame=1
			s_id=225
		end
		
		end
		s_rowy=flr(s_id/16)
		s_rowx=(s_id%16)
		s_x1=(s_rowx*8)+
		af[frame][1]
	s_y1=(s_rowy*8)+
		af[frame][2]
	sspr(s_x1,s_y1,4,5,
	x_draw,y,4,5,
	false,false)
	x_draw+=4
	end
	return x_draw-x
end

//given a pos, get
// tile col
function pixcol(px,py)
	x=flr(px/4)
	y=flr(py/4)
	return tcol(x,y)
end

//given pixel x,y
// index for tile
// for slopes
function pixi(px,py)
	//convert to tile space
	x=flr(px/4)
	y=flr(py/4)
	//keep check in room bounds
	if y < 0 then y=0 end
	if x < 0 then x=0 end
	if y > room.h-1 then 
		y=(room.h)-1 end
	if x > room.w-1 then
		x=(room.w)-1 end
	//return the tile i setting
	return tiles[room.t[
	rxy_to_dex(x,y)]].i
end

//given an x and y position
// in tile space
// get the collision setting
//	for the given tile
function tcol(x,y)
if y < 0 then y=0 end
if x < 0 then x=0 end
if y > room.h-1 then 
y=(room.h)-1 end
if x > room.w-1 then
x=(room.w)-1 end
	return tiles[room.t[
	rxy_to_dex(x,y)]].t 
end

//given a room x and y, get the
//room index in the table
function rxy_to_dex(x,y)
 r_index = (y*room.w) + x + 1
 return r_index
end
-->8
--bullet system, player health

shots={}
pshots=3
pcurshots=0

//edrops
drops={}
drop_list={
{s=23,t=20,f=1},
{s=23,t=50,f=3},
{s=22,t=75,f=1},
{s=22,t=100,f=3},
{s=13,t=-1,f=1},
{s=14,t=-2,f=1},
{s=15,t=-3,f=1}
}

//strength of p weaps
weap_str={1,3,4,6}

function make_drop(x,y,c)
	local drop=tcopy(drop_list[
		flr(rnd(#drop_list)+1)
		])
		if drop.t==-3
			and pickups.gun4==0 then
			drop=tcopy(drop_list[6])
		end
		if drop.t==-2
			and pickups.gun3==0 then
			drop=tcopy(drop_list[5])
		end
		if drop.t==-1
			and pickups.gun2==0 then
			drop=tcopy(drop_list[1])
		end
	drop.x=x
	drop.y=y
	if (rnd(100)+1)<c then
		add(drops,drop)
	end
end

function wipe_drops()
	for v in all(drops) do
		del(drops,v)
	end
end

function draw_drops(v)
		draw_small(v.s,
		v.f+flr(gframe/3),v.x,v.y)
end

function update_drops(v)
		if p_hit(v.x,v.y)
		then
			if v.t>0 then
				pickup_health(v.t)
				sfx(31)
			end
			if v.t==-1 then
				p.ammo[2]+=5
				sfx(32)
				if p.ammo[2]>
					pickups.gun2*5 then 
					p.ammo[2]=pickups.gun2*5 end
				end
			if v.t==-2 then
				p.ammo[3]+=5
				sfx(32)
				if p.ammo[3]>
				pickups.gun3*5 then 
					p.ammo[3]=pickups.gun3*5 end
			end
			if v.t==-3 then
				p.ammo[4]+=5
				sfx(32)
				if p.ammo[4]>
				pickups.gun4*5 then
					p.ammo[4]=pickups.gun4*5 end
			end
			del(drops,v)
		end
end

//health stuff
function player_hurt(dam)
	p.health-=dam
	while p.health<1 
	and p.res>0 do
		p.health+=100
		p.res-=100
	end
end

function pickup_health(v)
	p.health+=v
	//move to tanks if over 100
	while p.health>100
	and p.res< pickups.health*100
	do
		p.res+=100
		p.health-=100
	end
	//cap health at 100
	if p.health > 100 then
	p.health=100 end
end

//ask from left to right order
function check_for_hit(
x1,y1,x2,y2,is_p)
	local dam = 0
	--player checks for enemy
	if is_p==1 then
		for v in all(enemies) do
			if p_hit(v.x,v.y,5+v.x,
				5+v.y)
			then
				--hit player
				dam=v.hitp
				if v.dieonhit then
					del(enemies,v)
				end
				return dam
			end
		end--end e hit check
	end
	
	for a in all(shots) do
		if a.x>=x1 and a.x<=x2
		and a.y>=y1 and a.y<=y2
		then
			if is_p==1 then 
				if a.p==1 then
				//player is shot
				dam=a.dam
				del(shots,a)
				end
			else
				//enemy is shot
				if a.p==0 then
					//hit
					dam=a.dam
					//del bullet
					if a.sprite!=15 then
						del(shots,a)
						pcurshots-=1
					end
				end
			end
		end
	end
	return dam
end

//wipe bullet
function clear_shots()
		for v in all(shots) do
				if v.p==0 then
					pcurshots-=1
				end
			del(shots,v)
		end
end



//player shooting
function update_pshoots()
	if pcurshots < pshots then
	if btnp"5" then
		if p.ammo[p.weap+1]>0
	then
		if p.weap>0 then
		p.ammo[p.weap+1]-=1
		end
		if p.flpx then
			shoot(p.x,p.y,-2,0,
			12+p.weap,0,
			weap_str[p.weap+1])
		else
			shoot(p.x,p.y,2,0,
			12+p.weap,0,
			weap_str[p.weap+1])
		end
	else sfx(34) end
	end
	end
end

// x,y = position
// xspd,yspd = speed
// s=sprite
// p = 0-player, 1-enemy
function shoot(xpos,ypos,
	xspd,yspd,
	s,pla,dam)
	b={}
	b.x=xpos
	b.y=ypos
	b.xspd=xspd
	b.yspd=yspd
	b.sprite=s
	b.flipx=false
	b.flipy=false
	b.p=pla
	if dam then
		b.dam=dam
	else
		b.dam=1
	end
	add(shots,b)
	//if player shot, count
	if pla==0 then 
		pcurshots+=1
		sfx(wepsounds[p.weap+1])
	end
end

//update pos
function update_bullets()
	foreach(shots,b_update)
end

function draw_bullets()
	foreach(shots,draw_obj)
end

function b_update(b)
	b.x+=b.xspd
	b.y+=b.yspd
	//flip
	if b.xspd<0 then b.flpx=true end
	//collision w tile
	if pixcol(b.x,b.y) > 0 
	and b.sprite!=15
	and b.sprite!=14 then
		//if player shot, uncount
		if b.p==0 then 
			pcurshots-=1
		end
		del(shots,b)
	end
	//kill if screen left
	if b.x<0 or b.x>64
	or b.y<0 or b.y>64
	then
	//if player shot, uncount
		if b.p==0 then 
			pcurshots-=1
		end
		del(shots,b)
	end
end
-->8
--map system and hud
-- room changing
//coords
w_px=0
w_py=0
regen_room=false
//connecting rooms
//numbers are code ref
w_grid={
0,3,6,
1,4,7,
2,5,8
}
//check for doors elevators etc.
// 1=left,2=right
// 3=ev,4=ev top
w_grid_doors={
{0,0,0,0},{3,3,3,3},{6,6,6,6},
{1,1,1,1},{4,4,4,4},{7,7,7,7},
{2,2,2,2},{5,5,5,5},{8,8,8,8}
}
w_grx=0
w_gry=49

//change for width and height
ww=15
--wh=13
world={}
w_rx=16//render x pos
w_ry=20//ypos
//room properties
// t=type of room,
// d=difficulty, used for
// tiles and dif

//check for player entering
// new areas, reload room
function update_world()
	if p.x<0 or p.x>60 then
		//trigger trans
		if p.x<0 then
			if w_grid[1]>-1 then
				//move left
				w_px-=1
				p.x+=60
				regen_room=true
			else
				//just stop
				p.x=0
			end
		else
			//check if valid
			if w_grid[7]>-1 then
				//move right
				w_px+=1
				regen_room=true
				p.x-=60
			else
				//just stop
				p.x=60
			end
		end
	end
	if regen_room then
		//also refesh mini map
		w_grid_refresh()
		//gen rooms
		//set room dif
		room.dif=
			world[wtoid(w_px,w_py)].d
		gen_room(world[
		wtoid(w_px,w_py)].t,
		w_px+w_py+seed)
		regen_room=false
		clear_shots()
		wipe_drops()
		//also reset rand seed
		srand(trand)
		trand=rnd(100)//next rnd table
	end
end

function draw_w_grid()
	for x=0,2 do
		for y=0,2 do
			//render a room to grid
			i=w_grid[(x*3)+y]
			x1=(x*3)+w_grx
			y1=(y*3)+w_gry
			if i then
				//color
				local c=i+2
				//power up
				if i>99 then i=7 end
				
				if i!=-1 then
					//draw room icon
					rect(x1,y1,x1+2,y1+2,i+2)
					doorid=((x*3)+y)+1
					//open pixels if door
					if w_grid_doors[doorid]
					[1]==1 then
						pset(x1,y1+1,0)
					end
					//open pixels if door
					if w_grid_doors[doorid]
					[2]==1 then
						pset(x1+2,y1+1,0)
					end
					//open pixels if ev
					if w_grid_doors[doorid]
					[3]==1 then
						pset(x1+1,y1+2,0)
					end
					//open pixels if top is ev
					if w_grid_doors[doorid]
					[4]==1 then
						pset(x1+1,y1,0)
					end
				end
			end
			//show player
			if gframe==2 or gframe==4
			then
				pset(w_grx+4,w_gry+4,7)
			end
		end
	end
end

function w_grid_refresh()
	for x=0,2 do
		for y=0,2 do
			if world[wtoid(w_px-1+x,
			w_py-1+y)]
			then
				//get grid id
				w_grid[(x*3)+y]=
				world[wtoid(w_px-1+x,
				w_py-1+y)].t
				//get grid id
				doorid=((x*3)+y)+1
				//check for doors/ev
				//left door
				if world[wtoid(w_px-1+x-1,
				w_py-1+y)]
				then
					w_grid_doors[doorid][1]=1
				else
					w_grid_doors[doorid][1]=0
				end
				//right door
				if world[wtoid(w_px-1+x+1,
				w_py-1+y)]
				then
					w_grid_doors[doorid][2]=1
				else
					w_grid_doors[doorid][2]=0
				end
				//ev
				if world[wtoid(w_px-1+x,
				w_py-1+y+1)]
				then
					//only if ev bottom
					if world[wtoid(w_px-1+x,
						w_py-1+y+1)].t==3 then
					w_grid_doors[doorid][3]=1
					else
					w_grid_doors[doorid][3]=0
					end
				else
					w_grid_doors[doorid][3]=0
				end
				//check ev top
				if world[wtoid(w_px-1+x,
				w_py-1+y-1)]
				then
					//only if ev top
					if world[wtoid(w_px-1+x,
						w_py-1+y-1)].t==1 then
					w_grid_doors[doorid][4]=1
					else
					w_grid_doors[doorid][4]=0
					end
				else
					w_grid_doors[doorid][4]=0
				end
				--end door and ev open chk
			else
				w_grid[(x*3)+y]=-1
			end
		end
	end
end

//world gen version 2
function world_setup()
//set random seed
srand(seed)
//setup
wg_floor=1
wg_rowsleft=0 //len
wg_mapsectors=4// sector count
wg_y=0 //y axis
wg_dif=0
wg_erooms={}
wg_roomstofit={}
//last ev x
wg_evx=0
//floor edges
wg_left=0
wg_right=16

//start building
for wg_ms=1,wg_mapsectors do
//building a floor
for wg_row=0,wg_rowsleft do
	//if top floor, ev is random
	if wg_ms==1 and wg_row==0 then
		wg_evx=flr(rnd(ww))
		world[wtoid(wg_evx,wg_y)]=
			w_new_room(2,wg_dif,
			wg_evx,wg_y)
		w_px=wg_evx
		w_py=wg_y
		checkpoint()
	end
//setup proposed floor
wg_left=wg_evx-flr(rnd(ww/2))
-4-wg_dif
wg_right=wg_evx+flr(rnd(ww/2))
+4+wg_dif

//build floor, skip ev
for x=wg_left,wg_right do
	wg_id=wtoid(x,wg_y)
	if world[wg_id] then
		//exists
	else
		//make normal room
		world[wtoid(x,wg_y)]=
			w_new_room(0,wg_dif,
			x,wg_y)
		//add esc time
		add_esc_t()
		//add to list
		wgobj={x=x,y=wg_y,id=wg_id}
		add(wg_erooms,wgobj)
		//if world map would be off
		// screen, shift world rx
		if -wg_left>w_rx then
			w_rx=-wg_left
		end
	end //end _wg_id check
end //end build floor

//generate row rooms
add(wg_roomstofit,1)
//add powerups
if areapowers[wg_y+1] then
	for v in 
	all(areapowers[wg_y+1]) do
		add(wg_roomstofit,v)
		//count
		mpickups+=1
	end
end
//use _wg_erooms to pick rooms
for v in all(wg_roomstofit)
do
	c={}
	c=wg_erooms[
	flr(1+rnd(#wg_erooms))]
	//set room to v
	world[wtoid(c.x,c.y)]=
			w_new_room(v,wg_dif,
			c.x,c.y)
	//if this was ev shaft,
	// build bottom
	if v==1 then
		if wg_row==wg_rowsleft-1 then
		world[wtoid(c.x,c.y+1)]=
			w_new_room(3,wg_dif,
			c.x,c.y+1)
		else
		world[wtoid(c.x,c.y+1)]=
			w_new_room(3,wg_dif+1,
			c.x,c.y+1)
		end
		//update ev pos
		wg_evx=c.x
		//update with ev time
		add_esc_t(true)
	end
	
	//remove room from list
	del(wg_erooms,c)
	
end//end placing special rooms
//erase room list
for v in all(wg_roomstofit) do
	del(wg_roomstofit,v)
end
//erase build loc
for v in all(wg_erooms) do
	del(wg_erooms,v)
end
wg_y+=1
end //floor row loop end

//advance dif
wg_dif+=1
//also build 1 depth more
wg_rowsleft+=1
end //sector end
//boss and final room
world[wtoid(wg_evx-1,wg_y)]=
			w_new_room(5,0,
			wg_evx-1,wg_y)
world[wtoid(wg_evx-2,wg_y)]=
			w_new_room(106,wg_dif,
			wg_evx-2,wg_y)
end

//map render
function draw_world()
	for k,v in pairs(world) do
		col=2+v.d //default room
		if v.t==1 or v.t==3 then
			col=1 //ev room
		end
		if v.t==2 then
			col=9 //ship
		end
		if v.t>99 then
			if collected[v.x..","..(v.y*ww)] 
			then
				col=13
			else
				col=10
			end
		end
		//draw room
		pset(w_rx+v.x,w_ry+v.y,col)
	end
	//player
	if gframe==2 or gframe==4 then
		pset(w_rx+w_px,w_ry+w_py,15)
	end
end

//world x y to index id
function wtoid(x,y)
	return x..","..y
end

//room constructor
function w_new_room(rtype,dif,
xpos,ypos)
	_room={}
	_room.t=rtype
	_room.d=dif
	_room.x=xpos
	_room.y=ypos
	return _room
end
-->8
--enemies
enemies={}
// enemy
spawn_settings={
//e 1
{a="stand",sprite=16,frm=1,
ai={1},nodam=false,hitp=20,
drop=30},
//e 2 ev
{a="stand",sprite=17,
frm=1,ai={2},nodam=true,hitp=0},
//e 3
{a="stand",sprite=18,frm=1,
ai={3},nodam=true,hits=2,hitp=10,
drop=80},
{
//e 4
a="stand",sprite=20,frm=1,
ai={6},nodam=false,hitp=20,
drop=60,dieonhit=true
},
{
//5
},
{
//6
},
{
//7
},
{
//8
},
{
//boss 999 is placeholder
a="boss",sprite=99,frm=2,ai={7},
nodam=true,hits=999,hitp=0,
drop=100,x=6,y=1
},
{
//power up
a="stand",sprite=24,
frm=1,ai={4},nodam=false,x=-1,
hits=999,hitp=0,ispower=true
},
//doors
{a="none",sprite=44,frm=1,
ai={5},nodam=false,hitp=0,
hits=999
},
{a="none",sprite=45,frm=1,
ai={5},nodam=false,hitp=0,
hits=999
},
{a="none",sprite=46,frm=1,
ai={5},nodam=false,hitp=0,
hits=999
},
{a="none",sprite=47,frm=1,
ai={5},nodam=false,hitp=0,
hits=999
},
{a="none",sprite=48,frm=1,
ai={5},nodam=false,hitp=0,
hits=999
}
}

function draw_enemies()
	for v in all(enemies) do
		pal()
		if v.inv%4>0 then
			pal(3,7) pal(11,10)
			pal(14,8) pal(15,4)
		end
		if v.a=="stand" then
			draw_obj(v)
		else
			draw_obj_f(v,v.frm)
		end
		pal()
	end
end

function update_enemies()
	for v in all(enemies) do
		//update enemy
		if v.inv>0 then v.inv-=1 else
			update_ai(v) end
		if v.nodam==false then
			//check if damaged
			h=check_for_hit(v.x-1,v.y-1,
			v.x+5,v.y+5,0)
			if h > 0 then v.hits-=h 
			 if v.hitp>0 then
			 	v.inv=8
			 end
			end
			if v.hits<=0 then
				if v.drop then
					make_drop(v.x,v.y,v.drop)
				end
				//boss death
				if v.bosssetup then
					regen_room=true
					sfx"29"
					v.ispower=true
					bosswon=true
					music(-1)
					for v in all(room.props) do
						del(room.props,v)
					end
				end
				del(enemies,v)
				if not v.ispower then
					sfx"21"
				end
			end
		end
	end
end

function room_espawns()
 for x=0,room.w-1 do
		for y=0,room.h-1 do
			_i=room.t[rxy_to_dex(x,y)]
			if _i > 15 and _i<31 then
				//avoid edge
				if x>3 and x<room.w-4 then
					if roomenemy then
						if _i==20 and room.dif<2
						then
						else
							spawn_enemy(x,y,_i-16)
						end
					end
				end
				//ignore roomenemy
				if _i==18 
				or _i==26 
				or _i==25 then
					spawn_enemy(x,y,_i-16)
				end
				room.t[rxy_to_dex(x,y)]=
				1
			end
		end
	end
end

function clear_enemies()
	for i=#enemies,1,-1 do
		enemies[i]=nil
	end
end

function spawn_enemy(tx,ty,id)
	_e=tcopy(spawn_settings[id])
	if _e.x then
		_e.x+=(tx*4)
	else
		_e.x=tx*4
	end
	if _e.y then
	_e.y+=(ty*4)
	else
	_e.y=ty*4
	end
	//hitbox settings
	_e.inv=0
	if _e.hits then
	if _e.hits<999 then
		_e.hits+=(1*(room.dif+1))
		end
	else
		_e.hits=1 //default to 1
	end
	if _e.hitp then
	else
		_e.hitp=40
	end
	_e.flpx=false
	_e.flpy=false
	_e.aic=0
	add(enemies,_e)
end

//ai functions
function update_ai(e)
for ai in all(e.ai) do
	if ai==1 then
		if e.aic==0 then
			float_closer(e)
			e.aic=4
		else
			e.aic-=1
		end
	end--end ai 1
	//ev ai
	if ai==2 then
		if p.x<e.x+4 and p.x>e.x-2 then
			if p.y>e.y-1 then
				p.y=e.y-1
				pm.grounded=true
				pm.override_g=true
				pm.yspd=-1
				pm.curj=0
				if btn"3" 
				and w_grid[5]==3
				then
					ev_dir=0
					gamestate="ev_ride"
				end
				if btn"3" 
				and w_grid[3]==1
				then
					ev_dir=1
					gamestate="ev_ride"
				end
			end
		end
	end--end ai 2
	--plant ai
	if ai==3 then
		if e.timer then
			if p.x < e.x+16
			and p.x > e.x-12
			and p.y < e.y
			and e.timer==1
			then
				shoot(e.x+2,e.y-2,-1,-1,9,1,10)
				shoot(e.x+2,e.y-2,1,-1,9,1,10)
				shoot(e.x+2,e.y-2,0,-1,9,1,10)
				e.timer=60
				e.nodam=false
				e.a="shoot"
				e.sprite=19
				sfx"25"
			end
			if e.timer>1 then 
				e.timer-=1
				e.frm=1
				if e.timer<50 then
					e.frm=2
				end
				if e.timer<30 then
					e.frm=3
				end
				if e.timer<10 then
					e.frm=4
				end
			end
			if e.timer==1 then
				e.nodam=true
				e.a="stand"
				e.sprite=18
			end
		else
		 e.timer=1
		end
	end
	-- end ai 3
	-- powerup
	if ai==4 then
		if e.pow==106 
		and pickups.exp==1 then
			e.collected=true
			e.hits=-1
			e.pow=nil
		end
		if collected[
					w_px ..",".. (w_py*ww)]
		and e.pow!=106 and e.pow
		then
			e.collected=true
			e.hits=-1
			e.pow=nil
		end
		
		if e.pow then
			//reveals
			if e.hits<999 and 
			e.collected==false then
				e.hits=999 //inv
				e.reveal=true
			end
		
			if e.reveal then
				//set spr
				if e.pow==100 then
					e.sprite=26
				end
				if e.pow==101 then
					e.sprite=27
				end
				if e.pow==102 then
					e.sprite=28
				end
				if e.pow==103 then
					e.sprite=29
				end
				if e.pow==104 then
					e.sprite=30
				end
				if e.pow==105 then
					e.sprite=31
				end
				if e.pow==106 then
					e.sprite=25
				end
				if p_hit(e.x,e.y)
				then
					e.collected=true
					//write
					collected[
					w_px ..",".. (w_py*ww)]
					 =true
					ev_dir=e.pow-100
					ev_y=30
					music(-1)
					sfx"18"
					gamestate="message"
				end
			end -- revealed
		else
			//room id
			e.pow=world[wtoid(w_px,w_py)].t
			//hide
			e.reveal=false
			e.collected=false //not col
		end
	end
	-- end ai 4
	if ai==6 then
		if p.x<e.x+20 and p.x>e.x-16
		and e.swoop==nil
		then
			e.swoop=true
			e.swoopdir=e.x-p.x
			e.swooph=p.y
			e.timer=2
			sfx"24"
		end
		if e.swoop then
			e.timer-=1
			if e.timer<0 then
				if e.swoopdir>0 then
					e.x-=1
				else
					e.x+=1
				end
				if e.x<-4 or e.x>64 then
					del(enemies,e)
				end
				e.timer=2
				if pixcol(e.x,e.y+7)==0 and
				e.y< e.swooph then
					e.y+=3
				end
			end
			
		end
	end--end ai 6
	--boss
	if ai==7 then
		if e.bosssetup then
			e.btime-=1
			if e.btime==e.htime then
				if e.spawn==true then
					if #enemies<10 then
					spawn_enemy(3,7,1)
					spawn_enemy(2,5,1)
					spawn_enemy(1,6,1)
					spawn_enemy(4,5,1)
					end
					e.spawn=false
				else
				 if #enemies < 10 then
					spawn_enemy((p.x/4)-2,
					2,4)
					end
					e.spawn=true
				end
				e.btime-=1
			end
			if e.btime<100 and e.btime>50
				and e.bossshot==false then
				if e.btime%8==0 then
					shoot(e.x+1,e.y+1,
					2,0,10,1,90)
					sfx"33"
				end
				if e.btime%8==4 then
					shoot(e.x+1,e.y+1,
					2,2,11,1,90)
					shoot(e.x+1,e.y+1,
					2,-2,8,1,90)
					sfx"33"
				end
				e.sprite=97 e.nodam=false
			end
			if e.btime<0 then
				e.htime=flr(rnd(140))
				e.btime=150
				e.bossshot=false
				e.sprite=99 e.nodam=true
			end
		else
			e.btime=150
			e.htime=100
			e.headfire=false
			e.bossshot=false
			e.bosssetup=true
			e.hits=100
			e.spawn=false
			p.x=56
			gen_chunk(35,room.w-4,
			room.h-5)
		end
	end --end b
end
end

function float_closer(e)
	_up=false
	_left=false
	if p.x<e.x then _left=true
	else _left=false end
	if p.y<e.y then _up=true
	else _up=false end
	e.x+=1
	e.y+=1
	if _left then
		e.x-=2
	end
	if _up then
		e.y-=2
	end
end
__gfx__
940094009400940094009400940094000000000000000000000000000000000000bb003bb003300b00000000b300bb00000000000090009000ac00ac00900090
0980098009809c000c800c800c80ce000000000000000000000000000000000003b303bb03900830bbbb33bbbb303b300880088055595559cccaccca998a998a
09000900990099000c000c00cc00cc00000000000000000000000000000000003b303bb008b00b903333bb330bb303b3000000000090009000ac00ac00900090
9090909090909000c0c0c0c0c0c0c00000000000000000000000000000000000bb00bb00300330030000000000bb00bb00000000000000000000000000000000
9400940094009400940094009400940000000000000000000000000000000000003b00bb3003300300000000bb00b300000000000090009000ac00ac00900090
0980090009a009800c800c000ca00c800000000000000000000000000000000003bb0bb30b9009b03333bb333bb0bb300880088055595559cccaccca998a998a
09000980990099000c000c80cc00cc0000000000000000000000000000000000bb30bb3008300380bbbb33bb03bb03bb000000000090009000ac00ac00900090
9090909090909090c0c0c0c0c0c0c0c000000000000000000000000000000000b300b300300bb00300000000003b003b00000000000000000000000000000000
033003330000000000000000b88bb00b0e1000e1000000000ee002200ee0022077777777077006607989698977b767b777876787077006600770066007700660
311b311b000000000bb00bb00bb00bb0edefeedf00000000ecce2cc2e22e2ee27667766770076006789868987b3b6b3b78886888799769967cc76cc678876886
313b313b0000000003300330033003300ee00ee000000000ecce2cc2e22e2ee27667766770b76b06779767977b7b6b7b77876787799769967cc76cc678876886
0bb0bbb0a9999a993333333330033003ff000f00000000000ee002200ee002207777777777776666777766667777666677776666077006600770066007700660
033033300000000000000000b00b0bb00e100e10000000000ee002200ee00220777777770aa00660a9896989a7b767b7a78767870aa007700aa007700aa00770
331b311b000000000bb00bb00bb00bb00eefedef00000000eaae2aa2e88e288276677667ab0a60b6a8986898ab3b6b3ba8886888a99a7997acca7cc7a88a7887
313b313b000000000330033003300330fdd0fde000000000eaae2aa2e88e288276677667a00a6006a7976797ab7b6b7ba7876787a99a7997acca7cc7a88a7887
0bb00bb099a9999a33333333300333330f000f00000000000ee002200ee0022077777777aaaa6666aaaa6666aaaa6666aaaa66660aa007700aa007700aa00770
66000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000880088009900990011001100aa00aa
060000600999900000000000000000000000000000000000000000000000000000000000000000000000000000000000088c088c099c099c011c011c0aac0aac
00000660000099000000000000000000000000000000000000000000000000000000000000000000000000000000000008cc08cc09cc09cc01cc01cc0acc0acc
00000000009909000000000000000000000000000000000000000000000000000000000000000000000000000000000088cc000099cc000011cc0000aacc0000
00000000009009000000000000000000000000000000000000000000000000000000000000000000000000000000000000880000009900000011000000aa0000
066006000990090000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000000c0000000c0000000c0000
06600660099999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00550055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05560556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05660566000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3b333bb333bb333776677666665566645455544555445555858885588855888dedeeeddeeeddeee151511511151151100000000000000005555555500055000
3b3b3b3333b00b33666666666650056654545455554004558585858888500588edededeeeed00dee515111551510015100000000000000005000000500500500
33b3333b3b0000b3656566656500005655455554540000458858888585000058eedeeeeded0000de151551115100001500000000000000005000000505000050
b33333b3b000000b666566655000000545555545400000045888885850000005deeeeeded000000d515155111000000100000000000000005000000550000005
b3bbbbb3b000000b776677775000000545444445400000045855555850000005deddddded000000d515151511000000100000000000000005000000550000005
3b33bbb33b0000b3666666666500005654554445540000458588555885000058edeedddeed0000de111151155100001500000000000000005000000505000050
333bb33333b00b33666666666650056655544555554004558885588888500588eeeddeeeeed00dee511515511510015100000000000000005000000500500500
b3bb3b3b333bb333666665556665566645445454555445555855858588855888deddededeeeddeee151155111151151100000000000000005555555500055000
dddddddd515551550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd155555510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008880808080808080
dddddddd551555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008080008000008000
dddddddd555551510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008880008000000000
dddddddd555155550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008008000088808880
dddddddd555555510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008008880080808080
dddddddd515511550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008008000088808880
dddddddd555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000008000
11111111888888809988888888888880001111600000000000011100000011110000000000000000000000000000000000000000000000000000000000000000
1111100088886d609dd8dd8888888888001110000000011111111111111111060000000000000000000000000000000000000000000000000000000000000000
011111009999ddd00d88dd8899998686011160060001111111111111111106000000000000000000000000000000000000000000000000000000000000000000
01111000888986d60888888888898888011000010111111111111111000600000000000000000000000000000000000000000000000000000000000000000000
01101000999888880888888899988888011606110111111101000001100000000000000000000000000000000000000000000000000000000000000000000000
00100000888988000088889988898800011001111111111000000000116060600000000000000000000000000000000000000000000000000000000000000000
01100000999990000888899999999000011111101111000000000000011111110000000000000000000000000000000000000000000000000000000000000000
11000001999800008999999199980000011111001110000000000000000000110000000000000000000000000000000000000000000000000000000000000000
10000001000000008989899800000000000000000000000000000000000000000000000000011111000000000000000000000000000000000000000000000000
11000001000000008898989800000000000000000000000000000000000000000000000000110606000000000000000000000000000000000000000000000000
01000011000000000899898800000000000000000000000000000000000000000000000000110000000000000000000000000000000000000000000000000000
01000010000000000888988000000000000000000000000000000000000000000000000000110000000000000000000000000000000000000000000000000000
01000010000000000889898000000000000000000000000000000000000000001600006100111000000000000000000000000000000000000000000000000000
01000010000000000889988000000000000000000000000000000000000000001100001100111116000000000000000000000000000000000000000000000000
01000010000000000888888000000000000000000000000000000000000000000111611000111101000000000000000000000000000000000000000000000000
01000010000000000888888000000000000000000000000000000000000000000001110000111100000000000000000000000000000000000000000000000000
66666666333333333333333333333333300000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000
6000000630000003300000300300000333000000000000330b0000b0000000000000000000000000000000000000000000000000000000000000000000000000
60000006300000033000030000300003303000000000030300b00b00000000000000000000000000000000000000000000000000000000000000000000000000
600000063000000330003000000300033003000000003003000bb000000000000000000000000000000000000000000000000000000000000000000000000000
600000063000000330030000000030033000300000030003000bb000000000000000000000000000000000000000000000000000000000000000000000000000
60000006300000033030000000000303300003000030000300b00b00000000000000000000000000000000000000000000000000000000000000000000000000
6000000630000003330000000000003330000030030000030b0000b0000000000000000000000000000000000000000000000000000000000000000000000000
66666666333333333000000000000003333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddddddd8ddd888d888d888dd8d8888d8888888dd888888dd888888dd88d88dd888d79896989000800000009000000010000000a00000005000000000000
d888dd8ddddd8ddd8dddddd88dddd8d88ddd8ddd8ddd8ddd8dddddd88ddd8dd88dd8ddd87898689800880000009900000011000000aa00000055000000000000
d8ddd88ddddddddd8dddddd88dddd8d88ddd8ddd8ddd8ddd8dddddd88ddd8dd88dd8ddd87797679708cc000009cc000001cc00000acc00000566000000000000
d88ddd8d99a99a99888dd88d888dd888888d888888dd8ddd88ddddd888ddd88d88d8ddd87777666688cc000099cc000011cc0000aacc00005566000000000000
d8dddd8ddddddddd8dddddd88dddddd88dddddd88ddd888d8ddddd8d8ddd8dd88ddd8888a989698988cc000099cc000011cc0000aacc00005566000000000000
d8ddd888dddd8ddd8dddddd88dddddd88dddddd88ddd8dd88ddddd8d8ddd8dd88dddddd8a898689808cc000009cc000001cc00000acc00000566000000000000
d888dddddddd8ddd8dddddd88dddddd88ddd88888ddd8dd88ddddd8d8ddd8dd88dddddd8a797679700880000009900000011000000aa00000055000000000000
dddddddddddd8ddd888d888d8888ddd88888dddd888dd88d8888dd8d888dd88d888dddd8aaaa6666000800000009000000010000000a00000005000000000000
90090909000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99090909000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
90990909000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
90090990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09900990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000066000600660060606606600666066066066606006005050066006060660060066066066880088008800800880088080
00000000000000000000000000000000060606060606060660006060060060060006006606006660060606066000606060606060800800080008080808080080
00000000000000000000000000000000060606660660066060006600060066066006006066061616066000666060666060606066880088080008880880088080
00000000000000000000000000000000060606060606060660606060060060060006006006066a66060600066060606060606060800008080008080800080000
00000000000000000000000000000000066006060606060606606060666060060066606006006660066000666660606060606066880880008808080800088080
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010010000100100001001000010010065000056665066500566056600006650056600000000000000000000000000000cccccc0880080088808008808800000
00eeee0000eeee0000eeee0000eeee006500005658655a6556a55685000552655625500000000000000000000cccccc000000000800808008008008008080000
0de00ed00de11ed00de11ed00de11ed06500005655655565565556550005556556555000000000000cccccc000aaaa0000000000880888008008008808080000
0deeeed00deeeed00deeeed00deeeed065000056065506555560556000000655556000000cccccc0000000000000000000000000800808008008008008080000
eeeddeeeeeeddeeeeeeddeeeeeeddeee000000006650665005660566066055600655066000aaaa00000000000000000000000000800808088808808808800000
eee00eeeeee00eeeeee00eee9e9009e9666666665265516556155625005506600660550000000000000000000000000000000000000000000000000000000000
0d0000d00d0000d00d0000d00d0000d0655555565565556556555655000065500556000000000000000000000000000000000000000000000000000000000000
d0d00d0dd000000d0000000000000000656556560655065555605560566666655666666500000000000000000000000000000000000000000000000000000000
00999000000bb000000000005555555555555555555555555555555500666600088888800bb00b00000000bb0000008808880080880880000800808088088008
0099400000b33b00099999905000000550000005500000055000000506000060800000080b000b0000000b000000080008080808080800008080808080080808
000c000000b33b0099c99c9950000005500090055000a0a550009005600b0006800880080bb00b0000000b000000080008880800080880008080808088088008
000cc8000bb33bb09c9cc9c9508888055055590550ccca0550998a0560b00006800880080b00000000000b000000080808080800080800008080808080080800
000c00000b3333b09c9cc9c9508888055055590550ccca0550998a0560000b06800000080bb00b00000000bb0000008808080800080880000800080088080808
00c0c0000b3bb3b099c99c9950000005500090055000a0a55000900565b555b68008800800000000000000000000000000000000000000000000000000000000
00c0c0000bb00bb00999999050000005500000055000000550000005655b55568000000800000000000000000000000000000000000000000000000000000000
00000000000000000000000055555555555555555555555555555555666666660888888000000000000000000000000000000000000000000000000000000000
00b00080099000909990099090900999099009900990099008800080888008808080088808800880088008800110001011100110101001110110011001100110
0bbb0888900909900090900990909000900000099009900980080880008080088080800080000008800880081001011000101001101010001000000110011001
0b0b0080900900909990009099909990999000090990099980080080888000808880888088800008088008881001001011100010111011101110000101100111
00000000900900909000900900900009900900909009000980080080800080080080000880080080800800081001001010001001001000011001001010010001
00000000099009999990099000909990099000900990099008800888888008800080888008800080088008800110011111100110001011100110001001100110
000000009cc90000000090090000000000000000000000009cc90000000090090000000000000000000000009cc9000000009009000000000000000000000000
000000009cc90000000090090000000000000000000000009cc90000000090090000000000000000000000009cc9000000009009000000000000000000000000
00000000099000000000099000000000000000000000000009900000000009900000000000000000000000000990000000000990000000000000000000000000
0cc000c0ccc00cc0c0c00ccc0cc00cc00cc00cc0bbb0bbb00b0b00bb00b00bb0b00bbb0b00bb0bbb0bb00b00bb00bb00bbb0bb0bb000b0bb00bb0bbb00000000
c00c0cc000c0c00cc0c0c000c000000cc00cc00c0b000b00b0b0b0b00b0b0b0b0b0b0b0b00b000b0b000b0b0b0b0b000b0b0b00b0b0b00b00b0b00b009009000
c00c00c0ccc000c0ccc0ccc0ccc0000c0cc00ccc0b000b00b000b0bb0b0b0b000b0bb00b00bb00b0b000b0b0b0b0bb00bb00bb0bb00b00bb0b0b00b000090000
c00c00c0c000c00c00c0000cc00c00c0c00c000c0b000b00b000b0b00b0b0b000b0b000b00b000b0b000b0b0b0b0b000b000b00b0b0b00b00b0b00b000900000
0cc00cccccc00cc000c0ccc00cc000c00cc00cc00b00bbb0b000b0bb00b00b000b0b000bb0bb00b00bb00b00bb00bb00b000bb0b0b00b0bb0b0b00b009009000
9cc90000000090090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9cc90000000090090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09900000000009900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
bb33bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
bb33bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
33bb33bb1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
33bb33bb1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
3333bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bb333333
3333bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bb333333
bb333333111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111133bb33bb
bb333333111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111133bb33bb
bb33bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
bb33bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
33bb33bb1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
33bb33bb1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
3333bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bb333333
3333bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bb333333
bb333333111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111133bb33bb
bb333333111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111133bb33bb
bb33bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
bb33bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
33bb33bb1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
33bb33bb1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
3333bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bb333333
3333bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bb333333
bb333333111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111133bb33bb
bb333333111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111133bb33bb
bb33bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
bb33bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
33bb33bb1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
33bb33bb1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
3333bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bb333333
3333bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bb333333
bb333333111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111133bb33bb
bb333333111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111133bb33bb
bb33bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
bb33bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
33bb33bb1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
33bb33bb1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
3333bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bb333333
3333bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bb333333
bb333333111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111133bb33bb
bb333333111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111133bb33bb
bb33bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
bb33bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
33bb33bb1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
33bb33bb1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
3333bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bb333333
3333bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bb333333
bb333333111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111133bb33bb
bb333333111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111133bb33bb
bb33bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
bb33bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
33bb33bb1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
33bb33bb1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
3333bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bb333333
3333bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bb333333
bb333333111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111133bb33bb
bb333333111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111133bb33bb
bb33bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
bb33bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
33bb33bb1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
33bb33bb1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
3333bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bb333333
3333bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bb333333
bb333333111111111111111111111111111111111111111111111111111111111111111111111111118888111111111111111111111111111111111133bb33bb
bb333333111111111111111111111111111111111111111111111111111111111111111111111111118888111111111111111111111111111111111133bb33bb
bb33bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
bb33bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
33bb33bb1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
33bb33bb1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbb33
3333bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bb333333
3333bb331111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bb333333
bb333333111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111133bb33bb
bb333333111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111133bb33bb
11111111111111111111111111111111113333111111111111111111111111111111111111333311111111111111111111111111111111111111111111111111
11111111111111111111111111111111113333111111111111111111111111111111111111333311111111111111111111111111111111111111111111111111
11111111111111111111111111111111331111bb11111111111111111111111111111111331111bb111111111111111111111111111111111111111111111111
11111111111111111111111111111111331111bb11111111111111111111111111111111331111bb111111111111111111111111111111111111111111111111
11111111111111111111111111111111331133bb11111111111111111111111111111111331133bb111111111111111111111111111111111111111111111111
11111111111111111111111111111111331133bb11111111111111111111111111111111331133bb111111111111111111111111111111111111111111111111
1111111111111111111111111111111111bbbb111111111111111111111111111111111111bbbb11111111111111111111111111111111111111111111111111
1111111111111111111111111111111111bbbb111111111111111111111111111111111111bbbb11111111111111111111111111111111111111111111111111
111111111111994411111111111111111111111111111111111111111111111111111111111111bbbb1111111111111111111111111111111111111111111111
111111111111994411111111111111111111111111111111111111111111111111111111111111bbbb1111111111111111111111111111111111111111111111
111111111111119988111111111111111111111111bbbb111111111111bbbb11111111111111bb3333bb11111111111111111111111111111111111111111111
111111111111119988111111111111111111111111bbbb111111111111bbbb11111111111111bb3333bb11111111111111111111111111111111111111111111
11111111111111991111111111111111111111111133331111111111113333111111111111bb33333333bb111111111111111111111111111111111111111111
11111111111111991111111111111111111111111133331111111111113333111111111111bb33333333bb111111111111111111111111111111111111111111
111111111111991199111111111111111111111133333333111111113333333311111111bb333333333333bb1111111111111111111111111111111111111111
111111111111991199111111111111111111111133333333111111113333333311111111bb333333333333bb1111111111111111111111111111111111111111
bb33bb333333bbbbbb33bbbbbbbbbb33bb33bb333333bbbbbb33bbbbbbbbbb33bb33bb333333bbbbbb33bbbbbbbbbb33bb33bb333333bbbbbb33bbbbbbbbbb33
bb33bb333333bbbbbb33bbbbbbbbbb33bb33bb333333bbbbbb33bbbbbbbbbb33bb33bb333333bbbbbb33bbbbbbbbbb33bb33bb333333bbbbbb33bbbbbbbbbb33
33bb33bb33bb333333bb3333bbbbbb3333bb33bb33bb333333bb3333bbbbbb3333bb33bb33bb333333bb3333bbbbbb3333bb33bb33bb333333bb3333bbbbbb33
33bb33bb33bb333333bb3333bbbbbb3333bb33bb33bb333333bb3333bbbbbb3333bb33bb33bb333333bb3333bbbbbb3333bb33bb33bb333333bb3333bbbbbb33
3333bb33333333bb333333bbbb3333333333bb33333333bb333333bbbb3333333333bb33333333bb333333bbbb3333333333bb33333333bb333333bbbb333333
3333bb33333333bb333333bbbb3333333333bb33333333bb333333bbbb3333333333bb33333333bb333333bbbb3333333333bb33333333bb333333bbbb333333
bb3333333333bb33bb33bbbb33bb33bbbb3333333333bb33bb33bbbb33bb33bbbb3333333333bb33bb33bbbb33bb33bbbb3333333333bb33bb33bbbb33bb33bb
bb3333333333bb33bb33bbbb33bb33bbbb3333333333bb33bb33bbbb33bb33bbbb3333333333bb33bb33bbbb33bb33bbbb3333333333bb33bb33bbbb33bb33bb
00000000000000000000009999000099990000000000009900999999000000009999990099009900000000000000000000999900000000005555555555555555
00000000000000000000009999000099990000000000009900999999000000009999990099009900000000000000000000999900000000005555555555555555
000000000000000000009900009999000099009900009999000000990000990000009900990099000000000000bb000099000099000000005500000000000055
000000000000000000009900009999000099009900009999000000990000990000009900990099000000000000bb000099000099000000005500000000000055
0000000000000000000099000099990000990000000000990099999900000000999999009999990000000000bbbbbb0099000099000000005500000000000055
0000000000000000000099000099990000990000000000990099999900000000999999009999990000000000bbbbbb0099000099000000005500000000000055
0000000000000000000099000099990000990099000000990099000000009900990000000000990000000000bb00bb0099000099000000005500888888880055
0000000000000000000099000099990000990099000000990099000000009900990000000000990000000000bb00bb0099000099000000005500888888880055
44444422222222222200009999000099990000000000999999999999000000009999990000009900000000000000000000999900000000005500888888880055
44444422222222222200009999000099990000000000999999999999000000009999990000009900000000000000000000999900000000005500888888880055
00000000000000000000555555555555555555555555555555555555555555555555555555555555550000000000000000000000000000005500000000000055
00000000000000000000555555555555555555555555555555555555555555555555555555555555550000000000000000000000000000005500000000000055
4444442222222222220055cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc550000000000000000000000000000005500000000000055
4444442222222222220055cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc550000000000000000000000000000005500000000000055
22222222222222222200555555555555555555555555555555555555555555555555555555555555550000000000000000009944000000005555555555555555
22222222222222222200555555555555555555555555555555555555555555555555555555555555550000000000000000009944000000005555555555555555
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099880000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099880000000000000000000000
22222222222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000099000000000000000000000000
22222222222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000099000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009900990000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009900990000000000000000000000
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

__map__
908090808080809080808080808080808080808090808080808080808080908081818181818181818181818181818181818181818181818181818181818181818180808080808081a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0818181a0a0818181000000000000000000000000000000000000000000000000
808080808080808080809280808080808080808080808080809280808090808080808080838182808083829383818182808181808181818081818181808180818180808080808081a08181a0a0a0a0a081a0a08181a0a081a081a0a081a0a081a0a081a0a08181a0000000000000000000000000000000000000000000000000
809280928085848085818184809280808080928080808080808180808080808080808080809380808080808080838280809381808180818081818181809380808180808080808081a0a0a0a0a08181a0a0a0a0a0a0a0a0a0a0a08181a0a081a0a0a081a0a08181a0000000000000000000000000000000000000000000000000
818181818181818181818181818181818181818181818181818181818181818180808080808080808080808080808080808080809380938080808080808080808180818181818081a0a0a0a080808080a0a0a0a0a0a0a0a0a080808080a0a0a0a0a080a0a08080a0000000000000000000000000000000000000000000000000
81a0a0a081a0a0a0a0a0a081a0a0a08100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8080808081a0a0a080808080a0a0a08100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8080808081a0a0a080808080a0a0a08100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
81a0a0a081a0a0a0a0a0a081a0a0a08100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a0a0a0a0a0a0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a090a0a0a090a0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a0a0a0a0a090a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a0a0a0a0a0a0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a0a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a0a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a0a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a0a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a0a0a0a09191a0a09191a0a0a0a0a0a0a0a0a0a0a0a0a08686869880808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a08080a08180808181818181a09986a0a08699a0a0a099a08686868680808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a08686a08180808181818181a08686a0a08686a0a08581848686868081818181000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
001400200161001610016100161001610016100161001610016100161001610016100161001610016100161001610016100161001610016100161001610016100161001610016100161001610016100161001610
001000202b7202c020287202a02025720280202272025720227202302024720217202202025720237202572027720270202372021720260202172022720280202472022020257202102022720250202572024020
002d00202410021030252102603029110250301e210231100420013210152101a12016030130200f0301a110010001e02021020230301b110222101e030212101e100162101d0302303025030221102103025060
0010002005420054200b4200642001420034200242007420024200942001420014200a420044200642003420094200b420014200642005420024200542003420044200642009420034200a4200d4200642001420
001000200231002310023100231002310023100231002310023100231002310023100231002310023100231002310023100231002310023100231002310023100231002310023100231002310023100231002310
003600103f2001602000000331103320029020000003511000000230203820032110000001d020000002f11000000000000000000000000000000000000000000000000000000000000000000000000000000000
0020002032320340102e220000000000000000000000000035320340203621000000000000000000000000003b3203c5203921000000000000000000000000003a1203c3303b2303b20000000000000000000000
001000203f4103d710397103d1103e7103c710390103771036510387103a0103d7103e3103c7103b01038710375103a7103c0103d5103f7103d7103c0103a7103951038710397103b710380103a7103d7103e710
0010000007950099500b9500d9500e9500f9500f95010950119501295010950109501195011950119501195010950109500f9500f95010950109500f9500f9500e9500d9500c9500b9500a950099500995009950
0020000003b2004b0006b3006b0006b4007b0007b5007b0007b6007b0006b5006b0005b4004b0004b2002b0005b0007b0007b0007b0006b000ab0008b0007b0006b0007b0006b000ab0006b0008b0005b0004b00
0010002009f400ef6009f4011f400af4013f400bf6015f4008f6017f4008f4016f400af4018f7009f4019f600cf400af5014f400bf6018f400bf4015f600ff4012f700ff6011f400af4012f700df600bf400bf40
000a002019430184201a430174201643016420184301942019410174201643017420194301a420184101742017430194201a4101a42017410194201b4301b4201b4101a4201943018420194301b4201b4101a420
001400000000000000000003374033700000000000028740000000000000000327400000000000000002f740000000000000000337400000000000000003774000000000003a7003d74000000000000000035740
0014000001e0001e0002e003274003e0003e0003e002a7403270002e0002e003074002e0002e00000003a7400000003e0003e00327402f70005e0006e002d74007e0007e0005e003974001e000000002e0031740
00100000083100c3100d310103101231015310193101d310103101331016310183101a3101c3101f3102231015310163101a3101c3101e310223102531028310183101a3101c3101e310223102a3103231032310
001400003a0502f05025050210501f0501d050190501605013050100500f0500c0500b05009050070500605005050040500305002050010500105001050010500205002050020500205001050010500105001050
002e00202355000000155301550010530185001655000000205001650000000000000000000000000000000019530185002055001500295301950024540000002050000000000002850000000000002350000000
00030000393701e370263702237023300233000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001200000c3301033013300160301a03000300203302333025730287302c730307303203033030347403475034760347303472000300003000030000300003000030000300003000030000300003000030000300
00040000181502b1501c15022150171501b1501115014150011002910030100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005000006450234501d4502a45017450224503f40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500003f070370603206029060210601b0300c02008070080700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000e170111601316016150182401c240202701b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000030350183501c35012350183500e3501c3501f35019350123500b550065500355001550015500155005300033000330003300033000430001300003000030000300003000030000300003000030000300
000300001b3103072032230347403f3403844035240362403a740392503f2503b2503f2503a7503a750387302e710000000000000000000000000000000000000000000000000000000000000000000000000000
000400000a35011350143501a3501a150281501b05017050140500f05009050030500105004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008000032250052501f2500225006450064501840012400183001c3001e300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000010250142501a2501e25022250272502d2503225035250382503a250392503825038250372503525034250312502d2502725023250202501c2501c25023250292502c2502f2503125035250382503b250
00100000373503b3503f3500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400003f6700d6703f0700b6703b1700a670396700467023160350600e65021140166303a1301a630266301d6201f6203d140270402b05035050330502a0503c650170501b050191501714013110111100b010
00060000194501c450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600001815014050181502d07000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
0004000018150120502e1501c05029150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001337006650122401125012170092403f3003e3003730030300223000b300013003820035200302002e200322000000034200362003520031200312003020000000000000000000000000000000000000
000400000365004150021500010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000c00003f2503b2503f200362003f200362003f2003f20035200002000020000200002003f2003f2003f20000200002000020000200002000020000200002000020000200002000020000200002000020000200
__music__
03 007f4344
03 01424344
03 02424344
03 03064344
03 00044344
03 05424344
01 07080944
00 07094344
02 41090a44
01 0b0c4344
02 0b0d4344
04 0e444344
04 0f424344
03 10424344
00 04424344


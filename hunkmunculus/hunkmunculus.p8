pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--hunk-munculus♥ 0.2.0
--by shinbone
function _init()
	menuitem(1,"restart level", function()
		sfx(2)
		init_lvl(g.l)
	end)
	
	--update order
	up_order = {
		update_menu,
		update_story,
		update_level,
		update_end
	}
	--draw order
	drw_order = {
		draw_menu,
		draw_story,
		draw_level,
		draw_end
	}
	--set start scene
	update_scene=update_menu
	draw_scene=draw_menu
	
	reading=false
	showhint=true
	why=""
	
		--player data
	p={
		x=64,
		y=72,
		emotes={},
		severed=false
	}
	
	--hand data
	h={
		x=p.x,
		y=p.y,
		sp=10,
		fh=false,
		fv=false,
		grab=false,
		last={}
	}
	
	--arm data
	a={}
	
	--game data
	g={
		a=0.1,
		ofst=0.1,
		l=1,
		scene=1,
	}
	
	lmap=leveldata
	
	l={}
	resetl={}
	
	-- emote matches
	matches={
		["94"]=12,
		["122"]=13,
		["124"]=14,
		["108"]=63,
		["126"]=15,
		["109"]=99,
		["123"]=98,
		["196"]=28,
		["198"]=29,
		["62"]=30,
		["60"]=48,
	}
	
	sp_to_port={}
	sp_to_port[1]=108
	sp_to_port[2]=72
	sp_to_port[3]=74
	sp_to_port[4]=78
	
	namelookup={
		"hunkmunculus",
		"witch",
		"mummy",
		"moss",
		"ghost",
		"skeleton",
		"bat",
		"wizard"
	}
	
	save_lvl()
	init_lvl(4)
	music(0)
end

function _update()
	update_scene()
end

function _draw()
	cls()
	draw_scene()
	local buf=0
	if type(why)=="table" then
		for t in all(why) do
			print(t,0,buf,7)
			buf+=6
		end
	else
		print(why,0,buf,7)
	end
end
-->8
--update function
function update_menu()
 if btnp(➡️) then
 	adv_scene()
 	tb_init(6,story_txt,story_drw)
 end
 if btnp(🅾️) then
 	g.scene=2
 	adv_scene()
 end
end

function update_story()
	music(-1)
	if reading then
		tb_update()
	elseif not reading then
		adv_scene()
	end
end

function update_level()
	g.ofst+=0.1
	if (g.ofst>#l.emotes+1) g.ofst=0.1
	music(-1)
	if reading then
		tb_update()
	else
		handle_input()
	end
end

function update_end()
	if reading then
		tb_update()
	else
		run()
	end
end

--validate input for movement
function try_move_hand(inp)
	local hcrds={x=h.x,y=h.y}
	local nc=rel_crds(hcrds,inp)
	local mt=mtile_from_px(nc)
			
	if can_move_to(nc,inp) then
		--if emote grabbed
		if emote_grabbed_at(hcrds) then
			move_emote_to(hcrds,nc)
		end
		
		if going_backwrd(nc) then
			if not p.severed then
			 undo_move()
			end
		else
			--handle move, push, & grab
			move_hand_to(nc,inp)
			chk_for_push(nc,inp)
		end
	else
		sfx(rnd({5,6}))
	end
	
	--if plates pressed
	if plts_pressed() then
		if not l.trps_on then
			traps_on()
		end
	else
		if l.trps_on then
			traps_off()
		end
	end
		
	check_doors()
	chk_for_merge()
end

function chk_for_push(c,inp)
	local dest=rel_crds(c,inp)
		for o in all(l.sprites) do
		if crds_match(o,c) then
			o.x=dest.x
			o.y=dest.y
		end
	end
end

function crds_match(a,b)
	return a.x==b.x and a.y==b.y
end

function move_hand_to(nc,inp)
	sfx(rnd({1,2,3,4}))
	if p.severed then
		record_severed(h,inp)
	else
		record(h,inp)
	end
	
	h.x=nc.x
	h.y=nc.y
	
	if h.x==p.x and h.y==p.y then
		clr_tbl(a)
		p.severed=false
	end
end

function record_severed(h,ninp)
	local hd=hand_data(ninp)
	h.last=hd
	add(a,{
		inp=ninp,
		x=h.x,
		y=h.y,
		sp=nil,
		hsp=hd.sp,
		fv=hd.fv,
		fh=hd.fh
	})
	if #a>1 then
		local prev=a[#a-1].inp
		local curr=a[#a]
		curr.sp=get_arm_sp(prev,ninp)
	end
	deli(a,1)
end

function record(h,ninp)
	local hd=hand_data(ninp)
	h.last=hd
	add(a,{
		inp=ninp,
		x=h.x,
		y=h.y,
		sp=nil,
		hsp=hd.sp,
		fv=hd.fv,
		fh=hd.fh
	})
	
	if #a>1 then
		local prev=a[#a-1]
		local curr=a[#a]
		curr.sp=get_arm_sp(prev.inp,ninp)
	end
	
end

function handle_input()
	if l.lost then
		if btnp(🅾️) then
			init_lvl(g.l)
		end
		return
	end
	
	if l.won then
		if btnp(🅾️) then
			g.l+=1
			init_lvl(g.l)
		end
		return
	end
	
	--handle grab
	if btn(❎) then
		h.grab=true
	else
		h.grab=false
	end
	
	local inp=nil
	
	if (btnp(⬅️)) inp=⬅️
	if (btnp(➡️)) inp=➡️
	if (btnp(⬆️)) inp=⬆️
	if (btnp(⬇️)) inp=⬇️
	
	if inp then
		try_move_hand(inp)
	end
end
-->8
--draw functions
--draws the main menu
function draw_menu()
	map(116,0,16,10,12,12)
	
	local txt={
		{"press ➡️ to start",2,7},
		{"🅾️ to skip intro",2,6}
	}
	local buf=0
	for t in all(txt) do
		print(t[1],hc(t[1],t[2]),108+buf,t[3])
		buf+=8
	end
end

--draws the story intro
function draw_story()
	tb_draw()
	print('next ➡️', 100,100,13)
end

function draw_level()
	map(unpack(l.rm))
	draw_emotes()
	draw_items()
	draw_player()
	draw_hand()
	draw_ui()
	if #a<1 then
		draw_hints()
	end
end

function draw_end()
	tb_draw()
	print('next ➡️', 100,100,13)
end

function draw_player()
 --player
	spr(1,p.x,p.y)
	--arm
	for i, v in ipairs(a) do
		if v.sp!=nil then
			spr(v.sp,v.x,v.y,1,1,p.fh,p.fv)
		end
	end
end

function draw_hand()
	if (crds_match(h,p)) return
	--hand with arm
	if #a>=1 then
		local hsp=a[#a].hsp
		local hfh=a[#a].fh
		local hfv=a[#a].fv
		local drawsp=hsp
		
		if h.grab then
			if (hsp==10) drawsp=11
			if (hsp==26) drawsp=27
		end
		
		if h.x!=p.x or h.y!=p.y then
			spr(drawsp,h.x,h.y,1,1,hfh,hfv)
		end
	else
		local lfh=h.last.fh
		local lfv=h.last.fv
		local lsp=h.last.sp
		spr(lsp,h.x,h.y,1,1,lfh,lfv)
	end
end

function draw_items()
	for o in all(l.sprites) do
		spr(o.sp,o.x,o.y)
	end
end

function draw_emotes()
	local bump=0
	for i,o in ipairs(l.emotes) do
		if i<g.ofst and g.ofst<i+1 then
		 bump=1
		end
		spr(o.sp,o.x,o.y-bump)
	end
end

function draw_ui()
	rectfill(0,96,127,127,1)
	rect(0,96,127,127,13)
	
	local msg=l.intro
	local msgbuf=0
	local msgcol=7
	
	if #p.emotes>0 then
		if l.banter[#p.emotes] then
			msg=l.banter[#p.emotes]
			msgbuf=0
			msgcol=7
		end
	end
	
	if l.won then
		msg=l.win
		msgbuf=0
		msgcol=11
	elseif l.lost then
		msg=l.lose
		msgbuf=0
		msgcol=8
	end
	
	if l.lost then
		local t1="you got your emotions mixed"
		local t2="up. press 🅾️/z to reset"
		print(t1,hc(t1),10,8)
		print(t2,hc(t2,2),16,8)
	end
	
	if l.won then
		local t="press 🅾️/z to continue."
		print(t,hc(t,2),20,11)
	end
	
	print(msg,hc(msg),100,msgcol)
	
	spr(l.rc,10,109,2,2)
	
	print("drag emotes",75,109,13)
	print("to the "..l.name,75,116,13)
	spr(l.rsp,65,112)
	
	-- level emote goal
	local buffer=0
	for e in all(l.goal) do
		spr(e,30+buffer,110)
		buffer+=9
	end
	
	buffer=0
	
	-- empty circles
	for c in all(l.goal) do
		spr(60,30+buffer,118)
		buffer+=9
	end
	
	buffer=0
	
	for e in all(p.emotes) do
		spr(e,30+buffer,118)
		buffer+=9
	end
end

function draw_hints()
	local fline=3
	for txt in all(l.txt) do
		local offset=0
		if txt[2] then
			offset=txt[2]
		end
		fline+=6
		print(txt[1],hc(txt[1],offset),fline,6)
	end
end
-->8
--talkbox funcitons
function tb_init(voice,string,draws)
	--early exit to prevent dupe
	if reading then return end
 reading=true
 tb={
  str=string,
  voice=voice,
  draws=draws,
  i=1,
  cur=0,
  char=0,
  x=0, -- x coordinate
  y=106, -- y coordginate
  w=127, -- text box width
  h=21, -- text box height
 }
end

function tb_update()
	local strlen=#tb.str[tb.i]
	--[[
		if not finished printing
		increase cur by 0.9
	]]
 if tb.char<strlen then
  tb.cur+=0.9
 end
 
 --[[
 	animate typing and play voice
 	sfx
 ]]
 if tb.cur>0.9 then
  tb.char+=1
  tb.cur=0
  if (ord(tb.str[tb.i],tb.char)!=32) sfx(tb.voice)
 end
 
 if btnp(➡️) then
 	-- if not finished typing
 	if tb.char<strlen then
 	 -- skip typing
 		tb.char=strlen
 	elseif tb.char==strlen then
 		if #tb.str>tb.i then
   	tb.i+=1
   	tb.cur=0
   	tb.char=0
  	else
   	reading=false
   end
  end
 end
end

function tb_draw()
 if reading then
  rectfill(tb.x,tb.y,tb.x+tb.w,tb.y+tb.h,1)
  rect(tb.x,tb.y,tb.x+tb.w,tb.y+tb.h,13)
  print(sub(tb.str[tb.i],1,tb.char),tb.x+2,tb.y+2,7)
 	--render image from data
 	map(unpack(tb.draws[tb.i]))
 end
end
-->8
--utilities
function adv_scene()
	g.scene+=1
	update_scene=up_order[g.scene]
	draw_scene=drw_order[g.scene]
end

function reset_lvl()
	clr_tbl(a)
	h={
		x=p.x,
		y=p.y,
		sp=4,
		fh=false,
		fv=false,
		grab=false
	}
	init_lvl(g.l)
end

function save_lvl()
	memcpy(save_dest,msrc,mlgth)
end

function p_origin(t)
	return t[1]==p.x and t[2]==p.y
end

function chk_for_merge()
	local input={}
	local mt1=l.mrgt[1]
	local mt2=l.mrgt[2]
	--result merge position
	local rmp=l.mrga
	
	for t in all(l.mrgt) do
		if crd_has_emote(t) then
			add(input,get_emote_at(t))
		end
	end
	
	local filled=#input==#l.mrgt
	-- check all inputs match
	if filled then
		local match=input[1].sp+input[2].sp
		local newsp=nil
		
		newsp=matches[tostr(match)]
		if (newsp!=nil) then
			--delete old sprites
			for v in all(input) do
				delete_emote_at(v)
			end
			
			why=newsp
			
			add(l.emotes, {
				x=rmp.x,
				y=rmp.y,
				sp=newsp,
				f=4
			})
		else
			--fizzle sfx
			newsp=31
			add(l.emote, {
				x=rmp.x,
				y=rmp.y,
				sp=newsp,
				f=4
			})
		end
		
		--remove all consumed sprites
		--generate new sprite at altar
	end
end

function chk_for_win()
	for i=1, #p.emotes do
		if l.goal[i]!=p.emotes[i] then
			sfx(9)
			l.lost=true
		end
	end
	
	if #l.goal==#p.emotes then
		if l.lost==false then
			sfx(8)
			l.won=true
		end
	end
end

function clr_tbl(tbl)
 for i=#tbl, 1, -1 do
	 deli(tbl,i)
 end
end

--horizontal center
function hc(s,offst)
	if offst==nil then offst=0 end
	return (64-#s*2)-offst
end

--expects map coords
function m_to_px(x,y)
	local crds={x=0,y=0}
	crds.x=((x-l.rm[1])*8)+l.rm[3]
	crds.y=((y-l.rm[2])*8)+l.rm[4]
	return crds
end

function crd_has_arm(c)
	local xc=c.x
	local yc=c.y
	for arm in all(a) do
		if arm.x==xc and arm.y==yc then
			return true
		end
	end
	return false
end

function get_arm_sp(old,new)
	local horz={18,19,20}
	local vert={34,35,36}
	local ru_dl={33}
	local lu_dr={32}
	local ur_ld={16}
	local rd_ul={17}
	
	local lookup={
		["00"]=horz,
		["11"]=horz,
		["22"]=vert,
		["33"]=vert,
		["12"]=ru_dl,
		["30"]=ru_dl,
		["02"]=lu_dr,
		["31"]=lu_dr,
		["21"]=ur_ld,
		["03"]=ur_ld,
		["13"]=rd_ul,
		["20"]=rd_ul
	}
	
	local trgt=""..old..new
	
	return rnd(lookup[trgt])
end

--gen a tile table key
function tkey(c)
	tk=c.x+c.y*128
	return tostr(tk)
end
-->8
--lookups
cx=63
cy=56
sm=1
md=2
lg=3
xl=4
tsize=8 --tile size
--map saving vars
msrc=0x2000
save_dest = 0x8000
mlgth=0x2000

inpmap={
	["⬆️"]={0,-1},
	["➡️"]={1,0},
	["⬇️"]={0,1},
	["⬅️"]={-1,0}
}

arm_sets={
	["➡️⬇️"]={17},
	["⬆️⬅️"]={17},
	["➡️➡️"]={18,19,20},
	["⬅️⬅️"]={18,19,20},
	["⬇️⬇️"]={34,35,36},
	["⬆️⬆️"]={34,35,36},
	["⬇️➡️"]={32},
	["⬅️⬆️"]={32},
	["➡️⬆️"]={33},
	["⬇️⬅️"]={33},
	["⬅️⬇️"]={16},
	["⬆️➡️"]={16}
}

--offset by inpt
function calc(n,sz,px,py)
	if px then px=cx+px end
	if py then py=cy+py end
	if px == nil then px=cx end
	if py == nil then py=cy end
	return {
		n,
		px,
		py,
		sz,
		sz,
	}
end

story_drw={
	{108,0,30,30,8,5},
	{108,6,35,30,8,6},
	{122,12,40,30,6,6},
	{121,12,60,40,1,3},
	{111,12,22,30,10,7},
	{111,19,14,20,12,9},
	{123,18,44,40,5,5}
}

story_txt={	
[[you are a homunculus,
newly made.]],
[[the wizard who created
you has been down in the
dumps lately.]],
[[he built you in the hopes
you could help cheer him up.]],
[[unfortunately you don't
understand emotions too well...]],
[[maybe the wizard's monster
friends can help you learn
how to feel?]],
[[with your wizard's
blessing, you're sent into
the dungeons.]],
[[discover what you can
so you can bring a smile
to his beared face.]]
}

end_txt={
[[after consorting with the
monsters, something stirs in
your homuncu-chest.]],
[[the wizard's friends have
awoken your emotions!]],
[[you're ready to return to
the wizard in your new form.]],
[[you are hunk-munculus♥.]]
}

end_drw={
	{103,12,32,32,8,7},
	{103,19,32,32,8,7},
	{102,0,40,40,6,5},
	{98,5,24,40,10,6},
}
-->8
--level data
function init_lvl(li)
	reset_lvl()
	
	if li>#lmap then
		adv_scene()
		tb_init(6,end_txt,end_drw)
		return
	end
 
 --set game lvl number to li
	g.l=li
	
	--set level to mapped level
	l=lmap[li]
	
	l.won=false
	l.lost=false
	--static tiles
	l.stl={}
	--portraits and target sprite
	l.rc=nil
	l.rsp=nil
	
	l.sprites={}
	l.emotes={}
	l.mrgt={}
	l.mrga={}
	
	l.trps_on=false
	
	--get level map
	local t=lmap[g.l]
	
	--search map for sprite
	local mxfrom=t.rm[1]
	local myfrom=t.rm[2]
	local mxto=mxfrom+t.rm[5]
	local myto=myfrom+t.rm[6]
	
	local pstart={0,0}
	
	--loop through all map tiles
	for mx=mxfrom,mxto do
		for my=myfrom,myto do
			local tile=mget(mx,my)
			local flag=fget(tile)
			local k=tkey({x=mx,y=my})
			local pxc=m_to_px(mx,my)
			
			local pushsps={9,43}
			
			local function set_stl()
				local acptsps={}
				if is_plt(pxc) or is_trp_dwn(pxc) then 
					acptsps=pushsps
				end
				
				local rstsp=tile
				local rndflr=rnd({48,49,50,51})
				
				--box or key have no rstsp
				if tile==9 or tile==43 then
					rstsp=rndflr
				end
				
				l.stl[k]={
					mx=mx,
					my=my,
					x=pxc.x,
					y=pxc.y,
					pxc=pxc,
					sp=rstsp,
					acptsps=acptsps,
					is_plt=is_plt(pxc),
					is_trp=is_trp(pxc),
					is_rune=is_rune(pxc),
				}
			end
			
			--if player
			if flag==1 then
				pstart=m_to_px(mx,my)
			end
			
			--if npc
			if flag==2 then
				l.rc=sp_to_port[tile]
				l.rsp=tile
				l.name=namelookup[tile]
				l.npccrd=pxc
			end
			
			--add merge tiles
			local mrgt={37,38,53,54}
			if count(mrgt, tile)>0 then
				add(l.mrgt,pxc)
			end
			
			if tile==22 then
				l.mrga=pxc
			end
			
			if flag==3 then
				add(l.sprites,{
					x=pxc.x,
					y=pxc.y,
					sp=tile,
					f=flag
				})
				mset(mx,my,48)
			elseif flag==4 then
				add(l.emotes,{
					x=pxc.x,
					y=pxc.y,
					sp=tile,
					f=flag
				})
				mset(mx,my,48)
			else
				set_stl()
			end
		end
	end
	
	--set up player for level
	p.x=pstart.x
	p.y=pstart.y
	h.x=pstart.x
	h.y=pstart.y
	p.severed=false
	
	--clear out arm data
	clr_tbl(a)
end

function reset_lvl()
	memcpy(msrc, save_dest,mlgth)
	clr_tbl(p.emotes)
end

leveldata={
		{
			--lvl 1 witch intro
			rm={0,0,36,35,7,5},
			goal={31},
			intro="hey lil guy, what's up?",
			lose="",
			win="still learning to talk huh?",
			banter={},
			txt={
				{"⬆️➡️⬇️⬅️ to move hand",8},
				{"hold ❎/x to grab",2},
				{"drag floating emotes."},
			}
		},
		{	
			--lvl 2 witch second intro
			rm={7,0,30,40,9,5},
			goal={46,30},
			intro="did the wizard send you?",
			lose="you're not making any sense.",
			win="something's wrong with him?",
			banter={
				"i'll take that as a yes.",
			},
			txt={
				{"respond with the right"},
				{"emotes in the right order"},
				{"to complete a level."},
			}
		},
		{
			--lvl 3 witch potions
			rm={16,0,26,40,9,7},
			goal={31,46,30},
			intro="i could make him a potion.",
			lose="what are you mumbling about?",
			win="okay, okay no potions!",
			banter={
				"you want eye of newt flavor?",
				"no? maybe hair of dog?",
			},
			txt={
				{"you can push barrels"},
				{"into empty spaces."},
			}
		},
		{
			--lvl 4 witch merge
			rm={25,0,40,40,7,7},
			goal={12},
			intro="you need emotional options.",
			lose="that doesn't seem right...",
			win="nice self expression!",
			banter={},
			txt={
				{"drag solid colors onto"},
				{"the magic dots to create"},
				{"your own emotion."}
			},
		},
		{
			--lvl 5 mummy intro keys
			rm={9,10,36,24,7,9},
			goal={62,31},
			intro="agh! who disturbed my rest!",
			lose="put me in my sarcophagus...",
			win="sorry, been asleep 100 years.",
			banter={
				"aren't you afraid of my curse?",
			},
			txt={
				{"push keys into doors"},
				{"keys can't be grabbed."},
				{"help the mummy calm down."}
			},
		},
		{
			--lvl 6 mummy traps
			rm={0,12,26,32,9,5},
			goal={46},
			intro="watch out for sharp stuff.",
			lose="",
			win="i was worried you'd get hurt.",
			banter={},
			txt={
				{"to get past traps, push"},
				{"boxes onto pressure plates."}
			},
		},
		{
			--lvl 7 mummy severed
			rm={0,17,30,30,9,5},
			goal={46},
			intro="this is going to hurt...",
			lose="",
			win="ouch... are you alright?",
			banter={},
			txt={
				{"try activating the trap"},
				{"while your arm is over it..."},
			},
		},
		{
			--lvl 8 test
			rm={0,17,30,30,9,7},
			goal={12},
			intro="this is going to hurt...",
			lose="that's got me weirded out.",
			win="ouch... are you alright?",
			banter={},
			txt={
				{"try activating the trap"},
				{"while your arm is over it..."},
			},
		},
	}
-->8
--movement handling
--map flag lookup
mfl={
	--empty
	["mpt"]=0,
	--player
	["plr"]=1,
	--npc
	["npc"]=2,
	--pushable tile
	["psh"]=3,
	--grab
	["grb"]=4,
	--obstacle like wall
	["obs"]=5,
	--rune
	["rne"]=6,
	--door
	["dor"]=8,
	--active trap
	["atp"]=9,
	--disabled trap
	["dtp"]=10,
	--plates
	["plt"]=11
}

--checks for flag type
function chk_ft(f,flgs)
	local found=false
	for v in all(flgs) do
		if mfl[v]==f then
			found=true
		end
	end
	return found
end

function last_arm_crd()
	local crds={x=0,y=0}
	if #a then
		crds.x=a[#a].x
		crds.y=a[#a].y
	end
	return crds
end

--accepts destination px coords
function can_move_to(c,inp)
	local mt=mtile_from_px(c)
	local f=mt.mf
	
	--can't ever move onto these
	if chk_ft(f,{"obs","atp"}) then
		return false
	end
	
	if h.grab and crd_has_emote(c) then
		return false
	end
	
	--[[can't move onto own arm
	unless its previous move]]
	if crd_has_arm(c) then
		return crds_match(
			c,last_arm_crd()
		) 
	end
	
	--can move onto items if..
	if crd_has_lsp(c) then
		--can push into next tile
		if valid_push_dir(c,inp) then
			return true
		else
			return false
		end
	end
	return true
end

function crd_has_lsp(c)
	local found=false
	for o in all(l.sprites) do
		if (crds_match(o,c)) found=true
	end
	return found
end

function crd_has_emote(c)
	local found=false
	for e in all(l.emotes) do
		if (crds_match(e,c)) found=true
	end
	return found
end

function lsp_flag(c)
	local f=nil
	for o in all(l.sprites) do
		if (crds_match(o,c)) f=o.f
	end
	return f
end

function lsp_sprite(c)
 local sp=nil
	for o in all(l.sprites) do
		if (crds_match(o,c)) sp=o.sp
	end
	return sp
end

function get_item_at(c)
	local item=nil
	for o in all(l.sprites) do
		if (crds_match(o,c)) item=o
	end
	return item
end

function get_emote_at(c)
	for e in all(l.emotes) do
		if (crds_match(e,c)) return e
	end
	return nil
end

function delete_emote_at(c)
	for e in all(l.emotes) do
		if crds_match(e,c) then
			del(l.emotes, e)
		end
	end
end

function valid_push_dir(c,inp)
	local dest=rel_crds(c,inp)
	--[[cant push into arm
	sprite or item sprite or
 emote sprite]]
	if crd_has_arm(dest) or
	crd_has_lsp(dest) or
	crd_has_emote(dest) then
	 return false
	end
	
	--check for valid flag
	local tile=mtile_from_px(dest)
	local f=tile.mf
	local nsf=lsp_flag(dest)
	local oss=lsp_sprite(c)
	
	local goodtiles={
		"mpt","plt",
		"dtp","rne"
	}
	
	if oss==9 then
		add(goodtiles, "dor")
	end
	
	--map flag is in goodtiles
	if chk_ft(f,goodtiles) or
	chk_ft(nsf,goodtiles) then
	 return true
	end
	
	return false
end

function glyphmap(g)
	local v={x=0,y=0}
	if (g==⬅️) v={x=-1,y=0}
	if (g==➡️) v={x=1,y=0}
	if (g==⬆️) v={x=0,y=-1}
	if (g==⬇️) v={x=0,y=1}
	return v
end

--rltve coords by inp dirctn
function rel_crds(c,inp)
	local x=c.x
	local y=c.y
	local v=glyphmap(inp)
	return {
		x=x+(v.x*8),
		y=y+(v.y*8)
	}
end

function map_crd(x,y)
	local xloc=l.rm[1]
	local yloc=l.rm[2]
	local xoffst=l.rm[3]
	local yoffst=l.rm[4]
	
	local mx=((x-xoffst)/8)+xloc
	local my=((y-l.rm[4])/8)+yloc
	return {tx=mx,ty=my}
end

function mtile_from_px(c)
	local m=map_crd(c.x,c.y)
	local ms=mget(m.tx,m.ty)
	return {
		mx=m.tx,
		my=m.ty,
		ms=ms,
		mf=fget(ms)
	}
end

function hand_data(inp)
	local hdata={
		fh=inp==⬅️,
		fv=inp==⬇️,
		sp=nil
	}
	
	if inp==⬆️ or inp==⬇️ then
		hdata.sp=26
	end
	
	if inp==⬅️ or inp==➡️ then
		hdata.sp=10
	end
	
	return hdata
end

function going_backwrd(dest)
	if (#a<1) return false
	--last move
	local l=a[#a]
	local xmtch=l.x==dest.x
	local ymtch=l.y==dest.y
	return xmtch and ymtch
end

function undo_move()
	--exit if no move to undo
	if (#a<1) return
	sfx(rnd({1,2,3,4}))
	local pop=deli(a)
	h.x=pop.x
	h.y=pop.y
	h.fh=pop.fh
	h.vh=pop.fv
	h.sp=pop.hsp
end

function plts_pressed()
	local plts=0
	local pressed=0
	for k,v in pairs(l.stl) do
		if v.is_plt then
			plts+=1
			local item=lsp_sprite(v.pxc)
			if item==43 then
				pressed+=1
				if mget(v.mx,v.my)!=44 then
					mset
					(v.mx,v.my,44)
				end
			else
				if mget(v.mx,v.my)!=45 then
					mset(v.mx,v.my,45)
				end
			end
		end
	end
	if plts==0 then
		return false
	end
	return plts==pressed
end

function check_doors()
	for k, v in pairs(l.stl) do
		if v.sp==25 then
			local item=get_item_at(v.pxc)
			if lsp_sprite(v.pxc)==9 then
				sfx(13)
				mset(v.mx,v.my,48)
				del(l.sprites,item)
			end
		end
	end
end

function traps_on()
	sfx(13)
	l.trps_on=true
	for k,v in pairs(l.stl) do
		if v.is_trp then
			if v.sp==56 then
				mset(v.mx,v.my,55)
			end
			if v.sp==55 then
				mset(v.mx,v.my,56)
			end
		end
	end
	check_severed()
end

function traps_off()
	sfx(13)
	l.trps_on=false
	for k,v in pairs(l.stl) do
		if v.is_trp then
			mset(v.mx,v.my,v.sp)
		end
	end
	check_severed()
end

function check_severed()
	local armcrds={}
	for k,v in pairs(l.stl) do
		if v.is_trp then
			if crd_has_arm(v.pxc) then
				if mget(v.mx,v.my)==55 then
					add(armcrds,v.pxc)
				end
			end
		end
	end
	sever_arm(armcrds)
end

function sever_arm(acrds)
	local marked=false
	for i=#a,1,-1 do
		for crd in all(acrds) do
			if crd.x==a[i].x and crd.y==a[i].y then
				p.severed=true
				marked=true
			end
		end
		if marked then
			deli(a,i)
		end
	end
end

function emote_grabbed_at(c)
	return h.grab and crd_has_emote(c)
end

function move_emote_to(c,nc)
	local delivered=false
	--if nc has emote or item return
	if crd_has_lsp(nc) or crd_has_emote(nc) then
		return false
	end
	
	if crds_match(nc,l.npccrd) then
		delivered=true
	end
	
	for e in all(l.emotes) do
		if delivered then
			if crds_match(e,c) then
				add(p.emotes,e.sp)
				del(l.emotes,e)
				sfx(rnd({10,11,12}))
				chk_for_win()
				return true
			end
		end
		if crds_match(e,c) then
			e.x=nc.x
			e.y=nc.y
		end
	end
end

function is_box(c)
	local mtile=mtile_from_px(c)
	local boxes={43}
	return count(boxes,mtile.ms)>0
end

function is_key(c)
	local mtile=mtile_from_px(c)
	return mtile.mf==3
end

function is_emote(c)
	local mtile=mtile_from_px(c)
	return mtile.mf==4
end

function is_rune(c)
	local mtile=mtile_from_px(c)
	local runes={
		21,22,23,24,
		37,38,39,40,
		52,53,54
	}
	return count(runes, mtile.ms)>0
end

function is_plt(c)
	local mtile=mtile_from_px(c)
	local plts={44,45}
	return count(plts,mtile.ms)>0
end

function is_trp(c)
	local mtile=mtile_from_px(c)
	local trps={55,56}
	return count(trps,mtile.ms)>0
end

function is_empty(c)
	local mtile=mtile_from_px(c)
	return mtile.mf==0
end

function is_player(c)
	local mtile=mtile_from_px(c)
	return mtile.mf==3
end

function is_trp_dwn(c)
	local mtile=mtile_from_px(c)
	return mtile.ms==56
end

function is_trp_up(c)
	local mtile=mtile_from_px(c)
	return mtile.ms==55
end

__gfx__
0000000000666000000dd0000776770000bbbb000077770007777700ddd00dd000cc00000000000000000000000000000aaaaa00088888000ccccc0009999900
000000000666660000dddd00766666700bbbbbb007777770777777700ddddd000cccc000aaa000000666600006666000a1aaa1a011181110c1ccc1c091191190
0070070066161660ddddddd0658585604b9b9b3007c7c77078778770d8dd8dd0cccccc00a0aaaaa06666660066666600aaaaaaa081888180c7ccc7c099999990
0007700066616660051b15b0766666700b3b3bb00767677077777700ddddddd06585f600a0a0090066606600666d6600a1aaa1a088818880cc111cc091111190
000770006666666005bbb550077676000bb3bb40077c777067676000d72272d06f8f6c00aaa0a0a06600000066dd6600aa111aa088181880c1ccc1c099999990
007007006066606000ddddd076667760bbb3bbb0777c77700655567007dd7d00c666ccc00000000066666000666660002aaaaa20288888202ccccc2029999920
00000000006060000bdddbd0677767703bbbb3b07777777067666760ddddddd0fc6cfcc000000000066600000666000002222200022222000222220002222200
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000011111110111111101111111011111110044444000000000000000000022222000bbbbb000555550007777700
0000000000000000006666000000000000000000111111101ccccc10111111101111111044444440000000000000000022121220bbbbbbb05555555077777770
000006666660000066666666666006666666666611111110c77777c0111111101111111055555550006600000066600021121120b71b71b05155515071777170
0000666666660000666666666666666666666666ccccccccdddddddc111ccccccccc111044444a40066606000666660022222220bbbbbbb05551555077777770
00066666666660006666666666666666666666661111111015555510111c1110111c11104444a4a006600660066dd66022111220bb111bb05515155077111770
006666666666660066600666666666666666666611111110ddddddd0111c1110111c111055555a50066606600666d660122222102bbbbb202555552027777720
00666660066666000000000000666600000000001111111011111110111c1110111c111044444440066666600666666001111100022222000222220002222200
00666600006666000000000000000000000000000000000000000000000c0000000c000000000000006666000066660000000000000000000000000000000000
00666600006666000066660000666600006666001111111011111110111c1110111c1110dddddddddddddddd0000000011111110111111100ddddd000aaaaa00
00666660066666000066660000666600006666001111111011111110111c1110111c1110dddddddddddddddd002220001111111011111110ddddddd0aaaaaaa0
00666666666666000066666006666600006666001117111011171110111c1110111c1110dddddddddddddddd055555001111111011111110dd1d1dd0aaaaaaa0
000666666666600000066660066660000066660011777ccccc777110111ccccccccc1110dddddddddddddddd042424001155511011555110ddddddd0aaaaaaa0
000066666666000000066660066660000066660011171110111711101111111011111110dddddddddddddddd042424001555551015555510dd111dd0aaaaaaa0
000006666660000000666660066666000066660011111110111111101111111011111110dddddd111111111100555000b22222b0822222802ddddd202aaaaa20
000000000000000000666600006666000066660011111110111111101111111011111110dddddd1111111111000000001bbbbb10188888100222220002222200
000000000000000000666600006666000066660000000000000000000000000000000000dddddd10000000000000000000000000000000000000000000000000
11111110111111001111111011111110111c1110111c1110111111101711171011111110dddddd10dddddddddddddd1007777700088888000ccccc0009999900
11111110111111101111111001111110111c1110111c1110111111106561656011111110dddddd10dddddddddddddd107000007088888880ccccccc099999990
11111110111111101111110011111110111c11101117111011171110ddd1ddd0ddd1ddd0dddddd10dddddddddddddd107070707088888880ccccccc099999990
11111110111111101111111011111110111c111011777110117771101111111011111110dddddd10dddddddddddddd107000007088888880ccccccc099999990
11111110111111101111111011111110111c111011171110111711101711171011111110dddddd10dddddddddddddd107077707088888880ccccccc099999990
11111110111111101111111011111110111c111011111110111c11106561656011111110dddddd10111111111111111070000070288888202ccccc2029999920
11111110011111101111111011111110111c111011111110111c1110ddd1ddd0ddd1ddd0dddddd10111111111111111007777700022222000222220002222200
00000000000000000000000000000000000c000000000000000c00000000000000000000dddddd10000000000000000000000000000000000000000000000000
00000000111114101111111011aaa1100000c0000000000cc00000000000c000000000dddd0000000000777777760000000000cccc0000000000000000000000
0111111011114110155555101a999a1000000000000000cc7c00000000c0000000000ddddd00000000077776666770000000cccccccc00000000000000000000
5b3b33b5111411105b3b33501a9a9a1000c00c00000000cccc00000000cc00000000ddd2ddd000000077766777777700000cccccccccc0000000000000000000
555515551a211110555555501a999a100ccc0cc0000000cccc00000000cccc00000ddddddddd00000776666666667770000cceecceecc0000000000000000000
55555155aa91111055155550199999100ccc0cc000000c7cccc00000000ccc000ddd2ddd2dd2ddd00765885558856770000ceeeeceeec0000000000000000000
55155555a9111110155555101aa9aa100ccc00c000000ccc7cc00000000ccc0000dddddddddddd00066588555885677000cceeeeeeeecc000000000000000000
0555555011111110151115101222221000c0000000000ccccccc00000000c00000b571337155b00007766666666677700cccceeeeeecccc00000000000000000
05010050000000000000000000000000000000000000cc7ccc7c00000000000000b5bb33bb5bb00007777766777777700cccceeeeeecccc00000000000000000
007777001111111000000066600000001111111000007c7cc7c7c000000000000000bb111bb250000077777766777700cccccceeeecccccc0000000000000000
00077000111d11100000066666000000d661111000007c7cc7c7c0000000000000052bbbbb2b50000007777777676600ccc0ccceeccc0ccc0000000000000000
007bb70011ddd1100000661616600000dd551110000cc7c7c7cc700600000000000bd22222dbb0000076666666666770cc00cccccccc00cc0000000000000000
073bbb701d1d1d100000666166600000ddd66110606cc7cc7cccc6660000000000bbdddddbbbb0000777767777777760cc0cccccccccc0cc0000000000000000
73b3b337111d11100000666666600000dddd55106666cccccccc66600000000000bbbdddbbbb2d000677776677777670000cccc00cccc0000000000000000000
73333317111d11100000606660600000ddddd660066666cac66666600000000000bbbb2dbbbb2d000766777767666770000ccc0000ccc0000000000000000000
71313117111111100000006060000000ddddddd00006666866666000000000000d2bbbdd2bb2ddd007776667667777700cccc000000cccc00000000000000000
077777700000000000000000000000000000000000675588a5576666000000000ddbbdddddddddd007777776677777700cccc000000cccc00000000000000000
0000000000000000022222000bbbbb0000000000666a5588a55a66660000000000000000000c00000000000000aaaa0000000066660000000cc7666666666666
000001111110000022222220bbbbbbb000000006666ae888aeea666660000000000000c000000c00000000000aaaaaa00000666666660000cccc666666666666
00111b3333b1110022222220bbbbbbb0000000666666a8888aa6666666000000000cc0000000cc000000000aa99aaaaa0006111661116000c7ccc66666666666
055b33bbbb33b55022222220bbbbbbb00000006666666688666666666600000000ccc00000cccc000000aaaaaaa90aaa0006616166166000ccccaaaa66666666
05555b3333b5555022222220bbbbbbb00000006666666eeee666666666cc000000ccc00000ccc0000000aaaaaaaa00aa0006616166166000cccaaaaaa6666666
0555555515555550122222102bbbbb200000cc666666e6666ee6666666ccc00000cc000000ccc00000aaaaaa9aaaa0000066666166666600ccaaaaa99aa66666
00555555515555000111110002222200000cc6666666666666666666666cc0000c000000000c00000aaa9aaaa9aaa0000666666116666660ccaaa09aaaaaaa66
0015551555555100000000000000000000ccc6666666666666666666666cccc000000000000000000aaaa9aaa90a00aa066666666666666000aa00aaaaaaaa66
05510555555015500000000000000000cccc66666666666666666666666ccccc000000ccc000000009aaa9aaa9000aaa666666111166666600000aaaa9aaaaaa
05500011110005500000000000000000cccc66666666666666666666c66ccccc00000cecec00000009aaa99a9aaaaaaa666066611666066600000aaa9aaaa9aa
55500001100005550000000000000000c7ccc666666666666666666ccccccccc0000ceeeeec00000099a9999aaaaaaa0660066666666006600aa00a09aaa9aaa
55000001100000550000000000000000ccccccc66666666666666666cccc7ccc0000cceeecc000000099999aaaaaaa00660666666666606600aaa0009aaa9aaa
55000001100000550000000000000000ccccccc666c6666666666666cccccccc0000ccceccc0000000099999aaaa0000000666600666600000aaaaaaa9a99aaa
55500001100005550000000000000000ccc7ccc66ccc6666666cc666cccccccc0000c0ccc0c0000000000000000000000006660000666000000aaaaaaa9999a9
05550001100055500000000000000000cccccccccccccc666cccccccc7cccccc000000c0c0000000000000000000000006666000000666600000aaaaaaa99999
55550000000055550000000000000000cccccccccccccc666ccccccccccccccc000000000000000000000000000000000666600000066660000000aaaa999900
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
080080008080008008000800800800080008080008880008080008000008080008880000ee00e000000000000000000000000000000000000000000000000000
88008808808808880880880880888088808808808888808808808800008808808888800eee0eee00000000000000000000000000000000000000000000000000
88888808808808808880888800888888808808808800008808808800008808808880000eeeeeee00000000000000000000000000000000000000000000000000
888888088088088088808888808808088088088088800088088088800088088000880000eeeee000000000000000000000000000000000000000000000000000
8800880888880880888088088088000880888880888880888880888880888880888880000eee0000000000000000000000000000000000000000000000000000
08008000888000800800080080080008000888000888000888000888000888000888000000e00000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666a5588a55a666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000006666ae888aeea666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000666666a8888aa6666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000066666666886666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000066666666eeee666666666cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000aa6aa6aa666666ee66aa6aacaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0caaaaaaaaaa9a6666a9aaaaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccaaaaaaaaaaa9a66a9aaaaaaaaaaac0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddaaaaaaaaaaaddddddaaaaaaaaaaadd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddaaadaaadaaaddddddaaadaaadaaadd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddaaadaaadaaaddddddaaadaaadaaadd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddaaddaaddaaddddddaaddaaddaaddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddddddddddddddddddddddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
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
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000c000000000000000cc7c00000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000cc00000000000000000cccc00000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000ccc00000000000000000cccc00000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000ccc0000000000000000c7cccc0000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000cc00000000000000000ccc7cc0000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000c0000000000000000000ccccccc000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc7ccc7c000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000c000000000000000000000007c7cc7c7c00000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000c00000000000000000000000007c7cc7c7c00000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000cc00000000000000000000000cc7c7c7cc700660000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000cccc000000000000000006606cc7cc7cccc66600000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000ccc0000000000000000006666cccccccc666000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000ccc000000000000000000066666cac666666000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000c0000000000000000000000666686666600000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000675588a557666600000000000000000000000000000000
000000000000000000000000000000000000c0000000000000aaaa00000000000000c00000000000666a5588a55a666600000000000000000000000000000000
0000000000000000000000000000000000000000000000000aaaaaa0000000000000000000000006666ae888aeea666660000000000000000000000000000000
0000000000000000000000000000000000c00c000000000aa99aaaaa0000000000c00c00000000666666a8888aa6666666000000000000000000000000000000
000000000000000000000000000000000ccc0cc00000aaaaaaa90aaa000000000ccc0cc000000066666666886666666666000000000000000000000000000000
000000000000000000000000000000000ccc0cc00000aaaaaaaa00aa000000000ccc0cc00000006666666eeee666666666cc0000000000000000000000000000
000000000000000000000000000000000ccc00c000aaaaaa9aaaa000000000000ccc00c00000cc666666e6666ee6666666ccc000000000000000000000000000
0000000000000000000000000000000000c000000aaa9aaaa9aaa0000000000000c00000000cc6666666666666666666666cc000000000000000000000000000
00000000000000000000000000000000000000000aaaa9aaa90a00aa000000000000000000ccc6666666666666666666666cccc0000000000000000000000000
000000000000000000000000000000000000000009aaa9aaa9000aaa00000000000000000cc766666666666666666666666ccccc000000000000000000000000
000000000000000000000000000000000000000009aaa99a9aaaaaaa0000000000000000cccc66666666666666666666c66ccccc000000000000000000000000
0000000000000000000000000000000000000000099a9999aaaaaaa00000000000000000c7ccc666666666666666666ccccccccc000000000000000000000000
00000000000000000000000000000000000000000099999aaaaaaa000000000000000000ccccaaaa6666666666666666cccc7ccc000000000000000000000000
000000000000000000000000000000000000000000099999aaaa00000000000000000000cccaaaaaa666666666666666cccccccc000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000ccaaaaa99aa66666666cc666cccccccc000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000ccaaa09aaaaaaa666cccccccc7cccccc000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000aa00aaaaaaaa666ccccccccccccccc000000000000000000000000
0000000000000000000000001111111000000000000000000000c000000000666000000000000aaaa9aaaaaa0000000000000000000000000000000000000000
00000000000000000000000001111110000000000000000000c00000000006666600000000000aaa9aaaa9aa0000000000000000000000000000000000000000
00000000000000000000000011111110000000000000000000cc0000000066161660000000aa00a09aaa9aaa0000000000000000000000000000000000000000
00000000000000000000000011111110000000000000000000cccc00000066616660000000aaa0009aaa9aaa0000000000000000000000000000000000000000
000000000000000000000000111111100000000000000000000ccc00000066666660000000aaaaaaa9a99aaa0000000000000000000000000000000000000000
000000000000000000000000111111100000000000000000000ccc000000606660600000000aaaaaaa9999a90000000000000000000000000000000000000000
0000000000000000000000001111111000000000000000000000c00000000060600000000000aaaaaaa999990000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000aaaa9999000000000000000000000000000000000000000000
0000000000000000000000000000000000000000111111101111111000000000000000000000000000000000000c000011111100000000000000000000000000
000000000000000000000000000000000000000001111110011111100000011111100000000000000000000000000c0011111110000000000000000000000000
0000000000000000000000000000000000000000111111101111111000111b3333b1110000000000000000000000cc0011111110000000000000000000000000
00000000000000000000000000000000000000001111111011111110055b33bbbb33b550000000000000000000cccc0011111110000000000000000000000000
0000000000000000000000000000000000000000111111101111111005555b3333b55550000000000000000000ccc00011111110000000000000000000000000
000000000000000000000000000000000000000011111110111111100555555515555550000000000000000000ccc00011111110000000000000000000000000
0000000000000000000000000000000000000000111111101111111000555555515555000000000000000000000c000001111110000000000000000000000000
00000000000000000000000000000000000000000000000000000000001555155555510000000000000000000000000000000000000000000000000000000000
000000000000000000000000dddddd100000c00011111110111111100551055555501550111111101111111000000000dddddd10000000000000000000000000
000000000000000000000000dddddd1000c0000011111110111111100550001111000550111111101111111000000000dddddd10000000000000000000000000
000000000000000000000000dddddd1000cc000011111110111c11105550000110000555111c11101111111000000000dddddd10000000000000000000000000
000000000000000000000000dddddd1000cccc00111cccccccc7c110550000011000005511c7cccccccc111000000000dddddd10000000000000000000000000
000000000000000000000000dddddd10000ccc00111c1110111c11105500000110000055111c1110111c111000000000dddddd10000000000000000000000000
000000000000000000000000dddddd10000ccc00111c111011111110555000011000055511111110111c111000000000dddddd10000000000000000000000000
000000000000000000000000dddddd100000c000111c111011111110055500011000555011111110111c111000000000dddddd10000000000000000000000000
000000000000000000000000dddddd1000000000000c000000000000555500000000555500000000000c000000000000dddddd10000000000000000000000000
0000000000000000dddddddddddddd1011111110111c1110000dd000111111101111111000bbbb00111c111011111110dddddddddddddd100000000000000000
0000000000000000dddddddddddddd1011111110111c111000dddd0011111110111111100bbbbbb0111c111011111110dddddddddddddd100000000000000000
0000000000000000dddddddddddddd1011111110111c1110ddddddd011111110111111104b9b9b30111c111011111110dddddddddddddd100000000000000000
0000000000000000dddddddddddddd10111ccccccccc1110051b15b011111110111111100b3b3bb0111ccccccccc1110dddddddddddddd100000000000000000
0000000000000000dddddddddddddd10111c11101111111005bbb55011111110111111100bb3bb4011111110111c1110dddddddddddddd100000000000000000
0000000000000000dddddd1111111110111c11101111111000ddddd01111111011111110bbb3bbb011111110111c111011111111dddddd100000000000000000
0000000000000000dddddd1111111110111c1110111111100bdddbd011111110111111103bbbb3b011111110111c111011111111dddddd100000000000000000
0000000000000000dddddd1000000000000c0000000000000000000000000000000000000000000000000000000c000000000000dddddd100000000000000000
0000000000000000dddddd1011111110111c1110077677001111110011111110111111001111111000777700111c111011111110dddddd100000000000000000
0000000000000000dddddd1011111110111c1110766666701111111011111110111111101111111007777770111c111011111110dddddd100000000000000000
0000000000000000dddddd1011111110111c1110658585601111111011111110111111101111111007c7c770111c111011111110dddddd100000000000000000
0000000000000000dddddd1011111110111c1110766666701111111011111110111111101111111007676770111c111011111110dddddd100000000000000000
0000000000000000dddddd1011111110111c11100776760011111110111111101111111011111110077c7770111c111011111110dddddd100000000000000000
0000000000000000dddddd1011111110111c11107666776011111110111111101111111011111110777c7770111c111011111110dddddd100000000000000000
0000000000000000dddddd1011111110111c1110677767700111111011111110011111101111111077777770111c111011111110dddddd100000000000000000
0000000000000000dddddd1000000000000c0000000000000000000000000000000000000000000000000000000c000000000000dddddd100000000000000000
0000000000000000dddddddddddddd10111c111011111110ddd00dd011111110111111100777770011111110111c1110dddddddddddddd100000000000000000
0000000000000000dddddddddddddd10111c1110111111100ddddd0011111110011111107777777011111110111c1110dddddddddddddd100000000000000000
0000000000000000dddddddddddddd10111c1110111c1110d8dd8dd0111111101111111078778770111c1110111c1110dddddddddddddd100000000000000000
0000000000000000dddddddddddddd10111cccccccc7c110ddddddd011111110111111107777770011c7cccccccc1110dddddddddddddd100000000000000000
0000000000000000dddddddddddddd1011111110111c1110d72272d0111111101111111067676000111c111011111110dddddddddddddd100000000000000000
000000000000000011111111dddddd10111111101111111007dd7d001111111011111110065556701111111011111110dddddd11111111100000000000000000
000000000000000011111111dddddd101111111011111110ddddddd01111101011111110676667601111111011111110dddddd11111111100000000000000000
000000000000000000000000dddddd100000000000000000000000000000000000000000000000000000000000000000dddddd10000000000000000000000000
000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd10000000000000000000000000
000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd10000000000000000000000000
000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd10000000000000000000000000
000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd10000000000000000000000000
000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd10000000000000000000000000
00000000000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111110000000000000000000000000
00000000000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111110000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000080080008080008008000800800800080008080008880008080008000008080008880000ee00e000000000000000000000000000
00000000000000000000000088008808808808880880880880888088808808808888808808808800008808808888800eee0eee00000000000000000000000000
00000000000000000000000088888808808808808880888800888888808808808800008808808800008808808880000eeeeeee00000000000000000000000000
000000000000000000000000888888088088088088808888808808088088088088800088088088800088088000880000eeeee000000000000000000000000000
0000000000000000000000008800880888880880888088088088000880888880888880888880888880888880888880000eee0000000000000000000000000000
00000000000000000000000008008000888000800800080080080008000888000888000888000888000888000888000000e00000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000077707770777007700770000007777700000077700770000007707770777077707770000000000000000000000000000000
00000000000000000000000000000070707070700070007000000077007770000007007070000070000700707070700700000000000000000000000000000000
00000000000000000000000000000077707700770077707770000077000770000007007070000077700700777077000700000000000000000000000000000000
00000000000000000000000000000070007070700000700070000077007770000007007070000000700700707070700700000000000000000000000000000000
00000000000000000000000000000070007070777077007700000007777700000007007700000077000700707070700700000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000066666000000666006600000066060606660666000006660660066606660066000000000000000000000000000000000
00000000000000000000000000000000660006600000060060600000600060600600606000000600606006006060606000000000000000000000000000000000
00000000000000000000000000000000660606600000060060600000666066000600666000000600606006006600606000000000000000000000000000000000
00000000000000000000000000000000660006600000060060600000006060600600600000000600606006006060606000000000000000000000000000000000
00000000000000000000000000000000066666000000060066000000660060606660600000006660606006006060660000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0001020202020202020300000404040400000000000006000008000004040404000000000006060000050503030b040400000000000606090a0505050204040405050505000000000000000000000000000000000000000000000000000000000000040400000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
292a292a3a2a390000292a2a2a390000292a2a2a2a2a39000000292a2a2a3900292a2a2a292a2a39000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d1800000000300000000032000000000000680045460000
39013930303039292a3b302e302a2a3939420230301e2a2a3900392516263900393030303930302a390000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444c4d47000000003132300000000000000047004455566800
39303b1f393039390132303b303002392a2a293b3030301f39293b5130512a39393030303b2b2b3039000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c155c5d152e00003330013130000000446a6b00446465666700
393030303902392a2a39311e30292a3b292a3b2b303030303939013030300239392b2b3030303030390000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000681728690030000031423000310000007a7b00006e6f767700
2a2a2a2a2a2a3b00002a2a2a2a3b0000390131302b303030392a2a392f292a3b3930302a392b2b3039000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000270e00000000300033000000003300004752537e7f000000
000000000000000000000000000000002a2a3930302b302e390000392f3900002a3930303930303039000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333000000000000000000000000000000333360610000693100
0000000000000000000000000000000000002a2a2a2a2a2a3b00002a2a3b0000002a2a2a2a2a2a2a3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000306c6d300000000000004546000000003968172670712518003900
00000000000000000000000000000000292a2a2a2a2a2a2a2a2a2a2a2a2a2a39000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000031307c7d313100000000445556680000293b17280230300427182a39
0000000000000000000000000000000039303030303030303030303030303039000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000303131300000000047909192936900393034033130313005343039
000000000000000000000000000000003930303030303030303030303030303900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333300000000292aa0a1a2a32a392a392726073233062528293b
0000000000000000000000292a39000039303030303030303030303030303039000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000808182838485868788893930013132303339002a2a2a2a2a2a2a2a2a3b00
00000000000000000000293b032a390039303030303030303030303030303039000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002a2a2a2a2a2a2a3b008081828384858687888900
292a2a2a2a2a2a2a39293b1f1f1f2a3939303030303030303030303030303039000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000320000000047004849004a4b00683c001f0d0e0f00
393030303130370339292a3b192a2a392a2a2a2a2a2a2a2a2a2a2a2a2a2a2a3b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000032333332000000000f5859695a5b0d0001000c52532e00
3930012b2e2b3737393933093030303924000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304406076830000005292a2a2a2a2a390440001d1c1e1f00
39303030313232303939303b30300139240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000303303525302330044293b25151615262a3900003360613300
2a2a2a2a2a2a2a2a3b3930303030303924000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000032324704056932320039023230013232033900323070713031
292a2a2a2a2a2a2a392a39251626293b2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030303333323200002a390732313106293b00003130323000
390130300c0d303039002a2a2a2a3b00240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003032000000002a2a2a2a2a2a3b0000001012141311
3930323030303030390000000000000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000320000000069004745460000000000002410121123
393030303030303039000000000000002400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000323333320000476a6b6855560000000000002224012122
393030303031303039000000000000002400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030440f1c683000007a7b6465929344003b30002320131421
3930303030300230390000000000000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030330d78790c33000000292a2aa2a3293b380000201314120a
2a2a2a2a2a2a2a2a3b000000000000002400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003232471d0e69323200293b303330313b370031260000000000
00000000292a2a2a2a2a2a3900000000240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003030333332320000395401323009193231023b1800000000
000000293b32301f1f30362a390000002400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030320000002a393230303039320033000000000000
00002939321e312a3b1728332a2a3900240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002a2a2a2a2a2a3b332b360000000000
00293b3b171515151528323009192a3924000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002d3b000000000000
293b3030343b2c17183b292a3932433900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000031000000000000
3930303927161528272639003932033900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2a2a2a2a2a2a2a2a2a3b002a2a2a3b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
__sfx__
991e00000e535000000000000000095350000000000000000e535000000000000000095350000000000000000e5350953500000085050e5350953500000005051853500000155350000011535000000e53500505
010300000e51013510135000050002500215002350000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00030000125201651011500025001f5001c5001a50000503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503
00030000165101d510025000050016500185001a50000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00030000175101a51000500145000d500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00050000110300a020005000000008500165000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500000e0300602000000170000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c03000016520185201b5201f52024520275202952000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000000000000
0004000013720137001b7201b700227202470000700137202c7001a72000700227201b70027730227002c73026700007000070000700007000070000700007000070000700007000070000700007000070000700
00040000001000f120121201512015120121200f1200c120001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000400000b0200f0201202014020170201b0001b00009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000d0200f020120201602019020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000c0200f020130201602018020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000009620036000f6400f640106001b6001c6001c6001c6001d60000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
011e00000000000000000000000037000000000000000000116150060500605006051161500605006050060511615006050060500605116150060500605006051161500605006050060511615006050060500605
011e00000e05400004110541005411054000040e0541105410054110540e054000040205400004000040000411054100540e0540c0540b0540c0540e0541005411054000000b0540000002054000040000000000
001e00000561505615006050000005615006050060500605056150060500605006050561500605006050060505615006050060500605056150060500605006050561500000000000000000000000000000000000
010400002561300000196131062300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603000030000000000
010400001061300000196132562300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 000e4344
06 0f104344


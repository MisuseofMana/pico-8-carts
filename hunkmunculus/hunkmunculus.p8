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
		l=0,
	}
	
	lmap=leveldata()
	
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
	sp_to_port[5]=138
	sp_to_port[6]=142
	sp_to_port[7]=172
	sp_to_port[8]=172
	
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
	music(0)
end

function _update()
	if g.l == 0 then
		update_menu()
	else
		update_level()
	end
end

function _draw()
	cls()
	if g.l == 0 then
		draw_menu()
	else
		draw_level()
	end
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
 	init_lvl(1)
 	music(-1)
 end
 if btnp(🅾️) then
 	init_lvl(2)
 	music(-1)
 end
end

function update_level()
	if reading then
		tb_update()
	else
		if l.tp=="story" or l.tp=="cutscene" or l.tp=="end" then
			adv_scene()
		else
			g.ofst+=0.1
			if (g.ofst>#l.emotes+1) g.ofst=0.1
			handle_input()
		end
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
function draw_level()
	if l.tp=="story" or l.tp=="cutscene" or l.tp=="end" then
		tb_draw()
		print('next ➡️', 100,100,13)
	else
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
		music(-1)
		msg=l.win
		msgbuf=0
		msgcol=11
	elseif l.lost then
		music(-1)
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
		print(t,hc(t,2),88,11)
	end
	
	print(msg,hc(msg),100,msgcol)
	
	spr(l.rc,10,108,2,2)
	
	print("target",85,113,13)
	spr(l.rsp,75,112)
	
	-- level emote goal
	local buffer=0
	for e in all(l.goal) do
		spr(e,30+buffer,108)
		buffer+=9
	end
	
	buffer=0
	
	-- empty circles
	for c in all(l.goal) do
		spr(60,30+buffer,117)
		buffer+=9
	end
	
	buffer=0
	
	for e in all(p.emotes) do
		spr(e,30+buffer,117)
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
  x=0, --x coordinate
  y=106, --y coordginate
  w=127, --text box width
  h=21, --text box height
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
	g.l+=1
	init_lvl(g.l)
end

function save_lvl()
	memcpy(save_dest,msrc,mlgth)
end

function chk_for_merge()
	if not l.mergelvl then
		return
	end
	local input={}
	local mt1=l.mrgt[1]
	local mt2=l.mrgt[2]
	--result merge position
	local rmp=l.mrga
	
	--if merge location has emote
	if crd_has_emote(rmp) then
		--do nothing and early exit
		return
	end
	
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
			
			add(l.emotes, {
				x=rmp.x,
				y=rmp.y,
				sp=newsp,
				f=4
			})
			sfx(7)
		else
			--fizzle sfx
			newsp=31
			add(l.emote, {
				x=rmp.x,
				y=rmp.y,
				sp=newsp,
				f=4
			})
			sfx(22)
		end
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

-->8
--level data
function init_lvl(li)
	reset_lvl()
	
	if li>#lmap then
		g.l=0
		return
	end
 
	--set game lvl number to li
	g.l=li
	
	--set level to mapped level
	l=lmap[li]
	
	--handle story, cutscene, and end sequences
	if l.tp=="story" or l.tp=="cutscene" or l.tp=="end" then
		tb_init(lmap[li].voice,lmap[li].txt,lmap[li].drw)
		return
	end
	
	if l.mus!=nil then
	music(l.mus)
	else
	music(-1)
	end
	
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
	l.mergelvl=false
	
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
	for mx=mxfrom,mxto-1 do
		for my=myfrom,myto-1 do
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
				l.mergelvl=true
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

function leveldata()
	local defaults = {
		rm={},
		goal={},
		intro="",
		lose="",
		win="",
		banter={},
		txt={},
		voice=6,
		drw={},
		tp="level",
		mus=nil
	}
	
	local story_item = {
		tp="story",
		voice=6,
		txt={
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
		},
		drw={
			{108,0,30,30,8,5},
			{108,6,35,30,8,6},
			{122,12,40,30,6,6},
			{121,12,60,40,1,3},
			{111,12,22,30,10,7},
			{111,19,14,20,12,9},
			{123,18,44,40,5,5}
		}
	}
	
	local end_item = {
		tp="end",
		voice=6,
		txt={
[[after consorting with the
monsters, something stirs in
your homuncu-chest.]],
[[the wizard's friends have
awoken your emotions!]],
[[you cheered up your creator!]],
[[you are hunk-munculus♥.]],
[[thank you for playing.
♥♥♥ i love you. ♥♥♥]]
		},
		drw={
			{103,12,32,32,8,7},
			{103,19,32,32,8,7},
			{102,0,40,40,6,5},
			{98,5,24,40,10,6},
			{81,24,24,40,8,7}
		}
	}
	
	local witch_levels = {
		{
			mus=2,
			tp="level",
			rm={0,0,36,35,7,5},
			goal={31},
			intro="hey lil guy, what's up?",
			win="still learning to talk huh?",

			txt={
				{"⬆️➡️⬇️⬅️ to move hand",8},
				{"hold ❎/x to grab",2},
				{"drag floating emotes."},
			}
		},
		{
			mus=2,
			tp="level",
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
			mus=2,
			tp="level",
			rm={25,0,40,30,7,5},
			goal={12},
			intro="you need some emotional help.",
			lose="that doesn't seem right...",
			win="that's a happy response!",
			txt={
				{"combine two yellow to"},
				{"make a happy emote."},
			},
		},
		{
			mus=2,
			tp="level",
			rm={32,0,40,34,7,5},
			goal={13,14},
			intro="show me angry...",
			lose="tsk tsk, that's not it.",
			win="nice work, you learn fast!",
			banter={"great! now do sad."},
			txt={
				{"match two red for angry."},
				{"match two blue for sad."}
			},
		},
		{
			tp="cutscene",
			voice=19,
			txt={
[[that's all i can teach
you lil guy.]],
[[go see my friend moss now.]],
[[he can teach you how to
express yourself with more
complex emotions.]]
			},
			drw={
				{93,0,38,30,7,6},
				{92,6,42,30,6,5},
				{92,11,44,40,5,3},
			}
		},
	}
	
	local moss_levels = {
		{
			mus=5,
			tp="level",
			rm={59,0,30,24,9,8},
			goal={31},
			intro="w-who's out there?",
			win="oh! a homunculus!?",
			txt={
				{"barrels can be pushed"},
				{"into empty spaces."}
			},
		},
		{
		 mus=5,
			tp="level",
			rm={68,0,36,24,7,8},
			goal={30,46},
			intro="s-sorry for being nervous.",
			lose="what...",
			win="come with m-me.",
			banter={"did t-the witch send you?"},
			txt={
				{"if you get stuck, pause"},
				{"and choose reset level."}
			},
		},
		{
		 mus=5,
			tp="level",
			rm={39,0,24,30,11,7},
			goal={63,98,99},
			intro="try ∧mixing∧ colors.",
			lose="that's not it...",
			win="green is my favorite ♥",
			banter={
				"a lovely orange.",
				"what a nice purple.",
			},
			txt={
				{"mixing primary colors"},
				{"makes secondary colors."}
			},
		},
		{
		 mus=5,
			tp="level",
			rm={75,0,24,8,10,10},
			goal={15,28,29},
			intro="this is my garden.",
			lose="i don't get it...",
			win="let me t-teach you more.",
			banter={
				"it's nice here, right?",
				"colors are the best.",
				"thanks for being emotional."
			},
		},
		{
			tp="cutscene",
			voice=19,
			txt={
[[i'm g-glad you came to
see me.]],
[[but all t-things come
to an end, don't they?]],
[[speaking of ends, go
visit my dead skeleton
friend.]],
[[he's scared to leave,
his house, but you'll
learn a lot from him.]]
			},
			drw={
				{97,11,42,30,6,6},
				{97,11,42,30,6,6},
				{91,19,42,36,6,5},
				{97,22,42,36,6,5}
			}
		},
	}
	
	local skeleton_levels = {
		{
			mus=8,
			tp="level",
			rm={0,5,32,32,9,7},
			goal={31},
			intro="nobodies home!",
			win="hmm, you're so tiny...",
			txt={
				{"to get past doors, push"},
				{"keys into them."}
			},
		},
		{
			mus=8,
			tp="level",
			rm={9,5,26,32,7,7},
			goal={30,28},
			intro="what do you want?",
			win="but you're so tiny...",
			banter={
				"that's a blank stare...",
				"oh! you know merging!"
			},
			txt={
				{"if you feel stuck, press"},
				{"pause and then pick"},
				{"reset level."}
			},
		},
		{
			mus=8,
			tp="level",
			rm={16,7,26,24,9,8},
			goal={29},
			intro="try getting in now!",
			win="ah! you're so tricky!",
			txt={
				{"get creative with your"},
				{"pushing and dragging."}
			},
		},
		{
			mus=8,
			tp="level",
			rm={25,5,26,32,9,7},
			goal={13},
			intro="no way you get in!",
			win="you've bested me!",
			txt={
				{"remember, you can reset"},
				{"from the pause menu."}
			},
		},
		{
			mus=8,
			tp="level",
			rm={34,7,24,21,10,9},
			goal={15},
			intro="i'm not coming out!",
			win="is it safe out there?",
			txt={
				{"so many keys!"}
			},
		},
		{
			tp="cutscene",
			voice=24,
			txt={
[[ahh, man... i've been
scared to leave my house
for so long...]],
[[thanks for coming by
and helping to encourage
me to leave.]],
[[you'll cheer up your
wizard, no problem when
you get home.]],
[[go see my friend ghost,
she knows all sorts of
reasons for feeling sad.]]
			},
			drw={
				{90,14,34,32,7,5},
				{91,19,40,32,6,5},
				{90,24,34,32,7,5},
				{123,23,44,42,5,4}
			}
		},
	}
	
	local ghost_levels={
		{
			--18
			mus=11,
			tp="level",
			rm={44,7,24,24,10,8},
			goal={31,14},
			intro="helloooo???",
			win="what has you sooo sad?",
			banter={
			"yooou're here for meee?",
			},
			txt={
				{"push barrels onto"},
				{"plates to toggle traps."}
			},
		},
		{
			--19
			mus=11,
			tp="level",
			rm={50,0,28,30,9,7},
			goal={31,30,14},
			intro="you met with other monsters?",
			win="i know all about grief...",
			banter={
			"your wizard is depressed?",
			"how hooorible...",
			},
			txt={
				{"all plates must have"},
				{"a barrel to trigger."}
			},
		},
		{
			mus=11,
			tp="level",
			rm={54,8,12,24,13,7},
			goal={31,14},
			intro="grief... it's like...",
			win="you need to go to him.",
			banter={
			"losing part of yourself...",
			"your wizard must be grieving.",
			},
			txt={
				{"we all sacrifice something."},
			},
		},
		{
			tp="cutscene",
			voice=23,
			txt={
[[your wizard is mourning
you, his creation.]],
[[maybe he wanted to give
you the world...]],
[[and despite his effort
feels he let you down...]],
[[go show him what you've
learned, your growth will
surely bring him joy.]]
			},
			drw={
				{86,0,34,32,7,6},
				{85,5,34,34,7,5},
				{82,11,28,28,8,7},
				{82,18,34,30,7,5}
			}
		},
	}
	
	local wiz_levels={
		{
			--21
			mus=14,
			tp="level",
			rm={3,16,8,8,14,9},
			goal={31,12,14,15},
			intro="my homuncu-son, you're home!",
			win="oh, my heart is full!",
			banter={
			"i'm so glad you're safe.",
			"and you're full of glee.",
			"yes, i was sad but now!",
			},
		},
	}
	
	-- Compile all levels into single sequence
	local all_levels = {}
	local idx = 1
	
	-- Add story at the beginning
	all_levels[idx] = story_item
	idx += 1
	
	-- Add all character levels
	for _, char_levels in ipairs({witch_levels, moss_levels, skeleton_levels, ghost_levels, wiz_levels}) do
		for _, level in ipairs(char_levels) do
			all_levels[idx] = level
			idx += 1
		end
	end
	
	-- add end at the end
	all_levels[idx] = end_item
	
	-- apply defaults to any missing keys
	for _, level in ipairs(all_levels) do
		for key, default_value in pairs(defaults) do
			if level[key] == nil then
				if type(default_value) == "table" then
					level[key] = {}
				else
					level[key] = default_value
				end
			end
		end
	end
	
	return all_levels
end
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
	if chk_ft(f,{"obs","atp","dor"}) then
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
				l.stl[k]=nil
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
	
	if crds_match(nc,p) then
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

function is_trp_dwn(c)
	local mtile=mtile_from_px(c)
	return mtile.ms==56
end

__gfx__
0000000000666000000dd0000776770000bbbb000077770007777700ddd00dd000cc00000000000006666000000000000aaaaa00088888000ccccc0009999900
000000000666660000dddd00766666700bbbbbb007777770777777700ddddd000cccc000aaa000006666660006660000a1aaa1a011181110c1ccc1c091191190
0070070066161660ddddddd0658585604b9b9b3007c7c77078778770d8dd8dd0cccccc00a0aaaaa066606600666660009aaaaa9081888180c7ccc7c0ff999ff0
0007700066616660051b15b0766666700b3b3bb00767677077777700ddddddd06585f600a0a009006600000066066000a1aaa1a088818880c71117c0f19991f0
000770006666666005bbb550077676000bb3bb40077c777067676000d72272d06f8f6c00aaa0a0a06606600066d66000aa111aa088181880c1ccc1c099111990
007007006066606000ddddd076667760bbb3bbb0777c77700655567007dd7d00c666ccc00000000066666000666600009aaaaa90288888202ccccc2049999940
00000000006060000bdddbd0677767703bbbb3b07777777067666760ddddddd0fc6cfcc000000000066600000660000009999900022222000222220004444400
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000001111111011ccc1101111111011111110044444000000000000000000022222000bbbbb000666660007777700
0000000000000000006666000000000000000000111111101c111c10111111101111111044444440000000000000000022222220bb1bb1b06566656077777770
000006666660000066666666666006666666666611111110c1c7c1c0111111101111111055555550066000000000000011121110bbbbbbb06666666076777670
0000666666660000666666666666666666666666ccccccccc17771c0111ccccccccc111044444a40666066000066600021222120b11111b06666666077777770
000666666666600066666666666666666666666611111110c1c7c1c0111c1110111c11104444a4a0660066600666660022111220bbbbbbb06665666077666770
0066666666666600666006666666666666666666111111101c111c10111c1110111c111055555a50666006600660d660522222503bbbbb302666662027777720
00666660066666000000000000666600000000001111111011ccc110111c1110111c111044444440666666600666666005555500033333000222220002222200
00666600006666000000000000000000000000000000000000000000000c0000000c000000000000066666000066660000000000000000000000000000000000
00666600006666000066660000666600006666001111111011111110111c1110111c1110dddddddddddddddd0000000011111110111111100ddddd000aaaaa00
00666660066666000066660000666600006666001111111011111110111c1110111c1110dddddddddddddddd002220001111111011111110ddddddd0aaaaaaa0
006666666666660000666660066666000066660011c7c11011c7c110111c1110111c1110dddddddddddddddd055555001111111011111110dd1d1dd0aaaaaaa0
000666666666600000066660066660000066660011777110cc777110111ccccccccc1110dddddddddddddddd042424001155511011555110ddddddd0aaaaaaa0
000066666666000000066660066660000066660011c7c11011c7c1101111111011111110dddddddddddddddd042424001555551015555510dd111dd0aaaaaaa0
000006666660000000666660066666000066660011111110111111101111111011111110dddddd111111111100555000b22222b0822222802ddddd209aaaaa90
000000000000000000666600006666000066660011111110111111101111111011111110dddddd1111111111000000001bbbbb10188888100222220009999900
000000000000000000666600006666000066660000000000000000000000000000000000dddddd10000000000000000000000000000000000000000000000000
11111110111111001111111011111110111c1110111c1110111111101711171011111110dddddd10dddddddddddddd1007777700088888000ccccc0009999900
11111110111111101111111001111110111c1110111c1110111111106561656011111110dddddd10dddddddddddddd107000007088888880ccccccc099999990
11111110111111101111110011111110111c111011c7c11011c7c110ddd1ddd0ddd1ddd0dddddd10dddddddddddddd107070707088888880ccccccc099999990
11111110111111101111111011111110111c111011777110117771101111111011111110dddddd10dddddddddddddd107000007088888880ccccccc099999990
11111110111111101111111011111110111c111011c7c11011c7c1101711171011111110dddddd10dddddddddddddd107077707088888880ccccccc099999990
11111110111111101111111011111110111c111011111110111c11106561656011111110dddddd10111111111111111070000070288888202ccccc2049999940
11111110011111101111111011111110111c111011111110111c1110ddd1ddd0ddd1ddd0dddddd10111111111111111007777700022222000222220004444400
00000000000000000000000000000000000c000000000000000c00000000000000000000dddddd10000000000000000000000000000000000000000000000000
00000000111114101111111011aaa1100000c0000000000cc00000000000c000000000dddd0000000000777777760000000000cccc00000000000bbbbba00000
0111111011114110155555101a999a1000000000000000cc7c00000000c0000000000ddddd00000000077776666770000000cccccccc00000000bbb4ba9a0000
5b3b33b5111411105b3b33501a9a9a1000c00c00000000cccc00000000cc00000000ddd2ddd000000077766777777700000cccccccccc000000bbbbbbbabb000
555515551a211110555555501a999a100ccc0cc0000000cccc00000000cccc00000ddddddddd00000776666666667770000cceecceecc000004bbbbbbbbbbb00
55555155aa91111055155550199999100ccc0cc000000c7cccc00000000ccc000ddd2ddd2dd2ddd00765885558856770000ceeeeceeec00004bba9bbba9b4b00
55155555a9111110155555101aa9aa100ccc00c000000ccc7cc00000000ccc0000dddddddddddd00066588555885677000cceeeeeeeecc0000baa9bbba9ab440
0555555011111110151115101222221000c0000000000ccccccc00000000c00000b571337155b00007766666666677700cccceeeeeecccc000b333bbb333bb00
05010050000000000000000000000000000000000000cc7ccc7c00000000000000b5bb33bb5bb00007777766777777700cccceeeeeecccc00bbbbb111bbbbbb0
007777001111111000000066600000001111111000007c7cc7c7c000111111100000bb111bb250000077777766777700cccccceeeecccccc0bb4b13331bbbab0
00077000111c111000000666660000001dbbbb1000007c7cc7c7c0001daaaa1000052bbbbb2b50000007777777676600ccc0ccceeccc0ccc0bbb1333331ba9a0
007bb70011ccc11000006616166000001d5bbb10000cc7c7c7cc70061d5aaa10000bd22222dbb0000076666666666770cc00cccccccc00cc0bbb33bbb33bbab0
073bbb701c1c1c1000006661666000001d5dbb10606cc7cc7cccc6661d5daa1000bbdddddbbbb0000777767777777760cc0cccccccccc0cc00ab3bbbbb3b4bb0
73b3b337111c111000006666666000001d5d5b106666cccccccc66601d5d5a1000bbbdddbbbb2d000677776677777670000cccc00cccc0000a9abbbbbbbb4bb0
73333317111c111000006066606000001d5d5d10066666cfc66666601d5d5d1000bbbb2dbbbb2d000766777767666770000ccc0000ccc0000ba4bbb3bbbbbbb0
71313117111111100000006060000000111111100006666866666000111111100d2bbbdd2bb2ddd007776667667777700cccc000000cccc0bb4bbbbbbbb3bbbb
077777700000000000000000000000000000000000671188f1176666000000000ddbbdddddddddd007777776677777700cccc000000cccc0bbb3bbbbbb4bbbbb
0000000000000000022222000bbbbb0000000000666f1188f11f66660000000000000000000c00000000000000ffff0000000066660000000cc7666666666666
000001111110000022222220bbbbbbb000000006666fe888feef666660000000000000c000000c00000000000ffffff00000666666660000cccc666666666666
00111b3333b1110022222220bbbbbbb0000000666666f8888ff6666666000000000cc0000000cc000000000ff99fffff0006111661116000c7ccc66666666666
055b33bbbb33b55022222220bbbbbbb00000006666666688666666666600000000ccc00000cccc000000fffffff90fff0006616166166000ccccffff66666666
05555b3333b5555022222220bbbbbbb000000066666665555666666666cc000000ccc00000ccc0000000ffffffff00ff0006616166166000cccffffff6666666
0555555515555550422222403bbbbb300000cc6666665eeee556666666ccc00000cc000000ccc00000ffffff9ffff0000066666166666600ccfffff99ff66666
00555555515555000444440003333300000cc6666666666666666666666cc0000c000000000c00000fff9ffff9fff0000666666116666660ccfff09fffffff66
0015551555555100000000000000000000ccc6666666666666666666666cccc000000000000000000ffff9fff90f00ff066666666666666000ff00ffffffff66
05510555555015501111111011111110cccc66666666666666666666666ccccc000000ccc000000009fff9fff9000fff666666111166666600000ffff9ffffff
05500011110005501111111011111110cccc66666666666666666666c66ccccc00000cecec00000009fff99f9fffffff666066611666066600000fff9ffff9ff
5550000110000555111c111011ccc110c7ccc666666666666666666ccccccccc0000ceeeeec00000099f9999fffffff0660066666666006600ff00f09fff9fff
550000011000005511ccc11011111110ccccccc66666666666666666cccc7ccc0000cceeecc000000099999fffffff00660666666666606600fff0009fff9fff
5500000110000055111c111011ccc110ccccccc666c6666666666666cccccccc0000ccceccc0000000099999ffff0000000666600666600000fffffff9f99fff
55500001100005551111111011111110ccc7ccc66ccc6666666cc666cccccccc0000c0ccc0c0000000000000000000000006660000666000000fffffff9999f9
05550001100055501111111011111110cccccccccccccc666cccccccc7cccccc000000c0c0000000000000000000000006666000000666600000fffffff99999
55550000000055550000000000000000cccccccccccccc666ccccccccccccccc000000000000000000000000000000000666600000066660000000ffff999900
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccccccccccc0000077777700000
080080008080008008000800800800080008080008880008080008000008080008880000ee00e0000000077777700000cccccccccccccccc0000777777770000
88008808808808880880880880888088808808808888808808808800008808808888800eee0eee000000777777770000cccccccccccccccc0007777777777000
88888808808808808880888800888888808808808800008808808800008808808880000eeeeeee000007717771777000cccccccccccccccc0077777777777700
888888088088088088808888808808088088088088800088088088800088088000880000eeeee00000771c777c177000cccccccccccccccc0077857758777700
8800880888880880888088088088000880888880888880888880888880888880888880000eee00000071cc777cc17700cccccc11111111110075857758577700
08008000888000800800080080080008000888000888000888000888000888000888000000e00000007ccc777ccc7700cccccc11111111110075565565577700
00000000000000000000000000000000000000000000000000000000000000000000000000000000077cc67776cc7700cccccc10000000000076677576677000
00000000666f1188f11f6666000000004404444044444440444444401111111066666666666666660776677777667770cccccc10cccccc100007777777770000
00000006666fe888feef66666000000044444b4044444a404d8888401dcccc1066666666666666660777771177777770cccccc10cccccc100707575757707700
000000666666f8888ff6666666000000445444404444a9a04d5888401d5ccc106666666666666666077777cc17777770cccccc10cccccc107770757575077770
000000666666668866666666660000004b4444404444ba404d5d88401d5dcc106666666666666666007777ccc7777770cccccc10cccccc107777706660777777
0000066666666eeee666666666cc000044b44440444444404d5d58401d5d5c1066666666666666660077777c77777770cccccc10cccccc107776677777766777
000ff6ff6ff666666ee66ff6ffcff000444445404b4444404d5d5d401d5d5d1066666655555555550077777c77777770cccccc10111111107707666666667077
0cffffffffff9f6666f9ffffffffff004444444044444440444444401111111066666655555555550777777777777700cccccc10111111107006777677776007
ccfffffffffff9f66f9fffffffffffc00000000000000000000000000000000066666650000000000777777777777700cccccc10000000007007660006667007
ddfffffffffffddddddfffffffffffdd4444444004444440bbbbbbbbbbbbbbbb66666650666666500dd0000000000dd00000ccccccc000000000ccccccc00000
ddfffdfffdfffddddddfffdfffdfffdd44444b4044544440bbbbbbbbbbbbbbbb666666506666665000dd00000000dd000007ccc7ccc700000007ccc7ccc70000
ddfffdfffdfffddddddfffdfffdfffdd4444444044444440bbbbbbbbbbbbbbbb6666665066666650002dd000000dd200000c7c7c7c7c0000000c7c7c7c7c0000
dddffddffddffddddddffddffddffddd4444444044444440bbbbbbbbbbbbbbbb666666506666665000d2dd0000dd2d00000cc7ccc7cc0000066667ccc7c66660
dddddddddddddddddddddddddddddddd4444444048444440bbbbbbbbbbbbbbbb666666506666665000dd2dddddd2dd0000ccccccccccc0000066666cc6666600
111111111111111111111111111111114b44444089844440bbbbbb333333333366666650555555500d22dddddddd22d000c6666cc666c0000006666cc6666000
111111111111111111111111111111114444404048b44400bbbbbb33333333336666665055555550dddddddddddddddd0666661881666660006f71188117f600
000000000000000000000000000000000000000000000000bbbbbb30000000006666665000000000ddd87deeddd87ddd006671188117660006ffeee88eeeff60
111011101111111055555550011111104444440044444440bbbbbb30bbbbbb301111111000000000ddd88eeeedd88ddd065feee88eecf5606664ff8888ff4666
111111101111111055555550111b11104c44444044444440bbbbbb30bbbbbb301d88881000000000ddd22eeeedd22ddd666fff8888fcf666665eee8888eee566
11111110171111005555555011111110c7c4444044444440bbbbbb30bbbbbb301d58881000000000dddddeeeeddddddd6666ff8888ff666665e6777887776e56
111111101111111055555550111111104cb4444044444440bbbbbb30bbbbbb301d5d8810000000000dd222ee2222ddd06666666886666666666e57757775e666
11711110111171105555555011111b104444444044444440bbbbbb30bbbbbb301d5d5810000000000d2677ddd7762dd06666665ee56666666666e555555e6666
1111111011111710555555501b1111100444454044444440bbbbbb30333333301d5d5d10000000000ddd7ddddd7dddd0666665666656666666666eeeeee66666
111011101111111055555550111111104444444044444440bbbbbb30333333301111111000000000dddddddddddddddd66666666666666666666666666666666
000000000000000000000000000000000000000000000000bbbbbb30000000000000000000000000dddddddddddddddd66666666666666666666666666666666
000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000ccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000ccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000ccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000ccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000ccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000007ccc7ccc7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000c7c7c7c7c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000066667ccc7c6666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000066666cc666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000006666cc666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006f71188117f60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000006ffeee88eeeff6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000066664ff8888ff466600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000066665eee8888eee56660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0006666665e6777887776e5666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006666666e57757775e66666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000cc66666e555555e66666ccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ccc6666666eeeeee6666666cccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ccc6666666666666666666666cccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccc66666666666666666666666cccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccc6666666666666666666666666ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc66666666666666666666ccc666ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccc66cc6666666666666ccccccc7cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccc66666666666ccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc7cccccccc666666666ccc7cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccc6666666ccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccc7cccccccccc66cccccccccc7cccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
700000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000c000000000000000cc7c00000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000cc00000000000000000cccc00000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000ccc00000000000000000cccc00000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000ccc0000000000000000c7cccc0000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000cc00000000000000000ccc7cc0000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000c0000000000000000000ccccccc000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc7ccc7c000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000c000000000000000c00000007c7cc7c7c00000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000c00000000000000000000000007c7cc7c7c000000000c0000000000000000000000000
0000000000000000000000000000000000000000000000000000000000cc00000000000000c00c00000cc7c7c7cc7006000cc000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000cccc00000000000ccc0cc0606cc7cc7cccc66600ccc000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000ccc00000000000ccc0cc06666cccccccc666000ccc000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000ccc00000000000ccc00c0066666cfc666666000cc0000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000c0000000000000c0000000066668666660000c000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000671188f117666600000000000000000000000000000000
000000000000000000000000000000000000c0000000000000ffff00000000000000c00000000000666f1188f11f666600000000000000000000000000000000
0000000000000000000000000000000000000000000000000ffffff0000000000000000000000006666fe888feef666660000000000000000000000000000000
0000000000000000000000000000000000c00c000000000ff99fffff0000000000c00c00000000666666f8888ff6666666000000000000000000000000000000
000000000000000000000000000000000ccc0cc00000fffffff90fff000000000ccc0cc000000066666666886666666666000000000000000000000000000000
000000000000000000000000000000000ccc0cc00000ffffffff00ff000000000ccc0cc000000066666665555666666666cc0000000000000000000000000000
000000000000000000000000000000000ccc00c000ffffff9ffff000000000000ccc00c00000cc6666665eeee556666666ccc000000000000000000000000000
0000000000000000000000000000000000c000000fff9ffff9fff0000000000000c00000000cc6666666666666666666666cc000000000000000000000000000
00000000000000000000000000000000000000000ffff9fff90f00ff000000000000000000ccc6666666666666666666666cccc0000000000000000000000000
000000000000000000000000000000000000000009fff9fff9000fff00000000000000000cc766666666666666666666666ccccc000000000000000000000000
000000000000000000000000000000000000000009fff99f9fffffff0000000000000000cccc66666666666666666666c66ccccc000000000000000000000000
0000000000000000000000000000000000000000099f9999fffffff00000000000000000c7ccc666666666666666666ccccccccc000000000000000000000000
00000000000000000000000000000000000000000099999fffffff000000000000000000ccccffff6666666666666666cccc7ccc000000000000000000000000
000000000000000000000000000000000000000000099999ffff00000000000000000000cccffffff666666666666666cccccccc000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000ccfffff99ff66666666cc666cccccccc000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000ccfff09fffffff666cccccccc7cccccc000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000ff00ffffffff666ccccccccccccccc000000000000000000000000
0000000000000000000000001111111000000000000000000000c000000000666000000000000ffff9ffffff0000000000000000000000000000000000000000
00000000000000000000000001111110000000000000000000c00000000006666600000000000fff9ffff9ff0000000000000000000000000000000000000000
00000000000000000000000011111110000000000000000000cc0000000066161660000000ff00f09fff9fff0000000000000000000000000000000000000000
00000000000000000000000011111110000000000000000000cccc00000066616660000000fff0009fff9fff0000000000000000000000000000000000000000
000000000000000000000000111111100000000000000000000ccc00000066666660000000fffffff9f99fff0000000000000000000000000000000000000000
000000000000000000000000111111100000000000000000000ccc000000606660600000000fffffff9999f90000000000000000000000000000000000000000
0000000000000000000000001111111000000000000000000000c00000000060600000000000fffffff999990000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000ffff9999000000000000000000000000000000000000000000
0000000000000000000000000000000000000000111111101111111000000000000000000000000000000000000c000011111100000000000000000000000000
000000000000000000000000000000000000000001111110011111100000011111100000000000000000000000000c0011111110000000000000000000000000
0000000000000000000000000000000000000000111111101111111000111b3333b1110000000000000000000000cc0011111110000000000000000000000000
00000000000000000000000000000000000000001111111011111110055b33bbbb33b550000000000000000000cccc0011111110000000000000000000000000
0000000000000000000000000000000000000000111111101111111005555b3333b55550000000000000000000ccc00011111110000000000000000000000000
000000000000000000000000000000000000000011111110111111100555555515555550000000000000000000ccc00011111110000000000000000000000000
0000000000000000000000000000000000000000111111101111111000555555515555000000000000000000000c000001111110000000000000000000000000
00000000000000000000000000000000000000000000000000000000001555155555510000000000000000000000000000000000000000000000000000000000
000000000000000000000000dddddd100000000011111110111111100551055555501550111111101111111000000000dddddd10000000000000000000000000
000000000000000000000000dddddd10000000c011111110111111100550001111000550111111101111111000000000dddddd10000000000000000000000000
000000000000000000000000dddddd10000cc0001111111011c7c110555000011000055511c7c1101111111000000000dddddd10000000000000000000000000
000000000000000000000000dddddd1000ccc000111ccccccc777110550000011000005511777110cccc111000000000dddddd10000000000000000000000000
000000000000000000000000dddddd1000ccc000111c111011c7c110550000011000005511c7c110111c111000000000dddddd10000000000000000000000000
000000000000000000000000dddddd1000cc0000111c111011111110555000011000055511111110111c111000000000dddddd10000000000000000000000000
000000000000000000000000dddddd100c000000111c111011111110055500011000555011111110111c111000000000dddddd10000000000000000000000000
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
0000000000000000dddddddddddddd10111c111011c7c110d8dd8dd011111100111111107877877011c7c110111c1110dddddddddddddd100000000000000000
0000000000000000dddddddddddddd10111ccccccc777110ddddddd011111110111111107777770011777110cccc1110dddddddddddddd100000000000000000
0000000000000000dddddddddddddd101111111011c7c110d72272d011111110111111106767600011c7c11011111110dddddddddddddd100000000000000000
000000000000000011111111dddddd10111111101111111007dd7d001111111011111110065556701111111011111110dddddd11111111100000000000000000
000000000000000011111111dddddd101111111011111110ddddddd01111111011111110676667601111111011111110dddddd11111111100000000000000000
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
0000000000000000000000000505000000000000000000000505000005050000010101010000050505050000000000000000000000000505000500000000000000000000000000000505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
292a2a2a3a2a390000292a2a2a39000000292a292a2a2a2a3900292a2a2a3900292a2a2a2a2a3900292a2a2a2a2a2a3900008c8d8d8d8d8d8d8d9c0000000000292a3900292a292aa7a7b6a6a7a7a7a7a7b6000000000000000030000000003200001e00000000000d1800000000300000000032000000000000680045460000
39573030303039292a3b302e302a2a3900393d392b30303039293b2516252a39392b3e3d25543900393025722573162a39009c012530383333339c292a2a292a3b1f2a393901b6b404a5b6b601302b3d2bb6000000000030473130440000161f3030442e000000444c4d47000000003132300000000000000047004455566800
3901301f300239390132303b30300239292a293b301e3002393901513b5102393901303b160239003930513051303030a7399c25322b9c1e1f8c9d395430393030b504393930b695b5a4b6b63030303e3da7a7a7b60030372e8a8b69002f30013048494200000c155c5d152e00003330013130000000446a6b00446465666700
393030303030392a2a39311e30292a3b392f3901301f3030392a392f722f293b392b3e3d252b39293b303d722f3030b4a4b69c2d302d8c8d8d9c003901303930b5a5293b3930a7b6a51eb6b62f30323030306325b6000032019a9b31300047303058593d000000681728690030000031423000310000007a7b00006e6f767700
2a2a2a2a2a2a3b00002a2a2a2a3b00002a292a39302e304239002a2a2a2a3b002a2a2a2a2a2a3b3901303e723d30a5b5a4b69c2b30309d3e3e8d9c3930303b3030293b00393032b7302e39b62b2f303030336216b600000068303830000025303e30250000000000270e00000000300033000000003300004752537e7f000000
009899999998a80000989999999899a800393e393030303039009899999999a8000000000000002a2a392f723e30309504b69c163230373030059c2a39302b30303900002a392b2b3030b6a7a7b62b3e30303f25b600330000300000000000000000000000003333000000000000000000000000000000333360610000693100
00a8303032a899a800a8013062a9b1a8002a2a2a2a2a2a2a3b98a916303d319999a8000000000000002a2a2a2aa72aa7a7b78d8d8d8d8d8d8d8d9d003930393030390000003930303031390000a7a6b7b5a7a6a7b700000c30303000000000320000000000306c6d300000000000004546000000003968172670712518003900
98a9300930a91f99a8a83030301930a89899999999999999a8a80130b1303130b0a8989999999999989999a8008c8d9c0000000000000000000000002a2a2a2a2a3b0000002a2a3a3a3a3b000000b6b4a495b6000033300130053000003330303000000031307c7d313100000000445556680000293b17280230300427182a39
a854013030193206a8a8253016a825a8a8013030302b3030a89899a93032a80930a8a801302f3030a99725a88c9db88c8d8d8c8d9c008c8d8d8d8d8d8d8c8d8d8d8d9c0000000000000000000000b6a50496b6000000303030300033323001025431000000303131300000000047909192936900393034033130313005343039
99a8302b30a82b98a9a8300930a83ea8a830a930b02b3030a8a806192b30a93030a8a83009303009193030a89c01309d1f309c3e9c009c3e2b332b2b2b9c1f2516259c0000000000000000000000a7a7a7a7b700000000000031000000303030310000000000333300000000292aa0a1a2a32a392a392726073233062528293b
0099a82b2ba898a900a81eb03da806a8a863303030a90930a89999a8303d25b125a8a8303098a919a83030a89c30091930309d308d9c9c333333332b2b9d373737379c00000000000000000000000000000000000000000000000000000030000000808182838485868788893930013132303339002a2a2a2a2a2a2a2a2a3b00
000099999999a90000999999999999a99899a830302b3030a80000999999999999a9a82b30a9303099a83fa88c8d8d9d2b303730059c9c2b0130303030383232322d9c000000000000000000000000000000000000454600000000000001113c040062b5b5950000000000002a2a2a2a2a2a2a3b008081828384858687888900
00000000000000000000000000000000a825a930b1999999a8000000000000000000a8302b19300930a830a88d9c2d3030309c308c9d9c30303233302b9c323232309c00000000000000000000000000000000000055560000000000101321100a00940fb52b4700000000320000000047004849004a4b00683c001f0d0e0f00
00000000000000000000000000000000a816253030196306a8000000000000000000a82530a8303030a806a8008d9c2516259c3e9c009c3e30332b30309c573232059c0000000000000000000000000000000030646566673000000020141221001db5b54e4fb5000032333332000000000f5859695a5b0d0001000c52532e00
000000000000000000000000000000009999999999999999a9000000000000000000999999a816303d9899a900008d8d8d8d8d8d9d008d8d8d8d8d8d8d8d8d8d8d8d9d000000000000000000000000000000308c8d8d8d8d9c3000000030300000b501955e5fa400304406076830000005292a2a2a2a2a390440001d1c1e1f00
0000000000000000000000000000000000000000000000000000000000000000000000000099999999a900000000000000000000000000000000000000000000000000000000000000000000000000000000329c013119089c320030478e8f0e0044b4b5b5b5b5303303525302330044293b25151615262a3900003360613300
000000292a2a2a292a2a2a2a2a2a2a39000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000308d8d8d8d8d9d302e01309e9f303000b51c00630032324704056932320039023230013232033900323070713031
00000039570130392b2b082b2b373e2a3900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000031303230323000003031300969000000b5b500000030303333323200002a390732313106293b00003130323000
000000393031303b2b3030303037303e3900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001f00000000000000001d301931000000b5a4a5b500000000003032000000002a2a2a2a2a2a3b0000001012141311
00000039303030193030301f303737373900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044000900690e0000000033330000b5950104b59400000000320000000069004745460000000000002410121123
000000392b2b2b39302b303033302d303900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c011214130a0800000030300c300000b5b4a4b5000000323333320000476a6b6855560000000000002224012122
0000003932303039303130303030302f390000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000471e00000000303101063030000000b500000030440f1c683000007a7b6465929344003b30002320131421
00000039300930393d293b372a39302f3900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002e000000303033300031000032000030330d78790c33000000292a2aa2a3293b380000201314120a
00000039303032392f39251625393f423900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000303000000030303032003232471d0e69323200293b303330313b37002600001f303016
0000002a2a2a2a2a2a2a2a2a2a2a2a2a3b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000440cc1c20f8e8f0000003100000000011932063231003030333332320000395401323009193231023b300130052d
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaab47d1d2689e9f0000321e33292a390031303232090000000030320000002a393230303039320033003725302b38
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000babbe0e1e2e34e4f00323001303908390000302b0031000000000000000000002a2a2a2a2a2a3b332b360000330000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0f1f2f35e5f00003030312a2a3b00000000000000000000000000000000000000000000002d3b000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008a8b6c6d484900000000003100000000000000000000000000000000000000000000000000000031000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009a9b7c7d585900000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005253000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
__sfx__
991e00000e535000000000000000095350000000000000000e535000000000000000095350000000000000000e5350953500000085050e5350953500000005051853500000155350000011535000000e53500505
010300000e51013510135000050002500215002350000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00030000125201651011500025001f5001c5001a50000503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503
00030000165101d510025000050016500185001a50000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00030000175101a51000500145000d500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00050000110300a020005000000008500165000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500000e0300602000000170000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102000016735187351b7351f73524735277352973500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705
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
010500000211004120051100010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
0110000018722000000070000000000000000000000000001c7221f7221f722000000000000000000000000022720217200070000000000000000000000000001f7201c7221c7221a720000001f7200000000000
191000000053000000000000050000000000000000000000095300000000000005000000000000000000000002530000000000000500000000000000000000000753000500005000050000500005000050000500
570800001e6251c6250e6250c62500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605
9f030000217251c725187250070500705307050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705
bf050000216231d623186250060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603
691000000c522005020e52100502105220050213522005020c522005000e521005000e5220000000000000000e5220c52100502005020c522000000e52110522115210000013522000000c522000000000000000
011000000c522000000000000000000000000000000000000e5220000000000000000000000000000000000011522000000000000000000000000000000000001052200000000000000000000000000000000000
551000000c0110000000001180011c012000001301200000210100000013010000001c0100000000001000010c021100210e02100001000010000100001000010000113020000001102010021000001802100000
491000000c7230000000000007030c724000000000000703137230000000000007031372400000000000070315723000000000000703157240000000000007031372300703000000000010021007030070300703
911000001871018711187111871118711187111871118710187051870018700187001870018700187001870013710137111371113711137111371113711137101370013700137001370013700137001370013700
b31000000c5120c5120c5120c5120e5120e5120e5120e512135121351213512135120e5120e5120e5120e51215512155121551215512135121351213512135120e5120e5120e5120e5120e5120c5020c5020c000
c1180000247142471124712247122471124715000000000020714207112071220712207112071500000000001f7141f7111f7121f7121f7111f71500000000002071420711207122071220711207150000000000
c518000000704007040070400704277142771227712277152b7142b7122b7122b715007040070400704007042c7142c7122c7122c7152b7142b7122b7122b7152771427712277122771500704007040070400704
ad1800002b7142b7122b7122b7152c7142c7122c7122c7152b7142b7122b7122b7152771427712277122771524000240002400024000267142671226712267152771427712277122771524714247122471224715
__music__
01 000e4344
06 0f104344
01 54154344
00 54154344
02 14154344
01 591a4344
00 411a4344
02 195a4344
01 1c424344
00 1c424344
02 1b424344
01 1d424344
00 1d424344
02 1d1e4344
01 1f424344
00 1f424344
00 1f204344
00 1f424344
02 1f214344


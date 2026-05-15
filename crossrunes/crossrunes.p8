pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--crossrunes
--by shinbone★

function _init()
	why=""
	version=1
	cartdata("shinbone_crossrune_"..version)
	--particle effects
	effects={}
	
	--game definition
	g={
		scene=1,
		draw=draw_menu,
		update=update_menu,
		timing=0,
		tlimit=120,
		second_tick=30,
		talk_timer=0,
		level_ended=false,
		item=1,
		sol_max=8,
		gradesp=230,
		passed=false
	}
	--level data
	l={
		char=char.mage,
		score={cap=99,t=24,v=24,dv=0},
		size=8,
		runes={},
		solution={},
		picker={x=9,y=9},
		saved_rune_loc={},
		selected={},
		orbs={
			{cap=90,v=90,dv=90,l=7,c=12},
			{cap=60,v=60,dv=60,l=10,c=9},
			{cap=30,v=30,dv=30,l=2,c=8},
		},
	}
	--menu options
	m={
		opt={
		 {t="new game",f=new_game,a=true},
			{t="load game",f=load_game,a=false},	
			--{t="options",f=options,a=false}
		},
		selection=1
	}
	
	--in game menu options
	igm={
		opt={
		 {t="retry level",f=reset_level,a=true,e=true},
		 {t="next level", f=next_level,a=false,e=false}
		},
		selection=1
	}
	handle_menu_options()
end

function _update()
	g.timing+=0.1
	if g.timing>10.5 then
		g.timing=rnd({1,2,3,4,5,6})
	end
	g.update()
	update_fx()
end

function _draw()
	cls()
	g.draw()
	--debug printing
	print(why,0,0,7)
end

-->8
--lookups

--[[
	number sprites for the games
	big timer display
]]
num_sp={
	[1]=192,[2]=193,[3]=194,
	[4]=195,[5]=208,[6]=209,
	[7]=210,[8]=211,[9]=224,
	[0]=225
}

function get_numsp(key)
	return num_sp[key]
end

--[[
	character sprite reference
	by character names
]]
char={
	mage={
		nlvl="baldy",
		rune_c={12,9,8},
		score={cap=99,t=24,v=0,dv=0},
		size=8,
		tlimit=120,
		orbs={
			{cap=90,v=90,dv=90,l=7,c=12},
			{cap=60,v=60,dv=60,l=10,c=9},
			{cap=30,v=30,dv=30,l=2,c=8},
		},
		sol_leng=3,
		min_sol_leng=3,
		mien="intro",
		talksounds={10,11},
		port=9,
		talk=61,
		blink=13,
		emote={
			intro={m=nil,e=nil},
			passed={m=64,e=nil},
			failed={m=62,e=29},
			angry={m=62,e=29},
			ignore={m=nil,e=45},
			happy={m=63,e=nil}
		},
		a_dialog="",
		dialog={
			intro={"ready for your enchantment lesson today?"},
			passed={"fantastic training, i'm impressed you managed to get this far."},
			failed={"class is over for today, put down your quill."},
			angry={
				"that's not right.",
				"what are you doing?",
				"go back to the basics..."
			},
			ignore={
				"ugh...",
				"oh, come on now.",
				"sloppy tracing..."
			},
			happy={
				"that's great, good work.",
				"excellent literacy.",
				"keep up the momentum."
			}
		}
	},
	baldy={
		nlvl="gob",
		rune_c={12,12,9,9,8},
		score={cap=99,t=36,v=0,dv=0},
		size=8,
		tlimit=110,
		orbs={
			{cap=80,v=80,dv=70,l=7,c=12},
			{cap=60,v=40,dv=40,l=10,c=9},
			{cap=30,v=15,dv=15,l=2,c=8},
		},
		sol_leng=4,
		min_sol_leng=4,
		mien="intro",
		talksounds={10,11},
		port=73,
		talk=125,
		blink=77,
		emote={
			intro={m=nil,e=nil},
			passed={m=127,e=nil},
			failed={m=126,e=93},
			angry={m=126,e=93},
			ignore={m=nil,e=109},
			happy={m=127,e=nil}
		},
		a_dialog="",
		dialog={
			intro={"i hope you've been studying."},
			passed={"good enough."},
			failed={"you're not ready for this..."},
			angry={
				"are you trying to blow us up?",
				"are you picking at random?",
				"why are you even bothering at this?"
			},
			ignore={
				"i don't tolerate mistakes.",
				"try a little harder, won't you?",
				"are you trying to flunk?"
			},
			happy={
				"i'll accept that one.",
				"you're not completely off the mark.",
				"acceptable, i suppose."
			}
		}
	},
	gob={
		nlvl="seer",
		rune_c={12,12,12,9,9,9,8},
		score={cap=99,t=56,v=0,dv=0},
		size=8,
		tlimit=90,
		orbs={
			{cap=70,v=70,dv=50,l=7,c=12},
			{cap=40,v=30,dv=30,l=10,c=9},
			{cap=30,v=10,dv=10,l=2,c=8},
		},
		sol_leng=5,
		min_sol_leng=5,
		mien="intro",
		talksounds={10,11},
		port=137,
		talk=189,
		blink=141,
		emote={
			intro={m=nil,e=nil},
			passed={m=191,e=nil},
			failed={m=190,e=157},
			angry={m=190,e=157},
			ignore={m=nil,e=173},
			happy={m=191,e=nil}
		},
		a_dialog="",
		dialog={
			intro={"you here to learn goblin spells?"},
			passed={"good enough, ."},
			failed={"you're not ready for this..."},
			angry={
				"goblin spells too hard for you?",
				"even goblin baby knows this one.",
				"you make a terrible goblin wizard."
			},
			ignore={
				"yucky spelling, eww. yuck.",
				"you make me laugh, maybe cry.",
				"why are you so bad at this?"
			},
			happy={
				"good goblin magic, that is",
				"oh, that good spell for a human, i guess...",
				"not bad! good good good!"
			}
		}
	},
	seer={
		nlvl="mage",
		rune_c={12,12,12,9,8},
		score={cap=99,t=80,v=0,dv=0},
		size=8,
		tlimit=180,
		orbs={
			{cap=99,v=30,dv=30,l=7,c=12},
			{cap=40,v=20,dv=20,l=10,c=9},
			{cap=30,v=0,dv=0,l=2,c=8},
		},
		sol_leng=5,
		min_sol_leng=5,
		mien="intro",
		talksounds={10,11},
		port=201,
		talk=253,
		blink=205,
		emote={
			intro={m=nil,e=nil},
			passed={m=255,e=nil},
			failed={m=254,e=221},
			angry={m=254,e=221},
			ignore={m=nil,e=237},
			happy={m=255,e=nil}
		},
		a_dialog="",
		dialog={
			intro={"i won't make this easy for you."},
			passed={"happy to see you graduate!"},
			failed={"I'm not sure where we went wrong here..."},
			angry={
				"i expect more from a student at this level.",
				"what have the professors been teaching you?",
				"this is embarrassing for both of us."
			},
			ignore={
				"this is not acceptable.",
				"i can't give you your diploma with work like this.",
				"all that tuition and it's gone to waste, huh?"
			},
			happy={
				"you're doing great work, keep it up.",
				"proud to have student's like you here.",
				"i'm sure you'll do great things with this knowledge."
			}
		}
	}
}

function get_char(key)
	return char[key]
end

orbsp={
	128,130,132,134,
	160,162,164,166
}

runes={
	1,2,3,4,5,6,7,8,
	16,17,18,19,20,21,22,23,24,
	32,33,34,35,36,37,38,39,40,
	48,49,50,51,52,53,54,55,56
}

rune_c={15}

items={
	{
		k="hand",sp=168,
		x=90,y=73,sr=0,
		c=12,mc=1,o=1,
	},
	{
		k="swap",sp=184,
		x=102,y=73,sr=2,
		c=9,mc=20,o=2
	},
	{
		k="bomb",sp=152,
		x=115,y=73,sr=2,
		c=8,mc=30,o=3
	},
}

grades={
	230,229,228,216,
	215,214,244
}

-->8
--drawing
function draw_menu()
	local l={
		c=196,
		r=197,
		o=198,
		s=199,
		u=200,
		n=212,
		e=213,
	}
	local title={
		l.c,l.r,l.o,l.s,
		l.s,l.r,l.u,l.n,
		l.e,l.s
	}
	rectfill(0,0,127,127,13)
	fillp(▒)
	rectfill(0,0,128,60,2)
	rectfill(0,128,128,88)
	rectfill(0,0,128,20,1)
	rectfill(0,128,128,108)
	fillp()
	rectfill(16,16,116,108,1)
	map(0,0,8,12,15,13)
	local txp=19
	for v in all(title) do
		spr(v,txp,58)
		txp+=9
	end
	
	local xp=45
	local yp=72
	local col=7
	for opt in all(m.opt) do
		if opt.a==true then
			col=9
			spr(226,xp-10,yp-1)
		else	
			col=7
		end
		print(opt.t,hc_txt(opt.t),yp,col)
		yp+=10
	end
end

function draw_ui()
	rectfill(3,3,84,84,1)
	rect(3,3,84,84,6)
	spr(64,0,0)
	spr(65,80,0)
	spr(80,0,80)
	spr(81,80,80)
	rectfill(0,90,127,127,2)
	rect(0,90,127,127,6)
end

function draw_char()
	rectfill(2,92,34,125,0)
	rect(2,92,34,125,6)
	local c=l.char
	local em=c.emote
	spr(c.port,3,93,4,4)
	if l.char.mien=="angry" then
		spr(em.angry.e,11,101,3,1)
		spr(em.angry.m,19,109)
	end
	--blink timer
	if g.timing>10 then
		spr(c.blink,11,101,3,1)
	end
	--side-eye
	if (g.timing==mid(2,g.timing,5)) then
		spr(em.ignore.e,11,101,3,1)
	end
	
	if g.talk_timer>0 then
		if g.talk_timer%10<5 then
			spr(c.talk,19,109)
		end
	end
end

function draw_timer()
	spr(136,91,5)
	local num_str=tostr(g.tlimit)
	local chars=split(num_str,"")
	local cleng=#chars
	--init xpos based on cleng
	local xpos=112-((cleng*8)/2)
	for c in all(chars) do
		spr(get_numsp(c),xpos,5)
		xpos+=8
	end
end

function draw_score()
	local st=l.score.dv.."/"..l.score.t
	local cleng=#st
	local xpos=108-(cleng*4)/2
	spr(118,xpos-7,16)
	print(st,xpos+4,17,9)
end

function draw_orb()
	local sx=89
	local sy=27
	for o in all(l.orbs) do
		local ex=sx+9
		local ey=sy+9
		ovalfill(sx,sy,ex,ey,o.c)
		local perc=(o.dv/o.cap)
		local mask=9-ceil(9*perc)
		rectfill(sx,sy,ex,sy+mask,0)
		oval(sx,sy,ex,ey,o.l)
		local mana=tostr(o.dv)
		print(mana.."/"..o.cap,sx+12,sy+3,o.c)
		sy+=12
	end
end

function draw_dialog(str)
	local c=l.char
	local str=c.a_dialog
	local words=split(str, " ")
	local pointer=0
	local pstr=""
	for w in all(words) do
		if pointer+(#w+1)>20 then
			pstr=pstr.."\n"
			pointer=0
		end
		pstr=pstr.." "..w
		pointer+=#w+1
	end
	
	print(pstr,34,94,7)
end

function draw_runes()
	for r in all(l.runes) do
		rectfill(r.x,r.y,r.x+7,r.y+7, r.c)
		pal({[7]=1})
		spr(r.sp,r.x,r.y)
		pal()
	end
end

function draw_solution()
	rectfill(36,114,125,125,5)
	rect(36,114,125,125,6)
	local xpos=38
	local some_sel=#l.selected>0
	for i, r in ipairs(l.solution) do
		local in_range=#l.selected>=i
		if some_sel and in_range then
			if runes_match(r,l.selected[i]) then
				ovalfill(xpos+2,112,xpos+5,115,11)
			else
				ovalfill(xpos+2,112,xpos+5,115,8)
			end
		end
		pal({[7]=r.c})
		spr(r.sp,xpos,116)
		pal()
		xpos+=8
	end
end

function draw_cursor()
	local p=l.picker
	local t=g.second_tick
	local ccol=7
	local sizes={
		["hand"]={
			{p.x-1,p.y-1,p.x+8,p.y+8,ccol},
			{p.x-2,p.y-2,p.x+9,p.y+9,ccol}
		},
		["bomb"]={
			{p.x-1,p.y-1,p.x+26,p.y+26,ccol},
			{p.x-2,p.y-2,p.x+27,p.y+27,ccol}
		},
		["swap"]={
			{p.x-1,p.y-1,p.x+26,p.y+26,ccol},
			{p.x-2,p.y-2,p.x+27,p.y+27,ccol}
		}
	}
	local k=items[g.item].k
	local size=sizes[k]
	local dr=rect
	if k=="bomb" then
		fillp(✽)
		dr=rectfill
	elseif k=="swap" then
		fillp(░)
		dr=rectfill
	end
	if t<15 then
		dr(unpack(size[1]))
	else
		dr(unpack(size[2]))
	end
	fillp()
end

function draw_hints()
	print("rune ❎",1,84,5)
	print("swap 🅾️",93,84,6)
end

function draw_items()
	local xp=90
	local yp=74
	local ct=items[g.item]
	rect(ct.x-2,ct.y-2,ct.x+9,ct.y+9,ct.c)
	for k,t in pairs(items) do
		spr(t.sp,t.x,t.y)
		print(t.mc,t.x+2,t.y-8,t.c)
		--show x if cost is too high
		if t.mc>l.orbs[t.o].v then
			spr(117,t.x,t.y)
		end
	end
	rectfill(ct.x+5,ct.y+7,ct.x+8,ct.y+11,0)
	print("🅾️",ct.x+4,ct.y+7,ct.c)
end

function draw_path()
	local colr=7
	local s=l.selected
	for i, r in ipairs(s) do
		if i==1 then
			oval(r.x-1,r.y-1,r.x+8,r.y+8,colr)
		end
		if i>1 then
			local p=s[i-1]
			oval(r.x-1,r.y-1,r.x+8,r.y+8,colr)
		end
	end
end

function draw_grade()
	if g.level_ended then
		rectfill(4,4,84,84,1)
		
		rect(3,3,85,85,4)
		rect(4,4,84,84,2)
		spr(96,0,0)
		spr(112,0,80)
		spr(97,80,0)
		spr(113,80,80)
		
		print("◆final grade◆",13,15,7)
		spr(g.gradesp,40,25)
		local score=l.score.v.."/"..l.score.t
		print(score, hc_txt(score)-20,36,9)
	
		local xp=45
		local yp=55
		local col=7
		
		for opt in all(igm.opt) do
		 if opt.a==true then
			 col=9
			 spr(226,xp-29,yp-1)
		 else	
			 col=7
		 end
		 
		 print(opt.t,hc_txt(opt.t)-15,yp,col)
		 yp+=10
	 end
	end
end

function draw_game()
	draw_ui()
	draw_char()
	draw_timer()
	draw_orb()
	draw_dialog()
	draw_runes()
	draw_path()
	draw_solution()
	draw_fx()
	draw_cursor()
	draw_score()
	--draw_hints()
	draw_items()
	draw_grade()
end
-->8
--updating

function update_menu()
	local bs=tostr(btnp())
	local bn=btnp()
	if bn==0 then return end
	
	local btns={
		["4"]=-1,--up
		["8"]=1,--down
	}
	
	if btnp(❎) then --❎
		m.opt[m.selection].f()
	end
	
	if btns[bs] then
		sfx(0)
 	m.selection+=btns[bs]
 end
	
	if m.selection>#m.opt then
		m.selection=1
	elseif m.selection<=0 then
		m.selection=#m.opt
	end
	
	for i,v in ipairs(m.opt) do
		if i==m.selection then
			v.a=true
		else
			v.a=false
		end
	end
end

function update_igmenu()
	local bs=tostr(btnp())
	local bn=btnp()
	if bn==0 then return end
	
	local btns={
		["4"]=-1,--up
		["8"]=1,--down
	}
	
	if btnp(❎) then --❎
		igm.opt[igm.selection].f()
	end
	
	if btns[bs] then
		sfx(0)
 	igm.selection+=btns[bs]
 end
	
	if igm.selection>#igm.opt then
		igm.selection=1
	elseif igm.selection<=0 then
		igm.selection=#m.opt
	end
	
	for i,v in ipairs(igm.opt) do
		if i==igm.selection then
			v.a=true
		else
			v.a=false
		end
	end
end

function handle_game_input(bp)
	local bs=tostr(bp)
	
	if btnp(❎) then
		local k=items[g.item].k
		if k=="hand" then
			click_rune(l.picker)
		elseif k=="bomb" then
			explode_runes()
		elseif k=="swap" then
			swap_runes()
		end
	end
	
	if btnp(🅾️) then
		next_item()
		local sr=items[g.item].sr
		l.picker.x=mid(9,l.picker.x,(l.size-sr)*9)
		l.picker.y=mid(9,l.picker.y,(l.size-sr)*9)
	end
	
	local btns={
		["1"]={x=-1,y=0},--left
		["2"]={x=1,y=0},--right
		["4"]={x=0,y=-1},--up
		["8"]={x=0,y=1},--down
	}
	if btns[bs] then
		sfx(rnd({1,2,3}))
		local x=btns[bs].x
		local y=btns[bs].y
		local xdest=l.picker.x+(x*9)
		local ydest=l.picker.y+(y*9)
		local np={x=xdest,y=ydest}
		local sr=items[g.item].sr
		l.picker.x=mid(9,xdest,(l.size-sr)*9)
		l.picker.y=mid(9,ydest,(l.size-sr)*9)
 end
end

function update_game()
	tick_down()
	handle_game_input(btnp())
	update_fx()
	animate_value(l.score)
	for o in all(l.orbs) do
		animate_value(o)
	end
	if g.talk_timer>0 then
		g.talk_timer-=1
	end
end
-->8
--save & level transition
function save_game()
	dset(0,level)--level
	dset(1,game)--game
	dset(2,scene)--scene
end

function new_game()
	init_level()
	set_dialog("intro")
end

function load_game()
	--todo: handle loading data
	new_game()
end

function options()
	--todo: handle options
end

function reset_level()
	init_level()
end

function next_level()
	l.char=char[l.char.nlvl]
	init_level()
end

function handle_menu_options()
	if dget(0)==0 then
		deli(m.opt,2)
	end
end


-->8
--utilities

function hc_txt(txt)
 --gets horizontal center
 --for the provided text
 local tl=#txt
 local tw=tl*4
 return 64-tw/2
end

--tick down to track seconds
function tick_down()
	if g.tlimit==0 and not g.level_ended then
		end_level()
		set_mien("failed")
	end
	if (g.level_ended) return
	g.second_tick-=1
	if g.second_tick==0 then
		g.second_tick=30
		g.tlimit-=1
	end
end

function init_runes()
	--[[should genertate runes
	for all the spaces in the
	board. ]]
	l.runes={}
	for y=1, l.size do
		for x=1, l.size do
			add(l.runes, {
				sp=rnd(runes),
				x=x*9,
				y=y*9,
				c=rnd(l.char.rune_c)
			})
		end
	end
end

function gen_rune_solution()
	if #l.runes==0 then
		end_level()
	end
	l.solution={}
	local runes={}
	for r in all(l.runes) do
		add(runes,r)
	end
	for i=1, l.char.sol_leng do
		local t=del(runes,rnd(runes))
		add(l.solution,t)
	end
end

function remove_rune(r)
	del(l.runes,r)
end

function rune_is_selected(pos)
	local x=pos.x
	local y=pos.y
	for r in	all(l.selected) do
		local foundx=r.x==x
		local foundy=r.y==y
		if foundx and foundy then
			return true
		end
	end
	return false
end

function pos_are_adj(p1,p2)
	local xdif=abs(p1.x-p2.x)
	local ydif=abs(p1.y-p2.y)
	local dif=xdif+ydif
	if dif>=0 and dif<=9*3 then
		return true
	end
	return false
end

function click_rune(pos)
	local x=pos.x
	local y=pos.y
	for r in	all(l.runes) do
		local foundx=r.x==x
		local foundy=r.y==y
		if foundx and foundy then
			local s=l.selected
			if rune_is_selected(r) then
				sfx(5)
				return
			end
			if #s>0 then
				sfx(4)
				add(l.selected, r)
			--[[
				if no runes are selected
				can select any rune
			]]
			elseif #s==0 then
				sfx(4)
				add(l.selected, r)
			end
			check_valid_solution()
			reduce_mana(2,12)
		end
	end
end

function get_orb_sp(o)
	local division=o.cap/#orbsp
	local i=o.dv\division+1
	if (i>#orbsp) i=#orbsp	
	return orbsp[i]
end

function runes_match(r1,r2)
	local cm=r1.c==r2.c
	local sm=r1.sp==r2.sp
	return cm and sm
end

function pick_pos()
	return {
		x=l.picker.x,
		y=l.picker.y
	}
end

function check_valid_solution()
	local valid=true
	local pts=l.char.sol_leng
	local apts=ceil(pts/2)
	if #l.solution != #l.selected then
		return
	end
	for i,r in ipairs(l.selected) do
		local s=l.score
		if r.sp != l.solution[i].sp then
			valid=false
			l.score.v=max(0,s.v-1)
			reduce_mana(apts,r.c)
		else
			l.score.v+=1
			add_mana(apts,r.c)
			add_time(2)
			remove_rune(r)
		end
	end
	
	if valid==true then
		set_mien("happy")
		l.char.sol_leng=mid(1,pts+1,g.sol_max)
		if l.char.sol_leng>#l.runes then
			l.char.sol_leng=#l.runes
		end
	else
		fire()
		l.char.sol_leng=l.char.min_sol_leng
		if l.char.mien=="ignore" then
			set_mien("angry")
		else
			set_mien("ignore")
		end
	end
	l.selected={}
	gen_rune_solution()
end

function can_move_to(np)
	local ppos=pick_pos()
	local s=l.selected
	if #s>0 then
		ppos=s[#s]		
	end
	return pos_are_adj(np,ppos)	
end

function init_level()
	g.level_ended=false
	set_mien("intro")
	init_runes()
	gen_rune_solution()
	l.score=l.char.score
	l.size=l.char.size
	l.orbs=l.char.orbs
	g.tlimit=l.char.tlimit
	l.selected={}
	l.picker={x=9,y=9}
	l.saved_rune_loc={}
	g.draw=draw_game
	g.update=update_game
end

function end_level()
	g.update=update_igmenu
	local target=l.score.t
	local endscore=l.score.v+g.tlimit
	local r=endscore/target
	
	if r<0.3 then
		g.gradesp=230
	elseif r>0.4 and r<0.5 then
		g.gradesp=229
	elseif r>0.5 and r<0.6 then
		g.gradesp=228
	elseif r>0.6 and r<0.7 then
		g.gradesp=216
	elseif r>0.7 and r<0.8 then
		g.gradesp=215
	elseif r>0.8 and r<1 then
		g.gradesp=214
	elseif r>=1 then
		g.gradesp=244
	end
	
	if r>0.8 then
		g.passed=true
	else
		g.passed=false
	end
	
	g.level_ended=true
end

function get_rune_at(p)
	for r in	all(l.runes) do
		local foundx=r.x==p.x
		local foundy=r.y==p.y
		if foundx and foundy then
			return r
		end
	end
end

function orb_by_col(c)
	for o in all(l.orbs) do
		if o.c==c then
			return o
		end
	end
end

function reduce_mana(n,c)
	local orb=orb_by_col(c)
	orb.v-=n
	if orb.v<=0 then
		orb.v=0
		if orb.c==12 then
			set_mien("failed")
			end_level()
		end
	end
end

function add_mana(n,c)
	local orb=orb_by_col(c)
	orb.v+=n
	if orb.v>orb.cap then
		orb.v=orb.cap
	end
end

function add_time(n)
	g.tlimit+=n
end

function set_mien(to)
	l.char.mien=to
	set_dialog(to)
end

function animate_talk()
	g.talk_timer=40
	sfx(rnd(l.char.talksounds))
end

function set_dialog(m)
	l.char.a_dialog=rnd(l.char.dialog[m])
	animate_talk()
end

function next_item()
	sfx(rnd({1,2,3}))
	local n=g.item+1
	if #items<n then
		n=1
	end
	local nitem=items[n]
	local norb=l.orbs[n]
	if nitem!=nil and norb!=nil then
		if norb.v<nitem.mc then
			n+=1
		end
	end
	if n>#items then
		n=1
	end
	g.item=n
end

function explode_runes()
	local x=l.picker.x
	local y=l.picker.y
	for i=1,3 do
		for j=1,3 do
			local r=get_rune_at({x=x,y=y})
			del(l.runes,r)
			y+=9
		end
		x+=9
		y=l.picker.y
	end
	fire({
		w=24,
		c={7,8,9,10},
		num=3,
		x=l.picker.x+9,
		y=l.picker.y+18,
		sf=9
	})
	l.selected={}
	gen_rune_solution()
	reduce_mana(items[g.item].mc,8)
	g.item=1
end

function swap_runes()
	local x=l.picker.x
	local y=l.picker.y
	for i=1,4 do
		for j=1,4 do
			local r=get_rune_at({x=x,y=y})
			if r!=nil then
				local cswap={
					["12"]=9,
					["9"]=8,
					["8"]=12
				}
				r.c=cswap[tostr(r.c)]
			end
			y+=9
		end
		x+=9
		y=l.picker.y
	end
	fire({
		w=8*3,
		c={7,8,9,12,7},
		num=1,
		x=l.picker.x+9,
		y=l.picker.y+18,
		sf=12
	})
	l.selected={}
	reduce_mana(items[g.item].mc,9)
	g.item=1
end
-->8
--animations

function fire(opts)
	if opts==nil then
		opts={
			w=88,c={1,12,7,6},
			num=24,x=44,y=44,
			sf=9
		}
	end
 local w=opts.w
 local c=opts.c
 local num=opts.num
 local x=opts.x
 local y=opts.y
 
 sfx(opts.sf)
 
 for i=0, num do
  --settings
  add_fx(
   x+rnd(w)-w/2,  -- x
   y+rnd(w)-w/2,  -- y
   30+rnd(10),	-- die
   0,        	 -- dx
   -.5,       	-- dy
   false,     	-- gravity
   true,     		-- grow
   false,      -- shrink
   rnd({1,12}),-- radius
   c    -- color_table
 	)
 end
end

function update_fx()
 for fx in all(effects) do
	 --lifetime
	 fx.t+=1
	 if fx.t>fx.die then del(effects,fx) end
	
	 --color depends on lifetime
	 if fx.t/fx.die < 1/#fx.c_table then
	  fx.c=fx.c_table[1]
	
	 elseif fx.t/fx.die < 2/#fx.c_table then
	  fx.c=fx.c_table[2]
	
	 elseif fx.t/fx.die < 3/#fx.c_table then
	  fx.c=fx.c_table[3]
	
	 else
	  fx.c=fx.c_table[4]
	 end
	
	 --physics
	 if fx.grav then fx.dy+=.5 end
	 if fx.grow then fx.r+=.1 end
	 if fx.shrink then fx.r-=.1 end
	
	 --move
	 fx.x+=fx.dx
	 fx.y+=fx.dy
 end
end

function draw_fx()
 for fx in all(effects) do
  --draw pixel for size 1, draw circle for larger
  if fx.r<=1 then
   pset(fx.x,fx.y,fx.c)
  else
   circfill(fx.x,fx.y,fx.r,fx.c)
  end
 end
end

function add_fx(x,y,die,dx,dy,grav,grow,shrink,r,c_table)
 local fx={
  x=x,
  y=y,
  t=0,
  die=die,
  dx=dx,
  dy=dy,
  grav=grav,
  grow=grow,
  shrink=shrink,
  r=r,
  c=0,
  c_table=c_table
 }
 add(effects,fx)
end

function animate_value(t)
	if t.v != t.dv then
		if g.second_tick%1==0 then
			t.dv+=sgn(t.v-t.dv)
		end
	end
end
__gfx__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009a9aaaaaaa4aaaaaaaaa0a00
0000000007077070007777000700070000707700077700000700007007700000077077700000000000000000000000000a000000aaa9aa4aaaa4aaa4aaaaaa00
0070070000700700070000700700707007070070000077700077007000077000000070000000000000aaaaaaaaaa00aaaa0000009aa4aa44aaafaaa44aaaa000
00077000000770000777707007007000070700000070070000007070077007700777000000000000aaaaa9aaaaaaaaaaa0000000a9afaafff44ff44fff490000
0007700000700700070070700777770007077700007007000007070000007000000077000000000aaa999aaaaaaa9aaa000000004aafafffffffffffff9a0000
007007000700007007007070007000700770007000007770000700000000700007700070000000aaa9aaaaa9aaaaa9aaaa00000049afffffffffffffffaaf000
00000000070000700077770000700070070000700777000007007770000070000000770000000a9aaaaaaaaaaaaaaaaaaaa00000faaffe9f9efffe9fefaaf000
000000000000000000000000000000000000000000000000000000000000000000000000000049a9aaaaaaaaaaaaaaaaaaa00000faaf222222fff22222aaf000
0000000000000000000000000000000000000000000000000000000000000000000000000000949a9a9aaaaaaa4aaaaaaaaa0a009a9aaaaaaa4aaaaaaaaa0a00
00707000007000000070070007077070000700000700007007000070070000700007707000009949aaa9aa4aaaa4aaa4aaaaaa00aaa9aa4aaaa4aaa4aaaaaa00
070707700707700007077070007007000070770000707700070770700700007007700700000949499aa4aa44aaafaaa44aaaa0009aa4aa44aaafaaa44aaaa000
00707000007000000007000000070000000700000007000000700700077007700000700000049994a9afaafff44ff44fff490000a9afaafff44ff44fff490000
00707700007700000000770000007000070070700770077000700700000770000007070000494fff4aafa2442fffff244f9a00004aafafffffffffffff9a0000
0070007000707070070700000070070000770700000770000007700000700700007000700044ffff49a226c1c2fff21c622af00049aff24422fff2442faaf000
0070070000700700000700000707707007000070007007000070070007077070070077000044ff4ffaaf27c1c7fff71c77aaf000faa227c1c7fff71c722af000
0000000000000000000000000000000000000000000000000000000000000000000000000044fff4faaff7c1c7fff41c77aaf000faaff7c1c7fff41c77aaf000
0000000000000000000000000000000000000000000000000000000000000000000000000004ff4f4aaf5f444efff4e44faaf0009a9aaaaaaa4aaaaaaaaa0a00
0070070007077070007007000700070000077000000700000070000007070770007777000004fffb3aaefefffffff4fefeaa0000aaa9aa4aaaa4aaa4aaaaaa00
00707000070000700007700000707070007007000070700000070700007070000707007000004ffb3aafeffffffff4ffefa300009aa4aa44aaafaaa44aaaa000
0707777000707700077007700007070007070070000700700070700007000770070070000000044bbaafffffffff4fffffab0000a9afaafff44ff44fff490000
000007000007000000077000007070000770777000777700007077000000700007070000000094444aaffffffffffffff0a000004aafa2442fffff244f9a0000
0070007007007700007007000000070007000070070000700070070000070700070070700009994444affffffff88ffff000000049a22c1c62fff2c6622af000
0707070000700070070770700777707000777700007777000700007007700070007777000009949494a4fffff98888ff00000000faaf2c1c77fff1c777aaf000
0000000000000000000000000000000000000000000000000000000000000000000000000000944990ff4ffffffeefff00000000faaffc1c77fff4c777aaf000
0000000000000000000000000000000000000000000000000000000000000000000000000000099900ff44fffffffff0000000004efff4e44efff4e44efff4e4
070000700007700007000070000700000007700000770700070000700007777007077070000000ccccfff444ffffff0000000000fffff4fefffff4fefffff4fe
007007000070070000700700007070700070070007007070007007000070000000700700000ccc1ccc6fff44441166c000000000fffff4fffffff4fffffff4ff
00700070070770700070707007077700000070700700700007070700070707700700007001c1cdc116cccff4441ccc16c1100000ffff4fffffff4fffffff4fff
00070070007007000007007000700070007007000077070007007000070070000007700011151ccc61cccccc6cccc1cc1c151000ffffffffffffffffffffffff
0077007007077070007077000070007007077000000007000700070007007000007007001151c1c6cc11ccdcc6cc1ccc51115100fff88ffffff88ffff9f88f9f
07007700070000700700007007077700007007700777700000777770070007700707707015111c16cccc1cccc611ccc1c5111500f98778ffff8888ffff8888ff
000000000000000000000000000000000000000000000000000000000000000000000000511111511cdcccdcc6cccc1c15111510fffeeffff9feef9ffffeefff
066000000000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005eeeeeeeeeeeeeeeee550000
6886000000006996000000000000000000099000000000000000000000099000000990000000000000000000000000000000000055eeeeeeeeeeeeeeee550000
6886000000006996000000000000000000999900099999900000000000999900009999000000000000000000000000000000000055ee5555eeeeeee555550000
06565667766565600000999999990000099999999999999999000099999999900999999000000000000eeeeeeeeee0000000000055eeee5555eee5555e554400
0006111111116000000999999999900009999999990000999999999999999990099999900000000000eeeeeeeeeeeee000000000555eeeee55eee55eee554400
000611111111600000099900009990000099990000000000099999900099990000999900000055511eee77eeeeeeeeee10000000555eeeeeeeeeeeeeee544000
00061111111160000009900000099000000990000000000000000000000990000009900000000555eeeeeeeeeeeeeeeee5000000e55eeeeeeeee4eeeee544000
00071111111170000009900000099000000000000000000000000000000000000009900000055555ee7eeeeeeeeeeeeee1500000ee5ee22222eee4222e440000
000711111111700000099000000990000000000000000000000990000009900000099000000055555eeeeeeeeeeeeeeeee5500005eeeeeeeeeeeeeeeee550000
0006111111116000000990000009900000000000000000000009900000099000000990000000055555eeeeeeeeeeeeeeee55000055eeeeeeeeeeeeeeee550000
0006111111116000000999000099900000000000000000000009900000099000009990000ee0055555ee5555eeeeeee55555000055eeeeeeeeeeeeeeee550000
0006111111116000000999999999900099999000000999990009900000099000009900000eeee55555eeee5555eee5555e55440055ee5555eeeeeee555554400
06565667766565600000999999990000999999000099999900099900009990000099000000eeeee5555eeeee55eee55eee554400555eee5555eee5555e554400
6cc6000000006bb600000000000000000000999009990000000099900999000000990000000ee4ee555eee2222eee2222e544000555eeeee55eee55eee544000
6cc6000000006bb600000000000000000000099999900000000009999990000000999000000eee4ee55ee29196ee491962544000e55ee2222eee4e222e544000
0660000000000660000000000000000000000099990000000000009999000000000990000000eee4ee5e279192eee41977440000ee5e279192eee41972440000
04400000000004400000000000000000000000999900000000000099990000000009900000000e4e4eee444444eeee44444400005eeeeeeeeeeeeeeeee550000
42240000000042240000000000000000000009999990000000000999999000000009990000000eee4eeeeeeeeeeeee4eee40000055eeeeeeeeeeeeeeee550000
422400000000422400099000000990000000999009990000000099900999000000009900000000eeeeeeeeeeee4eee4eee00000055ee5555eeeeeee555550000
0424244224424240009999000099990099999900009999990009990000999000000099000000000eeeeeeeeeeeee44eeee00000055eeee5555eee5555e554400
0004222222224000009999000099990099999000000999990009900000099000000099000000000000eeeeeeeeeeeeeee0000000555eeeee55eee55eee554400
00042111111240000009999009999000000000000000000000099000000990000009990000000000004eeeeeeeeeeeeee0000000555eee2222eee2222e544000
0004211111124000000009999990000000000000000000000009900000099000000990000000000000e4eeeee44444ee00000000e55ee21966ee419662544000
0002211111122000000000999900000000000000000000000009900000099000000990000000008882ee4eeeeeeeeeee00000000ee5e291972eee49777440000
0002211111122000000000999900000000099000800000080666666000777700000990000000088888ee44eeeeeeeee00000000044eeee4444eeee4444eeee44
0004211111124000000009999990000000900900280000826622226600777700000990000000888888eee444eeeeee8880000000eeeeee4eeeeeee4eeeeeee4e
00042111111240000009999009999000090000900280082062666626007777000099990000028888ee8eee44444228ee88000000ee4eee4eee4eee4eee4eee4e
0004222222224000009999000099990090000009002882006262262600777700099999900222888e8888eee444428888e8800000eeee44eeeeee44eeeeee44ee
042424422442424000999900009999009000000900028000626226267777777709999990228288e888888e77ee8668888e822000eeeeeeeeeeeeeeeeeeeeeeee
42240000000042240009900000099000090000900080280062666626077777700099990028222e88888887777766688888e22200ee444eeeee4444eee4eeeeee
42240000000042240000000000000000009009000820028066222266007777000009900082222e888888e8777776888888222200e47774eee4eee4eeee4444ee
04400000000004400000000000000000000990008200002806666660000770000000000022282288888e88867777788882282220eeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000004444444400000000000000000000000000000000b3bb3bbbbbbbbbbbbbb00000
0000000000000000000000000000000000000000000000000000000000000000077777700000000000bbbbbbbbb0000000000000bbbbbbbbbbbbb3bbbbb00030
000000000000000000000000000000000000000000000000000000000000000007ffff70000000000bbbbbbbbb3bbb0000000000bb3bb555bbbbbbbb55500330
0000000000000000000000000000000000000000000000000000000000000000007ff700000000000bbb3bbbbbbbbbbb00000000bbbbbbbb555bbb55bbb03330
00000000000000000000000000000000000000000000000000000000000000000007f00000000000bbbbbbbbbbbbbbbbb00000003bbbbbbbbbbbbbbbbbb33330
0000000000000000000000000000000000000000000000000000000000000000007f770000000000bb3bbbbbbbbbbbb3bb000000b3bbbbbbbbbbbbbbbbb33300
000000000000000000000000000000000000000000000000000000000000000007ffff700000000bbbbbbbbbb3bbbbbbbbb00000bb3bbbbbbbbbbbbbbbb33300
0000000000000000000000000000000000000000000000000000000000000000444444440000000bbbbbbbbbbbbbbbbbbbb00000dbbbb222222bbb2222233000
00000000000000000000000000000000000000000000000000000000000000000000ff80000000bbb3bb3bbbbbbbbbbbbbb00000b3bb3bbbbbbbbbbbbbb00000
00000000000000000000000000000000000000000000000000000000000000000004090a0bb000bbbbbbbbbbbbbbb3bbbbb00030bbbbbbbbbbbbb3bbbbb00030
000000000000000000000000000000000000000000000000000000000000000002dddda000bbb03bbb3bb555bbbbbbbb55500330bb3bbbbbbbbbbbbbbbb00330
00000000000000000000000000000000000000000000000000000000000000002d2dddd000bbbbb3bbbbbbbb555bbb55bbb03330bbbbb555bbbbbbbb55503330
000000000000000000000000000000000000000000000000000000000000000022d2ddd0000bbbbb3bbbbbbbbbbbbbbbbbb333303bbbbbbb555bbb55bbb33330
0000000000000000000000000000000000000000000000000000000000000000222d2dd00000bbdbb3bbbb2222bbbb2222b33300b3bbbbbbbbbbbbbbbbb33300
00000000000000000000000000000000000000000000000000000000000000002222d2d00000bbbdbb3bb281892bb28189233300bb3bb22222bbbbb222233300
00000000000000000000000000000000000000000000000000000000000000000222220000000bbbdbbb2981892bbb2189933000dbbb2981892bbb2189933000
00000000000000000000000000000000000000000000000000000000000000000770000000000bbdbdbbbddddddbbbb2ddd33300b3bb3bbbbbbbbbbbbbb00000
00000000000000000000000000000000000000000000000000000000000000000777000000000bbbbdbbbbbbbbbbbbb2bbb33300bbbbbbbbbbbbb3bbbbb00030
000000000000000000000000000000000000000000000000000000000000000000776760000000bbbbbbbbbbb3bbbbbb2bb33000bb3bb555bbbbbbbb55500330
0000000000000000000000000000000000000000000000000000000000000000000777770000000bb00b3bbbbbbbb2bbb2b00000bbbbbbbb555bbb55bbb03330
00000000000000000000000000000000000000000000000000000000000000000707777700000000000bbbbbbbbbbb222b0000003bbbbbbbbbbbbbbbbbb33330
00000000000000000000000000000000000000000000000000000000000000007707777700000000000dbb3bbb7bbbbbbb000000b3bbbb2222bbbb2222b33300
00000000000000000000000000000000000000000000000000000000000000007777777700000000000bdbbbb277222bb0000000bb3bb298182bb29981233300
00000000000000000000000000000000000000000000000000000000000000000777777000000404442bbdbbbbbbbbbbb0040000dbbb2998182bbb2981833000
0000000000000000000000000000000000000000000000000000000000000000088888800044004444bbbddbbbbbbbbb00440000dddbbbb2dddbbbb2dddbbbb2
0000000000000000000000000000000000000000000000000000000000000000088666800004444444b4bbdddbbbbbb444400000bbbbbbb2bbbbbbb2bbbbbbb2
00000000000000000000000000000000000000000000000000000000000000000879996900022444444b4bbdddddddd444404400bbbbbbbbbbbbbbbbbbbbbbbb
0000000000000000000000000000000000000000000000000000000000000000c777c969022244444444b4bbddddddb444444000bbbbb2bbbbbbb2bbbbbbb2bb
0000000000000000000000000000000000000000000000000000000000000000cc7cc9692222444444444b4b4b4b4b4b44442200bbbbbb22bbbbbb22bbbbbb22
0000000000000000000000000000000000000000000000000000000000000000ccccc69922424444444444b4b4b4b4b444444220bb722bbbbb7bbbbbb2b7bbbb
0000000000000000000000000000000000000000000000000000000000000000ccc7799922244444444444444444444444442220b277722bbb77222bbb27722b
0000000000000000000000000000000000000000000000000000000000000000ccccc00022222224444444444444444444422222bbbbbbbbb2bbbbbbbbbbbbbb
0007700000777700007777000770077007777770777777700777777007777770077007700000000001111111111111000000000011111144444f4f4441111100
00777000077777700777777007700770777777777777777777777777777777777770077700000001111111111111111100000000111114111144f44114111100
07777000077007700770077007700770777000777700077777700777777700777700007700001011111111111111111110100000111111111114441111111110
00077000000077700000770007777770770000007700777077000077007770007700007700001111111111111111111111110000121144444444444444111100
00077000000777000000777000777770770000007777770077000077000777007700007700011111111111111111111111100000111144444444444444111100
00077000007700000770077000000770777000777777777077700777770077777770077700001111111111111111111111110000111144444444444444111100
07777770077777000777777000000770777777777700777777777777777777777777777700011111111111111111111111111010111144222224442222111000
07777770077777700077770000000770077777707700077707777770077777700777777001011111111111144444f44111111100411122222224422222112000
0777777000777700077777700077770077000770077777770088880008888880088888800011111211111144444f4f444111110011111144444f4f4441111100
07777770077777700777777007777770777007777777777008888880888888888888888800111111111114111144f44114111100111114444444f44444111100
07700000077000000770077007700770777700777700000088800888888008888880008800111111111111111114441111111110111111111444444111111110
07777700077777000000770000777700777770777777770088000088888888808800000000111111121144444444444444111100121141111114441114111100
00777770077777700000770007700770770777777777700088888888888008888800000000111111111144222244442224111100111144441114441144111100
000007700770077000077000077007707700777777000000888888888880008888800088001111411111422e6624422e62111100111144222244442224111100
0777777007777770000770000777777077700777777777708880088888888888888888880101144411112722e7744722e711100011114222e7244222e2111000
0077770000777700000770000077770007700077077777770880088008888880088888800001142441112722e7444722e711200041112722e7444722e7112000
0077770000777700000770000000000008888800088888880888888800000000000000000000044224444424424444244242200011111144444f4f4441111100
07777770077777700077760000000000888888808888888088888880000088000000000000000444424442f4444444244f422000111114111144f44114111100
0770077007700770777d767700000000888088888800000088800000000088000000000000000044244444444424442444420000111111111114441111111110
07777770077077707776d77700000000888008888888880088888800008888880088888800000004a0044444444422444440a000121144444444444444111100
007777700777077077776600000000008880008888888000888880000088888800888888000000900a04444444444444444a0000111144222244442224111100
00000770077007707777770000000000888008888800000088800000000088000000000000000009a00244444442224444400000111142e6662442e662111100
077777700777777000777000000000008888888888888880888000000000880000000000000000000d22244442222224440000001111222e7774422e77111000
00777700007777000000000000000000088888800888888808800000000000000000000000000111ddd2224444888844400000004111222e7744422e77112000
00000000111170001111111100071111088888800000000000000000000000000000000000011111dddd22244444444400000000424444244244442442444424
00000000111170001111111100071111888888880000000000000000000000000000000000111111d1ddd4424444444dd0000000444444244444442444444424
0000000011117000111111110007111188800088000000000000000000000000000000000111111d1d1dddd4222211ddddd00000442444244424442444244424
7777777711117000111111110007111108888000000000000000000000000000000000001111111dd1ddddd9444211111ddd0000444422444444224444442244
1111111111117000777777770007111100088880000000000000000000000000000000001111111dddddd1da94444111111dd100444444444444444444444444
1111111111117000000000000007111188008888000000000000000000000000000000001111111ddddd1d1daa444a111111dd10444222444442224442422244
1111111111117000000000000007111188888888000000000000000000000000000000001111111dddddd1ddd9aaa1111111dd11427777244422224444222224
11111111111170000000000000071111088888800000000000000000000000000000000011111111dddddddddd9444111111dd11448888444288882444888844
__label__
06600000000000000000000000000000000000000000000000000000000000000000000000000000000006600000000000000000000000000000000000000000
68860000000000000000000000000000000000000000000000000000000000000000000000000000000069960000000000000000000000000000000000000000
68860000000000000000000000000000000000000000000000000000000000000000000000000000000069960000000000000000000000000000000000000000
06565667666666666666666666666666666666666666666666666666666666666666666666666666766565600000000000000000000000000000000000000000
00061111111111111111111111111111111111111111111111111111111111111111111111111111111160000000000000000000000000000000000000000000
00061111111111111111111111111111111111111111111111111111111111111111111111111111111160000004444444400007700000777700007777000000
70000000888801111111111111111111111111111111111111111111111111111111111111111111111160000000777777000077700007777770077777700000
070000008888011111111111111111111111111111111111111111111111111111111111111111111111700000007ffff7000777700007700770077000000000
0070000088880777771111111111111111111111111111111111111111111111111111111111111111116000000007ff70000007700007707770077777000000
070000008888088887999999991888888881888888881cccccccc1999999991888888881cccccccc111160000000007f00000007700007770770077777700000
700000008888018887919119191818118181888118881c1cccc1c1991999991811811181cc1111cc11116000000007f770000007700007700770077007700000
000000000000081887991991991818888181881881881cc1cc1cc1999191991888818881c1c1cc1c1111600000007ffff7000777777007777770077777700000
000611117818118187919999191881811881888818181cc1c1c1c1991919991811188881c1cc1ccc111160000004444444400777777000777700007777000000
000611117881881887999119991888188881881881881ccc1cc1c1991911991888811881c1c1cccc111160000000000000000000000000000000000000000000
000611117818118187991991991818811881818118881cc1c11cc1991991991811888181c1cc1c1c111160000000000000000000000000000000000000000000
000611117818888187919119191881888181881881181c1cccc1c1919999191888811881cc1111cc111160000000000000000000000000000000000000000000
000611117888888887999999991888888881888888881cccccccc1999999991888888881cccccccc111160000000006666660000000000000000000000000000
00061111777777777711111111111111111111111111111111111111111111111111111111111111111160000000066222266000999000909990900000000000
000611111cccccccc1999999991cccccccc1cccccccc199999999188888888188888888199999999111160000000062666626000909009000090900000000000
000611111c1c11c1c1919999191c1ccc1cc1c1c11c1c191911919188111188188181188199919999111160000000062622626000909009000990999000000000
000611111cc1cc1cc1991991991c1cc1c1c1cc1cc1cc199199199181888818181818818199191199111160000000062622626000909009000090909000000000
000611111c1cccc1c1919191991c1cc1ccc1c1cccc1c199911999181111818181818888199919999111160000000062666626000999090009990999000000000
000611111ccc11ccc1919919991c11111cc1ccc11ccc199199199181881818181811188191991919111160000000066222266000000000000000000000000000
000611111cc1cc1cc1919991991cc1ccc1c1cc1cc1cc191999919181881818181188818199119199111160000000006666660000000000000000000000000000
000611111c1c11c1c1991111191cc1ccc1c1c1c11c1c191999919188111188181888818191999919111160000000000000000000000000000000000000000000
000611111cccccccc1999999991cccccccc1cccccccc199999999188888888188888888199999999111160000000000000000000000000000000000000000000
00061111111111111111111111111111111111111111111111111111111111111111111111111111111160000000000000000000000000000000000000000000
000611111999999991888888881cccccccc1999999991cccccccc1999999991cccccccc1cccccccc111160000000777700000000000000000000000000000000
000611111999199991818118181ccc11c1c1919119191ccc11ccc1999199991c11c111c1c1cccc1c111160000077cccc77000000000000000000000000000000
000611111991919191881881881c11cc1cc1991991991cc1cc1cc1991919191cccc1ccc1cc1cc1cc11116000007cccccc7000000000000000000000000000000
000611111919111991888118881cccc1ccc1999119991cccc1c1c1919111991c111cccc1cc1ccc1c1111600007cccccccc700ccc0ccc000c0ccc0ccc00000000
000611111991999191881881881ccc1c1cc1991991991cc1cc1cc1991999191cccc11cc1ccc1cc1c1111600007cccccccc700c0c0c0c00c00c0c0c0c00000000
000611111991999191818888181cc1ccc1c1919999191c1c11ccc1991999191c11ccc1c1cc11cc1c1111600007cccccccc700ccc0c0c00c00ccc0c0c00000000
000611111919111991818888181c1cc11cc1919999191cc1cc11c1919111991cccc11cc1c1cc11cc1111600007cccccccc700c0c0c0c00c00c0c0c0c00000000
000611111999999991888888881cccccccc1999999991cccccccc1999999991cccccccc1cccccccc11116000007cccccc7000ccc0ccc0c000ccc0ccc00000000
00061111111111111111111111111111111111111111111111111111111111111111111111111111111160000077cccc77000000000000000000000000000000
000611111999999991888888881999999991999999991cccccccc1999999991cccccccc1cccccccc111160000000777700000000000000000000000000000000
000611111991999991818181181991999991919999191cc1111cc1919999191cc1cc1cc1cc1111cc111160000000000000000000000000000000000000000000
000611111999191991881818881999191991919999191c1c1cc1c1991991991c1c11c1c1c1c1cc1c111160000000000000000000000000000000000000000000
000611111991919991818881181991919991911991191c1cc1ccc1919191991ccc1cccc1c1cc1ccc111160000000aaaa00000000000000000000000000000000
000611111991911991888818881991911991999119991c1c1cccc1919919991cccc11cc1c1c1cccc1111600000aa0000aa000000000000000000000000000000
000611111991991991888181881991991991991991991c1cc1c1c1919991991c1c1cccc1c1cc1c1c1111600000a000000a000000000000000000000000000000
000611111919999191811888181919999191919119191cc1111cc1991111191ccc1cccc1cc1111cc111160000a00000000a00909099900090900099900000000
000611111999999991888888881999999991999999991cccccccc1999999991cccccccc1cccccccc111160000a99999999a00909090900900900090900000000
00061111111111111111111111111111111111111111111111111111111111111111111111111111111160000a99999999a00999090900900999090900000000
000611111cccccccc1999999991cccccccc1cccccccc1999999991999999991cccccccc188888888111160000a99999999a00009090900900909090900000000
000611111ccc1cccc1999111191c1cccc1c1cc11c1cc1991991991999119991c1cccc1c1818888181111600000a999999a000009099909000999099900000000
000611111cc1c11cc1991999991c1c11c1c1c1cc1c1c1991919991991991991cc1cc1cc1881811881111600000aa9999aa000000000000000000000000000000
000611111ccc1cccc1919191191cc1cc1cc1c1cc1ccc1919111191919119191cc1ccc1c188818888111160000000aaaa00000000000000000000000000000000
000611111c1cc1c1c1919919991cc1cc1cc1cc11c1cc1999991991991991991ccc1cc1c181188118111160000000000000000000000000000000000000000000
000611111cc11c1cc1919919991ccc11ccc1ccccc1cc1991999191919119191cc11cc1c188811888111160000000000000000000000000000000000000000000
000611111c1cccc1c1919991191cc1cc1cc1c1111ccc1919191991919999191c1cc11cc188188188111160000000222200000000000000000000000000000000
000611111cccccccc1999999991cccccccc1cccccccc1999999991999999991cccccccc188888888111160000022000022000000000000000000000000000000
00061111111111111111111111111111111111111111111111111111111111111111111111111111111160000020000002000000000000000000000000000000
000611111cccccccc1cccccccc1cccccccc1999999991888888881999999991cccccccc199999999111160000200000000200880088800080888088800000000
000611111cc11c1cc1cc1cc1cc1c11c111c1919191191881881881999111191ccc11ccc191999919111160000200000000200080080000800008080800000000
000611111c1cc1c1c1c1c11c1c1cccc1ccc1991919991881818881991999991cc1cc1cc191999919111160000288888888200080088800800088080800000000
000611111c1cc1ccc1ccc1cccc1c111cccc1919991191818111181919191191cccc1c1c191199119111160000288888888200080000800800008080800000000
000611111cc11c1cc1cccc11cc1cccc11cc1999919991888881881919919991cc1cc1cc199911999111160000028888882000888088808000888088800000000
000611111ccccc1cc1c1c1cccc1c11ccc1c1999191991881888181919919991c1c11ccc199199199111160000022888822000000000000000000000000000000
000611111c1111ccc1ccc1cccc1cccc11cc1911999191818181881919991191cc1cc11c191911919111160000000222200000000000000000000000000000000
000611111cccccccc1cccccccc1cccccccc1999999991888888881999999991cccccccc199999999111160000000000000000000000000000000000000000000
00061111111111111111111111111111111111111111111111111111111111111111111111111111111160000000000000000000000000000000000000000000
000611111999999991888888881888888881999999991888888881cccccccc199999999199999999111160000000000000000000000000000000000000000000
000611111999111191818118181881881881919119191881111881c1c11c1c199919999191911919111160000000000000000000000000000000000000000000
000611111991999991881881881888118881991991991818188181cc1cc1cc199191919199199199111160000000cc0000000000999099900000088808880000
000611111919191191888188881811881181999119991818818881ccc11ccc1919111991919999191111600000000c0000000000009090900000000808080000
000611111919919991888818881888118881991991991818188881cc1cc1cc1991999191999119991111600000000c0000000000999090900000008808080000
000611111919919991881881881881881881919999191818818181c1cccc1c1991999191991991991111600000000c0000000000900090900000000808080000
000611111919991191818118181818118181919999191881111881c1cccc1c191911199191911919111160000000ccc000000000999099900000088808880000
000611111999999991888888881888888881999999991888888881cccccccc199999999199999999111160000000000000000000000000000000000000000000
0006111111111111111111111111111111111111111111111111111111111111111111111111111111116000cccccccccccc0000000000000000000000000000
000611111999999991888888881cccccccc1cccccccc1999999991999999991888888881cccccccc11116000c0000000000c0000000000000000000000000000
000611111911999991811188881c1cccc1c1c11ccccc1919991991991111991818888181ccc11ccc11116000c0077000000c0008888880000008000ff8800000
000611111999119991888811181cc11cc1c1ccc11ccc1991919191919999191881811881cc1cc1cc11116000c0077700000c0008866680000002804098200000
000611111911991191881881881cccc1c1c1c11cc11c1999191991911119191888188881c1c1cc1c11116000c0007767600c000879996900000028dd82000000
000611111999919991881881881ccc1c1cc1cccc1ccc1991919991919919191811881181c11c111c11116000c0000777770c00c777c969000002d2882d000000
000611111999919991888811181ccc1cccc1cccc1ccc1999991991919919191888118881c1cccc1c11116000c0070777770c00cc7cc9690000022d28dd000000
000611111999919991811188881c1cc111c1cccc1ccc1911119191991111991881881881cc1111cc11116000c0770777770c00ccccc69900000228d28d000000
000611111999999991888888881cccccccc1cccccccc1999999991999999991888888881cccccccc11116000c0777777770c00ccc77999000002822d28000000
0007111111111111111111111111111111111111111111111111111111111111111111111111111111117000c007777ccccc00ccccc000000008222222800000
0006111111111111111111111111111111111111111111111111111111111111111111111111111111116000c00000cc000cc000000000000000000000000000
0006111111111111111111111111111111111111111111111111111111111111111111111111111111116000cccccccc0c0cc000000000000000000000000000
0006111111111111111111111111111111111111111111111111111111111111111111111111111111116000000000cc000cc000000000000000000000000000
06565667666666666666666666666666666666666666666666666666666666666666666666666666766565600000000ccccc0000000000000000000000000000
6cc6000000000000000000000000000000000000000000000000000000000000000000000000000000006bb60000000000000000000000000000000000000000
6cc6000000000000000000000000000000000000000000000000000000000000000000000000000000006bb60000000000000000000000000000000000000000
06600000000000000000000000000000000000000000000000000000000000000000000000000000000006600000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
62222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226
62666666666666666666666666666666666222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226
62600000000000000000000000000000006222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226
62600000000000000000000000000000006222777222227272277277727772222272722772727227227272777222227772777277727722222222222222222226
62600000000000000000000000000000006222272222227272727272727222222272727272727272227272722222227272722272227272222222222222222226
62600000000000eeeeeeeeee00000000006222272222227772727277727722222277727272727222227272772222227722772277227272222222222222222226
6260000000000eeeeeeeeeeeee000000006222272222227272727272227222222222727272727222227772722222227272722272227272222222222222222226
626000055511eee77eeeeeeeeee10000006222777222227272772272227772222277727722277222222722777222227772777277727272222222222222222226
62600000555eeeeeeeeeeeeeeeee5000006222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226
62600055555ee7eeeeeeeeeeeeee1500006222277277727272772272727772772227722222222222222222222222222222222222222222222222222222222226
626000055555eeeeeeeeeeeeeeeee550006222722227227272727272722722727272222222222222222222222222222222222222222222222222222222222226
6260000055555eeeeeeeeeeeeeeee550006222777227227272727277722722727272222222222222222222222222222222222222222222222222222222222226
6260ee0055555ee5555eeeeeee555550006222227227227272727222722722727272722222222222222222222222222222222222222222222222222222222226
6260eeee55555eeee5555eee5555e554406222772227222772777277727772727277722722222222222222222222222222222222222222222222222222222226
62600eeeee5555eeeee55eee55eee554406222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226
626000ee4ee555eee2222eee2222e544006222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226
626000eee4ee55ee29196ee491962544006222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226
6260000eee4ee5e279192eee41977440006222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226
62600000e4e4eee444444eeee4444440006222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226
62600000eee4eeeeeeeeeeeee4eee400006222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226
626000000eeeeeeeeeeee4eee4eee000006222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226
6260000000eeeeeeeeeeeee44eeee000006222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226
6260000000000eeeeeeeeeeeeeee0000006222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226
62600000000004eeeeeeeeeeeeee0000006266666666666666666666666666666666666666666666666666666666666666666666666666666666666666666626
6260000000000e4eeeee44444ee00000006265555555555555555555555555555555555555555555555555555555555555555555555555555555555555555626
6260000008882ee4eeeeeeeeeee00000006265555555555555555555555555555555555555555555555555555555555555555555555555555555555555555626
6260000088888ee44eeeeeeeee000000006265585885855959959555599995588855555555555555555555555555555555555555555555555555555555555626
6260000888888eee444eeeeee8880000006265558558555595595555955555555588855555555555555555555555555555555555555555555555555555555626
62600028888ee8eee44444228ee88000006265555855555559955559595995558558555555555555555555555555555555555555555555555555555555555626
6260222888e8888eee444428888e8800006265555585555595595559559555558558555555555555555555555555555555555555555555555555555555555626
626228288e888888e77ee8668888e822006265558558555955559559559555555588855555555555555555555555555555555555555555555555555555555626
62628222e88888887777766688888e22206265585885855955559559555995588855555555555555555555555555555555555555555555555555555555555626
62682222e888888e8777776888888222206265555555555555555555555555555555555555555555555555555555555555555555555555555555555555555626
62622282288888e88867777788882282226265555555555555555555555555555555555555555555555555555555555555555555555555555555555555555626
62666666666666666666666666666666666266666666666666666666666666666666666666666666666666666666666666666666666666666666666666666626
62222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666

__map__
40f0f0f0f0f0f0f0f0f0f0f0f041000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f3002800370355457400050000f1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f3003002426400350001003206f1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f3740000783642430400630074f1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f3086545464653565564001278f1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f3000000000000000000000000f1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f3000000000000000000000000f1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f3000000000000000000000000f1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f3244800000000000000622274f1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f3005700000000000000006553f1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f3740000007454003800200063f1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f3210000260000730074466400f1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50f2f2f2f2f2f2f2f2f2f2f2f251000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
01050000140501c050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001e510195101351011510125101551016510115001c5001b5001b5001a5001a5001a5001a5001a5001a5001a5001a5001a5001a5001a50000500005000050000500005000050000500005000050000500
010100001c51019510175101351012510175101c51000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010100001c5101a5101751017510185101b5101f51000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400001251215512175122351223502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200000000000000000000
01040000205221e5221d5221252200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200000000000000000000
00010000125201552016520185201652013520115201c500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000100001152016520185201852016520115200c52000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000008520085200b5200b5200e5200e5200e5200b5200b5200552005520025200252000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a0500000761708617086170a6170b6170c6170e6170e6270f627106271162711627106270e6270c6270a6270962708627076170561704617026170061712607116070f6070e6070b60709607086070660705607
cb0400000c5200c5300d5400c54017500195000a5400c5500f5400f5300c52000500005000c5300c5400a5400a530005000d5300f540115501154000500005000f5400e5400e5500d5600050009555075450f500
ca0400000c5500c5300f5300f5300f5000d5000c5300c5400c5500c5000d5000f5300f5300d5400c5500f56011500135001353013540115500f5400d5200c5000c5000d5300f5400d5400c5000c5500a55007550
010300000c5510c55116551165511355113551165511655122501225011e501225010050100501005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501

pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--diceroll code
--by jake, kevin, & sean

function _init()
  num_dice = 2  -- change this to roll more
  rolls = {}    -- table to hold each die result
  for i = 1, num_dice do
    rolls[i] = 1
  end
  rolling = false
  roll_timer = 0
  snake_eyes = false
  roll_duration = 60
  ox = {}
  oy = {}
  for i = 1, num_dice do
    ox[i] = 0
    oy[i] = 0
  end
end

function _update()
  if btnp(4) and not rolling then
    rolling = true
    roll_timer = 0
    sfx(0)
  end

  if rolling then
    roll_timer += 1

    local flash_rate = 4
    if roll_timer % flash_rate == 0 then
      for i = 1, num_dice do
        rolls[i] = flr(rnd(6)) + 1
        ox[i] = flr(rnd(5)) - 2
        oy[i] = flr(rnd(5)) - 2
      end
    end

			if roll_timer >= roll_duration then
			  rolling = false
			  snake_eyes = true
			  for i = 1, num_dice do
			    rolls[i] = flr(rnd(6)) + 1
			    ox[i] = 0
			    oy[i] = 0
			  end
			  -- check after final rolls are set
			  snake_eyes = true
			  for i = 1, num_dice do
			    if rolls[i] != 1 then
			      snake_eyes = false
			    end
			  end
			end
  end
end



function _draw()
  cls()
  -- spread dice across screen, 20px apart
  for i = 1, num_dice do
    local x = 54 + (i - 1) * 20
    local fx = rolling and (rnd(2) > 1) or false
    local fy = rolling and (rnd(2) > 1) or false
    spr(rolls[i], x + ox[i], 64 + oy[i], 1, 1, fx, fy)
  end

  if not rolling then
	  local sum = 0
	  for i = 1, num_dice do
	    sum += rolls[i]
	  end
	  print("total: "..sum, 56, 80, 7)
	
	  if snake_eyes then
	    print("snake eyes, bitch!", 46, 90, 8)  -- color 8 = red
	  end
	end
end
__gfx__
00000000777777777777777777777777777777777777777777777777000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777777117777771177777711771177117711771177117000000000000000000000000000000000000000000000000000000000000000000000000
00700700777777777117777771177777711771177117711771177117000000000000000000000000000000000000000000000000000000000000000000000000
0007700077711777777777777771177777777777777117777dd77dd7000000000000000000000000000000000000000000000000000000000000000000000000
0007700077711777777777777771177777777777777117777dd77dd7000000000000000000000000000000000000000000000000000000000000000000000000
00700700777777777777711777777117711771177117711771177117000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777777777711777777117711771177117711771177117000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777777777777777777777777777777777777777777777000000000000000000000000000000000000000000000000000000000000000000000000

love.graphics.drawq = love.graphics.draw
local LogicalScale = {}
local lx, ly = 800, 600

function love.run()
	if love.math then
		love.math.setRandomSeed(os.time())
	end
	math.randomseed(os.time())

	if love.load then love.load(arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0
	
	windowwidth, windowheight = love.window.getMode()
	LogicalScale.ScreenX, LogicalScale.ScreenY = windowwidth, windowheight
	LogicalScale.ScaleOverall = math.min(LogicalScale.ScreenX / lx, LogicalScale.ScreenY / ly)
	LogicalScale.OffX = (LogicalScale.ScreenX - LogicalScale.ScaleOverall * lx) / 2
	LogicalScale.OffY = (LogicalScale.ScreenY - LogicalScale.ScaleOverall * ly) / 2
	
	function love.resize(w, h)
		windowwidth, windowheight = w, h
		--lx, ly = Config.Letterboxing.LogicalWidth, Config.Letterboxing.LogicalHeight
		LogicalScale.ScreenX, LogicalScale.ScreenY = w, h
		LogicalScale.ScaleOverall = math.min(LogicalScale.ScreenX / lx, LogicalScale.ScreenY / ly)
		LogicalScale.OffX = (LogicalScale.ScreenX - LogicalScale.ScaleOverall * lx) / 2
		LogicalScale.OffY = (LogicalScale.ScreenY - LogicalScale.ScaleOverall * ly) / 2
	end

	-- Main loop time.
	while true do
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end

		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

		if love.graphics and love.graphics.isActive() then
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.graphics.push("all")
			love.graphics.translate(LogicalScale.OffX, LogicalScale.OffY)
			love.graphics.scale(LogicalScale.ScaleOverall)
			if love.draw then love.draw() end
			love.graphics.pop()
			love.graphics.present()
		end

		if love.timer then love.timer.sleep(0.001) end
	end
end

function physicaltological(x, y)
	return
		(x - LogicalScale.OffX) / LogicalScale.ScaleOverall,
		(y - LogicalScale.OffY) / LogicalScale.ScaleOverall
end

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	
	require "class"
	require "menu"
	require "cloud"
	require "cloud2"
	require "bush"
	require "scene1"
	require "scene2"
	require "scene3"
	require "scene4"
	require "scene5"
	require "scene6"
	require "laser"
	require "enemy"
	require "explosion"
	require "bigexplosion"
	require "splatter"
	require "powerup"
	require "rocket"
	require "star"
	require "asteroid"
	require "bullet"
	require "bird"
	gvec = require "gvec"
	
	love.window.setIcon( love.image.newImageData("graphics/icon.png") )
	imagelist = {"title", "cloud1", "cloud2", "ground", "bush1", "bush2", "powerup", "rocket", "star", "asteroid-big1", "sunglasses", "awesome", "arrow", "groundwin",
				"asteroid-big2", "asteroid-small1", "asteroid-small2", "bullet", "littleexplosion", "warning", "wheatley", "alert", "randomshit", "bird"}
	
	for i = 1, #imagelist do
		_G[imagelist[i] .. "img"] = love.graphics.newImage("graphics/" .. imagelist[i] .. ".png")
	end
	
	fontimage = love.graphics.newImage("graphics/font.png")
	
	fontglyphs = "0123456789abcdefghijklmnopqrstuvwxyz.:/,'C-_>* !{}?"
	fontquads = {}
	for i = 1, string.len(fontglyphs) do
		fontquads[string.sub(fontglyphs, i, i)] = love.graphics.newQuad((i-1)*8, 0, 8, 8, 408, 8)
	end
	
	playerimg = love.graphics.newImage("graphics/trosh.png")
	playerquad = {love.graphics.newQuad(0, 0, 14, 25, 54, 25), love.graphics.newQuad(14, 0, 14, 25, 54, 25), love.graphics.newQuad(28, 0, 26, 12, 54, 25), love.graphics.newQuad(28, 12, 26, 12, 54, 25)}
	
	winplayerimg = love.graphics.newImage("graphics/troshwin.png")
	winplayerquad = {}
	for x = 1, 4 do
		winplayerquad[x] = love.graphics.newQuad((x-1)*11, 0, 11, 26, 44, 26)
	end
	
	enemyimg = love.graphics.newImage("graphics/enemy.png")
	enemyquad = {}
	for y = 1, 4 do
		for x = 1, 4 do
			enemyquad[(y-1)*4+x] = love.graphics.newQuad((x-1)*100, (y-1)*96, 100, 96, 400, 384)
		end
	end
	
	explosionimg = love.graphics.newImage("graphics/explosion.png")
	explosionquad = {}
	for y = 1, 5 do
		for x = 1, 5 do
			explosionquad[(y-1)*5+x] = love.graphics.newQuad((x-1)*66, (y-1)*81, 66, 81, 330, 405)
		end
	end
	
	bigexplosionimg = love.graphics.newImage("graphics/bigexplosion.png")
	bigexplosionquad = {}
	for y = 1, 5 do
		for x = 1, 5 do
			bigexplosionquad[(y-1)*5+x] = love.graphics.newQuad((x-1)*108, (y-1)*121, 108, 121, 540, 605)
		end
	end
	
	splatterimg = love.graphics.newImage("graphics/splatter.png")
	splatterquad = {}
	for x = 1, 6 do
		splatterquad[x] = love.graphics.newQuad((x-1)*64, 0, 64, 64, 384, 64)
	end
	
	birdquad = {love.graphics.newQuad(0, 0, 29, 16, 29, 32), love.graphics.newQuad(0, 16, 29, 16, 29, 32)}
	
	scale = 8
	--[[
	local w, h = love.window.getMode()
	if w ~= 100*scale or h ~= 80*scale then
		love.window.setMode(100*scale, 80*scale, false, true, 16)
	end
	love.window.setIcon( love.image.newImageData("graphics/icon.png") )
	]]
	
	bgmusic = love.audio.newSource("audio/trosong.ogg")
	bgmusic:setLooping(true)
	lasersound = love.audio.newSource("audio/laser.wav", "static")
	bigexplosionsound = love.audio.newSource("audio/bigexplosion.ogg", "static")
	explosionsound = love.audio.newSource("audio/explosion.wav", "static")
	launchsound = love.audio.newSource("audio/launch.ogg", "static")
	gunfire = love.audio.newSource("audio/gunfire.wav", "static")
	space = love.audio.newSource("audio/space.ogg", "static")
	sunglassessound = love.audio.newSource("audio/sunglasses.ogg", "static")
	splat = love.audio.newSource("audio/splat.ogg", "static")
	ding = love.audio.newSource("audio/ding.ogg", "static")
	credits = love.audio.newSource("audio/credits.ogg")
	approach = love.audio.newSource("audio/approach.ogg", "static")
	credits:setLooping(true)
	
	skipupdate = true
	shakeamount = 0
	shake = 0
	fade = 0
	playerframe = 1
	scoreanim = 1
	rainbowi = 0.5
	sini = 0
	sini2 = math.pi/2
	scrollx = 0
	points = 0
	machinedelay = 0.05
	stars = {}
	explosions = {}
	backgroundstripes = 10
	sunrot = 0
	
	lasers = {}
	
	realasteroiddelay = 1
	movement1speed = 100
	laserdelay = 0
	reallaserdelay = 0.4
	starttimer = 0
	changegamestate("menu")
end

function love.update(dt)
	if skipupdate then
		skipupdate = false
		return
	end
	
	sunrot = sunrot + dt*50
	
	starttimer = starttimer + dt
	
	if scoreanim < 1 then
		scoreanim = scoreanim + (1-scoreanim)*8*dt
	end
	
	if laserdelay > 0 then
		laserdelay = math.max(0, laserdelay-dt)
	end
	
	shake = math.random()*shakeamount*2-shakeamount
	
	if _G[gamestate .. "_update"] then
		_G[gamestate .. "_update"](dt)
	end
	
	--LASERS
	local delete = {}
	
	for i, v in pairs(lasers) do
		if v:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(lasers, v) --remove
	end
end

function pointsget(i)
	points = points + i
	scoreanim = 0
	rainbowi = math.random()
	shakeamount = 10
end

function love.draw()
	love.graphics.translate(50*scale, 40*scale)
	love.graphics.rotate(shake/300)
	love.graphics.translate(-50*scale, -40*scale)
	
	love.graphics.translate(shake*scale/4, shake*scale/4)
	
	if _G[gamestate .. "_draw"] then
		_G[gamestate .. "_draw"]()
	end
	
	
	if gamestate ~= "menu" and gamestate ~= "scene6" and not landing then
		local r, g, b = unpack(getrainbowcolor(rainbowi))
		
		local ar = r + (255-r)*scoreanim
		local ag = g + (255-g)*scoreanim
		local ab = b + (255-b)*scoreanim
		
		love.graphics.setColor(ar, ag, ab)
		
		local s = scale*0.5+(1-scoreanim)*10
		love.graphics.rotate((1-scoreanim)*0.4)
		properprint("score: " .. points, 2, 2, s)
		love.graphics.rotate(-(1-scoreanim)*0.4)
	end
	
	love.graphics.translate(-shake*scale/4, -shake*scale/4)
	
	
	love.graphics.translate(50*scale, 40*scale)
	love.graphics.rotate(-shake/300)
	love.graphics.translate(-50*scale, -40*scale)
	if fade > 0 then
		love.graphics.setColor(255, 255, 255, 255*fade)
		love.graphics.rectangle("fill", 0, 0, 100*scale, 80*scale)
		love.graphics.setColor(255, 255, 255, 255)
	end
end

function love.keypressed(key, unicode)
	if key == "escape" then return love.event.quit() end
	if _G[gamestate .. "_keypressed"] then
		_G[gamestate .. "_keypressed"](key, unicode)
	end
	
	if key ~= "left" and key ~= "up" and key ~= "right" and key ~= "down" then
		if _G[gamestate .. "_action"] then
			_G[gamestate .. "_action"](key)
		end
	end
end

function love.keyreleased(key, unicode)
	if _G[gamestate .. "_keyreleased"] then
		_G[gamestate .. "_keyreleased"](key, unicode)
	end
end

function changegamestate(i)
	gamestate = i
	if _G[gamestate .. "_load"] then
		_G[gamestate .. "_load"]()
	end
end

function draw(drawable, x, y, r, sx, sy, ox, oy, kx, ky)
	if not sx then
		sx = 1
	end
	if not sy then
		sy = 1
	end
	love.graphics.draw(drawable, x*scale, y*scale, r, sx*scale, sy*scale, ox, oy, kx, ky )
end

function round(num, idp) --Not by me
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function properprint(s, x, y, sc)
	local sc = sc or scale
	local startx = x
	local skip = 0
	for i = 1, string.len(tostring(s)) do
		if skip > 0 then
			skip = skip - 1
		else
			local char = string.sub(s, i, i)
			if fontquads[char] then
				love.graphics.drawq(fontimage, fontquads[char], x*scale+((i-1)*8+1)*sc, y*scale, 0, sc, sc)
			end
		end
	end
end

function round(num, idp) --Not by me
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function getrainbowcolor(i, whiteness)
	local whiteness = whiteness or 255
	local r, g, b
	if i < 1/6 then
		r = 1
		g = i*6
		b = 0
	elseif i >= 1/6 and i < 2/6 then
		r = (1/6-(i-1/6))*6
		g = 1
		b = 0
	elseif i >= 2/6 and i < 3/6 then
		r = 0
		g = 1
		b = (i-2/6)*6
	elseif i >= 3/6 and i < 4/6 then
		r = 0
		g = (1/6-(i-3/6))*6
		b = 1
	elseif i >= 4/6 and i < 5/6 then
		r = (i-4/6)*6
		g = 0
		b = 1
	else
		r = 1
		g = 0
		b = (1/6-(i-5/6))*6
	end
	
	local add = 0
	if whiteness > 255 then
		add = whiteness-255
	end
	
	return {math.min(255, round(r*whiteness)+add), math.min(255, round(g*whiteness)+add), math.min(255, round(b*whiteness)+add), 255}
end

function love.touchpressed(touch_id, x, y)
	x, y = physicaltological(x, y)
	if not(touchcontrol) and x <= 266 then
		touchcontrol = {touch_id, x, y, 0, {}}
	else
		return love.keypressed("i", "i")
	end
end

function add_direction(t, name)
	for i = 1, #t do
		if t[i] == name then return end
	end
	
	t[#t + 1] = name
end

function contains_value(t, val)
	for i = 1, #t do
		if t[i] == val then return true end
	end
	return false
end

local a = love.keyboard.isDown
function love.keyboard.isDown(...)
	if touchcontrol then
		local arg = {...}
		
		for i = 1, #arg do
			if contains_value(touchcontrol[5], arg[i]) then
				return true
			end
		end
	end
	
	return a(select(1, ...))
end

function love.touchmoved(touch_id, x, y)
	x, y = physicaltological(x, y)
	if touchcontrol and touchcontrol[1] == touch_id then
		local v = gvec.vec2(touchcontrol[2] - x, touchcontrol[3] - y)
		local rot = (math.floor((math.deg(math.atan2(v.y, v.x)) - 90) / 45 + 0.5) * 45) % 360
		
		if gvec.length(gvec.clamp(v, -100, 100)/141.42135) >= 0.5 then
			local dirtemp = {}
			for i = #touchcontrol[5], 1, -1 do
				print("release", touchcontrol[5][i])
				love.keyreleased(touchcontrol[5][i], touchcontrol[5][i])
			end
			
			-- Pressed. Check range
			if rot == 0 then
				add_direction(dirtemp, "up")
			elseif rot == 45 then
				add_direction(dirtemp, "up")
				add_direction(dirtemp, "right")
			elseif rot == 90 then
				add_direction(dirtemp, "right")
			elseif rot == 135 then
				add_direction(dirtemp, "right")
				add_direction(dirtemp, "down")
			elseif rot == 180 or rot == -180 then
				add_direction(dirtemp, "down")
			elseif rot == 225 then
				add_direction(dirtemp, "down")
				add_direction(dirtemp, "left")
			elseif rot == 270 then
				add_direction(dirtemp, "left")
			elseif rot == 315 then
				add_direction(dirtemp, "left")
				add_direction(dirtemp, "up")
			end
			for i = 1, #dirtemp do
				print("press", dirtemp[i])
				love.keypressed(dirtemp[i], dirtemp[i])
			end
			--print(dirtemp[1], dirtemp[2])
			--[[
			-- compare with previous
			print("dbg", touchcontrol[5][1], touchcontrol[5][2], dirtemp[1], dirtemp[2])
			for i = 1, #touchcontrol[5] do
				local f = false
				if contains_value(dirtemp, touchcontrol[5][i]) then
					f = true
					break
				end
				
				print("rem", touchcontrol[5][i], f)
				if not(f) then
					love.keyreleased(touchcontrol[5][i], touchcontrol[5][i])
				end
			end
			
			-- compare with current
			for i = 1, #dirtemp do
				local f = false
				if contains_value(touchcontrol[5], dirtemp[i]) then
					f = true
					break
				end
				
				print("add", dirtemp[i], f)
				if not(f) then
					love.keypressed(dirtemp[i], dirtemp[i])
				end
			end
			]]
			touchcontrol[5] = dirtemp
		else
			-- remove all
			for i = 1, #touchcontrol[5] do
				love.keyreleased(touchcontrol[5][i], touchcontrol[5][i])
			end
			touchcontrol[5] = {}
		end
		
		touchcontrol[4] = rot
	end
end

function love.touchreleased(touch_id, x, y)
	if touchcontrol and touchcontrol[1] == touch_id then
		-- remove all
		for i = 1, #touchcontrol[5] do
			love.keyreleased(touchcontrol[5][i], touchcontrol[5][i])
		end
		touchcontrol = nil
	else
		love.keyreleased("i", "i")
	end
end

-- test emulate
function love.mousepressed(x, y, b, ist)
	if ist then return end
	return love.touchpressed(1, x, y)
end

function love.mousemoved(x, y, dx, dy, ist)
	if ist then return end
	return love.touchmoved(1, x, y)
end

function love.mousereleased(x, y, b, ist)
	if ist then return end
	return love.touchreleased(1, x, y)
end

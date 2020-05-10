local sched = require "scheduler"
local socket = require "socket"
local invoke = require "invoke"

local gettime = socket.gettime
local after = sched.after

local schedfood = 0
local reloadfood = 0
local rects = {}
--[[ format:
	rects[id] = {
		w = 100,
		h = 100,
		x = 0,
		y = 0,
		color = {0.4, 0.2, 0.2, 0.5},
	}
]]

local rectoutlns = {}
--[[ format:
	rects[id] = {
		w = 100,
		h = 100,
		x = 0,
		y = 0,
		color = {0.4, 0.2, 0.2, 0.5},
		thick = 3,
	}
]]

local floor = math.floor
local abs = math.abs
local cos = math.cos
local sin = math.sin
local tan = math.tan
local asin = math.asin
local acos = math.acos
local atan = math.atan
local rad = math.rad
local tins = table.insert
local rand = math.random
local sqrt = math.sqrt
local PI = math.pi

local function calchyp (a, b)
	local c = sqrt(a^2 + b^2)
	return c
end

local function findangle (x1, y1, x2, y2)
	-- get relative coords
	local dx = x2 - x1
	local dy = y2 - y1
	-- make 0 - 1 range
	local hyp = calchyp(dx, dy)

	local ancos = dx / hyp
	if ancos == 1 then
		return 0
	end
	if ancos == -1 then
		return PI
	end

	local ansin = dy / hyp
	local angle = acos(ancos)
	if ansin < 0 then
		return -angle
	else
		return angle
	end
end

local function genrects ()

	local floor = math.floor
	local cos = math.cos
	local sin = math.sin
	local rad = math.rad
	local tins = table.insert

	math.randomseed(floor(gettime() * 1000) % 1327)
	local rand = math.random
	rand()
	rand()

	local interv = 20
	local scolor = 0.1
	local ecolor = 0.9
	local elwidth = 10
	local elheight = 15
	local colorgrad = (ecolor - scolor) / elwidth
	local flareradius = 8
	local rangle = 30
	local ox = 155
	local oy = 95
	local xoffset = 130
	local yoffset = 60

	local greenflares = {}
	while #greenflares < 15 do
		local x = floor(rand() * elwidth)
		local y = floor(rand() * elheight)

		local found = false
		for i, v in ipairs(greenflares) do
			if v.x == x and v.y == y then
				found = true
				break
			end
		end
		if not found then
			tins(greenflares, { x = x, y = y })
		end
	end

	for ely = 1, elheight do
		for elx = 1, elwidth do

			local x = xoffset + (elx - 1) * interv
			local y = yoffset + (ely - 1) * interv

			-- do NOT rotate
			if false then
				
				local curangle = findangle(ox, oy, x, y)
				local tarangle = curangle + PI / 6
				local r = calchyp(x - ox, y - oy)
				x = ox + r * cos(tarangle)
				y = oy + r * sin(tarangle)
			end

			local rcolor = scolor + colorgrad * elx

			local gcolor = 0.2
			do
				local nearestflare = nil
				for i, v in ipairs(greenflares) do
					local dx = math.abs(v.x - elx)
					local dy = math.abs(v.y - ely)
					local hyp = math.sqrt(dx^2 + dy^2)
					if not nearestflare
					or nearestflare > hyp
					then
						nearestflare = hyp
					end
				end
				if nearestflare < flareradius then
					local gincrease = 0.75 * ((flareradius - nearestflare) / flareradius)
					gcolor = gcolor + gincrease
				end
			end

			local bcolor = 0.2
			if rand() > 0.9 then
				bcolor = 0.1 + rand() % 0.7
			end

			rects[x .. "x" .. y .. "rect"] = {
				w = 8,
				h = 8,
				x = x + 1,
				y = y + 1,
				color = { rcolor, gcolor, bcolor, 1 },
			}

			rectoutlns[x .. "x" .. y .. "rectol"] = {
				w = 10,
				h = 10,
				x = x,
				y = y,
				thick = 1,
				color = { 0.9, 0.9, 0.9, 0.8 },
			}

		end
	end
end

local function genrectsr ()

	local floor = math.floor
	local cos = math.cos
	local sin = math.sin
	local rad = math.rad
	local tins = table.insert

	math.randomseed(floor(gettime() * 1000) % 1327)
	local rand = math.random
	rand()
	rand()

	local interv = 20
	local scolor = 0.1
	local ecolor = 0.9
	local elwidth = 10
	local elheight = 15
	local colorgrad = (ecolor - scolor) / elwidth
	local flareradius = 8
	local rangle = rad(15)
	local ox = 555
	local oy = 85
	local xoffset = 530
	local yoffset = 60

	local greenflares = {}
	while #greenflares < 15 do
		local x = floor(rand() * elwidth)
		local y = floor(rand() * elheight)

		local found = false
		for i, v in ipairs(greenflares) do
			if v.x == x and v.y == y then
				found = true
				break
			end
		end
		if not found then
			tins(greenflares, { x = x, y = y })
		end
	end

	for ely = 1, elheight do
		for elx = 1, elwidth do

			local x = xoffset + (elx - 1) * interv
			local y = yoffset + (ely - 1) * interv

			-- rotate
			if true then
				
				local curangle = findangle(ox, oy, x, y)
				local tarangle = curangle + rangle
				local r = calchyp(x - ox, y - oy)
				x = ox + r * cos(tarangle)
				y = oy + r * sin(tarangle)
			end

			local rcolor = scolor + colorgrad * elx

			local gcolor = 0.2
			do
				local nearestflare = nil
				for i, v in ipairs(greenflares) do
					local dx = math.abs(v.x - elx)
					local dy = math.abs(v.y - ely)
					local hyp = math.sqrt(dx^2 + dy^2)
					if not nearestflare
					or nearestflare > hyp
					then
						nearestflare = hyp
					end
				end
				if nearestflare < flareradius then
					local gincrease = 0.75 * ((flareradius - nearestflare) / flareradius)
					gcolor = gcolor + gincrease
				end
			end

			local bcolor = 0.2
			if rand() > 0.9 then
				bcolor = 0.1 + rand() % 0.7
			end

			rects[x .. "x" .. y .. "rect"] = {
				w = 8,
				h = 8,
				x = x + 1,
				y = y + 1,
				color = { rcolor, gcolor, bcolor, 1 },
			}

			rectoutlns[x .. "x" .. y .. "rectol"] = {
				w = 10,
				h = 10,
				x = x,
				y = y,
				thick = 1,
				color = { 0.9, 0.9, 0.9, 0.8 },
			}

		end
	end
end

function love.load ()
	genrects()
	genrectsr()
end

function love.update (dt)

	schedfood = schedfood + dt
	reloadfood = reloadfood + dt

	if schedfood > 1 then
		schedfood = 1
	end
	if reloadfood > 1 then
		reloadfood = 1
	end
	if schedfood >= 0.04 then
		schedfood = schedfood - 0.4
		sched.exec()
	end
	if reloadfood >= 0.1 then
		reloadfood = reloadfood - 0.1
		--love.load()
	end

	local keydown = love.keyboard.isDown
	if keydown("left") then
	end
	if keydown("right") then
	end
	if keydown("up") then
	end
	if keydown("down") then
	end
end

function love.keypressed (key, scancode, isrepeat)
	if key == "escape" then
		os.exit()
	end
	if key == "r" then
		love.load()
	end
end

function love.draw ()
	local rect = love.graphics.rectangle
	local color = love.graphics.setColor
	local linew = love.graphics.setLineWidth
	for i, v in pairs(rects) do
		color(table.unpack(v.color))
		rect("fill", v.x, v.y, v.w, v.h)
	end
	for i, v in pairs(rectoutlns) do
		color(table.unpack(v.color))
		linew(v.thick)
		rect("line", v.x, v.y, v.w, v.h)
	end
end


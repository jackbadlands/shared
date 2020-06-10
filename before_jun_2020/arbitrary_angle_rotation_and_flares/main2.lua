local sched = require "scheduler"
local socket = require "socket"
local invoke = require "invoke"

local gettime = socket.gettime
local after = sched.after

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
	math.randomseed(floor(gettime() * 1000) % 1327)
	rand()
	rand()

	X = 100
	Y = 100

	rects["orect"] = {
		w = 8,
		h = 8,
		x = X,
		y = X,
		color = { 0.9, 0.2, 0.2, 1 },
	}

	rects["rrect"] = {
		w = 8,
		h = 8,
		x = X + 100,
		y = Y,
		color = { 0.2, 0.9, 0.2, 1 },
	}

	local x = X
	local y = Y
	local r = 100
	local ox = X
	local oy = Y
	local rx = x + r * cos(rad(-90))
	local ry = y + r * sin(rad(-90))

	rects["grect"] = {
		w = 8,
		h = 8,
		x = rx,
		y = ry,
		color = { 0.2, 0.2, 0.9, 1 },
	}

	local ang = findangle(x, y, rx, ry)
	print("angle found: "..ang)
	local rx1 = x + r * cos(ang)
	local ry1 = y + r * sin(ang)

	rects["grectsmall"] = {
		w = 4,
		h = 4,
		x = rx1,
		y = ry1,
		color = { 0.9, 0.9, 0.2, 1 },
	}

	local rx1 = x + r * cos(ang + PI / 6)
	local ry1 = y + r * sin(ang + PI / 6)

	rects["grectsmall2"] = {
		w = 4,
		h = 4,
		x = rx1,
		y = ry1,
		color = { 0.9, 0.9, 0.2, 1 },
	}

	local rx1 = x + r * cos(ang + (PI / 6) * 2)
	local ry1 = y + r * sin(ang + (PI / 6) * 2)

	rects["grectsmall3"] = {
		w = 4,
		h = 4,
		x = rx1,
		y = ry1,
		color = { 0.9, 0.9, 0.2, 1 },
	}

end

function love.load ()
	genrects()
end

function love.update (dt)
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


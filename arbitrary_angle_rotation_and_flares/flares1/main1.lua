local sched = require "scheduler"
local socket = require "socket"
local invoke = require "invoke"

local gettime = socket.gettime
local after = sched.after

local schedfood = 0
local objs = {}
local sel = 1

local function newrect ()
	local q = {
		t = "rect",
		w = 100,
		h = 100,
		x = 0,
		y = 0,
		color = {0.4, 0.2, 0.2, 0.5},
	}
	if objs[sel] then
		q.x = objs[sel].x
		q.y = objs[sel].y
	end
	table.insert(objs, q)
	sel = #objs
end

local keymap = {
	escape = function ()
		os.exit()
	end,
	n = function ()
		invoke(newrect)
	end,
}

local movespeed = 160
local moveleft = function (dt)
	if objs[sel] then
		objs[sel].x = objs[sel].x - movespeed * dt
	end
end
local moveright = function (dt)
	if objs[sel] then
		objs[sel].x = objs[sel].x + movespeed * dt
	end
end
local moveup = function (dt)
	if objs[sel] then
		objs[sel].y = objs[sel].y - movespeed * dt
	end
end
local movedown = function (dt)
	if objs[sel] then
		objs[sel].y = objs[sel].y + movespeed * dt
	end
end

function love.load ()
	-- nothing onload
end

function love.update (dt)

	schedfood = schedfood + dt

	if schedfood > 1 then
		schedfood = 1
	end
	if schedfood >= 0.04 then
		schedfood = schedfood - 0.4
		sched.exec()
	end

	local keydown = love.keyboard.isDown
	if keydown("left") then
		moveleft(dt)
	end
	if keydown("right") then
		moveright(dt)
	end
	if keydown("up") then
		moveup(dt)
	end
	if keydown("down") then
		movedown(dt)
	end
end

function love.keypressed (key, scancode, isrepeat)
	if keymap[key] then
		invoke(keymap[key])
	end
end

function love.draw ()
	local rect = love.graphics.rectangle
	local color = love.graphics.setColor
	for i, v in ipairs(objs) do
		if v.t == "rect" then
			color(table.unpack(v.color))
			rect("fill", v.x, v.y, v.w, v.h)
		end
	end
end


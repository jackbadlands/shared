local coordconv = require "coordconv"

function drawrect (xofst, yofst, w, h)
	local RECTW, RECTH = 100, 100
	local sx, sy, mx, my = coordconv.scalecontain(w, h, RECTW, RECTH)
	love.graphics.setColor(54, 192, 64)
	love.graphics.rectangle("fill", xofst, yofst, RECTW, RECTH)
	love.graphics.setColor(224, 224, 224)
	local draww = w * sx
	local drawh = h * sy
	love.graphics.rectangle("fill", xofst + mx, yofst + my, draww, drawh)
end

function drawrectzoom (xofst, yofst, w, h)
	local RECTW, RECTH = 100, 100
	local sx, sy, mx, my = coordconv.scalezoom(w, h, RECTW, RECTH)
	love.graphics.setColor(224, 224, 224)
	local draww = w * sx
	local drawh = h * sy
	love.graphics.rectangle("fill", xofst + mx, yofst + my, draww, drawh)
	love.graphics.setColor(64, 192, 64)
	love.graphics.rectangle("fill", xofst, yofst, RECTW, RECTH)
end

function love_draw_contain ()
	drawrect(10 + 105 * 0, 10 + 105 * 0, 30, 20)
	drawrect(10 + 105 * 1, 10 + 105 * 0, 20, 30)
	drawrect(10 + 105 * 2, 10 + 105 * 0, 40, 40)
	drawrect(10 + 105 * 0, 10 + 105 * 1, 40, 40)
	drawrect(10 + 105 * 0, 10 + 105 * 1, 20, 40)
end

function love_draw_zoom ()
	drawrectzoom(60 + 205 * 0, 60 + 205 * 0, 30, 20)
	drawrectzoom(60 + 205 * 1, 60 + 205 * 0, 20, 30)
	drawrectzoom(60 + 205 * 2, 60 + 205 * 0, 40, 40)
	drawrectzoom(60 + 205 * 0, 60 + 205 * 1, 40, 40)
	drawrectzoom(60 + 205 * 0, 60 + 205 * 1, 20, 40)
end

love.draw = love_draw_contain

function love.keypressed ()
	if love.draw == love_draw_contain then
		love.draw = love_draw_zoom
	else
		love.draw = love_draw_contain
	end
end


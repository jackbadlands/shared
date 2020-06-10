love.widget = require "lovewidget"
love.ui = require "loveui"

local st = {}

st.scissoractive = true

function love.load()

	local function drawcb(uiobj, data, absx, absy, cx, cy, cw, ch)
		love.graphics.setColor(data.r, data.g, data.b, data.a)
		if st.scissoractive then
			love.graphics.setScissor(cx, cy, cw, ch)
		end
		love.graphics.rectangle("fill", absx, absy, uiobj.w, uiobj.h)
		if st.scissoractive then
			love.graphics.setScissor()
		end
		return true
	end
	local function eventcb(uiobj, data, relx, rely, event)
		if event == "hover" then
			data.hr = data.r
			data.hg = data.g
			data.hb = data.b
			data.ha = data.a
			data.r = 100
			data.g = 100
			data.b = 100
		elseif event == "leave" then
			data.r = data.hr
			data.g = data.hg
			data.b = data.hb
			data.a = data.ha
		end
		return true
	end

	st.screenwidget = love.ui.new(400, 400)
	st.screenwidget:insert(10, 10,
		love.ui.new(100, 100, {r = 255, g = 0, b = 0, a = 128}, drawcb, eventcb))
	st.screenwidget:insert(30, 30,
		love.ui.new(100, 100, {r = 255, g = 255, b = 0, a = 128}, drawcb, eventcb))
	st.screenwidget:insert(370, 370,
		love.ui.new(100, 100, {r = 255, g = 0, b = 255, a = 128}, drawcb, eventcb))
	st.screenwidget:insert(370, 40,
		love.ui.new(100, 100, {r = 0, g = 0, b = 255, a = 128}, drawcb, eventcb))
	st.screenwidget:insert(-50, 120,
		love.ui.new(100, 100, {r = 255, g = 0, b = 0, a = 128}, drawcb, eventcb))

	local rect1 = love.ui.new(100, 100, {r = 0, g = 0, b = 255, a = 128}, drawcb, eventcb)
	local rect2 = love.ui.new(50, 50, {r = 0, g = 0, b = 255, a = 128}, drawcb, eventcb)
	rect1:insert(20, 20, rect2)
	st.screenwidget:insert(270, 270, rect1)
end

-- Input handling -----------------

function love.keypressed(k)
	if k == "up" then
		st.dy = st.dy - 10
	end
	if k == "down" then
		st.dy = st.dy + 10
	end
	if k == "left" then
		st.dx = st.dx - 10
	end
	if k == "right" then
		st.dx = st.dx + 10
	end

	if k == " " then
		st.scissoractive = not st.scissoractive
	end

	if k == "q"
	or k == "escape" then
		os.exit()
	end
end

function love.mousepressed(x, y, key)
end
 
function love.update(dt)
	local x, y = love.mouse.getPosition()
	if st.moldx then
		st.screenwidget:sendEvent(st.moldx, st.moldy, "leave")
	end
	st.screenwidget:sendEvent(x, y, "hover")
	st.moldx = x
	st.moldy = y
end
 
-- Drawing scene ------------------

function love.draw()
	st.screenwidget:draw(5, 0, 0, 0, love.window.getWidth(), love.window.getHeight())
end


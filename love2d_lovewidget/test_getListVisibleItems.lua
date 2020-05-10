love.widget = require "lovewidget"

local st = {}

-- Startup ------------------------

function love.load()
	st.list = { 1, 2, 3, 4, 5,
		"asd", "ccxcxc", "zzxzxxz" }
	st.scroll = 0
	st.itemheight = 40
	st.viewheight = 100
end

-- Input handling -----------------

function love.keypressed(k)

	if k == "down" then
		st.scroll = st.scroll + 6
		if st.scroll > st.itemheight * (#st.list - 1) then
			st.scroll = st.itemheight * (#st.list - 1)
		end
	end
	if k == "up" then
		st.scroll = st.scroll - 6
		if st.scroll < 0 then
			st.scroll = 0
		end
	end

	-- Escape condition
	if k == "q"
	or k == "escape" then
		os.exit()
	end
end
 
function love.update(dt)

end
 
-- Drawing scene ------------------

function love.draw()
	local fi, li = love.widget.getListVisibleItems(st.viewheight, st.itemheight, st.scroll)
	love.graphics.setColor(255,40,20)
	love.graphics.print(tostring(fi).." "..tostring(li).." "..tostring(st.scroll), 10, 10)
	love.graphics.setColor(40,40,40)
	love.graphics.rectangle("fill", 40, 50, 300, st.viewheight)
	
	for i = fi, li do
		local ypos = (i - 1) * st.itemheight - st.scroll
		if st.list[i] then
			love.graphics.setColor(128,40,128, 128)
			love.graphics.rectangle("fill", 40, ypos + 50, 300, st.itemheight - 2)
			love.graphics.setColor(255,255,255, 255)
			love.graphics.print(tostring(i)..": "..st.list[i], 40, ypos + 50)
		end
	end
end


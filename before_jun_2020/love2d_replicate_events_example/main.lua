local Elements = {}
local e = Elements

for _, eventname in pairs {

	"keypressed",
	"keyreleased",
	"textinput",

	"mousepressed",
	"mousereleased",
	"mousemoved",
	"touchpressed",
	"touchreleased",
	"touchmoved",
	"wheelmoved",

	"directorydropped",
	"filedropped",

	"quit",
	"mousefocus",
	"focus",
	"resize",
	"visible",

	"threaderror",

	"update",
	"draw",
} do
	love[eventname] = function(...)
		for element, _ in pairs(Elements) do
			if type(element[eventname]) == "function" then
				element[eventname](element, ...)
			end
		end
	end
end

function love.load ()

	local drawmgr = {}
	local button = {}
	local progressbar = {}
	local programcontrol = {}

	-- drawmgr config
	function drawmgr:draw ()
		for idx, drawable in pairs { button, progressbar } do
			-- print("drawmgr:draw()") -- DEBUG
			if drawable.type == "progressbar" then
				love.graphics.setColor(drawable.r,
						drawable.g, drawable.b, drawable.a)
				love.graphics.rectangle("fill",
						drawable.x,
						drawable.y,
						drawable.w * (drawable.cur / drawable.max),
						drawable.h
				)
				love.graphics.setLineWidth(2)
				love.graphics.rectangle("line",
						drawable.x,
						drawable.y,
						drawable.w,
						drawable.h
				)
			elseif drawable.type == "textbutton" then
				love.graphics.setColor(drawable.bg.r,
						drawable.bg.g, drawable.bg.b, drawable.bg.a)
				love.graphics.rectangle("fill",
						drawable.bg.x,
						drawable.bg.y,
						drawable.bg.w,
						drawable.bg.h
				)
				love.graphics.setColor(drawable.text.r,
						drawable.text.g, drawable.text.b, drawable.text.a)
				love.graphics.draw(drawable.text.data,
						drawable.text.x, drawable.text.y)
			end
		end
	end

	-- button config
	button.type = "textbutton"
	button.bg = {
		r = 200,
		g = 20,
		b = 20,
		a = 255,
		x = 40,
		y = 300,
		w = 100,
		h = 40,
	}
	button.text = {
		r = 255,
		g = 255,
		b = 255,
		a = 255,
		x = 45,
		y = 305,
		data = love.graphics.newText(love.graphics.getFont(), "button1")
	}
	function button:keypressed(key)
		progressbar.cur = 0
	end

	-- progressbar config
	progressbar.type = "progressbar"
	progressbar.x = 10
	progressbar.y = 10
	progressbar.w = 250
	progressbar.h = 30
	progressbar.max = 100
	progressbar.cur = 0
	progressbar.r = 30
	progressbar.g = 230
	progressbar.b = 30
	progressbar.a = 255
	function progressbar:update (dt)
		self.cur = self.cur + 4 * dt
		if self.cur > self.max then
			self.cur = self.max
		end
	end

	-- programcontrol config
	function programcontrol:keyreleased(key)
		if key == "escape" then
			os.exit()
		end
	end

	e[drawmgr] = true
	e[progressbar] = true
	e[button] = true
	e[programcontrol] = true

end


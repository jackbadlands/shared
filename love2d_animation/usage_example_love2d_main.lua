local Animation = require "animation".new()

function love.load ()
	Animation:addFrame(1, function(self, t, progr)
		love.graphics.print(string.format("1 (%.1f%%)", progr * 100), 5, 5)
	end)
	Animation:addFrame(2, function(self, t, progr)
		love.graphics.print(string.format("2 (%.1f%%)", progr * 100), 5, 5)
	end)
	Animation:addFrame(5, function(self, t, progr)
		love.graphics.print(string.format("5 (%.1f%%) is_running: %s",
				progr * 100, Animation.IsRunning and "yes" or "no"), 5, 5)
	end)
end

function love.update (dt)
	Animation:update(dt)
end

function love.draw ()
	Animation:draw(dt)
end


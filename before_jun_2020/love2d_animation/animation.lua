local clonetable = require "clonetable"

local Animation = {
	Frames = {},
	IsCyclic = false,
	CurrentFrame = 1,
	TimeLeft = 0.5,
	update = function (self, dt)
		if #self.Frames > 0 then
			self.IsRunning = true
			while dt > 0 do
				if self.TimeLeft - dt > 0 then
					self.TimeLeft = self.TimeLeft - dt
					dt = 0
				else
					dt = dt - self.TimeLeft
					if self.CurrentFrame < #self.Frames then
						self.CurrentFrame = self.CurrentFrame + 1
						self.TimeLeft = self.Frames[self.CurrentFrame].duration
					else
						if self.IsCyclic then
							self.CurrentFrame = 1
							self.TimeLeft = self.Frames[1].duration
						else
							dt = 0
							self.TimeLeft = 0
							self.IsRunning = false
						end
					end
				end
			end
		else
			self.IsRunning = false
		end
	end,
	draw = function (self)
		if #self.Frames > 0 then
			local cur_frame = self.CurrentFrame
			local cur_duration = self.Frames[cur_frame].duration
			local cur_frame_time = cur_duration - self.TimeLeft
			local cur_frame_progress = cur_frame_time / cur_duration
			self.Frames[self.CurrentFrame]:draw(cur_frame_time, cur_frame_progress)
		end
	end,
	addFrame = function (self, duration, draw_cb)
		duration = assert(tonumber(duration))
		assert(draw_cb)
		table.insert(self.Frames, { duration = duration, draw = draw_cb })
	end,
	restart = function (self)
		self.CurrentFrame = 1
		self.TimeLeft = self.Frames[1].duration
	end,
	clearFrames = function (self)
		self.Frames = {}
		self.CurrentFrame = nil
		self.TimeLeft = nil
	end,
	new = function (self)
		return clonetable(Animation)
	end,
	clone = function (self)
		return clonetable(self)
	end,
}

return {
	new = function ()
		return clonetable(Animation)
	end,
}


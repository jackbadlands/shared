local clonetable = require "clonetable"
local widget = require "lovewidget"

local UIObjectProto = {}

UIObjectProto._SIGN = "UIObject for Love2d engine v1"
UIObjectProto.w = 0
UIObjectProto.h = 0
UIObjectProto.event_cb = nil
UIObjectProto.draw_cb = nil
UIObjectProto.data = nil
UIObjectProto.insertedx = {}
UIObjectProto.insertedy = {}

function UIObjectProto:insert(x, y, what)
	if self._SIGN ~= UIObjectProto._SIGN then
		error("LoveUI:insert(): Cannot insert into not UI object")
	end
	if what._SIGN ~= UIObjectProto._SIGN then
		error("LoveUI:insert(): Cannot insert not UI object")
	end
	self.insertedx[what] = assert(tonumber(x))
	self.insertedy[what] = assert(tonumber(y))
	return true
end
function UIObjectProto:sendEvent(x, y, event, myabsx, myabsy)
	myabsx = tonumber(myabsx) or 0
	myabsy = tonumber(myabsy) or 0
	local evrelx, evrely = widget.relativeXY(myabsx, myabsy, x, y)
	if widget.doesRectsIntersects(0, 0, self.w, self.h,
				evrelx, evrely, 1, 1) then
		local handled = false
		for inobj, inx in pairs(self.insertedx) do
			local iny = self.insertedy[inobj]
			if inobj:sendEvent(evrelx, evrely, event, inx, iny) then
				handled = true
			end
		end
		if handled then
			return true
		end
		if type(self.event_cb) == "function" then
			if self.event_cb(self, self.data, evrelx, evrely, event) then
				return true
			end
		end
	end
	return false
end
function UIObjectProto:draw(x, y, cropx, cropy, cropw, croph)
	local cx, cy, cw, ch = widget.getRectsIntersection(
			assert(tonumber(x)),
			assert(tonumber(y)),
			assert(tonumber(self.w)),
			assert(tonumber(self.h)),
			assert(tonumber(cropx)),
			assert(tonumber(cropy)),
			assert(tonumber(cropw)),
			assert(tonumber(croph)))
	if cx then
		if type(self.draw_cb) == "function" then
			self.draw_cb(self, self.data, x, y, cx, cy, cw, ch)
		end
		for inobj, inx in pairs(self.insertedx) do
			local iny = self.insertedy[inobj]
			local inabsx, inabsy = widget.translateXY(x, y, inx, iny)
			inobj:draw(inabsx, inabsy, cx, cy, cw, ch)
		end
	end
	return true
end

local public = {}

function public.new(w, h, data, draw_cb, event_cb)
	local new = clonetable(UIObjectProto)
	new.w = assert(tonumber(w))
	new.h = assert(tonumber(h))
	new.data = data -- Object data
	new.event_cb = event_cb -- event_handler(uiobj, data, relx, rely, event)
	new.draw_cb = draw_cb -- draw_handler(uiobj, data, absx, absy, cropx, cropy, cropw, croph)
	return new
end

return public


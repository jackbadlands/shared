local m = {}

local clonetable = require "clonetable"
local stripppmcomments = require "stripppmcomments"

local proto = {}

function proto:getPixel (x, y)
	local r = self.data[(y * self.width * 3 + x * 3) + 1]
	local g = self.data[(y * self.width * 3 + x * 3) + 2]
	local b = self.data[(y * self.width * 3 + x * 3) + 3]
	return tonumber(r), tonumber(g), tonumber(b)
end

function proto:setPixel (x, y, r, g, b)
	self.data[(y * self.width * 3 + x * 3) + 1] = r
	self.data[(y * self.width * 3 + x * 3) + 2] = g
	self.data[(y * self.width * 3 + x * 3) + 3] = b
end


function proto:load (filename)

	assert(filename)

	stripppmcomments(filename)

	local fd = assert(io.open(filename, "rb"))
	local filedata = assert(fd:read("*a"))
	fd:close()
	
	local sig, width, height, maxval, bdata =
		string.match(filedata, "^(P6)%s+(%d+)%s+(%d+)%s+(%d+)\n(.*)")

	if not sig then
		return nil, "error while parsing file"
	end

	self.width = tonumber(width)
	self.height = tonumber(height)
	self.maxvalue = tonumber(maxval)
	self.data = {}

	--print("bdata size:", #bdata)

	for y = 0, self.height - 1 do
		for x = 0, self.width - 1 do
			local o = (y * self.width * 3) + (x * 3) + 1
			local r, g, b = string.byte(bdata, o, o+3)
			self:setPixel(x, y, tonumber(r), tonumber(g), tonumber(b))
		end
	end
end

function proto:store (filename)

	assert(filename)
	
	-- conv data back to bin format
	local bdata = {}
	for i, c in ipairs(self.data) do
		table.insert(bdata, string.char(c))
	end
	local bdata_s = table.concat(bdata, "")

	-- gen filedata string
	local fdata_s = string.format("P6\n%d %d\n%d\n%s",
			self.width, self.height, self.maxvalue, bdata_s)

	-- write filedata string to file
	local fd = assert(io.open(filename, "wb"))
	assert(fd:write(fdata_s))
	assert(fd:close())
end


function m.new ()
	return clonetable(proto)
end

function m.load (fname)
	local new = clonetable(proto)
	new:load(fname)
	return new
end

return m


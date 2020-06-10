local m = {}

local clonetable = require "clonetable"

local proto = {}

-- read word and whitespace. skip comments
local function readwordwssc (fd)
	local t = {}
	local wordbegin = false
	while true do
		local c = assert(fd:read(1))
		if string.match(c, "%s") then
			if wordbegin then
				break
			else
				-- skip
			end
		else
			if not wordbegin
			and string.match(c, "#")
			then
				while c ~= "\n" do
					c = assert(fd:read(1))
				end
			else
				table.insert(t, c)
				wordbegin = true
			end
		end
	end
	return table.concat(t, "")
end

function proto:load (filename)

	assert(filename)

	local fd = assert(io.open(filename, "rb"))
	
	local sig = readwordwssc(fd)
	local width = tonumber(readwordwssc(fd))
	local height = tonumber(readwordwssc(fd))
	local maxval = tonumber(readwordwssc(fd))

	if sig ~= "P6" then
		return nil, "cannot recognize file type"
	end

	self.width = tonumber(width)
	self.height = tonumber(height)
	self.maxvalue = tonumber(maxval)
	self.r = {}
	self.g = {}
	self.b = {}

	for y = 0, self.height - 1 do
		for x = 0, self.width - 1 do
			self.r[y] = self.r[y] or {}
			self.g[y] = self.g[y] or {}
			self.b[y] = self.b[y] or {}
			self.r[y][x] = string.byte(assert(fd:read(1)))
			self.g[y][x] = string.byte(assert(fd:read(1)))
			self.b[y][x] = string.byte(assert(fd:read(1)))
		end
	end

	return true
end

function proto:new (w, h, r, g, b)
	assert(w)
	assert(h)
	r = r or 0
	g = g or 0
	b = b or 0

	self.width = tonumber(w)
	self.height = tonumber(h)
	self.maxvalue = 255
	self.r = {}
	self.g = {}
	self.b = {}

	for y = 0, self.height - 1 do
		for x = 0, self.width - 1 do
			self.r[y] = self.r[y] or {}
			self.g[y] = self.g[y] or {}
			self.b[y] = self.b[y] or {}
			self.r[y][x] = r
			self.g[y][x] = g
			self.b[y][x] = b
		end
	end

	return true
end

function proto:store (filename)

	assert(filename)
	
	-- gen filedata string
	local fdata_h = string.format("P6\n%d %d\n%d\n",
			self.width, self.height, self.maxvalue)

	-- write filedata string to file
	local fd = assert(io.open(filename, "wb"))
	assert(fd:write(fdata_h))
	for y = 0, self.height - 1 do
		for x = 0, self.width - 1 do
			local r = string.char(self.r[y][x])
			assert(fd:write(r))
			local g = string.char(self.g[y][x])
			assert(fd:write(g))
			local b = string.char(self.b[y][x])
			assert(fd:write(b))
		end
	end
	assert(fd:close())
end

function proto.drawrect (img, x, y, w, h, r, g, b, filled)
	if filled then
		for iy = y, y + h do
			for ix = x, x + w do
				img.r[iy][ix] = r
				img.g[iy][ix] = g
				img.b[iy][ix] = b
			end
		end
	else
		for iy = y, y + h do
			img.r[iy][x] = r
			img.g[iy][x] = g
			img.b[iy][x] = b

			img.r[iy][x + w] = r
			img.g[iy][x + w] = g
			img.b[iy][x + w] = b
		end

		for ix = x, x + w do
			img.r[y][ix] = r
			img.g[y][ix] = g
			img.b[y][ix] = b

			img.r[y + h][ix] = r
			img.g[y + h][ix] = g
			img.b[y + h][ix] = b
		end
	end
	return true
end

function proto.getsubimage (img, x, y, w, h)
	local new = m.new(w, h)
	for j = 0, h - 1 do
		for i = 0, w - 1 do
			local sx = x + i
			local sy = y + j
			local tx = i
			local ty = j
			new.r[ty][tx] = img.r[sy][sx]
			new.g[ty][tx] = img.g[sy][sx]
			new.b[ty][tx] = img.b[sy][sx]
		end
	end
	return new
end

function proto.pasteimage (img, subimg, x, y)
	for j = 0, subimg.height - 1 do
		for i = 0, subimg.width - 1 do
			local tx = x + i
			local ty = y + j
			local sx = i
			local sy = j
			img.r[ty][tx] = subimg.r[sy][sx]
			img.g[ty][tx] = subimg.g[sy][sx]
			img.b[ty][tx] = subimg.b[sy][sx]
		end
	end
	return true
end

function m.new (...)
	local new = clonetable(proto)
	new:new(...)
	return new
end

function m.load (fname)
	local new = clonetable(proto)
	new:load(fname)
	return new
end

return m


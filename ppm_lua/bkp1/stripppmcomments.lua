local function stripppmcomments (fname)
	local fd = assert(io.open(fname, "rb"))
	local firstline = string.upper(assert(fd:read("*l")))
	if firstline ~= "P6" and firstline ~= "P3" then
		return
	end
	local line = assert(fd:read("*l"))
	while string.match(line, "^%s*#.*$") do
		line = assert(fd:read("*l"))
	end
	local restofdata = assert(fd:read("*a"))
	assert(fd:close())
	local fd = assert(io.open(fname, "wb"))
	assert(fd:write(string.format("%s\n%s\n%s", firstline, line, restofdata)))
	assert(fd:close())
end

return stripppmcomments


local function readfile (fname)
	local fd = assert(io.open(fname, "rb"))
	local data = assert(fd:read("*a"))
	assert(fd:close())
	return data
end

local function mexpand (str, S)
	S = S or {}
	local concatlinebuf = {}
	local out = {}
	local function subst (line)
		local ret
		repeat
			local changed = false
			ret = string.gsub(line, "([%$%w%d_]+)", function(word)
				if S[word] then
					changed = true
					return tostring(S[word])
				else
					return word
				end
			end)
			if changed then
				line = ret
			end
		until not changed
		return ret
	end
	local function processdirective (directive)
		local inc_fname = string.match(directive, "%s*include%s([^\r\n]+)\r?\n?$")
		if inc_fname then
			return mexpand(readfile(inc_fname), S)
		end
		local k, v = string.match(directive,
				"%s*define%s+([%$%w%d_]+)%s([^\r\n]+)\r?\n?$")
		if k and v then
			S[k] = v
			return ""
		end
		local u = string.match(directive, "%s*undef%s+([%$%w%d_]+)\r?\n?$")
		if u then
			S[u] = nil
			return ""
		end
		error(string.format("unknown directive: @%q", directive))
	end
	for line in string.gmatch(str, "([^\n]*\n?)") do
		local bareline = string.match(line, "(.*)\\\r?\n?$")
		if bareline then
			table.insert(concatlinebuf, bareline)
		else
			if #concatlinebuf > 0 then
				table.insert(concatlinebuf, line)
				line = table.concat(concatlinebuf, "")
				concatlinebuf = {}
			end
			local directive = string.match(line, "^@(.*)")
			if directive then
				table.insert(out, processdirective(directive))
			else
				table.insert(out, subst(line))
			end
			--print(string.format("%q", line))
		end
	end
	return table.concat(out, "")
end

print(mexpand(readfile(arg[1]), {
	__DATE__ = os.date(),
	__LUAVER__ = _G._VERSION,
}))


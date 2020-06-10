table.unpack = table.unpack or unpack

local callentered = false
local callqueue = {}

local function callexec_ ()
	callentered = true
	while #callqueue > 0 do
		local collected = callqueue
		callqueue = {}
		for i, v in ipairs(collected) do
			local func = v[1]
			local args = v[2]
			func(table.unpack(args))
		end
	end
	callentered = false
  return true
end

local function invoke (func, ...)
  table.insert(callqueue, {func, {...}})
  if not callentered then
    callexec_()
  end
  return true
end

return invoke


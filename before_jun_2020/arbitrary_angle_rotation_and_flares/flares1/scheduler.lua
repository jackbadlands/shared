local M = {}

socket = require "socket"
gettime = socket.gettime
sleep = socket.sleep
table.unpack = table.unpack or unpack

local timeouts = {}

function M.after (timeout, func, ...)
	assert(timeout)
	assert(func)
	local curtime = gettime()
	local waketime = curtime + timeout
	return M.at(waketime, func, ...)
end

function M.at (time, func, ...)
	assert(time)
	assert(func)
	table.insert(timeouts, { time, func, {...} })
end

function M.exec ()
	local collected = timeouts
	timeouts = {}
	local curtime = gettime()

	for i, v in ipairs(collected) do
		local at = v[1]
		local func = v[2]
		local args = v[3]
		if at <= curtime then
			 func(table.unpack(args))
		else
			table.insert(timeouts, v)
		end
	end
end

function M.loop (interval)
	interval = interval or 0.1
	while true do
		M.exec()
		sleep(interval)
	end
end

return M


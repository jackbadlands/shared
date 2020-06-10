--[[

	module description:
		finite state machine + scheduler  module, version 4

	usage:
		m:after(delay, func, arg1) - branch to next func after delay
		(use delay = 0 to call func as fast as possible)

]]

local gettime = require "socket".gettime
local sleep = require "socket".sleep
local clonetable = require "clonetable"
table.unpack = unpack or table.unpack

local NIL = {}

local function push7 (t, a, b, c, d, e, f, g)
	if a == nil then a = NIL end
	if b == nil then b = NIL end
	if c == nil then c = NIL end
	if d == nil then d = NIL end
	if e == nil then e = NIL end
	if f == nil then f = NIL end
	if g == nil then g = NIL end
	table.insert(t, a)
	table.insert(t, b)
	table.insert(t, c)
	table.insert(t, d)
	table.insert(t, e)
	table.insert(t, f)
	table.insert(t, g)
end

local function pop7 (t)
	if #t < 7 then
		error("too few data")
	end
	local g = table.remove(t)
	local f = table.remove(t)
	local e = table.remove(t)
	local d = table.remove(t)
	local c = table.remove(t)
	local b = table.remove(t)
	local a = table.remove(t)
	if a == NIL then a = nil end
	if b == NIL then b = nil end
	if c == NIL then c = nil end
	if d == NIL then d = nil end
	if e == NIL then e = nil end
	if f == NIL then f = nil end
	if g == NIL then g = nil end
	return a, b, c, d, e, f, g
end

local function try7 (t)
	if #t < 7 then
		error("too few data")
	end
	local top = #t
	local a = t[top - 6]
	local b = t[top - 5]
	local c = t[top - 4]
	local d = t[top - 3]
	local e = t[top - 2]
	local f = t[top - 1]
	local g = t[top - 0]
	if a == NIL then a = nil end
	if b == NIL then b = nil end
	if c == NIL then c = nil end
	if d == NIL then d = nil end
	if e == NIL then e = nil end
	if f == NIL then f = nil end
	if g == NIL then g = nil end
	return a, b, c, d, e, f, g
end

local proto = {
	curtasks = {},
	nexttasks = {},
	shouldrun = true, -- set this to false to exit proto:loop()
}

function proto:after (delay, func, a, b, c, d, e)
	delay = assert(tonumber(delay), "wrong delay value")
	assert(func, "func is not specified")
	local curtime = gettime()
	local waketime = curtime + delay
	push7(self.nexttasks, waketime, func, a, b, c, d, e)
end

function proto:step ()
	local curtime = gettime()
	self.curtasks, self.nexttasks =
			self.nexttasks, self.curtasks
	local c = self.curtasks
	local n = self.nexttasks
	local callcount = 0
	local taskcount = 0
	local pos_count = 0
	local neg_count = 0
	while #c > 0 do
		taskcount = taskcount + 1
		local wt, f, a, b, c, d, e = pop7(c)
		if wt <= curtime then
			if f(a, b, c, d, e) then
				pos_count = pos_count + 1
			else
				neg_count = neg_count + 1
			end
			callcount = callcount + 1
		else
			push7(n, wt, f, a, b, c, d, e)
		end
	end
	return pos_count, neg_count, callcount, taskcount
end

function proto:loop ()
	self.shouldrun = true
	while self.shouldrun do
		local _, _, cc = self:step()
		if cc == 0 then
			if #self.nexttasks == 0 then
				return
			end
			sleep(0.01)
		end
	end
end

return clonetable(proto)


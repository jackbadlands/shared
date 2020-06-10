#!/usr/bin/env lua

local public = {}

local socket = require "socket"
local gettime = socket.gettime
local sleep = socket.sleep
local rbtree = require "rbtree"
local eventtree = rbtree.new()
local eventsbytime = {}
local nexteventtime = gettime()

local function schedloop()

	nexteventtime = gettime()

	while true do

		-- Wait for step time
		local curtime = gettime()
		while curtime < nexteventtime do
			sleep(nexteventtime - curtime)
			curtime = gettime()
		end

		-- Call events
		for i, ev in pairs(eventsbytime[nexteventtime] or {}) do
			if type(ev) == "table"
			and type(ev.schedaction) == "function" then
				ev:schedaction(public, nexteventtime)
			end
		end

		-- Cleanup
		eventsbytime[nexteventtime] = nil
		local curevnode = eventtree:findNode(nexteventtime)
		if curevnode then
			eventtree:deleteNode(curevnode)
		end

		-- Search next time point
		local minnode = eventtree:getMinNode()
		if not minnode then
			return nil, "exhausted"
		end
		nexteventtime = eventtree:getNodeData(minnode)
	end
end

local function addevent(time, event)
	if not tonumber(time)
	or event == nil then
		error(string.format("scheduler.addevent(): wrong arguments: %s %s",
			tostring(time),
			tostring(event)))
	end
	local alreadyschednode = eventtree:findNode(time)
	if not alreadyschednode then
		eventtree:insertNode(time)
	end
	eventsbytime[time] = eventsbytime[time] or {}
	table.insert(eventsbytime[time], event)
	return true
end

local function interruptloop()
	eventtree = rbtree.new()
	eventsbytime = {}
end

local function schedgettime()
	return gettime()
end

public.loop = schedloop
public.addevent = addevent
public.interruptloop = interruptloop
public.gettime = schedgettime

return public


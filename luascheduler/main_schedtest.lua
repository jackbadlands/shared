#!/usr/bin/env lua

local sched = require "scheduler"

sched.addevent(sched.gettime() + 2, {
	schedaction = function(self, sched, time)
		print("------")

		sched.addevent(sched.gettime() - 1, {
			schedaction = function(self, sched, time)
				print("////")
				
			end
		})
	end
})

print(sched.loop())


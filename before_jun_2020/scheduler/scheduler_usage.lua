local sched = require "scheduler"
local after = sched.after

function delayed (i)
	print("i", i)
	if i < 5 then
		sched.after(0.3, delayed, i + 1)
	end
end

function delayed2 (i)
	print("2i", i)
	if i < 5 then
		sched.after(1, delayed2, i + 1)
	end
end

after(1, delayed, 1)
after(1, delayed2, 1)
after(10, os.exit)

sched.loop(0.01)


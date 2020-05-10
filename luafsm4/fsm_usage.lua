local fsm = require "fsm"

function after (...)
	fsm:after(...)
end

------------------------------------------

function print10 (state, string)
	if state.count < 4 then
		state.count = state.count + 1
		print(string)
		after(0, print10, state, string)
	end
end

after(0, print10, {count = 0}, "zzzz")
after(2, print, "aaa")
after(1, print10, {count = 2}, "bbb")

-- loop ----------------------------------

fsm:loop()


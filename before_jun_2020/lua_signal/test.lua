#!/usr/bin/lua

require "signal"
require "socket"

print("Registering SIGINT:", signal.register("SIGINT"))

local ints = 0

while true do
	local sigs_t = signal.check()
	if next(sigs_t) then
		print("Signals received:")
		for i, v in pairs(sigs_t) do
			print("", i, v)
		end
		print()
	end
	if sigs_t.SIGINT then
		ints = ints + sigs_t.SIGINT
		if ints > 10 then
			print("interrupted 10 or more times. terminating program")
			os.exit()
		end
	end
	socket.sleep(1)
end

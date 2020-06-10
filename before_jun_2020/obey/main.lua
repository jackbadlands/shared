local obey = require "obey"
local socket = require "socket"
local sleep = socket.sleep

obey:open(4040)
for i = 1, 60 do
	print("step", i)
	while obey:step() do end
	sleep(1)
end
obey:close()



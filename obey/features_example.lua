local obey = require "obey"
local socket = require "socket"
local sleep = socket.sleep

function obey:getPermissionHandler(ip, port, fenv, req, proof)
	if req == "print1" then
		fenv.print1 = function(...) print("--1-1-1", ...) end
		return true
	end
	return false
end

obey.basicfenv.HostName = "Super Egg"
obey.basicfenv.HostInfo = "My SuperEgg host. Home."

obey:listen(4040)



local p = {}

local socket = require "socket"
local clonetable = require "clonetable"

p.TaskTimeout = 0.5

p.basicfenv = {
	require = function() end,
}

p.ListeningIsEnabled = false

function p:requireHandler (ip, port, fenv, req, proof)
	return false
end

function p:listen (udp_port)
	self:open(udp_port)
	assert(self.usock:settimeout())
	self.ListeningIsEnabled = true
	repeat
		local data, ip, port = self.usock:receivefrom()
		if data and ip and port then
			self:handlerequest(data, ip, port)
		end	
	until not data or not p.ListeningIsEnabled
	self.ListeningIsEnabled = false
	print("listening is ended")
	assert(self.usock:settimeout(0))
end

function p:open (udp_port)
	local udp_port = assert(tonumber(udp_port))
	local usock = assert(socket.udp())
	assert(usock:setsockname("*", tonumber(udp_port)))
	assert(usock:settimeout(0))
	self:close()
	self.usock = usock
end

function p:close ()
	if self.usock then
		self.usock:close()
		self.usock = nil
	end
end

function p:step()
	assert(self.usock)
	local data, ip, port = self.usock:receivefrom()
	if data and ip and port then
		self:handlerequest(data, ip, port)
		return true
	else
		return false
	end	
end

function p:handlerequest(data, ip, port, fenv)
	
	local curfenv
	if type(fenv) == "table" then
		curfenv = fenv
	else
		curfenv = clonetable(self.basicfenv)
	end

	curfenv.require = function(req, proof)
		return self:requireHandler(ip, port, curfenv, req, proof)
	end

	local func = loadstring(data)

	if func then
		setfenv(func, curfenv)
	end

	local starttime = socket.gettime()

	local dbg_cb = function()
		local curtime = socket.gettime()
		if curtime - starttime > self.TaskTimeout then
			debug.sethook()
			print("terminated")
			error("timeout")
		end
	end

	debug.sethook(dbg_cb, "clr")
	local ok, descr = pcall(func)
	if not ok then
		print(descr)
	end
	debug.sethook()

end

return p



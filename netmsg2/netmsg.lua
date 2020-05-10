local p = {}

local socket = require "socket"
local usock = nil
local Routers = {}

p.DEBUG = true

local function touch_usock ()
	if not usock then
		usock = assert(socket.udp())
		assert(usock:setsockname("*", 0))
		assert(usock:settimeout(1))
	end
end

function p.reset ()
	if usock then
		usock:close()
	end
	usock = nil
end

function p.subscribe (routerip, routerport, name)
	touch_usock()

	if p.DEBUG then
		print("SUBSCRIBE", routerip, routerport, name)
		local pretty = require "pl.pretty"
		print("SUBSCR_ROUTERS_TAB_BEFORE", pretty.write(Routers))
	end

	usock:sendto("reg "..name, routerip, routerport)
	Routers[routerip] = Routers[routerip] or {}
	Routers[routerip][routerport] = Routers[routerip][routerport] or {}
	Routers[routerip][routerport][name] = true

	if p.DEBUG then
		local pretty = require "pl.pretty"
		print("SUBSCR_ROUTERS_TAB_AFTER", pretty.write(Routers))
	end
end
p.register = p.subscribe

function p.unsubscribe (routerip, routerport, name)
	touch_usock()

	if p.DEBUG then
		print("UNSUBSCRIBE", routerip, routerport, name)
		local pretty = require "pl.pretty"
		print("UNSUBSCR_ROUTERS_TAB_BEFORE", pretty.write(Routers))
	end

	usock:sendto("lve "..name, routerip, routerport)
	if Routers[routerip]
	and Routers[routerip][routerport]
	and Routers[routerip][routerport][name]
	then
		Routers[routerip][routerport][name] = nil
		if not next(Routers[routerip][routerport]) then
			Routers[routerip][routerport] = nil
			if not next(Routers[routerip]) then
				Routers[routerip] = nil
			end
		end
	end

	if p.DEBUG then
		local pretty = require "pl.pretty"
		print("UNSUBSCR_ROUTERS_TAB_AFTER", pretty.write(Routers))
	end
end
p.unregister = p.unsubscribe
p.leave = p.unsubscribe

function p.receive (timeout)
	touch_usock()
	if not timeout then
		timeout = 0
	end
	assert(usock:settimeout(timeout))
	return usock:receivefrom()
end

function p.send (name, data)
	touch_usock()
	local msg = "snd "..name.." "..data
	for routerip, ports_t in pairs(Routers) do
		for port, _ in pairs(ports_t) do
			usock:sendto(msg, routerip, port)
		end
	end
end

function p.route(lport)

	local usock = assert(socket.udp())
	assert(usock:setsockname("*", lport))
	assert(usock:settimeout(1))

	local NameToAddr = {}

	while true do
		repeat
			data, ip, port = usock:receivefrom()
			if data then
				assert(ip)
				assert(port)

				_=p.DEBUG and print("RECVD", data, ip, port)

				local regname= string.match(data, "^reg%s+(%S+)")
				local sndname, sdata = string.match(data, "^snd%s+(%S+)%s(.*)")
				local lvename = string.match(data, "^lve%s+(%S+)")

				if regname then

					_=p.DEBUG and print("regname_enter")

					NameToAddr[regname] = NameToAddr[regname] or {}
					NameToAddr[regname][ip] = NameToAddr[regname][ip] or {}
					NameToAddr[regname][ip][port] = true

					if p.DEBUG then
						local pretty = require "pl.pretty"
						print("REG_TAB", pretty.write(NameToAddr))
					end
				end

				if sndname then

					_=p.DEBUG and print("sndname_enter")

					if NameToAddr[sndname] then

						_=p.DEBUG and print("sndname_name_reg_ok")

						for ip, ip_t in pairs(NameToAddr[sndname]) do

							_=p.DEBUG and print("sndname_ip", ip)

							for port, port_t in pairs(ip_t) do

								_=p.DEBUG and print("sndname_port", port)
								_=p.DEBUG and print("sndname_msg", sdata)

								assert(usock:sendto(sdata, ip, port))
							end
						end
					end
				end

				if lvename then

					_=p.DEBUG and print("lvename_enter")

					if NameToAddr[lvename]
					and NameToAddr[lvename][ip]
					and NameToAddr[lvename][ip][port]
					then
						NameToAddr[lvename][ip][port] = nil
						if not next(NameToAddr[lvename][ip]) then
							NameToAddr[lvename][ip] = nil
							if not next(NameToAddr[lvename]) then
								NameToAddr[lvename] = nil
							end
						end
					end

					if p.DEBUG then
						local pretty = require "pl.pretty"
						print("REG_TAB", pretty.write(NameToAddr))
					end
				end

			end
		until not data
	end
end

return p



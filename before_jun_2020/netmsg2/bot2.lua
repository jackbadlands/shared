local netmsg = require "netmsg"

netmsg.register("127.0.0.1", 6000, "bot2")
netmsg.send("bot1", "Hello")
netmsg.leave("127.0.0.1", 6000, "bot2")


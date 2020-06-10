local netmsg = require "netmsg"

netmsg.register("127.0.0.1", 6000, "bot1")
print(netmsg.receive(60))
print(netmsg.receive(15))
netmsg.leave("127.0.0.1", 6000, "bot1")


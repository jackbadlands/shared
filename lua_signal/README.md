# signal
system signal handling in Lua (tested not enough)

#building:
make

#usage:
```lua
require "signal"
signal.register("SIGINT") -- Now module will capture SIGINTS
sigs_t = signal.check() -- If any signals captured, it will returned in the table
                        -- empty table will be returned if no signals captured yet
                        -- In simple words, you have to check for received signals periodically.
                        -- No callbacks here.
```

#example:
see test.lua

local invoke = require "invoke"

function deep (i)
	if i < 100000 then
		invoke(deep, i + 1)
		invoke(print, i + 1)
	else
		print("done")
	end
end

invoke(deep, 1)


local function clonetable(t)
	if type(t) ~= "table" then
		error("clonetable(): arg #1 not a table: "..tostring(t))
	end
	local out = {}
	for i, v in pairs(t) do
		if type(v) == "table" then
			out[i] = clonetable(v)
		else
			out[i] = v
		end
	end
	return out
end

return clonetable


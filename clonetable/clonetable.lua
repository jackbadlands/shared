--[[

  function clones table (inner table whole tree
  will be cloned) and returns the clone.
  objects of any other data types, except tables
  will be the same in new table (originals).

  software license is public domain or MIT
  (select most suitable to your needs)

]]

local function clonetable (t)
	if type(t) == "table" then
		local new = {}
		for k, v in pairs(t) do
			new[k] = clonetable(v)
		end
		return new
	else
		return t
	end
end

return clonetable


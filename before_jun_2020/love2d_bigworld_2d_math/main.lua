local cells = {}
local cell_size = 10
local obj_size = {}

local function add_object(x, y, w, h, data)
	if obj_size[data] ~= nil then
		error("bigworld.add_object(): data already exists")
	end
	local start_cell_x = math.floor(x / cell_size)
	local end_cell_x = math.floor((x + w) / cell_size)
	local start_cell_y = math.floor(y / cell_size)
	local end_cell_y = math.floor((y + h) / cell_size)
	obj_size[data] = {x = x, y = y, w = w, h = h}
	for xx = start_cell_x, end_cell_x do
		for yy = start_cell_y, end_cell_y do
			cells[yy] = cells[yy] or {}
			cells[yy][xx] = cells[yy][xx] or {}
			cells[yy][xx][data] = true
			-- DEBUG
			print("object", data, "inserted to", xx, yy, "cell")
		end
	end
	return true
end

local function remove_object(data)
	if obj_size[data] == nil then
		error("bigworld.remove_object(): data not exists")
	end
	local start_cell_x = math.floor(obj_size[data].x / cell_size)
	local end_cell_x = math.floor((obj_size[data].x + obj_size[data].w) / cell_size)
	local start_cell_y = math.floor(obj_size[data].y / cell_size)
	local end_cell_y = math.floor((obj_size[data].y + obj_size[data].h) / cell_size)
	for xx = start_cell_x, end_cell_x do
		for yy = start_cell_y, end_cell_y do
			cells[yy][xx][data] = nil
			-- DEBUG
			print("object", data, "deleted from", xx, yy, "cell")
		end
	end
	obj_size[data] = nil
	return true
end

local function get_objects_in_area(x, y, w, h)
	local start_cell_x = math.floor(x / cell_size)
	local end_cell_x = math.floor((x + w) / cell_size)
	local start_cell_y = math.floor(y / cell_size)
	local end_cell_y = math.floor((y + h) / cell_size)
	local found = {}
	for xx = start_cell_x, end_cell_x do
		for yy = start_cell_y, end_cell_y do
			if cells[yy]
			and cells[yy][xx] then
				for obj, status in pairs(cells[yy][xx]) do
					found[obj] = true
					-- DEBUG
					print("found object", obj, "in", xx, yy, "cell")
				end
			end
		end
	end
	return found
end

-- main() --------------------------------------

add_object(1, 1, 10, 10, "obj1-1-1-10-10")
print()

add_object(0, 0, 9, 9, "obj2-0-0-9-9")
print()

add_object(11, 1, 21, 33, "obj3-11-1-21-33")
print()

local found = get_objects_in_area(0, 0, 50, 50)
print("objects got:")
for i, v in pairs(found) do
	print("", i)
end
print()

remove_object("obj1-1-1-10-10")
print()

local found = get_objects_in_area(0, 0, 50, 50)
print("objects got:")
for i, v in pairs(found) do
	print("", i)
end
print()

local found = get_objects_in_area(0, 0, 10, 10)
print("objects got:")
for i, v in pairs(found) do
	print("", i)
end
print()

local found = get_objects_in_area(20, 20, 10, 10)
print("objects got:")
for i, v in pairs(found) do
	print("", i)
end
print()


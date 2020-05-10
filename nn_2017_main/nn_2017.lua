DEFAULT_TENSION = 0
DEFAULT_CHARGE = 0
TENSION_MIN = 0
ACTIVATION_TVALUE = 1

image = {
	links = {},
	tensions = {},
	actions = {},
}

-- Internal
function touch_node (node_name)
	if not image.tensions[node_name] then
		image.tensions[node_name] = DEFAULT_TENSION
	end
	if not image.links[node_name] then
		image.links[node_name] = {}
	end
end

-- Internal
function touch_link (src_name, trg_name)
	touch_node(src_name)
	touch_node(trg_name)
	if not image.links[src_name][trg_name] then
		image.links[src_name][trg_name] = DEFAULT_CHARGE
	end
end

-- Set tension
function tn (node_name, tension)
	touch_node(node_name)
	image.tensions[node_name] = tension
end

-- Set node action
function set_action (node_name, action)
	touch_node(node_name)
	image.actions[node_name] = action
end

-- Create link
function link (src_name, trg_name, charge)
	touch_node(src_name)
	touch_node(trg_name)
	image.links[src_name][trg_name] = charge
end

function step (step_count)
	for s = 1, (step_count or 1) do

		local activated = {}
		local undercharged = {}

		for node_name, tension in pairs(image.tensions) do
			if tension >= ACTIVATION_TVALUE then
				activated[node_name] = tension
			end
			if tension < TENSION_MIN then
				undercharged[node_name] = tension
			end
		end

		-- reset activated nodes
		for node_name, tension in pairs(activated) do
			image.tensions[node_name] = TENSION_MIN
		end

		-- reset undercharged nodes
		for node_name, tension in pairs(undercharged) do
			image.tensions[node_name] = TENSION_MIN
		end

		-- trigger actions
		for node_name, tension in pairs(activated) do
			if image.actions[node_name] then
				image.actions[node_name](node_name, tension)
			end
		end

		-- send charges to the target nodes
		for src_name, tension in pairs(activated) do
			for trg_name, charge in pairs(image.links[src_name]) do
				image.tensions[trg_name] = image.tensions[trg_name] + charge
			end
		end
	end
end

-- main()
for i = 1, 10 do
	tn("n"..i, 1)
	for l = 1, 10 do
		link("n"..i, "n"..l, 1)
	end
end
set_action("n1", function() print("1!") end)
for i = 1, 10000 do
	print("executing step " .. i .. "...")
	step()
end

-- results
for node_name, tension in pairs(image.tensions) do
	print(string.format("tension \"%s\" %f", node_name, tension))
	for trg_name, charge in pairs(image.links[node_name]) do
		print(string.format("\tcharge \"%s\" %f", trg_name, charge))
	end
end


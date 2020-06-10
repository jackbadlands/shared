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

local LEFT = 1
local RIGHT = 2
local COLOR = 3
local PARENT = 4
local DATA = 5

-- Tree sentinel node
local Sentinel = {}
	Sentinel[LEFT] = nil
	Sentinel[RIGHT] = nil
	Sentinel[COLOR] = "BLACK"
	Sentinel[PARENT] = nil
	Sentinel[DATA] = nil
local NIL = Sentinel

-- Tree prototype -----------------------------

local TreeProto = {}

-- Default compare functions
function TreeProto.compLT(a,b)
	return a < b
end
function TreeProto.compEQ(a,b)
	return a == b
end

function TreeProto.rotateLeft(tree, x)

	local y = x[RIGHT]

	-- establish x->right link
	x[RIGHT] = y[LEFT]
	if (y[LEFT] ~= tree.NIL) then
		y[LEFT][PARENT] = x
	end

	-- establish y->parent link
	if (y ~= tree.NIL) then
		y[PARENT] = x[PARENT]
	end
	if (x[PARENT]) then
		if (x == x[PARENT][LEFT]) then
			x[PARENT][LEFT] = y
		else
			x[PARENT][RIGHT] = y
		end
	else
		tree.root = y
	end

	-- link x and y
	y[LEFT] = x
	if (x ~= tree.NIL) then
		x[PARENT] = y
	end
end

function TreeProto.rotateRight(tree, x)

	local y = x[LEFT]

	-- establish x->left link
	x[LEFT] = y[RIGHT]
	if (y[RIGHT] ~= tree.NIL) then
		y[RIGHT][PARENT] = x
	end

	-- establish y->parent link
	if (y ~= tree.NIL) then
		y[PARENT] = x[PARENT]
	end
	if (x[PARENT]) then
		if (x == x[PARENT][RIGHT]) then
			x[PARENT][RIGHT] = y
		else
			x[PARENT][LEFT] = y
		end
	else
		tree.root = y
	end

	-- link x and y
	y[RIGHT] = x
	if (x ~= tree.NIL) then
		x[PARENT] = y
	end
end

function TreeProto.insertFixup(tree, x)

	--[[
	*************************************
	*  maintain Red-Black tree balance  *
	*  after inserting node x           *
	************************************* ]]

	-- check Red-Black properties
	while (x ~= tree.root and x[PARENT][COLOR] == "RED") do
		-- /* we have a violation */
		if (x[PARENT] == x[PARENT][PARENT][LEFT]) then
			local y = x[PARENT][PARENT][RIGHT]
			if (y[COLOR] == "RED") then

				-- uncle is RED
				x[PARENT][COLOR] = "BLACK"
				y[COLOR] = "BLACK"
				x[PARENT][PARENT][COLOR] = "RED"
				x = x[PARENT][PARENT]
			else

				-- uncle is BLACK
				if (x == x[PARENT][RIGHT]) then
						-- /* make x a left child */
						x = x[PARENT]
						tree:rotateLeft(x)
				end

				-- recolor and rotate
				x[PARENT][COLOR] = "BLACK"
				x[PARENT][PARENT][COLOR] = "RED"
				tree:rotateRight(x[PARENT][PARENT])
			end
		else

			-- mirror image of above code
			local y = x[PARENT][PARENT][LEFT]
			if (y[COLOR] == "RED") then

				-- uncle is RED
				x[PARENT][COLOR] = "BLACK"
				y[COLOR] = "BLACK"
				x[PARENT][PARENT][COLOR] = "RED"
				x = x[PARENT][PARENT]
			else

				-- uncle is BLACK
				if (x == x[PARENT][LEFT]) then
						x = x[PARENT]
						tree:rotateRight(x)
				end
				x[PARENT][COLOR] = "BLACK"
				x[PARENT][PARENT][COLOR] = "RED"
				tree:rotateLeft(x[PARENT][PARENT])
			end
		end
	end
	tree.root[COLOR] = "BLACK"
end

function TreeProto.insertNode(tree, data)
	local current, parent, x

	--[[
	***********************************************
	*  allocate node for data and insert in tree  *
	*********************************************** ]]

	-- find where node belongs
	current = tree.root
	parent = nil
	while (current ~= tree.NIL) do
		if (tree.compEQ(data, current[DATA])) then
			return current
		end
		parent = current
		if tree.compLT(data, current[DATA]) then
			current = current[LEFT]
		else
			current = current[RIGHT]
		end
	end

	-- setup new node
	x = {}
	x[DATA] = data
	x[PARENT] = parent
	x[LEFT] = tree.NIL
	x[RIGHT] = tree.NIL
	x[COLOR] = "RED"

	-- insert node in tree
	if parent then
		if (tree.compLT(data, parent[DATA])) then
			parent[LEFT] = x
		else
			parent[RIGHT] = x
		end
	else
		tree.root = x;
	end

	tree:insertFixup(x)
	return x
end

function TreeProto.deleteFixup(tree, x)

	--[[
	*************************************
	*  maintain Red-Black tree balance  *
	*  after deleting node x            *
	************************************* ]]

	while (x ~= tree.root and x[COLOR] == "BLACK") do
		if (x == x[PARENT][LEFT]) then
			local w = x[PARENT][RIGHT]
			if (w[COLOR] == "RED") then
				w[COLOR] = "BLACK"
				x[PARENT][COLOR] = "RED"
				tree:rotateLeft(x[PARENT])
				w = x[PARENT][RIGHT]
			end
			if (w[LEFT][COLOR] == "BLACK" and w[RIGHT][COLOR] == "BLACK") then
				w[COLOR] = "RED"
				x = x[PARENT]
			else
				if (w[RIGHT][COLOR] == "BLACK") then
					w[LEFT][COLOR] = "BLACK"
					w[COLOR] = "RED"
					tree:rotateRight(w)
					w = x[PARENT][RIGHT]
				end
				w[COLOR] = x[PARENT][COLOR]
				x[PARENT][COLOR] = "BLACK"
				w[RIGHT][COLOR] = "BLACK"
				tree:rotateLeft(x[PARENT])
				x = tree.root
			end
		else
			local w = x[PARENT][LEFT]
			if (w[COLOR] == "RED") then
				w[COLOR] = "BLACK"
				x[PARENT][COLOR] = "RED"
				tree:rotateRight(x[PARENT])
				w = x[PARENT][LEFT]
			end
			if (w[RIGHT][COLOR] == "BLACK" and w[LEFT][COLOR] == "BLACK") then
				w[COLOR] = "RED"
				x = x[PARENT]
			else
				if (w[LEFT][COLOR] == "BLACK") then
					w[RIGHT][COLOR] = "BLACK"
					w[COLOR] = "RED"
					tree:rotateLeft(w)
					w = x[PARENT][LEFT]
				end
				w[COLOR] = x[PARENT][COLOR];
				x[PARENT][COLOR] = "BLACK"
				w[LEFT][COLOR] = "BLACK"
				tree:rotateRight(x[PARENT])
				x = tree.root
			end
		end
	end
	x[COLOR] = "BLACK"
end

function TreeProto.deleteNode(tree, z)
	local x, y

	--[[
	*****************************
	*  delete node z from tree  *
	***************************** ]]

	if (not z or z == tree.NIL) then
		return
	end

	if (z[LEFT] == tree.NIL or z[RIGHT] == tree.NIL) then
		-- y has a NIL node as a child
		y = z
	else
		-- find tree successor with a NIL node as a child
		y = z[RIGHT]
		while (y[LEFT] ~= tree.NIL) do
			y = y[LEFT]
		end
	end

	-- x is y's only child
	if (y[LEFT] ~= tree.NIL) then
		x = y[LEFT]
	else
		x = y[RIGHT]
	end

	-- remove y from the parent chain
	x[PARENT] = y[PARENT]
	if (y[PARENT]) then
		if (y == y[PARENT][LEFT]) then
			y[PARENT][LEFT] = x
		else
			y[PARENT][RIGHT] = x
		end
	else
		tree.root = x
	end

	if (y ~= z) then
		z[DATA] = y[DATA]
	end


	if (y[COLOR] == "BLACK") then
		tree:deleteFixup(x)
	end

	-- free(y)
end


function TreeProto.findNode(tree, data)

	--[[
	*******************************
	*  find node containing data  *
	******************************* ]]

	local current = tree.root
	while(current ~= tree.NIL) do
		if tree.compEQ(data, current[DATA]) then
			return current
		else
			if tree.compLT(data, current[DATA]) then
				current = current[LEFT]
			else
				current = current[RIGHT]
			end
		end
	end
	return nil
end

-- More ----------------------------------------

-- Searches in subtree root of which is @n
-- or, if @n not specified, searches from tree root.
function TreeProto.getMinNode(tree, n)
	if not n then
		n = tree.root
	end
	while n[LEFT] ~= tree.NIL do
		n = n[LEFT]
	end
	if n == tree.NIL then return nil end
	return n
end

-- Searches in subtree root of which is @n
-- or, if @n not specified, searches from tree root.
function TreeProto.getMaxNode(tree, n)
	if not n then
		n = tree.root
	end
	while n[RIGHT] ~= tree.NIL do
		n = n[RIGHT]
	end
	if n == tree.NIL then return nil end
	return n
end

-- Returns next node after @n.
-- If @n not specified, behave as tree:getMinNode().
function TreeProto.getNextNode(tree, n)
	if not n or n == tree.NIL then
		return tree:getMinNode()
	end
	if n[RIGHT] ~= tree.NIL then
		return tree:getMinNode(n[RIGHT])
	else
		local c = n
		local p = n[PARENT]
		while p and p ~= tree.NIL and c == p[RIGHT] do
			c = p
			p = p[PARENT]
		end
		if not p or p == tree.NIL then
			return nil
		else
			return p
		end
	end
end

-- Returns previous node before @n.
-- If @n not specified, behave as tree:getMaxNode().
function TreeProto.getPrevNode(tree, n)
	if not n or n == tree.NIL then
		return tree:getMaxNode()
	end
	if n[LEFT] ~= tree.NIL then
		return tree:getMaxNode(n[LEFT])
	else
		local c = n
		local p = n[PARENT]
		while p and p ~= tree.NIL and c == p[LEFT] do
			c = p
			p = p[PARENT]
		end
		if not p or p == tree.NIL then
			return nil
		else
			return p
		end
	end
end

function TreeProto.findNearestNodes(tree, data)

	local current = tree.root
	local lasttrue = nil

	-- Search node
	while(current ~= tree.NIL) do
		if tree.compEQ(data, current[DATA]) then
			lasttrue = current
			break
		else
			if tree.compLT(data, current[DATA]) then
				current = current[LEFT]
			else
				current = current[RIGHT]
			end

			if current ~= tree.NIL then
				lasttrue = current
			end
		end
	end
	if not lasttrue then -- No nodes in the tree
		return nil
	end
	if current ~= tree.NIL then
		return tree:getPrevNode(current), tree:getNextNode(current)
	else
		local l, g
		if tree.compLT(data, lasttrue[DATA]) then
			g = lasttrue
			l = tree:getPrevNode(lasttrue)
		else
			l = lasttrue
			g = tree:getNextNode(lasttrue)
		end
		return l, g
	end
end

function TreeProto.getNodesInRange(tree, datastart, dataend)

	local ign

	-- get start node
	local startn
	startn = tree:findNode(datastart)
	if not startn then
		ign, startn = tree:findNearestNodes(datastart)
		if not startn then
			return {}
		end
	end

	local out = {}
	local curn = startn
	while tree.compLT(curn[DATA], dataend)
	   or tree.compEQ(curn[DATA], dataend)
	do
		table.insert(out, curn)

		curn = tree:getNextNode(curn)
		if not curn then
			return out
		end
	end

	return out
end

function TreeProto.getNodeData(tree, n)
	if n then
		return n[DATA]
	else
		return nil
	end
end

-- Public API ----------------------------------

local public = {}

function public.new(cfg_t)

	local new = clonetable(TreeProto)

	local Sentinel = {}
	Sentinel[LEFT] = Sentinel
	Sentinel[RIGHT] = Sentinel
	Sentinel[COLOR] = "BLACK"
	Sentinel[PARENT] = nil
	Sentinel[DATA] = nil

	new.NIL = Sentinel
	new.root = new.NIL

	cfg_t = cfg_t or {}
	if type(cfg_t.compLT) == "function" then
		new.compLT = cfg_t.compLT
	end
	if type(cfg_t.compEQ) == "function" then
		new.compEQ = cfg_t.compEQ
	end
	return new
end

return public


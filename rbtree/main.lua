local rbtree = require "rbtree"
local tree = rbtree.new()
local tree1 = rbtree.new()

for i = 1, 10 do
	tree:insertNode(i)
end

print(string.rep("-", 40))

for i, v in pairs(tree:getNodesInRange(4, 7)) do
	print(i, tree:getNodeData(v))
end

print(string.rep("-", 40))

print(tree:findNode(5))
print(tree:getNodeData(tree:findNode(5)))


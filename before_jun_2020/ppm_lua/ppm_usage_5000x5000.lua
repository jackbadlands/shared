#!/usr/bin/env lua

local ppm = require "ppm"

print("loading 1.ppm")
local img = ppm.load("1.ppm")

print("editing 1.ppm")
for y = 0, 14 do
	for x = 0, 14 do
		img.r[y][x] = 255
		img.g[y][x] = 0
		img.b[y][x] = 255
	end
end

print("storing to 1_out.ppm")
img:store("1_out.ppm")

print("generating 2.ppm")
local img = ppm.new(5000, 5000, 0, 0, 255)
print("storing to 2_out.ppm")
img:store("2_out.ppm")
print("done")


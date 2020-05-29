#!/usr/bin/env lua

-- DESCR:
-- program searches n-root for target number value.
-- only positive numbers.
--
-- USAGE:
-- I want to find x, where x^3==8.
-- then I will run command
--   lua nroot.lua 3 8
-- result will be printed into console's stdout.

-- LICENSE:
-- License is public domain in countries that accepts public domain license.
-- or use most permissive license in other countries (use MIT for example.
-- honestly i don't care about mention me as author).
--
-- my position: use for whatever you want. just don't take it from other
-- people or machines. let them use it too, if they want.


-- parse args:
-- 1) power of root that we find for (n)
-- 2) target value, that:
--    root ^ n == target
-- 3) acceptable_bias, default is 0.1, optional
local n = math.abs(assert(tonumber(arg[1])))
local target = math.abs(assert(tonumber(arg[2])))
local acceptable_bias = arg[3] and assert(tonumber(arg[3])) or 0.1

function sign_differs (a, b)
  if (a >= 0 and b < 0)
  or (b >= 0 and a < 0)
  then
    return true
  else
    return false
  end
end

local root = 10 -- some random root for beginning
local step = root * 0.99 -- some random step
local num = root ^ n -- initial num calculation
local prev_diff = 0 -- something (don't care in beginning)

-- "find root" loop
while math.abs(num - target) > acceptable_bias do
  local diff = num - target

  -- make impossible root to be less than 1
  while root - step < 1 do
    step = step / 2
  end

  -- lower step if passed through sign change
  if sign_differs(diff, prev_diff) then
    step = step / 2
  end

  -- apply step depending of lower or greater result than target value
  if num < target then
    root = root + step
  else
    root = root - step
  end

  -- save diff. recalculate num with new root (that will be checked in "while")
  prev_diff = diff
  num = root ^ n
end

print(root)



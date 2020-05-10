local public = {}

function public.getListVisibleItems(listviewsize, listitemsize, curscroll)
	local itemsvisible = {}
	local firstvisibleitem = math.floor(curscroll / listitemsize)
	local lastvisibleitem = math.ceil((curscroll + listviewsize)  / listitemsize)
	return firstvisibleitem + 1, lastvisibleitem
end

function public.getListItemOffset(listitemheight, curitemidx, curscroll)
	local pos = (curitemidx - 1) * listitemheight - curscroll
	return pos
end

function public.cutListScroll(listitemcount, listitemsize, viewsize, curscroll)
	local newscroll = curscroll
	local state = "normal"
	if curscroll < 0 then
		newscroll = 0
		state = "less"
	end
	if curscroll > listitemsize * (listitemcount - 1) - viewsize then
		newscroll = listitemsize * (listitemcount - 1) - viewsize
		state = "greater"
	end
	return newscroll, state
end

function public.doesRectsIntersects(xa, ya, wa, ha, xb, yb, wb, hb)
	local xa1 = xa + wa
	local ya1 = ya + ha
	local xb1 = xb + wb
	local yb1 = yb + hb
	function isDotInLine(p, lstart, lend)
		if (p >= lstart and p <= lend) then
			return true
		else
			return false
		end
	end
	if (
	      isDotInLine(xa, xb, xb1)
			  or
				isDotInLine(xa1, xb, xb1)
			  or
				isDotInLine(xb, xa, xa1)
			  or
				isDotInLine(xb1, xa, xa1)
	   )
		 and
		 (
	      isDotInLine(ya, yb, yb1)
			  or
				isDotInLine(ya1, yb, yb1)
			  or
				isDotInLine(yb, ya, ya1)
			  or
				isDotInLine(yb1, ya, ya1)
		 )
	then
		 return true
	else
		 return false
	end
end

function public.getRectsIntersection(ax, ay, aw, ah, bx, by, bw, bh)
	local xmin, xmax = nil, nil
	local ymin, ymax = nil, nil
	function isDotInLine(p, lstart, lend)
		if (p >= lstart and p <= lend) then
			return true
		else
			return false
		end
	end
	function updateXMinMax(x)
		if not xmin then
			xmin = x
		end
		if not xmax then
			xmax = x
		end
		if xmin > x then
			xmin = x
		end
		if xmax < x then
			xmax = x
		end
	end
	function updateYMinMax(y)
		if not ymin then
			ymin = y
		end
		if not ymax then
			ymax = y
		end
		if ymin > y then
			ymin = y
		end
		if ymax < y then
			ymax = y
		end
	end
	-- Check Xes
	if isDotInLine(ax, ax, ax + aw) and isDotInLine(ax, bx, bx + bw) then
		updateXMinMax(ax)
	end
	if isDotInLine(bx, ax, ax + aw) and isDotInLine(bx, bx, bx + bw) then
		updateXMinMax(bx)
	end
	if isDotInLine(ax + aw, ax, ax + aw) and isDotInLine(ax + aw, bx, bx + bw) then
		updateXMinMax(ax + aw)
	end
	if isDotInLine(bx + bw, ax, ax + aw) and isDotInLine(bx + bw, bx, bx + bw) then
		updateXMinMax(bx + bw)
	end
	-- Check Ys
	if isDotInLine(ay, ay, ay + ah) and isDotInLine(ay, by, by + bh) then
		updateYMinMax(ay)
	end
	if isDotInLine(by, ay, ay + ah) and isDotInLine(by, by, by + bh) then
		updateYMinMax(by)
	end
	if isDotInLine(ay + ah, ay, ay + ah) and isDotInLine(ay + ah, by, by + bh) then
		updateYMinMax(ay + ah)
	end
	if isDotInLine(by + bh, ay, ay + ah) and isDotInLine(by + bh, by, by + bh) then
		updateYMinMax(by + bh)
	end
	-- If intersection exists, return coordinates
	if xmin and xmax and ymin and ymax then
		if xmin < xmax then
			if ymin < ymax then
				local ox = xmin
				local oy = ymin
				local ow = xmax - xmin
				local oh = ymax - ymin
				return ox, oy, ow, oh
			end
		end
	end
	return nil
end

function public.translateXY(ox, oy, x, y)
	local newx = assert(tonumber(ox)) + assert(tonumber(x))
	local newy = assert(tonumber(oy)) + assert(tonumber(y))
	return newx, newy
end

function public.relativeXY(ox, oy, x, y)
	local newx = assert(tonumber(x)) - assert(tonumber(ox)) 
	local newy = assert(tonumber(y)) - assert(tonumber(oy)) 
	return newx, newy
end

return public


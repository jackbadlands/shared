local m = {}

function m.fromscreentogame (sx, sy, sw, wh, gw, gh)

end

function m.scalecontain (iw, ih, width, height)

	if iw > width then
			ih = ih * width / iw
			iw = width
	end
	if ih > height then
			iw = iw * height / ih
			ih = height
	end

	if ih == 0 or iw == 0 then
			return 0, 0
	end

	local aspectw = width / iw
	local aspecth = height / ih
	local aspect
	local movx, movy

			-- Use the smaller one of the two aspect ratios.
	if aspectw > aspecth then
		aspect = aspecth
		movx = math.floor((width - iw * aspect) / 2)
		movy = 0
	else
		aspect = aspectw
		movy = math.floor((height - ih * aspect) / 2)
		movx = 0
	end

	local scalex = aspect
	local scaley = aspect
	return scalex, scaley, movx, movy -- the same value
end

function m.scalezoom (iw, ih, width, height)

	local aspectw = width / iw
	local aspecth = height / ih

	aspecth = math.max(aspectw, aspecth)
	aspectw = math.max(aspectw, aspecth)

	local movx, movy = 0, 0
	local fw = iw * aspectw
	local fh = ih * aspecth
	if fw > width then
		movx = -((fw - width) / 2)
	end
	if fh > height then
		movy = -((fh - height) / 2)
	end

	return aspectw, aspecth, movx, movy
end

return m


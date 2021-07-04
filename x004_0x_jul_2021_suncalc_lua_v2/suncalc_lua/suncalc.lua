--[[

  Original code in JavaScript was used. Author of JS source:
    (c) 2011-2015, Vladimir Agafonkin
    SunCalc is a JavaScript library for calculating sun/moon
	  position and light phases.
    https://github.com/mourner/suncalc

  Rewritten in Lua by jackbadlands.

]]

-- shortcuts for easier to read formulas

local PI   = math.pi
local sin  = math.sin
local cos  = math.cos
local tan  = math.tan
local asin = math.asin
local atan = math.atan2
local acos = math.acos
local rad  = PI / 180

local function arcctg (x)

	--http://1cov-edu.ru/mat_analiz/funktsii/obratnie_trigonometricheskie/arctg/
	local ret1 = math.pi / 2 - math.atan(x)

	--https://en.wikipedia.org/wiki/Inverse_trigonometric_functions
	--local ret2 = math.atan(-x) + math.pi / 2

	--print("1cov-edu.ru arcctg("..x..") = "..ret1)
	--print("wiki        arcctg("..x..") = "..ret2)
	return ret1
end

-- sun calculations are based on http://aa.quae.nl/en/reken/zonpositie.html formulas


-- date/time constants and conversions

local dayMs = 1000 * 60 * 60 * 24
local daySec = 60 * 60 * 24
local J1970 = 2440588
local J2000 = 2451545

function toJulian (unix_secs_date)
	return unix_secs_date / daySec - 0.5 + J1970
end

function fromJulian (j)
	return (j + 0.5 - J1970) * daySec
end

function toDays (unix_secs_date)
	return toJulian(unix_secs_date) - J2000
end


-- general calculations for position

local e = rad * 23.4397 -- obliquity of the Earth

function rightAscension (l, b)
	return atan(sin(l) * cos(e) - tan(b) * sin(e), cos(l))
end

function declination (l, b)
	return asin(sin(b) * cos(e) + cos(b) * sin(e) * sin(l))
end

function azimuth (H, phi, dec)
	return atan(sin(H), cos(H) * sin(phi) - tan(dec) * cos(phi))
end

function altitude (H, phi, dec)
	return asin(sin(phi) * sin(dec) + cos(phi) * cos(dec) * cos(H))
end

function siderealTime (d, lw)
	return rad * (280.16 + 360.9856235 * d) - lw
end

function astroRefraction (h)
	if h < 0 then -- the following formula works for positive altitudes only.
		h = 0 -- if h = -0.08901179 a div/0 would occur.
	end

	-- formula 16.4 of "Astronomical Algorithms" 2nd edition by Jean Meeus (Willmann-Bell, Richmond) 1998.
	-- 1.02 / tan(h + 10.26 / (h + 5.10)) h in degrees, result in arc minutes -> converted to rad:
	return 0.0002967 / math.tan(h + 0.00312536 / (h + 0.08901179))
end

-- general sun calculations

function solarMeanAnomaly (d)
	return rad * (357.5291 + 0.98560028 * d)
end

function eclipticLongitude (M)

	-- equation of center
	local C = rad * (1.9148 * sin(M) + 0.02 * sin(2 * M) + 0.0003 * sin(3 * M))

	-- perihelion of the Earth
	local P = rad * 102.9372

	return M + C + P + PI
end

function sunCoords (d)

	local M = solarMeanAnomaly(d)
	local L = eclipticLongitude(M)

	return {
		dec = declination(L, 0),
		ra = rightAscension(L, 0),
	}
end

local SunCalc = {}


-- calculates sun position for a given date and latitude/longitude

SunCalc.getPosition = function (date, lat, lng)

	local lw  = rad * -lng
	local phi = rad * lat
	local d   = toDays(date)

	local c = sunCoords(d)
	local H = siderealTime(d, lw) - c.ra

	return {
		["azimuth  [-]"] = azimuth(H, phi, c.dec),
		["altitude [|]"] = altitude(H, phi, c.dec),
	}
end


-- sun times configuration (angle, morning name, evening name)

local times = {
	{-0.833, 'sunrise',       'sunset'      },
	{  -0.3, 'sunriseEnd',    'sunsetStart' },
	{    -6, 'dawn',          'dusk'        },
	{   -12, 'nauticalDawn',  'nauticalDusk'},
	{   -18, 'nightEnd',      'night'       },
	{     6, 'goldenHourEnd', 'goldenHour'  },
}

SunCalc.times = times

-- adds a custom time to the times config

SunCalc.addTime = function (angle, riseName, setName)
	table.insert(times, {angle, riseName, setName})
end


-- calculations for sun times

local J0 = 0.0009;

function math.round (d)
	if d % 1 < 0.5 then
		return math.floor(d)
	else
		return math.ceil(d)
	end
end

function julianCycle (d, lw)
	return math.round(d - J0 - lw / (2 * PI))
end

function approxTransit (Ht, lw, n)
	return J0 + (Ht + lw) / (2 * PI) + n
end

function solarTransitJ (ds, M, L)
	return J2000 + ds + 0.0053 * sin(M) - 0.0069 * sin(2 * L)
end

function hourAngle (h, phi, d)
	return acos((sin(h) - sin(phi) * sin(d)) / (cos(phi) * cos(d)))
end

-- returns set time for the given sun altitude
function getSetJ (h, lw, phi, dec, n, M, L)

	local w = hourAngle(h, phi, dec)
	local a = approxTransit(w, lw, n)
	return solarTransitJ(a, M, L)
end


-- calculates sun times for a given date and latitude/longitude

SunCalc.getTimes = function (date, lat, lng)

	local lw = rad * -lng
	local phi = rad * lat

	local d = toDays(date)
	local n = julianCycle(d, lw)
	local ds = approxTransit(0, lw, n)

	local M = solarMeanAnomaly(ds)
	local L = eclipticLongitude(M)
	local dec = declination(L, 0)

	local Jnoon = solarTransitJ(ds, M, L)

	local i, len, time, Jset, Jrise

	local result = {
		solarNoon = fromJulian(Jnoon),
		nadir = fromJulian(Jnoon - 0.5),
	}

	for i, time in ipairs(times) do

		local Jset = getSetJ(time[1] * rad, lw, phi, dec, n, M, L)
		local Jrise = Jnoon - (Jset - Jnoon)

		result[time[2]] = fromJulian(Jrise)
		result[time[3]] = fromJulian(Jset)
	end

  return result
end


-- moon calculations, based on http://aa.quae.nl/en/reken/hemelpositie.html formulas

function moonCoords (d) -- geocentric ecliptic coordinates of the moon

	local  L = rad * (218.316 + 13.176396 * d) -- ecliptic longitude
	local M = rad * (134.963 + 13.064993 * d) -- mean anomaly
	local F = rad * (93.272 + 13.229350 * d)  -- mean distance

	local l  = L + rad * 6.289 * sin(M) -- longitude
	local b  = rad * 5.128 * sin(F)     -- latitude
	local dt = 385001 - 20905 * cos(M)  -- distance to the moon in km

	return {
		ra = rightAscension(l, b),
		dec = declination(l, b),
		dist = dt,
	}
end

SunCalc.getMoonPosition = function (date, lat, lng)

	local lw  = rad * -lng
	local phi = rad * lat
	local d   = toDays(date)

	local c = moonCoords(d)
	local H = siderealTime(d, lw) - c.ra
	local h = altitude(H, phi, c.dec)
	-- formula 14.1 of "Astronomical Algorithms" 2nd edition by Jean Meeus (Willmann-Bell, Richmond) 1998.
	local pa = atan(sin(H), tan(phi) * cos(c.dec) - sin(c.dec) * cos(H))

	h = h + astroRefraction(h) -- altitude correction for refraction

	return {
		azimuth = azimuth(H, phi, c.dec),
		altitude = h,
		distance = c.dist,
		parallacticAngle = pa,
	}
end


-- calculations for illumination parameters of the moon,
-- based on http://idlastro.gsfc.nasa.gov/ftp/pro/astro/mphase.pro formulas and
-- Chapter 48 of "Astronomical Algorithms" 2nd edition by Jean Meeus (Willmann-Bell, Richmond) 1998.

SunCalc.getMoonIllumination = function (date)

	local d = toDays(date or os.time())
	local s = sunCoords(d)
	local m = moonCoords(d)

	local sdist = 149598000 -- distance from Earth to Sun in km

	local phi = acos(sin(s.dec) * sin(m.dec) + cos(s.dec) * cos(m.dec) * cos(s.ra - m.ra))
	local inc = atan(sdist * sin(phi), m.dist - sdist * cos(phi))
	local angle = atan(cos(s.dec) * sin(s.ra - m.ra), sin(s.dec) * cos(m.dec) -
							cos(s.dec) * sin(m.dec) * cos(s.ra - m.ra))

	return {
		fraction = (1 + cos(inc)) / 2,
		phase = 0.5 + 0.5 * inc * (angle < 0 and -1 or 1) / math.pi,
		angle = angle,
	}
end


function hoursLater (unix_secs_date, h)
	return unix_secs_date + h * daySec / 24
end

function SunCalc.diffUTCAndLocalTime (utime)
  local utc_time_t = os.date("!*t", utime)
  utc_time_t.isdst = nil
  local local_time_t = os.date("*t", utime)
  local utc_utime = os.time(utc_time_t)
  local local_utime = os.time(local_time_t)
  return os.difftime(local_utime, utc_utime)
end

local function set_hours_override (utime, h, m, s)
  local time_t = os.date("*t", utime)
  time_t.hour = h
  time_t.min = m
  time_t.sec = s
  local new_utime = os.time(time_t)
  return new_utime
end

-- TODO test
local function set_utc_hours_override (utime, h, m, s)
  local new_utime = set_hours_override(utime, h, m, s)
  local utc_ofst = SunCalc.diffUTCAndLocalTime(utime)
  return new_utime - utc_ofst
end

-- calculations for moon rise/set times are based on
-- http://www.stargazing.net/kepler/moonrise.html
-- article

function SunCalc.getMoonTimes (unix_secs_date, lat, lng, inUTC)
    local t = unix_secs_date
    if inUTC then
      t = set_utc_hours_override(t, 0, 0, 0) -- TODO test
    else
      t = set_hours_override(t, 0, 0, 0)
    end

    local hc = 0.133 * rad
    local h0 = SunCalc.getMoonPosition(t, lat, lng).altitude - hc
    local h1, h2, rise, set, a, b, xe, ye, d, roots, x1, x2, dx

    -- go in 2-hour chunks, each time seeing if a 3-point quadratic curve
    -- crosses zero (which means rise or set)
    for i = 1, 24, 2 do
        h1 = SunCalc.getMoonPosition(hoursLater(t, i), lat, lng).altitude - hc
        h2 = SunCalc.getMoonPosition(hoursLater(t, i + 1), lat, lng).altitude - hc

        a = (h0 + h2) / 2 - h1
        b = (h2 - h0) / 2
        xe = -b / (2 * a)
        ye = (a * xe + b) * xe + h1
        d = b * b - 4 * a * h1
        roots = 0

        if d >= 0 then
            dx = math.sqrt(d) / (math.abs(a) * 2)
            x1 = xe - dx
            x2 = xe + dx
            if math.abs(x1) <= 1 then roots = roots + 1 end
            if math.abs(x2) <= 1 then roots = roots + 1 end
            if x1 < -1 then x1 = x2 end
        end

        if roots == 1 then
            if h0 < 0 then
              rise = i + x1
            else
              set = i + x1
            end

        elseif roots == 2 then
            rise = i + ((ye < 0) and x2 or x1)
            set = i + ((ye < 0) and x1 or x2)
        end

        if (rise and rise ~= 0) and (set and set ~= 0) then break end

        h0 = h2
    end

    local result = {}

    if rise and rise ~= 0 then result.rise = hoursLater(t, rise) end
    if set and set ~= 0 then result.set = hoursLater(t, set) end

    if ((not rise or rise == 0) and (not set or set == 0)) then
      result[(ye > 0) and 'alwaysUp' or 'alwaysDown'] = true
    end

    return result
end

-- return module object
return SunCalc


AddCSLuaFile()

require("lithium")
lithium.log("'Lithium: Datatypes' override loading")

if lithium.datatypes.enable_creation_optimisation then -- creation optimisation my ass. SEE: modules/lithium.lua
	lithium.vector_old = lithium.vector_old or Vector
	lithium.angle_old = lithium.angle_old or Angle
	lithium.color_old = lithium.color_old or Color
	local cache = {}
	local lastused = {}

	local function cached_creator(a, b, c, old, default, key)
		if type(a) == key or isstring(a) then
			return old(a)
		end
		if a == nil and b == nil and c == nil then
			return default
		end
		local xyz = a * 32767 * 32767 + b * 32767 + c
		if cache[key][xyz] then
			local vec = cache[key][xyz]
			if vec.x == a and vec.y == b and vec.z == c then
				lastused[key][vec] = SysTime()
				return vec
			end
		end
		return old(a, b, c)
	end

	function Vector(a, b, c) return cached_creator(a, b, c, lithium.vector_old, vector_origin, 'Vector') end
	function Angle(a, b, c) return cached_creator(a, b, c, lithium.vector_old, vector_origin, 'Angle') end
	function Color(a, b, c, d)
		local r, g, b, a = a, b, c, d or 255
		local rgba = r * (1024^3) + g * (1024^2) + b * 1024 + a
		if cache['color'][xyz] then
			local vec = cache['color'][xyz]
			if vec.r == a and vec.g == b and vec.b == c and vec.a == d then
				lastused['color'][vec] = SysTime()
				return vec
			end
		end
		return old(a, b, c, d)
	end

	timer.Create("LITHIUM_CacheInvalidator", 5, 0, function()
		for _,cache_ in pairs(cache) do
			for xyz,val in pairs(cache_) do
				if SysTime() - lastused[val] > 5 then
					cache_[xyz] = nil
					lastused[val] = nil
				end
			end
		end
	end)
end

local meta_vector, meta_angle, meta_color = FindMetaTable("Vector"), FindMetaTable("Angle"), FindMetaTable("Color")
if lithium.enable_defaults_override then
	function meta_vector:ToColor()
		return Color(self.x * 255, self.y * 255, self.z * 255)
	end
	function meta_angle:SnapTo(component, degrees)
		if (degrees == 0) then
			ErrorNoHalt("The snap degrees must be non-zero.\n")
			return self
		end
		if (not self[component]) then
			ErrorNoHalt("You must choose a valid component of Angle( p || pitch, y || yaw, r || roll )"..
				"to snap such as Angle( 80, 40, 30 ):SnapTo( \"p\", 90 ):SnapTo( \"y\", 45 ):SnapTo( \"r\", 40 );"..
				"and yes, you can keep adding snaps.\n")
			return self
		end

		self[component] = math.Round(self[component] / degrees) * degrees
		self[component] = math.NormalizeAngle(self[component])

		return self
	end
end
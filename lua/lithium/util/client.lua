AddCSLuaFile()

local frame_time = 0
local last_query = 0

function RealFrameTime() return frame_time end

hook.Add("Think", "RealFrameTime", function()
	frame_time = SysTime() - last_query
	last_query = SysTime()
end)
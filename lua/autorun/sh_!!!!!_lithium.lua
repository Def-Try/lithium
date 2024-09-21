AddCSLuaFile()

--do return end

jit.on()

require("lithium")

lithium.log("Lithium starting")

timer.Create("LITHIUM_garbage_collector", 5 * 60, 0, function()
	lithium.gc()
end)

local overrides = {
	{"lithium/includes/modules/extensions/client/render.lua", CLIENT},
	{"lithium/includes/modules/extensions/datatypes.lua", true},
	{"lithium/includes/util/client.lua", CLIENT},
	{"lithium/includes/util/hook_override.lua", true}
}
for _,override in pairs(overrides) do
	if not override[2] then continue end
	include(override[1])
end

lithium.log("Lithium running!")

-- include("lithium/includes/util/tracer_mode.lua").start()
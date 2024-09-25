AddCSLuaFile()

local enable_convar = CreateConVar("lithium_enabled_"..(SERVER and "sv" or CLIENT and "cl" or "unk"), "1", {FCVAR_ARCHIVE}, "Enable Lithium (requires restart)", 0, 1)
if not enable_convar:GetBool() then
	return print("[LITHIUM] Skipping startup, lithium is disabled.")
end

jit.on()

require("lithium")

lithium.log("Core systems starting...")
local loaded, total = 0, 0

lithium.log("Starting: Garbage Collector")
timer.Create("LITHIUM_garbage_collector", 5 * 60, 0, function()
	lithium.gc()
end)
loaded = loaded + 1
total = total + 1

local function load(name, func)
	lithium.log("Loading: "..name)
	total = total + 1
	local succ, err_or_ret = pcall(function()
		return func()
	end)
	if not succ then
		lithium.warn("Failed to load "..name..": "..err_or_ret)
		return {false, err_or_ret}
	end
	loaded = loaded + 1
	return {true, err_or_ret}
end

local function load_include(path, name)
	return load(name, function()
		return include("lithium/"..path)
	end)
end

load("Hook System", function()
	local hook_table = hook.GetTable()
	require("hook_lithium")
	for event, event_table in pairs(hook_table) do
		for name, func in pairs(event_table) do
			hook.Add(event, name, func)
		end
	end
	if file.Exists("ulib/shared/hook.lua", "LUA") then -- ulib support (?)
		local old_include = _G.include
		function include(f, ...)
			if f == "ulib/shared/hook.lua" then
				lithium.log("Stopped ULX hook from loading. If you encounter errors, go ahead and report them.")
				_G.include = old_include
				return
			end
			return old_include(f, ...)
		end
	end

	if file.Exists("dlib/modules/hook.lua", "LUA") then
		lithium.warn("DLib is installed. DLib is a bloated addon.")
		lithium.warn("DLib also has a slower hook module. If you don't understand what it means, THIS MAKES YOUR SERVER / GAME SLOWER.")
		lithium.warn("See https://github.com/Def-Try/lithium for more info.")
	end
end)


if CLIENT then
	load_include("extensions/client/render.lua", "Render functions")
	load_include("util/client.lua", "Client functions")
end

load_include("util.lua", "Util functions")

lithium.log("Core systems startup complete. Loaded: "..loaded.."/"..total)

lithium.log("Auxiliary systems starting...")
loaded, total = 0, 0
if CLIENT then
	load_include("gpusaver.lua", "GPU Out-Of-Focus Saver")
end

lithium.log("Auxiliary systems startup complete. Loaded: "..loaded.."/"..total)

-- include("lithium/includes/util/tracer_mode.lua").start()
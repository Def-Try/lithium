AddCSLuaFile()


local function send_dir(dir)
    dir = dir .. "/"
    local File, Directory = file.Find(dir.."*", "LUA")

    for k, v in ipairs(File) do
        if not string.EndsWith(v, ".lua") then continue end
        local fileSide = string.lower(string.Left(v, 3))
	    if fileSide == "sh_" then
	        AddCSLuaFile(dir..v)
	    elseif fileSide == "cl_" then
	        AddCSLuaFile(dir..v)
    	end
    end
    
    for k, v in ipairs(Directory) do
        send_dir(dir..v)
    end
end

if SERVER then
	send_dir("lithium")
	AddCSLuaFile("includes/modules/hook_lithium.lua")
	AddCSLuaFile("includes/modules/lithium.lua")
	AddCSLuaFile("autorun/client/cl_lithium_controls.lua")
end

local enable_convar = CreateConVar("lithium_enabled_"..(SERVER and "sv" or CLIENT and "cl" or "unk"), "1", {FCVAR_ARCHIVE}, "Enable Lithium (requires restart)", 0, 1)
if not enable_convar:GetBool() then
	return print("[LITHIUM] Skipping startup, lithium is disabled.")
end

jit.on()

if file.Read("lithium_dontload.txt", "DATA") == "yes" then 
	return print("[LITHIUM] Skipping startup, lithium is disabled through data/lithium_dontload.txt")
end

local function mk_convar(name, desc, cl, sv, def)
	if CLIENT and not cl then return end
	if SERVER and not sv then return end
	return CreateConVar("lithium_"..name..((cl and sv) and ("_"..(SERVER and "sv" or CLIENT and "cl" or "unk")) or ""), tostring(def or 0), {FCVAR_ARCHIVE}, desc, 0, 1)
end

local enable_gc = mk_convar("enable_garbagecollector", "Enable Lithium Garbage Collector", true, true, 1)
local enable_hook = mk_convar("enable_hookmodule", "Enable Lithium Hook Module", true, true, 1)
local enable_convars = mk_convar("enable_convars", "Enable Lithium Optimised ConVars", true, true, 1)
local enable_clientutil = mk_convar("enable_clientutil", "Enable Lithium Client Utilities", true, false, 1)
local enable_renderutil = mk_convar("enable_renderutil", "Enable Lithium Render Utilities", true, false, 1)
local enable_betterrender = mk_convar("enable_betterrender", "Enable Lithium Better Render", true, false, 1)
local enable_utils = mk_convar("enable_util", "Enable Lithium Utilities", true, true, 0)
local enable_gpusaver = mk_convar("enable_gpusaver", "Enable Lithium GPU Out-Of-Focus Saver", true, false, 1)

require("lithium")

lithium.log("Core systems starting...")
local loaded, total, list = 0, 0, {}

if enable_gc:GetBool() then
	lithium.log("Starting: Garbage Collector")
	timer.Create("LITHIUM_garbage_collector", 5 * 60, 0, function()
		lithium.gc()
	end)
	loaded = loaded + 1
end
total = total + 1

local function load(name, func, skip)
	if skip then
		total = total + 1
		return
	end
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
	list[#list + 1] = name
	return {true, err_or_ret}
end

local function load_include(path, name, skip)
	return load(name, function()
		return include("lithium/"..path)
	end, skip)
end

load("Hook System", function()
	local hook_table = hook.GetTable()
	require("hook_lithium")
	for event, event_table in pairs(hook_table) do
		for name, func in pairs(event_table) do
			hook.Add(event, name, func)
		end
	end
	if file.Exists("ulib/shared/hook.lua", "LUA") then -- ulib support
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
end, not enable_hook:GetBool())


if CLIENT then
	load_include("extensions/client/render.lua", "Render functions", not enable_renderutil:GetBool())
	load_include("extensions/client/be_render.lua", "Better Render", not enable_betterrender:GetBool())
	load_include("util/client.lua", "Client functions", not enable_clientutil:GetBool())
end

load_include("util.lua", "Util functions", not enable_utils:GetBool())

local loaded_total, total_total = loaded, total
lithium.log("Core systems startup complete. Loaded: "..loaded.."/"..total)

lithium.log("Auxiliary systems starting...")
loaded, total = 0, 0
if CLIENT then
	load_include("gpusaver.lua", "GPU Out-Of-Focus Saver", not enable_gpusaver:GetBool())
end

load_include("convars.lua", "Optimised ConVars", not enable_convars:GetBool())

loaded_total, total_total = loaded_total + loaded, total_total + total
lithium.log("Auxiliary systems startup complete. Loaded: "..loaded.."/"..total)

if CLIENT then
	hook.Add("InitPostEntity", "LITHIUM_Notify", function()
		notification.AddLegacy("[LITHIUM] Lithium is installed!", NOTIFY_HINT, 5)
		timer.Simple(5, function()
			notification.AddLegacy("[LITHIUM] "..loaded_total.."/"..total_total.." systems loaded", NOTIFY_GENERIC, 5)
			for _,name in pairs(list) do
				notification.AddLegacy("[LITHIUM] "..name.." system loaded", NOTIFY_GENERIC, 5)
			end
		end)
	end)
end

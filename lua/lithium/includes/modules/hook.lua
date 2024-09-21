AddCSLuaFile()

require("lithium")
lithium.log("'Lithium: Hook Module' override loading")

local hooks = {}
local hooks_backward = {}
local hooks_lookup = {}
local hook = {}
local locked = true
local gm = nil
local remove_check = true

HOOK_MONITOR_HIGH = -2
HOOK_HIGH = -1
HOOK_NORMAL = 0
HOOK_LOW = 1
HOOK_MONITOR_LOW = 2

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

function hook.GetTable()
	return hooks_backward
end

function hook.GetLithiumTables()
	return hooks, hooks_lookup
end

function hook.Add(event_name, name, func, priority)
	if not priority or not isnumber(priority) then priority = 0 end
	if not isstring(event_name) then
		return ErrorNoHaltWithStack("bad argument #1 to 'Add' (string expected, got "..type(event_name)..")")
	end
	if not isfunction(func) then
		return ErrorNoHaltWithStack("bad argument #3 to 'Add' (function expected, got "..type(func)..")")
	end
	local notValid = name == nil or isnumber(name) or isbool(name) or isfunction(name) or not name.IsValid or not name:IsValid()
	if not isstring(name) and notValid then
		return ErrorNoHaltWithStack("bad argument #2 to 'Add' (string expected, got "..type(name)..")")
	end
	if isnumber(name) then name = tostring(name) end

	local hook_table = hooks[event_name]
	local hook_lookup_table = hooks_lookup[event_name]
	if not hook_table then
		hooks[event_name] = {[-2]={}, [-1]={}, [0]={}, [1]={}, [2]={}}
		hooks_backward[event_name] = {}
		hooks_lookup[event_name] = {[-2]={}, [-1]={}, [0]={}, [1]={}, [2]={}}
		hook_table = hooks[event_name]
		hook_lookup_table = hooks_lookup[event_name]
	end
	hook_table = hook_table[priority]
	hook_lookup_table = hook_lookup_table[priority]

	if not isstring(name) then
		local real_func = func
		local isvalid = name.IsValid
		func = function(...)
			if not isvalid(name) then
				remove_check = false
				hook.Remove(event_name, name)
				remove_check = true
				return
			end
			return real_func(name, ...)
		end
	end

	local first_free = (table.maxn(hook_table) or 0) + 1
	for k=1, table.maxn(hook_table) do
		if hook_table[k] ~= nil then continue end
		first_free = k
		break
	end

	local id = hook_lookup_table[name] or first_free

	hook_lookup_table[id] = name
	hook_lookup_table[name] = id

	hook_table[id] = func

	hooks_backward[event_name][name] = func
end

function hook.Remove(event_name, name)
	if not hooks[event_name] then return end

	if not isstring(event_name) then
		return ErrorNoHaltWithStack("bad argument #1 to 'Remove' (string expected, got "..type(event_name)..")")
	end
	if remove_check then
		local notValid = name == nil or isnumber(name) or isbool(name) or isfunction(name) or not name.IsValid or not name:IsValid()
		if not isstring(name) and notValid then
			return ErrorNoHaltWithStack("bad argument #2 to 'Remove' (string expected, got "..type(name)..")")
		end
	end

	if isnumber(name) then name = tostring(name) end

	local hook_table = hooks[event_name]
	local hook_lookup_table = hooks_lookup[event_name]

	for priority=-2,2,1 do
		local id = hook_lookup_table[priority][name]
		if not id then
			continue
		end
		local hook_table = hook_table[priority]
		local hook_lookup_table = hook_lookup_table[priority]

		local fill_id = table.maxn(hook_table)
		local fill_name = hook_lookup_table[table.maxn(hook_table)]

		hook_table[id] = hook_table[fill_id]
		hook_lookup_table[id] = hook_lookup_table[fill_id]
		hook_lookup_table[name] = hook_lookup_table[fill_name]

		hook_table[fill_id] = nil
		hook_lookup_table[fill_id] = nil
		hook_lookup_table[fill_name] = nil
	end

	hooks_backward[event_name][name] = nil
end

function hook.Call(name, gm, ...)
	--do return end
	local a, b, c, d, e, f, v, hook_table
	for priority=-2,2,1 do
		if not hooks[name] then continue end
		hook_table = hooks[name][priority]

		if not hook_table then continue end
		for k=1, table.maxn(hook_table) do
			v = hook_table[k]
			if not v then continue end
			a, b, c, d, e, f = v(...)
			if a == nil or priority <= -2 or priority >= 2 then
				continue
			end
			return a, b, c, d, e, f
		end
	end

	if not gm then return end
	local gamemode_hook = gm[name]
	if not gamemode_hook then return end
	return gamemode_hook(gm, ...)
end

function hook.Run(name, ...)
	if not gm then gm = gmod and gmod.GetGamemode() or nil end
	return hook.Call(name, gm, ...)
end

return hook
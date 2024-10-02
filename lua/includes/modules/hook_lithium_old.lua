if hook.GetLithiumTables then return end

AddCSLuaFile()

require("lithium")

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

function hook.GetTable()
	return hooks_backward
end

function hook.GetLithiumTables()
	return hooks, hooks_lookup
end

function hook.Add(event_name, name, func, priority)
	lithium.debug("[HOOK] Add: "..tostring(event_name)..":"..tostring(name))
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

	local hook_table = hooks[event_name]
	local hook_lookup_table = hooks_lookup[event_name]
	if not hook_table then
		hooks[event_name] = {[-2]={}, [-1]={}, [0]={}, [1]={}, [2]={}}
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

	local id = hook_lookup_table[name] or (table.maxn(hook_table) + 1)

	remove_check = false
	hook.Remove(event_name, name)
	remove_check = true

	hook_lookup_table[id] = name
	hook_lookup_table[name] = id

	hook_table[id] = func

	if not hooks_backward[event_name] then
		hooks_backward[event_name] = {}
	end

	hooks_backward[event_name][name] = func
end

function hook.Remove(event_name, name)
	lithium.debug("[HOOK] Removed: "..tostring(event_name)..":"..tostring(name))
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

	local hook_table = hooks[event_name]
	local hook_lookup_table = hooks_lookup[event_name]

	for priority=-2,2,1 do
		local id = hook_lookup_table[priority][name]
		if not id then
			continue
		end
		local hook_table_i = hook_table[priority]
		local hook_lookup_table_i = hook_lookup_table[priority]

		hook_table_i[id] = nil
		hook_lookup_table_i[id] = nil
		hook_lookup_table_i[name] = nil
	end

	--print(event_name, name)
	if hooks_backward[event_name] then hooks_backward[event_name][name] = nil end
end

function hook.Call(name, gm, ...)
	--do return end
	local a, b, c, d, e, f, v, maxn, hook_table
	for priority=-2,2,1 do
		if not hooks[name] then continue end
		hook_table = hooks[name][priority]

		if not hook_table then continue end
		maxn = table.maxn(hook_table)
		for k=1, maxn do
			v = hook_table[k]
			if not v then continue end
			lithium.debug("[HOOK] Called: "..tostring(name)..": "..tostring(k).."/"..tostring(maxn))
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

module("hook")

Call = hook.Call
Run = hook.Run
Add = hook.Add
Remove = hook.Remove
GetTable = hook.GetTable
GetLithiumTables = hook.GetLithiumTables

return hook
if hook.GetULibTable then return end

require("lithium")

local hooks = {} -- hook table, for keeping tracks of hooks (in ULX format)
local hooks_backward = {} -- hook table for backward compability
local hooks_table = {} -- actual hook table that we use

local ErrorNoHaltWithStack = ErrorNoHaltWithStack
local isnumber = isnumber
local isstring = isstring
local isbool = isbool
local isfunction = isfunction
local type = type
local gmod = gmod
local table = table
local lithium = lithium
local string = string

HOOK_MONITOR_HIGH = -2
HOOK_HIGH = -1
HOOK_NORMAL = 0
HOOK_LOW = 1
HOOK_MONITOR_LOW = 2

module("hook")

function GetTable() return hooks_backward end
function GetULibTable() return hooks end
function GetLithiumTable() return hooks_table end

local empty = {}
local function FindInsertIndex(event, priority)
	if not hooks_table[event] then return 1 end
    local amount = 0
    for i=1,priority + 3,1 do
    	amount = amount + (hooks_table[event][i] or 0)
    end
    local went = 0
    for i=5,#hooks_table[event],3 do
    	if went == amount then
    		return i
    	end
    	went = went + 1
    end
    return #hooks_table[event] + 1
end

function Add(event, name, func, priority)
	lithium.debug(string.format("hook.Add(%q, %q, function, %s)", event, name, priority))
	if not priority or not isnumber(priority) then priority = 0 end
	if not isstring(event) then
		return ErrorNoHaltWithStack("bad argument #1 to 'Add' (string expected, got "..type(event)..")")
	end
	if not isfunction(func) then
		return ErrorNoHaltWithStack("bad argument #3 to 'Add' (function expected, got "..type(func)..")")
	end
	local notValid = name == nil or isnumber(name) or isbool(name) or isfunction(name) or not name.IsValid or not name:IsValid()
	if not isstring(name) and notValid then
		return ErrorNoHaltWithStack("bad argument #2 to 'Add' (string expected, got "..type(name)..")")
	end

	RemoveForce(event, name)

	-- cursed
	local hook_table = hooks[event] or {[-2]={}, [-1]={}, [0]={}, [1]={}, [2]={}}
	hooks[event] = hook_table
	hook_table = hook_table[priority]
	hooks[event][priority] = hook_table

	hooks_backward[event] = hooks_backward[event] or {}

	hook_table[name] = {fn=func, isstring=isstring(name)}
	hooks_backward[event][name] = func
	hooks_table[event] = hooks_table[event] or {0, 0, 0, 0, 0}

	local insert_pos = FindInsertIndex(event, priority) + 1
	table.insert(hooks_table[event], insert_pos, func)
	table.insert(hooks_table[event], insert_pos + 1, isstring(name))
	table.insert(hooks_table[event], insert_pos + 2, name)
	hooks_table[event][priority + 3] = hooks_table[event][priority + 3] + 1
end

function Remove(event, name)
	lithium.debug(string.format("hook.Remove(%q, %q)", event, name))
	if not isstring(event) then
		return ErrorNoHaltWithStack("bad argument #1 to 'Remove' (string expected, got "..type(event)..")")
	end
	local notValid = name == nil or isnumber(name) or isbool(name) or isfunction(name) or not name.IsValid or not name:IsValid()
	if not isstring(name) and notValid then
		return ErrorNoHaltWithStack("bad argument #2 to 'Remove' (string expected, got "..type(name)..")")
	end
	return RemoveForce(event, name)
end

function RemoveForce(event, name)
	if not hooks_backward[event] then return end
	for i=-2,2,1 do
		hooks[event][i][name] = nil
	end
	hooks_backward[event][name] = nil

	local pr_n2 = FindInsertIndex(event, -2) + 1
	local pr_n1 = FindInsertIndex(event, -1) + 1
	local pr_z0 = FindInsertIndex(event,  0) + 1
	local pr_p1 = FindInsertIndex(event,  1) + 1

	local hook_table = hooks_table[event]
	if not hook_table then return end
	local maxn = #hook_table
	local done = false
	while not done do
		for i=6,maxn,3 do
			local name2 = hook_table[i + 2]
			if name2 == name then
				done = true
				table.remove(hook_table, i)
				table.remove(hook_table, i)
				table.remove(hook_table, i)
				if     i >= pr_p1 then hook_table[5] = hook_table[5] - 1
				elseif i >= pr_z0 then hook_table[4] = hook_table[4] - 1
				elseif i >= pr_n1 then hook_table[3] = hook_table[3] - 1
				elseif i >= pr_n2 then hook_table[2] = hook_table[2] - 1
				else 				  hook_table[1] = hook_table[1] - 1
				end
				break
			end
		end
		if done then
			done = false
			continue
		end
		break
	end
end

local name
function CallPartNoReturn(hook_table, event, i, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
	if hook_table[i + 1] then
		hook_table[i](arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
	else
		name = hook_table[i + 2]
		if not name then return end
		if not name:IsValid() then
			return RemoveForce(event, name)
		end
		hook_table[i](name, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
	end
end
function CallPart(hook_table, event, i, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
	if hook_table[i + 1] then
		return hook_table[i](arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
	else
		name = hook_table[i + 2]
		if not name then return end
		if not name:IsValid() then
			return RemoveForce(event, name)
		end
		return hook_table[i](name, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
	end
end

function Call(event, gm, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
	lithium.debug(string.format("hook.Call(%q)", event))
	--do return end
	local hook_table = hooks_table[event]
	if hook_table then
		local n1, p2 = FindInsertIndex(event, -2), FindInsertIndex(event, 1)

		local a, b, c, d, e, f
		local maxn = #hook_table
		for i=6,n1,3 do
			CallPartNoReturn(hook_table, event, i, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
		end
		for i=n1+1,p2,3 do
			a, b, c, d, e, f = CallPart(hook_table, event, i, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
			if a ~= nil then return a, b, c, d, e, f end
		end
		for i=p2+1,maxn,3 do
			CallPartNoReturn(hook_table, event, i, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
		end
	end
	if gm and gm[event] then return gm[event](gm, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) end
end

local gm = nil
function Run(event, ...)
	if not gm then gm = gmod and gmod.GetGamemode() or nil end
	return Call(event, gm, ...)
end


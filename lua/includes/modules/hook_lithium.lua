AddCSLuaFile()

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
local CompileString = CompileString
local pairs = pairs
local print = print
local PrintTable = PrintTable
local unpack = unpack
local gmod = gmod
local getfenv = getfenv
local setfenv = setfenv
local string = string
local error = error
local tostring = tostring
local table = table
local istable = istable
local util = util

HOOK_MONITOR_HIGH = -2
HOOK_HIGH = -1
HOOK_NORMAL = 0
HOOK_LOW = 1
HOOK_MONITOR_LOW = 2

module("hook")

local table_was_accessed, table_access_copy = false, nil

function GetTable() return hooks_backward end
function GetULibTable()
	table_was_accessed = true
	table_access_copy = table.Copy(hooks)
	return hooks
end
function GetLithiumTable() return hooks_table end

function ReorderHookTable(event)
	local hook_table = {}
	hooks_table[event] = hook_table
	local hook_n = 0
	hook_table[1] = -1
	hook_table[2] = -1
	for priority=-2,2 do
		if priority == -1 then
			hook_table[1] = hook_n - 1
		end
		if priority == 2 and hook_table[2] == -1 then
			hook_table[2] = hook_n
		end
		if not hooks[event][priority] then continue end
		for _,hook in pairs(hooks[event][priority]) do
			hook_n = hook_n + 1
			if not hook.isstring then
				hook_table[#hook_table + 1] = 0
				hook_table[#hook_table + 1] = hook.fn
				hook_table[#hook_table + 1] = _
			else
				hook_table[#hook_table + 1] = hook.fn
				hook_table[#hook_table + 1] = 0
				hook_table[#hook_table + 1] = 0
			end
		end
	end
end

function Add(event, name, func, priority)
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

	-- cursed
	local hook_table = hooks[event] or {[-2]={}, [-1]={}, [0]={}, [1]={}, [2]={}}
	hooks[event] = hook_table
	hook_table = hook_table[priority]
	hooks[event][priority] = hook_table

	hooks_backward[event] = hooks_backward[event] or {}

	hook_table[name] = {fn=func, isstring=isstring(name)}
	hooks_backward[event][name] = func
	ReorderHookTable(event)
end

function Remove(event, name)
	if not isstring(event) then
		return ErrorNoHaltWithStack("bad argument #1 to 'Remove' (string expected, got "..type(event)..")")
	end
	local notValid = name == nil or isnumber(name) or isbool(name) or isfunction(name) or not name.IsValid or not name:IsValid()
	if not isstring(name) and notValid then
		return ErrorNoHaltWithStack("bad argument #2 to 'Remove' (string expected, got "..type(name)..")")
	end
	if not hooks_backward[event] then return end
	for i=-2,2,1 do
		hooks[event][i][name] = nil
	end
	hooks_backward[event][name] = nil
	ReorderHookTable(event)
end

function Call(event, gm, ...)
	if table_was_accessed then
		local hashes = {}
		for event, h_table in pairs(hooks) do
			hashes[event] = util.MD5(util.TableToJSON(h_table))
		end
		for event, h_table in pairs(table_access_copy) do
			if hashes[event] ~= util.MD5(util.TableToJSON(h_table)) then
				ReorderHookTable(event)
			end
		end
		table_was_accessed = false
		table_access_copy = nil
	end
	local hook_table = hooks_table[event]
	if hook_table then
		local n1, p2 = 3 + hook_table[1] * 3, 3 + hook_table[2] * 3

		local priority, a, b, c, d, e, f, name, h
		local maxn = #hook_table
		for i=3,maxn,3 do
			h = hook_table[i]
			if h ~= 0 then
				if i > n1 and i < p2 then
					a, b, c, d, e, f = h(...)
					if a ~= nil then return a, b, c, d, e, f end
				else
					h(...)
				end
			else
				h = hook_table[i + 1]
				name = hook_table[i + 2]
				if not name:IsValid() then
					for i=-2,2,1 do hooks[event][i][name] = nil end
					hooks_backward[event][name] = nil
					ReorderHookTable(event) -- i really don't like that, can we just shift everything down?
					continue
				end
				if i > n1 and i < p2 then
					a, b, c, d, e, f = h(name, ...)
					if a ~= nil then return a, b, c, d, e, f end
				else
					h(name, ...)
				end
			end
		end
	end
	if gm and gm[event] then return gm[event](gm, ...) end
end

local gm = nil
function Run(event, ...)
	if not gm then gm = gmod and gmod.GetGamemode() or nil end
	return Call(event, gm, ...)
end
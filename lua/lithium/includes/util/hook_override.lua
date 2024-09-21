AddCSLuaFile()

local hook_lithium = include("lithium/includes/modules/hook.lua")

local hook_table = hook.GetTable()
for event, event_table in pairs(hook_table) do
	for name, func in pairs(event_table) do
		hook_lithium.Add(event, name, func)
	end
end
local old_hook = _G.hook
_G.hook = hook_lithium
table.Empty(old_hook.GetTable())
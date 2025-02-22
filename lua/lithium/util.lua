AddCSLuaFile()

local ConVarCache = {}
local MaterialCache = {}

_G.LITHIUM_CreateConVar_old = _G.LITHIUM_CreateConVar_old or CreateConVar
function CreateConVar(name, default, iFlags, helptext, min, max)
	local convar = LITHIUM_CreateConVar_old(name, default, iFlags, helptext, min, max)
	ConVarCache[name] = convar
	return convar
end

function GetConVar(name)
	local convar = ConVarCache[name]
	if convar then
		return convar
	end
	convar = GetConVar_Internal(name)
	if not convar then
		return
	end
	ConVarCache[name] = convar
	return convar
end

function GetConVarNumber(name)
	if name == "maxplayers" then return game.MaxPlayers() end
	local convar = GetConVar(name)
	return convar and convar:GetFloat() or 0
end

function GetConVarString(name)
	if name == "maxplayers" then return tostring(game.MaxPlayers()) end
	local convar = GetConVar(name)
	return convar and convar:GetString() or ""
end

_G.LITHIUM_Material_old = _G.LITHIUM_Material_old or Material
function Material(name, words)
	if name == "" and words == nil then -- the fuck?
		return LITHIUM_Material_old(name, words)
	end
	local r_words = words
	if words == nil then words = false end
	if MaterialCache[name] and MaterialCache[name][words] then
		return MaterialCache[name][words]
	end
	if not MaterialCache[name] then
		MaterialCache[name] = {}
	end
	MaterialCache[name][words] = LITHIUM_Material_old(name, r_words)
	return Material(name, r_words)
end

function IsValid(data)
	return data and (isnumber(data) or isstring(data) or data.IsValid and data:IsValid())
end
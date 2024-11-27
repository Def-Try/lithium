AddCSLuaFile()

local ConVarCache = {}
local MaterialCache = {}

_G.CreateConVar_old = _G.CreateConVar_old or CreateConVar
function CreateConVar(name, default, iFlags, helptext, min, max)
	lithium.debug("[UTIL] ConVar Create: "..tostring(name))
	local convar = CreateConVar_old(name, default, iFlags, helptext, min, max)
	ConVarCache[name] = convar
	return convar
end

function GetConVar(name)
	lithium.debug("[UTIL] ConVar Get: "..tostring(name))
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
	lithium.debug("[UTIL] ConVar GetNumber: "..tostring(name))
	if name == "maxplayers" then return game.MaxPlayers() end
	local convar = GetConVar(name)
	return convar and convar:GetFloat() or 0
end

function GetConVarString(name)
	lithium.debug("[UTIL] ConVar GetString: "..tostring(name))
	if name == "maxplayers" then return tostring(game.MaxPlayers()) end
	local convar = GetConVar(name)
	return convar and convar:GetString() or ""
end

_G.Material_old = _G.Material_old or Material
function Material(name, words)
	lithium.debug(string.format("[UTIL] Material: %q %q", name, words))
	if name == "" and words == nil then
		return Material_old(name, words)
	end
	local r_words = words
	if words == nil then words = false end
	if MaterialCache[name] and MaterialCache[name][words] then
		return MaterialCache[name][words]
	end
	if not MaterialCache[name] then
		MaterialCache[name] = {}
	end
	MaterialCache[name][words] = Material_old(name, r_words)
	return Material(name, r_words)
end

function IsValid(data)
	return data and data.IsValid and data:IsValid()
end
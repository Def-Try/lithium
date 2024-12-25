if CLIENT then
	_G.lithium_LOCALPLAYER = _G.lithium_LOCALPLAYER or LocalPlayer
	local localplayer = nil
	function LocalPlayer()
		if localplayer then return localplayer end
		local localplayer_ = _G.lithium_LOCALPLAYER()
		if IsValid(localplayer_) then
			localplayer = localplayer_
		end
		return localplayer_
	end
end

local ENTITY = FindMetaTable("Entity")
local ENTITY_EntIndex = ENTITY.EntIndex
local ENTITY_IsValid = ENTITY.IsValid
_G.LITHIUM_entlist = _G.LITHIUM_entlist or {}
local entlist = _G.LITHIUM_entlist
_G.LITHIUM_OldEntity = _G.LITHIUM_OldEntity or Entity
local OldEntity = _G.LITHIUM_OldEntity

local tonumber = tonumber
local isnumber = isnumber

hook.Add("OnEntityCreated", "LITHIUM_CacheEntity", function(ent)
	if not ent:IsValid() then return end
	local idx = ENTITY_EntIndex(ent)
	if idx == -1 then return end
	if idx == 0 then return end
	entlist[idx] = ent
end)

hook.Add("EntityRemoved", "LITHIUM_CacheEntity", function(ent, fullupdate)
	if fullupdate then return end
	local idx = ENTITY_EntIndex(ent)
	if idx == -1 then return end
	if idx == 0 then return end
	entlist[idx] = nil
end)
function Entity(entindex)
	if not isnumber(entindex) then entindex = tonumber(entindex) end
	local ent = entlist[entindex]
	if not ent then
		ent = OldEntity(entindex)
		
		if entindex ~= 0 then
			if ent and ENTITY_IsValid(ent) then entlist[entindex] = ent end
		end
	end
	return ent
end

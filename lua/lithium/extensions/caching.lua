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

_G.LITHIUM_entlist = _G.LITHIUM_entlist or {}

hook.Add("OnEntityCreated", "LITHIUM_CacheEntity", function(ent)
	if not ent:IsValid() then return end
	_G.LITHIUM_entlist[ent:EntIndex()] = ent
end)

hook.Add("EntityRemoved", "LITHIUM_CacheEntity", function(ent, fullupdate)
	if fullupdate then return end

	_G.LITHIUM_entlist[ent:EntIndex()] = nil
end)
_G.LITHIUM_OldEntity = _G.LITHIUM_OldEntity or Entity
function Entity(entindex)
	local ent = _G.LITHIUM_entlist[entindex] or _G.LITHIUM_entlist[tonumber(entindex)] or NULL
	if not ent then
		ent = _G.LITHIUM_OldEntity(entindex)
		if ent and ent:IsValid() then _G.LITHIUM_entlist[entindex] = ent end
	end
	return ent
end

include("optimised_draw.lua")

local isnumber = isnumber
local cam_Start = cam.Start
local ClientsideModel = ClientsideModel
local ENTITY = FindMetaTable("Entity")
local ENTITY_IsValid = ENTITY.IsValid
local ENTITY_GetModelScale = ENTITY.GetModelScale
local ENTITY_SetModelScale = ENTITY.SetModelScale
local ENTITY_Activate = ENTITY.Activate
local ENTITY_GetBoneCount = ENTITY.GetBoneCount
local ENTITY_ManipulateBoneScane = ENTITY.ManipulateBoneScale
local ENTITY_SetModel = ENTITY.SetModel
local ENTITY_SetNoDraw = ENTITY.SetNoDraw
local ENTITY_SetPos = ENTITY.SetPos
local ENTITY_SetAngles = ENTITY.SetAngles
local ENTITY_DrawModel = ENTITY.DrawModel

local cam_start2d = {type = '2D'}
local cam_start3d = {type = '3D'}

function cam.Start2D()
	cam_Start(cam_start2d)
end

function cam.Start3D(pos, ang, fov, x, y, w, h, znear, zfar)
	local tab = cam_start3d

	tab.origin = pos
	tab.angles = ang
	tab.fov = fov

	if isnumber(x) and isnumber(y) and isnumber(w) and isnumber(h) then
		tab.x, tab.y, tab.w, tab.hm, tab.aspect = x, y, w, h, (w / h)
	else
		tab.x, tab.y, tab.w, tab.hm, tab.aspect = nil, nil, nil, nil, nil
	end

	if isnumber(znear) and isnumber(zfar) then
		tab.znear, tab.zfar = znear, zfar
	else
		tab.znear, tab.zfar = nil, nil
	end

	return cam_Start(tab)
end

local cs_entity = nil
function render.Model(tbl, ent)
	if ent == nil or not ENTITY_IsValid(ent) then
		if cs_entity == nil or not ENTITY_IsValid(cs_entity) then
			cs_entity = ClientsideModel(tbl.model or "error.mdl", RENDERGROUP_OTHER)
		end
		ent = cs_entity
		if ENTITY_GetModelScale(ent) ~= 1 then
			ENTITY_SetModelScale(ent, 1, 0.000001)
			ENTITY_Activate(ent)
		end
		for bone=0, ENTITY_GetBoneCount(ent)-1 do
			ENTITY_ManipulateBoneScale(ent, bone, Vector(1, 1, 1))
		end
	end

	-- just in case
	if ent == nil or not ENTITY_IsValid(ent) then return end

	ENTITY_SetModel(ent, tbl.model or "error.mdl")
	ENTITY_SetNoDraw(ent, true)

	ENTITY_SetPos(ent, tbl.pos or vector_origin)
	ENTITY_SetAngles(ent, tbl.angle or angle_zero)
	ENTITY_DrawModel(ent)
end
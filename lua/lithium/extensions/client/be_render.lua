-- Better Entity Rendering: only render entities that are realistically visible
-- credit to noaccessl. dm me at @googer_ in discord if you don't want your code there!

require("lithium")
lithium.log("Hi from noaccessl PerformantRender!")

local VECTOR = FindMetaTable('Vector')
local ENTITY = FindMetaTable('Entity')

local VECTOR_DistToSqr = VECTOR.DistToSqr
local VECTOR_Set = VECTOR.Set
local VECTOR_Sub = VECTOR.Sub
local VECTOR_Normalize = VECTOR.Normalize
local VECTOR_Dot = VECTOR.Dot

local SPARE_VECTOR_1 = Vector()
local VIEW_ORIGIN
local VIEW_ANGLE
local FOV_VIEW
local MYSELF = NULL

local ENTITY_IsValid = ENTITY.IsValid
local ENTITY_IsDormant = ENTITY.IsDormant
local ENTITY_GetPos = ENTITY.GetPos
local ENTITY_GetRenderBounds = ENTITY.GetRenderBounds
local ENTITY_SetNoDraw = ENTITY.SetNoDraw
local ENTITY_GetNoDraw = ENTITY.GetNoDraw
local ENTITY_RemoveEFlags = ENTITY.RemoveEFlags
local ENTITY_AddEFlags = ENTITY.AddEFlags
ENTITY.SetRenderBounds_I = ENTITY.SetRenderBounds_I or ENTITY.SetRenderBounds
ENTITY.SetRenderBoundsWS_I = ENTITY.SetRenderBoundsWS_I or ENTITY.SetRenderBoundsWS

local ANGLE_Forward = FindMetaTable('Angle').Forward

local MATH_cos = math.cos
local MATH_DEG_2_RAD = math.pi / 180

local RENDER_GetFogDistances = render.GetFogDistances
local RENDER_GetFogMode = render.GetFogMode
local UTIL_PixelVisible = util.PixelVisible

local EFL_NO_THINK_FUNCTION = EFL_NO_THINK_FUNCTION

g_Renderables		 = g_Renderables or {}
g_Renderables_Lookup = g_Renderables_Lookup or {}

local function IsInFOV(view_origin, view_direction, point, fov_cos)
	VECTOR_Set(SPARE_VECTOR_1, point)
	VECTOR_Sub(SPARE_VECTOR_1, view_origin)
	VECTOR_Normalize(SPARE_VECTOR_1)
	return VECTOR_Dot(view_direction, SPARE_VECTOR_1) > fov_cos
end

local function CalculateDiagonal(entity)
	local mins, maxs = ENTITY_GetRenderBounds(entity)
	local diagonal_sqr = VECTOR_DistToSqr(mins, maxs)

	local entity_t = g_Renderables_Lookup[entity]

	entity_t.diagonal_sqr = diagonal_sqr * 1.3225
	entity_t.diagonal = diagonal_sqr ^ 0.5
end

function ENTITY:SetRenderBounds(mins, maxs, add)
	self:SetRenderBounds_I(mins, maxs, add)
	if self.m_bRenderable then CalculateDiagonal(self) end
end

function ENTITY:SetRenderBoundsWS(mins, maxs, add)
	self:SetRenderBoundsWS_I(mins, maxs, add)
	if self.m_bRenderable then CalculateDiagonal(self) end
end

function RegisterRenderable(entity)
	entity.m_bRenderable = true
	g_Renderables_Lookup[entity] = {
		visible = true,
		outside_pvs = false,
		pix_vis = util.GetPixelVisibleHandle()
	}
	CalculateDiagonal(entity)
	table.insert(g_Renderables, entity)
end

function RegisterPotentialRenderable(entity, force)
	timer.Simple(0, function()
		if not IsValid(entity) then return end
		local class = entity:GetClass()
		if class:sub(6, 9) == "door" then return end
		if ENTITY_GetNoDraw(entity) then return end
		local model = entity:GetModel()
		if not isstring(model) then return end
		if not model:StartsWith("models") or model == "models/error.mdl" then return end
		if entity:IsPlayer() or entity:IsWeapon() or not entity:IsSolid() then return end
		RegisterRenderable(entity)
	end)
end
hook.Add("OnEntityCreated", "LITHIUM_PerformantRender", RegisterPotentialRenderable)

local function CalculateRenderablesVisibility(view_origin, view_angle, fov)
	local g_Renderables = g_Renderables
	local amount = #g_Renderables

	if amount == 0 then return end

	local g_Renderables_Lookup = g_Renderables_Lookup
	local view_direction = ANGLE_Forward(view_angle)
	local fov_cos = MATH_cos(MATH_DEG_2_RAD * (fov * 0.75))

	for i=1, amount do
		local entity = g_Renderables[i]
		if not entity or not ENTITY_IsValid(entity) then
			table.remove(g_Renderables, i)
			g_Renderables_Lookup[entity] = nil
			break
		end
		if ENTITY_IsDormant(entity) then continue end
		local origin = ENTITY_GetPos(entity)
		if not IsInFOV(view_origin, view_direction, origin, fov_cos) then continue end
		local entity_t = g_Renderables_Lookup[entity]
		local diagonal_sqr = entity_t.diagonal_sqr
		local dist_sqr = VECTOR_DistToSqr(view_origin, origin)
		local in_fog = false
		if false and RENDER_GetFogMode() ~= 0 then -- TODO: verify: causes issues?
			local _, fog_end = RENDER_GetFogDistances()
			if fog_end > 0 then
				in_fog = dist_sqr > fog_end * fog_end + diagonal_sqr
			end
		end
		local visible, outside_pvs = false, false
		if in_fog then
			outside_pvs = true
		else
			local in_distance = dist_sqr <= diagonal_sqr
			local radius = entity_t.diagonal
			if in_distance then
				radius = (radius - (radius - dist_sqr ^ 0.5))
			end

			visible = UTIL_PixelVisible(origin, radius, entity_t.pix_vis) > 0
			if not visible and in_distance then
				visible = true
			end
		end
		local no_draw = ENTITY_GetNoDraw(entity)
		if visible then
			if no_draw then
				ENTITY_SetNoDraw(entity, false)
				ENTITY_RemoveEFlags(entity, EFL_NO_THINK_FUNCTION)
			end
			entity_t.visible = true
		else
			if not no_draw then
				ENTITY_SetNoDraw(entity, true)
				ENTITY_AddEFlags(entity, EFL_NO_THINK_FUNCTION)
			end
			entity_t.visible = false
		end
		entity_t.outside_pvs = outside_pvs
	end
end

hook.Add('PreRender', 'CalculateRenderablesVisibility', function()
	if MYSELF.tardis or not VIEW_ORIGIN then return end
	CalculateRenderablesVisibility(VIEW_ORIGIN, VIEW_ANGLE, FOV_VIEW)
end)

hook.Add('RenderScene', 'CalculateRenderablesVisibility', function(view_origin, view_angle, fov)
	if not ENTITY_IsValid(MYSELF) then
		MYSELF = LocalPlayer()
	end
	VIEW_ORIGIN = view_origin
	VIEW_ANGLE = view_angle
	FOV_VIEW = fov
end)

gameevent.Listen('entity_killed')
hook.Add('entity_killed', 'FixVisibleDeadNPCs', function(data)
	local npc = Entity(data.entindex_killed)
	if not npc:IsNPC() then
		return
	end
	ENTITY_SetNoDraw(npc, false)
	ENTITY_RemoveEFlags(npc, EFL_NO_THINK_FUNCTION)
	npc.m_bRenderable = nil
	for index, entity in ipairs(g_Renderables) do
		if entity == npc then
			table.remove(g_Renderables,index)
			g_Renderables_Lookup[npc] = nil
			break
		end
	end
end)

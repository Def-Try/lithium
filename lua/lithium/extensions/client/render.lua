AddCSLuaFile()

-- We don't want this to run in menu state, and render.GetAmbientLightColor doesn't exist in menu state
if not render or not render.GetAmbientLightColor then return end

include("optimised_draw.lua")

--[[---------------------------------------------------------
  Short aliases for stencil constants
-----------------------------------------------------------]]

STENCIL_NEVER = STENCILCOMPARISONFUNCTION_NEVER
STENCIL_LESS = STENCILCOMPARISONFUNCTION_LESS
STENCIL_EQUAL = STENCILCOMPARISONFUNCTION_EQUAL
STENCIL_LESSEQUAL = STENCILCOMPARISONFUNCTION_LESSEQUAL
STENCIL_GREATER = STENCILCOMPARISONFUNCTION_GREATER
STENCIL_NOTEQUAL = STENCILCOMPARISONFUNCTION_NOTEQUAL
STENCIL_GREATEREQUAL = STENCILCOMPARISONFUNCTION_GREATEREQUAL
STENCIL_ALWAYS = STENCILCOMPARISONFUNCTION_ALWAYS

STENCIL_KEEP = STENCILOPERATION_KEEP
STENCIL_ZERO = STENCILOPERATION_ZERO
STENCIL_REPLACE = STENCILOPERATION_REPLACE
STENCIL_INCRSAT = STENCILOPERATION_INCRSAT
STENCIL_DECRSAT = STENCILOPERATION_DECRSAT
STENCIL_INVERT = STENCILOPERATION_INVERT
STENCIL_INCR = STENCILOPERATION_INCR
STENCIL_DECR = STENCILOPERATION_DECR

function render.ClearRenderTarget(rt, color)
	color = color or color_black
	render.PushRenderTarget(rt)
		render.Clear(color.r or 0, color.g or 0, color.b or 0, color.a or 255)
	render.PopRenderTarget()
end

function render.SupportsHDR()
	return render.GetDXLevel() >= 80
end

function render.CopyTexture(from, to)
	render.PushRenderTarget(from)
		render.CopyRenderTargetToTexture(to)
	render.PopRenderTarget()
end

local color_material		 = Material("color")
local color_ignorez_material = Material("color_ignorez")

function render.SetColorMaterial()
	render.SetMaterial(color_material)
end
function render.SetColorMaterialIgnoreZ()
	render.SetMaterial(color_ignorez_material)
end

local material_blurx			= Material("pp/blurx")
local material_blury			= Material("pp/blury")
local texture_bloom1			= render.GetBloomTex1()
function render.BlurRenderTarget(rt, sizex, sizey, passes)
	if passes == 0 then return end
	if sizex == 0 and sizey == 0 then return end

	material_blurx:SetTexture("$basetexture", rt)
	material_blury:SetTexture("$basetexture", texture_bloom1)
	material_blurx:SetFloat("$size", sizex)
	material_blury:SetFloat("$size", sizey)
	for i=0, passes do
		render.SetRenderTarget(texture_bloom1)
		render.SetMaterial(material_blurx)
		render.DrawScreenQuad()

		render.SetRenderTarget(rt)
		render.SetMaterial(material_blury)
		render.DrawScreenQuad()
	end
end

local cam_start2d = {type = '2D'}
local cam_start3d = {type = '3D'}

function cam.Start2D()
	cam.Start(cam_start2d)
end

function cam.Start3D(pos, ang, fov, x, y, w, h, znear, zfar)
	local tab = cam_start3d
	local isnumber = isnumber

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

	return cam.Start(tab)
end

local matFSB = Material("pp/motionblur")
function render.DrawTextureToScreen(tex)
	matFSB:SetFloat("$alpha", 1.0)
	matFSB:SetTexture("$basetexture", tex)

	render.SetMaterial(matFSB)
	render.DrawScreenQuad()
end

function render.DrawTextureToScreenRect(tex, x, y, w, h)
	matFSB:SetFloat("$alpha", 1.0)
	matFSB:SetTexture("$basetexture", tex)

	render.SetMaterial(matFSB)
	render.DrawScreenQuadEx(x, y, w, h)
end

local cs_entity = nil
function render.Model(tbl, ent)
	local inent = ent

	if not IsValid(ent) then
		if not IsValid(cs_entity) then
			cs_entity = ClientsideModel(tbl.model or "error.mdl", RENDERGROUP_OTHER)
		end
		ent = cs_entity
		if ent:GetModelScale() ~= 1 then
			ent:SetModelScale(1, 0.000001)
			ent:Activate()
		end
	end

	if not IsValid(ent) then return end

	ent:SetModel(tbl.model or "error.mdl")
	ent:SetNoDraw(true)

	ent:SetPos(tbl.pos or vector_origin)
	ent:SetAngles(tbl.angle or angle_zero)
	ent:DrawModel()
end
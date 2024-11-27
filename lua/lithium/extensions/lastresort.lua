require("niknaks") -- bsp parser

if not NikNaks then return end

local function calc_lighting(pos, normal) 
	local surface = render.GetLightColor(pos + normal)
	--local exposure = render.ComputeLighting(pos + normal, normal)
	
	local final = (surface)
	final[1] = math.min(final[1]^(1 / 2.2), 1)
	final[2] = math.min(final[2]^(1 / 2.2), 1)
	final[3] = math.min(final[3]^(1 / 2.2), 1)
	final = final * 255
	
	--return final[1], final[2], final[3], 255
	return math.abs(normal.x * 127) + final[1] / 255 * 127,
		   math.abs(normal.y * 127) + final[2] / 255 * 127,
		   math.abs(normal.z * 127) + final[3] / 255 * 127,
		   255
end

if false  then
	for i=1,(_G.LITHIUM_MAPMESHES and #_G.LITHIUM_MAPMESHES or 0) do
		pcall(function() _G.LITHIUM_MAPMESHES[i]:Destroy() end)
	end
	_G.LITHIUM_MAPMESHES = nil
	_G.LITHIUM_MAPMINMAXS = nil
end

hook.Add("ShutDown", "LITHIUM_KILLLASTRESORTMESHES", function()
	for i=1,(_G.LITHIUM_MAPMESHES and #_G.LITHIUM_MAPMESHES or 0) do
		pcall(function() _G.LITHIUM_MAPMESHES[i]:Destroy() end)
	end
end)

local MAX_TRIANGLES = 10922
local function generate_map_meshes()
	local function do_face(v, vmid)
		mesh.Position(v.pos)
		mesh.TexCoord(0, v.u, v.v)
		mesh.Normal(v.normal)
		mesh.UserData(0, 0, 0, 0)
		mesh.Color(calc_lighting(v.pos + (vmid - v.pos):GetNormalized(), v.normal))
		mesh.AdvanceVertex()
	end

	local minmaxs = {}
	local imeshes = {}
	local imesh = Mesh()
	local p1, p2, p3, p4, p5, p6, p7, p8 = Vector(), Vector(), Vector(), Vector(),
										   Vector(), Vector(), Vector(), Vector()
	mesh.Begin(imesh, MATERIAL_TRIANGLES, MAX_TRIANGLES)
	--for _, leaf in ipairs(NikNaks.CurrentMap:GetLeafs()) do
	for _, face in ipairs(NikNaks.CurrentMap:GetFaces(true)) do

		if !face:IsWorld() then continue end
		
		local face_vertices = face:GenerateVertexTriangleData()
		if !face_vertices then continue end

		for v = 1, #face_vertices, 3 do
			local succ, str = pcall(function()
			local v1 = face_vertices[v    ]
			local v2 = face_vertices[v + 1]
			local v3 = face_vertices[v + 2]

			local vmid = (v1.pos + v2.pos + v3.pos) / 3

			do_face(v1, vmid)
			do_face(v2, vmid)
			do_face(v3, vmid)
			p1 = Vector(math.min(p1.x, v1.pos.x, v2.pos.x, v3.pos.x), -- 0
						math.min(p1.y, v1.pos.y, v2.pos.y, v3.pos.y), -- 0
						math.min(p1.z, v1.pos.z, v2.pos.z, v3.pos.z)) -- 0

			p2 = Vector(math.max(p2.x, v1.pos.x, v2.pos.x, v3.pos.x), -- 1
						math.min(p2.y, v1.pos.y, v2.pos.y, v3.pos.y), -- 0
						math.min(p2.z, v1.pos.z, v2.pos.z, v3.pos.z)) -- 0

			p3 = Vector(math.min(p3.x, v1.pos.x, v2.pos.x, v3.pos.x), -- 0
						math.max(p3.y, v1.pos.y, v2.pos.y, v3.pos.y), -- 1
						math.min(p3.z, v1.pos.z, v2.pos.z, v3.pos.z)) -- 0

			p4 = Vector(math.max(p4.x, v1.pos.x, v2.pos.x, v3.pos.x), -- 1
						math.max(p4.y, v1.pos.y, v2.pos.y, v3.pos.y), -- 1
						math.min(p4.z, v1.pos.z, v2.pos.z, v3.pos.z)) -- 0

			p5 = Vector(math.min(p5.x, v1.pos.x, v2.pos.x, v3.pos.x), -- 0
						math.min(p5.y, v1.pos.y, v2.pos.y, v3.pos.y), -- 0
						math.max(p5.z, v1.pos.z, v2.pos.z, v3.pos.z)) -- 1

			p6 = Vector(math.max(p6.x, v1.pos.x, v2.pos.x, v3.pos.x), -- 1
						math.min(p6.y, v1.pos.y, v2.pos.y, v3.pos.y), -- 0
						math.max(p6.z, v1.pos.z, v2.pos.z, v3.pos.z)) -- 1

			p7 = Vector(math.min(p7.x, v1.pos.x, v2.pos.x, v3.pos.x), -- 0
						math.max(p7.y, v1.pos.y, v2.pos.y, v3.pos.y), -- 1
						math.max(p7.z, v1.pos.z, v2.pos.z, v3.pos.z)) -- 1

			p8 = Vector(math.max(p8.x, v1.pos.x, v2.pos.x, v3.pos.x), -- 1
						math.max(p8.y, v1.pos.y, v2.pos.y, v3.pos.y), -- 1
						math.max(p8.z, v1.pos.z, v2.pos.z, v3.pos.z)) -- 1
			end)

			if not succ then print(str) end
		end
		
		if mesh.VertexCount() >= MAX_TRIANGLES then
			mesh.End()
			table.insert(imeshes, imesh)
			table.insert(minmaxs, {p1, p2, p3, p4, p5, p6, p7, p8})

			imesh = Mesh()
			mesh.Begin(imesh, MATERIAL_TRIANGLES, MAX_TRIANGLES)
		end
	end
	--end
	mesh.End()
	table.insert(imeshes, imesh)
	table.insert(minmaxs, {p1, p2, p3, p4, p5, p6, p7, p8}) 

	return imeshes, minmaxs
end

local map_unlit = CreateMaterial("map_unlit", "UnlitGeneric", {
	["$basetexture"] = "lights/white",
	["$vertexcolor"] = 1,
})

local map_lit = CreateMaterial("map_lit", "VertexLitGeneric", {
	["$basetexture"] = map_unlit:GetString("$basetexture")
})

local eyepos, eyeang, fov, detoured_localplayer = Vector(), Angle(0), 0, false

function EyePos() return eyepos end
function EyeAngles() return eyeang end

local vm_fov = GetConVar("viewmodel_fov")

function render.RenderView(view)
	local vm = LocalPlayer():GetViewModel()
	local view = table.Copy(view)
	view["type"] = "3D"
	--cam.Start2D()
	render.Clear(0, 0, 0, 0, true, true)
	cam.Start(view)
		-- draw map
		render.SetMaterial(map_unlit)
		for _, imesh in ipairs(_G.LITHIUM_MAPMESHES) do
			-- TODO: """PVS""", check if camera is in box in _G.LITHIUM_MAPMINMAXS
			imesh:Draw()
		end
		-- draw map flashlight
		render.SetMaterial(map_lit)
		for _, imesh in ipairs(_G.LITHIUM_MAPMESHES) do render.RenderFlashlights(function() imesh:Draw() end) end

		hook.Run("DrawMonitors") -- "Draw" monitors. can be used by addons to tick their stuff?

		local opaque, translucent = {}, {}
		local rendergroup
		for _, ent in ents.Iterator() do
			if not IsValid(ent) or ent:GetNoDraw() then continue end
			if ent == vm then continue end
			if ent:GetClass() == "gmod_hands" then continue end
			-- frustrum culling, if too close dont bother
			--[[
			local pos = ent:GetPos()
			if pos:DistToSqr(eye_pos) > ent:BoundingRadius()^2 * 10^2 then
				local screen = pos:ToScreen()
				if !screen.visible or screen.x < 0 or screen.x > ScrW() or screen.y < 0 or screen.y > ScrH() then continue end
			end
			]]
			rendergroup = ent:GetRenderGroup()
			if rendergroup == RENDERGROUP_OPAQUE or
			   rendergroup == RENDERGROUP_VIEWMODEL or
			   rendergroup == RENDERGROUP_OPAQUE_BRUSH or
			   rendergroup == RENDERGROUP_BOTH then
				opaque[#opaque + 1] = ent
			end
			if rendergroup == RENDERGROUP_TRANSLUCENT or
			   rendergroup == RENDERGROUP_VIEWMODEL_TRANSLUCENT or
			   rendergroup == RENDERGROUP_BOTH then
				translucent[#translucent + 1] = ent
			end
		end

		if hook.Run("PreDrawOpaqueRenderables", false, false, false) ~= true then
			local ent
			for i=1, #opaque do
				ent = opaque[i]
				if ent.Draw then ent:Draw() else ent:DrawModel() end
				render.RenderFlashlights(function() if ent.Draw then ent:Draw() else ent:DrawModel() end end)
			end
			
			hook.Run("PostDrawOpaqueRenderables", false, false, false)
		end

		if hook.Run("PreDrawTranslucentRenderables", false, false, false) ~= true then
			local ent
			for i=1, #translucent do
				ent = translucent[i]
				if ent.DrawTranslucent then ent:DrawTranslucent() else ent:DrawModel() end
				render.RenderFlashlights(function() if ent.DrawTranslucent then ent:DrawTranslucent() else ent:DrawModel() end end)
			end
			hook.Run("PostDrawTranslucentRenderables", false, false, false)
		end
	cam.End3D()

	if view.drawviewmodel then
		if IsValid(vm) and
			hook.Run("PreDrawViewModel", vm, LocalPlayer(), LocalPlayer():GetActiveWeapon()) ~= true and
			hook.Run("ShouldDrawLocalPlayer", LocalPlayer()) ~= true and LocalPlayer():ShouldDrawLocalPlayer() ~= true then
			cam.Start3D(eyepos, eyeang, vm_fov and vm_fov:GetFloat() / 0.75 or 60)
				render.DepthRange(0, 0.03)
				vm:DrawModel()
				render.DepthRange(0, 1)
			cam.End3D()
			hook.Run("PostDrawViewModel", vm, LocalPlayer(), LocalPlayer():GetActiveWeapon())
		end
	end
	if view.drawhud then
		render.RenderHUD(0, 0, ScrW(), ScrH())
	end

	--cam.End2D()
end

-- EPIC NEW GMOD RENDER PIPELINE 
local drawing = false
hook.Add("RenderScene", "map", function(eye_pos, eye_angles, cam_fov) 
	if drawing then return end
	if not _G.LITHIUM_MAPMESHES then
		_G.LITHIUM_MAPMESHES, _G.LITHIUM_MAPMINMAXS = generate_map_meshes()
	end

	do -- let's give addons a chance to stop this horrid stuff
		drawing = true
		local skip = hook.Run("RenderScene", eye_pos, eye_angles, fov)
		drawing = false
		if skip then return true end
	end

	eyepos, eyeang, fov = eye_pos, eye_angles, cam_fov
	if not detoured_localplayer then
		detoured_localplayer = true
		local lp = LocalPlayer()
		function lp:EyeAngles() return eyeang end
		function lp:EyePos() return eyepos end
	end

	drawing = true
	render.RenderView(
		{
			origin=eye_pos, angles=eye_angles,
			drawviewmodel=true, drawhud=true
		}
	)
	drawing = false

	-- we're done!!!!!!!!!
	return true
end)
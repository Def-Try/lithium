local dark_mode = CreateConVar("lithium_gpusaver_darkmode", 0, {FCVAR_ARCHIVE}, "GPU Saver Dark Mode", 0, 1)
local draw_info = CreateConVar("lithium_gpusaver_drawinfo", 1, {FCVAR_ARCHIVE}, "GPU Saver Draw Info", 0, 1)

local show_name = CreateConVar("lithium_gpusaver_info_name", 1, {FCVAR_ARCHIVE}, "GPU Saver Show Name", 0, 1)
local show_health = CreateConVar("lithium_gpusaver_info_health", 1, {FCVAR_ARCHIVE}, "GPU Saver Show Health and armor", 0, 1)
local show_activity = CreateConVar("lithium_gpusaver_info_activity", 1, {FCVAR_ARCHIVE}, "GPU Saver Show Last active time", 0, 1)
local show_session = CreateConVar("lithium_gpusaver_info_session", 1, {FCVAR_ARCHIVE}, "GPU Saver Show Session time", 0, 1)
local show_velocity = CreateConVar("lithium_gpusaver_info_velocity", 1, {FCVAR_ARCHIVE}, "GPU Saver Show Velocity", 0, 1)

hook.Add("PreRender", "LITHIUM_GPUSaver", function()
	if system.HasFocus() then return end
	cam.Start2D()
		local lp = LocalPlayer()
		if not dark_mode:GetBool() then
			surface.SetDrawColor(0, 127, 255, 255)
		else
			surface.SetDrawColor(24, 24, 32, 255)
		end
		surface.DrawRect(0, 0, ScrW(), ScrH())
		draw.DrawText("Lithium", "DermaDefault", ScrW() * 0.5, ScrH() * 0.25, color_white, TEXT_ALIGN_CENTER)
		draw.DrawText("GPU Saver is ACTIVE", "DermaLarge", ScrW() * 0.5, ScrH() * 0.25 + 18, color_white, TEXT_ALIGN_CENTER)
		draw.DrawText("If you believe this is a mistake, send a bug report at https://github.com/Def-Try/Lithium", "DermaDefault",
			ScrW() * 0.5, ScrH() - 18, color_white, TEXT_ALIGN_CENTER)

		if draw_info:GetBool() then
			local y = ScrH() * 0.25 + 52
			if not lp then
				draw.DrawText("Player stats:", "DermaLarge", ScrW() * 0.1, ScrH() * 0.25 + 18, color_white, TEXT_ALIGN_CENTER)
				draw.DrawText("< UNAVALIABLE >", "DermaDefault", ScrW() * 0.1, y, color_white, TEXT_ALIGN_CENTER)
				cam.End2D()
				return true
			end

			draw.DrawText((show_name:GetBool() and lp:Name() or "Player").." stats:", "DermaLarge", ScrW() * 0.1, ScrH() * 0.25 + 18, color_white, TEXT_ALIGN_CENTER)
			if show_health:GetBool() then
				draw.DrawText("Health: "..lp:Health().."/"..lp:GetMaxHealth(), "DermaDefault", ScrW() * 0.1, y, color_white, TEXT_ALIGN_CENTER)
				draw.DrawText("Armor: "..lp:Armor().."/"..lp:GetMaxArmor(), "DermaDefault", ScrW() * 0.1, y + 18, color_white, TEXT_ALIGN_CENTER)
				y = y + 18 * 2
			end
			if show_velocity:GetBool() then
				draw.DrawText("Velocity: "..tostring(lp:GetVelocity()), "DermaDefault", ScrW() * 0.1, y, color_white, TEXT_ALIGN_CENTER)
				y = y + 18
			end
			if show_activity:GetBool() then
				draw.DrawText("Last mouse move time: "..string.FormattedTime(system.UpTime(), "%02i:%02i"), "DermaDefault", ScrW() * 0.1, y, color_white, TEXT_ALIGN_CENTER)
				y = y + 18
			end
			if show_session:GetBool() then
				local apptime = string.FormattedTime(system.AppTime())
				apptime = string.format("%02i:%02i:%02i", apptime.h, apptime.m, apptime.s)
				draw.DrawText("Application time (as reported by steam): "..apptime, "DermaDefault", ScrW() * 0.1, y, color_white, TEXT_ALIGN_CENTER)
				y = y + 18
			end
		end
	cam.End2D()
	return true
end)
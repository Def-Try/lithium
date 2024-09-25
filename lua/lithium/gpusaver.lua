hook.Add("PreRender", "LITHIUM_GPUSaver", function()
	if system.HasFocus() then return end
	cam.Start2D()

		local lp = LocalPlayer()

		surface.SetDrawColor(0, 127, 255, 255)
		surface.DrawRect(0, 0, ScrW(), ScrH())
		draw.DrawText("Lithium", "DermaDefault", ScrW() * 0.5, ScrH() * 0.25, color_white, TEXT_ALIGN_CENTER)
		draw.DrawText("GPU Saver is ACTIVE", "DermaLarge", ScrW() * 0.5, ScrH() * 0.25 + 18, color_white, TEXT_ALIGN_CENTER)
		draw.DrawText("If you believe this is a mistake, send a bug report at https://github.com/Def-Try/Lithium", "DermaDefault",
			ScrW() * 0.5, ScrH() - 18, color_white, TEXT_ALIGN_CENTER)

		if not lp then
			draw.DrawText("Player stats:", "DermaLarge", ScrW() * 0.1, ScrH() * 0.25, color_white, TEXT_ALIGN_CENTER)
			draw.DrawText("< UNAVALIABLE >", "DermaDefault", ScrW() * 0.1, ScrH() * 0.25 + 35, color_white, TEXT_ALIGN_CENTER)
			cam.End2D()
			return true
		end
		draw.DrawText(lp:Name().." stats:", "DermaLarge", ScrW() * 0.1, ScrH() * 0.25 + 18, color_white, TEXT_ALIGN_CENTER)
		draw.DrawText("Health: "..lp:Health().."/"..lp:GetMaxHealth(), "DermaDefault", ScrW() * 0.1, ScrH() * 0.25 + 52, color_white, TEXT_ALIGN_CENTER)
		draw.DrawText("Armor: "..lp:Armor().."/"..lp:GetMaxArmor(), "DermaDefault", ScrW() * 0.1, ScrH() * 0.25 + 52 + 18, color_white, TEXT_ALIGN_CENTER)
		draw.DrawText("Velocity: "..tostring(lp:GetVelocity()), "DermaDefault", ScrW() * 0.1, ScrH() * 0.25 + 52 + 18 * 2, color_white, TEXT_ALIGN_CENTER)
		draw.DrawText("Last mouse move time: "..string.FormattedTime(system.UpTime(), "%02i:%02i"), "DermaDefault", ScrW() * 0.1, ScrH() * 0.25 + 52 + 18 * 3, color_white, TEXT_ALIGN_CENTER)
		local apptime = string.FormattedTime(system.AppTime())
		apptime = string.format("%02i:%02i:%02i", apptime.h, apptime.m, apptime.s)
		draw.DrawText("Application time (as reported by steam): "..apptime, "DermaDefault", ScrW() * 0.1, ScrH() * 0.25 + 52 + 18 * 4, color_white, TEXT_ALIGN_CENTER)
	cam.End2D()
	return true
end)
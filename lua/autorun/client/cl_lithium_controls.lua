hook.Add("PopulateToolMenu", "lithium_tools", function()
    local gc, hm, ou, el
    net.Receive("lithium_controls", function()
        local msg = net.ReadUInt(4)
        if msg == 0 then -- get bool
            local name = net.ReadString()
            if name == "lithium_enable_garbagecollector_sv" then
                return gc:SetValue(net.ReadBool())
            end
            if name == "lithium_enable_hookmodule_sv" then
                return hm:SetValue(net.ReadBool())
            end
            if name == "lithium_enable_util_sv" then
                return ou:SetValue(net.ReadBool())
            end
            if name == "lithium_enabled_sv" then
                return el:SetValue(net.ReadBool())
            end
        end
    end)
    spawnmenu.AddToolMenuOption("Utilities", "Lithium", "lithium_general", "General", "", "", function(panel)
        panel:Clear()
        panel:Help("This tab controls general lithium settings.")

        panel:Help("===============================")

        panel:CheckBox("Enable Lithium on CLIENT", "lithium_enabled_cl")
        el = panel:CheckBox("Enable Lithium on SERVER", "")
        function el:OnChange(val)
            net.Start("lithium_controls")
                net.WriteUInt(1, 4)
                net.WriteString("lithium_enabled_sv")
                net.WriteBool(val)
            net.SendToServer()
        end
        el:SetConVar(nil)
        net.Start("lithium_controls")
            net.WriteUInt(0, 4)
            net.WriteString("lithium_enabled_sv")
        net.SendToServer()

        panel:Help("===============================")
        panel:Help("CLIENT: GPU Saver Settings")
        panel:ControlHelp("See Lithium > Systems: CLIENT for on/off switch.")
        panel:CheckBox("Dark mode", "lithium_gpusaver_darkmode")
        panel:CheckBox("Draw info", "lithium_gpusaver_drawinfo")
        panel:CheckBox("Show player name in info", "lithium_gpusaver_info_name")
        panel:CheckBox("Show health and armor in info", "lithium_gpusaver_info_health")
        panel:CheckBox("Show velocity in info", "lithium_gpusaver_info_velocity")
        panel:CheckBox("Show total session time in info", "lithium_gpusaver_info_session")
        panel:CheckBox("Show last activity time in info", "lithium_gpusaver_info_activity")
    end)
    spawnmenu.AddToolMenuOption("Utilities", "Lithium", "lithium_systems_cl", "Systems: CLIENT", "", "", function(panel)
        panel:Clear()
        panel:Help("This tab controls what systems are enabled on the client. Changes will not come into effect until restart.")

        panel:Help("===============================")
        panel:Help("Core Systems")
        panel:ControlHelp("Lithium systems that are essential for it's active performance improvements.")

        panel:CheckBox("Garbage Collector", "lithium_enable_garbagecollector_cl")
        panel:ControlHelp("Garbage collector collects and frees unused memory. Negligible performance impact with addons that are written right.")

        panel:CheckBox("Hook Module", "lithium_enable_hookmodule_cl")
        panel:ControlHelp("Core system of Garry's Mod itself. Disabling this will make lithium NOT override the default hook system, which is about 40% slower.")

        panel:CheckBox("Client Utilities", "lithium_enable_clientutil")
        panel:ControlHelp("A collection of random functions that are very often used in addons big and small.")

        panel:CheckBox("Render Utilities", "lithium_enable_renderutil")
        panel:ControlHelp("A collection of random functions that are very often used in addons big and small.")

        panel:CheckBox("Other Utilities", "lithium_enable_util_cl")
        panel:ControlHelp("A collection of random functions that are very often used in addons big and small.")

        panel:Help("===============================")
        panel:Help("Auxiliary Systems")
        panel:ControlHelp("Lithium systems that give passive performance improvements.")
        panel:CheckBox("GPU Saver", "lithium_enable_gpusaver")
        panel:ControlHelp("Stops entire game from rendering to save GPU resources. This is not the same as pausing.")
    end)
    spawnmenu.AddToolMenuOption("Utilities", "Lithium", "lithium_systems_sv", "Systems: SERVER", "", "", function(panel)
        panel:Clear()
        panel:Help("This tab controls what systems are enabled on the server. Changes will not come into effect until restart.")

        panel:Help("===============================")
        panel:Help("Core Systems")
        panel:ControlHelp("Lithium systems that are essential for it's active performance improvements.")

        gc = panel:CheckBox("Garbage Collector", "")
        panel:ControlHelp("Garbage collector collects and frees unused memory. Negligible performance impact with addons that are written right.")
        function gc:OnChange(val)
            net.Start("lithium_controls")
                net.WriteUInt(1, 4)
                net.WriteString("lithium_enable_garbagecollector_sv")
                net.WriteBool(val)
            net.SendToServer()
        end
        gc:SetConVar(nil)

        hm = panel:CheckBox("Hook Module", "")
        panel:ControlHelp("Core system of Garry's Mod itself. Disabling this will make lithium NOT override the default hook system, which is about 40% slower.")
        function hm:OnChange(val)
            net.Start("lithium_controls")
                net.WriteUInt(1, 4)
                net.WriteString("lithium_enable_hookmodule_sv")
                net.WriteBool(val)
            net.SendToServer()
        end
        hm:SetConVar(nil)

        ou = panel:CheckBox("Other Utilities", "")
        panel:ControlHelp("A collection of random functions that are very often used in addons big and small.")
        function ou:OnChange(val)
            net.Start("lithium_controls")
                net.WriteUInt(1, 4)
                net.WriteString("lithium_enable_util_sv")
                net.WriteBool(val)
            net.SendToServer()
        end
        ou:SetConVar(nil)

        net.Start("lithium_controls")
            net.WriteUInt(0, 4)
            net.WriteString("lithium_enable_garbagecollector_sv")
        net.SendToServer()
        net.Start("lithium_controls")
            net.WriteUInt(0, 4)
            net.WriteString("lithium_enable_hookmodule_sv")
        net.SendToServer()
        net.Start("lithium_controls")
            net.WriteUInt(0, 4)
            net.WriteString("lithium_enable_util_sv")
        net.SendToServer()
    end)
end)
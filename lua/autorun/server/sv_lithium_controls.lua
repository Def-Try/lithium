util.AddNetworkString("lithium_controls")

net.Receive("lithium_controls", function(_, ply)
	local msg = net.ReadUInt(4)
	if msg == 1 then -- set bool
		if not ply:IsAdmin() then return end
		local cv = net.ReadString()
		if not string.StartsWith(cv, "lithium_") then return end
		local cvv = GetConVar(cv)
		if not cvv then return end
		cvv:SetBool(net.ReadBool())
		return
	end
	if msg == 0 then -- get bool
		local name = net.ReadString()
		if not string.StartsWith(name, "lithium_") then return end
		net.Start("lithium_controls")
            net.WriteUInt(0, 4)
            net.WriteString(name)
            local cv = GetConVar(name)
            if not cv then
            	net.WriteBool(false)
            else
            	net.WriteBool(cv:GetBool())
            end
        net.Send(ply)
		return
	end
end)

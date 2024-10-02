util.AddNetworkString("lithium_controls")

net.Receive("lithium_controls", function(_, ply)
	local msg = net.ReadUInt(4)
	if msg == 1 then -- set bool
		if not ply:IsAdmin() then return end
		GetConVar(net.ReadString()):SetBool(net.ReadBool())
		return
	end
	if msg == 0 then -- get bool
		local name = net.ReadString()
		net.Start("lithium_controls")
            net.WriteUInt(0, 4)
            net.WriteString(name)
            net.WriteBool(GetConVar(name):GetBool())
        net.Send(ply)
		return
	end
end)
local oldhookdata = nil

local was = {}

return {
	start=function()
		jit.off()
		if oldhookdata then return end
		oldhookdata = {debug.gethook()}
		debug.sethook(function(event)
			local i = debug.getinfo(2)
			if i.short_src == "" then return end
			if i.short_src == "[C]" then return end
			if string.StartsWith(i.short_src, "lua/includes/") then return end
			if string.StartsWith(i.short_src, "includes/") then return end
			if was[i.short_src .. " : " .. (i.name or "<unknown>")] then return end
      		file.Append("lithium_trace.txt", i.short_src .. " : " .. (i.name or "<unknown>") .. "\n")
      		was[i.short_src .. " : " .. (i.name or "<unknown>")] = true
		end, "c")
	end,
	stop=function()
		if not oldhookdata then return end
		debug.sethook(oldhookdata[1], oldhookdata[2], oldhookdata[3])
		oldhookdata = nil
	end
}
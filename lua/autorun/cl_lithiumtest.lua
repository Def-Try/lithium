if not CLIENT then return end

local frametimes = {}

local function bench(id, start, end_, iters)
	frametimes[id] = frametimes[id] or {}
	local took = (end_ - start) * 1000 / iters
	frametimes[id][#frametimes[id]+1] = took

	--frametimes[#frametimes+1] = 1 / FrameTime()
	local avg = 0
	local max, min = 0, 10000
	for _,v in pairs(frametimes[id]) do
		avg = avg + v
		max = math.max(v, max)
		min = math.min(v, min)
	end
	avg = avg / #frametimes[id]
	print(id.." - "..iters.." iterations")
	print("min "..math.Round(min, 5), "max "..math.Round(max, 5), "avg "..math.Round(avg, 5), "cur "..math.Round(took, 5))
end

local function fps_bench()
	if FrameTime() == 0 then return end
	frametimes["fps"] = frametimes["fps"] or {}
	frametimes["fps"][#frametimes["fps"]+1] = 1 / FrameTime()
	local avg = 0
	local max, min = 0, 10000
	for _,v in pairs(frametimes["fps"]) do
		avg = avg + v
		max = math.max(v, max)
		min = math.min(v, min)
	end
	avg = avg / #frametimes["fps"]
	print("min "..math.Round(min, 5), "max "..math.Round(max, 5), "avg "..math.Round(avg, 5), "cur "..math.Round(1 / FrameTime(), 5))
end

hook.Add("PostRender", "lithium_test", function()
	do return end
	-- fps_bench()
	local start = SysTime()
		for i=0,5000,1 do
			Material("phoenix_storms/wire/pcb_green")
		end
	local end_ = SysTime()
	bench('material embedded', start, end_, 1)

	local start = SysTime()
		for i=0,5000,1 do
			Material("camcoder/gui/icon.png")
		end
	local end_ = SysTime()
	bench('material png', start, end_, 1)
end)
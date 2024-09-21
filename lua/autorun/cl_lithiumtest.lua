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

hook.Add("PostRender", "lithium_test", function()
	do return end
	local start = SysTime()

	local end_ = SysTime()
	bench('add-run-remove 500h', start, end_, 500)
end)
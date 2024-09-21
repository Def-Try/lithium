AddCSLuaFile()

local print = print
local unpack = unpack
local collectgarbage = collectgarbage
local SysTime = SysTime
local round = math.floor
local ErrorNoHalt = ErrorNoHalt

module("lithium")

function log(text)
	print("[LITHIUM] "..text)
end

function warn(text)
	ErrorNoHalt("[LITHIUM] "..text.."\n")
end

function gc()
	log("Running full garbage collection!")
	local then_ = collectgarbage("count")
	local start_time = SysTime()
	collectgarbage("collect")
	local end_time = SysTime()
	local now = collectgarbage("count")
	local cleared = round(then_ - now)
	local took_time = round((end_time - start_time) * 1000, 2)
	log("Done. Collected "..cleared.."kb of garbage, took "..took_time.."ms")
	log("Memory usage is now at "..round(now).."kb")
end

datatypes = {
	enable = true,

	enable_creation_optimisation = false, -- this isn't really an "optimisation", it 2x's
										  -- the time on average to create 10000 vectors in my tests

	enable_defaults_override = false, 	  -- pretty much useless
}
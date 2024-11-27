---@diagnostic disable: lowercase-global
local print = print
local unpack = unpack
local collectgarbage = collectgarbage
local SysTime = SysTime
local round = math.floor
local ErrorNoHalt = ErrorNoHalt
local file = file
local CLIENT = CLIENT
local SERVER = SERVER

module("lithium")

function log(text)
	print("[LITHIUM] "..text)
end

function warn(text)
	ErrorNoHalt("[LITHIUM] "..text.."\n")
end

local debug_ = false
function debug(text)
	if not debug_ then return end
	log(text)
end

function gc()
	log("Running full garbage collection!")
	local then_ = collectgarbage("count")
	local start_time = SysTime()
	collectgarbage("collect")
	local end_time = SysTime()
	local now = collectgarbage("count")
	local cleared = round(then_ - now)
	local took_time = round((end_time - start_time) * 1000)
	log("Done. Collected "..cleared.."kb of garbage, took "..took_time.."ms")
	log("Memory usage is now at "..round(now).."kb")
end
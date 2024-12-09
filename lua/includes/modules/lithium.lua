---@diagnostic disable: lowercase-global
local print = print
local ErrorNoHalt = ErrorNoHalt

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
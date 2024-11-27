require("lithium")

local name = "lithium_hook_selftest"

local GM = {}

local function RunTest()
	hook.GetLithiumTable()[name] = nil
	do
		local ret = 0
		lithium.log("[HOOK] [SELFTEST] Basic hook test running")

		GM[name] = function(_, ret) return ret end
		local ran = false
		hook.Add(name, "1", function()
			ran = true
		end)

		local ret = hook.Call(name, GM, 1)

		assert(ran == true, "hook.Call didn't run the hook")
		assert(ret == 1, "hook.Call didn't run the gamemode function or returned the wrong value")
		lithium.log("[HOOK] [SELFTEST] Basic hook test OK")
		-- Remove wasn't tested yet, don't clean up
	end

	do
		lithium.log("[HOOK] [SELFTEST] Hook order test running")
		local order = {}
		for i = 1, 3 do
			---@diagnostic disable-next-line: redundant-parameter
			hook.Add(name, tostring(i), function() table.insert(order, tostring(i)) end, HOOK_NORMAL)
		end
		hook.Call(name, {})

		assert(table.concat(order) == "123", "Hooks with the same priority did not execute in order of addition (got "..table.concat(order)..")")
		lithium.log("[HOOK] [SELFTEST] Hook order test OK")
		-- Remove wasn't tested yet, don't clean up
	end

	do
		lithium.log("[HOOK] [SELFTEST] Hook removal test running")
		local executed = {}
		hook.Add(name, "1", function() table.insert(executed, "hook1") end)
		hook.Add(name, "2", function() table.insert(executed, "hook2") end)
		hook.Add(name, "3", function() table.insert(executed, "hook3") end)

		hook.Remove(name, "1")
		hook.Call(name, {})

		assert(not table.HasValue(executed, "hook1"), "Removed hook should not execute")
		lithium.log("[HOOK] [SELFTEST] Hook removal test OK")
		-- Remove is OK, we can now clean up after ourselves
		hook.Remove(name, "2")
		hook.Remove(name, "3")
	end

	do
		lithium.log("[HOOK] [SELFTEST] Hook replace test running")
		local executed = false
		hook.Add(name, "hook", function() executed = true end)
		hook.Add(name, "hook", function() executed = false end)

		hook.Call(name, {})

		assert(executed == false, "Hook should have its functionality replaced")
		lithium.log("[HOOK] [SELFTEST] Hook replace test OK")
		hook.Remove(name, "hook")
	end

	do
		lithium.log("[HOOK] [SELFTEST] Complex hook chain test running")
		local order = {}
		for i = 1, 5 do
			hook.Add(name, "hook" .. tostring(i), function() table.insert(order, "hook" .. tostring(i)) end)
		end

		hook.Call(name, {})

		assert(table.concat(order) == "hook1hook2hook3hook4hook5", "Complex chain of hooks did not execute correctly")
		lithium.log("[HOOK] [SELFTEST] Complex hook chain test OK")
		for i = 1, 5 do hook.Remove(name, "hook" .. tostring(i)) end
	end

	do
		lithium.log("[HOOK] [SELFTEST] Concurrent hook add/remove in call test running")
		local function dynamic_hook() hook.Remove(name, "dynamic") end
		hook.Add(name, "static", function() hook.Add(name, "dynamic", dynamic_hook) end)

		hook.Call(name, {})

		assert(pcall(hook.Call, name, {}), "Should be stable after concurrent add/remove during call")
		lithium.log("[HOOK] [SELFTEST] Concurrent hook add/remove in call OK")
		hook.Remove(name, "static")
	end

	do
		lithium.log("[HOOK] [SELFTEST] Nested hook call test running")
		local nested_called = false
		hook.Add(name, "outer", function() hook.Call("nested", {}) end)
		hook.Add("nested", "inner", function() nested_called = true end)

		hook.Call(name, {})

		assert(nested_called, "Nested hook calls should be handled correctly")
		lithium.log("[HOOK] [SELFTEST] Nested hook call test OK")
		hook.Remove(name, "outer")
		hook.Remove("nested", "inner")
	end

	do
		lithium.log("[HOOK] [SELFTEST] Hook with varargs test running")
		local args_received = false
		---@diagnostic disable-next-line: cast-local-type
		hook.Add(name, "varargs", function(...) args_received = {...} end)

		hook.Call(name, {}, 1, 2, 3)

		assert(args_received and #args_received == 3 and args_received[1] == 1 and args_received[2] == 2 and args_received[3] == 3, "Hooks should handle variable arguments correctly")

		lithium.log("[HOOK] [SELFTEST] Hook with varargs test OK")
		hook.Remove(name, "varargs")
	end

	do
		lithium.log("[HOOK] [SELFTEST] Gamemode hook test running")
		GM[name] = function() return "gm_called" end

		local ret = hook.Call(name, GM)

		assert(ret == "gm_called", "The gamemode function should run and return its value when no hooks are present")
		lithium.log("[HOOK] [SELFTEST] Gamemode hook test OK")
	end

	do
		lithium.log("[HOOK] [SELFTEST] High priority hook running before GM test running")
		GM[name] = function() return "gm_not_called" end
		local returnValue = nil
		---@diagnostic disable-next-line: redundant-parameter
		hook.Add(name, "PreHookReturn", function() return "pre_returned" end, HOOK_HIGH)

		returnValue = hook.Call(name, GM)

		assert(returnValue == "pre_returned", "High priority hook with return should stop execution and return its value")
		lithium.log("[HOOK] [SELFTEST] High priority hook running before GM test OK")
		hook.Remove(name, "PreHookReturn")
	end

	do
		lithium.log("[HOOK] [SELFTEST] Different priority hooks run test running")
		local normal_hook_ran = false
		local post_hook_ran = false
		---@diagnostic disable-next-line: redundant-parameter
		hook.Add(name, "normalhook", function() normal_hook_ran = true end, HOOK_NORMAL)
		---@diagnostic disable-next-line: redundant-parameter
		hook.Add(name, "posthook", function() post_hook_ran = true end, HOOK_LOW)

		hook.Call(name, {})

		assert(normal_hook_ran and post_hook_ran, "Both normal and low hooks should run")
		lithium.log("[HOOK] [SELFTEST] Different priority hooks run test OK")
		hook.Remove(name, "normalhook")
		hook.Remove(name, "posthook")
	end

	do
		lithium.log("[HOOK] [SELFTEST] Removing hook in call test running")
		local hookran = false
		local function removing_hook() hook.Remove(name, "dynamicHook") end
		---@diagnostic disable-next-line: redundant-parameter
		hook.Add(name, "removing_hook", removing_hook, HOOK_HIGH)
		---@diagnostic disable-next-line: redundant-parameter
		hook.Add(name, "dynamicHook", function() hookran = true end, HOOK_NORMAL)

		hook.Call(name, {})

		assert(not hookran, "Hook should not run after being removed")
		lithium.log("[HOOK] [SELFTEST] Removing hook in call test OK")
		hook.Remove(name, "removing_hook")
		hook.Remove(name, "dynamicHook")
	end

	do
		lithium.log("[HOOK] [SELFTEST] GMod wrong behaviour replication test running")
		-- https://github.com/Facepunch/garrysmod/pull/1642#issuecomment-601288451
		-- thank you srlion
		local a, b, c
		hook.Add(name, "a", function()
			a = true
			hook.Add(name, "c", function()
				c = true
			end)
		end)
		hook.Add(name, "b", function()
			b = true
		end)

		hook.Call(name)
		assert(a == true and b == true and c == nil, "something is wrong, called: a: " .. tostring(a) .. " b: " .. tostring(b) .. " c: " .. tostring(c))
		a, b, c = nil, nil, nil
		hook.Call(name)
		assert(a == true and b == true and c == true, "something is wrong, called: a: " .. tostring(a) .. " b: " .. tostring(b) .. " c: " .. tostring(c))
		lithium.log("[HOOK] [SELFTEST] GMod wrong behaviour replication test OK")
		hook.Remove(name, "a")
		hook.Remove(name, "b")
		hook.Remove(name, "c")
	end

	do
		lithium.log("[HOOK] [SELFTEST] IsValid-able as hook name test running")
		local entity = {
			IsValid = function()
				return true
			end
		}

		hook.Add(name, entity, function()
			return true
		end)

		assert(hook.Call(name, nil, 1) == true, "hook.Call didn't run the hook or returned the wrong value")

		lithium.log("[HOOK] [SELFTEST] IsValid-able as hook name test OK")
		hook.Remove(name, entity)
	end

	do
		lithium.log("[HOOK] [SELFTEST] IsValid-able turning invalid as hook name test running")
		local called = 0
		local entity = {
			IsValid = function()
				called = called + 1
				if called <= 2 then
					return true
				end
				return false
			end
		}

		hook.Add(name, entity, function()
			return true
		end)

		assert(hook.Call(name, nil, 1) == true, "hook.Call didn't run the hook or returned the wrong value")
		assert(hook.Call(name, nil, 1) == nil, "hook.Call entity was called even though it became invalid")

		lithium.log("[HOOK] [SELFTEST] IsValid-able turning invalid as hook name test OK")
	end
end

local success, error = pcall(RunTest)
if not success then
	lithium.warn(error)
	PrintTable(hook.GetLithiumTable()[name] or {})
end
return success
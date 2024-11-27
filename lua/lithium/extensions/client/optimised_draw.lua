require("lithium")

-- https://github.com/JetBoom/zombiesurvival/blob/master/gamemodes/zombiesurvival/gamemode/perf/shared/buffthefps.lua
-- dm me at @googer_ in discord if you don't want your code there!
local function fix()
	lithium.log("Hi from JetBoom's mouth and ear anim fixes!")

	local SpeakFlexes = {
		["jaw_drop"] = true,
		["right_part"] = true,
		["left_part"] = true,
		["right_mouth_drop"] = true,
		["left_mouth_drop"] = true
	}
	local GESTURE_SLOT_VCD = GESTURE_SLOT_VCD
	local ACT_GMOD_IN_CHAT = ACT_GMOD_IN_CHAT
	local GAMEMODE = gmod.GetGamemode()
	function GAMEMODE:MouthMoveAnimation(pl)
		if pl:IsSpeaking() then
			pl.m_bWasSpeaking = true

			local FlexNum = pl:GetFlexNum() - 1
			if FlexNum <= 0 then return end
			local weight = math.Clamp(pl:VoiceVolume() * 2, 0, 2)
			for i = 0, FlexNum - 1 do
				if SpeakFlexes[pl:GetFlexName(i)] then
					pl:SetFlexWeight(i, weight)
				end
			end
		elseif pl.m_bWasSpeaking then
			pl.m_bWasSpeaking = false

			local FlexNum = pl:GetFlexNum() - 1
			if FlexNum <= 0 then return end
			for i = 0, FlexNum - 1 do
				if SpeakFlexes[pl:GetFlexName(i)] then
					pl:SetFlexWeight( i, 0 )
				end
			end
		end
	end

	function GAMEMODE:GrabEarAnimation(pl)
		if pl:IsTyping() then
			pl.ChatGestureWeight = math.Approach(pl.ChatGestureWeight or 0, 1, FrameTime() * 5)
		elseif pl.ChatGestureWeight and pl.ChatGestureWeight > 0 then
			pl.ChatGestureWeight = math.Approach(pl.ChatGestureWeight, 0, FrameTime() * 5)
			if pl.ChatGestureWeight == 0 then
				pl.ChatGestureWeight = nil
			end
		end

		if pl.ChatGestureWeight then
			if pl:IsPlayingTaunt() then return end -- Don't show this when we're playing a taunt!

			pl:AnimRestartGesture(GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT, true)
			pl:AnimSetGestureWeight(GESTURE_SLOT_VCD, pl.ChatGestureWeight)
		end
	end
end
timer.Simple(0, fix)
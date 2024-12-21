require("lithium")

-- https://github.com/JetBoom/zombiesurvival/blob/master/gamemodes/zombiesurvival/gamemode/perf/shared/buffthefps.lua
-- dm me at @googer_ in discord if you don't want your code there!
timer.Simple(0, function()
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
end)

lithium.log("Hi from JetBoom's draw functions!")

-- TODO: in my tests some of them were *slower*? validate and remove ones that actually hurt

local surface = surface
local Color = Color
local color_white = color_white

local TEXT_ALIGN_CENTER	= 1
local TEXT_ALIGN_RIGHT = 2
local TEXT_ALIGN_BOTTOM	= 4

local surface_SetFont = surface.SetFont
local surface_GetTextSize = surface.GetTextSize
local surface_SetTextPos = surface.SetTextPos
local surface_SetTextColor = surface.SetTextColor
local surface_DrawText = surface.DrawText
local surface_SetTexture = surface.SetTexture
local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawRect = surface.DrawRect
local surface_DrawTexturedRect = surface.DrawTexturedRect
local surface_DrawTexturedRectRotated = surface.DrawTexturedRectRotated

local string_sub = string.sub

local math_ceil = math.ceil

local Tex_Corner8 = surface.GetTextureID("gui/corner8")
local Tex_Corner16 = surface.GetTextureID("gui/corner16")
local Tex_Corner32 = surface.GetTextureID("gui/corner32")
local Tex_Corner64 = surface.GetTextureID("gui/corner64")
local Tex_white = surface.GetTextureID("vgui/white")

-- Just an FYI that this is around 450 times faster than using surface.GetTextSize when cached.
LITHIUM_CachedFontHeights = {}
function draw.GetFontHeight(font)
	if LITHIUM_CachedFontHeights[font] then
		return LITHIUM_CachedFontHeights[font]
	end

	surface_SetFont(font)
	local _, h = surface_GetTextSize("W")
	LITHIUM_CachedFontHeights[font] = h

	return h
end

function draw.SimpleText(text, font, x, y, color, xalign, yalign)
	surface_SetFont(font or "DermaDefault")

	if xalign == TEXT_ALIGN_CENTER then
		local w, _ = surface_GetTextSize(text)
		x = x - w / 2
	elseif xalign == TEXT_ALIGN_RIGHT then
		local w, _ = surface_GetTextSize(text)
		x = x - w
	end

	if yalign == TEXT_ALIGN_CENTER then
		local h = draw.GetFontHeight(font)
		y = y - h / 2
	elseif yalign == TEXT_ALIGN_BOTTOM then
		local h = draw.GetFontHeight(font)
		y = y - h
	end

	surface_SetTextPos(x, y)
	if color then
		surface_SetTextColor(color.r, color.g, color.b, color.a)
	else
		surface_SetTextColor(255, 255, 255, 255)
	end
	surface_DrawText(text)
end

function draw.DrawText(text, font, x, y, color, xalign)
	local curX = x
	local curY = y
	local curString = ""

	local lineHeight = draw.GetFontHeight(font or "DermaDefault")

	for i=1, #text do
		local ch = string_sub(text, i, i)
		if ch == "\n" then
			if #curString > 0 then
				draw.SimpleText(curString, font, curX, curY, color, xalign)
			end

			curY = curY + lineHeight -- / 2
			curX = x
			curString = ""
		elseif ch == "\t" then
			if #curString > 0 then
				draw.SimpleText(curString, font, curX, curY, color, xalign)
			end
			local tmpSizeX, _ =  surface_GetTextSize(curString)
			curX = math_ceil( (curX + tmpSizeX) / 50 ) * 50
			curString = ""
		else
			curString = curString .. ch
		end
	end
	if #curString > 0 then
		draw.SimpleText(curString, font, curX, curY, color, xalign)
	end
end

function draw.Text(tab)
	local text = tab.text
	local font = tab.font or "DermaDefault"
	local x = tab.pos[1] or 0
	local y = tab.pos[2] or 0
	local xalign = tab.xalign
	local yalign = tab.yalign

	surface_SetFont(font)

	local w, h = surface_GetTextSize(text)

	if xalign == TEXT_ALIGN_CENTER then
		x = x - w / 2
	elseif xalign == TEXT_ALIGN_RIGHT then
		x = x - w
	end

	if yalign == TEXT_ALIGN_CENTER then
		local h = draw.GetFontHeight(font)
		y = y - h / 2
	end

	surface_SetTextPos(x, y)

	if tab.color then
		surface_SetTextColor(tab.color)
	else
		surface_SetTextColor(255, 255, 255, 255)
	end

	surface_DrawText(text)

	return w, h
end

function draw.WordBox(bordersize, x, y, text, font, color, fontcolor)
	surface_SetFont(font)
	local w, h = surface_GetTextSize(text)

	draw.RoundedBox(bordersize, x, y, w+bordersize*2, h+bordersize*2, color)

	surface_SetTextColor(fontcolor.r, fontcolor.g, fontcolor.b, fontcolor.a)
	surface_SetTextPos(x + bordersize, y + bordersize)
	surface_DrawText(text)
end

function draw.TextShadow(tab, distance, alpha)
	alpha = alpha or 200

	local color = tab.color
	local pos 	= tab.pos
	tab.color = Color(0, 0, 0, alpha)
	tab.pos = {pos[1] + distance, pos[2] + distance}

	local w, h = draw.Text(tab)

	tab.color = color
	tab.pos = pos

	draw.Text(tab)

	return w, h
end

function draw.TexturedQuad(tab)
	surface_SetTexture(tab.texture)
	surface_SetDrawColor(tab.color or color_white)
	surface_DrawTexturedRect(tab.x, tab.y, tab.w, tab.h)
end

function draw.NoTexture()
	surface_SetTexture(Tex_white)
end

function draw.RoundedBoxEx(bordersize, x, y, w, h, color, a, b, c, d)
	surface_SetDrawColor(color)
	bordersize = math.max(bordersize, 0)

	if bordersize <= 0 then
		bordersize = 0
	elseif bordersize <= 8 then
		surface_SetTexture(Tex_Corner8)
	elseif bordersize <= 16 then
		surface_SetTexture(Tex_Corner16)
	elseif bordersize <= 32 then
		surface_SetTexture(Tex_Corner32)
	else
		surface_SetTexture(Tex_Corner64)
	end

	-- Draw as much of the rect as we can without textures
	surface_DrawRect(x + bordersize, y, w - bordersize * 2, h)
	surface_DrawRect(x, y + bordersize, bordersize, h - bordersize * 2)
	surface_DrawRect(x + w - bordersize, y + bordersize, bordersize, h - bordersize * 2)

	if bordersize == 0 then return end
	
	if a then
		surface_DrawTexturedRectRotated(x + bordersize/2, y + bordersize/2, bordersize, bordersize, 0)
	else
		surface_DrawRect(x, y, bordersize, bordersize)
	end

	if b then
		surface_DrawTexturedRectRotated(x + w - bordersize/2, y + bordersize/2, bordersize, bordersize, 270)
	else
		surface_DrawRect(x + w - bordersize, y, bordersize, bordersize)
	end

	if c then
		surface_DrawTexturedRectRotated(x + bordersize/2, y + h - bordersize/2, bordersize, bordersize, 90)
	else
		surface_DrawRect(x, y + h - bordersize, bordersize, bordersize)
	end

	if d then
		surface_DrawTexturedRectRotated(x + w - bordersize/2, y + h - bordersize/2, bordersize, bordersize, 180)
	else
		surface_DrawRect(x + w - bordersize, y + h - bordersize, bordersize, bordersize)
	end
end

function draw.RoundedBox(bordersize, x, y, w, h, color)
	draw.RoundedBoxEx(bordersize, x, y, w, h, color, true, true, true, true)
end

function draw.SimpleTextOutlined(text, font, x, y, colour, xalign, yalign, outlinewidth, outlinecolor)
	local steps = (outlinewidth*2) / 3
	if steps < 1 then steps = 1 end

	for _x=-outlinewidth, outlinewidth, steps do
		for _y=-outlinewidth, outlinewidth, steps do
			draw.SimpleText(text, font, x + _x, y + _y, outlinecolor, xalign, yalign)
		end
	end

	draw.SimpleText(text, font, x, y, colour, xalign, yalign)
end
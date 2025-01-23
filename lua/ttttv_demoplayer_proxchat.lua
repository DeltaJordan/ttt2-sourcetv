local HearDead = CreateConVar("tv_voice_hear_dead", 1, FCVAR_ARCHIVE)
local ProxChatDistance = CreateConVar("tv_voice_radius", 2500, FCVAR_ARCHIVE)
local EnableProxChat = CreateConVar("tv_voice_proximity", 1, FCVAR_ARCHIVE)
local function UpdateVoice(listener, talker)
	if not IsValid(listener) or not IsValid(talker) or listener == talker then return end
	if not EnableProxChat:GetBool() then
		talker:SetVoiceVolumeScale(1)
		return
	end

	if not talker:Alive() then
		if HearDead:GetBool() then
			talker:SetVoiceVolumeScale(1)
			return
		else
			talker:SetVoiceVolumeScale(0)
			return
		end
	end

	local distance = listener:EyePos():Distance(talker:EyePos())
	if distance > ProxChatDistance:GetInt() then
		talker:SetVoiceVolumeScale(0)
		return
	end

	local vol = ((distance / ProxChatDistance:GetInt()) * -1) + 1
	local func = VOICE.ScalingFunctions[VOICE.cv.scaling_mode:GetString()]
	if isfunction(func) then vol = func(vol) end
	--local tm = talker:GetTeam()
	--talker[tm .. "_gvoice"] = true
	talker:SetVoiceVolumeScale(vol)
end

local function UpdateVoices()
	local listener = LocalPlayer()
	if not IsValid(listener) then return end
	for _, talker in ipairs(player.GetAll()) do
		if talker ~= listener and not talker:IsMuted() then UpdateVoice(listener, talker) end
	end
end

hook.Add("PlayerStartVoice", "StartVoiceChatSourceTVTTT", function(ply)
	local listener = LocalPlayer()
	if not IsValid(listener) then return end
	UpdateVoice(listener, talker)
	VOICE.SetVoiceMode(ply, VOICE_MODE_GLOBAL)
end)

hook.Add("Think", "ProximityVoiceSourceTVTTT", function() UpdateVoices() end)
if EnableProxChat:GetBool() then
	if not IsValid(localPlayer) then return end
	for _, tlkr in ipairs(player.GetAll()) do
		UpdateVoiceDSP(localPlayer, tlkr)
	end
end
if !CPTBase then return end
if !CLIENT then return end
-------------------------------------------------------------------------------------------------------------------
local ENT_Meta = FindMetaTable("Entity")
local NPC_Meta = FindMetaTable("NPC")
local PLY_Meta = FindMetaTable("Player")
local WPN_Meta = FindMetaTable("Weapon")

function FindLuaFile(luadir)
	return file.Exists(luadir,"LUA")
end

function FindGameFile(filedir)
	return file.Exists(filedir,"GAME")
end

function NPC_Meta:CreateThemeSong(track,len)
	for _,v in ipairs(player.GetAll()) do
		if v.CPTBase_CurrentSoundtrack == nil then
			v.CPTBase_CurrentSoundtrack = CreateSound(v,track)
			v.CPTBase_CurrentSoundtrack:SetSoundLevel(0.2)
			v.CPTBase_CurrentSoundtrack:Play()
				// Fast forward kind of system
			-- v.CPTBase_CurrentSoundtrack:ChangePitch(250) // 250 max. Setting volume to zero then 0.2 should mute the intro fx
			-- timer.Simple(1,function() v.CPTBase_CurrentSoundtrack:ChangePitch(100) end)
			v.CPTBase_CurrentSoundtrackDir = track
			v.CPTBase_CurrentSoundtrackNPC = self
			v.CPTBase_CurrentSoundtrackTime = RealTime() +len
			v.CPTBase_CurrentSoundtrackRestartTime = len
		end
	end
end

function NPC_Meta:StopAllThemeSongs()
	for _,v in ipairs(player.GetAll()) do
		if v.CPTBase_CurrentSoundtrack != nil then
			v.CPTBase_CurrentSoundtrack:Stop()
			v.CPTBase_CurrentSoundtrack = nil
			v.CPTBase_CurrentSoundtrackDir = nil
			v.CPTBase_CurrentSoundtrackNPC = NULL
			v.CPTBase_CurrentSoundtrackTime = nil
			v.CPTBase_CurrentSoundtrackRestartTime = nil
		end
	end
end

hook.Add("Think","CPTBase_ThemeSystemThink",function()
	if LocalPlayer().CPTBase_CurrentSoundtrack != nil then
		if !IsValid(LocalPlayer().CPTBase_CurrentSoundtrackNPC) then
			LocalPlayer().CPTBase_CurrentSoundtrack:FadeOut(0.5)
			LocalPlayer().CPTBase_CurrentSoundtrack = nil
			LocalPlayer().CPTBase_CurrentSoundtrackDir = nil
			LocalPlayer().CPTBase_CurrentSoundtrackTime = nil
			LocalPlayer().CPTBase_CurrentSoundtrackRestartTime = nil
		end
		if LocalPlayer().CPTBase_CurrentSoundtrack != nil && RealTime() > LocalPlayer().CPTBase_CurrentSoundtrackTime then
			LocalPlayer().CPTBase_CurrentSoundtrack:FadeOut(4)
			local prevNPC = LocalPlayer().CPTBase_CurrentSoundtrackNPC
			timer.Simple(4,function()
				if IsValid(LocalPlayer()) then
					if IsValid(LocalPlayer().CPTBase_CurrentSoundtrackNPC) && prevNPC == LocalPlayer().CPTBase_CurrentSoundtrackNPC then
						LocalPlayer().CPTBase_CurrentSoundtrack:Stop()
						LocalPlayer().CPTBase_CurrentSoundtrack = CreateSound(LocalPlayer(),LocalPlayer().CPTBase_CurrentSoundtrackDir)
						LocalPlayer().CPTBase_CurrentSoundtrack:SetSoundLevel(0.2)
						LocalPlayer().CPTBase_CurrentSoundtrack:Play()
					end
				end
			end)
			LocalPlayer().CPTBase_CurrentSoundtrackTime = RealTime() +LocalPlayer().CPTBase_CurrentSoundtrackRestartTime
		end
	end
end)
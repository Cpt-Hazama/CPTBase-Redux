/*--------------------------------------------------
	Copyright (c) 2017 by Cpt. Hazama, All rights reserved.
	Nothing in these files or/and code may be reproduced, adapted, merged or
	modified without prior written consent of the original author, Cpt. Hazama
--------------------------------------------------*/
include('server/cpt_utilities.lua')

local buttonsounds = {"buttons/blip1.wav","buttons/button14.wav","buttons/button17.wav","buttons/button24.wav","buttons/button3.wav","buttons/button9.wav","buttons/combine_button7.wav","buttons/lightswitch2.wav","common/warning.wav","ambient/materials/smallwire_pluck3.wav","ambient/voices/citizen_beaten1.wav"}
local killsounds = {"music/stingers/industrial_suspense1.wav","music/stingers/industrial_suspense2.wav","music/stingers/hl1_stinger_song16.mp3","music/stingers/hl1_stinger_song27.mp3","music/stingers/hl1_stinger_song28.mp3","music/stingers/hl1_stinger_song7.mp3","music/stingers/hl1_stinger_song8.mp3"}
local volume = 45

local function CPT_ResetMap(ply)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		game.CleanUpMap()
		if (SERVER) then
			ply:SendLua("GAMEMODE:AddNotify(\"Reset Map!\", NOTIFY_CLEANUP, 5)")
		end
		ply:EmitSound(Sound(buttonsounds[math.random(1,#buttonsounds)]),volume,100)
	end
end
concommand.Add("cpt_resetmap",CPT_ResetMap)

local function CPT_StopSounds(ply)
	ply:ConCommand("stopsound")
	if (SERVER) then
		ply:SendLua("GAMEMODE:AddNotify(\"Reset Map!\", NOTIFY_CLEANUP, 5)")
	end
	ply:EmitSound(Sound(buttonsounds[math.random(1,#buttonsounds)]),volume,100)
end
concommand.Add("cpt_stopsounds",CPT_StopSounds)

local function CPT_RemoveSNPCs(ply)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		local i = 0
		local snpcs = ents.GetAll()
		for k, v in pairs(snpcs) do
		if v:IsNPC() && v:IsValid() && (v.IsVJBaseSNPC or v.CPTBase_NPC) then
			undo.ReplaceEntity(v,nil)
			v:Remove()
			i = i + 1
			end            
		end
		if (SERVER) then
			ply:SendLua("GAMEMODE:AddNotify(\"Removed " .. i .. " SNPCs\", NOTIFY_CLEANUP, 5)")
		end
		ply:EmitSound(Sound(buttonsounds[math.random(1,#buttonsounds)]),volume,100)
	end
end
concommand.Add("cpt_removesnpcs", CPT_RemoveSNPCs)

local function CPT_RemoveNPCs(ply)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		local i = 0
		local npcs = ents.GetAll()
		for k, v in pairs(npcs) do
		if v:IsNPC() && v:IsValid() then
			undo.ReplaceEntity(v,nil)
			v:Remove()
			i = i + 1
			end            
		end
		if (SERVER) then
			ply:SendLua("GAMEMODE:AddNotify(\"Removed " .. i .. " NPCs\", NOTIFY_CLEANUP, 5)")
		end
		ply:EmitSound(Sound(buttonsounds[math.random(1,#buttonsounds)]),volume,100)
	end
end
concommand.Add("cpt_removenpcs", CPT_RemoveNPCs)

local function CPT_RemoveNextbots(ply)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		local i = 0
		local npcs = ents.GetAll()
		for k, v in pairs(npcs) do
		if v:IsNPC() && v:IsValid() && v:IsNextbot() == true then
			undo.ReplaceEntity(v,nil)
			v:Remove()
			i = i + 1
			end 
		end
		if (SERVER) then
			ply:SendLua("GAMEMODE:AddNotify(\"Removed " .. i .. " Nextbots\", NOTIFY_CLEANUP, 5)")
		end
		ply:EmitSound(Sound(buttonsounds[math.random(1,#buttonsounds)]),volume,100)
	end
end
concommand.Add("cpt_removenextbots", CPT_RemoveNextbots)

local function CPT_RemoveAmmo(ply)
	ply:RemoveAllAmmo()
	if (SERVER) then
		ply:SendLua("GAMEMODE:AddNotify(\"Removed All Your Ammo\", NOTIFY_CLEANUP, 5)")
	end
	ply:EmitSound(Sound(buttonsounds[math.random(1,#buttonsounds)]),volume,100)
end
concommand.Add("cpt_removeammo", CPT_RemoveAmmo)

local function CPT_RemoveWeapons(ply)
	ply:StripWeapons()
	if (SERVER) then
		ply:SendLua("GAMEMODE:AddNotify(\"Removed All Your Weapons\", NOTIFY_CLEANUP, 5)")
	end
	ply:EmitSound(Sound(buttonsounds[math.random(1,#buttonsounds)]),volume,100)
end
concommand.Add("cpt_removeweapons", CPT_RemoveWeapons)

local function CPT_KillPlayers(ply)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		for _,v in ipairs(player.GetAll()) do
			if v:IsValid() && v:Alive() then
				v:Kill()
			end
		end
		if (SERVER) then
			ply:SendLua("GAMEMODE:AddNotify(\"Killed All Players\", NOTIFY_CLEANUP, 5)")
		end
		ply:EmitSound(Sound(killsounds[math.random(1,#killsounds)]),volume,100)
		ply:ChatPrint(ply:Nick() .. " has slain everyone!")
	end
end
concommand.Add("cpt_killplayers", CPT_KillPlayers)

local function CPT_KillEverything(ply)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		for _,v in ipairs(ents.GetAll()) do
			if v:IsValid() && v:Health() != nil then
				v:TakeDamage(9999999999,v)
			end
		end
		if (SERVER) then
			ply:SendLua("GAMEMODE:AddNotify(\"Killed  Everything\", NOTIFY_CLEANUP, 5)")
		end
		ply:EmitSound(Sound(killsounds[math.random(1,#killsounds)]),volume,100)
		ply:ChatPrint(ply:Nick() .. " has slain everything!")
	end
end
concommand.Add("cpt_killeverything", CPT_KillEverything)

if (CLIENT) then
local function CPTBaseMenu_Func(panel)
	if !game.SinglePlayer() then
		if !LocalPlayer():IsAdmin() or !LocalPlayer():IsSuperAdmin() then
			panel:AddControl("Label", {Text = "Only Admins Can Access These Settings!"})
			return
		end
	end

	panel:AddControl("Button", {Label = "Reset Map", Command = "cpt_resetmap"})
	panel:AddControl("Button", {Label = "Stop All Sounds", Command = "cpt_stopsounds"})
	panel:AddControl("Button", {Label = "Remove Ammo", Command = "cpt_removeammo"})
	panel:AddControl("Button", {Label = "Remove Weapons", Command = "cpt_removeweapons"})
	panel:AddControl("Button", {Label = "Remove SNPCs", Command = "cpt_removesnpcs"})
	panel:AddControl("Button", {Label = "Remove NPCs", Command = "cpt_removenpcs"})
	panel:AddControl("Button", {Label = "Remove Nextbots", Command = "cpt_removenextbots"})
	panel:AddControl("Button", {Label = "Kill All Players", Command = "cpt_killplayers"})
	panel:ControlHelp("This may lag if there are too many players!")
	panel:AddControl("Button", {Label = "Kill Everything", Command = "cpt_killeverything"})
	panel:ControlHelp("This may crash your game!")
end

function CPTBaseMenu_AddFunc() -- Add menus here
	spawnmenu.AddToolMenuOption("CPTBase","Functions","Default Functions","Default Functions","","",CPTBaseMenu_Func) -- Tab, Dropdown, Select, Title
end

hook.Add("PopulateToolMenu", "CPTBaseMenu_AddFunc", CPTBaseMenu_AddFunc)
end
/*--------------------------------------------------
	Copyright (c) 2018 by Cpt. Hazama, All rights reserved.
	Nothing in these files or/and code may be reproduced, adapted, merged or
	modified without prior written consent of the original author, Cpt. Hazama
--------------------------------------------------*/
AddCSLuaFile('server/cpt_utilities.lua')
include('server/cpt_utilities.lua')

// Combine
CPTBase.AddNPC("Combine Assasssin","npc_cpt_cassassin","CPTBase Redux")
CPTBase.AddNPC("Mortar Synth","npc_cpt_mortarsynth","CPTBase Redux")
CPTBase.AddNPC("Zombie (NB)","nextbot_cpt_testnpc","CPTBase Redux")
-- CPTBase.AddNPC("Combine APC","npc_cpt_apc","CPTBase Redux")

// Fallout
-- CPTBase.AddNPC("Super Mutant","npc_cpt_supermutant","CPTBase Redux")

// Zombies + Enemy Aliens
CPTBase.AddNPC("Puker Zombie","npc_cpt_pukerzombie","CPTBase Redux")
CPTBase.AddNPC("Ichthyosaur","npc_cpt_icky","CPTBase Redux")

CPTBase.AddConVar("cpt_corpselifetime",100)

CPTBase.AddParticleSystem("particles/cpt_blood.pcf",{}) -- I made these myself :)
CPTBase.AddParticleSystem("particles/cpt_darkmessiah.pcf",{}) -- I made these myself :)
CPTBase.AddParticleSystem("particles/cpt_mutation.pcf",{})
CPTBase.AddParticleSystem("particles/mininuke.pcf",{}) -- Credits to Silverlan
CPTBase.AddParticleSystem("particles/mortarsynth_fx.pcf",{}) -- Credits to Silverlan
CPTBase.AddParticleSystem("particles/WEAPON_FX.pcf",{})

game.AddAmmoType({name="9×19mm",dmgtype=DMG_BULLET})
game.AddAmmoType({name="5.7×28mm",dmgtype=DMG_BULLET})
game.AddAmmoType({name="darkpulseenergy",dmgtype=DMG_DISSOLVE})
game.AddAmmoType({name="defaultammo",dmgtype=DMG_BULLET})

-- hook.Add("Think","CPTBase_AdminWeapon",function()
	-- if CLIENT then
		-- local tb = {}
		-- for _,v in ipairs(ents.GetAll()) do
			-- if v:GetClass() == "weapon_cpt_adminweapon" && IsValid(v:GetOwner()) then
				-- if !table.HasValue(tb,v) then
					-- table.insert(tb,v)
				-- end
				-- if !table.HasValue(tb,v:GetOwner()) then
					-- table.insert(tb,v:GetOwner())
				-- end
			-- else
				-- if table.HasValue(tb,v) then
					-- tb[v] = nil
				-- end
			-- end
		-- end
		-- halo.Add(tb,Color(127,0,0),4,4,3,true,true)
	-- end
-- end)

function CPTBase_Chat(ply,spoke)
	local lowered = string.lower(spoke)
	if (ply:IsAdmin() or ply:IsSuperAdmin()) && (string.sub(lowered,1,11) == "!setfaction") then
		local in_faction = string.sub(string.upper(spoke),13)
		ply.Faction = in_faction
		ply:ChatPrint("Set faction to " .. in_faction)
	end
end
hook.Add("PlayerSay","CPTBase_Chat",CPTBase_Chat)

hook.Add("PlayerSpawn","CPTBase_AddDefaultPlayerValues",function(ply)
	ply.IsPossessing = false
	ply:SetNWBool("CPTBase_IsPossessing",false)
	ply:SetNWEntity("CPTBase_PossessedNPCClass",nil)
end)

if CLIENT then
	hook.Add("PlayerStartVoice","CPTBase_SetVoiceData",function(ply)
		for _,v in ipairs(ents.GetAll()) do
			if v:IsValid() && v:IsNPC() && v:GetNWBool("IsCPTBase_NPC") then
				net.Start("cpt_SpeakingPlayer")
				net.WriteEntity(v)
				net.WriteEntity(ply)
				net.SendToServer()
			end
		end
	end)
end
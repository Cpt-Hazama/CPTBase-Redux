/*--------------------------------------------------
	Copyright (c) 2019 by Cpt. Hazama, All rights reserved.
	Nothing in these files or/and code may be reproduced, adapted, merged or
	modified without prior written consent of the original author, Cpt. Hazama
--------------------------------------------------*/
AddCSLuaFile('server/cpt_utilities.lua')
include('server/cpt_utilities.lua')

-- CPTBase.AddAddon("cptbase","54")

// Bots
CPTBase.AddNPC("Player Bot","npc_cpt_bot","CPTBase Redux")

// Combine
CPTBase.AddNPC("Combine Assasssin","npc_cpt_cassassin","CPTBase Redux")
CPTBase.AddNPC("Cremator","npc_cpt_cremator","CPTBase Redux")
CPTBase.AddNPC("Mortar Synth","npc_cpt_mortarsynth","CPTBase Redux")
CPTBase.AddNPC("Combine Soldier","npc_cpt_csoldier","CPTBase Redux")

// Zombies + Enemy Aliens
CPTBase.AddNPC("Parasite","npc_cpt_parasite","CPTBase Redux")
CPTBase.AddNPC("Puker Zombie","npc_cpt_pukerzombie","CPTBase Redux")
CPTBase.AddNPC("Infectious Zombie","npc_cpt_scientistzombie","CPTBase Redux")
CPTBase.AddNPC("Zombie (NB)","nextbot_cpt_testnpc","CPTBase Redux")
CPTBase.AddNPC("Ichthyosaur","npc_cpt_icky","CPTBase Redux")

CPTBase.AddConVar("cpt_npchearing_advanced",0)
CPTBase.AddConVar("cpt_allowspecialdmg",1)
CPTBase.AddConVar("cpt_corpselifetime",100)
CPTBase.AddConVar("cpt_debug_nodegraph",0)
CPTBase.AddConVar("cpt_debug_showcptnodegraph",0)
CPTBase.AddConVar("cpt_debug_cancreategraph",0)
CPTBase.AddConVar("cpt_aiusecustomnodes",0)
CPTBase.AddConVar("cpt_aidifficulty",2) -- 1 = Easy, 2 = Normal, 3 = Hard, 4 = Hell

game.AddAmmoType({name="9×19mm",dmgtype=DMG_BULLET})
game.AddAmmoType({name="5.7×28mm",dmgtype=DMG_BULLET})
game.AddAmmoType({name="5.56×45mm",dmgtype=DMG_BULLET})
game.AddAmmoType({name="darkpulseenergy",dmgtype=DMG_DISSOLVE})
game.AddAmmoType({name="defaultammo",dmgtype=DMG_BULLET})

function CPTBase_Chat(ply,spoke)
	local lowered = string.lower(spoke)
	if (ply:IsAdmin() or ply:IsSuperAdmin()) && (string.sub(lowered,1,11) == "!setfaction") then
		local in_faction = string.sub(string.upper(spoke),13)
		ply.Faction = in_faction
		ply:SetNW2String("CPTBase_NPCFaction",in_faction)
		ply:ChatPrint("Set faction to " .. in_faction)
	end
end
hook.Add("PlayerSay","CPTBase_Chat",CPTBase_Chat)

-- hook.Add("PlayerDeath","CPTBase_DeathData",function(ply)
	-- for _,v in ipairs(ents.GetAll()) do
		-- if v:IsNPC() && v.IsFollowingAPlayer && v.TheFollowedPlayer == ply then
			-- v.IsFollowingAPlayer = false
			-- v.TheFollowedPlayer = NULL
		-- end
	-- end
-- end)

hook.Add("PlayerSpawn","CPTBase_StopIgnition",function(ply)
	timer.Simple(0.02,function()
		if IsValid(ply) then
			if ply:IsOnFire() then
				ply:Extinguish()
			end
		end
	end)
end)

hook.Add("InitialPlayerSpawn","CPTBase_AddDefaultInitialPlayerValues",function(ply)
	ply:SetNW2Bool("CPTBase_IsPossessing",false)
end)

hook.Add("PlayerSpawn","CPTBase_AddDefaultPlayerValues",function(ply)
	ply.IsPossessing = false
	ply.CPTBase_EF_RAD = 0
	ply.CPTBase_ExperiencingEFDamage_RAD = false
	ply.CPTBase_ExperiencingEFDamage_POI = false
	ply.CPTBase_ExperiencingEFDamage_AFTERBURN = false
	ply.CPTBase_ExperiencingEFDamage_FROST = false
	ply.CPTBase_ExperiencingEFDamage_DE = false
	ply.CPTBase_ExperiencingEFDamage_ELEC = false
	ply.CPTBase_Ragdoll = NULL
	ply.CPTBase_HasBeenRagdolled = false
	ply.LastRagdollMoveT = CurTime()
	ply.CPTBase_TotalDrinks = 0
	ply.CPTBase_TimeSinceLastPotionDrink = CurTime()
	ply.CPTBase_CurrentSoundtrack = nil
	ply.CPTBase_CurrentSoundtrackDir = nil
	ply.CPTBase_CurrentSoundtrackNPC = NULL
	ply.CPTBase_CurrentSoundtrackTime = 0
	ply.CPTBase_CurrentSoundtrackRestartTime = 0
	if ply:GetNW2String("CPTBase_NPCFaction") == nil then
		ply:SetNW2String("CPTBase_NPCFaction","FACTION_PLAYER")
	end
	ply:SetNW2Bool("CPTBase_IsPossessing",false)
	ply:SetNW2String("CPTBase_PossessedNPCClass",nil)
	ply:SetNW2Entity("CPTBase_PossessedNPC",NULL)
	ply:SetNW2Int("CPTBase_Magicka",100)
	ply:SetNW2Int("CPTBase_MaxMagicka",100)
	ply:SetNW2Int("CPTBase_NextMagickaT",5)
	ply:SetNW2String("CPTBase_SpellConjuration","npc_cpt_parasite")
end)

if SERVER then
	hook.Add("Think","CPTBase_PlayerRagdolling",function()
		for _,v in ipairs(player.GetAll()) do
			v:UpdateNPCFaction()
			if v:GetNW2Int("CPTBase_Magicka") < v:GetNW2Int("CPTBase_MaxMagicka") && CurTime() > v:GetNW2Int("CPTBase_NextMagickaT") then
				v:SetNW2Int("CPTBase_Magicka",v:GetNW2Int("CPTBase_Magicka") +1)
				if v:GetNW2Int("CPTBase_Magicka") > v:GetNW2Int("CPTBase_MaxMagicka") then
					v:SetNW2Int("CPTBase_Magicka",v:GetNW2Int("CPTBase_MaxMagicka"))
				end
				v:SetNW2Int("CPTBase_NextMagickaT",CurTime() +1)
			end
			if IsValid(v) && v.CPTBase_HasBeenRagdolled then
				if IsValid(v:GetCPTBaseRagdoll()) then
					-- v:GodEnable()
					v:GodDisable()
					v:StripWeapons()
					v:Spectate(OBS_MODE_CHASE)
					v:SpectateEntity(v:GetCPTBaseRagdoll())
					v:SetMoveType(MOVETYPE_OBSERVER)
					v:SetPos(v:GetCPTBaseRagdoll():GetPos())
					if v:GetCPTBaseRagdoll():GetVelocity():Length() > 10 then
						v.LastRagdollMoveT = CurTime() +5
					end
					if v:KeyReleased(IN_FORWARD) then
						v.LastRagdollMoveT = v.LastRagdollMoveT -0.6
					end
					if CurTime() > v.LastRagdollMoveT then
						v:CPTBaseUnRagdoll()
						-- v:GodDisable()
					end
				end
			end
		end
	end)

	hook.Add("PlayerDeath","CPTBase_PlayerRagdollingDeath",function(v,inflictor,attacker)
		if v.CPTBase_HasBeenRagdolled && IsValid(v:GetCPTBaseRagdoll()) then
			if IsValid(v:GetRagdollEntity()) then
				local ent = v:GetCPTBaseRagdoll()
				local rag = v:GetRagdollEntity()
				rag:SetPos(ent:GetPos())
				rag:SetAngles(ent:GetAngles())
				if ent:IsOnFire() then
					rag:Ignite(math.random(8,10),1)
				end
				rag:SetVelocity(ent:GetVelocity())
				for i = 1,128 do
					local bonephys = rag:GetPhysicsObjectNum(i)
					if IsValid(bonephys) then
						local bonepos,boneang = ent:GetBonePosition(rag:TranslatePhysBoneToBone(i))
						if(bonepos) then
							bonephys:SetPos(bonepos)
							bonephys:SetAngles(boneang)
						end
					end
				end
			end
			v:GetCPTBaseRagdoll():Remove()
		end
	end)
end

if CLIENT then
	hook.Add("PlayerStartVoice","CPTBase_SetVoiceData",function(ply)
		for _,v in ipairs(ents.GetAll()) do
			if v:IsValid() && v:IsNPC() && v:GetNW2Bool("IsCPTBase_NPC") then
				net.Start("cpt_SpeakingPlayer")
				net.WriteEntity(v)
				net.WriteEntity(ply)
				net.SendToServer()
			end
		end
	end)
end

properties.Add("Control NPC", {
	MenuLabel = "#Control NPC",
	Order = 9999,
	MenuIcon = "icon16/pill.png",

	Filter = function(self,ent,ply)
		if !IsValid(ent) then return false end
		if !ent:IsNPC() then return false end
		if ent.Base != "npc_cpt_base" then return false end
		return true
	end,
	Action = function(self,ent) -- CS
		self:MsgStart()
			net.WriteEntity(ent)
		self:MsgEnd()
	end,
	Receive = function(self,length,player) -- SV
		local ent = net.ReadEntity()
		if !self:Filter(ent,player) then return end
		if ent.IsPossessed && ent:GetPossessor() != player then return end
		local switch = !ent.IsPossessed
		ent:ControlNPC(switch,player)
	end
})
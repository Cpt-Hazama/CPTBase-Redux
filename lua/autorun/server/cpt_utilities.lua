CPTBase = {
	AddParticleSystem = function(cptDir,cptList)
		game.AddParticles(cptDir)
		local particlename = cptList
		for _,v in ipairs(particlename) do PrecacheParticleSystem(v) end
	end,
	RegisterMod = function(cptName,cptVersion)
		if tbl_cptMods == nil then
			tbl_cptMods = {}
		end
		if cptVersion == nil then
			cptVersion = "0.1.0"
		end
		table.insert(tbl_cptMods,{name = cptName,version = cptVersion})
	end,
	SetSoundDuration = function(snd,dur)
		if SNDDURATION_TABLE == nil then SNDDURATION_TABLE = {} end
		if !table.HasValue(SNDDURATION_TABLE,snd) then
			table.insert(SNDDURATION_TABLE,snd)
		end
		SNDDURATION_TABLE[snd] = dur
	end,
	DefineDecal = function(cptName,cptTbl)
		game.AddDecal(cptName,cptTbl)
	end,
	AddNPC = function(cptName,cptClass,cptCat,cptOnCeiling,cptOnFloor)
		local NPC = {Name = cptName, Class = cptClass, Category = cptCat, OnCeiling = cptOnCeiling,OnFloor = cptOnFloor}
		list.Set("NPC",NPC.Class,NPC)
		if (CLIENT) then
			language.Add(cptClass,cptName)
			language.Add("#" .. cptClass,cptName)
		end
	end,
	AddHumanNPC = function(cptName,cptClass,cptCat,cptWeapons)
		local NPC = {Name = cptName, Class = cptClass, Category = cptCat, Weapons = cptWeapons}
		list.Set("NPC",NPC.Class,NPC)
		if (CLIENT) then
			language.Add(cptClass,cptName)
			language.Add("#" .. cptClass,cptName)
		end
	end,
	AddNPCWeapon = function(cptName,cptClass)
		list.Add("NPCUsableWeapons",{class = cptClass,title = cptName})
	end,
	AddConVar = function(cvName,cvVal)
		CreateConVar(cvName,cvVal,{FCVAR_ARCHIVE})
	end,
	AddClientVar = function(cvName,cvVal,cvSendData)
		CreateClientConVar(cvName,cvVal,cvSendData,false)
	end,
	AddPlayerModel = function(cptName,cptModel,cptArms,cptSkin,cptBodygroup)
		player_manager.AddValidModel(cptName,cptModel)
		player_manager.AddValidHands(cptName,cptArms,cptSkin,cptBodygroup)
		list.Set("PlayerOptionsModel",cptName,cptModel)
	end,
	AddAmmo = function(cptName,cptClass,cptAmmo,cptDamageType)
		game.AddAmmoType({name=cptAmmo,dmgtype=cptDamageType})
		if (CLIENT) then
			if cptName != nil && cptClass != nil then
				language.Add(cptClass,cptName)
				killicon.Add(cptClass,"HUD/killicons/default",Color(255,80,0,255))
				language.Add("#" .. cptClass,cptName)
				killicon.Add("#" .. cptClass,"HUD/killicons/default",Color(255,80,0,255))
			end
		end
	end,
	RegisterNPCWeapon = function(wepName,wepClass,wepIsMelee)
		if CPTBASE_NPCWEAPON_TABLE == nil then CPTBASE_NPCWEAPON_TABLE = {} end
		if !table.HasValue(CPTBASE_NPCWEAPON_TABLE,wepName) then
			table.insert(CPTBASE_NPCWEAPON_TABLE,wepName)
		end
		CPTBASE_NPCWEAPON_TABLE[wepName].Class = wepClass
		CPTBASE_NPCWEAPON_TABLE[wepName].wepIsMelee = wepIsMelee
	end,
	IsInstalled = true
}
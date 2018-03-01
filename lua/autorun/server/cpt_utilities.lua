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
			cptVersion = "1"
		end
		table.insert(tbl_cptMods,{name = cptName,version = cptVersion})
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
			language.Add(cptClass,cptName)
			killicon.Add(cptClass,"HUD/killicons/default",Color(255,80,0,255))
			language.Add("#" .. cptClass,cptName)
			killicon.Add("#" .. cptClass,"HUD/killicons/default",Color(255,80,0,255))
		end
	end,
	IsInstalled = true
}
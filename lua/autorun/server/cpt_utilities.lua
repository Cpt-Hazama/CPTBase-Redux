CPTBase_Addons = {}

CPTBase = {
	AddToTable = function(tbl,data)
		if tbl == nil || !tbl then
			tbl = {}
		end
		table.insert(tbl,data)
	end,
	AddAddon = function(addonID,addonV)
		if CPTBase_Addons == nil then
			CPTBase_Addons = {}
		end
		table.insert(CPTBase_Addons,addonID)
		table.insert(CPTBase_Addons[addonID],addonV)
		-- PrintTable(CPTBase_Addons)
		MsgN("Registering CPTBase addon ID " .. addonID .. ", reference version " .. addonV)
	end,
	FindAddon = function(addonID)
		if CPTBase_Addons[addonID] then
			MsgN("Found CPTBase addon ID " .. addonID)
			return true
		end
		MsgN("Could not locate CPTBase addon ID " .. addonID)
		return false
	end,
	IsAddonUpdated = function(addonID,desiredV)
		local isUpdated = false
		if CPTBase_Addons[addonID] then
			if CPTBase_Addons[addonID] == desiredV then
				isUpdated = true
			end
		end
		if isUpdated == false then
			for _,v in ipairs(player.GetAll()) do
				v:ChatPrint("The addon " .. addonID .. " that you have installed is not the latest version!")
				v:ChatPrint(tostring(CPTBase_Addons[addonID]))
				v:ChatPrint(tostring(desiredV))
			end
		end
		return isUpdated
	end,
	AddParticleSystem = function(cptDir,cptList)
		game.AddParticles(cptDir)
		local particlename = cptList
		for _,v in ipairs(particlename) do PrecacheParticleSystem(v) end
		MsgN("Adding CPTBase particle system " .. cptDir)
	end,
	RegisterMod = function(cptName,cptVersion)
		if tbl_cptMods == nil then
			tbl_cptMods = {}
		end
		if cptVersion == nil then
			cptVersion = "0.1.0"
		end
		table.insert(tbl_cptMods,{name = cptName,version = cptVersion})
		MsgN("Adding CPTBase mod " .. cptName .. ", version " .. cptVersion)
	end,
	SetSoundDuration = function(snd,dur)
		if SNDDURATION_TABLE == nil then SNDDURATION_TABLE = {} end
		if !table.HasValue(SNDDURATION_TABLE,snd) then
			table.insert(SNDDURATION_TABLE,snd)
		end
		SNDDURATION_TABLE[snd] = dur
		MsgN("Creating CPTBase sound duration system " .. snd .. " for " .. dur .. " seconds")
	end,
	DefineDecal = function(cptName,cptTbl)
		game.AddDecal(cptName,cptTbl)
		MsgN("Defining CPTBase decal system " .. cptName)
	end,
	AddNPC = function(cptName,cptClass,cptCat,cptOnCeiling,cptOnFloor)
		local kill = false
		if type(cptOnCeiling) == "string" then
			kill = true
		end
		local NPC
		if kill == false then
			NPC = {Name = cptName, Class = cptClass, Category = cptCat, OnCeiling = cptOnCeiling,OnFloor = cptOnFloor}
		else
			NPC = {Name = cptName, Class = cptClass, Category = cptCat}
		end
		list.Set("NPC",NPC.Class,NPC)
		if (CLIENT) then
			language.Add(cptClass,cptName)
			language.Add("#" .. cptClass,cptName)
			if kill then
				killicon.Add(cptClass,cptOnCeiling,Color(255,255,255,255))
				killicon.Add("#" .. cptClass,cptOnCeiling,Color(255,255,255,255))
			end
		end
		MsgN("Adding CPTBase NPC " .. cptName .. " [" .. cptClass .. "] to spawnmenu category [" .. cptCat .. "]")
	end,
	AddAdminNPC = function(cptName,cptClass,cptCat,cptOnCeiling,cptOnFloor)
		local kill = false
		if type(cptOnCeiling) == "string" then
			kill = true
		end
		local NPC
		if kill == false then
			NPC = {Name = cptName, Class = cptClass, Category = cptCat, OnCeiling = cptOnCeiling,OnFloor = cptOnFloor, AdminOnly = true}
		else
			NPC = {Name = cptName, Class = cptClass, Category = cptCat, AdminOnly = true}
		end
		list.Set("NPC",NPC.Class,NPC)
		if (CLIENT) then
			language.Add(cptClass,cptName)
			language.Add("#" .. cptClass,cptName)
			if kill then
				killicon.Add(cptClass,cptOnCeiling,Color(255,255,255,255))
				killicon.Add("#" .. cptClass,cptOnCeiling,Color(255,255,255,255))
			end
		end
		MsgN("Adding (Admin-Only) CPTBase NPC " .. cptName .. " [" .. cptClass .. "] to spawnmenu category [" .. cptCat .. "]")
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
		MsgN("Registering CPTBase NPC weapon " .. cptName)
	end,
	AddConVar = function(cvName,cvVal)
		CreateConVar(cvName,cvVal,{FCVAR_ARCHIVE})
		MsgN("Registering CPTBase ConVar " .. cvName .. " with default value " .. cvVal)
	end,
	AddClientVar = function(cvName,cvVal,cvSendData)
		CreateClientConVar(cvName,cvVal,cvSendData,false)
		MsgN("Registering CPTBase Client ConVar " .. cvName .. " with default value " .. cvVal)
	end,
	AddPlayerModel = function(cptName,cptModel,cptArms,cptSkin,cptBodygroup)
		player_manager.AddValidModel(cptName,cptModel)
		player_manager.AddValidHands(cptName,cptArms,cptSkin,cptBodygroup)
		list.Set("PlayerOptionsModel",cptName,cptModel)
		MsgN("Registering CPTBase player model " .. cptName)
	end,
	AddAmmo = function(cptName,cptClass,cptAmmo,cptDamageType)
		game.AddAmmoType({name=cptAmmo,dmgtype=cptDamageType})
		if cptName == nil then return end
		if (CLIENT) then
			language.Add(cptClass,cptName)
			killicon.Add(cptClass,"HUD/killicons/default",Color(255,80,0,255))
			language.Add("#" .. cptClass,cptName)
			killicon.Add("#" .. cptClass,"HUD/killicons/default",Color(255,80,0,255))
		end
		MsgN("Adding CPTBase ammo type " .. cptName .. " with a damage type of " .. cptDamageType)
	end,
	RegisterNPCWeapon = function(wepName,wepClass,wepIsMelee)
		if CPTBASE_NPCWEAPON_TABLE == nil then CPTBASE_NPCWEAPON_TABLE = {} end
		if !table.HasValue(CPTBASE_NPCWEAPON_TABLE,wepName) then
			table.insert(CPTBASE_NPCWEAPON_TABLE,wepName)
		end
		CPTBASE_NPCWEAPON_TABLE[wepName].Class = wepClass
		CPTBASE_NPCWEAPON_TABLE[wepName].wepIsMelee = wepIsMelee
	end,
	HasRegisteredKey = function(key,a_id)
		for _,v in ipairs(player.GetAll()) do
			for _,id in ipairs(a_id) do
				local sid = tostring(v:SteamID())
				if game.SinglePlayer() then
					sid = v:Nick()
				end
				if id == sid then
					MsgN("Registered addon key " .. key)
					return true
				end
			end
		end
		return false
	end,
	IsInstalled = true
}

	-- Addon Keys --
if game.SinglePlayer() then
	keyGivenFO4 = {
		[1] = "Raven",
		[2] = "sherkboi10",
		[3] = "🎃💀SpookyLemonade",
		[4] = "=WL= Rawch",
		[5] = "DrVrej",
		[6] = "身体傷害",
		[7] = "Spiderkidder",
		[8] = "Moke weed",
		[9] = "ϟLightning Boltϟ",
		[10] = "Spookzama", // Me
		[00010083] = "U71K-17AS-PT49W"
	}
else
	keyGivenFO4 = {
		[1] = "STEAM_0:1:79138755",
		[2] = "STEAM_0:1:203424197",
		[3] = "STEAM_0:0:-2056404133",
		[4] = "STEAM_0:1:50192742",
		[5] = "STEAM_0:0:22688298",
		[6] = "STEAM_0:1:41437218",
		[7] = "STEAM_0:0:-2047589152",
		[8] = "STEAM_0:0:61346406",
		[9] = "STEAM_0:0:61346406",
		[10] = "STEAM_0:0:38270154", // Me
		[00010083] = "U71K-17AS-PT49W"
	}
end
if !CPTBase then return end
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.ModelTable = {
	-- "models/player/soldier_stripped.mdl",
	-- "models/player/alyx.mdl",
	-- "models/player/dod_american.mdl",
	-- "models/player/arctic.mdl",
	-- "models/player/barney.mdl",
	-- "models/player/breen.mdl",
	-- "models/player/charple.mdl",
	-- "models/player/combine_soldier.mdl",
	-- "models/player/combine_soldier_prisonguard.mdl",
	-- "models/player/combine_super_soldier.mdl",
	-- "models/player/corpse1.mdl",
	-- "models/player/dod_german.mdl",
	-- "models/player/eli.mdl",
	-- "models/player/gasmask.mdl",
	-- "models/player/gman_high.mdl",
	-- "models/player/guerilla.mdl",
	-- "models/player/kleiner.mdl",
	-- "models/player/leet.mdl",
	-- "models/player/magnusson.mdl",
	-- "models/player/monk.mdl",
	-- "models/player/mossman.mdl",
	-- "models/player/mossman_arctic.mdl",
	-- "models/player/odessa.mdl",
	-- "models/player/p2_chell.mdl",
	-- "models/player/phoenix.mdl",
	-- "models/player/police.mdl",
	-- "models/player/police_fem.mdl",
	-- "models/player/riot.mdl",
	-- "models/player/skeleton.mdl",
	-- "models/player/swat.mdl",
	-- "models/player/urban.mdl",
	-- "models/player/zombie_classic.mdl",
	-- "models/player/zombie_fast.mdl",
	-- "models/player/zombie_soldier.mdl"
}
ENT.StartHealth = 100
ENT.CanUseTaunts = true
ENT.UseDefaultWeaponThink = true
ENT.TurnsOnDamage = false
ENT.CanSeeAllEnemies = false
ENT.Faction = "FACTION_PLAYER"
ENT.FriendlyToPlayers = true
ENT.Team = "No Team"
ENT.CanFollowPlayer = true

ENT.BloodEffect = {"blood_impact_red_01"}

ENT.UseTimedSteps = true
ENT.NextFootSound_Walk = 0.4
ENT.NextFootSound_Run = 0.3

ENT.tbl_ChatIdle = {
	"Guys this is really boring",
	"Let's do something already",
	"I wanna kill someone",
	"lol",
	"fag",
	"S&box is gonna be so gay",
	"Spongebob ice cream bars are pretty rad",
	"Can I get a mic check?",
}

ENT.tbl_ChatCombat = {
	"UR DEAD",
	"GONNA KILL U!",
	"LOL REKT",
	"NAME THE BULLY",
	"Waste of Space",
	"Is this all you had to offer?",
	"Expected more from you...",
	"WOW! You're not as good as I had thought.",
	"Jump and kill, can't even touch me.",
	"I'm flying over here, nerd.",
	"Bam you're dead.",
	"Times up chuckle-nuts, you're dead.",
	"Mad? Salty? I can smell it.",
	"I'm about to vapitate all over you!",
	"i'm gonna call the bully hunters on you",
}

ENT.tbl_ChatDeath = {
	"ARE YOU FUCKIN KIDDING ME!!??",
	"seriously..",
	"fuck this shit!",
	"im going invisible.",
	"I'm so done.",
	"ur fucking hacking!",
	"xD",
}

ENT.tbl_Names = {
	"Cpt. Hazama",
	"DrVrej",
	"Mayhem",
	"Vp Snipes",
	"RAWCH",
	"Peanut",
	"Headcrab",
	"GabeN",
	"Mawskeeto",
	"BULLY_HUNTER_77",
	"urmomgaylol",
	"Pyrocynical",
	"FAT",
	"Spy",
	"Hugh Welsh",
	"big gay",
	"CrispiestOhio42",
	"A Professional With Standards",
	"AimBot",
	"AmNot",
	"Aperture Science Prototype XR7",
	"Archimedes!",
	"BeepBeepBoop",
	"Chell",
	"Cannon Fodder",
	"Herr Doktor",
	"H@XX0RZ",
	"LOS LOS LOS",
	"Nom Nom Nom",
	"SMELLY UNFORTUNATE",
	"10001011101",
	"0xDEADBEEF",
	"Numnutz",
	"GENTLE MANNE of LEISURE",
	"Delicious Cake",
	"C++",
	"LUA",
	"Crowbar",
	"The Freeman",
	"roger7",
}

ENT.tbl_Animations = {
	["Walk"] = {ACT_HL2MP_IDLE_AR2},
	["Run"] = {ACT_HL2MP_IDLE_AR2},
	["Idle"] = {ACT_HL2MP_IDLE_AR2},
}

ENT.tbl_Weapons = {
	"weapon_cpt_ar2",
	"weapon_cpt_ar3",
	"weapon_cpt_galil",
	"weapon_cpt_pistol",
	"weapon_cpt_shotgun",
	"weapon_cpt_pipe",
	"weapon_cpt_css_knife",
	"weapon_cpt_css_m16",
	"weapon_cpt_css_fiveseven",
	"weapon_cpt_css_awp",
	"weapon_cpt_css_aug",
	"weapon_cpt_css_famas",
	"weapon_cpt_css_g3",
	"weapon_cpt_css_glock",
	"weapon_cpt_css_m3super",
	"weapon_cpt_css_mp5",
	"weapon_cpt_css_p90",
	"weapon_cpt_css_p228",
	"weapon_cpt_css_sg550",
	"weapon_cpt_css_sg552",
	"weapon_cpt_css_ump",
	"weapon_cpt_css_usp",
	"weapon_cpt_css_xm1014",
	"weapon_cpt_css_ak47",
	"weapon_cpt_css_galil",
	"weapon_cpt_css_mac10",
	"weapon_cpt_css_deagle",
	"weapon_cpt_css_dualelite",
	"weapon_cpt_css_tmp",
	"weapon_cpt_css_m249",
	"weapon_cpt_css_scout",
}

ENT.UseTimedSteps = true
ENT.NextFootSound_Walk = 0.45
ENT.NextFootSound_Run = 0.3

ENT.tbl_Sounds = {
	["FootStep"] = {"npc/footsteps/hardboot_generic1.wav"},
	-- ["Spot"] = {"cptbase/bot/autism.wav","cptbase/bot/butt.wav","cptbase/bot/filfthy.wav","cptbase/bot/liar.wav","cptbase/bot/yell2.wav"},
	-- ["Pain"] = {"cptbase/bot/fuckingfunny.wav","cptbase/bot/notnigeria.wav","cptbase/bot/spastic.wav"},
	-- ["Death"] = {"hl1/fvox/flatline.wav","cptbase/bot/rage1.wav","cptbase/bot/rage2.wav","cptbase/bot/yell1.wav","cptbase/bot/yell3.wav","cptbase/bot/yell4.wav"}
}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnBotCreated()
	self.NextTauntPT = 0
	if GetConVar("cpt_bot_seeenemies"):GetInt() == 1 then
		self.CanSeeAllEnemies = true
	elseif GetConVar("cpt_bot_seeenemies"):GetInt() == 0 then
		self.CanSeeAllEnemies = false
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:BotThink()
	if IsValid(self:GetActiveWeapon()) && !self:GetActiveWeapon().CPTBase_Weapon then
		local wep = self:GetActiveWeapon()
		local wWM = wep:GetModel()
		-- if wep.WorldModel then
			-- wWM = wep.WorldModel
		-- elseif wep.WM then
			-- wWM = wep.WM
		-- end
		local wHT
		if wep.HoldType then
			wHT = wep.HoldType
		elseif wep.NormalHoldType then
			wHT = wep.NormalHoldType
		end
		local wPS = wep.Primary.NumberOfShots
		local wD = wep.Primary.Damage
		local wCS = wep.Primary.ClipSize
		local wDe
		if wep.Primary.Delay then
			wDe = wep.Primary.Sound
		elseif wep.FireDelay then
			wDe = wep.FireDelay
		end
		local wS
		if wep.Primary.Sound then
			wS = wep.Primary.Sound
		elseif wep.Sounds then
			wS = wep.Sounds.sound
		end
		local wWMP
		if wep.WMPos then
			wWMP = wep.WMPos
		end
		local wWMA
		if wep.WMAng then
			wWMP = wep.WMAng
		end
		wep:Remove()
		self:Give("weapon_cpt_bot_weapon")
		local newep = self:GetActiveWeapon()
		newep.Custom_WorldModel = wWM
		newep.Custom_DefaultHoldType = wHT
		newep.Custom_HoldType = wHT
		newep.Custom_Primary_TotalShots = wPS
		newep.Custom_Primary_Damage = wD
		newep.Custom_Primary_ClipSize = wCS
		newep.Custom_Primary_Delay = wDe
		newep.Custom_Primary_NPCFireRate = wDe
		if wWMP then newep.Custom_WM_Pos = wWMP end
		if wWMA then newep.Custom_WM_Ang = wWMA end
		if type(wS) == "table" then
			newep.tbl_Sounds["Fire"] = wS
		else
			newep.tbl_Sounds["Fire"] = {wS}
		end
		newep:SetModel(wWM)
		newep.CanInitializedValues = true
		self:SetupHoldtypes(newep,wHT)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetNPCModel(mdl)
	local count = table.Count(player_manager.AllValidModels())
	for i = 1,count do
		local model = table.Random(player_manager.AllValidModels())
		table.insert(self.ModelTable,model)
	end
	if mdl == nil then
		if table.Count(self.ModelTable) > 0 then
			self:SetModel(self:SelectFromTable(self.ModelTable))
		end
	else
		self:SetModel(mdl)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Duck(possessor)
	if CurTime() > self.NextTauntPT then
		self:PlayTaunt(true)
		self.NextTauntPT = CurTime() +10
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Reload(possessor)
	if IsValid(self:GetActiveWeapon()) then
		if self:GetActiveWeapon():Clip1() < self:GetActiveWeapon().Primary.DefaultClip then
			self:GetActiveWeapon():NPC_Reload()
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:BeforeBotCreated()
	-- if FindLuaFile("autorun/cpt_scpsl_autorun.lua") then
		-- local tb = {
			-- "weapon_cpt_scpsl_e11",
			-- "weapon_cpt_scpsl_e11v2",
			-- "weapon_cpt_scpsl_ar762",
			-- "weapon_cpt_scpsl_logicer",
			-- "weapon_cpt_scpsl_com15",
			-- "weapon_cpt_scpsl_p90",
			-- "weapon_cpt_scpsl_hk417",
			-- "weapon_cpt_scpsl_mp7",
			-- "weapon_cpt_scpsl_microhid",
			-- "weapon_cpt_scpsl_sbx7",
		-- }
		-- table.insert(self.tbl_Weapons,tb)
	-- end
end
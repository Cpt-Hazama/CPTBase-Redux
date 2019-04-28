SWEP.PrintName		= "Unmounted Pulse Rifle"
SWEP.HUDSlot = 4
SWEP.HUDImportance = 3
SWEP.Author 		= "Cpt. Hazama"
SWEP.Category		= "CPTBase"
SWEP.ViewModelFOV	= 40
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/cpthazama/weapons/v_ar3.mdl"
SWEP.WorldModel		= "models/props_combine/bunker_gun01.mdl"
SWEP.HoldType = "crossbow"
SWEP.Base = "weapon_cpt_base"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.UseHands = true

SWEP.AmmoNameTypes = "combine dark energy containers"
SWEP.DrawTime = 2
SWEP.ReloadTime = false
SWEP.WeaponWeight = 85
SWEP.HasShells = false

SWEP.Primary.TotalShots = 1
SWEP.Primary.Spread = 0.04
SWEP.Primary.Tracer = 1
SWEP.Primary.Force = 0
SWEP.Primary.Damage = 18
SWEP.Primary.Delay = 0.04
SWEP.MuzzleEffect = "cpt_muzzle_energy"
SWEP.Primary.TracerEffect = "cpt_tracer_energy"
SWEP.MuzzleFlash_Color = Color(0,115,255)

SWEP.Primary.ClipSize		= 200
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "darkpulseenergy"
SWEP.NPCFireRate = 0.41
SWEP.tbl_NPCFireTimes = {0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4}
SWEP.NPC_EnemyFarDistance = 1350 -- Too Far, chase
SWEP.NPC_FireDistance = 2500
SWEP.NPC_FireDistanceStop = 500
SWEP.NPC_FireDistanceMoveAway = 200
SWEP.NPC_Spread = 10
SWEP.ReloadSpeed = 0.8
SWEP.OverrideBulletPos = true

SWEP.DrawAnimation = ACT_VM_DRAW
SWEP.IdleAnimation = ACT_VM_IDLE
SWEP.FireAnimation = ACT_VM_PRIMARYATTACK
SWEP.ReloadAnimation = ACT_VM_FIDGET

SWEP.AdjustWorldModel = true
SWEP.WorldModelAdjust = {
	Pos = {Right = -0.5,Forward = 6.2,Up = -15},
	Ang = {Right = -180,Up = 180,Forward = 3}
}

SWEP.AdjustViewModel = true
SWEP.ViewModelAdjust = {
	Pos = {Right = -4,Forward = 12,Up = -4},
	Ang = {Right = 0,Up = 0,Forward = 0}
}

SWEP.tbl_Sounds = {
	["DryFire"] = {"weapons/ar2/ar2_empty.wav"},
	["Equip"] = {"physics/metal/weapon_impact_soft2.wav"},
	-- ["Fire"] = {"weapons/airboat/airboat_gun_energy1.wav","weapons/airboat/airboat_gun_energy2.wav"},
	["Fire"] = {"Weapon_FuncTank.Single"},
	["Charge"] = {"buttons/combine_button5.wav"},
	["Reload"] = {"weapons/physcannon/physcannon_charge.wav"}
}

function SWEP:Deploy()
	if SERVER then self:PlayWeaponSound("Equip",70) end
	self.CanUseIdle = false
	self.IsDrawing = true
	if self.Owner:IsPlayer() then
		self.OriginalSpeed = self.Owner:GetWalkSpeed()
		self.OriginalRunSpeed = self.Owner:GetRunSpeed()
	end
	self:PlayerSpeeds("setup")
	-- self.Weapon:SendWeaponAnim(self.DrawAnimation)
	local anim = self.DrawAnimation
	if type(anim) == "table" then
		anim = self:SelectFromTable(anim)
	end
	if type(anim) == "number" then
		self.Weapon:SendWeaponAnim(anim)
	elseif type(anim) == "string" then
		self.Weapon:ResetSequence(self.Weapon:LookupSequence(anim))
		self.Weapon:ResetSequenceInfo()
		if speed == nil then speed = 1 end
		self.Weapon:SetPlaybackRate(speed)
		if loop == nil then loop = 0 end
		self.Weapon:SetCycle(loop)
	end
	timer.Simple(1,function() if self:IsValid() then self.Weapon:SendWeaponAnim(self.ReloadAnimation) self:PlayWeaponSound("Charge",75) end end)
	timer.Simple(self.DrawTime,function() if self:IsValid() then self.CanUseIdle = true self.IsDrawing = false end end)
	timer.Simple(self.DrawTime +0.03,function() if self:IsValid() then self:DoIdleAnimation() end end)
	self.Weapon:SetNextPrimaryFire(self.DrawTime)
	return true
end

local nextnotifyt = 0
function SWEP:OnThink()
	if self:Clip1() == 0 && CurTime() > nextnotifyt then
		sound.Play("buttons/combine_button1.wav",self:GetPos(),75,100,1)
		nextnotifyt = CurTime() +10
	end
end

function SWEP:ReloadSounds()
	self:PlayWeaponSound("Reload",75,160)
end
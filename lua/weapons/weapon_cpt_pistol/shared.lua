SWEP.PrintName		= "Five-SeveN Pistol"
SWEP.HUDSlot = 2
SWEP.HUDImportance = 3
SWEP.Author 		= "Cpt. Hazama"
SWEP.Category		= "CPTBase"
SWEP.ViewModelFOV	= 55
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/cstrike/c_pist_fiveseven.mdl"
SWEP.WorldModel		= "models/weapons/w_pist_fiveseven.mdl"
SWEP.HoldType = "revolver"
SWEP.Base = "weapon_cpt_base"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.UseHands = true

SWEP.DrawTime = false
SWEP.ReloadTime = false
SWEP.WeaponWeight = 5
SWEP.Muzzle = "1"
SWEP.OverrideBulletPos = true

SWEP.Primary.TotalShots = 1
SWEP.Primary.Spread = 0.03
SWEP.Primary.Tracer = 1
SWEP.Primary.Force = 1
SWEP.Primary.Damage = 24
SWEP.Primary.Delay = 0.14

SWEP.Primary.ClipSize		= 20
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "5.7×28mm"
SWEP.NPCFireRate = 0.5
SWEP.tbl_NPCFireTimes = {0,0.25}
SWEP.NPC_EnemyFarDistance = 1350 -- Too Far, chase
SWEP.NPC_FireDistance = 2500
SWEP.NPC_FireDistanceStop = 500
SWEP.NPC_FireDistanceMoveAway = 200
SWEP.NPC_Spread = 5
SWEP.ReloadSpeed = 0.8

SWEP.DrawAnimation = ACT_VM_DRAW
SWEP.IdleAnimation = ACT_VM_IDLE
SWEP.FireAnimation = ACT_VM_PRIMARYATTACK
SWEP.ReloadAnimation = ACT_VM_RELOAD

SWEP.AdjustViewModel = true
SWEP.ViewModelAdjust = {
	Pos = {Right = -3,Forward = 2,Up = 1},
	Ang = {Right = 0,Up = 0,Forward = 0}
}

SWEP.tbl_Sounds = {
	["DryFire"] = {"weapons/clipempty_pistol.wav"},
	["Fire"] = {"weapons/fiveseven/fiveseven-1.wav"},
}
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:BeforeReload() self:SetWeaponHoldType("pistol") end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:FinishedReload() self:SetWeaponHoldType(self.HoldType) end
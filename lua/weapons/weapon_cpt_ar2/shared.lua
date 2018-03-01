SWEP.PrintName		= "Pulse Rifle"
SWEP.Slot			= 2
SWEP.SlotPos		= 3
SWEP.Author 		= "Cpt. Hazama"
SWEP.Category		= "CPTBase"
SWEP.ViewModelFOV	= 55
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/c_irifle.mdl"
SWEP.WorldModel		= "models/weapons/w_irifle.mdl"
SWEP.HoldType = "ar2"
SWEP.Base = "weapon_cpt_base"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.UseHands = true

SWEP.DrawTime = 0.5
SWEP.ReloadTime = false
SWEP.WeaponWeight = 7

SWEP.Primary.TotalShots = 1
SWEP.Primary.Spread = 0.03
SWEP.Primary.Tracer = 1
SWEP.Primary.Force = 1
SWEP.Primary.Damage = 14
SWEP.Primary.Delay = 0.09
SWEP.MuzzleEffect = "cpt_muzzle_combine"
SWEP.Primary.TracerEffect = "cpt_tracer_combine"

SWEP.Primary.ClipSize		= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "darkpulseenergy"
SWEP.NPCFireRate = 0.08
SWEP.NPC_FireDistance = 2000

SWEP.DrawAnimation = ACT_VM_DRAW
SWEP.IdleAnimation = ACT_VM_IDLE
SWEP.FireAnimation = ACT_VM_PRIMARYATTACK
SWEP.ReloadAnimation = ACT_VM_RELOAD

SWEP.AdjustWorldModel = true
SWEP.WorldModelAdjust = {
	Pos = {Right = -4.3,Forward = -6.2,Up = 5},
	Ang = {Right = -10,Up = 180,Forward = 0}
}

SWEP.tbl_Sounds = {
	["DryFire"] = {"weapons/ar2/ar2_empty.wav"},
	["Fire"] = {"weapons/ar1/ar1_dist1.wav","weapons/ar1/ar1_dist2.wav"},
}
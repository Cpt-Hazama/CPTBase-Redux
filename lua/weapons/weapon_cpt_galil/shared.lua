SWEP.PrintName		= "IMI Galil"
SWEP.HUDSlot		= 3
SWEP.HUDImportance 	= 3
SWEP.Author 		= "Cpt. Hazama"
SWEP.Category		= "CPTBase"
SWEP.ViewModelFOV	= 55
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/cstrike/c_rif_galil.mdl"
SWEP.WorldModel		= "models/weapons/w_rif_galil.mdl"
SWEP.HoldType = "ar2"
SWEP.Base = "weapon_cpt_base"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.UseHands = true

SWEP.DrawTime = false
SWEP.ReloadTime = false
SWEP.WeaponWeight = 12

SWEP.Primary.TotalShots = 1
SWEP.Primary.Spread = 0.045
SWEP.Primary.Tracer = 1
SWEP.Primary.Force = 1
SWEP.Primary.Damage = 16
SWEP.Primary.Delay = 0.08
SWEP.Muzzle = "1"
SWEP.MuzzleEffect = "cpt_muzzle"
SWEP.Primary.TracerEffect = "cpt_tracer"
SWEP.OverrideBulletPos = true

SWEP.Primary.ClipSize		= 35
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "5.56×45mm"
SWEP.NPCFireRate = 0.2
SWEP.tbl_NPCFireTimes = {0,0.1}
SWEP.NPC_EnemyFarDistance = 1350 -- Too Far, chase
SWEP.NPC_FireDistance = 2500
SWEP.NPC_FireDistanceStop = 500
SWEP.NPC_FireDistanceMoveAway = 200
SWEP.NPC_Spread = 10
SWEP.ReloadSpeed = 0.8

SWEP.DrawAnimation = ACT_VM_DRAW
SWEP.IdleAnimation = ACT_VM_IDLE
SWEP.FireAnimation = ACT_VM_PRIMARYATTACK
SWEP.ReloadAnimation = ACT_VM_RELOAD

SWEP.AdjustWorldModel = true
SWEP.WorldModelAdjust = {
	Pos = {Right = -4.3,Forward = -6.2,Up = 5},
	Ang = {Right = -10,Up = 180,Forward = 0}
}

SWEP.AdjustViewModel = true
SWEP.ViewModelAdjust = {
	Pos = {Right = -2,Forward = 3,Up = -1},
	Ang = {Right = 0,Up = 0,Forward = 0}
}

SWEP.tbl_Sounds = {
	["DryFire"] = {"weapons/ar2/ar2_empty.wav"},
	["Fire"] = {"weapons/galil/galil-1.wav"},
}
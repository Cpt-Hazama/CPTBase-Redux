SWEP.PrintName		= "Shredder MP5"
SWEP.HUDSlot		= 3
SWEP.HUDImportance 	= 3
SWEP.Author 		= "Cpt. Hazama"
SWEP.Category		= "CPTBase"
SWEP.ViewModelFOV	= 70
SWEP.ViewModelFlip	= true
SWEP.ViewModel		= "models/cpthazama/zombiesurvival/v_smg_mp5.mdl"
SWEP.WorldModel		= "models/cpthazama/zombiesurvival/w_smg_mp5.mdl"
SWEP.HoldType = "ar2"
SWEP.Base = "weapon_cpt_base"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.SwayScale = 0.0001

SWEP.DrawTime = false
SWEP.ReloadTime = false
SWEP.WeaponWeight = 4

SWEP.Primary.TotalShots = 1
SWEP.Primary.Spread = 0.031
SWEP.Primary.Tracer = 1
SWEP.Primary.Force = 2
SWEP.Primary.Damage = 8
SWEP.Primary.Delay = 0.1
SWEP.Muzzle = "1"
SWEP.MuzzleEffect = "cpt_muzzle_zs"
SWEP.Primary.TracerEffect = "cpt_tracer"
SWEP.OverrideBulletPos = true

SWEP.Primary.ClipSize		= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "5.7×28mm"

SWEP.NPCFireRate = 0.4
SWEP.tbl_NPCFireTimes = {0,0.1,0.2,0.3}
SWEP.NPC_EnemyFarDistance = 1350 -- Too Far, chase
SWEP.NPC_FireDistance = 2500
SWEP.NPC_FireDistanceStop = 500
SWEP.NPC_FireDistanceMoveAway = 200
SWEP.NPC_Spread = 10
SWEP.ReloadSpeed = 0.5

SWEP.DrawAnimation = ACT_VM_DRAW
SWEP.IdleAnimation = ACT_VM_IDLE
SWEP.FireAnimation = ACT_VM_PRIMARYATTACK
SWEP.ReloadAnimation = ACT_VM_RELOAD

SWEP.AdjustWorldModel = true
SWEP.WorldModelAdjust = {
	Pos = {Right = -1,Forward = -3,Up = -1},
	Ang = {Right = -10,Up = 0,Forward = 180}
}

SWEP.tbl_Sounds = {
	["DryFire"] = {"weapons/ar2/ar2_empty.wav"},
	["Fire"] = {"cptbase/zs_mp5/fire.wav"},
}
SWEP.WorldModel		= "models/weapons/w_shot_xm1014.mdl"
SWEP.HoldType = "shotgun"
SWEP.Base = "weapon_cpt_base"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.Primary.TotalShots = 7
SWEP.Primary.Spread = 0.08
SWEP.Primary.Damage = 8
SWEP.Muzzle = "muzzle"
SWEP.MuzzleEffect = "cpt_muzzle"
SWEP.Primary.TracerEffect = "cpt_tracer"

SWEP.Primary.ClipSize		= 10
SWEP.Primary.Ammo			= "defaultammo"
SWEP.NPCFireRate = 0.3
SWEP.tbl_NPCFireTimes = {0}
SWEP.NPC_EnemyFarDistance = 800 -- Too Far, chase
SWEP.NPC_FireDistance = 1400
SWEP.NPC_FireDistanceStop = 500
SWEP.NPC_FireDistanceMoveAway = 200
SWEP.NPC_Spread = 14
SWEP.ReloadSpeed = 1

SWEP.tbl_Sounds = {
	["DryFire"] = {"weapons/ar2/ar2_empty.wav"},
	["Fire"] = {"weapons/xm1014/xm1014-1.wav"},
}
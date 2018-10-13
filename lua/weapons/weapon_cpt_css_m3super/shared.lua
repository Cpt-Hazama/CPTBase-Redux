SWEP.WorldModel		= "models/weapons/w_shot_m3super90.mdl"
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

SWEP.Primary.ClipSize		= 8
SWEP.Primary.Ammo			= "defaultammo"
SWEP.NPCFireRate = 2
SWEP.tbl_NPCFireTimes = {0}
SWEP.NPC_EnemyFarDistance = 800 -- Too Far, chase
SWEP.NPC_FireDistance = 1400
SWEP.NPC_FireDistanceStop = 500
SWEP.NPC_FireDistanceMoveAway = 200
SWEP.NPC_Spread = 14
SWEP.ReloadSpeed = 0.8

SWEP.tbl_Sounds = {
	["DryFire"] = {"weapons/ar2/ar2_empty.wav"},
	["Fire"] = {"weapons/m3/m3-1.wav"},
}
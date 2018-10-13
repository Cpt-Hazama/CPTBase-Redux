SWEP.WorldModel		= "models/weapons/w_snip_awp.mdl"
SWEP.HoldType = "ar2"
SWEP.Base = "weapon_cpt_base"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.Primary.TotalShots = 1
SWEP.Primary.Spread = 0.045
SWEP.Primary.Damage = 78
SWEP.Muzzle = "muzzle"
SWEP.MuzzleEffect = "cpt_muzzle"
SWEP.Primary.TracerEffect = "cpt_tracer"

SWEP.Primary.ClipSize		= 5
SWEP.Primary.Ammo			= "defaultammo"
SWEP.NPCFireRate = 4
SWEP.tbl_NPCFireTimes = {0}
SWEP.NPC_EnemyFarDistance = 4000 -- Too Far, chase
SWEP.NPC_FireDistance = 3600
SWEP.NPC_FireDistanceStop = 2500
SWEP.NPC_FireDistanceMoveAway = 1000
SWEP.NPC_Spread = 4
SWEP.ReloadSpeed = 0.2

SWEP.tbl_Sounds = {
	["DryFire"] = {"weapons/ar2/ar2_empty.wav"},
	["Fire"] = {"weapons/awp/awp1.wav"},
}
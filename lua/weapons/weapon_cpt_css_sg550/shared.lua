SWEP.WorldModel		= "models/weapons/w_snip_sg550.mdl"
SWEP.HoldType = "ar2"
SWEP.Base = "weapon_cpt_base"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.Primary.TotalShots = 1
SWEP.Primary.Spread = 0.045
SWEP.Primary.Damage = 23
SWEP.Muzzle = "muzzle"
SWEP.MuzzleEffect = "cpt_muzzle"
SWEP.Primary.TracerEffect = "cpt_tracer"

SWEP.Primary.ClipSize		= 30
SWEP.Primary.Ammo			= "defaultammo"
SWEP.NPCFireRate = 0.2
SWEP.tbl_NPCFireTimes = {0,0.1}
SWEP.NPC_EnemyFarDistance = 4000 -- Too Far, chase
SWEP.NPC_FireDistance = 3600
SWEP.NPC_FireDistanceStop = 2500
SWEP.NPC_FireDistanceMoveAway = 1000
SWEP.NPC_Spread = 4
SWEP.ReloadSpeed = 0.8

SWEP.tbl_Sounds = {
	["DryFire"] = {"weapons/ar2/ar2_empty.wav"},
	["Fire"] = {"weapons/sg550/sg550-1.wav"},
}
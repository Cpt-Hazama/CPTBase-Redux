SWEP.WorldModel		= "models/weapons/w_rif_aug.mdl"
SWEP.HoldType = "smg"
SWEP.Base = "weapon_cpt_base"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.Primary.TotalShots = 1
SWEP.Primary.Spread = 0.045
SWEP.Primary.Damage = 8
SWEP.Muzzle = "muzzle"
SWEP.MuzzleEffect = "cpt_muzzle"
SWEP.Primary.TracerEffect = "cpt_tracer"

SWEP.Primary.ClipSize		= 30
SWEP.Primary.Ammo			= "defaultammo"
SWEP.NPCFireRate = 0.8
SWEP.tbl_NPCFireTimes = {0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8}
SWEP.NPC_EnemyFarDistance = 1350 -- Too Far, chase
SWEP.NPC_FireDistance = 2500
SWEP.NPC_FireDistanceStop = 500
SWEP.NPC_FireDistanceMoveAway = 200
SWEP.NPC_Spread = 6
SWEP.ReloadSpeed = 0.5

SWEP.tbl_Sounds = {
	["DryFire"] = {"weapons/ar2/ar2_empty.wav"},
	["Fire"] = {"weapons/aug/aug-1.wav"},
}
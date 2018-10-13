SWEP.WorldModel		= "models/weapons/w_smg_tmp.mdl"
SWEP.HoldType = "smg"
SWEP.Base = "weapon_cpt_base"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.Primary.TotalShots = 1
SWEP.Primary.Spread = 0.045
SWEP.Primary.Damage = 8
SWEP.Muzzle = "muzzle"
SWEP.MuzzleEffect = "cpt_muzzle_silenced"
SWEP.Primary.TracerEffect = "cpt_tracer"

SWEP.Primary.ClipSize		= 30
SWEP.Primary.Ammo			= "defaultammo"
SWEP.NPCFireRate = 0.25
SWEP.tbl_NPCFireTimes = {0,0.05,0.1,0.15,0.2}
SWEP.NPC_EnemyFarDistance = 1350 -- Too Far, chase
SWEP.NPC_FireDistance = 2500
SWEP.NPC_FireDistanceStop = 500
SWEP.NPC_FireDistanceMoveAway = 200
SWEP.NPC_Spread = 6
SWEP.ReloadSpeed = 0.9

SWEP.tbl_Sounds = {
	["DryFire"] = {"weapons/ar2/ar2_empty.wav"},
	["Fire"] = {"weapons/tmp/tmp-1.wav"},
}
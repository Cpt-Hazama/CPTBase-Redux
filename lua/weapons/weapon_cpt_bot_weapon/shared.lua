SWEP.WorldModel		= "models/error.mdl"
SWEP.HoldType = "none"
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
SWEP.tbl_NPCFireTimes = {0}
SWEP.NPC_EnemyFarDistance = 1350 -- Too Far, chase
SWEP.NPC_FireDistance = 2500
SWEP.NPC_FireDistanceStop = 500
SWEP.NPC_FireDistanceMoveAway = 200
SWEP.NPC_Spread = 8
SWEP.ReloadSpeed = 0.5

SWEP.tbl_Sounds = {
	["DryFire"] = {"weapons/ar2/ar2_empty.wav"},
	["Fire"] = {},
}

SWEP.CanInitializedValues = false
SWEP.Custom_WorldModel = nil
SWEP.Custom_DefaultHoldType = nil
SWEP.Custom_HoldType = nil
SWEP.Custom_Primary_TotalShots = nil
SWEP.Custom_Primary_Damage = nil
SWEP.Custom_Primary_ClipSize = nil
SWEP.Custom_Primary_Delay = nil
SWEP.Custom_Primary_NPCFireRate = nil
SWEP.Custom_WM_Pos = nil
SWEP.Custom_WM_Ang = nil

SWEP.AdjustWorldModel = false
SWEP.WorldModelAttachmentBone = "ValveBiped.Bip01_R_Hand"
SWEP.WorldModelAdjust = {
	Pos = {Right = 0,Forward = 0,Up = 0},
	Ang = {Right = 0,Up = 0,Forward = 0}
}
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnThink_NPC()
	if self.CanInitializedValues then
		self.Owner.OverrideWalkAnimation = self.NPC_WalkAnimation
		self.Owner.OverrideRunAnimation = self.NPC_RunAnimation
		self.Owner:SetIdleAnimation(self.NPC_IdleAnimation)
		self.Weapon:SetClip1(self.Custom_Primary_ClipSize)
		self.WorldModel = self.Custom_WorldModel
		self:SetWeaponHoldType(self.Custom_HoldType)
		self.DefaultHoldType = self.Custom_HoldType
		self.Primary.TotalShots = self.Custom_Primary_TotalShots
		self.Primary.Damage = self.Custom_Primary_Damage
		self.Primary.Delay = self.Custom_Primary_Delay
		self.NPCFireRate = self.Custom_Primary_NPCFireRate
		self:SetModel(self.Custom_WorldModel)
		self.AdjustWorldModel = true
	end
	if self.AdjustWorldModel && self.Custom_WM_Pos && self.Custom_WM_Ang then
		self.WorldModelAdjust = {
			Pos = {Right = self.Custom_WM_Pos.x,Forward = self.Custom_WM_Pos.y,Up = self.Custom_WM_Pos.z},
			Ang = {Right = self.Custom_WM_Ang.p,Up = self.self.Custom_WM_Ang.y,Forward = self.Custom_WM_Ang.r}
		}
	end
end
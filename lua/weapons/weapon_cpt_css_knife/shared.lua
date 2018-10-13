SWEP.WorldModel		= "models/weapons/w_knife_ct.mdl"
SWEP.HoldType = "knife"
SWEP.Base = "weapon_cpt_base"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.Primary.Damage = 20
SWEP.Primary.ClipSize		= 999999999
SWEP.Primary.Ammo			= "defaultammo"

SWEP.NPCFireRate = 0.8
SWEP.NPCMeleeHitTime = 0.2
SWEP.NPC_EnemyFarDistance = 30 -- Too Far, chase
SWEP.NPC_FireDistance = 80
SWEP.NPC_FireDistanceStop = 30
SWEP.NPC_FireDistanceMoveAway = 0
SWEP.NPC_Spread = 8
SWEP.ReloadSpeed = 0.5

SWEP.tbl_Sounds = {
	["DryFire"] = {"weapons/ar2/ar2_empty.wav"},
	["Fire"] = {"weapons/ak47/ak47-1.wav"},
}

---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:PrimaryAttack(ShootPos,ShootDir)
	self.IsFiring = true
	self.CanUseIdle = false
	-- self:PlayWeaponSound("Fire",100)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	if SERVER then
		self.NPC_NextFireT = CurTime() +self:GetNPCFireRate()
	end
	timer.Simple(self.NPCMeleeHitTime,function()
		if self:IsValid() && IsValid(self.Owner) then
			self.Owner:DoDamage(80,self.Primary.Damage,DMG_SLASH)
		end
	end)
	self:OnPrimaryAttack(oldclip,newclip)
	if self.Owner:IsNPC() then
		self:OnPrimaryAttack_NPC()
	end
	timer.Simple(self.Primary.Delay,function() if self:IsValid() then self.IsFiring = false self.CanUseIdle = true end end)
	timer.Simple(self.Primary.Delay +0.001,function() if self:IsValid() then self:DoIdleAnimation() end end)
end
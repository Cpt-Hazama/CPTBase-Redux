SWEP.WorldModel		= "models/weapons/w_pist_elite_single.mdl"
SWEP.SecondWeapon	= "models/weapons/w_pist_elite_single.mdl"
SWEP.HoldType = "dual"
SWEP.Base = "weapon_cpt_base"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.Primary.TotalShots = 1
SWEP.Primary.Spread = 0.045
SWEP.Primary.Damage = 13
SWEP.Muzzle = "muzzle"
SWEP.MuzzleEffect = "cpt_muzzle"
SWEP.Primary.TracerEffect = "cpt_tracer"

SWEP.Primary.ClipSize		= 30
SWEP.Primary.Ammo			= "defaultammo"
SWEP.NPCFireRate = 0.4
SWEP.tbl_NPCFireTimes = {0,0.2}
SWEP.NPC_EnemyFarDistance = 1350 -- Too Far, chase
SWEP.NPC_FireDistance = 2500
SWEP.NPC_FireDistanceStop = 500
SWEP.NPC_FireDistanceMoveAway = 200
SWEP.NPC_Spread = 5
SWEP.ReloadSpeed = 1

SWEP.tbl_Sounds = {
	["DryFire"] = {"weapons/ar2/ar2_empty.wav"},
	["Fire"] = {"weapons/elite/elite-1.wav"},
}
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnInit()
	self.LastFiredElite = "r"
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnPrimaryAttack_NPC()
	if self.Owner:IsNPC() && self.NPC_FireAnimation != nil then
		self:BeforePrimaryAttack_NPC()
		self.Owner:CPT_PlayNPCGesture("range_dual_" .. self.LastFiredElite,2,1)
		if self.LastFiredElite == "r" then
			self.LastFiredElite = "l"
		else
			self.LastFiredElite = "r"
		end
		self:AfterPrimaryAttack_NPC()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CreateMuzzleFlash()
	if self.HasMuzzleFlash == false then return end
	local fx = EffectData()
	if self.LastFiredElite == "r" then
		fx:SetEntity(self.Weapon)
		fx:SetOrigin(self:GetBulletPos())
		fx:SetNormal(self.Owner:GetAimVector())
		fx:SetAttachment(self.Weapon:LookupAttachment(self.Muzzle))
		util.Effect(self.MuzzleEffect,fx)
	else
		fx:SetEntity(self.Owner.EliteB)
		fx:SetOrigin(self.Owner.EliteB:GetPos())
		fx:SetNormal(self.Owner:GetAimVector())
		fx:SetAttachment(self.Owner.EliteB:LookupAttachment(self.Muzzle))
		util.Effect(self.MuzzleEffect,fx)
	end
	if SERVER then
		local fx_light = ents.Create("light_dynamic")
		fx_light:SetKeyValue("brightness",self.MuzzleFlash_Brightness)
		fx_light:SetKeyValue("distance",self.MuzzleFlash_Distance)
		if self.LastFiredElite == "r" then
			fx_light:SetLocalPos(self.Weapon:GetAttachment(1).Pos)
		elseif self.LastFiredElite == "l" then
			fx_light:SetLocalPos(self.Owner.EliteB:GetAttachment(1).Pos)
		end
		fx_light:Fire("Color",self.MuzzleFlash_Color.r .. " " .. self.MuzzleFlash_Color.g .. " " .. self.MuzzleFlash_Color.b)
		fx_light:SetParent(self)
		fx_light:Spawn()
		fx_light:Activate()
		fx_light:Fire("TurnOn","",0)
		fx_light:Fire("Kill","",0.1)
		self:DeleteOnRemove(fx_light)
	end
end
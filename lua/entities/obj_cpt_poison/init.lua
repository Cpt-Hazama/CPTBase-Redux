AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = "models/cpthazama/ball.mdl"
ENT.PhysicsType = SOLID_VPHYSICS
ENT.SolidType = SOLID_CUSTOM
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE
ENT.MoveCollide = COLLISION_GROUP_PROJECTILE
ENT.MoveType = MOVETYPE_VPHYSICS
ENT.StartHealth = 10
ENT.NextParticleT = 0

function ENT:Physics()
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(1)
		phys:SetBuoyancyRatio(0)
		phys:EnableGravity(true)
		phys:EnableDrag(false)
	end
	self:SetNoDraw(true)
	self:DrawShadow(false)
	if self.ImpactSound == nil then
		self.ImpactSound = "npc/antlion_grub/squashed.wav"
	end
	if self.ImpactSoundVolume == nil then
		self.ImpactSoundVolume = 80
	end
	if self.ImpactSoundPitch == nil then
		self.ImpactSoundPitch = 70
	end
end

function ENT:OnTouch(data,phys)
	if self.IsDead == false then
		self.IsDead = true
		self:SetHitEntity(data.HitEntity)
		if self:GetHitEntity():IsPlayer() or self:GetHitEntity():IsNPC() then
			if self:GetHitEntity():GetClass() != "npc_turret_floor" then
				local dmg = DamageInfo()
				dmg:SetDamage(self.Damage)
				dmg:SetAttacker(self:GetEntityOwner())
				dmg:SetInflictor(self)
				dmg:SetDamagePosition(data.HitPos)
				dmg:SetDamageType(self.DamageType)
				self:GetHitEntity():TakeDamageInfo(dmg)
			elseif !self:GetHitEntity().bSelfDestruct then
				self:GetHitEntity():GetPhysicsObject():ApplyForceCenter(self:GetVelocity():GetNormal() *1000)
				self:GetHitEntity():Fire("selfdestruct","",0)
				self:GetHitEntity().bSelfDestruct = true
			end
		end
		util.AddAttackEffect(self:GetEntityOwner(),self:GetHitEntity(),5,DMG_POI,0.5,10)
		self:EmitSound(Sound(self:GetImpactSound()),self.ImpactSoundVolume,self.ImpactSoundPitch)
		self:Remove()
	end
end
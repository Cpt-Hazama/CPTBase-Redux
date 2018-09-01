AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = "models/cpthazama/ball.mdl"
ENT.PhysicsType = SOLID_VPHYSICS
ENT.SolidType = SOLID_CUSTOM
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE
ENT.MoveCollide = COLLISION_GROUP_PROJECTILE
ENT.MoveType = MOVETYPE_VPHYSICS
ENT.MassAmount = 0.1
ENT.CanFade = true
ENT.FadeTime = 4

function ENT:GetMassAmount()
	return self.MassAmount
end

function ENT:SetMassAmount(mass)
	self.MassAmount = mass
end

function ENT:Physics()
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(self:GetMassAmount())
		phys:SetBuoyancyRatio(0)
		phys:EnableGravity(false)
	end
	self:SetNoDraw(true)
	self.NextParticleT = 0
	ParticleEffectAttach("electrical_arc_01_system",PATTACH_POINT_FOLLOW,self,0)
end

function ENT:OnThink()
	if CurTime() > self.NextParticleT then
		ParticleEffectAttach("electrical_arc_01_system",PATTACH_POINT_FOLLOW,self,0)
		self.NextParticleT = CurTime() +0.3
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
		self:EmitSound(Sound("ambient/energy/weld2.wav"),75,100)
		self:Remove()
	end
end
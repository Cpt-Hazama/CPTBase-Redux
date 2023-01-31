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
end

function ENT:OnThink()
	if CurTime() > self.NextParticleT then
		CPT_ParticleEffect("blood_impact_green_01",self:GetPos(),Angle(math.random(0,360),math.random(0,360),math.random(0,360)),self)
		CPT_ParticleEffect("blood_impact_red_01",self:GetPos(),Angle(math.random(0,360),math.random(0,360),math.random(0,360)),self)
		self.NextParticleT = CurTime() +0.1
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
		util.AddAttackEffect(self:GetEntityOwner(),self:GetHitEntity(),2,DMG_POI,1,10)
		self:EmitSound(Sound("npc/antlion_grub/squashed.wav"),75,100)
		self:Remove()
	end
end
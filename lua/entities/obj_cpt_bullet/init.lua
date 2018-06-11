AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = "models/cpthazama/bullet.mdl"
ENT.PhysicsType = SOLID_VPHYSICS
ENT.SolidType = SOLID_CUSTOM
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE
ENT.MoveCollide = COLLISION_GROUP_PROJECTILE
ENT.MoveType = MOVETYPE_VPHYSICS

function ENT:SetBulletMass(mass,gravity)
	self.BulletMass = mass
	self.BulletGravity = gravity
end

function ENT:GetBulletMass()
	return self.BulletMass
end

function ENT:GetBulletGravity()
	return self.BulletGravity
end

function ENT:Physics()
	local Glow = ents.Create("env_sprite")
	Glow:SetKeyValue("model","orangecore2.vmt")
	Glow:SetKeyValue("rendercolor","255 150 100")
	Glow:SetKeyValue("scale","0.03")
	Glow:SetPos(self:GetPos())
	Glow:SetParent(self)
	Glow:Spawn()
	Glow:Activate()
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(self:GetBulletMass())
		phys:SetBuoyancyRatio(0)
		phys:EnableGravity(self:GetBulletGravity())
		phys:EnableDrag(false)
	end
	self:SetNoDraw(true)
	self:DrawShadow(false)
end

-- function ENT:OnThink()
	-- self:SetAngles(self:GetAngles() +Angle(0,0,20))
	-- if self:GetVelocity() != self.InitialVelocity then
		-- self:SetVelocity(self.InitialVelocity)
	-- end
-- end

function ENT:OnTouch(data,phys)
	if self.IsDead == false then
		self.IsDead = true
		self:SetHitEntity(data.HitEntity)
		if self:GetHitEntity():IsPlayer() or self:GetHitEntity():IsNPC() then
			local dmg = DamageInfo()
			dmg:SetDamage(self.Damage)
			dmg:SetAttacker(self:GetEntityOwner())
			dmg:SetInflictor(self)
			dmg:SetDamagePosition(data.HitPos)
			dmg:SetDamageForce(self.DamageForce)
			dmg:SetDamageType(self.DamageType)
			self:GetHitEntity():TakeDamageInfo(dmg)
		end
		self:Remove()
	end
end
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = "models/weapons/w_missile_launch.mdl"
ENT.PhysicsType = SOLID_VPHYSICS
ENT.SolidType = SOLID_CUSTOM
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE
ENT.MoveCollide = COLLISION_GROUP_PROJECTILE
ENT.MoveType = MOVETYPE_VPHYSICS
ENT.StartHealth = 10
ENT.NextParticleT = 0
ENT.CanFade = false

function ENT:Physics()
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetBuoyancyRatio(0)
	end
	self:SetNoDraw(false)
	ParticleEffectAttach("rocket_smoke",PATTACH_ABSORIGIN_FOLLOW,self,0)
	-- self:EmitSound("weapons/rpg/rocket1.wav",70,100)
end

function ENT:OnTouch(data,phys)
	if self.IsDead == false then
		self.IsDead = true
		util.CreateCustomExplosion(self:GetPos(),150,300,self:GetOwner())
		local effectdata = EffectData()
		effectdata:SetOrigin(data.HitPos)
		effectdata:SetScale(50)
		util.Effect("Explosion",effectdata)
		self:Remove()
	end
end
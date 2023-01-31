AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "obj_cpt_base"
ENT.PrintName		= "ENT"
ENT.Author			= "Cpt. Hazama"
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetupDataTables()
	self:NetworkVar("String",0,"SpriteAnim")
	self:NetworkVar("String",1,"SpriteID")
	self:NetworkVar("Bool",0,"Killed")
	self:NetworkVar("Int",0,"SpriteScale")
	self:NetworkVar("Int",1,"SpriteHeight")
	self:NetworkVar("Int",2,"SpriteSize")
	self:NetworkVar("Vector",0,"SpriteOffset")
end
---------------------------------------------------------------------------------------------------------------------------------------------
if CLIENT then
	function ENT:Draw()
		local spriteID = self:GetSpriteID()
		local spriteAnim = self:GetSpriteAnim()
		local scale = self:GetSpriteScale()
		local offset = self:GetSpriteOffset()
		local height = self:GetSpriteHeight()
		local size = self:GetSpriteSize()
		-- self:DrawModel()
		CPTBase.RenderSprite(self,spriteID,spriteAnim,scale,offset,height,size)
	end
	return
end
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.Model = "models/cpthazama/ball.mdl"
ENT.PhysicsType = SOLID_VPHYSICS
ENT.SolidType = SOLID_CUSTOM
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE
ENT.MoveCollide = COLLISION_GROUP_PROJECTILE
ENT.MoveType = MOVETYPE_VPHYSICS
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Physics()
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:SetMass(0.1)
		phys:SetBuoyancyRatio(0)
		phys:EnableGravity(false)
		phys:EnableDrag(false)
	end
	self:SetKilled(false)
	self:SetSpriteID(self.SpriteID)
	self:SetSpriteScale(self.SpriteScale or 1)
	self:SetSpriteHeight(self.SpriteHeight or 0)
	self:SetSpriteSize(self.SpriteSize or 512)
	self:SetSpriteOffset(self.SpriteOffset or Vector(0,-25,25))
	self:SetSpriteAnim(self.IdleAnimation)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnTouch(data,phys)
	if self.IsDead == false then
		self.IsDead = true
		self:SetKilled(true)
		local ent = data.HitEntity
		self:SetHitEntity(ent)
		if ent:IsPlayer() or ent:IsNPC() then
			local dmg = DamageInfo()
			dmg:SetDamage(self.Damage)
			dmg:SetAttacker(self:GetEntityOwner())
			dmg:SetInflictor(self)
			dmg:SetDamagePosition(data.HitPos)
			dmg:SetDamageType(self.DamageType)
			ent:TakeDamageInfo(dmg)
		end
		if self.ImpactSounds then
			self:EmitSound(PICK(self.ImpactSounds),self.ImpactSoundVolume or 75,self.ImpactSoundPitch or 100)
		end
		self:SetSpriteAnim(self.ImpactAnimation)
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(false)
		end
		timer.Simple(self.RemovalDelay or 0,function()
			if IsValid(self) then
				self:Remove()
			end
		end)
	end
end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = "models/props_junk/watermelon01_chunk02c.mdl"
ENT.PhysicsType = SOLID_VPHYSICS
ENT.SolidType = SOLID_CUSTOM
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE
ENT.MoveCollide = 3
ENT.MoveType = MOVETYPE_VPHYSICS
ENT.StartHealth = 1
ENT.CanFade = false
ENT.FadeTime = 8
ENT.Damage = 10
ENT.DamageType = DMG_SLASH
ENT.RemoveOnHitEntity = false

function ENT:Initialize()
	self:SetMoveCollide(self.MoveCollide)
	self:SetCollisionGroup(self.CollisionGroup)
	self:SetModel(self.Model)
	self:PhysicsInit(self.PhysicsType)
	self:SetMoveType(self.MoveType)
	self:SetSolid(self.SolidType)
	self:SetHealth(self.StartHealth)
	self:SetNoDraw(false)
	self:DrawShadow(true)
	self:Physics()
	self:CustomEffects()
	if self.CanFade == true then
		self.RemoveTime = CurTime() +self.FadeTime
	end
	self.IsDead = false
end

function ENT:Physics()
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(1)
		phys:SetBuoyancyRatio(0)
		phys:EnableGravity(false)
		phys:EnableDrag(false)
	end
end

function ENT:CustomEffects() end

function ENT:SetImpactSound(snd,vol,pitch)
	self.ImpactSound = snd
	self.ImpactSoundVolume = vol
	self.ImpactSoundPitch = pitch
end

function ENT:GetImpactSound()
	return self.ImpactSound
end

function ENT:SetHitEntity(ent)
	self:SetNetworkedEntity("CPTProjectile_HitEntity",ent)
end

function ENT:GetHitEntity()
	return self:GetNetworkedEntity("CPTProjectile_HitEntity")
end

function ENT:OnRemove() end

function ENT:SetEntityOwner(ent)
	self:SetOwner(ent)
end

function ENT:GetEntityOwner()
	return IsValid(self:GetOwner()) && self:GetOwner() || self
end

function ENT:OnDamaged(dmg,dmginfo) end

function ENT:OnTakeDamage(dmg,hitgroup,dmginfo)
	local dmginfo = DamageInfo()
	local _Attacker = dmginfo:GetAttacker()
	local _Type = dmg:GetDamageType()
	local _Pos = dmg:GetDamagePosition()
	local _Force = dmg:GetDamageForce()
	local _Force = dmg:GetInflictor()
	local _Inflictor = dmg:GetInflictor()
	self:SetHealth(self:Health() -dmg:GetDamage())
	self:OnDamaged(dmg,dmginfo)
end

function ENT:Think()
	if self.CanFade == true then
		if CurTime() > self.RemoveTime then
			self:Remove()
			return
		end
	end
	self:OnThink()
	self:NextThink(CurTime())
	return true
end

function ENT:OnThink() end

function ENT:OnHit(ent,data,phys)
	if self.IsDead == false then
		self.IsDead = true
		local phys = self:GetPhysicsObject()
		if(phys:IsValid()) then
			phys:EnableMotion(false)
		end
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
				self:GetHitEntity():Fire("selfdestruct","", 0)
				self:GetHitEntity().bSelfDestruct = true
			end
		end
		self:Remove()
	end
end

function ENT:SetDamage(dmg,dmgtype)
	self.Damage = dmg
	if dmgtype then
		self.DamageType = dmgtype
	end
end

function ENT:PhysicsCollide(data,phys)
	if self.RemoveOnHitEntity == true then
		if !data.HitEntity then return true end
		if IsValid(self) then
			self:OnHit(data.HitEntity,data,phys)
			self:Remove()
			return true
		end
	else
		self:OnTouch(data,phys)
	end
	return true
end

function ENT:OnTouch(data,phys) end
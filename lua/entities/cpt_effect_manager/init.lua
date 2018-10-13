AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetPos(Vector(0,0,0))
end

/*
	efm:SetEffectTime(EFDeath)
	efm:SetEffectedEntity(ent)
	efm:SetEffectType("cpthazama/effect_rad")
*/

function ENT:SetEffectTime(time)
	self:SetNetworkedInt("EFtime",time)
	timer.Simple(time,function() if IsValid(self) then self:Remove() end end)
end

function ENT:SetEffectedEntity(ent)
	self:SetNetworkedEntity("EFent",ent)
end

function ENT:GetEffectedEntity()
	return self:GetNetworkedEntity("EFent")
end

function ENT:SetEffectType(ef)
	self:SetNetworkedString("EFType",ef)
end

function ENT:Think()
	if !IsValid(self:GetEffectedEntity()) || IsValid(self:GetEffectedEntity()) && !self:GetEffectedEntity():Alive() then
		self:Remove()
	end
end
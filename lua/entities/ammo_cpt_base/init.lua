AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = ""
ENT.AmmoType = "none"
ENT.AmmoPickup = 1
ENT.MaxAmmo = -1
ENT.PickupSound = "items/ammo_pickup.wav"

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_BBOX)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(1)
	end
end

function ENT:Touch(ent)
	self:SendAmmo(ent)
end

function ENT:Think()
	for _,v in ipairs(ents.FindInSphere(self:GetPos(),20)) do
		if v:IsPlayer() && v:Alive() then
			self:SendAmmo(v)
		end
	end
end

function ENT:SendAmmo(ent)
	if !ent:IsPlayer() || !ent:Alive() then return end
	local pickupAmount = self.MaxAmmo != -1 && math.Clamp(self.AmmoPickup,0,(self.MaxAmmo -ent:GetAmmoCount(self.AmmoType))) or self.AmmoPickup
	if pickupAmount == 0 then return end
	ent:EmitSound(self.PickupSound,75,100 *GetConVarNumber("host_timescale"))
	ent:AddToAmmoCount(pickupAmount,self.AmmoType)
	if file.Exists("lua/autorun/aftm_playerhud.lua","GAME") then
		ent:aftmSendDisplayMessage("pickup","You've picked up (" .. self.AmmoPickup .. ") " .. self.AmmoType .. ".")
	end
	self:Remove()
end
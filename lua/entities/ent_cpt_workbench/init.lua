AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/fallout/workbench.mdl")
	self:SetCollisionGroup(COLLISION_GROUP_NPC)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end
	self.NextRepairT = 0
end

function ENT:Use(activator,caller)
	local random = math.random(15,40)
	local cnd
	local repair
	if activator:IsPlayer() && activator:GetActiveWeapon() != nil then
		local weapon = activator:GetActiveWeapon()
		if weapon.WeaponCondition != nil && weapon.WeaponCondition < 100 then
			cnd = weapon.WeaponCondition
			-- repair = (100 -cnd) +random
			repair = 100 -(cnd +random)
			if repair <= 0 then
				repair = 100
			end
			if CurTime() > self.NextRepairT then
				weapon:SetWeaponCondition(cnd +random)
				self:EmitSound(Sound("cptbase/ui_repairweapon0" .. math.random(1,7) .. ".wav"),75,100 *GetConVarNumber("host_timescale"))
				activator:ChatPrint("You've successfully repaired " .. repair .. "% of your weapon's damages. Your weapon's condition is now " .. weapon.WeaponCondition .. "%")
				if file.Exists("lua/autorun/aftm_playerhud.lua","GAME") then
					activator:aftmSendDisplayMessage("repair")
				end
				self.NextRepairT = CurTime() +10
			else
				activator:ChatPrint("Please wait " .. math.Round(self.NextRepairT -CurTime()) .. " seconds before repairing again.")
			end
		end
	end
end
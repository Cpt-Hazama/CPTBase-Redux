if !CPTBase then return end
AddCSLuaFile('shared.lua')
include('definitions.lua')
include('shared.lua')

ENT.ModelTable = {"models/fallout/supermutant.mdl"}
ENT.StartHealth = 200

ENT.Faction = "FACTION_FEV"

ENT.BloodEffect = {"blood_impact_red_01"}

ENT.tbl_Weapons = {"weapon_cpt_ai_assaultrifle","weapon_cpt_ai_combatshotgun"}

ENT.tbl_Animations = {
	["Walk"] = {ACT_RUN},
	["Run"] = {ACT_RUN},
}

ENT.tbl_Sounds = {
	["FootStep"] = {"cptbase/supermutant/supermutant_foot_l01.mp3"}
}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetInit()
	self:SetHullType(HULL_HUMAN)
	self:SetCollisionBounds(Vector(20,20,105),Vector(-20,-20,0))
	self:CapabilitiesAdd(bit.bor(CAP_MOVE_GROUND,CAP_OPEN_DOORS,CAP_USE))
	self.IsRangeAttacking = false
	self:GiveNPCWeapon(self:SelectFromTable(self.tbl_Weapons))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleEvents(...)
	if(select(1,...) == "emit") then
		if(select(2,...) == "FootLeft" || select(2,...) == "FootRight") then
			self:PlaySound("FootStep",self.RunSoundVolume,90,self.StepSoundPitch,true)
		end
		return true
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	if self:GetActiveWeapon() != NULL then
		self:GetActiveWeapon():OnNPCThink()
		if self:GetActiveWeapon().NPC_UseAnimation == 1 then
			self:SetMovementAnimation(self:GetActiveWeapon().NPC_WalkAnimation)
		elseif self:GetActiveWeapon().NPC_UseAnimation == 2 then
			self:SetMovementAnimation(self:GetActiveWeapon().NPC_RunAnimation)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleSchedules(enemy,dist,nearest,disp)
	if self.IsPossessed then return end
	if(disp == D_HT) then
		-- if self:GetActiveWeapon() != NULL then self:GetActiveWeapon():OnNPCThink() end
	elseif(disp == D_FR) then
		self:Hide()
	end
end
include('shared.lua')
include('viewmodel.lua')

SWEP.PrintName			= ""
SWEP.Slot				= 0
SWEP.SlotPos			= 10
SWEP.DrawAmmo			= true
SWEP.DrawCrosshair		= true
SWEP.BounceWeaponIcon   = true
SWEP.SwayScale			= 1
SWEP.BobScale			= 0.3
SWEP.RenderGroup 		= RENDERGROUP_OPAQUE

function SWEP:DrawWorldModel()
	if self.AdjustWorldModel == true then
		if IsValid(self.Owner) then
			if self.Owner:IsPlayer() && self.Owner:InVehicle() then return end
			self:SetRenderOrigin(self:GetWorldModelPosition().pos)
			self:SetRenderAngles(self:GetWorldModelPosition().ang)
			self:FrameAdvance(FrameTime())
			self:SetupBones()
			self:DrawModel()
		else
			self:SetRenderOrigin(nil)
			self:SetRenderAngles(nil)
			self:DrawModel()
		end
	else
		self:DrawModel()
	end
end

function SWEP:DrawWorldModelTranslucent()
	self:DrawModel()
end
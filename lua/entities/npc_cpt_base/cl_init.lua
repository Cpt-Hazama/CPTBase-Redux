include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Draw()
	self.Entity:DrawModel()
	if self.OnDraw then self:OnDraw() end
end

function ENT:Think()
	if self.OnClientThink then self:OnClientThink() end
end

function ENT:DrawTranslucent() end

function ENT:BuildBonePositions(NumBones,NumPhysBones) end

function ENT:SetRagdollBones(bIn)
	self.m_bRagdollSetup = bIn
end

function ENT:DoRagdollBone(PhysBoneNum,BoneNum) end

function ENT:OnRestore() end

	//-- Custom Functions --\\

function ENT:OnDraw() end

function ENT:OnClientThink() end
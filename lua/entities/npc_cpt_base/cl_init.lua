include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
	self:OnClientInit()
end

function ENT:Draw()
	self:DrawModel()
	if self.OnDraw then
		self:OnDraw()
	end
end

function ENT:Think()
	if self.OnClientThink then
		self:OnClientThink()
	end
	self:AnimateBones()
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:BuildBonePositions(numBones,numPhysBones)
	self.tbl_BonePositions = {}
	for i = 0,numBones -1 do
		local pos,ang = self:GetBonePosition(i)
		self.tbl_BonePositions[i] = {pos,ang}
	end
	self:AnimateBones(numBones,self.tbl_BonePositions)
end

function ENT:SetRagdollBones(bIn)
	self.m_bRagdollSetup = bIn
end

function ENT:DoRagdollBone(PhysBoneNum,BoneNum) end

function ENT:OnRestore() end

	//-- Custom Functions --\\

function ENT:OnClientInit() end

function ENT:OnDraw() end

function ENT:OnClientThink() end

function ENT:AnimateBones(boneCount,bones)
	-- print(self:GetNWBool("LUADATA_PLAYINGANIMATION"),self:GetNWInt("LUADATA_ANIMATION_FRAME"),self:GetNWVector("LUADATA_POS_ANIMATIONID_"),self:GetNWAngle("LUADATA_ANG_ANIMATIONID_"))
	if self:GetNWBool("LUADATA_PLAYINGANIMATION") then
		if self:GetNWInt("LUADATA_ANIMATION_FRAME") != nil then
			for i = 0,self:GetBoneCount() -1 do
				if self:GetNWInt("LUADATA_ANIMATION_BONEID_" .. i) != nil then
					self:SetBonePosition(self:GetNWInt("LUADATA_ANIMATION_BONEID_" .. i),self:GetNWVector("LUADATA_POS_ANIMATIONID_" .. i),self:GetNWAngle("LUADATA_ANG_ANIMATIONID_" .. i))
				end
			end
		end
	end
end
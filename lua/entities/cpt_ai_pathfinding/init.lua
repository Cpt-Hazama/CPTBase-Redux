if !CPTBase then return end
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/props_junk/garbage_glassbottle001a_chunk04.mdl")
	self:SetNoDraw(true)
	self:DrawShadow(false)
	self:SetSolid(SOLID_NONE)
	self:SetSolidMask(MASK_NPCWORLDSTATIC)
	self:SetHealth(math.huge)
	self.ChasePosition = nil
	self:SetModelData()
	self:SetCustomCollisionCheck(true)
end

function ENT:SetModelData()
	if IsValid(self:GetOwner()) then
		if self:GetOwner():GetActivity() != ACT_IDLE then
			self.loco:SetDesiredSpeed(self:GetOwner():GetSequenceGroundSpeed(self:GetOwner():GetSequence()))
		end
		if self:GetOwner():GetPos():Distance(self:GetPos()) > self:GetOwner():GetSequenceGroundSpeed(self:GetOwner():GetSequence()) *1.5 then
			self:SetPos(self:GetOwner():GetPos() +self:GetOwner():GetForward() *20)
		end
	end
end

function ENT:ChasePos(options)
	if IsValid(self:GetOwner()) then
		if !self:GetOwner():CanPerformProcess() then coroutine.yield() return end
		if IsValid(self:GetOwner():GetEnemy()) then
			self.ChasePosition = self:GetOwner():GetEnemy():GetPos()
			local path = Path("Chase")
			path:SetMinLookAheadDistance(options.lookahead or 300)
			path:SetGoalTolerance(options.goaltolerance or 20)
			path:Compute(self,self.ChasePosition)
			if !path:IsValid() then return end
			while path:IsValid() do
				if path:GetAge() > 0.1 then
					path:Compute(self,self.ChasePosition)
				end
				path:Update(self)
				if GetConVarNumber("cpt_aidrawnav") == 1 then path:Draw() end
				if self.loco:IsStuck() then
					self:HandleStuck()
					return
				end
				self:SetModelData()
				coroutine.yield()
			end
		end
	end
end

function ENT:RunBehaviour()
	while (true) do
		if IsValid(self) then
			self:ChasePos({})
			self:SetModelData()
		end
		coroutine.yield()
	end
end

function ENT:HandleStuck()
	if IsValid(self) && self:GetOwner() && IsValid(self:GetOwner()) then
		self:SetPos(self:GetOwner():GetPos() +self:GetOwner():GetForward() *150)
	end
end

function ENT:OnKilled()
	self:Remove()
end
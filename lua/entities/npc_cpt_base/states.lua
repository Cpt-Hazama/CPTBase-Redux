include('shared.lua')

ENT.StringState = "No State"

function ENT:UpdateNPCState()
	local state = self:GetNPCState()
	if state != NPC_STATE_COMBAT && state != NPC_STATE_DEAD then
		self:SetNPCState(NPC_STATE_COMBAT)
	end
end

function ENT:GetState()
	return self:GetNPCState()
end

function ENT:SetState(state,checkscript)
	if state != NPC_STATE_SCRIPT && self:GetNPCState() == NPC_STATE_SCRIPT then return end
	if checkscript && self:GetNPCState() == NPC_STATE_SCRIPT then return end
	local old = self:GetNPCState()
	self:OnStateChanged(old,state)
	self:SetNPCState(state)
end

function ENT:OnStateChanged(laststate,currentstate)
	-- print(laststate,currentstate)
	if laststate == NPC_STATE_IDLE then
		if currentstate == NPC_STATE_ALERT then
			self:CPT_PlaySound("NormalToAlert")
			self.StringState = "Is Alerted"
		elseif currentstate == NPC_STATE_COMBAT then
			self:CPT_PlaySound("NormalToCombat")
			self.StringState = "Is In Combat"
		end
	elseif laststate == NPC_STATE_COMBAT then
		if currentstate == NPC_STATE_IDLE then
			self:CPT_PlaySound("CombatToNormal")
			self.StringState = "Is Idle"
		elseif currentstate == NPC_STATE_LOST then
			self:CPT_PlaySound("CombatToLost") 
			self.StringState = "Lost Enemy"
		end
	elseif laststate == NPC_STATE_ALERT then
		if currentstate == NPC_STATE_COMBAT then
			self:CPT_PlaySound("AlertToCombat")
			self.StringState = "Is In Combat"
		elseif currentstate == NPC_STATE_IDLE then
			self:CPT_PlaySound("AlertToNormal")
			self.StringState = "Is Idle"
		end
	elseif laststate == NPC_STATE_LOST then
		if currentstate == NPC_STATE_COMBAT then
			self:CPT_PlaySound("LostToCombat")
			self.StringState = "Is In Combat"
		elseif currentstate == NPC_STATE_IDLE then
			self:CPT_PlaySound("LostToNormal")
			self.StringState = "Is Idle"
		end
	end
end
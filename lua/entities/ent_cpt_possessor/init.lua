AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.TurnRadius = 25

function ENT:Initialize()
	self:SetModel("models/effects/teleporttrail.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetNoDraw(true)
	self:DrawShadow(false)
	self:SetColor(Color(255,255,255,0))
end

function ENT:PossessTheNPC()
	self.Possessor.IsPossessing = true
	self.Possessor:SetNWBool("CPTBase_IsPossessing",true)
	self.Possessor:SetNWString("CPTBase_PossessedNPCClass",self.PossessedNPC:GetClass())
	self.Possessor:SetNWEntity("CPTBase_PossessedNPC",self.PossessedNPC)
	self.Possessor.CurrentlyPossessedNPC = self.PossessedNPC
	self.Possessor.Faction = "FACTION_NONE"
	local usecam = false
	local camID = nil
	self.PossessorView = ents.Create("prop_dynamic")
	if self.PossessedNPC:GetAttachment(self.PossessedNPC:LookupAttachment("cptbase_possessor_camera")) != nil then
		self.PossessorView:SetPos(self.PossessedNPC:GetAttachment(self.PossessedNPC:LookupAttachment("cptbase_possessor_camera")).Pos)
		usecam = true
		camID = "cptbase_possessor_camera"
	elseif self.PossessedNPC:GetAttachment(self.PossessedNPC:LookupAttachment("possession_cam")) != nil then
		self.PossessorView:SetPos(self.PossessedNPC:GetAttachment(self.PossessedNPC:LookupAttachment("possession_cam")).Pos)
		usecam = true
		camID = "possession_cam"
	else
		if self.PossessedNPC.Possessor_UseBoneCamera then
			self.PossessorView:SetPos(self.PossessedNPC:GetBonePosition(self.PossessedNPC.Possessor_BoneCameraName) +self.PossessedNPC:GetUp() *self.PossessedNPC.Possessor_BoneCameraUp  +self.PossessedNPC:GetRight() *self.PossessedNPC.Possessor_BoneCameraRight  +self.PossessedNPC:GetForward() *self.PossessedNPC.Possessor_BoneCameraForward)
		else
			if self.PossessedNPC.Possessor_UsePossessorViewTable then
				self.PossessorView:SetPos(self.PossessedNPC:GetPos() +Vector(self.PossessedNPC:OBBCenter().x +self.PossessedNPC.PossessorView.Pos.Right,self.PossessedNPC:OBBCenter().y +self.PossessedNPC.PossessorView.Pos.Forward,self.PossessedNPC:OBBMaxs().z +self.PossessedNPC.PossessorView.Pos.Up))
			else
				local min,max = self.PossessedNPC:GetCollisionBounds()
				self.PossessorView:SetPos(self.PossessedNPC:GetPos() +(self:GetUp() *(max.z)))
			end
		end
	end
	self.PossessorView:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	self.PossessorView:SetParent(self.PossessedNPC)
	self.PossessorView:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.PossessorView:Spawn()
	if usecam then
		self.PossessorView:Fire("SetParentAttachment",camID,0)
	end
	self.PossessorView:SetColor(Color(0,0,0,0))
	self.PossessorView:SetNoDraw(false)
	self.PossessorView:DrawShadow(false)
	self.Possessor:GodEnable()
	self.Possessor:Spectate(OBS_MODE_CHASE)
	self.Possessor:SpectateEntity(self.PossessorView)
	self.Possessor:SetNoTarget(true)
	self.Possessor:DrawShadow(false)
	self.Possessor:SetNoDraw(true)
	self.Possessor:SetMoveType(MOVETYPE_OBSERVER)
	self.Possessor:DrawViewModel(false)
	self.Possessor:DrawWorldModel(false)
	self.Possessor.PossessorView = self.PossessorView
	self.Possessor.DefaultHealth = self.Possessor:Health()
	self.Possessor.DefaultArmor = self.Possessor:Armor()
	if (IsValid(self.Possessor:GetActiveWeapon())) then 
		self.PossessorCurrentWeapon = self.Possessor:GetActiveWeapon():GetClass()
	end
	self.PossessorCurrentWeapons = {}
	for k, v in pairs(self.Possessor:GetWeapons()) do
		table.insert(self.PossessorCurrentWeapons,v:GetClass())
	end
	self.Possessor:StripWeapons()
	local targetPos = self.PossessorView:GetPos() +self.Possessor:GetAimVector() *400
	self.PossessorBlock = self:CreateTestingBlock(targetPos,nil,true)
end

function ENT:UpdateBlock()
	local targetPos = self.PossessorView:GetPos() +self.Possessor:GetAimVector() *400
	self.PossessorBlock:SetPos(targetPos)
end

function ENT:PossessedNPC(possessed)
	self.PossessedNPC = possessed
	self.PossessedNPC.IsPossessed = true
	self.PossessedNPC:SetEnemy(NULL)
	self.PossessedNPC.Possessor = self.Possessor
	self.PossessedNPC:StopMoving()
	self.PossessedNPC:ClearSchedule()
	for _,v in ipairs(self.PossessedNPC.tbl_EnemyMemory) do
		self.PossessedNPC:RemoveFromMemory(v)
	end
	if self.PossessedNPC:IsMoving() then
		self.PossessedNPC:StopProcessing()
	end
	self.PossessedNPC:Possess_OnPossessed(self.Possessor)
end

function ENT:FaceForward()
	if self.PossessedNPC.Possessor_CanMove == true then
		if self.PossessedNPC:GetForward():Dot((self.PossessorBlock:GetPos() -self.PossessedNPC:GetPos() +self.PossessedNPC:GetForward() *15):GetNormalized()) < math.cos(math.rad(self.TurnRadius)) then
		-- if self:CheckCanSee(self.PossessorBlock,10) then
			-- self:PlayerChat("TURN")
			self.PossessedNPC:TASKFUNC_FACEPOSITION(self.PossessorBlock:GetPos())
		-- else
			-- self:PlayerChat("GUCCI")
		end
	end
end

function ENT:Think()
	if !self:IsValid() then self:StopPossessing() return end
	if self.PossessorView == nil then self:StopPossessing() return end
	if (!self.PossessorView:IsValid()) then self:StopPossessing() return end
	if !IsValid(self.PossessedNPC) then self:StopPossessing() end
	if !IsValid(self.Possessor) or self.Possessor:KeyDown(IN_USE) or self.Possessor:Health() <= 0 or (!self.Possessor.IsPossessing) or !IsValid(self.PossessedNPC) or self.PossessedNPC:Health() <= 0 then self:StopPossessing() return end
	if self.Possessor.IsPossessing != true then return end
	if (self.Possessor.IsPossessing) && IsValid(self.PossessedNPC) then
		self:UpdateBlock()
		self.PossessedNPC.CanChaseEnemy = false
		self.PossessedNPC:Possess_Think(self.Possessor,self)
		self.PossessedNPC:Possess_Commands(self.Possessor)
		self.PossessedNPC:Possess_CustomCommands(self.Possessor)
		self.PossessedNPC:Possess_Move(self.Possessor)
		if self.Possessor_CanTurnWhileAttacking then
			if self.PossessedNPC.IsLeapAttacking then self.PossessedNPC:Possess_FaceAimPosition() end
			if self.PossessedNPC.IsRangeAttacking then self.PossessedNPC:Possess_FaceAimPosition() end
			if self.PossessedNPC.IsAttacking then self.PossessedNPC:Possess_FaceAimPosition() end
		end
		if self.PossessedNPC:IsMoving() then
			if (self.Possessor:KeyDown(IN_SPEED)) then
				self.PossessedNPC:SetMovementAnimation("Run")
			else
				self.PossessedNPC:SetMovementAnimation("Walk")
			end
		else
			if self.PossessedNPC:CanPerformProcess() then
				self:FaceForward()
			end
		end
	end
	if #self.Possessor:GetWeapons() > 0 then
		self.Possessor:StripWeapons()
	end
	if (self.Possessor:KeyDown(IN_USE)) then
		self.PossessedNPC:StopMoving()
		self:StopPossessing()
	end
	net.Start("cpt_ControllerView")
	net.WriteBool(false)
	net.WriteFloat(self.PossessedNPC:GetMaxHealth())
	net.WriteFloat(self.PossessedNPC:Health())
	net.WriteString(self.PossessedNPC:GetClass())
	net.WriteString(tostring(self.PossessedNPC.HasMutated))
	net.WriteBool(self.PossessedNPC.DidGetHit)
	net.Send(self.Possessor)
	-- self.PossessedNPC:Possess_CustomHUDInterface(self.Possessor)
end

function ENT:StopPossessing(remove)
	remove = remove or true
	if !IsValid(self.Possessor) then return end
	if IsValid(self.Possessor) then
		self.Possessor.IsPossessing = false
		self.Possessor.Faction = nil
		if IsValid(self.PossessedNPC) then
			self.Possessor:SetPos(self.PossessedNPC:GetPos() +self.PossessedNPC:OBBCenter())
		end
		local playerpos = self.Possessor:GetPos()
		self.Possessor:UnSpectate()
		self.Possessor:KillSilent()
		self.Possessor:Spawn()
		self.Possessor:SetNWBool("CPTBase_IsPossessing",false)
		self.Possessor:SetNWString("CPTBase_PossessedNPCClass",nil)
		self.Possessor:SetNWEntity("CPTBase_PossessedNPC",NULL)
		if IsValid(self.PossessorView) then
			self.Possessor:SetPos(self.PossessorView:GetPos() +self.PossessorView:GetUp() *100)
		else
			self.Possessor:SetPos(playerpos)
		end
		for k, v in pairs(self.PossessorCurrentWeapons) do
			self.Possessor:Give(v)
		end
		if (self.PossessorCurrentWeapon) then 
			self.Possessor:SelectWeapon(self.PossessorCurrentWeapon)
		end
		self.Possessor:GodDisable()
		self.Possessor:SetNoDraw(false)
		self.Possessor:DrawShadow(true)
		self.Possessor:SetNoTarget(false)
		self.Possessor:DrawViewModel(true)
		self.Possessor:DrawWorldModel(true)
		self.Possessor:SetHealth(self.Possessor.DefaultHealth)
		self.Possessor:SetArmor(self.Possessor.DefaultArmor)
		for i = 0,self.Possessor:GetBoneCount() -1 do
			ParticleEffect("vortigaunt_glow_beam_cp0",self.Possessor:GetBonePosition(i),Angle(0,0,0),nil)
		end
	end
	if IsValid(self.PossessedNPC) then
		self.PossessedNPC.CanChaseEnemy = true
		self.PossessedNPC.IsPossessed = false
		self.PossessedNPC.Possessor = NULL
		for i = 0,self.PossessedNPC:GetBoneCount() -1 do
			ParticleEffect("vortigaunt_glow_beam_cp0",self.PossessedNPC:GetBonePosition(i),Angle(0,0,0),nil)
		end
		self.PossessedNPC:ClearSchedule()
		self.PossessedNPC:Possess_OnStopPossessing(self.Possessor)
	end
	self.Possessor = nil
	-- if remove == true then
		-- if self.PossessedNPC:IsValid() then
			-- if self.PossessedNPC:Health() > 0 then
				-- ParticleEffect("portal_rift_flash_01",self.PossessedNPC:GetPos() +self.PossessedNPC:OBBCenter(),Angle(0,0,0),nil)
				-- self.PossessedNPC:Remove()
			-- end
		-- end
	-- end
	net.Start("cpt_ControllerView")
	net.WriteBool(true)
	net.WriteFloat(0)
	net.WriteFloat(0)
	net.WriteString("")
	net.WriteString("")
	net.WriteBool(false)
	net.Broadcast()
	self:Remove()
end
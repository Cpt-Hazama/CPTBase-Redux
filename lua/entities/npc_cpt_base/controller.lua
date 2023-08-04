ENT.PossessorOptions = {}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ControlKeys(ent,keys)
	if keys.lmb then
		if self.Possess_Primary then
			self:Possess_Primary(ent)
		else
			if self.DoAttack then
				self:DoAttack()
			end
		end
	end
	if keys.rmb then
		if self.Possess_Secondary then
			self:Possess_Secondary(ent)
		else
			if self.DoRangeAttack then
				self:DoRangeAttack()
			end
		end
	end
	if keys.space then
		if self.Possess_Jump then
			self:Possess_Jump(ent)
		else
			if self.DoLongAttack then
				self:DoLongAttack()
			elseif self.DoLeapAttack then
				self:DoLeapAttack()
			end
		end
	end
	if keys.r then
		if self.Possess_Reload then
			self:Possess_Reload(ent)
		end
	end
	if keys.ctrl then
		if self.Possess_Duck then
			self:Possess_Duck(ent)
		end
	end
	if keys.alt then
		if self.Possess_Walk then
			self:Possess_Walk(ent)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ControlNPC(setControlled,ply,isRemoved)
	if setControlled then
		self.IsPossessed = true
		self:SetPossessor(ply)

		ply:SetNW2Entity("CPTBase_PossessingEntity",self)
		ply:GodEnable()
		ply:Spectate(OBS_MODE_CHASE)
		ply:SpectateEntity(self)
		ply:CPT_SetNoTarget(true)
		ply:DrawShadow(false)
		ply:SetNoDraw(true)
		ply:SetMoveType(MOVETYPE_OBSERVER)
		ply:DrawViewModel(false)
		ply:DrawWorldModel(false)
		ply:StripWeapons()
		ply:SetPos(self:GetPos() +self:OBBCenter())
		return
	end

	local cont = self:GetPossessor(ply)
	if IsValid(cont) then
		cont:SetNW2Entity("CPTBase_PossessingEntity",NULL)
		cont:UnSpectate()
		cont:KillSilent()
		cont:Spawn()
		cont:GodDisable()
		cont:SetNoDraw(false)
		cont:DrawShadow(true)
		cont:CPT_SetNoTarget(false)
		cont:DrawViewModel(true)
		cont:DrawWorldModel(true)
		local ang = self:GetAngles()
		cont:SetEyeAngles(Angle(cont:EyeAngles().p,ang.y,0))
		if isRemoved != true then
			local vec1,vec2 = self:GetCollisionBounds()
			cont:SetPos(self:GetPos() +Vector(0,0,vec2.z +10))
		else
			cont:SetPos(self:GetPos())
		end
	end
	self:SetPossessor(NULL)
	self.IsPossessed = false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetPossessorAimPos(vec)
	self.PossessorAimPos = vec
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetPossessorAimPos()
	return self.PossessorAimPos
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PossessorTrace()
	return self:GetPossessorAimPos()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_AimTarget() -- DEPRECATED, STOP USING THIS
	return self:GetEnemy() or self:PossessorTrace()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_EyeTrace() -- DEPRECATED, STOP USING THIS
	local tr = util.TraceLine({
		start = self:GetPos() +self:OBBCenter(),
		endpos = self:GetPossessorAimPos(),
		filter = self
	})
	return tr
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:IsKeyDown(key)
	return self:GetPossessor():KeyDown(key)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetPlayerKeys(ent)
	local tbKeys = {
		w=self:IsKeyDown(IN_FORWARD),
		a=self:IsKeyDown(IN_MOVELEFT),
		d=self:IsKeyDown(IN_MOVERIGHT),
		s=self:IsKeyDown(IN_BACK),
		lmb=self:IsKeyDown(IN_ATTACK),
		rmb=self:IsKeyDown(IN_ATTACK2),
		alt=self:IsKeyDown(IN_WALK),
		space=self:IsKeyDown(IN_JUMP),
		shift=self:IsKeyDown(IN_SPEED),
		zoom=self:IsKeyDown(IN_ZOOM),
		ctrl=self:IsKeyDown(IN_DUCK),
		e=self:IsKeyDown(IN_USE),
		r=self:IsKeyDown(IN_RELOAD),
		scroll_f=self:IsKeyDown(IN_WEAPON1),
		scroll_b=self:IsKeyDown(IN_WEAPON2),
		tab=self:IsKeyDown(IN_SCORE),
	}

	return tbKeys
end
---------------------------------------------------------------------------------------------------------------------------------------------
local offset = Vector(0,0,15)
local vec0 = Vector(0,0,0)
--
function ENT:ControlMovement()
	local ent = self:GetPossessor()
	local keys = self:GetPlayerKeys(ent)
	if keys.e then
		self:ControlNPC(false)
		return
	end

	local contData = self.PossessorOptions
	local vec1,vec2 = self:GetCollisionBounds()
	local centerPos = self:CPT_GetCenter()
	local aimVec = ent:GetAimVector()
	local forwardDir = ent:GetForward()
	local rightDir = ent:GetRight()
	local upDir = ent:GetUp()
	local startPos = ent:GetPos() +Vector(0,0,10)
	local movePos = startPos
	local moveYaw = 0
	local moveType = 1 // 2
	local moveAmount = math.Clamp(self:GetSequenceGroundSpeed(self:GetSequence()),50,450)
	local act = self:GetActivity()
	local isJumping = act == ACT_JUMP or act == ACT_GLIDE or act == ACT_LAND
	local isAerial = self:GetMoveType() == MOVETYPE_FLY
	if isAerial then
		movePos = ent:GetPos()
		offset = Vector(0,0,0)
	end
	local notMoving = (keys.w == false && keys.a == false && keys.s == false && keys.d == false)

	if self.CanMove then
		local tr = RunTrace(centerPos,centerPos +self:GetForward() *moveAmount,{self,ent})
		if tr.Hit then
			-- moveAmount = moveAmount -self:GetPos():Distance(tr.HitPos)
			moveAmount = self:GetPos():Distance(tr.HitPos) -15
		end
		if keys.shift then
			moveType = 2 // 3
		end
		if keys.w then
			movePos = movePos +forwardDir *moveAmount +offset
		end
		if keys.a then
			movePos = movePos +rightDir *-moveAmount +offset
		end
		if keys.d then
			movePos = movePos +rightDir *moveAmount +offset
		end
		if keys.s then
			movePos = movePos +forwardDir *-moveAmount +offset
		end
		if isAerial then
			if !notMoving then
				startPos = ent:GetPos()
			end
			if keys.ctrl then
				movePos = movePos +upDir *-moveAmount
			end
			if keys.space then
				movePos = movePos +upDir *moveAmount
			end
		end

		local tr = util.TraceHull({
			start = startPos,
			endpos = movePos +offset,
			filter = {self,ent},
			mins = self:OBBMins() /2,
			maxs = self:OBBMaxs() /2
		})
		if tr.Hit then
			movePos = tr.HitPos -tr.Normal *2
		end

		if (isAerial or !isAerial && !self.IsPlayingActivity) && movePos != (startPos) then
			if isAerial then
				local swimType = self.IsSwimType
				local velocity = self:GetVelocity()
				if !swimType && velocity:Length() <= 10 then
					velocity = Vector(0,0,0)
				end
				self:ApplyAngles(movePos,self:GetMaxYawSpeed(),!swimType)
				local moveDir = movePos -self:GetPos()
				local moveSpeed = moveType == 1 && (swimType && self:GetSwimSpeed() or self:GetFlySpeed()) or (swimType && self:GetFastSwimSpeed() or self:GetFastFlySpeed())
				self:SetLocalVelocity(moveDir:GetNormal() *moveSpeed)
				return
			end
			
			local turnPos = movePos
			if self.Possessor_CanFaceTrace or self.ConstantlyFaceEnemy then
			-- if self.Possessor_CanFaceTrace_Walking && moveType == 1 or self.Possessor_CanFaceTrace_Running && moveType == 2 then
				turnPos = self:PossessorTrace()
			end
			self:ApplyAngles(turnPos,self:GetMaxYawSpeed(),true)
			self:GoToPosition(movePos,moveType)
		end
		if notMoving then
			if !self.IsPlayingActivity then
				if self.Controller_UseFirstPerson then
					-- if isJumping then return end
					-- print("RUNNING FACE CODE")
					self:FacePosition(self:WorldToLocal(vec0) +aimVec *400)
				else
					-- if isJumping then return end
					-- print("RUNNING STOP CODE")
					self:CPT_StopMovement()
				end
			end
		end
	else
		if !self.IsPlayingActivity && !self.DisableMovement then
			-- if isJumping then return end
			-- print("RUNNING FACE CODE BOTTOM")
			self:FacePosition(self:WorldToLocal(vec0) +aimVec *400)
		end
	end
	self:ControlKeys(ent,keys)
end
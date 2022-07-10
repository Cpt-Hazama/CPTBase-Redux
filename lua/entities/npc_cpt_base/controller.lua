ENT.PossessorOptions = {}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ControlKeys(ent,keys)
	if keys.lmb && self.DoAttack then
		self:DoAttack()
	end
	if keys.rmb && self.DoRangeAttack then
		self:DoRangeAttack()
	end
	if keys.space && self.DoLongAttack then
		self:DoLongAttack()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ControlNPC(setControlled,ply)
	if setControlled then
		self.IsPossessed = true
		self:SetPossessor(ply)

		ply:SetNW2Entity("CPTBase_PossessingEntity",self)
		ply:GodEnable()
		ply:Spectate(OBS_MODE_CHASE)
		ply:SpectateEntity(self)
		ply:SetNoTarget(true)
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
		cont:SetNoTarget(false)
		cont:DrawViewModel(true)
		cont:DrawWorldModel(true)
		if ePlayer != 0 then
			local vec1,vec2 = self:GetCollisionBounds()
			cont:SetPos(self:GetPos() +Vector(0,0,vec2.z +10))
		else
			cont:SetPos(self:GetPos())
		end
	end
	self.IsPossessed = false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PossessorTrace()
	local ply = self:GetPossessor()
	if !IsValid(ply) then return end

	local tr = util.TraceLine({
		start = ply:GetEyeTrace(),
		endpos = ply:GetShootPos() +ply:GetAimVector() *32768,
		filter = {ply,self},
		mask = MASK_SHOT
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
		alt=self:IsKeyDown(IN_ALT1),
		space=self:IsKeyDown(IN_JUMP),
		shift=self:IsKeyDown(IN_SPEED),
		zoom=self:IsKeyDown(IN_ZOOM),
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
	local contMoveType = contData.MovementType
	local vec1,vec2 = self:GetCollisionBounds()
	local centerPos = self:GetCenter()
	local aimVec = ent:GetAimVector()
	local forwardDir = ent:GetForward()
	local rightDir = ent:GetRight()
	local startPos = ent:GetPos() +Vector(0,0,10)
	local movePos = startPos
	local moveYaw = 0
	local moveType = 1 // 2
	local moveAmount = math.Clamp(self:GetSequenceGroundSpeed(self:GetSequence()),50,450)
	local act = self:GetActivity()
	local isJumping = act == ACT_JUMP or act == ACT_GLIDE or act == ACT_LAND

	if keys.zoom then
		-- self:SetCalcViewData(nil,!self:GetNW2Bool("CH_ControllerUseBone"))
	end
	if keys.scroll_f then
		-- local v = self:GetNW2Vector("CH_ControllerThirdOffset")
		-- self:SetNW2Vector("CH_ControllerThirdOffset",Vector(v.x,v.y +2,v.z))
	end
	if keys.scroll_b then
		-- local v = self:GetNW2Vector("CH_ControllerThirdOffset")
		-- self:SetNW2Vector("CH_ControllerThirdOffset",Vector(v.x,v.y -2,v.z))
	end
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
			if contMoveType == 0 then
				moveYaw = keys.a && 45 or keys.d && -45 or 0
			else
				moveYaw = 0
			end
		end
		if keys.a then
			movePos = movePos +rightDir *-moveAmount +offset
			if contMoveType == 0 then
				moveYaw = !keys.w && (keys.d && 0 or 90) or moveYaw
			else
				moveYaw = 90
			end
		end
		if keys.d then
			movePos = movePos +rightDir *moveAmount +offset
			if contMoveType == 0 then
				moveYaw = !keys.w && (keys.a && 0 or -90) or moveYaw
			else
				moveYaw = -90
			end
		end
		if keys.s then
			movePos = movePos +forwardDir *-moveAmount +offset
			if contMoveType == 0 then
				moveYaw = !keys.w && (keys.a && 135 or keys.d && -135 or 180) or moveYaw
			else
				moveYaw = 180
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
		-- if CurTime() > t then
		-- 	self:TestBlock(movePos,3)
		-- 	t = CurTime() +0.5
		-- end
		if (keys.w == false && keys.a == false && keys.s == false && keys.d == false) then
			if !self.IsPlayingActivity then
				if self.Controller_UseFirstPerson then
					-- if isJumping then return end
					self:FacePosition(self:WorldToLocal(vec0) +aimVec *400)
				else
					-- if isJumping then return end
					self:StopMovement()
				end
			end
		end
		if !self.IsPlayingActivity && movePos != (startPos) then
			-- self:SetLastPos(movePos)
			-- self:RunTaskData(moveType)
			-- if isJumping then return end
			self.ForcedMovement = true
			local targetYaw = 0
			if IsValid(self.ViewTarget) then
				movePos = self.ViewTarget:GetPos()
				targetYaw = moveYaw
			end
			
			-- DebugBlock(movePos)
			self:ApplyAngles(movePos,self.MaxTurnSpeed,true)
			-- self:SetPoseParameter("move_yaw",targetYaw)
			-- self:ForceAnimation(self:SetMovementAnimation(moveType == 1 && "Walk" or "Run"))
			self:GoToPosition(movePos,moveType)
		else
			self.ForcedMovement = false
		end
	else
		if !self.IsPlayingActivity && !self.DisableMovement then
			-- if isJumping then return end
			self:FacePosition(self:WorldToLocal(vec0) +aimVec *400)
		end
	end
	self:ControlKeys(ent,keys)
end
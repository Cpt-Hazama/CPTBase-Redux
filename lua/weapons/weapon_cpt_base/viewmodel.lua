include('shared.lua')

function SWEP:ViewModelDrawn()
	if self.ExtraViewModel then
		local setvalid = IsValid(self._CModel)
		if !setvalid then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self._CModel = ClientsideModel(self.ExtraViewModel)
				self._CModel:SetPos(vm:GetPos())
				self._CModel:SetAngles(vm:GetAngles())
				self._CModel:AddEffects(EF_BONEMERGE)
				self._CModel:SetNoDraw(true)
				self._CModel:SetParent(vm)
				setvalid = true
			end
		end
		if setvalid then
			self._CModel:DrawModel()
			self.CWeaponModel = self._CModel
			if self._CModel:GetAttachment(self._CModel:LookupAttachment(self.Muzzle)) == nil then return end
			local ShootPos
			if self._CModel:GetAttachment(self._CModel:LookupAttachment(self.Muzzle)).Pos != nil then
				ShootPos = self._CModel:GetAttachment(self._CModel:LookupAttachment(self.Muzzle)).Pos
			else
				ShootPos = false
			end
			if (ShootPos != nil or ShootPos != false) && IsValid(self.Owner) then
				if ShootPos == self._CModel:GetAttachment(self._CModel:LookupAttachment(self.Muzzle)).Pos then
					-- net.Start("cpt_CModelshootpos")
					-- net.WriteVector(ShootPos)
					-- net.WriteEntity(self)
					-- net.SendToServer()
					self:SetNW2Vector("cpt_CModelshootpos",ShootPos)
				end
			end
			-- net.Start("cpt_CModel")
			-- net.WriteEntity(self._CModel)
			-- net.WriteEntity(self)
			-- net.SendToServer()
			self:SetNW2Vector("cpt_CModelshootpos",ShootPos)
			self:SetNW2Entity("cpt_CModel",self._CModel)
			-- print(self:GetNW2Entity("cpt_CModel"))
			-- print(self._CModel)
		end
	end
end

function SWEP:GetViewModelPosition(pos,ang) // Refer to the hook for movement
	local opos = pos *1
	local frameMultiply = self.IdleFPS
	local jump = 0
	local move1 = 0
	local move2 =  0
	local ironsights = self:GetNW2Bool("cptbase_UseIronsights")
	if self.AdjustViewModel == true then
		local adjustData = self.ViewModelAdjust
		opos:Add(ang:Right() *(adjustData.Pos.Right))
		opos:Add(ang:Forward() *(adjustData.Pos.Forward))
		opos:Add(ang:Up() *(adjustData.Pos.Up))
		pos:Add(ang:Right() *(adjustData.Pos.Right))
		pos:Add(ang:Forward() *(adjustData.Pos.Forward))
		pos:Add(ang:Up() *(adjustData.Pos.Up))
		ang:RotateAroundAxis(ang:Right(),adjustData.Ang.Right)
		ang:RotateAroundAxis(ang:Up(),adjustData.Ang.Up)
		ang:RotateAroundAxis(ang:Forward(),adjustData.Ang.Forward)
	else
		if ironsights == false then
			opos:Add(ang:Right() *0)
			opos:Add(ang:Forward() *0)
			opos:Add(ang:Up() *0)
			pos:Add(ang:Right() *0)
			pos:Add(ang:Forward() *0)
			pos:Add(ang:Up() *0)
			ang:RotateAroundAxis(ang:Right(),0)
			ang:RotateAroundAxis(ang:Up(),0)
			ang:RotateAroundAxis(ang:Forward(),0)
		elseif ironsights == true then
			local adjustData = self.Ironsights
			-- opos:Add(ang:Right() *(adjustData.Pos.Right))
			-- opos:Add(ang:Forward() *(adjustData.Pos.Forward))
			-- opos:Add(ang:Up() *(adjustData.Pos.Up))
			opos:Add(Lerp(1,ang:Right(),ang:Right() *(adjustData.Pos.Right)))
			opos:Add(Lerp(1,ang:Forward(),ang:Forward() *(adjustData.Pos.Forward)))
			opos:Add(Lerp(1,ang:Up(),ang:Up() *(adjustData.Pos.Up)))
			pos:Add(Lerp(1,ang:Right(),ang:Right() *(adjustData.Pos.Right)))
			pos:Add(Lerp(1,ang:Forward(),ang:Forward() *(adjustData.Pos.Forward)))
			pos:Add(Lerp(1,ang:Up(),ang:Up() *(adjustData.Pos.Up)))
			-- ang:RotateAroundAxis(Lerp(1,ang:Right(),ang:Right(),adjustData.Ang.Right))
			-- ang:RotateAroundAxis(Lerp(1,ang:Up(),ang:Up(),adjustData.Ang.Up))
			-- ang:RotateAroundAxis(Lerp(1,ang:Forward(),ang:Forward(),adjustData.Ang.Forward))
			-- pos:Add(ang:Right() *(adjustData.Pos.Right))
			-- pos:Add(ang:Forward() *(adjustData.Pos.Forward))
			-- pos:Add(ang:Up() *(adjustData.Pos.Up))
			ang:RotateAroundAxis(ang:Right(),adjustData.Ang.Right)
			ang:RotateAroundAxis(ang:Up(),adjustData.Ang.Up)
			ang:RotateAroundAxis(ang:Forward(),adjustData.Ang.Forward)
		end
	end

	-- if self.UseLuaMovement == true then
	-- 	if !self:GetNW2Bool("cptbase_UseIronsights") then
	-- 		ang = ang +Angle(math.cos(CurTime() *frameMultiply),math.cos(CurTime() *frameMultiply) /2,math.cos(CurTime() *frameMultiply))
	-- 	end
	-- 	if self.Owner:IsOnGround() then
	-- 		if jump > 0 then
	-- 			jump = jump -0.5
	-- 		end
	-- 	else
	-- 		if jump < 6 then
	-- 			jump = jump +0.1
	-- 		end
	-- 	end
	-- 	ang:RotateAroundAxis(ang:Right(),jump)
	-- 	ang:RotateAroundAxis(ang:Up(),(jump *-0.3))
	-- 	ang:RotateAroundAxis(ang:Forward(),0)
	-- 	local walkspeed = self.Owner:GetVelocity():Length() 
	-- 	if walkspeed > 0 then
	-- 		if !self.Owner:KeyDown(IN_WALK) && !self.Owner:KeyDown(IN_SPEED) && !self.Owner:KeyDown(IN_DUCK) && self.Owner:IsOnGround() && (self.Owner:KeyDown(IN_FORWARD) or self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_MOVELEFT) or self.Owner:KeyDown(IN_MOVERIGHT)) then
	-- 			move1 = 17
	-- 			move2 = 3
	-- 		elseif (self.Owner:KeyDown(IN_WALK) or self.Owner:KeyDown(IN_DUCK)) && !self.Owner:KeyDown(IN_SPEED) && self.Owner:IsOnGround() && (self.Owner:KeyDown(IN_FORWARD) or self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_MOVELEFT) or self.Owner:KeyDown(IN_MOVERIGHT)) then
	-- 			move1 = 15
	-- 			move2 = 10
	-- 		elseif self.Owner:KeyDown(IN_SPEED) && self.Owner:IsOnGround() && (self.Owner:KeyDown(IN_FORWARD) or self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_MOVELEFT) or self.Owner:KeyDown(IN_MOVERIGHT)) then
	-- 			move1 = 20
	-- 			move2 = 1 +(self.WeaponWeight /75)
	-- 		else
	-- 			move1 = 0
	-- 			move2 = 100
	-- 		end
	-- 		ang = ang +Angle(math.cos(CurTime() *move1) /move2,math.cos(CurTime() *move1 /2) /move2,0)
	-- 	end
	-- end
	return pos,ang
end

function SWEP:CalcViewModelView(vm, OldEyePos, OldEyeAng, EyePos, EyeAng)
	if self.UseLuaMovement == true then
		local ironsights = self:GetNW2Bool("cptbase_UseIronsights")
		local EyePos, EyeAng = self:GetViewModelPosition(OldEyePos, OldEyeAng)
		local ply = self:GetOwner()
		local EyePos = OldEyePos
		local EyeAng = OldEyeAng

		local realspeed = ply:GetVelocity():Length2D() /ply:GetRunSpeed()
		local speed = math.Clamp(ply:GetVelocity():Length2DSqr() /ply:GetRunSpeed(), 0.25, 1)

		local bob_x_val = CurTime() *(ironsights && 2 or 8)
		local bob_y_val = CurTime() *(ironsights && 4 or 16)
		
		local bob_x = math.sin(bob_x_val*0.1)*0.5
		local bob_y = math.sin(bob_y_val*0.15)*0.05
		EyePos = EyePos + EyeAng:Right()*bob_x
		EyePos = EyePos + EyeAng:Up()*bob_y
		EyeAng:RotateAroundAxis(EyeAng:Forward(), 5 *bob_x)
		
		local speed_mul = 2
		if self:GetOwner():IsOnGround() && realspeed > 0.1 then
			local bobspeed = math.Clamp(realspeed*1.1, 0, 1)
			local bob_x = math.sin(bob_x_val*1*speed) *0.1 *bobspeed
			local bob_y = math.cos(bob_y_val*1*speed) *0.125 *bobspeed
			EyePos = EyePos + EyeAng:Right()*bob_x*speed_mul *0.65
			EyePos = EyePos + EyeAng:Up() *bob_y *speed_mul *1.5
		end

		if FrameTime() < 0.04 then
			if !self.SwayPos then self.SwayPos = Vector() end
			local vel = ply:GetVelocity()
			vel.x = math.Clamp(vel.x/300, -0.5, 0.5)
			vel.y = math.Clamp(vel.y/300, -0.5, 0.5)
			vel.z = math.Clamp(vel.z/750, -1, 0.5)
			
			self.SwayPos = LerpVector(FrameTime()*25, self.SwayPos, -vel)
			EyePos = EyePos + self.SwayPos
		end

		local EyePos, EyeAng = self:GetViewModelPosition(EyePos, EyeAng)
		return EyePos, EyeAng
	end
	return EyePos, EyeAng
end
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
					self:SetNWVector("cpt_CModelshootpos",ShootPos)
				end
			end
			-- net.Start("cpt_CModel")
			-- net.WriteEntity(self._CModel)
			-- net.WriteEntity(self)
			-- net.SendToServer()
			self:SetNWVector("cpt_CModelshootpos",ShootPos)
			self:SetNWEntity("cpt_CModel",self._CModel)
			-- print(self:GetNWEntity("cpt_CModel"))
			-- print(self._CModel)
		end
	end
end

// Credit to zombine, I am not taking credit for this I just prefer his viewmodel movement more than mine :v
local function CalculateVector(start,scale,direction,dest)
	dest.x = start.x +direction.x *scale
	dest.y = start.y +direction.y *scale
	dest.z = start.z +direction.z *scale
end

hook.Add("CalcViewModelView","CPTBase_WeaponBase_Viewmodel",function(weapon,vm,oldpos,oldang,pos,ang)
	if weapon.CPTBase_Weapon != true then return end
	if weapon.UseLuaMovement == false then return end
	local Weapon_OriginalPos = Vector(pos.x,pos.y,pos.z)
	local Weapon_OriginalAngles = Angle(ang.x,ang.y,ang.z)
	local Scale_Forward = weapon.LuaMovementScale_Forward
	local Scale_Right = weapon.LuaMovementScale_Right
	local Scale_Up = weapon.LuaMovementScale_Up
	local Shift_Speed = 8
	vm.LastFacingAngle = vm.LastFacingAngle or ang:Forward()
	local forward = ang:Forward()
	if FrameTime() != 0 then
		local difference = forward -vm.LastFacingAngle
		local totaldifference = difference:Length()
		if totaldifference > 1.5 then
			local scale = totaldifference /1.5
			Shift_Speed = Shift_Speed *scale
		end
		CalculateVector(vm.LastFacingAngle,Shift_Speed *FrameTime(),difference,vm.LastFacingAngle)
		vm.LastFacingAngle:Normalize()
		CalculateVector(pos,5,difference * -1,pos)
	end
	local right,up
	right = oldang:Right()
	up = oldang:Up()
	local pitch = oldang[1]
	if (pitch > 180) then
		pitch = pitch -360
	elseif (pitch < -180) then
		pitch = pitch +360
	end

	CalculateVector(pos,-pitch *Scale_Forward,forward,pos)
	CalculateVector(pos,-pitch *Scale_Right,right,pos)
	CalculateVector(pos,-pitch *Scale_Up,up,pos)
end)

function SWEP:GetViewModelPosition(pos,ang) // Refer to the hook for movement
	local opos = pos *1
	local duck1 = 0
	local duck2 = 0
	local jump = 0
	local move1 = 0
	local move2 =  0
	if self.AdjustViewModel == true then
		if self:GetNWBool("cptbase_UseIronsights") == false then
			opos:Add(ang:Right() *(self.ViewModelAdjust.Pos.Right))
			opos:Add(ang:Forward() *(self.ViewModelAdjust.Pos.Forward))
			opos:Add(ang:Up() *(self.ViewModelAdjust.Pos.Up))
			pos:Add(ang:Right() *(self.ViewModelAdjust.Pos.Right))
			pos:Add(ang:Forward() *(self.ViewModelAdjust.Pos.Forward))
			pos:Add(ang:Up() *(self.ViewModelAdjust.Pos.Up))
			ang:RotateAroundAxis(ang:Right(),self.ViewModelAdjust.Ang.Right)
			ang:RotateAroundAxis(ang:Up(),self.ViewModelAdjust.Ang.Up)
			ang:RotateAroundAxis(ang:Forward(),self.ViewModelAdjust.Ang.Forward)
		elseif self:GetNWBool("cptbase_UseIronsights") == true then
			opos:Add(ang:Right() *(self.ViewModelAdjust.Pos.Right))
			opos:Add(ang:Forward() *(self.ViewModelAdjust.Pos.Forward))
			opos:Add(ang:Up() *(self.ViewModelAdjust.Pos.Up))
			pos:Add(ang:Right() *(self.ViewModelAdjust.Pos.Right))
			pos:Add(ang:Forward() *(self.ViewModelAdjust.Pos.Forward))
			pos:Add(ang:Up() *(self.ViewModelAdjust.Pos.Up))
			ang:RotateAroundAxis(ang:Right(),self.ViewModelAdjust.Ang.Right)
			ang:RotateAroundAxis(ang:Up(),self.ViewModelAdjust.Ang.Up)
			ang:RotateAroundAxis(ang:Forward(),self.ViewModelAdjust.Ang.Forward)
		end
	else
		if self:GetNWBool("cptbase_UseIronsights") == false then
			opos:Add(ang:Right() *0)
			opos:Add(ang:Forward() *0)
			opos:Add(ang:Up() *0)
			pos:Add(ang:Right() *0)
			pos:Add(ang:Forward() *0)
			pos:Add(ang:Up() *0)
			ang:RotateAroundAxis(ang:Right(),0)
			ang:RotateAroundAxis(ang:Up(),0)
			ang:RotateAroundAxis(ang:Forward(),0)
		elseif self:GetNWBool("cptbase_UseIronsights") == true then
			opos:Add(ang:Right() *(self.Ironsights.Pos.Right))
			opos:Add(ang:Forward() *(self.Ironsights.Pos.Forward))
			opos:Add(ang:Up() *(self.Ironsights.Pos.Up))
			pos:Add(ang:Right() *(self.Ironsights.Pos.Right))
			pos:Add(ang:Forward() *(self.Ironsights.Pos.Forward))
			pos:Add(ang:Up() *(self.Ironsights.Pos.Up))
			ang:RotateAroundAxis(ang:Right(),self.Ironsights.Ang.Right)
			ang:RotateAroundAxis(ang:Up(),self.Ironsights.Ang.Up)
			ang:RotateAroundAxis(ang:Forward(),self.Ironsights.Ang.Forward)
		end
	end

	if self.UseLuaMovement == true then
		if self.Owner:IsOnGround() then
			if jump > 0 then
				jump = jump -0.5
			end
		else
			if jump < 6 then
				jump = jump +0.1
			end
		end
		ang:RotateAroundAxis(ang:Right(),jump)
		ang:RotateAroundAxis(ang:Up(),(jump *-0.3))
		ang:RotateAroundAxis(ang:Forward(),0)
		local walkspeed = self.Owner:GetVelocity():Length() 
		if walkspeed > 0 then
			if !self.Owner:KeyDown(IN_WALK) && !self.Owner:KeyDown(IN_SPEED) && !self.Owner:KeyDown(IN_DUCK) && self.Owner:IsOnGround() && (self.Owner:KeyDown(IN_FORWARD) or self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_MOVELEFT) or self.Owner:KeyDown(IN_MOVERIGHT)) then
				move1 = 17
				move2 = 3
			elseif (self.Owner:KeyDown(IN_WALK) or self.Owner:KeyDown(IN_DUCK)) && !self.Owner:KeyDown(IN_SPEED) && self.Owner:IsOnGround() && (self.Owner:KeyDown(IN_FORWARD) or self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_MOVELEFT) or self.Owner:KeyDown(IN_MOVERIGHT)) then
				move1 = 15
				move2 = 10
			elseif self.Owner:KeyDown(IN_SPEED) && self.Owner:IsOnGround() && (self.Owner:KeyDown(IN_FORWARD) or self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_MOVELEFT) or self.Owner:KeyDown(IN_MOVERIGHT)) then
				move1 = 20
				move2 = 1 +(self.WeaponWeight /75)
			else
				move1 = 0
				move2 = 100
			end
			ang = ang +Angle(math.cos(CurTime() *move1) /move2,math.cos(CurTime() *move1 /2) /move2,0)
		end
	end
	return pos,ang
end
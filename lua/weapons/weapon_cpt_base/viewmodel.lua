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
					net.Start("cpt_CModelshootpos")
					net.WriteVector(ShootPos)
					net.WriteEntity(self)
					net.SendToServer()
				end
			end
			net.Start("cpt_CModel")
			net.WriteEntity(self._CModel)
			net.SendToServer()
		end
	end
end

// Credit to the viewmodel lagger creator, I am not taking credit for this I just prefer his lerp better than mine :V
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
	vm.LastFacingAngle = vm.LastFacingAngle or ang:Forward()
	local forward = ang:Forward()
	if (FrameTime() != 0.0) then
		local difference = forward -vm.LastFacingAngle
		local speed = 5.0
		local totaldifference = difference:Length()
		if totaldifference > 1.5 then
			local scale = totaldifference /1.5
			speed = speed *scale
		end
		CalculateVector(vm.LastFacingAngle,speed *FrameTime(),difference,vm.LastFacingAngle)
		vm.LastFacingAngle:Normalize()
		CalculateVector(pos,5.0,difference *-1.0,pos)
	end
	local right,up
	right = oldang:Right()
	up = oldang:Up()
	local pitch = oldang[1]
	if (pitch > 180.0) then
		pitch = pitch -360.0
	elseif (pitch < -180.0) then
		pitch = pitch +360.0
	end

	CalculateVector(pos,-pitch *0.035,forward,pos)
	CalculateVector(pos,-pitch *0.03,right,pos)
	CalculateVector(pos,-pitch *0.02,up,pos)
end)

function SWEP:GetViewModelPosition(pos,ang) // Refer to the hook for movement
	local opos = pos *1
	local duck1 = 0
	local duck2 = 0
	local jump = 0
	local move1 = 0
	local move2 =  0
	if self.AdjustViewModel == true then
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
	// This is my lerp, the other one is not mine :P
	if self.UseLuaMovement == true then
		ang = ang +Angle(math.cos(CurTime() *self.LuaIdleScale) /1.5,math.cos(CurTime() *self.LuaIdleScale) /1.5,math.cos(CurTime() *self.LuaIdleScale) /2)
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
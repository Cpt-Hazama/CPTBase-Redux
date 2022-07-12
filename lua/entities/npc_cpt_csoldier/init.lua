if !CPTBase then return end
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.ModelTable = {"models/combine_Soldier.mdl"}
ENT.StartHealth = 100

ENT.Faction = "FACTION_COMBINE"
ENT.UseDefaultWeaponThink = false

ENT.GrenadeDistance = 1000
ENT.GrenadeMinDistance = 450
ENT.GrenadeChance = 65

ENT.Possessor_CanFaceTrace = true

ENT.BloodEffect = {"blood_impact_red"}

ENT.tbl_Sounds = {
	["Idle"] = {"npc/combine_soldier/vo/copy.wav","npc/combine_soldier/vo/copythat.wav","npc/combine_soldier/vo/executingfullresponse.wav","npc/combine_soldier/vo/grid.wav","npc/combine_soldier/vo/isholdingatcode.wav","npc/combine_soldier/vo/meters.wav","npc/combine_soldier/vo/nova.wav","npc/combine_soldier/vo/on1.wav","npc/combine_soldier/vo/overwatchtargetcontained.wav","npc/combine_soldier/vo/priority1objective.wav","npc/combine_soldier/vo/reportingclear.wav","npc/combine_soldier/vo/secure.wav","npc/combine_soldier/vo/stayalert.wav","npc/combine_soldier/vo/striker.wav","npc/combine_soldier/vo/weaponsoffsafeprepforcontact.wav","npc/combine_soldier/vo/wehavenontaggedviromes.wav","npc/combine_soldier/vo/weareinaninfestationzone.wav"},
	["Alert"] = {"npc/combine_soldier/vo/alert1.wav","npc/combine_soldier/vo/callhotpoint.wav","npc/combine_soldier/vo/contact.wav","npc/combine_soldier/vo/contactcomfirm.wav","npc/combine_soldier/vo/engaging.wav","npc/combine_soldier/vo/fixsightlinesmovein.wav","npc/combine_soldier/vo/flush.wav","npc/combine_soldier/vo/freeman3.wav","npc/combine_soldier/vo/goactiveintercept.wav","npc/combine_soldier/vo/inbound.wav","npc/combine_soldier/vo/movein.wav","npc/combine_soldier/vo/sector.wav"},
	["Pain"] = {"npc/combine_soldier/pain1.wav","npc/combine_soldier/pain2.wav","npc/combine_soldier/pain3.wav"},
	["Death"] = {"npc/combine_soldier/die1.wav","npc/combine_soldier/die2.wav","npc/combine_soldier/die3.wav"},
}

ENT.tbl_PrimaryWeapons = {"weapon_cpt_ar2","weapon_cpt_ar2","weapon_cpt_ar2","weapon_cpt_ar2","weapon_cpt_shotgun"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetInit()
	self:SetHullType(HULL_HUMAN)
	self.WeaponIsDrawn = false
	self.IsMovingAround = false
	self.ThrowEnemyPos = Vector(0,0,0)
	self.P_NextDrawT = CurTime() +0
	self.NextMoveAroundT = CurTime() +0
	self.NextGrenadeT = CurTime() +1
	self.TimeUntilPutAwayWeapon = 0
	self.ArmorDeduction = 0.65
	self.NumGrenades = math.random(2,5)
	local wep = self:SelectFromTable(self.tbl_PrimaryWeapons)
	self:GiveNPCWeapon(wep,false)
	if wep == "weapon_cpt_shotgun" then
		self:SetSkin(1)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Primary(possessor)
	if IsValid(self:GetActiveWeapon()) then
		if self.WeaponIsDrawn == true then
			if self.ReloadingWeapon == false then
				self:GetActiveWeapon():CanFire(true)
			else
				self:GetActiveWeapon():CanFire(false)
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Duck(possessor)
	if CurTime() > self.P_NextDrawT then
		if IsValid(self:GetActiveWeapon()) then
			if self.WeaponIsDrawn == false then
				self:GetActiveWeapon():EmitSound("physics/metal/weapon_impact_soft2.wav",60,100)
				self.WeaponIsDrawn = true
			elseif self.WeaponIsDrawn == true then
				self.WeaponIsDrawn = false
				self:GetActiveWeapon():EmitSound("physics/metal/weapon_impact_soft1.wav",60,100)
			end
		end
		self.P_NextDrawT = CurTime() +1
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Jump(possessor)
	self:ThrowGrenade()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Reload(possessor)
	if IsValid(self:GetActiveWeapon()) then
		self:GetActiveWeapon():NPC_Reload()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	if IsValid(self:GetEnemy()) then
		if self:GetEnemy():Visible(self) then
			self.ThrowEnemyPos = self:GetEnemy():GetPos()
		end
	end
	-- if self.IsPossessed then
	-- 	self:SetAngles(Angle(0,(self:Possess_AimTarget() -self:GetPos()):Angle().y,0))
	-- end
	if IsValid(self:GetActiveWeapon()) then
		self:GetActiveWeapon():OnNPCThink()
		if self.IsMovingAround then
			if !self.IsPossessed && IsValid(self:GetEnemy()) then
				self:SetAngles(Angle(0,(self:GetEnemy():GetPos() -self:GetPos()):Angle().y,0))
			end
		end
		if !self.IsPossessed && IsValid(self:GetEnemy()) && self.WeaponIsDrawn then
			self.TimeUntilPutAwayWeapon = CurTime() +10
		end
	end
	if !self.WeaponIsDrawn then
		if IsValid(self:GetActiveWeapon()) then
			self:GetActiveWeapon():SetNoDraw(true)
			self:GetActiveWeapon():DrawShadow(false)
		end
		-- self:SetIdleAnimation("Idle_Unarmed")
		-- self.tbl_Animations["Walk"] = {"WalkUnArmed_all"}
		-- self.tbl_Animations["Run"] = {"WalkUnArmed_all"}
	else
		if IsValid(self:GetActiveWeapon()) then
			if !self.IsPossessed && !IsValid(self:GetEnemy()) && CurTime() > self.TimeUntilPutAwayWeapon then
				self.WeaponIsDrawn = false
				self:GetActiveWeapon():SetNoDraw(false)
				self:GetActiveWeapon():DrawShadow(true)
				self:GetActiveWeapon():EmitSound("physics/metal/weapon_impact_soft1.wav",60,100)
				self:StopCompletely()
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDamage_Pain(dmg,dmginfo,hitbox)
	self:MoveAway(false)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MoveAway(force)
	if self.IsPossessed then return end
	local trypos
	local trynum
	if self.IsMovingAround == false && CurTime() > self.NextMoveAroundT then
		if force == true then
			trynum = 1
		else
			trynum = math.random(1,3)
			if self.CurrentSchedule != nil && self.CurrentSchedule.Name == "getpathandchasetask" then return end
		end
		if trynum == 1 then trypos = self:GetForward() *-400 elseif trynum == 2 then trypos = self:GetRight() *-400 elseif trynum == 3 then trypos = self:GetRight() *400 end
		if !self:DoCustomTrace(self:GetPos() +self:OBBCenter(),self:GetPos() +self:OBBCenter() +trypos,{self},true).Hit then
			self:SetLastPosition(self:GetPos() +trypos)
			self:TASKFUNC_RUNLASTPOSITION()
			self.IsMovingAround = true
			local time = self:GetPathTimeToGoal()
			self.NextMoveAroundT = CurTime() +time
			timer.Simple(time,function()
				if self:IsValid() then
					self.IsMovingAround = false
				end
			end)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ChangeDamageOnHit(dmg,hitbox,dmginfo)
	local output = dmg:GetDamage()
	if (dmg:IsBulletDamage()) then
		self:EmitSound("physics/metal/metal_solid_impact_bullet" .. math.random(1,4) .. ".wav",70)
		local spark = EffectData()
		spark:SetOrigin(dmg:GetDamagePosition())
		spark:SetScale(0.2)
		util.Effect("ElectricSpark",spark)
		output = output *self.ArmorDeduction
	else
		self:EmitSound("physics/metal/metal_sheet_impact_bullet" .. math.random(1,2) .. ".wav",70)
	end
	return output
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoWeaponTrace()
	if !IsValid(self:GetActiveWeapon()) then return end
	local wep = self:GetActiveWeapon()
	local tracedata = {}
	tracedata.start = wep:GetAttachment(1).Pos
	tracedata.endpos = self:GetEnemy():GetPos() +self:GetEnemy():OBBCenter()
	tracedata.filter = {self,wep}
	local tr = util.TraceLine(tracedata)
	return tr.Hit
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetUpRangeAttackTarget()
	if self.IsPossessed then
		return (self:Possess_AimTarget() -self:LocalToWorld(Vector(0,0,0)))
	else
		if IsValid(self:GetEnemy()) then
			return (self.ThrowEnemyPos -self:LocalToWorld(Vector(0,0,0)))
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ThrowGrenade()
	if self.NumGrenades <= 0 then return end
	if CurTime() > self.NextGrenadeT then
		if self:CanPerformProcess() == false then return end
		self:StopCompletely()
		self:PlayActivity("grenThrow",2)
		self.IsRangeAttacking = true
		timer.Simple(0.6,function()
			if IsValid(self) then
				local grenent = ents.Create("obj_cpt_grenade")
				grenent:SetPos(self:GetAttachment(self:LookupAttachment("anim_attachment_LH")).Pos)
				grenent:SetAngles(self:GetAttachment(self:LookupAttachment("anim_attachment_LH")).Ang)
				grenent:SetParent(self)
				grenent:Fire("SetParentAttachment","anim_attachment_LH")
				grenent:SetTimer(4)
				grenent.HasTickLight = false
				grenent.TickSound = "weapons/grenade/tick1.wav"
				grenent:Spawn()
				grenent:SetModel("models/Items/grenadeAmmo.mdl")
				grenent:Activate()
				local phys = grenent:GetPhysicsObject()
				if IsValid(phys) then
					grenent:SetParent(NULL)
					phys:SetVelocity(self:SetUpRangeAttackTarget() *math.Rand(1,2) +self:GetUp() *200)
				end
				self.NumGrenades = self.NumGrenades -1
			end
		end)
		self:AttackFinish()
		local dif = math.Round(GetConVarNumber("cpt_aidifficulty"))
		local time
		if dif == 1 then
			time = math.random(12,20)
		elseif dif == 2 then
			time = math.random(5,8)
		elseif dif == 3 then
			time = math.random(3,5)
		elseif dif == 4 then
			time = math.random(1,2)
		end
		self.NextGrenadeT = CurTime() +time
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleSchedules(enemy,nearest,nearest,disp)
	if self.IsPossessed == true then return end
	if(disp == D_HT) then
		if nearest <= self.GrenadeDistance && nearest > self.GrenadeMinDistance && math.random(1,self.GrenadeChance) == 1 then
			self:ThrowGrenade()
		end
		if IsValid(self:GetActiveWeapon()) then
			local wep = self:GetActiveWeapon()
			if self.WeaponIsDrawn == false then
				wep:EmitSound("physics/metal/weapon_impact_soft2.wav",60,100)
				self.WeaponIsDrawn = true
				-- if !self:IsMoving() then
					-- self:PlayActivity(self:GetIdleAnimation())
				-- end
			end
			if !self.WeaponIsDrawn then return end
			if nearest > wep.NPC_EnemyFarDistance then
				if self:CanPerformProcess() then
					self:ChaseEnemy()
				end
			end
			if nearest <= wep.NPC_FireDistance then
				if self.ReloadingWeapon == false && enemy:Visible(self) && self:DoWeaponTrace() && self:FindInCone(enemy,40) then
					wep:CanFire(true)
					if wep.NPC_MoveRandomlyChance == nil then
						wep.NPC_MoveRandomlyChance = 30
					end
					if math.random(1,wep.NPC_MoveRandomlyChance) == 1 then
						self:MoveAway(false)
					end
				elseif !self:FindInCone(enemy,40) && enemy:Visible(self) && !self.IsMovingAround then
					self:FaceEnemy()
					if self:IsMoving() then self:StopCompletely() end
				elseif !enemy:Visible(self) then
					wep:CanFire(false)
					self:ChaseEnemy()
				end
				if nearest <= wep.NPC_FireDistanceStop && !self.IsMovingAround then
					self:SetAngles(Angle(0,(enemy:GetPos() -self:GetPos()):Angle().y,0))
					-- if self:IsMoving() then self:StopCompletely() end
					if nearest <= wep.NPC_FireDistanceMoveAway then
						self:MoveAway(false)
					end
				end
			elseif enemy:Visible(self) && !self.IsMovingAround then
				wep:CanFire(false)
				self:ChaseEnemy()
			else
				wep:CanFire(false)
			end
		end
	elseif(disp == D_FR) then
		self:Hide()
	end
end
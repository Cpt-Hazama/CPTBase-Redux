if !CPTBase then return end
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.ModelTable = {"models/cpthazama/hl2/cremator.mdl"}
ENT.StartHealth = 250
ENT.CollisionBounds = Vector(18,18,90)

ENT.Faction = "FACTION_COMBINE"

ENT.RangeAttackDistance = 300
ENT.RangeAttackDamageDistance = 380

ENT.BloodEffect = {"blood_impact_red"}
ENT.HasFlinchAnimation = true
ENT.FlinchChance = 28

ENT.tbl_Animations = {
	["Walk"] = {ACT_WALK},
	["Run"] = {ACT_RUN},
	["Pain"] = {ACT_BIG_FLINCH},
	["RangeAttack"] = {ACT_RANGE_ATTACK1},
	["RangeAttackStop"] = {ACT_RANGE_ATTACK1_LOW},
}

ENT.tbl_Sounds = {
	["FootStep"] = {"cptbase/cremator/foot1.wav","cptbase/cremator/foot2.wav","cptbase/cremator/foot3.wav"},
	["Alert"] = {"cptbase/cremator/alert_object.wav","cptbase/cremator/alert_player.wav"},
	["Ignite"] = {"cptbase/cremator/plasma_ignite.wav"},
}

ENT.tbl_Capabilities = {CAP_OPEN_DOORS,CAP_USE}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetInit()
	self:SetHullType(HULL_HUMAN)
	self:SetMovementType(MOVETYPE_STEP)
	self.IsRangeAttacking = false
	self.IsLoopRangeAttacking = false
	self.HasFlameParticle = false
	self.IsPlayingFireIdle = false
	self.NextDamageT = 0
	self.NextIdleLoopT = 0
	self.NextFireLoopT = 0
	self.IdleLoop = CreateSound(self,"cptbase/cremator/amb_loop.wav")
	self.IdleLoop:SetSoundLevel(60)
	self.FireLoop = CreateSound(self,"cptbase/cremator/plasma_shoot.wav")
	self.FireLoop:SetSoundLevel(68)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_OnPossessed(possessor)
	possessor:ChatPrint("Possessor Controls:")
	possessor:ChatPrint("LMB - Turn on Flame Thrower (Use again to stop)")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleEvents(...)
	local event = select(1,...)
	local arg1 = select(2,...)
	if(event == "rattack") then
		if arg1 == "loop" then
			self.IsLoopRangeAttacking = true
			self:PlaySound("Ignite",75,90,100,true)
		end
		return true
	end
	if(event == "emit") then
		if arg1 == "step" then
			self:PlaySound("FootStep",75,90,100,true)
		end
		return true
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Primary(possessor)
	if !self.IsLoopRangeAttacking then
		self:DoRangeAttack()
	else
		if !self.IsRangeAttacking && self.IsLoopRangeAttacking then
			self.IsLoopRangeAttacking = false
			self:EmitSound("cptbase/cremator/plasma_stop.wav",62,100)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Secondary(possessor) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	if !IsValid(self:GetEnemy()) && !self.IsPossessed then
		self.IsLoopRangeAttacking = false
	end
	if self.IsPossessed then
		self:SetAngles(Angle(0,(self:Possess_AimTarget() -self:GetPos()):Angle().y,0))
	end
	if self:WaterLevel() >= 2 then
		self.IsLoopRangeAttacking = false
	end
	-- if self:Health() <= 50 then
		-- if self == self then
			-- self.tbl_Animations["Walk"] = {ACT_WALK_HURT}
			-- self.tbl_Animations["Run"] = {ACT_WALK_HURT}
		-- end
	-- end
	if CurTime() > self.NextIdleLoopT then
		self.IdleLoop:Stop()
		self.IdleLoop:Play()
		self.NextIdleLoopT = CurTime() +SoundDuration("cptbase/cremator/amb_loop.wav")
	end
	if CurTime() > self.NextFireLoopT && self.HasFlameParticle then
		self.FireLoop:Stop()
		self.FireLoop:Play()
		self.NextFireLoopT = CurTime() +SoundDuration("cptbase/cremator/plasma_shoot.wav")
	end
	if self.IsLoopRangeAttacking then
		self:SetIdleAnimation(ACT_RANGE_ATTACK2)
		if !self.HasFlameParticle then
			self.HasFlameParticle = true
			ParticleEffectAttach("cpt_flamethrower",PATTACH_POINT_FOLLOW,self,1)
		end
		if CurTime() > self.NextDamageT then
			for _,ent in pairs(ents.FindInSphere(self:GetPos() +(self:GetForward() *self:OBBMaxs().y),self.RangeAttackDamageDistance)) do
				if IsValid(ent) && (ent:IsNPC() || ent:IsPlayer() && GetConVarNumber("ai_ignoreplayers") == 0) && ent != self && self:Disposition(ent) != D_LI && self:Visible(ent) then
					local yaw = self:FindAngleOfPosition(ent:GetPos(),self:GetAngles()).y
					if (yaw <= 70 && yaw >= 0) || (yaw <= 360 && yaw >= 290) then
					-- if self:FindInCone(ent,10) then
						local dif = GetConVarNumber("cpt_aidifficulty")
						local dmg
						local time
						if dif == 1 then
							dmg = 20 *0.5
							time = 3 *0.5
						elseif dif == 2 then
							dmg = 20
							time = 3
						elseif dif == 3 then
							dmg = 20 *2
							time = 3 *2
						elseif dif == 4 then
							dmg = 20 *4
							time = 3 *4
						end
						ent:Ignite(time)
						local dmginfo = DamageInfo()
						dmginfo:SetDamageType(DMG_BURN)
						dmginfo:SetDamage(dmg)
						dmginfo:SetAttacker(self)
						dmginfo:SetInflictor(self)
						ent:TakeDamageInfo(dmginfo)
					end
				end
			end
			self.NextDamageT = CurTime() +0.5
		end
	else
		self:SetIdleAnimation(ACT_IDLE)
		if self.HasFlameParticle then
			if !self.IsPossessed then
				self:StopCompletely()
			end
			self.HasFlameParticle = false
			self.FireLoop:Stop()
			self:StopParticles()
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:WhenRemoved()
	self.IdleLoop:Stop()
	self.FireLoop:Stop()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoRangeAttack()
	if self:CanPerformProcess() == false then return end
	if self.IsLoopRangeAttacking == true then return end
	if (!self.IsPossessed && IsValid(self:GetEnemy()) && !self:GetEnemy():Visible(self)) then return end
	self:StopCompletely()
	self:PlayAnimation("RangeAttack")
	self.IsRangeAttacking = true
	self:AttackFinish()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleSchedules(enemy,dist,nearest,disp)
	if self.IsPossessed then return end
	if(disp == D_HT) then
		if nearest <= self.RangeAttackDistance && !self.IsLoopRangeAttacking && self:FindInCone(enemy,self.MeleeAngle) then
			self:DoRangeAttack()
		end
		if nearest > self.RangeAttackDistance && self.IsLoopRangeAttacking then
			self.IsRangeAttacking = false
			self.IsLoopRangeAttacking = false
		end
		if self:CanPerformProcess() && nearest > 250 then
			self.CanChaseEnemy = true
			self:ChaseEnemy()
		elseif self:CanPerformProcess() && nearest <= 250 then
			self:SetAngles(Angle(0,(enemy:GetPos() -self:GetPos()):Angle().y,0))
			self.CanChaseEnemy = false
			if self:IsMoving() then
				self:StopCompletely()
			end
		end
	end
end
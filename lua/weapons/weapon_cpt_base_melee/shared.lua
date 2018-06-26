AddCSLuaFile("shared.lua")

SWEP.HoldType = "melee"
SWEP.Base = "weapon_cpt_base"

SWEP.MeleeCone = 25
SWEP.MeleeDamageRadius = 12
SWEP.MeleeDamageDistance = 12
SWEP.MeleeDamage = 10
SWEP.MeleeHitTime = 1
SWEP.MeleeDelay = 0.5
SWEP.MeleeHit = ACT_VM_HITCENTER
SWEP.MeleeMiss = ACT_VM_MISSCENTER

SWEP.CurrentTraceData = {}

function SWEP:OnHitEntity(ent) end

function SWEP:OnHitWorld() end

function SWEP:OnMissEntity() end

function SWEP:PrimaryAttack()
	if self.IsFiring == true then return end
	local UseAct = self.MeleeMiss
	local hitent = false
	local hit,tr = self:DoMeleeDamage(self.MeleeDamageDistance,self.MeleeDamage)
	// 0 = miss, 1 = hit entity, 2 = hit world
	timer.Simple(self.MeleeHitTime /1.25,function()
		if self:IsValid() && self.Owner:GetActiveWeapon():GetClass() == self:GetClass() then
			if self.Owner:IsPlayer() then
				self.Owner:ViewPunch(Angle(-self.Primary.Force,math.random(-self.Primary.Force /2,self.Primary.Force /2),0))
			end
		end
	end)
	timer.Simple(self.MeleeHitTime,function()
		if self:IsValid() && self.Owner:GetActiveWeapon():GetClass() == self:GetClass() then
			-- print(hit)
			if hit == 0 then
				self:PlayWeaponSound("Miss",80)
				UseAct = self.MeleeMiss
			elseif hit == 1 then
				for _,v in pairs(ents.FindInSphere(self.Owner:GetShootPos() +self.Owner:GetAimVector() *self.MeleeDamageDistance,self.MeleeDamageRadius)) do
					if v:IsValid() && v != self.Owner && v:Visible(self.Owner) then
						hitent = true
						self:CreateMeleeDamage(self,self.Owner,self.Owner:GetShootPos() +self.Owner:GetAimVector() *self.MeleeDamageDistance,self.MeleeDamageRadius,self.MeleeDamage,self.Owner,DMG_SLASH)
					end
				end
				if hitent == true then
					self:PlayWeaponSound("HitEntity",85)
					UseAct = self.MeleeHit
					hitent = false
				else
					self:PlayWeaponSound("Miss",80)
					UseAct = self.MeleeMiss
					self:OnMissEntity()
				end
			elseif hit == 2 then
				self:PlayWeaponSound("HitWorld",85)
				UseAct = self.MeleeHit
				self:OnHitWorld()
			end
			-- UseAct = self.MeleeHit
		end
		self.Weapon:SetNextSecondaryFire(CurTime() +self.MeleeDelay)
		self.Weapon:SetNextPrimaryFire(CurTime() +self.MeleeDelay)
		timer.Simple(self.MeleeDelay,function() if self:IsValid() then self.IsFiring = false self.CanUseIdle = true end end)
		timer.Simple(self.MeleeDelay +0.03,function() if self:IsValid() then self:DoIdleAnimation() end end)
	end)
	self.IsFiring = true
	self.CanUseIdle = false
	-- self.Weapon:SendWeaponAnim(UseAct)
	self:PlayMeleeAnimation(UseAct)
	if self.Owner:IsPlayer() then
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		-- self.Owner:ViewPunch(Angle(-self.Primary.Force,math.random(-self.Primary.Force /2,self.Primary.Force /2),0))
	end
end

function SWEP:PlayMeleeAnimation(anim)
	-- print(anim)
	if type(anim) == "table" then
		anim = self:SelectFromTable(anim)
	end
	if type(anim) == "number" then
		self.Weapon:SendWeaponAnim(anim)
	elseif type(anim) == "string" then
		self.Weapon:ResetSequence(self.Weapon:LookupSequence(anim))
		self.Weapon:ResetSequenceInfo()
		if speed == nil then speed = 1 end
		self.Weapon:SetPlaybackRate(speed)
		if loop == nil then loop = 0 end
		self.Weapon:SetCycle(loop)
	end
end

function SWEP:CheckBeforeDamage(ent)
	return true
end

function SWEP:CreateMeleeDamage(inflictor,attacker,pos,radius,dmg,filter,dmgtype)
	-- timer.Simple(self.MeleeHitTime,function()
		-- if self:IsValid() && self.Owner:GetActiveWeapon():GetClass() == self:GetClass() then
			local foundents = {}
			local didhit = false
			for _, v in pairs(ents.FindInSphere(pos,radius)) do
				if (v != filter && !util.TraceLine({start = pos, endpos = v:GetPos() +v:OBBCenter(), mask = MASK_NPCWORLDSTATIC}).HitEntity && v:Health() != nil) then
					if (v:IsNPC() || v:IsPlayer()) && self:CheckBeforeDamage(v) then
						local dmgpos = v:NearestPoint(pos)
						foundents[v] = pos:Distance(dmgpos)
						local dmginfo = DamageInfo()
						dmginfo:SetDamage(dmg)
						dmginfo:SetAttacker(attacker)
						dmginfo:SetInflictor(inflictor)
						dmginfo:SetDamageType(dmgtype)
						dmginfo:SetDamagePosition(dmgpos)
						v:TakeDamageInfo(dmginfo)
						didhit = true
						if !table.HasValue(foundents,v) then
							table.insert(foundents,v)
						end
					end
				end
			end
			if didhit == true then
				self:OnHitEntity(foundents)
			end
			-- return foundents
		-- end
	-- end)
end

function SWEP:DoMeleeDamage(dist,dmg)
	local hit = 0
	local posStart = self.Owner:GetShootPos()
	local posEnd = posStart +self.Owner:GetAimVector() *dist
	local tracedata = {}
	tracedata.start = posStart
	tracedata.endpos = posEnd
	tracedata.filter = self.Owner
	local tr = util.TraceLine(tracedata)
	table.Empty(self.CurrentTraceData)
	self.CurrentTraceData = tracedata
	if tr.HitWorld == false then
		-- if tr.Entity:IsValid() && tr.Entity != self && tr.Entity != self.Owner && (tr.Entity:IsNPC() or tr.Entity:IsPlayer() or !tr.Entity:IsWeapon()) && tr.Entity:Visible(self.Owner) then
			hit = 1
			-- self:CreateMeleeDamage(self,self.Owner,tr.HitPos +tr.Normal *6,self.MeleeDamageRadius,self.MeleeDamage,self.Owner,DMG_SLASH)
		-- for _,v in pairs(ents.FindInSphere(tracedata.endpos,self.MeleeDamageRadius)) do
			-- if v:IsValid() && v != self && v != self.Owner && (v:IsNPC() or v:IsPlayer() or !v:IsWeapon()) && v:Visible(self.Owner) then
				-- hit = 1
				-- self:CreateMeleeDamage(self,self.Owner,tr.HitPos +tr.Normal *6,self.MeleeDamageRadius,self.MeleeDamage,self.Owner,DMG_SLASH)
			-- end
		-- end
		-- end
	else
		hit = 2
	end
	return hit
end
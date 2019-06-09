AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = "models/cpthazama/scpsl/weapons/grenade.mdl"
ENT.PhysicsType = SOLID_VPHYSICS
ENT.SolidType = SOLID_VPHYSICS
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE
ENT.MoveCollide = COLLISION_GROUP_PROJECTILE
ENT.MoveType = MOVETYPE_VPHYSICS
ENT.AlreadyIgnited = false
ENT.HasTickLight = true
ENT.TickSound = "buttons/button16.wav"

function ENT:SetTimer(seconds)
	self.GrenadeTimer = seconds
end

function ENT:Physics()
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(0.8)
		phys:SetBuoyancyRatio(0)
		phys:EnableGravity(true)
	end
	self:GrenadeInitialize()
end

function ENT:GrenadeInitialize()
	if self.GrenadeTimer == nil then
		self.GrenadeTimer = 5
	end
	self.CursplodeT = CurTime() +self.GrenadeTimer
	timer.Simple(self.GrenadeTimer,function()
		if IsValid(self) then
			self:Explode()
		end
	end)
	local tick = self.GrenadeTimer
	for i = 0, self.GrenadeTimer do
		timer.Simple(i,function()
			if IsValid(self) then
				self:EmitSound(self.TickSound,68,85)
				if self.HasTickLight then
					local eyeglow1 = ents.Create("env_sprite")
					eyeglow1:SetKeyValue("model","sprites/glow1.vmt")
					eyeglow1:SetKeyValue("scale","0.05")
					eyeglow1:SetKeyValue("rendermode","5")
					eyeglow1:SetKeyValue("rendercolor","255 0 0")
					eyeglow1:SetKeyValue("spawnflags","1")
					eyeglow1:SetPos(self:GetPos())
					eyeglow1:SetParent(self)
					eyeglow1:Spawn()
					eyeglow1:Activate()
					self:DeleteOnRemove(eyeglow1)
				end
			end
		end)
	end
	timer.Simple(self.GrenadeTimer -0.5,function()
		if IsValid(self) then
			if math.random(1,200) == 1 then
				self:EmitSound("vo/ravenholm/madlaugh04.wav",90,150)
				if self.HasTickLight then
					local eyeglow1 = ents.Create("env_sprite")
					eyeglow1:SetKeyValue("model","sprites/glow1.vmt")
					eyeglow1:SetKeyValue("scale",tostring(0.05 *self.GrenadeTimer))
					eyeglow1:SetKeyValue("rendermode","5")
					eyeglow1:SetKeyValue("rendercolor","255 255 0")
					eyeglow1:SetKeyValue("spawnflags","1")
					eyeglow1:SetPos(self:GetPos())
					eyeglow1:SetParent(self)
					eyeglow1:Spawn()
					eyeglow1:Activate()
					self:DeleteOnRemove(eyeglow1)
				end
			else
				self:EmitSound(self.TickSound,90,150)
				if self.HasTickLight then
					local eyeglow1 = ents.Create("env_sprite")
					eyeglow1:SetKeyValue("model","sprites/glow1.vmt")
					eyeglow1:SetKeyValue("scale",tostring(0.05 *self.GrenadeTimer))
					eyeglow1:SetKeyValue("rendermode","5")
					eyeglow1:SetKeyValue("rendercolor","0 255 0")
					eyeglow1:SetKeyValue("spawnflags","1")
					eyeglow1:SetPos(self:GetPos())
					eyeglow1:SetParent(self)
					eyeglow1:Spawn()
					eyeglow1:Activate()
					self:DeleteOnRemove(eyeglow1)
				end
			end
		end
	end)
end

function ENT:Explode()
	if self.IsDead == false then
		self.IsDead = true
		-- util.CreateCustomExplosion(self:GetPos(),400,350,self,"hefg_explosion","cptbase/explode.wav",false,90)
		util.CreateCustomExplosion(self:GetPos(),400,350,self,"hefg_explosion","cptbase/explode_heavy.mp3",false,140)
		local epos = self:GetPos()
		timer.Simple(0.6,function()
			sound.Play("cptbase/explode_shockwave.wav",epos,120,100 *GetConVarNumber("host_timescale"))
		end)
		if self.AlreadyIgnited == false then
			self.AlreadyIgnited = true
			for _,v in ipairs(ents.FindInSphere(self:GetPos(),350)) do
				if IsValid(v) && v:Visible(self) &&  v:Health() != nil && !v:IsOnFire() then
					v:Ignite(8,10)
				end
				if IsValid(v) && (v:GetClass() == "prop_door_rotating" || v:GetClass() == "prop_door" || v:GetClass() == "func_door_rotating" || v:GetClass() == "func_door") && v:Visible(self) then
					local door = ents.Create("prop_physics")
					door:SetModel(v:GetModel())
					door:SetPos(v:GetPos())
					door:SetAngles(v:GetAngles())
					door:Spawn()
					door:Activate()
					if v:GetSkin() != nil then
						door:SetSkin(v:GetSkin())
					end
					door:SetMaterial(v:GetMaterial())
					v:Remove()
					timer.Simple(3,function()
						if IsValid(door) then
							door:SetCollisionGroup(1)
						end
					end)
					local phys = door:GetPhysicsObject()
					if phys:IsValid() then
						phys:SetVelocity(((door:GetPos() -self:GetPos()) *500 +(door:GetPos() +door:GetForward() *400 -self:GetPos()) +(door:GetPos() +door:GetUp() *200 -self:GetPos()) *140))
					end
				end
			end
		end
		self:Remove()
	end
end

function ENT:OnTouch(data,phys)
	if phys:GetVelocity():Length() >= 500 then
		phys:SetVelocity(phys:GetVelocity() *0.9)
	end
	if phys:GetVelocity():Length() > 100 then
		self:EmitSound("physics/metal/metal_grenade_impact_hard" .. math.random(1,3) .. ".wav",60,100)
	end
end
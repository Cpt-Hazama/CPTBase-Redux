if !CPTBase then return end
function EFFECT:Init(data)
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	self.Position = self:GetTracerShootPos(data:GetOrigin(),self.WeaponEnt,self.Attachment)
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	self.Up = self.Angle:Up()
	if !self.WeaponEnt:IsValid() or !self.WeaponEnt:GetOwner():IsValid() then return end
	local AddVel = self.WeaponEnt:GetOwner():GetVelocity()
	local emitter = ParticleEmitter(self.Position)
	local particle = emitter:Add("cptbase/muzzles/vortex"..math.random(1,2),self.Position)
	particle:SetVelocity(self.Forward *AddVel)
	particle:SetDieTime(0.25)
	particle:SetStartAlpha(160)
	particle:SetEndAlpha(0)
	particle:SetStartSize(8)
	particle:SetEndSize(math.random(12,20))
	particle:SetRoll(math.Rand(90,480))
	particle:SetRollDelta(math.Rand(-1,1))
	particle:SetAirResistance(160)
	if math.random(1,math.random(3,5)) == 1 then
		for i = 1,2 do
			local particle = emitter:Add("cptbase/muzzles/pulse_flutter",self.Position)
			particle:SetVelocity(math.Rand(60,80) *self.Forward +VectorRand() *30)
			particle:SetDieTime(math.Rand(0.1,0.3))
			particle:SetStartAlpha(255)
			particle:SetStartSize(math.random(6,8))
			particle:SetEndSize(math.random(9,11))
			particle:SetRoll(0)
			particle:SetGravity(Vector(0,0,0))
			particle:SetCollide(true)
			particle:SetBounce(0.8)
			particle:SetAirResistance(120)
			particle:SetStartLength(0)
			particle:SetEndLength(0.2)
			particle:SetVelocityScale(true)
			particle:SetCollide(true)
		end
	end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render() end
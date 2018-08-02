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
	local particle = emitter:Add("sprites/heatwave",self.Position -self.Forward *4)
	particle:SetVelocity(80 *self.Forward +20 *VectorRand() +1.05 *AddVel)
	particle:SetDieTime(math.Rand(0.2,0.25))
	particle:SetStartSize(math.random(2,4))
	particle:SetEndSize(math.random(3,7))
	particle:SetRoll(math.Rand(180,480))
	particle:SetRollDelta(math.Rand(-1,1))
	particle:SetGravity(Vector(0,0,100))
	particle:SetAirResistance(160)
	for i=1,2 do 
		local particle = emitter:Add("effects/muzzleflash" .. math.random(1,4),self.Position +2 *self.Forward)
		particle:SetVelocity(self.Forward *AddVel)
		particle:SetDieTime(0.15)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(4)
		particle:SetEndSize(math.random(6,10))
		particle:SetRoll(math.Rand(90,480))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(255,100,0)
		particle:SetAirResistance(160)
	end
	for i = 1,4 do
		local particle = emitter:Add("particle/particle_smokegrenade",self.Position)
		particle:SetVelocity(3 *i *self.Forward +1.1 *AddVel)
		particle:SetDieTime(math.Rand(0.36,0.78))
		particle:SetStartAlpha(math.Rand(20,30))
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.random(3,4))
		particle:SetEndSize(math.Rand(8,15))
		particle:SetRoll(math.Rand(180,480))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(208,208,208)
		particle:SetLighting(true)
		particle:SetAirResistance(150)
    end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render() end
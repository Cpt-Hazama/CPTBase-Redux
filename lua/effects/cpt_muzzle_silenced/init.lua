if !CPTBase then return end
function EFFECT:Init(data)
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	self.Position = self:GetTracerShootPos(data:GetOrigin(),self.WeaponEnt,self.Attachment)
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	self.Up = self.Angle:Up()
	local isWep = IsValid(self.WeaponEnt) && self.WeaponEnt:IsWeapon()
	if isWep then
		self.WeaponEnt = self.WeaponEnt:GetOwner()
	end
	if !IsValid(self.WeaponEnt) then return end
	local AddVel = self.WeaponEnt:GetVelocity()
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
	for i = 1,4 do
		local particle = emitter:Add("particle/particle_smokegrenade",self.Position)
		particle:SetVelocity(30 *i *self.Forward +1.1 *AddVel)
		particle:SetDieTime(math.Rand(0.36,0.78))
		particle:SetStartAlpha(math.Rand(60,100))
		particle:SetEndAlpha(math.Rand(10,20))
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
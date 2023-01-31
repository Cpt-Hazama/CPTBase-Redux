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
	for i=1,2 do
		local particle = emitter:Add("cpthazama/muzzle/tracer1",self.Position +2 *self.Forward)
		particle:SetVelocity(self.Forward *AddVel)
		particle:SetDieTime(0.15)
		particle:SetStartAlpha(170)
		particle:SetEndAlpha(0)
		particle:SetStartSize(4)
		particle:SetEndSize(math.random(6,10))
		particle:SetRoll(math.Rand(90,480))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(255,195,0)
		particle:SetAirResistance(160)
	end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render() end
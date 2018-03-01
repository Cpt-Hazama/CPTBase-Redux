include('shared.lua')

function ENT:Draw() self:DrawModel() end

// Enable these when you need to use an effect as an idle particle
-- function ENT:Initialize()
	-- self.IdleEffect = ParticleEmitter(self:GetPos())
-- end
 
-- function ENT:OnRemove()
	-- self.IdleEffect:Finish()
-- end
 
-- function ENT:Think()
	-- local texture = "toxicsplat_gon"
	-- local particle = self.IdleEffect:Add(texture,self:GetPos())
 	-- if particle then
 		-- particle:SetVelocity(VectorRand() *math.Rand(0,200))
 		-- particle:SetLifeTime(0)
 		-- particle:SetDieTime(math.Rand(0.3,0.5))
 		-- particle:SetStartAlpha(math.Rand(100,255))
 		-- particle:SetEndAlpha(0)
 		-- particle:SetStartSize(10)
 		-- particle:SetEndSize(5)
 		-- particle:SetRoll(math.Rand(0,360))
 		-- particle:SetAirResistance(400)
 		-- particle:SetGravity(Vector(0,0,-200))
 	-- end
-- end
if !CPTBase then return end
---------------------------------------------------------------------------------------------------------------------------------------------
EFFECT.Texture = Material("cptbase/muzzles/spark")
EFFECT.TextureColor = {r=255,g=131,b=0,a=255}
EFFECT.TextureSize = {x=5,y=5}
EFFECT.HasSecondTexture = false
EFFECT.Texture2 = Material("cptbase/muzzles/spark")
EFFECT.Texture2Color = {r=255,g=131,b=0,a=255}
EFFECT.Texture2Size = {x=2,y=2}

EFFECT.Speed = 7000
EFFECT.Length = 0.04

EFFECT.UseImpactSound = false
EFFECT.ImpactSound = Sound("common/null.wav")
EFFECT.ImpactVolume = 60
EFFECT.UseWhizSound = true
EFFECT.WhizSound = Sound("cptbase/bullet_whoosh.wav")
EFFECT.WhizVolume = 60
EFFECT.WhizDistance = 200
EFFECT.NextWhizT = 0
---------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:GetStartingPosition(data)
	local start = data:GetStart()
	local entity = data:GetEntity()
	local owner = entity:GetOwner()
	if !IsValid(entity) then
		return start
	end
	if(entity:IsWeapon()) then
		if IsValid(owner) && owner:IsPlayer() then
			local viewModel = owner:GetViewModel()
			if IsValid(viewModel) && !LocalPlayer():ShouldDrawLocalPlayer() then
				entity = viewModel
			end
		end
	end
	local att = entity:GetAttachment(data:GetAttachment())
	if att then
		start = att.Pos
	end
	return start
end
---------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Init(data)
	self.StartPos = self:GetStartingPosition(data)
	self.EndPos = data:GetOrigin()
	self.Direction = self.EndPos -self.StartPos
	self.Normal = (self.Direction):GetNormal()
	self:SetRenderBoundsWS(self.StartPos,self.EndPos)
	self.LifeTime = math.min(1,self.StartPos:Distance(self.EndPos) /10000)
	self.DieTime = CurTime() + self.LifeTime
end
---------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:OnHitEndPoint(pos) end
---------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Think()
	if CurTime() > self.DieTime then
		if self.UseImpactSound then
			sound.Play(self.ImpactSound,self:GetPos(),self.ImpactVolume,100 *GetConVarNumber("host_timescale"))
		end
		self:OnHitEndPoint(self.EndPos)
		return false
	end
	if self.UseWhizSound then
		local doplaysound = false
		for _,v in ipairs(ents.FindInSphere(self:GetPos(),self.WhizDistance)) do
			if v:IsValid() && v:IsPlayer() then
				doplaysound = true
			end
		end
		if doplaysound == true && CurTime() > self.NextWhizT then
			sound.Play(self.WhizSound,self:GetPos(),self.WhizVolume,100 *GetConVarNumber("host_timescale"))
			self.NextWhizT = CurTime() +SoundDuration(self.WhizSound)
		end
	end
	return true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Render()
	local timeDif = (self.DieTime -CurTime()) /self.LifeTime
	timeDif = math.Clamp(timeDif,0,1) ^0.5
	local sine = math.sin(timeDif *math.pi)
	local startPos = self.EndPos -self.Direction *(timeDif -sine *self.Length)
	local endPos = self.EndPos -self.Direction *(timeDif +sine *self.Length)
	local size = self.TextureSize.x +sine *self.TextureSize.y
	local color = Color(self.TextureColor.r,self.TextureColor.g,self.TextureColor.b,self.TextureColor.a)
	render.SetMaterial(self.Texture)
	render.DrawBeam(startPos,endPos,size,0,1,color)
	if self.HasSecondTexture then
		size = self.Texture2Size.x +sine *self.Texture2Size.y
		color = Color(self.Texture2Color.r,self.Texture2Color.g,self.Texture2Color.b,self.Texture2Color.a)
		render.SetMaterial(self.Texture2)
		render.DrawBeam(startPos,endPos,size,0,1,color)
	end
end
if !CPTBase then return end
---------------------------------------------------------------------------------------------------------------------------------------------
local Tracer = Material("trails/smoke")
local Tracer2  = Material("cpthazama/tracer")
local Width = 4
local Width2 = 16
local Speed = 7000
local Length = 200
---------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Init(data)
	self.Position = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.WeaponEnt = data:GetEntity()
	if !IsValid(self.WeaponEnt) then self.DieTime = 0 return end
	self.WeaponOwner = self.WeaponEnt:GetOwner()
	self.Attachment = data:GetAttachment()
	self.ModelEnt = self.WeaponOwner:IsPlayer() && (self.WeaponEnt._CModel or self.WeaponOwner:GetViewModel()) or self.WeaponEnt

	local muzEnt = self.WeaponOwner:IsPlayer() && (((self.WeaponOwner != LocalPlayer()) or self.WeaponOwner:ShouldDrawLocalPlayer()) && self.WeaponEnt) or self.ModelEnt
	self.StartPos = muzEnt:GetAttachment(self.Attachment).Pos
	self:SetRenderBoundsWS(self.StartPos,self.EndPos)

	local diff = (self.EndPos -self.StartPos)
	self.Dir = diff:GetNormal()
	self.Dist = self.StartPos:Distance(self.EndPos)
	
	self.StartTime = 0
	self.LifeTime = (diff:Length() +Length) /Speed
	self.LifeTime2 = 0.1 *self.LifeTime
	self.DieTime = CurTime() +self.LifeTime
	self.DieTime2 = CurTime() +self.LifeTime2

	self.ShouldDrawSmoke = math.random(1,3) == 1
end
---------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Think()
	self.StartTime = self.StartTime +FrameTime()
	if CurTime() > self.DieTime then
		return false
	end
	return true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Render()
	if CurTime() > self.DieTime then return end
	local r = 0
	local g = 178
	local b = 255
	
	local v = (self.DieTime -CurTime()) /self.LifeTime
	local v2 = (self.DieTime2 -CurTime()) /self.LifeTime2

	local endDistance = Speed *self.StartTime
	local startDistance = endDistance -Length
	startDistance = math.max(0,startDistance)
	endDistance = math.max(0,endDistance)
	local startPos = self.StartPos +self.Dir *startDistance
	local endPos = self.StartPos +self.Dir *endDistance

	if self.ShouldDrawSmoke then
		render.SetMaterial(Tracer)
		render.DrawBeam(startPos,endPos,Width,0,1,Color(37,53,107,v *90))
	end
	render.SetMaterial(Tracer2)
	render.DrawBeam(startPos,endPos,Width2,0,1,Color(r,g,b,(v2 *95) *0.5))
end
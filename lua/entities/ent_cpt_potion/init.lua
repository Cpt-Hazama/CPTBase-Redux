AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = "models/props_junk/garbage_glassbottle001a.mdl"
ENT.PotionLoad = 20
ENT.PickupSound = "cptbase/drink.mp3"

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_BBOX)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(1)
	end
	self:SetModelScale(0.7,0)
	self.HasBeenUsed = false
	self:SetColor(Color(0,180,255,150))
	local LightEffect = ents.Create("light_dynamic")
	LightEffect:SetKeyValue("_light", "0 180 255 100")
	LightEffect:SetKeyValue("brightness", "4")
	LightEffect:SetKeyValue("distance", "100")
	LightEffect:SetKeyValue("_cone", "0")
	LightEffect:SetPos(self:GetPos() +self:OBBCenter())
	LightEffect:SetParent(self)
	LightEffect:Spawn()
	LightEffect:Activate()
	LightEffect:Fire("TurnOn", "", 0)
	self.LightEffect = LightEffect
	self:DeleteOnRemove(self.LightEffect)
	GlowEffect = ents.Create( "env_sprite" )
	GlowEffect:SetKeyValue( "rendercolor","0 180 255" )
	GlowEffect:SetKeyValue( "GlowProxySize","8.0" )
	GlowEffect:SetKeyValue( "HDRColorScale","1.0" )
	GlowEffect:SetKeyValue( "renderfx","14" )
	GlowEffect:SetKeyValue( "rendermode","5" )
	GlowEffect:SetKeyValue( "renderamt","255" )
	GlowEffect:SetKeyValue( "disablereceiveshadows","0" )
	GlowEffect:SetKeyValue( "mindxlevel","0" )
	GlowEffect:SetKeyValue( "maxdxlevel","0" )
	GlowEffect:SetKeyValue( "framerate","10.0" )
	GlowEffect:SetKeyValue( "model","sprites/blueflare1.spr" )
	GlowEffect:SetKeyValue( "spawnflags","0" )
	GlowEffect:SetKeyValue( "scale","1" )
	GlowEffect:SetPos(self:GetPos() +self:OBBCenter())
	GlowEffect:Spawn()
	GlowEffect:SetParent(self)
	self:DeleteOnRemove(GlowEffect)
end

function ENT:Use(act,v)
	if !self.HasBeenUsed && IsValid(v) && v:IsPlayer() then
		self.HasBeenUsed = true
		if v.CPTBase_TimeSinceLastPotionDrink == nil then
			v.CPTBase_TimeSinceLastPotionDrink = CurTime()
		end
		if v.CPTBase_TotalDrinks == nil then
			v.CPTBase_TotalDrinks = 0
		end
		if CurTime() <= v.CPTBase_TimeSinceLastPotionDrink then
			v.CPTBase_TotalDrinks = v.CPTBase_TotalDrinks +1
			v.CPTBase_TimeSinceLastPotionDrink = CurTime() +10
		elseif CurTime() > v.CPTBase_TimeSinceLastPotionDrink then
			v.CPTBase_TotalDrinks = v.CPTBase_TotalDrinks -1
			if v.CPTBase_TotalDrinks < 0 then
				v.CPTBase_TotalDrinks = 0
			end
			v.CPTBase_TimeSinceLastPotionDrink = CurTime() +5
		end
		if v.CPTBase_TotalDrinks > 7 then
			v:EmitSound(self.PickupSound,75,100 *GetConVarNumber("host_timescale"))
			v:Kill()
			v:ChatPrint("You drank too much magicka potions in a short period of time! Be careful in the future.")
			self:Remove()
			return
		end
		v:SetNW2Int("CPTBase_Magicka",v:GetNW2Int("CPTBase_Magicka") +self.PotionLoad)
		if v:GetNW2Int("CPTBase_Magicka") > v:GetNW2Int("CPTBase_MaxMagicka") then
			v:SetNW2Int("CPTBase_Magicka",v:GetNW2Int("CPTBase_MaxMagicka"))
		end
		v:ChatPrint("You have " .. tostring(v:GetNW2Int("CPTBase_Magicka")) .. "/" .. tostring(v:GetNW2Int("CPTBase_MaxMagicka")) .. " magicka")
		v:EmitSound(self.PickupSound,75,100 *GetConVarNumber("host_timescale"))
		self:Remove()
	end
end
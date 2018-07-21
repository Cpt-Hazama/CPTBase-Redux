AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = "models/items/boxsrounds.mdl"
ENT.AmmoType = "5.56×45mm"
ENT.AmmoPickup = 35
ENT.MaxAmmo = 9999

function ENT:SpawnFunction(pl,tr)
	if !tr.Hit then return end
	local pos = tr.HitPos
	local ang = tr.HitNormal:Angle() +Angle(90,0,0)
	local ent = ents.Create("ammo_cpt_5.56mm")
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:Activate()

	return ent
end
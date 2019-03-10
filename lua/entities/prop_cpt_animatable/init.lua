if !CPTBase then return end
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetSolid(SOLID_OBB)
end
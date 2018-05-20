ENT.Base = "base_entity"
ENT.Type = "ai"
ENT.PrintName = "CPTBase"
ENT.Author = "Cpt. Hazama"
ENT.Contact = "http://steamcommunity.com/id/cpthazama/" 
ENT.Purpose = "A base used to easily created SNPCs."
ENT.Instructions = "Code an SNPC."
ENT.Information	= "Include this in your SNPC."  
ENT.Category = "CPTBase"
ENT.AutomaticFrameAdvance = true

ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetAutomaticFrameAdvance(bUsingAnim)
	self.AutomaticFrameAdvance = bUsingAnim
end

function ENT:PhysicsCollide(data,phys) end

function ENT:PhysicsUpdate(phys) end
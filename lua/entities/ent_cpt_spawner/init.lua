if !CPTBase then return end
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.SpawnableNPCs = {} -- {"npc_cpt_puker","npc_cpt_mortarsynth"}
ENT.SpawnableVectors = {} -- {[1] = Vector(5,10,0),[2] = Vector(30,5,10)}
ENT.MaxAliveNPCs = 0 -- How many NPCs that can be spawned at once
ENT.MaxSpawnableNPCs = 0 -- Set to -1 to make it infinite, otherwise it'll remove itself once X amount have spawned
ENT.SpawnChance = 8
ENT.IsActivated = false
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInitialize() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnEntitySpawned(ent) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink_BeforeNPCsSpawned() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnRemoved() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Initialize()
	self:SetModel("models/props_junk/popcan01a.mdl")
	self:DrawShadow(false)
	self:SetNoDraw(true)
	self:SetNotSolid(true)
	self.TotalSpawnedNPCs = 0
	self.tblSpawnedNPCs = {}
	if self.MaxAliveNPCs <= 0 then
		self:Remove()
		return
	end
		-- Checks if your IQ is high enough to watch Rick and Morty --
	if self.MaxSpawnableNPCs != -1 then
		if self.TotalSpawnedNPCs >= self.MaxSpawnableNPCs then
			self:Remove()
			return
		end
	end
	self:OnInitialize()
	self.bInitialized = true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink_BeforeActivated() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Think()
	if self.bInitialized != true then return end
	self:OnThink_BeforeActivated()
	if self.IsActivated == false then return end
	if self.MaxSpawnableNPCs != -1 then
		if self.TotalSpawnedNPCs >= self.MaxSpawnableNPCs then
			self:Remove()
			return
		end
	end
	self:OnThink_BeforeNPCsSpawned()
	for _,npc in ipairs(self.tblSpawnedNPCs) do
		if table.Count(self.tblSpawnedNPCs) > 0 && !IsValid(npc) && self.tblSpawnedNPCs[npc] != NULL then
			self.TotalSpawnedNPCs = self.TotalSpawnedNPCs -1
			self.tblSpawnedNPCs[npc] = NULL
		end
	end
	for i = 1,self.MaxAliveNPCs do
		if self.TotalSpawnedNPCs < self.MaxAliveNPCs then
			if math.random(1,self.SpawnChance) == 1 then
				local ent = ents.Create(self:SelectFromTable(self.SpawnableNPCs))
				ent:SetPos(self:GetPos() +self:SelectFromTable(self.SpawnableVectors))
				ent:SetAngles(self:GetAngles())
				ent:Spawn()
				ent:Activate()
				self:OnEntitySpawned(ent)
				table.insert(self.tblSpawnedNPCs,ent)
				self.TotalSpawnedNPCs = self.TotalSpawnedNPCs +1
			end
		end
	end
	self:OnThink()
	self:NextThink(CurTime() +0.5)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnRemove()
	self:OnRemoved()
	for _,ent in ipairs(self.tblSpawnedNPCs) do
		if IsValid(ent) then
			ent:Remove()
		end
	end
end
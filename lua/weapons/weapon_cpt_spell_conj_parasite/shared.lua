	-- Magic Stuff --
SWEP.MagickaCost = 15
SWEP.CheckMagicka = true
SWEP.SpellDelay = 1
SWEP.SelectedConjure = "npc_cpt_parasite"

	-- SWEP Stuff --
SWEP.PrintName		= "Conjure Parasite"
SWEP.Author 		= "Cpt. Hazama"
-- SWEP.Category		= "CPTBase - Spells"
SWEP.Base = "weapon_cpt_spell_base"
SWEP.AdminSpawnable = true
SWEP.Spawnable = true
SWEP.UseHands = true

SWEP.tbl_Sounds = {
	["Fire"] = {"cptbase/spells/spl_conjuration_cast.wav"}
}
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:PrimaryAttackCode(ShootPos,ShootDir)
	local tracedata = {}
	tracedata.start = self.Owner:GetPos() +self.Owner:OBBCenter()
	tracedata.endpos = self.Owner:GetPos() +self.Owner:OBBCenter() +self.Owner:GetForward() *350
	local tr = util.TraceLine(tracedata)
	local summonpos = self.Owner:GetEyeTrace().HitPos
	if self.Owner:GetPos():Distance(self.Owner:GetEyeTrace().HitPos) > 350 then
		summonpos = tr.HitPos
	end
	self:CreateSummon(summonpos,self.SelectedConjure)
end
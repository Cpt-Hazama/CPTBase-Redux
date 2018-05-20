if !CPTBase then return end
-------------------------------------------------------------------------------------------------------------------
hook.Add("ScaleNPCDamage","cpt_FindHitGroup",function(ent,hitbox,dmginfo)
	if ent.CPTBase_NPC == true then
		ent.Hitbox = hitbox
		ent.tblDamageInfo = dmginfo
		if (ent.Hitbox == HITGROUP_HEAD) then
			dmginfo:SetDamage(2.0)
		end
	end
end)

hook.Add("PlayerSpawnedNPC","cpt_SetOwnerNPC",function(ply,ent)
	if ent:IsNPC() && ent.CPTBase_NPC then
		if ent:GetOwner() == NULL then
			ent.NPC_Owner = ply
		end
	end
end)

hook.Add("OnNPCKilled","cpt_KilledNPC",function(victim,inflictor,killer)
	if killer.CPTBase_NPC then
		if killer != victim then
			killer:OnKilledEnemy(victim)
			killer:RemoveFromMemory(victim)
		end
	end
end)

hook.Add("PlayerDeath","cpt_KilledPlayer",function(victim,inflictor,killer)
	if killer.CPTBase_NPC then
		if killer != victim then
			killer:OnKilledEnemy(victim)
			killer:RemoveFromMemory(victim)
		end
	end
end)
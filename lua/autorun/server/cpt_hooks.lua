if !CPTBase then return end
-------------------------------------------------------------------------------------------------------------------
hook.Add("ScaleNPCDamage","cpt_FindHitGroup",function(ent,hitbox,dmginfo)
	if ent.CPTBase_NPC == true then
		ent.Hitbox = hitbox
		ent.tblDamageInfo = dmginfo
		if (ent.Hitbox == HITGROUP_HEAD) then
			dmginfo:ScaleDamage(2.0)
		end
	end
end)

hook.Add("EntityEmitSound","CPTBase_DetectEntitySounds",function(data)
	if GetConVarNumber("cpt_npchearing_advanced") == 0 then 
		return nil -- Don't alter sound data, proceed
	end
	/*
		Example Table:
			Ambient	=	false
			Channel	=	4
			DSP	=	0
			Entity	=	Player [1][Cpt. Hazama]
			Flags	=	0
			OriginalSoundName	=	player/footsteps/concrete2.wav
			Pitch	=	100
			Pos	=	778.584045 -835.784668 -143.968750
			SoundLevel	=	75
			SoundName	=	player/footsteps/concrete2.wav
			SoundTime	=	0
			Volume	=	0.20000000298023
	*/
	-- PrintTable(data)
	if !IsValid(data.Entity) then return nil end
	for _,v in pairs(ents.GetAll()) do
		if IsValid(v) && v:IsNPC() && v != data.Entity && v.CPTBase_NPC && v.UseAdvancedHearing then
			local ent = data.Entity
			local vol = data.SoundLevel
			local pos = data.Pos
			v:AdvancedHearingCode(ent,vol,pos)
		end
	end
	return nil
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
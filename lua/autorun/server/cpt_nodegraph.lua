if !CPTBase then return end
-------------------------------------------------------------------------------------------------------------------
/*
	To do:
		- Fix stack error
		- Add more node support types
*/

CPTBASE_NODE_GROUND = 1
CPTBASE_NODE_AIR = 2
CPTBASE_NODE_CLIMB = 3
CPTBASE_NODE_SWIM = 4
CPTBASE_NODE_HINT = 5

CPTBASE_NODE_TABLE = {}

CPTBASE_SV_MAXNODES = 7500 // 4096 is default for Garry's Mod. Too bad we're too cool for gSchool
CPTBASE_SV_DISTANCEBETWEENNODES = 170
CPTBASE_SV_MAXGENERATIONTIME = 15
CPTBASE_SV_MAXDISTANCECHECK = 32768

CPTBASE_SV_CANSETNODEGRAPH = false
CPTBASE_SV_STARTEDNODEGRAPH = false
CPTBASE_SV_NODEGRAPH = false
CPTBASE_SV_FINISHEDNODEGRAPH = false
-------------------------------------------------------------------------------------------------------------------
hook.Add("EntityRemoved","cpt_DetectRealNodes",function(ent)
	local nodetype = ent:GetClass()
	if string.find("node",ent:GetClass()) then print(ent) end
	if nodetype == "info_node" || nodetype == "info_node_hint" then
		table.insert(CPTBASE_NODE_TABLE,ent:GetPos())
	end
end)
-------------------------------------------------------------------------------------------------------------------
hook.Add("PlayerInitialSpawn","cpt_FindNodegraph",function(ply)
	if GetConVarNumber("cpt_debug_nodegraph") == 1 then
		timer.Simple(8,function()
			local map = game.GetMap()
			local dir = "maps/graphs/"
			local fileextension = ".ain"
			if !FindGameFile(dir .. map .. fileextension) then
				ply:ChatPrint("CPTBase Warning! This map does not have a nodegraph! Without a nodegraph, all SNPCs will not be able to navigate. Try searching up the map on the workshop and look for someone who has made a nodegraph. Otherwise, you'll need to make your own using Silverlan's Nodegraph tool: https://steamcommunity.com/sharedfiles/filedetails/?id=104487190")
				if ply:IsSuperAdmin() && !CPTBASE_SV_NODEGRAPH then
					CPTBASE_SV_CANSETNODEGRAPH = true
				end
			elseif FindGameFile(dir .. map .. fileextension) then
				local filesize = file.Size(dir .. map .. fileextension,"GAME")
				if filesize < 1500 && filesize > 400 then
					ply:ChatPrint("CPTBase Warning! This map has a nodegraph however it is very small. If this map is small then ignore this error however, if the map is as big as gm_construct or bigger, then this nodegraph is most likely bad/unfinished. Expect bad pathfinding!")
				elseif filesize <= 400 && filesize > 20 then
					ply:ChatPrint("CPTBase Warning! The nodegraph that this map has is incomplete/very poorly made. Expect really bad pathfinding!")
					if ply:IsSuperAdmin() && !CPTBASE_SV_NODEGRAPH then
						CPTBASE_SV_CANSETNODEGRAPH = true
					end
				elseif filesize <= 20 then
					ply:ChatPrint("CPTBase Warning! This map does not have a nodegraph! Without a nodegraph, all SNPCs will not be able to navigate. Try searching up the map on the workshop and look for someone who has made a nodegraph. Otherwise, you'll need to make your own using Silverlan's Nodegraph tool: https://steamcommunity.com/sharedfiles/filedetails/?id=104487190")
					if ply:IsSuperAdmin() && !CPTBASE_SV_NODEGRAPH then
						CPTBASE_SV_CANSETNODEGRAPH = true
					end
				elseif filesize >= 1500 then
					ply:ChatPrint("CPTBase Notification! This map has a nodegraph, although this does not determine the functionality of the graph. Expect varying pathfinding. Most good nodegraphs are about 100,000 bytes in size. The current nodegraph size is " .. filesize .. " bytes!")
				end
			end
		end)
	end
end)
-------------------------------------------------------------------------------------------------------------------
hook.Add("Initialize","cpt_DetectCanMakeNodegraph",function()
	timer.Simple(10,function()
		if CPTBASE_SV_CANSETNODEGRAPH then
			for _,ply in ipairs(player.GetAll()) do
				if ply:IsSuperAdmin() then
					ply:ConCommand("CPTBase_GenerateNodegraph")
					break
				end
			end
		end
	end)
end)
-------------------------------------------------------------------------------------------------------------------
concommand.Add("sv_cptbase_ainodes",function(caller,cmd,arg)
	if !caller:IsSuperAdmin() then return end
	local ent
	for _,v in ipairs(ents.GetAll()) do
		if v:GetClass() == "cpt_ai_node_manager" then
			ent = v
		end
	end
	ent:DisplayNodes()
end)
-------------------------------------------------------------------------------------------------------------------
concommand.Add("CPTBase_GenerateNodegraph",function(caller,cmd,arg)
	if GetConVarNumber("cpt_debug_cancreategraph") == 0 then return end
	if !caller:IsSuperAdmin() then return end
	-- if !CPTBASE_SV_CANSETNODEGRAPH then return end
	if CPTBASE_SV_NODEGRAPH then return end
	if CPTBASE_SV_FINISHEDNODEGRAPH then return end
	CPTBASE_SV_NODEGRAPH = true
	local cNodes = 0
	caller:ChatPrint("CPTBase is about to generate a temporary nodegraph. This may lag/crash your game during the writing process...")
	timer.Simple(5,function()
		if CPTBASE_SV_STARTEDNODEGRAPH then return end
		CPTBASE_SV_STARTEDNODEGRAPH = true
		local nm = ents.Create("cpt_ai_node_manager")
		nm:SetPos(Vector(0,0,0))
		nm:Spawn()
		local function CreateNode()
			if CPTBASE_SV_FINISHEDNODEGRAPH then return end
			local ve = VectorRand() *CPTBASE_SV_MAXDISTANCECHECK
			local tA = false
			if util.IsInWorld(ve) then
				local tr = util.TraceLine({
					start = ve,
					endpos = ve -Vector(0,0,CPTBASE_SV_MAXDISTANCECHECK),
					mask = MASK_PLAYERSOLID_BRUSHONLY
				})
				if tr.Hit then
					local nP = tr.HitPos
					local cmN = true
					for _,non in ipairs(ents.FindInSphere(nP,CPTBASE_SV_DISTANCEBETWEENNODES)) do
						if non:GetPos():Distance(nP) < CPTBASE_SV_DISTANCEBETWEENNODES then
							CreateNode()
							cmN = false
							break;
						end
					end
					if cmN then
						local n = ents.Create("cpt_ai_node")
						n:SetPos(nP +Vector(0,0,3))
						n:SetNodeType(1)
						n:SetNodeRadius(375)
						n:SetCanBeRemoved(true)
						n:Spawn()
						n:SetCanBeRemoved(true)
						cNodes = cNodes +1
					end
				end
			else
				tA = true
			end
			if tA then
				CreateNode()
			end
		end
		local loadedNodegraph = util.GetCPTBaseNodegraph()
		if loadedNodegraph != "noData" then
			if loadedNodegraph != nil && table.Count(loadedNodegraph) > 0 then
				nodegraphCount = table.Count(loadedNodegraph)
				for _,node in pairs(loadedNodegraph) do
					nm:InsertNode(node)
				end
			else
				for i = 1,CPTBASE_SV_MAXNODES do
					CreateNode()
				end
			end
		else
			for i = 1,CPTBASE_SV_MAXNODES do
				CreateNode()
			end
		end
		timer.Simple(CPTBASE_SV_MAXGENERATIONTIME,function()
			CPTBASE_SV_FINISHEDNODEGRAPH = true
			util.SaveCPTBaseNodegraph()
			caller:ChatPrint("Generated " .. tostring(cNodes) .. "/" .. CPTBASE_SV_MAXNODES .. " nodes.")
		end)
	end)
	if CPTBASE_SV_FINISHEDNODEGRAPH then
		caller:ChatPrint("CPTBase is has finished generating a temporary nodegraph. This nodegraph is dynamic and will only be available during this session. The next time you load this map, CPTBase will remake it and the nodes will most likely be in different positions.")
	end
end)
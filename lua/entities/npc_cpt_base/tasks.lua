include('shared.lua')

function ENT:TASKFUNC_WAIT()
	local _waittask = ai_sched_cpt.New("_waittask")
	_waittask:EngTask("TASK_WAIT",0)
	self:StartSchedule(_waittask)
end

function ENT:TASKFUNC_NAVRUN()
	if self.CanMove == false then return end
	if self:IsJumping() || self:IsClimbing() then return end
	local _runtoposition = ai_sched_cpt.New("_runtoposition")
	_runtoposition:EngTask("TASK_GET_PATH_TO_LASTPOSITION",0)
	_runtoposition:EngTask("TASK_RUN_PATH",0)
	_runtoposition:EngTask("TASK_WAIT_FOR_MOVEMENT",0)
	self:StartSchedule(_runtoposition)
	self:SetMovementAnimation("Run")
	if self.UsePlayermodelMovement then
		self:SetPoseParameter("move_x",self.PlayermodelMovementSpeed_Forward)
	end
end

function ENT:TASKFUNC_NAVWALK()
	if self.CanMove == false then return end
	if self:IsJumping() || self:IsClimbing() then return end
	local _walktoposition = ai_sched_cpt.New("_walktoposition") 
	_walktoposition:EngTask("TASK_GET_PATH_TO_LASTPOSITION",0)
	_walktoposition:EngTask("TASK_WALK_PATH",0)
	_walktoposition:EngTask("TASK_WAIT_FOR_MOVEMENT",0)
	self:StartSchedule(_walktoposition)
	self:SetMovementAnimation("Walk")
	if self.UsePlayermodelMovement then
		self:SetPoseParameter("move_x",self.PlayermodelMovementSpeed_Forward)
	end
end

function ENT:MoveNavMesh(movetype)
	if IsValid(self.NavMeshEntity) then
		if self:GetPos():Distance(self.NavMeshEntity:GetPos()) > 15 then
			self:SetLastPosition(self.NavMeshEntity:GetPos())
			if movetype == "run" then
				self:TASKFUNC_NAVRUN()
			else
				self:TASKFUNC_NAVWALK()
			end
		end
	end
end

function ENT:TASKFUNC_RUNTOPOS()
	if self.CanMove == false then return end
	if self.UseNavMesh && !self.IsPossessed then
		self:MoveNavMesh("run")
		return
	end
	if self:IsJumping() || self:IsClimbing() then return end
	local _runtoposition = ai_sched_cpt.New("_runtoposition")
	_runtoposition:EngTask("TASK_GET_PATH_TO_LASTPOSITION",0)
	_runtoposition:EngTask("TASK_RUN_PATH",0)
	_runtoposition:EngTask("TASK_WAIT_FOR_MOVEMENT",0)
	self:StartSchedule(_runtoposition)
	self:SetMovementAnimation("Run")
	if self.UsePlayermodelMovement then
		self:SetPoseParameter("move_x",self.PlayermodelMovementSpeed_Forward)
	end
end

function ENT:TASKFUNC_WALKTOPOS()
	if self.CanMove == false then return end
	if self.UseNavMesh && !self.IsPossessed then
		self:MoveNavMesh()
		return
	end
	if self:IsJumping() || self:IsClimbing() then return end
	local _walktoposition = ai_sched_cpt.New("_walktoposition") 
	_walktoposition:EngTask("TASK_GET_PATH_TO_LASTPOSITION",0)
	_walktoposition:EngTask("TASK_WALK_PATH",0)
	_walktoposition:EngTask("TASK_WAIT_FOR_MOVEMENT",0)
	self:StartSchedule(_walktoposition)
	self:SetMovementAnimation("Walk")
	if self.UsePlayermodelMovement then
		self:SetPoseParameter("move_x",self.PlayermodelMovementSpeed_Forward)
	end
end

function ENT:TASKFUNC_FOLLOWPLAYER()
	if self.CanMove == false then return end
	if self.UseNavMesh && !self.IsPossessed then
		self:MoveNavMesh("run")
		return
	end
	if self:IsJumping() || self:IsClimbing() then return end
	local _followplayer = ai_sched_cpt.New("_followplayer")
	_followplayer:EngTask("TASK_GET_PATH_TO_TARGET",0)
	-- _followplayer:EngTask("TASK_RUN_PATH",0)
	self:StartSchedule(_followplayer)
	-- self:SetMovementAnimation("Run")
	if self.UsePlayermodelMovement then
		self:SetPoseParameter("move_x",self.PlayermodelMovementSpeed_Forward)
	end
end

function ENT:TASKFUNC_LASTPOSITION()
	if self.CanMove == false then return end
	if self.UseNavMesh && !self.IsPossessed then
		self:MoveNavMesh("run")
		return
	end
	if self:IsJumping() || self:IsClimbing() then return end
	local _lastpositiontask = ai_sched_cpt.New("_lastpositiontask")
	_lastpositiontask:EngTask("TASK_GET_PATH_TO_LASTPOSITION",0)
	_lastpositiontask:EngTask("TASK_WAIT_FOR_MOVEMENT",0)
	self:StartSchedule(_lastpositiontask)
	self:SetMovementAnimation("Run") // New change
	if self.UsePlayermodelMovement then
		self:SetPoseParameter("move_x",self.PlayermodelMovementSpeed_Forward)
	end
end

function ENT:TASKFUNC_WALKLASTPOSITION()
	if self.CanMove == false then return end
	if self.UseNavMesh && !self.IsPossessed then
		self:MoveNavMesh()
		return
	end
	if self:IsJumping() || self:IsClimbing() then return end
	local _lastpositiontask = ai_sched_cpt.New("_lastpositiontask_walk")
	_lastpositiontask:EngTask("TASK_GET_PATH_TO_LASTPOSITION",0)
	-- _lastpositiontask:EngTask("TASK_WALK_PATH",0)
	_lastpositiontask:EngTask("TASK_WAIT_FOR_MOVEMENT",0)
	self:StartSchedule(_lastpositiontask)
	self:SetMovementAnimation("Walk")
	if self.UsePlayermodelMovement then
		self:SetPoseParameter("move_x",self.PlayermodelMovementSpeed_Forward)
	end
end

function ENT:TASKFUNC_RUNLASTPOSITION()
	if self.CanMove == false then return end
	if self.UseNavMesh && !self.IsPossessed then
		self:MoveNavMesh("run")
		return
	end
	if self:IsJumping() || self:IsClimbing() then return end
	local _lastpositiontask = ai_sched_cpt.New("_lastpositiontask_run")
	_lastpositiontask:EngTask("TASK_GET_PATH_TO_LASTPOSITION",0)
	-- _lastpositiontask:EngTask("TASK_RUN_PATH",0)
	_lastpositiontask:EngTask("TASK_WAIT_FOR_MOVEMENT",0)
	self:StartSchedule(_lastpositiontask)
	self:SetMovementAnimation("Run")
	if self.UsePlayermodelMovement then
		self:SetPoseParameter("move_x",self.PlayermodelMovementSpeed_Forward)
	end
end

function ENT:Hide(move)
	if self.CanMove == false then return end
	if self:IsJumping() || self:IsClimbing() then return end
	if self.CurrentSchedule != nil && self.CurrentSchedule.Name == "_hidetask" then return end
	local moveanim = move
	if move == nil then
		moveanim = "Run"
	end
	local _hidetask = ai_sched_cpt.New("_hidetask")
	-- _hidetask:EngTask("TASK_FIND_COVER_FROM_ENEMY",0) 
	_hidetask:EngTask("TASK_FIND_FAR_NODE_COVER_FROM_ENEMY",300) 
	_hidetask:EngTask("TASK_WAIT_FOR_MOVEMENT",0)
	self:StartSchedule(_hidetask)
	self:SetMovementAnimation(moveanim)
	if self.UsePlayermodelMovement then
		self:SetPoseParameter("move_x",self.PlayermodelMovementSpeed_Forward)
	end
end

function ENT:UseTraceChase(enemy)
	if self.CanMove == false then return end
	local gopos
	if nearest < 270 then
		local pos = self:GetPos() +Vector(0,0,10)
		local newdist = 230
		local tr = util.TraceHull({
			start = pos,
			endpos = pos +(enemy:Visible(self) && (enemy:GetPos() -self:GetPos()):GetNormal()) *newdist,
			-- mask = MASK_NPCSOLID,
			filter = {self,enemy},
			mins = self:OBBMins(),
			maxs = self:OBBMaxs()
		})
		if (tr.Hit) then
			gopos = pos +(enemy:Visible(self) && (enemy:GetPos() -self:GetPos()):GetNormal()) *newdist
			self:SetLastPosition(gopos)
			self:TASKFUNC_CHASE()
			-- self:TASKFUNC_GETPATHANDGO()
		end
	end
end

function ENT:TASKFUNC_FACEPOSITION(pos)
	if self.CanMove == false then return end
	local _facepositiontask = ai_sched_cpt.New("_facepositiontask")
	_facepositiontask:EngTask("TASK_FACE_LASTPOSITION",0)
	self:SetLastPosition(pos)
	self:StartSchedule(_facepositiontask)
end

local fnode = NULL
local flastnode = NULL
local nextnodet = CurTime()
function ENT:TASKFUNC_CPTBASENAVIGATE(ent)
	if self.CanMove == false then return end
	if self.UseCPTBaseAINavigation == false then return end
	if self:GetPos():Distance(ent:GetPos()) < 375 then
		self:SetTarget(ent)
		self:TASKFUNC_GETPATHANDGO()
		return
	end
	if CurTime() > nextnodet then
		for _,nodepos in ipairs(self:GetNodeManager():GetNodes()) do
			if self:VisibleVec(nodepos) then
				if !table.HasValue(self.tbl_RegisteredNodes,nodepos) then
					table.insert(self.tbl_RegisteredNodes,nodepos)
				end
			end
		end
		nextnodet = CurTime() +0.3
	end
	if self.tbl_RegisteredNodes != nil && table.Count(self.tbl_RegisteredNodes) > 0 then
		local node = self:GetClosestNodes(self.tbl_RegisteredNodes,ent)
		if !node then MsgN("NPC has no nodes near by! Do NOT report this error to me on the workshop page! This error is being caused because the NPC can't find any nodes near by.") return end
		self:SetLastPosition(node)
		self:TASKFUNC_RUNTOPOS()
		-- if !IsValid(fnode) then
			-- local b = ents.Create("prop_dynamic")
			-- b:SetModel("models/editor/ground_node.mdl")
			-- b:SetPos(node)
			-- b:Spawn()
			-- self:DeleteOnRemove(b)
			-- fnode = b
			-- timer.Simple(self:GetPathTimeToGoal(),function() if IsValid(b) then b:Remove() end end)
		-- end
		if self.UsePlayermodelMovement then
			self:SetPoseParameter("move_x",self.PlayermodelMovementSpeed_Forward)
		end
	end
end

function ENT:TASKFUNC_GETPATHANDGO()
	if self.CanMove == false then return end
	if self.UseNavMesh && !self.IsPossessed then
		self:MoveNavMesh("run")
		return
	end
	if self:IsJumping() || self:IsClimbing() then return end
	if self.CurrentSchedule != nil && self.CurrentSchedule.Name == "getpathandchasetask" then return end
	local getpathandchasetask = ai_sched_cpt.New("getpathandchasetask")
	getpathandchasetask:EngTask("TASK_GET_PATH_TO_ENEMY",0)
	getpathandchasetask:EngTask("TASK_WAIT_FOR_MOVEMENT",0)
	-- getpathandchasetask:EngTask("TASK_FACE_ENEMY",0)
	self:StartSchedule(getpathandchasetask)
	if self.UsePlayermodelMovement then
		self:SetPoseParameter("move_x",self.PlayermodelMovementSpeed_Forward)
	end
end

function ENT:TASKFUNC_CHASE()
	if self.CanMove == false then return end
	if self.UseNavMesh && !self.IsPossessed then
		self:MoveNavMesh("run")
		return
	end
	if self:IsJumping() || self:IsClimbing() then return end
	if self.CurrentSchedule != nil && self.CurrentSchedule.Name == "_chasetaskfunc" then return end
	local _chasetaskfunc = ai_sched_cpt.New("_chasetaskfunc")
	_chasetaskfunc:EngTask("TASK_GET_PATH_TO_ENEMY",0)
	-- _chasetaskfunc:EngTask("TASK_RUN_PATH",0)
	_chasetaskfunc:EngTask("TASK_WAIT_FOR_MOVEMENT",0)
	_chasetaskfunc:EngTask("TASK_FACE_ENEMY",0)
	self:StartSchedule(_chasetaskfunc)
	if self.UsePlayermodelMovement then
		self:SetPoseParameter("move_x",self.PlayermodelMovementSpeed_Forward)
	end
end

function ENT:TASKFUNC_WANDER()
	if self.CanMove == false then return end
	if self.UseCPTBaseAINavigation then
		if CurTime() > nextnodet then
			for _,nodes in ipairs(ents.GetAll()) do
				if IsValid(nodes) && nodes:GetClass() == "cpt_ai_node" && self:Visible(nodes) then
					if !table.HasValue(self.tbl_RegisteredNodes,nodes) then
						table.insert(self.tbl_RegisteredNodes,nodes)
					end
				end
			end
			nextnodet = CurTime() +0.3
		end
		if self.tbl_RegisteredNodes != nil && table.Count(self.tbl_RegisteredNodes) > 0 then
			local nodes = self:FindWanderNodes(self.tbl_RegisteredNodes)
			local node = self:GetClosestNodes(nodes,self:SelectFromTable(nodes))
			if node == nil then return end
			self:SetLastPosition(node)
			self:TASKFUNC_WALKTOPOS()
			if self.UsePlayermodelMovement then
				self:SetPoseParameter("move_x",self.PlayermodelMovementSpeed_Forward)
			end
		end
	else
		local _wandertaskfunc = ai_sched_cpt.New("_wandertaskfunc")
		_wandertaskfunc:EngTask("TASK_GET_PATH_TO_RANDOM_NODE",400)
		-- _wandertaskfunc:EngTask("TASK_WALK_PATH",0)
		_wandertaskfunc:EngTask("TASK_WAIT_FOR_MOVEMENT",0)
		self:StartSchedule(_wandertaskfunc)
		self:SetMovementAnimation("Walk")
		if self.UsePlayermodelMovement then
			self:SetPoseParameter("move_x",self.PlayermodelMovementSpeed_Forward)
		end
	end
end
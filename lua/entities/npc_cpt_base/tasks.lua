include('shared.lua')

function ENT:TASKFUNC_WAIT()
	local _waittask = ai_sched_cpt.New("_waittask")
	_waittask:EngTask("TASK_WAIT",0)
	self:StartSchedule(_waittask)
end

function ENT:TASKFUNC_RUNTOPOS()
	local _runtoposition = ai_sched_cpt.New("_runtoposition")
	_runtoposition:EngTask("TASK_GET_PATH_TO_LASTPOSITION",0)
	_runtoposition:EngTask("TASK_RUN_PATH",0)
	_runtoposition:EngTask("TASK_WAIT_FOR_MOVEMENT",0)
	self:StartSchedule(_runtoposition)
end

function ENT:TASKFUNC_WALKTOPOS()
	local _walktoposition = ai_sched_cpt.New("_walktoposition") 
	_walktoposition:EngTask("TASK_GET_PATH_TO_LASTPOSITION",0)
	_walktoposition:EngTask("TASK_WALK_PATH",0)
	_walktoposition:EngTask("TASK_WAIT_FOR_MOVEMENT",0)
	self:StartSchedule(_walktoposition)
end

function ENT:TASKFUNC_FOLLOWPLAYER()
	local _followplayer = ai_sched_cpt.New("_followplayer")
	_followplayer:EngTask("TASK_GET_PATH_TO_TARGET",0)
	_followplayer:EngTask("TASK_RUN_PATH",0)
	self:StartSchedule(_followplayer)
end

function ENT:TASKFUNC_LASTPOSITION()
	local _lastpositiontask = ai_sched_cpt.New("_lastpositiontask")
	_lastpositiontask:EngTask("TASK_GET_PATH_TO_LASTPOSITION",0)
	_lastpositiontask:EngTask("TASK_WAIT_FOR_MOVEMENT",0)
	self:StartSchedule(_lastpositiontask)
end

function ENT:Hide()
	local _hidetask = ai_sched_cpt.New("_hidetask") 
	_hidetask:EngTask("TASK_FIND_COVER_FROM_ENEMY",0) 
	_hidetask:EngTask("TASK_WAIT_FOR_MOVEMENT",0)
	self:StartSchedule(_hidetask)
end

function ENT:UseTraceChase(enemy)
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
	local _facepositiontask = ai_sched_cpt.New("_facepositiontask")
	_facepositiontask:EngTask("TASK_FACE_LASTPOSITION",0)
	self:SetLastPosition(pos)
	self:StartSchedule(_facepositiontask)
end

function ENT:TASKFUNC_GETPATHANDGO()
	if self.CurrentSchedule != nil && self.CurrentSchedule.Name == "getpathandchasetask" then return end
	local getpathandchasetask = ai_sched_cpt.New("getpathandchasetask")
	getpathandchasetask:EngTask("TASK_GET_PATH_TO_TARGET",0)
	self:StartSchedule(getpathandchasetask)
end

function ENT:TASKFUNC_CHASE()
	if self.CurrentSchedule != nil && self.CurrentSchedule.Name == "_chasetaskfunc" then return end
	local _chasetaskfunc = ai_sched_cpt.New("_chasetaskfunc")
	_chasetaskfunc:EngTask("TASK_GET_PATH_TO_ENEMY",0)
	_chasetaskfunc:EngTask("TASK_RUN_PATH",0)
	_chasetaskfunc:EngTask("TASK_WAIT_FOR_MOVEMENT",0)
	_chasetaskfunc:EngTask("TASK_FACE_ENEMY",0)
	self:StartSchedule(_chasetaskfunc)
end

function ENT:TASKFUNC_WANDER()
	local _wandertaskfunc = ai_sched_cpt.New("_wandertaskfunc")
	_wandertaskfunc:EngTask("TASK_GET_PATH_TO_RANDOM_NODE",400)
	_wandertaskfunc:EngTask("TASK_WALK_PATH",0)
	_wandertaskfunc:EngTask("TASK_WAIT_FOR_MOVEMENT",0)
	self:StartSchedule(_wandertaskfunc)
end
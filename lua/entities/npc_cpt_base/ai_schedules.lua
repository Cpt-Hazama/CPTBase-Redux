if !CPTBase then return end
if (CLIENT) then return end

require("ai_sched_cpt")
require("ai_task_cpt")

function ENT:RunAI(strExp)
	if not IsValid(self) then return end
	if (self:IsRunningBehavior()) then return true end
	if (self:DoingEngineSchedule()) then return true end
	if (self.CurrentSchedule) then self:DoSchedule(self.CurrentSchedule) end
	if (!self.CurrentSchedule) then self:SelectSchedule() end
	local __cyc = self:GetCycle() == 1
	self:MaintainActivity()
	if (self.IsPlayingSequence) then return end
	local anim = ai_sched_cpt.New(self:GetIdleAnimation())
	if(!self.CurrentTask && __cyc && self:GetCycle() == 1) then
		if IsValid(self) then
			anim:EngTask("TASK_PLAY_SEQUENCE",self:GetIdleAnimation())
			self:StartEngineTask(GetTaskID("TASK_SET_ACTIVITY"),self:GetIdleAnimation())
			self:MaintainActivity()
		end
	end
end

function ENT:StartSchedule(schedule)
	if not IsValid(self) then return end
	-- if (self.IsPlayingSequence) then return end
	self:ClearCondition(35)
	for k,v in ipairs(schedule.Tasks) do
		if v.TaskName == "TASK_FACE_TARGET" or v.TaskName == "TASK_FACE_ENEMY" then
			schedule.ScheduleMoving_FaceTarget = true
		end
		if v.TaskName == "TASK_RUN_PATH" or v.TaskName == "TASK_RUN_PATH_FLEE" or v.TaskName == "TASK_RUN_PATH_TIMED" or v.TaskName == "TASK_RUN_PATH_FOR_UNITS" or v.TaskName == "TASK_RUN_PATH_WITHIN_DIST" then
			schedule.ScheduleMoving = true
			schedule.Schedule_Running = true
			break
		end
		if v.TaskName == "TASK_WALK_PATH" or v.TaskName == "TASK_WALK_PATH_TIMED" or v.TaskName == "TASK_WALK_PATH_WITHIN_DIST" or v.TaskName == "TASK_WALK_PATH_FOR_UNITS" then
			schedule.ScheduleMoving = true
			schedule.Schedule_Walking = true
			break
		end
		schedule.ScheduleMoving = false
		schedule.Schedule_Running = false
		schedule.Schedule_Walking = false
		schedule.ScheduleMoving_FaceTarget = false
	end
	self.CurrentSchedule = schedule
	self.CurrentSchedule.Name = schedule
	self.CurrentTaskID = 1
	self:SetTask(schedule:GetTask(1))
end

function ENT:GetSchedule()
	for s=0, LAST_SHARED_SCHEDULE -1 do
		if (self:IsCurrentSchedule(s)) then
			return s
		end
	end
	return 0
end

function ENT:DoSchedule( schedule )
	if not IsValid(self) then return end
	if (self.CurrentTask) then
		self:RunTask(self.CurrentTask)
	end
	if (self:TaskFinished()) then
		self:NextTask(schedule)
	end
end

function ENT:ScheduleFinished()
	if not IsValid(self) then return end
	self.CurrentSchedule = nil
	self.CurrentTask = nil
	self.CurrentTaskID = nil
end

function ENT:SetTask(task)
	if not IsValid(self) then return end
	if (self.IsPlayingSequence) then return end
	self.CurrentTask = task
	self.bTaskComplete = false
	self.TaskStartTime = CurTime()
	self:StartTask( self.CurrentTask )
end

function ENT:NextTask(schedule)
	if not IsValid(self) then return end
	self.CurrentTaskID = self.CurrentTaskID + 1 || 1
	local val = schedule:NumTasks() || 1
	if ( self.CurrentTaskID > schedule:NumTasks() ) then
		self:ScheduleFinished( schedule )
		return
	end
	self:SetTask( schedule:GetTask( self.CurrentTaskID ) )
end

function ENT:StartTask(task) task:Start(self) end
function ENT:RunTask(task) if !task || !self then return end task:Run(self) end
function ENT:TaskTime() return CurTime() - self.TaskStartTime end
function ENT:OnTaskComplete() self.bTaskComplete = true end
function ENT:TaskFinished() return self.bTaskComplete end
function ENT:StartEngineTask(iTaskID,TaskData) end
function ENT:RunEngineTask(iTaskID,TaskData) end
function ENT:StartEngineSchedule(scheduleID) self:ScheduleFinished() self.bDoingEngineSchedule = true end
function ENT:EngineScheduleFinish() self.bDoingEngineSchedule = nil end
function ENT:DoingEngineSchedule() return self.bDoingEngineSchedule end
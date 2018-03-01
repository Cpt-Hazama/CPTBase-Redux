if !CPTBase then return end
-------------------------------------------------------------------------------------------------------------------
if (CLIENT) then return end

require("ai_task_cpt")
module("ai_sched_cpt",package.seeall)

local ai_sched_cpt = {}
ai_sched_cpt.__index = ai_sched_cpt

function ai_sched_cpt:Init(_debugname_) 
	self.DebugName = tostring(_name_)
	self.Tasks = {}
	self.TaskCount = 0
end

function New(debugname)
	local NewSchedule = {}
	setmetatable(NewSchedule,ai_sched_cpt)
	NewSchedule:Init(debugname)
	return NewSchedule
end

function ai_sched_cpt:AddTask(_functionname_,_data_)
	local NewTask = ai_sched_cpt.New()
	NewTask:InitFunctionName("TaskStart_".._functionname_,"Task_".._functionname_,_data_)
	self.TaskCount = table.insert(self.Tasks,NewTask)
end

function ai_sched_cpt:EngTask(_taskname_,_taskdata_)
	local NewTask = ai_task_cpt.New()
	NewTask:InitEngine(_taskname_,_taskdata_)
	self.TaskCount = table.insert(self.Tasks,NewTask)
end

function ai_sched_cpt:NumTasks() return self.TaskCount end
function ai_sched_cpt:GetTask(num) return self.Tasks[num] end
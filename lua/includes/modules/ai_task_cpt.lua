if !CPTBase then return end
-------------------------------------------------------------------------------------------------------------------
if (CLIENT) then return end

module("ai_task_cpt",package.seeall)

local setmetatable = setmetatable
local tostring = tostring
local table	= table
local Msg = Msg
local Error = Error
local TYPE_ENGINE = 1
local TYPE_FNAME = 2
local Task = {}

Task.__index = Task

function Task:Init() self.Type = nil end

function Task:InitEngine(_taskname_,_taskdata_)
	self.TaskName = _taskname_
	self.TaskID = nil
	self.TaskData = _taskdata_
	self.Type = TYPE_ENGINE
end

function Task:Start(npc)
	if (self:IsFNameType()) then self:Start_FName(npc) return end
	if (self:IsEngineType()) then
		if (!self.TaskID) then self.TaskID = GetTaskID(self.TaskName) end
		npc:StartEngineTask(self.TaskID,self.TaskData)
	end
end

function Task:Run(npc)
	if (self:IsFNameType()) then self:Run_FName(npc) return end
	if (self:IsEngineType()) then
		npc:RunEngineTask( self.TaskID,self.TaskData )
	end
end

function New()
	local NewTask = {}
	setmetatable(NewTask,Task)
	NewTask:Init()
	return NewTask
end

function Task:IsEngineType() return (self.Type == TYPE_ENGINE) end
function Task:IsFNameType() return (self.Type == TYPE_FNAME) end
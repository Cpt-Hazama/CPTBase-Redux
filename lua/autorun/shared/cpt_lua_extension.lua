cptLua = {}

cptLua.OpenTable = function(tb)
	for key,value in pairs(tb) do
		print(tostring(key) .. " = " .. tostring(value))
	end
	MsgN("Opened table /n"
end

return cptLua
∞ = math.huge
π = math.pi

math.Mean = function(tb)
	local totalsum = 0
	local num = #tb
	for k,v in ipairs(tb) do
		totalsum = totalsum +v
		if k == #tb then
			totalsum = totalsum /num
		end
	end
	return totalsum
end

math.Median = function(tbl)
	local count = #tbl
	local mVal = math.ceil(count /2)
	return tbl[mVal]
end

math.Mode = function(tb)
	local tbValues = {}
	for k,v in ipairs(tb) do
		tbValues[#tbValues +1] = v
	end
	return tbValues[#tbValues] -tbValues[1]
end
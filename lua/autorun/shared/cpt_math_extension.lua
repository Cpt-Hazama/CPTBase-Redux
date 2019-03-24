∞ = math.huge
π = math.pi

math.IsInteger = function(num)
	return math.floor(num) == num
end

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
	local val = math.ceil(count /2)
	return tbl[val]
end

math.Mode = function(tb)
	local tbl = {}
	for k,v in ipairs(tb) do
		tbl[#tbl +1] = v
	end
	return tbl[#tbl] -tbl[1]
end
Vector = {}

function Vector.len(vec)
	return math.sqrt(vec.x ^2 +vec.y ^2 +vec.z ^2)
end

function Vector.tostring(vec)
	return "(" .. vec.x .. "," .. vec.y .. "," .. vec.z .. ")"
end

return Vector
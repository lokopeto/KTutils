local M = {}

local floor_limit = 10000

-- float imprecise handler
function M.zeroout(num)
	if math.floor(num * floor_limit) == -1 then
		return 0
	elseif math.floor(num * floor_limit) == 1 then
		return 0
	else
		return num
	end
end

return M

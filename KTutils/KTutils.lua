local utils = {}

local floor_limit = 10000

-- float imprecise handler
function utils.zeroout(num)
	if math.floor(num * floor_limit) == -1 then
		return 0
	elseif math.floor(num * floor_limit) == 1 then
		return 0
	else
		return num
	end
end

-- code from https://defold.com/manuals/camera/#converting-mouse-to-world-coordinates
-- may changes occur to the code on the future
local function utils.screen_to_world(sx, sy, sz, window_width, window_height, projection, view)
	local inv = vmath.inv(projection * view)
	sx = (2 * sx / window_width) - 1
	sy = (2 * sy / window_height) - 1
	sz = (2 * sz) - 1
	local wx = sx * inv.m00 + sy * inv.m01 + sz * inv.m02 + inv.m03
	local wy = sx * inv.m10 + sy * inv.m11 + sz * inv.m12 + inv.m13
	local wz = sx * inv.m20 + sy * inv.m21 + sz * inv.m22 + inv.m23
	return wx, wy, wz
end

return utils

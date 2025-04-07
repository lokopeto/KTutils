local utils = {}

local floor_limit = 10000

-- simple float imprecise handler
function utils.zeroout(num)
	if math.floor(num * floor_limit) == -1 then
		return 0
	elseif math.floor(num * floor_limit) == 1 then
		return 0
	else
		return num
	end
end
--

-- code from https://defold.com/manuals/camera/#converting-mouse-to-world-coordinates
-- may changes occur to the code on the future

--- Convert from screen to world coordinates
-- @param sx Screen x
-- @param sy Screen y
-- @param sz Screen z
-- @param window_width Width of the window (use render.get_width() or window.get_size().x)
-- @param window_height Height of the window (use render.get_height() or window.get_size().y)
-- @param projection Camera/render projection (use go.get("#camera", "projection"))
-- @param view Camera/render view (use go.get("#camera", "view"))
-- @return wx World x
-- @return wy World y
-- @return wz World z
function utils.screen_to_world(sx, sy, sz, window_width, window_height, projection, view)
	local inv = vmath.inv(projection * view)
	sx = (2 * sx / window_width) - 1
	sy = (2 * sy / window_height) - 1
	sz = (2 * sz) - 1
	local wx = sx * inv.m00 + sy * inv.m01 + sz * inv.m02 + inv.m03
	local wy = sx * inv.m10 + sy * inv.m11 + sz * inv.m12 + inv.m13
	local wz = sx * inv.m20 + sy * inv.m21 + sz * inv.m22 + inv.m23
	return wx, wy, wz
end

-- debug with drawning text on the screen
function utils.easydebug(x, y, string)
	msg.post("@render:", "draw_text", { text = string, position = vmath.vector3(x, y, 0) })
end
--

-- convenient functions for ips
function utils.concat_ip(ip,port)
	return tostring(ip) .. ":" .. tostring(port) -- example: 127.0.0.0:0000 = "127.0.0.0","0000"
end

function utils.deconcat_ip(str)
	return utils.deconcat(str, ":")
end
--

function utils.concat(left, right, finder)
	return left .. finder .. right
end

function utils.deconcat(str, finder)
	local loc = string.find(str, finder)
	local size = string.len(finder)
	
	if loc then
		return string.sub(str,0,loc - 1), string.sub(str,loc + size) -- ip, port
	else
		return str
	end
end

return utils

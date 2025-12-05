-- path = /Entities#Player -- data = "basic data" -- customdata = "customdata"
local M = {}
local plus = "|"
table.new = package.preload["table.new"]()
ffi = package.preload["ffi"]()
local buffer = package.preload["string.buffer"]()


local userdataConverter = {
	vector3 = function(v) return { v.x, v.y, v.z } end,
	vector4 = function(v) return { v.x, v.y, v.z, v.w } end,
	matrix4 = function(m)
		return {
			m.m00, m.m01, m.m02, m.m03,
			m.m10, m.m11, m.m12, m.m13,
			m.m20, m.m21, m.m22, m.m23,
			m.m30, m.m31, m.m32, m.m33,
		}
	end,
	quat = function(q) return { q.x, q.y, q.z, q.w } end,
	vector = function(v)
		local t = {}
		for i = 1, #v do
			t[i] = v[i]
		end
		return t
	end,
	hash = function(h) return hash_to_hex(h) or tostring(h) end,
} -- table with function for perfomance
local userdatas = {
	"vector3",
	"vector4",
	"matrix4",
	"quat",
	"vector",
	"hash",
}
local userdataType2userdata = {
	vector3 = function(v) return vmath.vector3(v[1], v[2], v[3]) end,
	vector4 = function(v) return vmath.vector4(v[1], v[2], v[3], v[4]) end,
	matrix4 = function(v)
		return vmath.matrix4(
			v[1],  v[2],  v[3],  v[4],
			v[5],  v[6],  v[7],  v[8],
			v[9],  v[10], v[11], v[12],
			v[13], v[14], v[15], v[16]
		)
	end,
	quat = function(v) return vmath.quat(v[1], v[2], v[3], v[4]) end,
	vector = function(v) return vmath.vector(v) end,
	hash = function(v) return hash(v) end,
}

-- duplication of name for perfomance
-- numered tables is faster

local function deepcopy(orig, opt)
	-- opt.userdata == true/false | pass userdata/convert to table
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key,opt)] = deepcopy(orig_value,opt)
		end
		setmetatable(copy, deepcopy(getmetatable(orig),opt))
	else -- number, string, boolean, etc
		if opt.userdata == true then
			if type(orig) == "userdata" then
				for k,v in ipairs(userdatas) do
					if types["is_"..v](orig) then
						orig = userdataConverter[v](orig)
						orig.__userdataType = v
						break
					end
				end
			end
		end
		copy = orig
	end
	return copy
end
local function table2userdata(orig, pastvalue, pastkey)
	local orig_type = type(orig)
	if orig_type == 'table' then
		if orig.__userdataType then
			local type = orig.__userdataType
			orig.__userdataType = nil
			pastvalue[pastkey] = userdataType2userdata[type](orig)
			return
		end
		for orig_key, orig_value in next, orig, nil do
			table2userdata(orig_value, orig, orig_key)
		end
	end
end



function M.compress(data,prefix)
	prefix = prefix or ""

	local table = deepcopy(data, {userdata = true})
	local str = buffer.encode(table)

	return prefix..":"..str
end

function M.decompress(str)	
	local prefix, data = str:match("^(.-):(.*)")
	data = buffer.decode(data)
	table2userdata(data)
	
	return table, prefix
end

return M

local ffi = require("ffi")
local buffer = require("string.buffer")
local C = ffi.C

local s = "/local/entities#Goblin532:name=s-Cave Goblin,id=s-goblin_01,transform/rotation=q-0|0|0|1,transform/scale=v3-1|1|1,transform/position=v3-4|18|0,physics/velocity=v3-0|0|0,physics/acceleration=v3-0|-9.8000001907349|0,physics/knockback=v3-0|0|0,stats/combat/attack=n-6,transform/bounding/size=v3-0.80000001192093|1.2000000476837|0,transform/bounding/offset=v3-0|0.10000000149012|0,physics/collider/shape=s-capsule,physics/collider/height=n-1.2,physics/collider/radius=n-0.35,transform/rotation=q-0|0|0|1,transform/scale=v3-1|1|1,transform/position=v3-4|18|0,physics/velocity=v3-0|0|0,physics/acceleration=v3-0|-9.8000001907349|0,physics/knockback=v3-0|0|0,stats/combat/defense=n-2,stats/combat/speed=n-1.1,stats/combat/attack=n-6,transform/bounding/size=v3-0.80000001192093|1.2000000476837|0,transform/bounding/offset=v3-0|0.10000000149012|0,physics/collider/shape=s-capsule,physics/collider/height=n-1.2,physics/collider/radius=n-0.35,stats/core/stamina/current=n-14,stats/core/stamina/max=n-14,stats/core/health/current=n-32,stats/core/health/max=n-32,stats/combat/crit/multiplier=n-1.5,stats/combat/crit/chance=n-0.08,transform/rotation=q-0|0|0|1,transform/scale=v3-1|1|1,transform/position=v3-4|18|0,physics/velocity=v3-0|0|0,physics/acceleration=v3-0|-9.8000001907349|0,physics/knockback=v3-0|0|0,stats/combat/defense=n-2,stats/combat/speed=n-1.1,stats/combat/attack=n-6,transform/bounding/size=v3-0.80000001192093|1.2000000476837|0,transform/bounding/offset=v3-0|0.10000000149012|0,physics/collider/shape=s-capsule,physics/collider/height=n-1.2,physics/collider/radius=n-0.35,stats/core/stamina/current=n-14,stats/core/stamina/max=n-14,stats/core/health/current=n-32,stats/core/health/max=n-32,stats/combat/crit/multiplier=n-1.5,stats/combat/crit/chance=n-0.08,transform/rotation=q-0|0|0|1,transform/scale=v3-1|1|1,transform/position=v3-4|18|0,physics/velocity=v3-0|0|0,physics/acceleration=v3-0|-9.8000001907349|0,physics/knockback=v3-0|0|0,stats/combat/defense=n-2,stats/combat/speed=n-1.1,"

local str = buffer.new():put(s)



-- local symbolfinder = { ",", ":", "=", "/", "|" }
-- local list = {}
-- local listSym = {} 
-- local listindex = 1
-- for _,v in ipairs(symbolfinder) do
-- 	listSym[v] = {}
-- end
-- for i = 1, #str do
-- 	local get = str:get(1)
-- 	for _,v in ipairs(symbolfinder) do
-- 		if get == v then
-- 			list[listindex] = i
-- 			listSym[v][listindex] = i
-- 			listindex = listindex + 1
-- 		end
-- 	end
-- end
-- str:put(s)
-- local lastI = 0
-- for i = 1, #listSym[","] do
-- 	local get1,get2 = str:get(listSym[","][i] - lastI - 1)
-- 	lastI = list[i]
-- 	print(get1)
-- 	str:skip(1)
-- end
local EntityData = {
	id = "goblin_01",
	name = "Cave Goblin",

	transform = {
		position = vmath.vector3(4, 18, 0),
		rotation = vmath.quat_rotation_z(0),
		scale = vmath.vector3(1, 1, 1),

		bounding = {
			size = vmath.vector3(0.8, 1.2, 0),
			offset = vmath.vector3(0, 0.1, 0)
		}
	},

	stats = {
		core = {
			health = { current = 32, max = 32 },
			stamina = { current = 14, max = 14 }
		},
		combat = {
			attack = 6,
			defense = 2,
			speed = 1.1,
			crit = { chance = 0.08, multiplier = 1.5 }
		}
	},

	physics = {
		velocity = vmath.vector3(0, 0, 0),
		acceleration = vmath.vector3(0, -9.8, 0),
		knockback = vmath.vector3(0, 0, 0),

		collider = {
			shape = "capsule",
			radius = 0.35,
			height = 1.2
		}
	}
}





local function compress(data,prefix)
	prefix = prefix or ""

	local tables = {}
	tables[1] = {}
	local nontables = {}
	for k,v in pairs(data) do
		if type(v) == "table" then
			tables[1][k] = v
		else
			nontables[k] = v
		end
	end

	if next(tables[1]) then
		local has_tables = 1
		local i = 1
		while has_tables >= 1 do
			tables[i+1] = tables[i+1] or {}
			has_tables = 0
			for k,v in pairs(tables[i]) do
				if type(v) == "table" then
					for k1,v1 in pairs(v) do
						tables[i+1][k.."/"..k1] = v1
						has_tables = has_tables + 1
					end
				else
					tables[i+1][k] = v
				end
			end
			i = i + 1
		end
	end

	-- concat everything
	local str = ""
	for k,v in pairs(nontables) do
		str = str..values2string(k,v)
	end
	for k,v in pairs(tables) do
		for k1,v1 in pairs(v) do
			if type(v1) ~= "table" then
				str = str..values2string(k1,v1)
			end
		end
	end
	return prefix..":"..str
end









local function decompress(str)
	local prefix = string.sub(str, 0, string.find(str,":") - 1)
	local data = string.sub(str, string.len(prefix) + 2)

	-- separate path from value
	local rawtable = {}
	for s in string.gmatch(data,"(.-%,)") do
		s = string.sub(s,0,-2)
		local varpath = string.sub(s,0,string.find(s,"=") - 1)
		local value = string.sub(s,string.len(varpath) + 2)
		rawtable[varpath] = value
	end
	local table = {}

	local tablekeys = {}
	for k,v in pairs(rawtable) do
		local finder = 0
		local index = 1
		local singlepath = {}
		local oldF = 0
		for s in string.gmatch(k,"(%/)") do
			local key = ""
			oldF = finder + 1
			finder = string.find(k,"/",finder+1)
			key = string.sub(k,oldF,finder - 1)
			if string.match(key,"%d") == key then
				key = tonumber(key)
			end
			singlepath[index] = key

			index = index+1
		end
		local cur = table
		for k1,v1 in ipairs(singlepath) do
			if not cur[v1] then
				cur[v1] = {}
			end
			cur = cur[v1]
		end
		local key = string.sub(k,finder + 1)
		local v = simple2func[string.sub(v, 0, 1)](string.sub(v, 3))
		cur[key] = v
	end

	return table, prefix
end


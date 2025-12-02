-- path = /Entities#Player -- data = "basic data" -- customdata = "customdata"
local M = {}

local type2simple = {
	["string"]   = "s",
	["number"]   = "n",
	["function"] = "f",
	["boolean"]  = "b",
	["nil"]      = "0",
}
local simple2type = {
	["s"] = "string",
	["n"] = "number",
	["f"] = "function",
	["b"] = "boolean",
	["0"] = "nil",
}
local simple2func = {
	["s"] = function(v) return v end,
	["n"] = tonumber,
	["b"] = function(v)
		if v == "true"  or v == true  or v == 1 or v == "1" then return true  end
		if v == "false" or v == false or v == 0 or v == "0" then return false end
		return nil
	end,
	["0"] = function(_) return nil end,
}

function M.compress(prefix,data)
	prefix = prefix or ""
	local str = ""

	local tables = { }
	tables[1] = {}
	for k,v in pairs(data) do
		if type(v) == "table" then
			tables[1][k] = v 
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
	for k,v in pairs(data) do
		if not tables[1][k] then
			str = str..tostring(k).."="..type2simple[type(v)].."-"..tostring(v)..","
		end
	end
	for k,v in pairs(tables) do
		for k1,v1 in pairs(v) do
			if type(v1) ~= "table" then
				str = str..tostring(k1).."="..type2simple[type(v1)].."-"..tostring(v1)..","
			end
		end
	end
	return prefix..":"..str
end

function M.decompress(str)
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

return M

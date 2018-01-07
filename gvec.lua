-- luagvect
-- GLSL-like vector & matrix function

local vec = {}
local math = require("math")

------------------
-- Vector class --
------------------

local swizzle_mt = {mask_map = {
	x = 1, y = 2, z = 3, w = 4,
	r = 1, g = 2, b = 3, a = 4,
	s = 1, t = 2, p = 3, q = 4
}}

function swizzle_mt.__index(vec, var)
	assert(type(var) == "string" and #var <= #vec, "Invalid index")
	
	if #var == 1 then
		return vec[assert(swizzle_mt.mask_map[var], "Invalid swizzle mask")]
	end
	
	local ret_vec = {}
	
	for i = 1, #var do
		local char = var:sub(i, i)
		ret_vec[i] = vec[assert(swizzle_mt.mask_map[char], "Invalid swizzle mask")]
	end
	
	return (setmetatable(ret_vec, swizzle_mt))
end

function swizzle_mt.__newindex(vec, var, val)
	if #var == 1 then
		-- float
		vec[assert(swizzle_mt.mask_map[var])] = assert(type(val) == "number" and val, "Invalid value")
	else
		-- vector
		assert(#val == #var, "Invalid vector")
		
		for i = 1, #var do
			local char = var:sub(i, i)
			vec[i] = val[assert(swizzle_mt.mask_map[char], "Invalid swizzle mask")]
		end
	end
end

local function make_binary_op(binf)
	return function(veca, b)
		local vecr = {}
		
		if type(b) == "number" then
			-- vector with scalar
			for i = 1, #veca do
				vecr[i] = binf(veca[i], b)
			end
		else
			if type(veca) == "number" then
				local x = {}
				for i = 1, #b do
					x[i] = veca
				end
				veca = x
			end
			
			-- component-wise vector with vector
			assert(#veca == #b, "Invalid vector")
			for i = 1, #veca do
				vecr[i] = binf(veca[i], b[i])
			end
		end
		
		return (setmetatable(vecr, swizzle_mt))
	end
end

function swizzle_mt.__unm(veca)
	local vecr = {}
	
	for i = 1, #veca do
		vecr[i] = -veca[i]
	end
	
	return (setmetatable(vecr, swizzle_mt))
end

swizzle_mt.__add = make_binary_op(function(a, b) return a + b end)
swizzle_mt.__sub = make_binary_op(function(a, b) return a - b end)
swizzle_mt.__mul = make_binary_op(function(a, b) return a * b end)
swizzle_mt.__div = make_binary_op(function(a, b) return a / b end)

function swizzle_mt.__tostring(vec)
	local strb = {"vec"}
	strb[#strb + 1] = tostring(#vec)
	strb[#strb + 1] = "("
	
	for i = 1, #vec do
		strb[#strb + 1] = string.format("%f", vec[i])
		strb[#strb + 1] = ", "
	end
	strb[#strb] = ")"
	
	return table.concat(strb)
end

local function make_vecn(n)
	return function(...)
		local vecs = {}
		local len = select("#", ...)
		local vtemp = select(1, ...)
		local j = 1
		
		if len == 1 and type(vtemp) == "number" then	-- float
			for i = 1, n do
				vecs[i] = vtemp
			end
		else
			for i = 1, select("#", ...) do
				local v = select(i, ...)
				
				if type(v) == "number" then
					vecs[j] = v
					j = j + 1
				else
					assert(type(v) == "table")
					
					for k = 1, #v do
						vecs[j] = assert(type(v[k]) == "number" and v[k], "Invalid value")
						j = j + 1
					end
				end
			end
			
			for i = n + 1, #vecs do
				vecs[i] = nil
			end
		end
		
		return (setmetatable(vecs, swizzle_mt))
	end
end

vec.vec2 = make_vecn(2)
vec.vec3 = make_vecn(3)
vec.vec4 = make_vecn(4)

------------------
-- Matrix class --
------------------
local matrix_mt = {}

function matrix_mt.__add(ma, mb)
	assert(getmetatable(ma) == getmetatable(mb), "Invalid type")
	assert(#ma == #mb, "Invalid matrix")
	local mr = {}
	
	for i = 1, #ma do
		local a = {}
		assert(#ma[i] == #mb[i], "Invalid matrix")
		
		for j = 1, #ma[i] do
			a[j] = ma[i][j] + mb[i][j]
		end
		
		mr[i] = setmetatable(a, swizzle_mt)
	end
	
	return (setmetatable(mr, matrix_mt))
end

function matrix_mt.__unm(ma)
	local mr = {}
	
	for i = 1, #ma do
		local a = {}
		
		for j = 1, #ma[i] do
			a[j] = -ma[i][j]
		end
		
		mr[i] = setmetatable(a, swizzle_mt)
	end
	
	return (setmetatable(mr, matrix_mt))
end

function matrix_mt.__sub(ma, mb)
	return -mb + ma
end

function matrix_mt.__mul(a, mb)
	local mr = {}
	
	if getmetatable(mb) == swizzle_mt then
		-- matrix with vector
		local a = {}
		for i = 1, #mb do
			a[i] = {mb[i]}
		end
		mb = setmetatable(a, matrix_mt)
	end
	
	if type(a) == "number" then
		-- multiply scalar with matrix
		for i = 1, #mb do
			local b = {}
			
			for j = 1, #mb[i] do
				b[j] = mb[i][j] * a
			end
			
			mr[i] = setmetatable(b, swizzle_mt)
		end
	else
		-- matrix with matrix
		assert(#a[1] == #mb, "Invalid matrix")
		
		for i = 1, #a do
			mr[i] = {}
			for j = 1, #mb[1] do
				mr[i][j] = 0
				for k = 1, #mb do
					mr[i][j] = mr[i][j] + a[i][k] * mb[k][j]
				end
			end
		end
	end
	
	if #mr[1] == 1 then
		-- Change to vector
		local a = {}
		for i = 1, #mr do
			a[i] = mr[i][1]
		end
		
		return (setmetatable(a, swizzle_mt))
	end
	
	return (setmetatable(mr, matrix_mt))
end

function matrix_mt.__div(ma, mb)
	-- component-wise matrix divide
	assert(getmetatable(ma) == getmetatable(mb), "Invalid type")
	assert(#ma == #mb, "Invalid matrix")
	local mr = {}
	
	for i = 1, #ma do
		local a = {}
		assert(#ma[i] == #mb[i], "Invalid matrix")
		
		for j = 1, #ma[i] do
			a[j] = ma[i][j] / mb[i][j]
		end
		
		mr[i] = setmetatable(a, swizzle_mt)
	end
	
	return (setmetatable(mr, matrix_mt))
end

local function make_mat(m, n)
	return function(...)
		local vals = {}
		local len = select("#", ...)
		local j = 1
		
		for i = 1, select("#", ...) do
			local v = select(i, ...)
			
			if type(v) == "number" then
				vals[j] = v
				j = j + 1
			else
				assert(type(v) == "table")
				
				for k = 1, #v do
					vals[j] = v[k]
					j = j + 1
				end
			end
		end
		
		local mr = {}
		for i = 1, m do
			local v = {}
			
			for j = 1, n do
				v[j] = table.remove(vals, 1)
			end
			
			mr[i] = setmetatable(v, swizzle_mt)
		end
		
		return (setmetatable(mr, matrix_mt))
	end
end

vec.mat2 = make_mat(2, 2)
vec.mat3 = make_mat(3, 3)
vec.mat4 = make_mat(4, 4)
vec.mat2x2 = vec.mat2
vec.mat3x3 = vec.mat3
vec.mat4x4 = vec.mat4
vec.mat2x3 = make_mat(2, 3)
vec.mat2x4 = make_mat(2, 4)
vec.mat3x2 = make_mat(3, 2)
vec.mat4x2 = make_mat(4, 2)
vec.mat3x4 = make_mat(3, 4)
vec.mat4x3 = make_mat(4, 3)

-------------------------------------
-- Component-wise vector functions --
-------------------------------------
local function make_component_wise_func(func)
	return function(vec)
		if type(vec) == "number" then
			return func(vec)
		else
			local vecr = {}
			
			for i = 1, #vec do
				vecr[i] = func(vec[i])
			end
			
			return (setmetatable(vecr, swizzle_mt))
		end
	end
end

local function make_component_wise_func2(func)
	return function(veca, vecb)
		
		if type(veca) == "number" then
			return func(veca, vecb)
		end
		
		if type(vecb) == "number" then
			vecb = {vecb, vecb, vecb, vecb}
		end
		
		local vecr = {}
		
		for i = 1, #veca do
			vecr[i] = func(veca[i], vecb[i])
		end
		
		return (setmetatable(vecr, swizzle_mt))
	end
end

-- from http://www.shaderific.com/glsl-functions/
vec.radians = make_component_wise_func(math.rad)
vec.degrees = make_component_wise_func(math.deg)
vec.sin = make_component_wise_func(math.sin)
vec.cos = make_component_wise_func(math.cos)
vec.tan = make_component_wise_func(math.tan)
vec.asin = make_component_wise_func(math.asin)
vec.acos = make_component_wise_func(math.acos)
vec.atan = make_component_wise_func(math.atan)
vec.atan2 = make_component_wise_func2(math.atan2)
vec.pow = make_component_wise_func2(math.pow)
vec.exp = make_component_wise_func(math.exp)
vec.log = make_component_wise_func(math.log)
vec.exp2 = make_component_wise_func(function(x) return 2^x end)
vec.log2 = make_component_wise_func(function(x) return math.log(x) / math.log(2) end)
vec.sqrt = make_component_wise_func(math.sqrt)
vec.inversesqrt = make_component_wise_func(function(x) return 1 / math.sqrt(x) end)
vec.abs = make_component_wise_func(math.abs)
vec.sign = make_component_wise_func(function(x) return x > 0 and 1 or (x < 0 and -1 or 0) end)
vec.floor = make_component_wise_func(math.floor)
vec.ceil = make_component_wise_func(math.ceil)
vec.fract = make_component_wise_func(function(x) return x - math.floor(x) end)
vec.mod = make_component_wise_func2(function(x, y) return x % y end)
vec.min = make_component_wise_func2(math.min)
vec.max = make_component_wise_func2(math.max)

--[[
function vec.min(x, y)
	if type(x) == "number" then
		return math.min(x, y)
	else
		local vecr = {}
		
		if type(y) == "number" then
			local z = y
			y = {z, z, z, z}
		else
			assert(#x == #y, "Invalid vector")
		end
		
		for i = 1, #x do
			vecr[i] = math.min(x[i], y[i])
		end
		
		return (setmetatable(vecr, swizzle_mt))
	end
end

function vec.max(x, y)
	if type(x) == "number" then
		return math.max(x, y)
	else
		local vecr = {}
		
		if type(y) == "number" then
			local z = y
			y = {z, z, z, z}
		else
			assert(#x == #y, "Invalid vector")
		end
		
		for i = 1, #x do
			vecr[i] = math.max(x[i], y[i])
		end
		
		return (setmetatable(vecr, swizzle_mt))
	end
end
]]

function vec.clamp(x, minval, maxval)
	if type(x) == "number" then
		return math.min(math.max(x, minval), maxval)
	else
		assert(getmetatable(x) == swizzle_mt, "Invalid type")
		local vecr = {}
		
		for i = 1, #x do
			vecr[i] = math.min(math.max(x[i], minval), maxval)
		end
		
		return (setmetatable(vecr, swizzle_mt))
	end
end

function vec.mix(x, y, a)
	if type(x) == "number" and type(y) == "number" then
		-- Number lerp
		assert(type(a) == "number", "Invalid type")
		return x * (1 - a) + y * a
	end
	
	assert(#x == #y, "Invalid vector")
	
	if type(a) == "number" then
		local b = a
		a = {b, b, b, b}
	else
		assert(#x == #a, "Invalid vector")
	end
	
	local vecr = {}
	for i = 1, #x do
		vecr[i] = x[i] * (1 - a[i]) + y[i] * a[i]
	end
	
	return (setmetatable(vecr, swizzle_mt))
end

--------------------------------
-- Vector geometric functions --
--------------------------------
function vec.length(vec)
	local r = 0
	
	for i = 1, #vec do
		r = r + vec[i] * vec[i]
	end
	
	return math.sqrt(r)
end

function vec.distance(veca, vecb)
	return vec.length(veca - vecb)
end

function vec.dot(veca, vecb)
	assert(#veca == #vecb, "Invalid vector")
	local res = 0
	
	for i = 1, #veca do
		res = res + veca[i] * vecb[i]
	end
	
	return res
end

function vec.cross(veca, vecb)
	assert(#veca == 3 and #vecb == 3, "Invalid vector (must be vec3)")
	local vecr = {}
	vecr[1] = veca[2] * vecb[3] - veca[3] * vecb[2]
	vecr[2] = veca[3] * vecb[1] - veca[1] * vecb[3]
	vecr[3] = veca[1] * vecb[2] - veca[2] * vecb[1]
	
	return (setmetatable(vecr, swizzle_mt))
end

function vec.normalize(v)
	return v / vec.length(v)
end

function vec.reflect(I, N)
	return I - 2 * vec.dot(N, I) * N
end

------------------------------
-- Vector compare functions --
------------------------------
local function make_cmp_function(cmpfunc)
	return function(veca, vecb)
		assert(#veca == #vecb, "Invalid vector")
		local len = #veca
		
		if len == 2 then
			return cmpfunc(veca[1], vecb[1]), cmpfunc(veca[2], vecb[2])
		elseif len == 3 then
			return cmpfunc(veca[1], vecb[1]), cmpfunc(veca[2], vecb[2]), cmpfunc(veca[3], vecb[3])
		elseif len == 4 then
			return cmpfunc(veca[1], vecb[1]), cmpfunc(veca[2], vecb[2]), cmpfunc(veca[3], vecb[3]), cmpfunc(veca[4], vecb[4])
		else
			-- Shouldn't happen
			local t = {}
			for i = 1, len do
				t[i] = cmpfunc(veca[i], vecb[i])
			end
			return unpack(t)
		end
	end
end

vec.lessThan = make_cmp_function(function(a, b) return a < b end)
vec.lessThanEqual = make_cmp_function(function(a, b) return a <= b end)
vec.greaterThan = make_cmp_function(function(a, b) return a > b end)
vec.greaterThanEqual = make_cmp_function(function(a, b) return a >= b end)
vec.equal = make_cmp_function(function(a, b) return a == b end)
vec.notEqual = make_cmp_function(function(a, b) return a ~= b end)

-- Matrix functions
function vec.matrixCompMult(ma, mb)
	-- component-wise matrix multiply
	assert(getmetatable(ma) == getmetatable(mb), "Invalid type")
	assert(#ma == #mb, "Invalid matrix")
	local mr = {}
	
	for i = 1, #ma do
		local a = {}
		assert(#ma[i] == #mb[i], "Invalid matrix")
		
		for j = 1, #ma[i] do
			a[j] = ma[i][j] * mb[i][j]
		end
		
		mr[i] = setmetatable(a, swizzle_mt)
	end
	
	return (setmetatable(mr, matrix_mt))
end

return vec

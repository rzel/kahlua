function assert(c, msg, ...)
	if c then
		return c, msg, ...
	end
	error(msg or "assertion failed!")
end

local function ipairs_iterator(t, index)
	local nextIndex = index + 1
	local nextValue = t[nextIndex]
	if nextValue then
		return nextIndex, nextValue
	end
end

function ipairs(t)
	return ipairs_iterator, t, 0
end

function pairs(t)
	return next, t, nil
end

function string.len(s)
	return #s
end

function string.rep(s, n)
	local ret = ""
	for i = 1, n do
		ret = ret .. s
	end
	return ret
end

function string.gmatch(str, pattern)
	local init = 1
	local function gmatch_it()
		if init <= str:len() then 
			local s, e = str:find(pattern, init)
			if s then
				local res = {str:match(pattern, init)}
				init = e+1
				return unpack(res)
			end
		end
	end
	return gmatch_it
end

function math.max(max, ...)
	local select = select
	for i = 1, select("#", ...) do
		local v = select(i, ...)
		max = (max < v) and v or max
	end
	return max
end

function math.min(min, ...)
	local select = select
	for i = 1, select("#", ...) do
		local v = select(i, ...)
		min = (min > v) and v or min
	end
	return min
end

table = {}
function table.insert(t, a, b)
	local tlen = #t
	local pos, value
	if b then
		pos, value = a, b
	else
		pos, value = tlen + 1, a
	end
	for i = tlen, pos, -1 do
		t[i + 1] = t[i]
	end
	t[pos] = v
end

function table.remove(t, pos)
	local tlen = #t
	for i = pos, tlen - 1 do
		t[i] = t[i + 1]
	end
	local v = t[tlen]
	t[tlen] = nil
	return v
end

function table.setn()
	error("setn is obsolete")
end

function table.getn(t)
	return #t
end

function table.maxn(t)
	local maxIndex = 0
	for k, v in next, t do
		if maxIndex < k then
			maxIndex = k
		end
	end
	return maxIndex
end

do
	local function partition(tbl, left, right, pivot, comp)
		local pval = tbl[pivot]
		tbl[pivot], tbl[right] = tbl[right], tbl[pivot]
		local store = left
		for v = left, right - 1, 1 do
			if comp(tbl[v], pval) then
				tbl[v], tbl[store] = tbl[store], tbl[v]
				store = store + 1
			end
		end
		tbl[store], tbl[right] = tbl[right], tbl[store]
		return store
	end
	local function quicksort(tbl, left, right, comp)
		if right > left then
			local pivot = left
			local newpivot = partition(tbl,left,right,pivot, comp)
			quicksort(tbl,left,newpivot-1, comp)
			return quicksort(tbl,newpivot+1,right, comp)
		end
		return tbl
	end

	function table.sort(tbl, comp) -- quicksort
	    if not comp then
		comp = function(one,two) return one < two end
	    end
	    return quicksort(tbl,1, #tbl, comp)
	end
end

table.concat = tableconcat

do
	local error = error
	local ccreate = coroutine.create
	local cresume = coroutine.resume

	local function wrap_helper(status, ...)
		if status then
			return ...
		end
		error(...)
	end

	function coroutine.wrap(f)
		local coro = ccreate(f)
		return function(...)
			return wrap_helper(
				cresume(
					coro, ...
				)
			)
		end
	end
end
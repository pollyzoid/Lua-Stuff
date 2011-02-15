local function checkType( ... )
	local a = {...}

	local num = #a/2
	if num % 2 ~= 0 then error 'uneven amount of arguments' end

	for i=1, num do
		if type( a[i] ) ~= a[num + i] then
			return false
		end
	end

	return true
end

local STRING = getmetatable ""

function STRING.__add( o1, o2 )
	if checkType( o1, o2, "string", "string" ) then
		return o1 .. o2
	end

	error( 'attempt to perform arithmetic on a string value', 2 )
end

function STRING.__sub( o1, o2 )
	if checkType( o1, o2, "string", "number" ) then
		return o1:sub( 1, -o2-1 )
	elseif checkType( o2, o1, "string", "number" ) then
		return o2:sub( -o1 )
	end

	if checkType( o1, o2, "string", "string" ) then
		return o1:gsub( o2, "" )
	end

	error( 'attempt to perform arithmetic on a string value', 2 )
end

function STRING.__mul( o1, o2 )
	if checkType( o1, o2, "string", "number" ) then
		return o1:rep( o2 )
	end

	error( 'attempt to perform arithmetic on a string value', 2 )
end

function STRING.__div( o1, o2 )
	if checkType( o1, o2, "string", "string" ) then
		return o1:split( o2 )
	end

	error( 'attempt to perform arithmetic on a string value', 2 )
end
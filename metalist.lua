local getmetatable, setmetatable, ipairs, print, unpack
    = getmetatable, setmetatable, ipairs, print, unpack

module 'metalist'

local _ML = {}

function new( tbl )
    return setmetatable( { List = tbl }, _ML )
end

-- wee
setmetatable( _M, { __call = function( self, tbl ) return new( tbl ) end } )

--// Some helpers

local function ResultList( self, func )
    local ret = {}
    for k, v in ipairs( self.List ) do
        ret[k] = func( v, k )
    end
    return new( ret )
end

local function BinOp( func )
    return function( o1, o2 )
        if IsMetaList( o1 ) then
            return ResultList( o1, function( m ) return func( m, o2 ) end )
        else
            return ResultList( o2, function( m ) return func( o1, m ) end )
        end
    end
end

function IsValid( ml )
	return getmetatable( ml ) == _ML
end

--// MetaList methods

function _ML:any( func )
	for k,v in ipairs( ResultList( self, function( m ) return func( m ) end ).List ) do
		if v then return true end
	end

	return false
end

function _ML:all( func )
	for k,v in ipairs( ResultList( self, function( m ) return func( m ) end ).List ) do
		if v == false then return false end
	end

	return true
end

function _ML:call( func, ... )
    local args = {...}
    return ResultList( self, function( m ) return func( m, unpack(args) ) end )
end

function _ML:__tostring()
	return "MetaList"
end

function _ML:__index( k )
	return _ML[k] or ResultList( self, function( m, k ) return m[k] end )
end

function _ML:__newindex( k, v )
	return ResultList( self, function( m ) m[k] = v end )
end

function _ML:__call( slef, ... )
	local args = { ... }
	return ResultList( self, function( m, k ) return m( slef.List[k], unpack( args ) ) end )
end

function _ML:__unm()
	return ResultList( self, function( m ) return -m end )
end

function _ML:__len()
	return ResultList( self, function( m ) return #m end )
end

_ML.__sub = BinOp( function( a, b ) return a - b end )
_ML.__add = BinOp( function( a, b ) return a + b end )
_ML.__mul = BinOp( function( a, b ) return a * b end )
_ML.__div = BinOp( function( a, b ) return a / b end )
_ML.__pow = BinOp( function( a, b ) return a ^ b end )

_ML.__concat = BinOp( function( a, b ) return a .. b end )

_ML.__eq = BinOp( function( a, b ) return a == b end )
_ML.__lt = BinOp( function( a, b ) return a < b end )
_ML.__le = BinOp( function( a, b ) return a <= b end )

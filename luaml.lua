local print, setmetatable, type, rawget, pairs, ipairs, tostring
	= print, setmetatable, type, rawget, pairs, ipairs, tostring

local table
    = table

module 'luaml'

local STATE_NEW = 1
local STATE_CHILDREN = 2
local STATE_DONE = 3

local _node = {}

local function newnode( name )
    return setmetatable( { __name = name, __children = {}, __properties = {}, __state = STATE_NEW }, _node )
end

setmetatable( _M, {
	__call = function( self )
		return newnode 'root'
	end
} )

-- ML Tree iterator
local function iter( n, i )
    i = i + 1
    local v = n.__children[i]
    if v then
        return i, v
    end
end

function tree( n )
    return iter, n.__children, 0
end

--// MarkupLanguage Node

function _node:__tostring()
    return 'node: ' .. self.__name
end

function _node:__index( k )
    if _node[k] then return _node[k] end
    if k:sub( 1, 2 ) == '__' then return rawget( self, k ) end

    return newnode( k )
end

-- magic starts here
function _node:__call( a )
    -- if argument is non-table, it's a value
    if type( a ) ~= 'table' then
        self.__value = a
        -- value is always last
        self.__state = STATE_DONE
    elseif self.__state == STATE_NEW then
        -- properties before children
        self.__properties = a
        self.__state = STATE_CHILDREN
    elseif self.__state == STATE_CHILDREN then
        self.__children = a
    end

    return self
end

local tab = '\t'
function _node:print( int )
    int = int or 0

    local str = tab:rep(int) .. self.__name

    if self.__value then
        local v = self.__value
        if type( v ) == 'string' then
            v = '\'' .. v .. '\''
        end
        str = str .. ': ' .. tostring( v )
    end
    if table.Count( self.__properties ) > 0 then
        str = str .. ' { '
        for k,v in pairs( self.__properties ) do
            if type( v ) == 'string' then
                v = '\'' .. v .. '\''
            end
            str = str .. k .. '=' .. tostring( v ) .. ' '
        end
        str = str .. '}'
    end

    print( str )

    for k,v in ipairs( self.__children ) do
        v:print( int + 1 )
    end
end

function _node:getvalue() return self.__value end
function _node:getproperties() return self.__properties end
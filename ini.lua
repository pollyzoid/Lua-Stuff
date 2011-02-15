local pairs
    = pairs

local string
    = string

module 'ini'

function Parse( str )
        local tbl = {}
        local sect
        for line in str:gmatch( "[^\r\n]+" ) do
                sect = line:match( "^%s*%[([^%[%]]+)%]" ) or sect
                if sect then
                        tbl[sect] = tbl[sect] or {}
                        local k, v = line:match( "^%s*([^;=]-)%s*=%s*\"?([^=\"]+)\"?%s*" )
                        tbl[sect][k or ""] = v
                end
        end

        return tbl
end

function Write( tbl )
        local str = ""
        for name, sect in pairs( tbl ) do
                str = str .. "[" .. name .. "]\n"

                for k, v in pairs( sect ) do
                        str = str .. string.format( "%s = %s\n", k, v )
                end

                str = str .. "\n"
        end

        return str:sub( 1, str:len() - 2 )
end
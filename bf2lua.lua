--[[
        Lazy man's Brainfuck in Lua
]]

module 'bf2lua'

local parsed = {
	[">"] = "cell.Idx = cell.Idx + $rep$";
	["<"] = "cell.Idx = cell.Idx - $rep$";
	["+"] = "cell[cell.Idx] = cell[cell.Idx] + $rep$";
	["-"] = "cell[cell.Idx] = cell[cell.Idx] - $rep$";
	["."] = "io.write( string.char( cell[cell.Idx] ):rep($rep$)) )";
	["["] = "while( cell[cell.Idx] ~= 0 ) do";
	["]"] = "end";
}

local _mt = {
    __index = function()
        return 0
    end
}

function Parse( str )
	cell = setmetatable( {
        Idx = 0;
    }, _mt )

    local newStr = ""

    local tkn = str:sub(1, 1)
    while tkn ~= '' do
        local num = str:sub( 1, str:match( "%" .. tkn .. "+()" ) - 1 ):len()

        if parsed[tkn] then
            newStr = newStr .. parsed[tkn]:gsub("%$rep%$", tostring(num)) .. "\n"
        end

        str = str:sub(num + 1)
        tkn = str:sub(1, 1)
    end

    return newStr
end

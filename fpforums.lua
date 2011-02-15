--[[
        NOTE: This is not useful at all.
]]

local http = require "socket.http"

local forums = {}

local tryAgain = true
local r, e

while tryAgain do
	tryAgain = false

	for i=1, 377 do -- 377 is last valid forum ID as of 15/2
		if not forums[i] then
			io.write( "requesting forum ", i, "... " )
			r, e = http.request( "http://www.facepunch.com/forums/" .. i )

			if r then
				local title = r:match "<title>(.-)</title>"
				local navList = {}

				for f in r:gmatch [[<span class="navbit">&gt; <a href="[^"]-">([^<]-)</a></span>]] do
					navList[#navList + 1] = f
				end

				if title == "Facepunch" then
					if r:find "you do not have permission to access this page" then
						title = "Secret"
					elseif r:find "Your administrator has required a password to access this forum." then
						title = "Passworded"
					elseif r:find "Invalid Forum specified." then
						title = "Invalid"
					end
				end

				forums[i] = {
					Title = title;
					Parents = navList;
				}

				if #navList == 0 then
					io.write( title, '\n' )
				else
					io.write( table.concat( navList, " > " ) .. " > " .. title, '\n' )
				end
			else
				forums[i] = false
				tryAgain = true
				io.write( e, '\n' )
			end
		end
	end
end

for k,v in ipairs( forums ) do
	print( k, table.concat( v.Parents, " > " ) .. " > " .. v.Title )
end
--[[
        BROKEN, TO FIX:
            - Text wrapping
            - Handling whitespace?
]]

local table, math, surface, string = table, math, surface, string
local print, PrintTable, error, ipairs, pairs, setmetatable, Color, tonumber, tostring, unpack = 
		print, PrintTable, error, ipairs, pairs, setmetatable, Color, tonumber, tostring, unpack

module( "markupx" )

local _tags, _tagStack = {}, {}
local _blockList, _currentBlock = {}, {}

local _mObject = {}
_mObject.__index = _mObject

function _mObject:Create( blocks, width, height )
	return setmetatable( {
		Blocks = blocks;
		Width = width;
		Height = height;
	}, self )
end

local function unpackColor( clr )
	return clr.r, clr.g, clr.b, 255
end

local _block
function _mObject:Draw( x, y )
	for i=1, #self.Blocks do
		_block = self.Blocks[i]
		
		for t,a in pairs( _block._Tags ) do
			if _tags[t].Draw then
				_tags[t]:Draw( _block )
			end
		end
		
		if _block.Text and #_block.Text then
			surface.SetTextPos( x + _block.X, y + (_block.Line - 1) * _block.Height )
			surface.DrawText( _block.Text )
		end
	end
end

function RegisterTag( tag, tbl )
	_tags[tag] = tbl
end

local function NewBlock( old, txt, child )
	local _block = table.Copy( old or {} )
	if child then
		_block.Parent = old
	end

	_block._Tags = _block._Tags or {}

	if not txt or #txt == 0 then
		_block.Text = nil
		_block.Width = 0
		_block.Height = 0
	elseif txt and #txt > 0 then
		_block.Text = txt
		_block.Width, _block.Height = surface.GetTextSize( txt )
	end

	local last = _blockList[#_blockList] or {}
	_block.Line = last.Line or 1
	_block.X = (last.X or 0) + (last.Width or 0)

	return _block
end

local function PushTag( tag, args, txt )
	if not _tags[tag] then return end

	_tagStack[tag] = _tagStack[tag] or {}

	table.insert( _tagStack[tag], {
		Tag = tag;
		Args = args;
	} )

	_currentBlock = NewBlock( _currentBlock, txt, true )
	_currentBlock._Tags[tag] = args
	_tags[tag]:Apply( _currentBlock, args )

	table.insert( _blockList, _currentBlock )
end

local function PopTag( tag, txt )
	if not _tags[tag] then return end

	local stack = _tagStack[tag]

	if not stack then
		error( "Syntax error in markup" )
	end

	_currentBlock = NewBlock( _currentBlock.Parent, txt, false )
	for t,a in pairs( _currentBlock._Tags ) do
		_tags[t]:Apply( _currentBlock, a )
	end

	table.insert( _blockList, _currentBlock )

	table.remove( stack )
end

function Parse( txt, config )
	_blockList, _tagStack = {}, {}

	PushTag( "font", config.Font or "default" )
	PushTag( "c", string.format( "%d,%d,%d", unpackColor( config.Color or Color( 200, 200, 200 ) ) ) )

	txt = txt:gsub( "\t", "[t/]" ):gsub( "\n", "[n/]" )

	for tag, args, text in txt:gmatch( "%[%s*([/%a]+)%s*=?([^%]]*)%]([^%[]*)" ) do
		if tag:sub( 1, 1 ) == "/" then
			PopTag( tag:sub( 2 ), text )
		elseif tag:sub( -1, -1 ) == "/" then
			PushTag( tag:sub( 1, -2 ), args, text )
			PopTag( tag:sub( 1, -2 ), text )
		elseif args:sub( -1, -1 ) == "/" then
			PushTag( tag, args:sub( 1, -2 ), text )
			PopTag( tag, text )
		else
			PushTag( tag, args, text )
		end
	end

	PopTag( "c" )
	PopTag( "font" )
	
	local _width, _height = 0, 0;
	local _lines = {}
	
	for _,b in ipairs( _blockList ) do
		_lines[b.Line] = _lines[b.Line] or {}
		_lines[b.Line].W = (_lines[b.Line].W or 0) + b.Width;
		_lines[b.Line].H = math.max( _lines[b.Line].H or 0, b.Height );
	end
	for l,tbl in ipairs( _lines ) do
		_width = math.max( _width, tbl.W )
		_height = _height + tbl.H
	end
	
	print(_width, _height)

	return _mObject:Create( _blockList, _width, _height )
end

RegisterTag( "n", {
	Apply = function( self, block )
		block.Line = block.Line + 1
		block.Text = nil
		block.X = 0
		block.Width = 0
	end
} )

RegisterTag( "t", {
	Apply = function( self, block )
		local w = surface.GetTextSize( " " )
		block.Width = w * 3
		block.Text = nil
	end
} )

RegisterTag( "c", {
	Apply = function( self, block, args )
		local r, g, b = args:match( "^(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*" )
		r, g, b = tonumber( r ), tonumber( g ), tonumber( b )
		if not r or not g or not b then return end
		
		block.Color = Color( r, g, b, 255 )
	end;
	Draw = function( self, block )
		surface.SetTextColor( unpackColor( block.Color ) )
	end;
} )

RegisterTag( "font", {
	Apply = function( self, block, args )
		block.Font = (args and #args > 0) and args or "default"
		
		if block.Text and #block.Text > 0 then
			surface.SetFont( block.Font )
			block.Width, block.Height = surface.GetTextSize( block.Text )
		end
	end;
	Draw = function( self, block )
		surface.SetFont( block.Font )
	end;
} )

RegisterTag( "b", {
	Apply = function( self, block, args )
		block.Font = block.Font .. "_bold"
	end
} )

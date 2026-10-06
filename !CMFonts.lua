local curFont = 0
local custom_fonts = {}

local function get_grid_pos(i, w, h)
	return i % w, math.floor(i/w) * h
end

local _djui_hud_render_texture_tile = djui_hud_render_texture_tile
local function djui_hud_render_texture_tile(tex, x, y, scaleX, scaleY, tX, tY, tW, tH) 
	_djui_hud_render_texture_tile(tex, x, y, (tH/tW)*scaleX, scaleY, tX, tY, tW, tH)
end
local function djui_hud_render_texture(tex, x, y, scaleX, scaleY)
	djui_hud_render_texture_tile(tex, x, y, scaleX, scaleY, 0, 0, tex.width, tex.height)
end

local function hex_to_rgb(hex)
	local r, g, b, a = 0, 0, 0, 0
    local colorhex = string.gsub(hex, "#", "")
    if (string.len(colorhex) == 6) then
        r = string.sub(colorhex, 0, 2)
        g = string.sub(colorhex, 3, 4)
        b = string.sub(colorhex, 5, 6)

        r = tonumber(r, 16)
        g = tonumber(g, 16)
        b = tonumber(b, 16)
        return r, g, b, 255
    elseif (string.len(colorhex) == 8) then
        r = string.sub(colorhex, 0, 2)
        g = string.sub(colorhex, 3, 4)
        b = string.sub(colorhex, 5, 6)
        a = string.sub(colorhex, 7, 8)

        r = tonumber(r, 16)
        g = tonumber(g, 16)
        b = tonumber(b, 16)
        a = tonumber(a, 16)
        return r, g, b, a
    else
        print("Color format is invalid.")
        return
    end
end

function new_font(tex, chars, spacing, w, h)
	font = {
		tex = tex,
		chars = {}
	}
	if type(chars) == "string" and w and h then
		for i = 1, #chars do
			local letter = chars:sub(i,i)
			local x, y = get_grid_pos((i - 1) * w, tex.width, h)
			font.chars[letter] = {
				width = w,
				height = h,
				x = x,
				y = y,
				spacing = spacing or 0
			}
		end
	elseif type(chars) == "table" then
		for i, c in pairs(chars) do
			font.chars[i] = {
				x = c.x or 0,
				y = c.y or 0,
				width = c.width or 0,
				height = c.height or 0,
				spacing = c.spacing or spacing or 0
			}
		end
	end
	custom_fonts[FONT_COUNT] = font
	FONT_COUNT = FONT_COUNT + 1
	return FONT_COUNT - 1
end

local _djui_hud_set_font = djui_hud_set_font
function djui_hud_set_font(id)
	if custom_fonts[id] then
		curFont = id
	else
		_djui_hud_set_font(id)
		curFont = id
	end
end

function djui_hud_get_font(id)
	return curFont
end

local _djui_hud_set_font = djui_hud_set_font
function djui_hud_set_font(id)
	if custom_fonts[id] then
		curFont = id
	else
		_djui_hud_set_font(id)
		curFont = id
	end
end

local function print_custom_text(font, str,x,y,sX,sY)
	local offset = 0
	local height = 0
	local y = y
	for i = 1, #str do
		local letter = str:sub(i,i)
		if font.chars[letter] then
			local c = font.chars[letter]
			djui_hud_render_texture_tile(font.tex, x + offset, y, sX, sY, c.x, c.y, c.width, c.height)
			offset = offset + (c.width + c.spacing) * sX
			if c.height > height then
				height = c.height
			end
		elseif letter == " " then
			offset = offset + 8 * sX
		elseif letter == "\n" then
			offset = 0
			y = y + height * sY
		end
	end
	return y
end

local function separate_text_and_formatters(text)
    local s = ''
    local t = {}
    local f = false
    for i = 1, #text do
        local c = text:sub(i,i)
        if c == '\\' then
	        table.insert(t, {
				text = s,
				formatter = f
			})
			s = ''
            f = not f
        else
            s = s .. c
        end
    end
    table.insert(t, {
		text = s,
		formatter = f
	})
    return t
end

local _djui_hud_print_text = djui_hud_print_text
function djui_hud_print_text(str, x, y, sX, sY)
	local col = djui_hud_get_color()
	local sY = sY or sX
	local y = y
	if custom_fonts[curFont] then
		local x = x
		local splitText = separate_text_and_formatters(str)
		for i = 1, #splitText do
			local text = splitText[i].text
			local isFormatter = splitText[i].formatter
			if isFormatter then
				local formatterType = text:sub(1,1)
				local realText = text:sub(2,#text)
				if formatterType == "#" then
					local r, g, b = hex_to_rgb(realText)
					if r and g and b then
						djui_hud_set_color(r * (col.r/255), g * (col.g/255), b * (col.b/255), col.a)
					end
				end
			else
				local w = djui_hud_measure_text(text)
				y = print_custom_text(custom_fonts[curFont],text,x,y,sX,sY)
				x = x + (w * sX)
			end
		end
	else
		_djui_hud_print_text(str,x,y,sX,sY)
	end
end

function custom_measure(font, str)
	local width = 0
	local height = 0
	for i = 1, #str do
		local letter = str:sub(i,i)
		if font.chars[letter] then
			local c = font.chars[letter]
			width = width + c.width + c.spacing
			if c.height > height then
				height = c.height
			end
		elseif letter == " " then
			width = width + 8
		end
	end
	return width, height
end

local function get_lines(str)
	local lines = {}
	for line in (str .. "\n"):gmatch("(.-)\r?\n") do
		table.insert(lines, line)
	end
	return lines
end

local _djui_hud_measure_text = djui_hud_measure_text
function djui_hud_measure_text(str)
	if custom_fonts[curFont] then
		local c = {w = 0, h = 0}
		local lines = get_lines(get_uncolored_string(str))
		for i = 1, #lines do
			local v = lines[i]
			local ww, hh = custom_measure(custom_fonts[curFont], v)
			if ww > c.w then
				c.w = ww
			end
			c.w = c.w + 1
			c.h = c.h + hh
		end
		return c.w, c.h
	else
		local w, h = _djui_hud_measure_text(str)
		return w,h
	end
end
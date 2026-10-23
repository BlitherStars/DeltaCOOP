function djui_hud_render_outlined_rect(x, y, width, height, borderColor, borderSize)
	local defaultColor = djui_hud_get_color()

	local x = x - (borderSize/2)
	local y = y - (borderSize/2)
	local width = width + borderSize
	local height = height + borderSize
	
	djui_hud_set_color(defaultColor.r, defaultColor.g, defaultColor.b, defaultColor.a)
	djui_hud_render_rect(x, y, (borderSize/2), height)
	djui_hud_render_rect(x + width - (borderSize/2), y, (borderSize/2), height)
	djui_hud_render_rect(x + (borderSize/2), y, width - borderSize, (borderSize/2))
	djui_hud_render_rect(x + (borderSize/2), y + height - (borderSize/2), width - borderSize, (borderSize/2))

	x = x + (borderSize/2)
	y = y + (borderSize/2)
	width = width - borderSize
	height = height - borderSize

	djui_hud_set_color(borderColor[1], borderColor[2], borderColor[3], borderColor[4])
	djui_hud_render_rect(x, y, (borderSize/2), height)
	djui_hud_render_rect(x + width - (borderSize/2), y, (borderSize/2), height)
	djui_hud_render_rect(x + (borderSize/2), y, width - borderSize, (borderSize/2))
	djui_hud_render_rect(x + (borderSize/2), y + height - (borderSize/2), width - borderSize, (borderSize/2))
	
	djui_hud_set_color(defaultColor.r, defaultColor.g, defaultColor.b, defaultColor.a)
	djui_hud_render_rect(x + (borderSize/2), y + (borderSize/2), width - borderSize, height - borderSize)
end

function djui_hud_print_outlined_text(text, x, y, scale, outlineDarkness, borderScale)
	local outlineDarkness = outlineDarkness or 0
	local offset = (borderScale or 2) * scale
	local color = djui_hud_get_color()
	
	djui_hud_set_color(color.r * outlineDarkness, color.g * outlineDarkness, color.b * outlineDarkness, color.a)
	djui_hud_print_text(text, x - offset, y, scale)
	djui_hud_print_text(text, x + offset, y, scale)
	djui_hud_print_text(text, x, y - offset, scale)
	djui_hud_print_text(text, x, y + offset, scale)
	djui_hud_print_text(text, x - offset / 2, y - offset / 2, scale)
	djui_hud_print_text(text, x - offset / 2, y + offset / 2, scale)
	djui_hud_print_text(text, x + offset / 2, y + offset / 2, scale)
	djui_hud_print_text(text, x + offset / 2, y - offset / 2, scale)
	
	djui_hud_set_color(color.r, color.g, color.b, color.a)
	djui_hud_print_text(text, x, y, scale)
end

local djui_hud_render_texture_real_tile = djui_hud_render_texture_tile

function djui_hud_render_texture_tile(tex, x, y, scaleX, scaleY, tX, tY, tW, tH) 
	djui_hud_render_texture_real_tile(tex, x, y, (tH/tW)*scaleX, scaleY, tX, tY, tW, tH)
end

function djui_hud_render_texture(tex, x, y, scaleX, scaleY)
	djui_hud_render_texture_tile(tex, x, y, scaleX, scaleY, 0, 0, tex.width, tex.height)
end

function djui_hud_render_texture_rect(tex, x, y, w, h, cornerSize)
	local w, h = math.max(w, cornerSize * 2), math.max(h, cornerSize * 2)
	djui_hud_render_texture_tile(tex,
		x, y,
		1, 1,
		0, 0,
		cornerSize, cornerSize
	)
	djui_hud_render_texture_tile(tex,
		x + cornerSize, y,
		(w - (cornerSize * 2)) / (tex.width - (cornerSize * 2)), 1,
		cornerSize, 0,
		(tex.width - (cornerSize * 2)), cornerSize
	)
	djui_hud_render_texture_tile(tex,
		x + w - cornerSize, y,
		1, 1,
		tex.width - cornerSize, 0,
		cornerSize, cornerSize
	)
	djui_hud_render_texture_tile(tex,
		x, y + cornerSize,
		1, (h - (cornerSize * 2)) / (tex.height - (cornerSize * 2)),
		0, cornerSize,
		cornerSize, (tex.height - (cornerSize * 2))
	)
	djui_hud_render_texture_tile(tex,
		x + w - cornerSize, y + cornerSize,
		1, (h - (cornerSize * 2)) / (tex.height - (cornerSize * 2)),
		tex.width - cornerSize, cornerSize,
		cornerSize, (tex.height - (cornerSize * 2))
	)
	djui_hud_render_texture_tile(tex,
		x + w - cornerSize, y + h - cornerSize,
		1, 1,
		tex.width - cornerSize, tex.height - cornerSize,
		cornerSize, cornerSize
	)
	djui_hud_render_texture_tile(tex,
		x, y + h - cornerSize,
		1, 1,
		0, tex.height - cornerSize,
		cornerSize, cornerSize
	)
	djui_hud_render_texture_tile(tex,
		x + cornerSize, y + h - cornerSize,
		(w - (cornerSize * 2)) / (tex.width - (cornerSize * 2)), 1,
		cornerSize, tex.height - cornerSize,
		(tex.width - (cornerSize * 2)), cornerSize
	)
	djui_hud_render_texture_tile(tex,
		x + cornerSize, y + cornerSize,
		(w - (cornerSize * 2)) / (tex.width - (cornerSize * 2)), (h - (cornerSize * 2)) / (tex.height - (cornerSize * 2)),
		cornerSize, cornerSize,
		(tex.width - (cornerSize * 2)), (tex.height - (cornerSize * 2))
	)
end

function wrap(var, min, max)
    if var > max then var = min end
    if var < min then var = max end
    return var
end

function nextDialog()
	dialog.chars = 0
	dialog.num = dialog.num + 1
end

musicStream = nil

function play_overworld_music(stream)
    if musicStream ~= stream then
    	stop_overworld_music()
	    if stream then
		    audio_stream_play(stream, false, 0.6)
			audio_stream_set_looping(stream, true)
		    musicStream = stream
		end
    end
end

function stop_overworld_music()
    if musicStream then
    	audio_stream_stop(musicStream)
	    musicStream = nil
    end
end

function table.indexOf(t, id)
	for i, v in pairs(t) do
		if v == id then
			return i
		end
	end
	return -1
end

function table.contains(t, id)
	for i, v in pairs(t) do
		if v == id then
			return true
		end
	end
	return false
end

function get_vessel_from_str(name)
	if type(name) == "string" then
		local charNames = {}
        for _, v in pairs(charList) do
        	table.insert(charNames, v.name)
        end	        
        return table.indexOf(charNames, mod_storage_load("character"))
	else
		return name
	end
end

function overlap(a, b, steps)
	local points = getPoints(a)
	for i = 1, #points do
		for l = 0, (steps or 10) do
			local pa = points[i]
			local pb = points[i + 1] or points[1]
			local x = l / (steps or 10)
			local pos = {
				math.lerp(pa[1], pb[1], x),
				math.lerp(pa[2], pb[2], x)
			}
			if (pos[1] >= b.x + 1 and pos[1] <= (b.x + b.width - 1) and pos[2] >= b.y + 1 and pos[2] <= (b.y + b.height - 1)) then
				return true;
			end
		end
	end
	return false;
end

function overlapPolygon(a, b, steps)
	local points = a.polygon
	for i = 1, #points do
		for l = 0, (steps or 10) do
			local pa = points[i]
			pa.x = a.x + pa.x
			pa.y = a.y + pa.y
			local pb = points[i + 1] or points[1]
			pb.x = pb.x + a.x
			pb.y = pb.y + a.y
			local x = l / (steps or 10)
			local pos = {
				math.lerp(pa.x, pb.x, x),
				math.lerp(pa.y, pb.y, x)
			}
			if (pos[1] >= b.x and pos[1] <= (b.x + b.width) and pos[2] >= b.y and pos[2] <= (b.y + b.height)) then
				return true;
			end
		end
	end
	return false;
end

function getPoints(obj)
    local rad = (obj.angle or 0) * (math.pi / 180)
    local cos, sin = math.cos(rad), math.sin(rad)
    
    local points = {
		{0, 0},
		{obj.width, 0},
		{obj.width, obj.height},
		{0, obj.height}
	}

    local actualPoints = {}

    for i = 1, #points do
    	local p = points[i]
        local r = {
			p[1] * cos - p[2] * sin,
			p[1] * sin + p[2] * cos
		}
        table.insert(actualPoints, {
			obj.x + r[1],
			obj.y + r[2]
		})
    end

    return actualPoints
end

function change_map(map, spawn)
	local rData = maps[map] or maps[entryMap]
	inTransition = true
	lastSpawn = spawn
	dialog.num = -1
	tween_start("transIn", 0, 255, 0.25, "linear", function(v) transitionAlpha = v end, function()
		s.map = map
		for i, layer in pairs(rData.layers) do
			if layer.type == "objectgroup" then
				for ii, obj in pairs(layer.objects) do
					if obj.name == "enemy" then
						if obj.encountered then
							obj.properties["alpha"] = (obj.oldalpha or 1)
							obj.encountered = false
						else
							obj.oldalpha = obj.properties["alpha"]
						end
					end
				end
			end
		end
        local spawn = get_map_spawn_pos(rData, spawn)
        s.x = spawn.x - s.bW/2
        s.y = spawn.y - s.bH/2
        inTransition = false
        if s.dead and s.hp <= 0 then
	        s.hp = s.maxHP
	        s.dead = false
			s.anim = lastAnim
			s.walking = true
        end
        ldx = 0
		tween_start("transOut", 255, 0, 0.25, "linear", function(v) transitionAlpha = v end)
	end)
end

function playAnim(anim, force)
	local sprites = charList[s.character].sprites[s.costume]
	if sprites[anim] and (s.anim ~= anim or force) then
		anim_timer = 0
		s.anim = anim
		s.frame = 1
	end
end

easeTypes = {
	["sineIn"] = IN_SINE, ["sineOut"] = OUT_SINE, ["sineInOut"] = IN_OUT_SINE, ["sineOutIn"] = OUT_IN_SINE,
	["quadIn"] = IN_QUAD, ["quadOut"] = OUT_QUAD, ["quadInOut"] = IN_OUT_QUAD, ["quadOutIn"] = OUT_IN_QUAD,
	["cubicIn"] = IN_CUBIC, ["cubicOut"] = OUT_CUBIC, ["cubicInOut"] = IN_OUT_CUBIC, ["cubicOutIn"] = OUT_IN_CUBIC,
	["quartIn"] = IN_QUART, ["quartOut"] = OUT_QUART, ["quartInOut"] = IN_OUT_QUART, ["quartOutIn"] = OUT_IN_QUART,
	["quintIn"] = IN_QUINT, ["quintOut"] = OUT_QUINT, ["quintInOut"] = IN_OUT_QUINT, ["quintOutIn"] = OUT_IN_QUINT,
	["expoIn"] = IN_EXPO, ["expoOut"] = OUT_EXPO, ["expoInOut"] = IN_OUT_EXPO, ["expoOutIn"] = OUT_IN_EXPO,
	["circIn"] = IN_CIRC, ["circOut"] = OUT_CIRC, ["circInOut"] = IN_OUT_CIRC, ["circOutIn"] = OUT_IN_CIRC,
	["backIn"] = IN_BACK, ["backOut"] = OUT_BACK, ["backInOut"] = IN_OUT_BACK, ["backOutIn"] = OUT_IN_BACK,
	["elasticIn"] = IN_ELASTIC, ["elasticOut"] = OUT_ELASTIC, ["elasticInOut"] = IN_OUT_ELASTIC, ["elasticOutIn"] = OUT_IN_ELASTIC,
	["bounceIn"] = IN_BOUNCE, ["bounceOut"] = OUT_BOUNCE, ["bounceInOut"] = IN_OUT_BOUNCE, ["bounceOutIn"] = OUT_IN_BOUNCE,
}

local tweens = {}
function tween_start(name, from, to, duration, easingType, updateCallback, endCallback)
	tweens[name] = {
		points = {from, to},
		elapsed = 0,
		length = math.floor(duration * 30),
		value = from,
		updateCallback = updateCallback,
		endCallback = endCallback,
		ease = easingType or "linear",
		paused = false,
	}
	return tweens[name]
end
function tween_cancel(name) tweens[name] = nil end
function tween_pause(name) tweens[name].paused = true end
function tween_resume(name) tweens[name].paused = false end
function tween_get(name) return tweens[name] end

local function tween_update()
	for index in pairs(tweens) do
		if tweens[index] and not tweens[index].paused then
			tweens[index].elapsed = tweens[index].elapsed + 1
			if easeTypes[tweens[index].ease] then
				tweens[index].value = math.tween(easeTypes[tweens[index].ease], tweens[index].points[1], tweens[index].points[2], tweens[index].elapsed / tweens[index].length) 
			else
				tweens[index].value = math.lerp(tweens[index].points[1], tweens[index].points[2], tweens[index].elapsed / tweens[index].length)
			end
			if tweens[index].updateCallback and tweens[index].value ~= nil then
				tweens[index].updateCallback(tweens[index].value)
			end
			if tweens[index].elapsed >= tweens[index].length then
				if tweens[index].endCallback and tweens[index].value ~= nil then
					tweens[index].endCallback(tweens[index])
				end
				tweens[index] = nil
			end
		end
	end
end
hook_event(HOOK_UPDATE, tween_update)

local timers = {}
function timer_start(name, duration, callback)
	timers[name] = {
		time = math.floor(duration*30),
		callback = callback,
		paused = false,
	}
	return timers[name]
end
function timer_cancel(name) timers[name] = nil end
function timer_pause(name) timers[name].paused = true end
function timer_resume(name) timers[name].paused = false end
function timer_get(name) return timers[name] end

local function timer_update()
	for index in pairs(timers) do
		if timers[index] ~= nil and not timers[index].paused then
			timers[index].time = timers[index].time - 1
			if timers[index].time <= 0 then
				if timers[index].callback ~= nil then
					timers[index].callback(timers[index])
				end
				timers[index] = nil
			end
		end
	end
end
hook_event(HOOK_UPDATE, timer_update)

function hex_to_rgb(hex)
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
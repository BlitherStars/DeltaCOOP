local djui_hud_render_texture_real_tile = djui_hud_render_texture_tile

function djui_hud_render_texture_tile(tex, x, y, scaleX, scaleY, tX, tY, tW, tH) 
	djui_hud_render_texture_real_tile(tex, x, y, (tH/tW)*scaleX, scaleY, tX, tY, tW, tH)
end

function djui_hud_render_texture(tex, x, y, scaleX, scaleY)
	djui_hud_render_texture_tile(tex, x, y, scaleX, scaleY, 0, 0, tex.width, tex.height)
end

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
	    audio_stream_play(stream, false, 0.6)
		audio_stream_set_looping(stream, true)
	    musicStream = stream
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
			if (pos[1] >= b.x and pos[1] <= (b.x + b.width) and pos[2] >= b.y and pos[2] <= (b.y + b.height)) then
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
			pa.x = pa.x + a.x
			pa.y = pa.y + a.y
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
	local rData = maps[map] or maps["kristalcastle1"]
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
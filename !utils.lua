local djui_hud_render_texture_real_tile = djui_hud_render_texture_tile

function djui_hud_render_texture_tile(tex, x, y, scaleX, scaleY, tX, tY, tW, tH) 
	djui_hud_render_texture_real_tile(tex, x, y, (tH/tW)*scaleX, scaleY, tX, tY, tW, tH)
end

function djui_hud_render_texture(tex, x, y, scaleX, scaleY)
	djui_hud_render_texture_tile(tex, x, y, scaleX, scaleY, 0, 0, tex.width, tex.height)
end

function wrap(var, min, max)
    if var > max then var = min end
    if var < min then var = max end
    return var
end

musicStream = nil

function play_overworld_music(stream)
    if musicStream ~= stream then
    	stop_overworld_music()
	    audio_stream_play(stream, false, 1)
		audio_stream_set_looping(stream, true)
		audio_stream_set_volume(stream, 0.6)
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
	local points = {
		{a.x, a.y},
		{a.x+a.width, a.y},
		{a.x+a.width, a.y+a.height},
		{a.x, a.y+a.height}
	}
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

function change_map(map, spawn)
	inTransition = true
	lastSpawn = spawn
	tween_start("transIn", 0, 255, 0.25, "linear", function(v) transitionAlpha = v end, function()
		s.map = map
		local rData = maps[map] or maps["castle1"]
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
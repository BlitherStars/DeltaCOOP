local player_chats = {}
local anim_timer = 0
local coolY = -48 
local ldx = 0

local charsTimer = {
	["."] = 0.125,
	[","] = 0.25,
	["!"] = 0.25,
	["?"] = 0.25,
}

lastAnim = "down"
lastSpawn = "spawn"

inTransition = false
transitionAlpha = 0

charScale = 1
mapScale = 0.5

camPos = {x = 0, y = 0}
freezeControls = false

local function on_chat_message(m, message)
    if m.playerIndex < MAX_PLAYERS then
        player_chats[m.playerIndex] = {
            text = message,
            timer = 30 * 4,
            chars = 0
        }
    end
end

local function render_overworld()
	freezeControls = menu ~= ""  or inTransition or s.dead
	
	if not s.deltarune then
		s.deltarune = true
		
        s.x = spawn_x or 0
        s.y = spawn_y or 0
        s.anim = "down"
        s.walking = false
        s.frame = 1
        
        s.attackCooldown = 0
        
        local charNames = {}
        for _, v in pairs(charList) do
        	table.insert(charNames, v.name)
        end
        
        s.character = math.max(table.indexOf(charNames, mod_storage_load("character")), 1)
        
        s.exp = mod_storage_exists("exp") and mod_storage_load_number("exp") or 0
        s.maxHP = math.floor(90 * (1 + (s.exp / 5000)))
        s.hp = s.maxHP
        
        s.costume = 1
        s.map = "kristalcastle1"
        s.bW = 0
        s.bH = 0
        
        local char = charList[s.character]
        local map = maps[s.map] or maps["kristalcastle1"]
        local spawn = get_map_spawn_pos(map, "spawn")
        s.x = spawn.x - char.boxW/2
        s.y = spawn.y - char.boxH/4
        
        s.flipX = false
    end
    
    s.attackCooldown = s.attackCooldown - 1
    
    if maps[s.map] == nil then
    	s.map = "map1"
    end
    
    local char = charList[s.character]
    local sprites = char.sprites[s.costume]
    local map = maps[s.map] or maps["map1"]
    if map.properties["music"] then
 	   play_overworld_music(map.properties["music"])
    else
    	stop_overworld_music()
    end
    
    local rW, rH = map.width * map.tilewidth * mapScale, map.height * map.tileheight * mapScale
	
    if not freezeControls and (m.controller.buttonPressed & L_TRIG) ~= 0 then
        s.costume = s.costume + 1
        audio_stream_play(snd_menumove, false, 1)
    end
    
    if s.costume > #char.sprites then
		s.costume = 1
	elseif s.costume < 1 then
		s.costume = #char.sprites
	end
	
    local box_w = char.boxW or 29
    local box_h = (char.boxH or 29) / 2
    
    if s.bW > 0 or s.bH > 0 then
    	s.x = s.x + ((s.bW - box_w) / 2)
    	s.y = s.y + (s.bH - box_h)
    end
    
    s.bW = box_w * charScale
    s.bH = box_h * charScale

    local stick_x = m.controller.stickX
    local stick_y = m.controller.stickY
    local dx = 0
    local dy = 0

    if not freezeControls then
        if useDpad then
            if (m.controller.buttonDown & L_JPAD) ~= 0 then dx, ldx = -1, -1 elseif (m.controller.buttonDown & R_JPAD) ~= 0 then dx, ldx = 1, 1 end
            if (m.controller.buttonDown & U_JPAD) ~= 0 then dy = -1 elseif (m.controller.buttonDown & D_JPAD) ~= 0 then dy = 1 end
        else
            if stick_x > 20 then dx, ldx = 1, 1 elseif stick_x < -20 then dx, ldx = -1, -1 end
            if stick_y > 20 then dy = -1 elseif stick_y < -20 then dy = 1 end
        end
    end

    local anim = s.anim
    local anim_frame = s.frame
	
	if s.walking then
		s.flipX = false
	    if dy < 0 then
	        anim = "up"
	    elseif dy > 0 then
	        anim = "down"
	    elseif dx > 0 then
	        anim = "right"
	    elseif dx < 0 then
	        anim = "left"
	    end
		lastAnim = anim
    end
    
    if sprites[anim] == nil then
		s.walking = true
		anim = lastAnim
	end
	
	if not freezeControls and (m.controller.buttonDown & X_BUTTON) ~= 0 and sprites["attack"] and s.attackCooldown <= 0 then
		s.walking = false
		s.attackCooldown = 30
		if ldx < 0 or anim == "left" then
			s.flipX = true
		end
		anim = "attack"
		anim_frame = 1
		anim_timer = 0
		
		if sprites[anim].snd then
			audio_stream_play(sprites[anim].snd, true, 1)
			network_send(true, {
				type = "player",
				character = s.character,
				costume = s.costume,
				anim = anim,
				map = s.map
			})
		else
			audio_stream_play(snd_slash, true, 1)
			network_send(true, {
				type = "attack",
				map = s.map
			})
		end
		
		for i = 0, MAX_PLAYERS - 1 do
	    	local ss = gPlayerSyncTable[i]
	        if ss ~= s and gNetworkPlayers[i].connected and ss.map == s.map and overlap({x = s.x - (box_w * (s.flipX and 1 or 0)), y = s.y, width = box_w*2, height = box_h}, {x = ss.x, y = ss.y, width = ss.bW, height = ss.bH}) then
				ss.hp = ss.hp - math.random(5, 10) * (1 + (s.exp / 5000))
				audio_stream_play(snd_damage, true, 1)
				network_send(true, {
					type = "dmg",
					map = s.map
				})
				if ss.hp <= 0 and not ss.dead then
					s.exp = s.exp + math.random(50, 150)
					local newHP = math.floor(90 * (1 + (s.exp / 5000)))
					local hpDiff = newHP - s.maxHP
					s.maxHP = newHP
        			s.hp = s.hp + hpDiff
					ss.dead = true
					mod_storage_save_number("exp", s.exp)
				end
			end
		end
	end
	
	if s.dead and not inTransition then
		if s.hp <= 0 then
			s.walking = false
			timer_start("deadTimer", 1, function()
				change_map(s.map, lastSpawn or "spawn")
			end)
			if sprites["defeat"] then
				anim = "defeat"
				s.anim = "defeat"
			end
			inTransition = true
		else
			s.dead = false
		end
	end
	
    local run = (m.controller.buttonDown & B_BUTTON) ~= 0
    if autoRun then
    	run = not run
    end
    
    local discard = {
		["up"] = true,
		["down"] = true,
		["left"] = true,
		["right"] = true,
	}
	local keys = {
		L_JPAD,
		D_JPAD,
		U_JPAD,
		R_JPAD
	}
	local curKey = 1
	for i, v in pairs(sprites) do
		if not discard[i] and not (v.other == true) and keys[curKey] and not freezeControls and not useDpad then
			if (m.controller.buttonPressed & keys[curKey]) ~= 0 then
				s.walking = false
				anim = i
				if sprites[anim].snd then
					audio_stream_play(sprites[anim].snd, true, 1)
					network_send(true, {
						type = "player",
						character = s.character,
						costume = s.costume,
						anim = anim,
						map = s.map
					})
				end
			end
			curKey = curKey + 1
		end
	end
    
    local max_frames = sprites[anim].length or 4
    local fpsDist = (sprites[anim].fps or 12) / 30
    local loop = sprites[anim].loop or false
    local persistent = sprites[anim].persistent or false
    local repeatAmount = sprites[anim].repeatAmount or 1
    
	if s.walking then
	    if dx == 0 and dy == 0 then
	        anim_frame = 1
	        anim_timer = 0
	    else
	        anim_timer = anim_timer + (fpsDist * (run and 0.5 or 0.25))
	        anim_frame = 1 + (math.floor(anim_timer) % max_frames)
	    end
    else
    	anim_timer = anim_timer + fpsDist
	    anim_frame = 1 + ((loop or repeatAmount > 1) and (math.floor(anim_timer) % max_frames) or math.min(math.floor(anim_timer), max_frames))
	    if not loop and not persistent and anim_timer >= (max_frames * repeatAmount) then
			s.walking = true
			anim = lastAnim
		end
		if (loop or persistent) and (m.controller.buttonPressed & A_BUTTON) ~= 0 then
			s.walking = true
			anim = lastAnim
		end
    end

    local speed = 2
    if run then speed = 3 end
    if not s.walking then speed = 0 end

    local nx, ny = s.x, s.y

    nx = nx + (dx * speed)
    ny = ny + (dy * speed)
	
	for lay_id, layer in pairs(map.layers) do
		if layer.type == "objectgroup" then
			if layer.name == "collision" then
				for obj_id, obj in pairs(layer.objects) do
					if overlap({x = nx, y = s.y, width = box_w, height = box_h}, {x = obj.x * mapScale, y = obj.y * mapScale, width = obj.width * mapScale, height = obj.height * mapScale}) then
						nx = s.x
	    			end
	  			  if overlap({x = s.x, y = ny, width = box_w, height = box_h}, {x = obj.x * mapScale, y = obj.y * mapScale, width = obj.width * mapScale, height = obj.height * mapScale}) then
						ny = s.y
	    			end
				end
			else
				for obj_id, obj in pairs(layer.objects) do
					if obj.name == "transition" and not inTransition and overlap({x = s.x, y = s.y, width = box_w, height = box_h}, {x = obj.x * mapScale, y = obj.y * mapScale, width = obj.width * mapScale, height = obj.height * mapScale}) then
						change_map(obj.properties["map"], obj.properties["marker"])
	    			end
					if obj.name == "sprite" then
						table.insert(render_queue, {
			                type = "sprite",
			                x = ((obj.x + layer.offsetx) or 0) * mapScale,
			                y = ((obj.y + layer.offsety) or 0) * mapScale,
			                sprite = {
								texture = obj.properties["texture"],
								length = 1,
								fps = 12 * obj.properties["speed"],
							},
							scaleX = obj.properties["scalex"] * mapScale,
							scaleY = obj.properties["scaley"] * mapScale,
							scrollX = layer.parallaxx or 1,
							scrollY = layer.parallaxy or 1,
			                frame = 1,
			                bW = (obj.width or 0) * mapScale,
			                bH = (obj.height or 0) * mapScale,
			                flipX = ss.flipX or false
			            })
						if overlap({x = nx, y = s.y, width = box_w, height = box_h}, {x = obj.x * mapScale, y = obj.y * mapScale, width = obj.width * mapScale, height = obj.height * mapScale}) then
							nx = s.x
		    			end
		  			  if overlap({x = s.x, y = ny, width = box_w, height = box_h}, {x = obj.x * mapScale, y = obj.y * mapScale, width = obj.width * mapScale, height = obj.height * mapScale}) then
							ny = s.y
		    			end
					end
				end
			end
		end
	end
	
	if nx < - box_w/2 then nx = - box_w/2 end
    if nx > rW - box_w/2 then nx = rW - box_w/2 end
    if ny < - box_w/2 then ny = - box_w/2 end
    if ny > rH - box_h/2 then ny = rH - box_h/2 end
	
	if not inTransition then
	    s.x = nx
	    s.y = ny
	    s.anim = anim
	    s.frame = anim_frame
    end

    djui_hud_set_resolution(RESOLUTION_N64)
    local sW = 320
    local sH = djui_hud_get_screen_height()
    
    local boundX = math.max(rW - sW, 0)
    local boundY = math.max(rH - sH, 0)
    camPos.x = math.min(math.max(s.x - ((sW - box_w) / 2), 0), boundX) - (screenOffset / 2)
    camPos.y = math.min(math.max(s.y - ((sH - (box_h / 2)) / 2), 0), boundY)

    djui_hud_set_color(0, 0, 0, 255)
    djui_hud_render_rect(-4, -4, djui_hud_get_screen_width() + 8, sH + 8)

    local render_queue = {}

    for i = 0, MAX_PLAYERS - 1 do
    	local ss = gPlayerSyncTable[i]
        if gNetworkPlayers[i].connected and ss.map == s.map and ss.deltarune then
            table.insert(render_queue, {
                type = "player",
                id = gMarioStates[i].playerIndex or 0,
                x = ss.x or spawn_x,
                y = ss.y or spawn_y,
                anim = ss.anim or "down",
                frame = ss.frame or 1,
                character = ss.character or 1,
                costume = ss.costume or 1,
                name = gNetworkPlayers[i].name or "UNKNOWN",
                bW = ss.bW or 0,
                bH = ss.bH or 0,
                flipX = ss.flipX or false,
                hp = ss.hp / ss.maxHP
            })
        end
    end

    table.sort(render_queue, function(a, b)
        return a.y < b.y
    end)
    
    for i, layer in pairs(map.layers) do
    	if layer.type == "tilelayer" then
	    	local default = {{firstgid = 1, name = "castle"}}
	    	draw_tile_layer(layer, map.tilesets or default, layer.x - camPos.x, layer.y - camPos.y, mapScale)
	    end
		if layer.type == "objectgroup" and debug then
			djui_hud_set_color(255, 255, 255, 32)
			for ii, obj in pairs(layer.objects) do
				djui_hud_render_rect((obj.x * mapScale) - camPos.x, (obj.y * mapScale) - camPos.y, obj.width * mapScale, obj.height  * mapScale)
			end
			djui_hud_set_color(255, 255, 255, 255)
		end
	end
	
    for _, ent in ipairs(render_queue) do
        local screen_x = (ent.x - camPos.x) * (ent.scrollX or 1)
        local screen_y = (ent.y - camPos.y) * (ent.scrollY or 1)
        local sprite = nil
        local pw, ph = ent.bW or 0, ent.bH or 0
        
        if ent.sprite then
        	sprite = ent.sprite
        else
	        local char = charList[ent.character] or charList[1]
	        local active_sprites = char.sprites[ent.costume] or char.sprites[1]
	        
	        if active_sprites and active_sprites[ent.anim] then
	            sprite = active_sprites[ent.anim]
	        end
        end
        
        local hasTex = sprite and sprite.texture and sprite.texture.width > 0 and sprite.texture.height > 0
        local scaleX = ent.scaleX or (ent.scale or (charList[ent.character or -1].scale ~= nil and (charList[ent.character or -1].scale * charScale) or 1))
        local scaleY = ent.scaleY or (ent.scale or (charList[ent.character or -1].scale ~= nil and (charList[ent.character or -1].scale * charScale) or 1))
        local alpha = math.max(ent.alpha or (charList[ent.character or -1].alpha or 1), 0.25)
        djui_hud_set_color(255, 255, 255, 255 * alpha)
        
        if hasTex then
        	local spr_w = (sprite.width or (sprite.texture.width / (sprite.length or 4)))
            local tex_w = spr_w * scaleX
            local tex_h = sprite.texture.height * scaleY
            local center_x = (screen_x + (pw - tex_w) / 2) + (tex_w * (ent.flipX and 1 or 0))
            local center_y = screen_y + (ph - tex_h)
            djui_hud_render_texture_tile(sprite.texture, center_x + ((sprite.offsetX or 0) * scaleX * (ent.flipX and -1 or 1)), center_y + ((sprite.offsetY or 0) * scaleY),  scaleX * (ent.flipX and -1 or 1), scaleY, spr_w * (math.min(ent.frame, sprite.length or 4) - 1), 0, spr_w, sprite.texture.height)
        end
        
        if debug or not hasTex then
        	djui_hud_set_color(255, 255, 255, 32)
        	djui_hud_render_rect(screen_x, screen_y, pw, ph)
        	djui_hud_set_color(255, 255, 255, 255)
        end
        
        djui_hud_set_font(FONT_SPECIAL)
  	  local text_scale = 0.3 * charScale
        local text_width = djui_hud_measure_text(ent.name) * text_scale
        local text_x = screen_x + (pw / 2) - (text_width / 2)
        local text_y = screen_y - ph - ((ent.hp and ent.hp < 1) and 14 or 8)
        
        local out_px = 1
        if useNametags and ent.type == "player" then
	        djui_hud_set_color(0, 0, 0, 255)
	        djui_hud_print_text(ent.name, text_x - out_px, text_y, text_scale)
	        djui_hud_print_text(ent.name, text_x + out_px, text_y, text_scale)
	        djui_hud_print_text(ent.name, text_x, text_y - out_px, text_scale)
	        djui_hud_print_text(ent.name, text_x, text_y + out_px, text_scale)
	        
	        djui_hud_set_color(255, 255, 255, 255)
	        djui_hud_print_text(ent.name, text_x, text_y, text_scale)
		end
		
		if ent.hp and ent.hp < 1 and ent.id ~= m.playerIndex then
		    djui_hud_set_color(128, 0, 0, 255)
			djui_hud_render_rect(text_x + (text_width - 32) / 2, text_y + 10, 32, 4)
			djui_hud_set_color(255, 255, 0, 255)
			djui_hud_render_rect(text_x + (text_width - 32) / 2, text_y + 10, 32 * ent.hp, 4)
		end
		
        if ent.type == "player" and player_chats[ent.id] ~= nil then
            local chat = player_chats[ent.id]
            if chat.chars >= string.len(chat.text) then
            	chat.timer = chat.timer - 1
            end
            if chat.timer <= 0 then
                player_chats[ent.id] = nil
            else
                local old_chars = math.floor(chat.chars)
                chat.chars = chat.chars + (charsTimer[chat.text:sub(math.floor(chat.chars), math.floor(chat.chars))] or 0.5)
                local max_chars = string.len(chat.text)
                if chat.chars > max_chars then chat.chars = max_chars end
                local new_chars = math.floor(chat.chars)

				local char = charList[ent.character]
                if new_chars > old_chars then
                    local play_snd = char.snd or snd_txt
                    if type(play_snd) == "table" then
                    	play_snd = play_snd[math.random(1, #play_snd)]
                    end
                    audio_stream_play(play_snd, true, 1)
                end

                local display_text = string.sub(chat.text, 1, new_chars)
                
                local lines = {}
                local current_str = display_text
                while string.len(current_str) > 30 do
                    local break_point = 30
                    local found_space = false
                    for j = 30, 15, -1 do
                        if string.sub(current_str, j, j) == " " then
                            break_point = j
                            found_space = true
                            break
                        end
                    end
                    if found_space then
                        table.insert(lines, string.sub(current_str, 1, break_point - 1))
                        current_str = string.sub(current_str, break_point + 1)
                    else
                        table.insert(lines, string.sub(current_str, 1, 30))
                        current_str = string.sub(current_str, 31)
                    end
                end
                
                if string.len(current_str) > 0 then
                    table.insert(lines, current_str)
                elseif #lines == 0 then
                    table.insert(lines, "")
                end

                local max_box_width = 0
                for _, l in ipairs(lines) do
                    local lw = djui_hud_measure_text(l) * text_scale
                    if lw > max_box_width then max_box_width = lw end
                end

                local out_border = 1 * charScale
                local in_border = 1 * charScale
                local total_border = out_border + in_border
                local pad = 2 * charScale
                local line_height = 8 * charScale
                
                local box_w_chat = max_box_width + (pad * 2) + (total_border * 2)
                local box_h_chat = (line_height * #lines) + (total_border * 2)
                local box_x = screen_x + (pw / 2) - (box_w_chat / 2)
                local box_y = text_y - box_h_chat - (2 * charScale)

                djui_hud_set_color(0, 0, 0, 255)
                djui_hud_render_rect(box_x, box_y, box_w_chat, box_h_chat)
                
                djui_hud_set_color(255, 255, 255, 255)
                djui_hud_render_rect(box_x + out_border, box_y + out_border, box_w_chat - (out_border * 2), box_h_chat - (out_border * 2))

                djui_hud_set_color(0, 0, 0, 255)
                djui_hud_render_rect(box_x + total_border, box_y + total_border, box_w_chat - (total_border * 2), box_h_chat - (total_border * 2))

                local text_render_x = box_x + total_border + pad
                
                for line_idx, l in ipairs(lines) do
                    local text_render_y = box_y + total_border - (1 * charScale) + ((line_idx - 1) * line_height)
                    djui_hud_set_color(255, 255, 255, 255)
                    djui_hud_print_text(l, text_render_x, text_render_y, text_scale)
                end
            end
        end
    end
    
    if not is_game_paused() then
	    local x = (screenOffset / 2) + 6
	    coolY = math.lerp(coolY, s.hp < s.maxHP and 0 or -26, 0.2)
	    local f = s.hp / s.maxHP
	    djui_hud_set_color(48, 32, 64, 255)
		djui_hud_render_rect(x - 6, coolY, 94, 26)
		djui_hud_set_color(0, 0, 0, 255)
		djui_hud_render_rect(x - 6, coolY, 92, 24)
		djui_hud_set_color(128, 0, 0, 255)
		djui_hud_render_rect(x+16, coolY + 6, 64, 12)
		djui_hud_set_color(255, 255, 0, 255)
		djui_hud_render_rect(x+16, coolY + 6, math.floor(64 * f), 12)
		djui_hud_set_color(255, 255, 255, 255)
		djui_hud_print_text("HP", x, coolY + 5, 0.45)
    end
    
    djui_hud_set_color(0, 0, 0, transitionAlpha)
    djui_hud_render_rect(-4, -4, djui_hud_get_screen_width() + 8, sH + 8)
end

function getGridPos(i, w, h)
	return i % w, math.floor(i/w) * h
end

function draw_tile_layer(data, tilesetList, x, y, scale)
	local x = (x + (data.offsetx or 0)) * (data.parallaxx or 1)
	local y = (y + (data.offsety or 0)) * (data.parallaxy or 1)
	local tiles = data.data
	if not tiles then return end
	djui_hud_set_color(255, 255, 255, 255 * data.opacity)
	for i, tile in pairs(tiles) do
		if tile > 0 then
			local texture
			local tileset
			local offset = 0
			for i = 1, #tilesetList do
				if tile >= tilesetList[i].firstgid then
					tileset = tilesets[tilesetList[i].name]
					if tileset then
						texture = tileset.texture
					end
					offset = tilesetList[i].firstgid
				end
			end
			if texture and tileset then
				local tX, tY = getGridPos((tile - offset) * tileset.tilewidth, texture.width, tileset.tileheight)
				local oX, oY = getGridPos((i - 1) * tileset.tilewidth, data.width * tileset.tilewidth, tileset.tileheight)
				djui_hud_render_texture_tile(texture, x + (oX * scale), y + (oY * scale), scale, scale, tX, tY, tileset.tilewidth, tileset.tileheight)
			end
		end
	end
end

function get_map_spawn_pos(map, id)
	for i, layer in pairs(map.layers) do
		if layer.type == "objectgroup" and layer.name == "markers" then
			for ii, obj in pairs(layer.objects) do
				if obj.shape == "point" and obj.name == id then
					return {x = obj.x * mapScale, y = obj.y * mapScale}
				end
			end
		end
	end
	for i, layer in pairs(map.layers) do
		if layer.type == "objectgroup" and layer.name == "markers" then
			for ii, obj in pairs(layer.objects) do
				if obj.shape == "point" then
					return {x = obj.x * mapScale, y = obj.y * mapScale}
				end
			end
		end
	end
	return {x=0,y=0}
end

function on_packet(d)
	if d.type == "player" then
		local anim = d.anim
		local sprites = charList[d.character].sprites[d.costume]
		if sprites[anim] and sprites[anim].snd and d.map == s.map then
			audio_stream_play(sprites[anim].snd, true, 1)
		end
	elseif d.type == "attack" then
		if d.map == s.map then
			audio_stream_play(snd_slash, true, 1)
		end
	elseif d.type == "dmg" then
		if d.map == s.map then
			audio_stream_play(snd_damage, true, 1)
		end
	end
end

function on_player_disconnected(m)
	if not network_is_server() then return end
	gPlayerSyncTable[m.playerIndex].deltarune = false
end

hook_event(HOOK_ON_HUD_RENDER_BEHIND, render_overworld)
hook_event(HOOK_ON_CHAT_MESSAGE, on_chat_message)
hook_event(HOOK_ON_PACKET_RECEIVE, on_packet)
hook_event(HOOK_ON_PLAYER_DISCONNECTED, on_player_disconnected)

function emote(anim)
	local anim = anim:lower()
	local sprites = charList[s.character].sprites[s.costume]
	if sprites[anim] and not (sprites[anim].other == true) then
		s.walking = false
		s.anim = anim
		if sprites[anim].snd then
			audio_stream_play(sprites[anim].snd, true, 1)
			network_send(true, {
				type = "player",
				character = s.character,
				costume = s.costume,
				anim = anim,
				map = s.map
			})
		end
	end
	return true
end

function emote_list()
	local discard = {
		["up"] = true,
		["down"] = true,
		["left"] = true,
		["right"] = true,
	}
	local text = ""
	local sprites = charList[s.character].sprites[s.costume]
	for i, v in pairs(sprites) do
		if not discard[i] and not (v.other == true) then
			text = text .. (text == "" and "" or ", ") .. i
		end
	end
	djui_chat_message_create("\\#FFFF00\\Emote List:\\#FFFFFF\\\n"..text)
	return true
end

hook_chat_command("e", "[emote name] - do an emote", emote)
hook_chat_command("emotes", " - see your emotes", emote_list)
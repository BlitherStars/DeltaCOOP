local sServerSettings = gServerSettings
_G.gServerSettings = {
	enablePlayerList			= sServerSettings.enablePlayerList,
	enablePlayersInLevelDisplay = sServerSettings.enablePlayersInLevelDisplay,
}
local _ServerSettingsMetaTable = {
	__index = function (t, k)
		return rawget(t, k) or sServerSettings[k]
	end,
	__newindex = function (_, k, v)
		sServerSettings[k] = v
	end,
}
setmetatable(gServerSettings, _ServerSettingsMetaTable)

dialog = {
	data = {},
	num = -1,
	chars = 0,
}

local player_chats = {}
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

anim_timer = 0

inTransition = false
inSaveMenu = false
saveMenuHasSelected = false
saveMenuSel = 1
saveMenuCd = 0
battleAlpha = 0
transitionAlpha = 0

_G.charScale = 1
_G.mapScale = 0.5

_G.camPos = {x = 0, y = 0}
_G.freezeControls = false

_G.render_queue = {}

local coolspX = 0
local coolspY = 0

local function on_chat_message(m, msg)
	if m.playerIndex < MAX_PLAYERS then
		player_chats[m.playerIndex] = {
			text = get_uncolored_string(msg),
			timer = 30 * 4,
			chars = 0
		}
	end
end

local function render_overworld()
	if musicStream then
		audio_stream_set_volume(musicStream, SURVEY_INTERFACE.inBattle and 0 or 0.5)
	end
	
	djui_hud_set_resolution(RESOLUTION_N64)
	
	_G.render_queue = {}
	local sW = 320
	local sH = djui_hud_get_screen_height()
	
	freezeControls = menu ~= ""or inTransition or s.dead or (dialog.num > 0 and dialog.num <= #dialog.data) or inSaveMenu or fade_alpha > 0
	
	if not s.deltarune or s.hp == nil or s.x == nil or s.y == nil or s.anim == nil then
		s.deltarune = true
		
		s.x = 0
		s.y = 0
		s.anim = "down"
		s.walking = false
		s.battle = false
		s.frame = 1
		
		s.attackCooldown = 0
		
		local charNames = {}
		for _, v in pairs(charList) do
			table.insert(charNames, v.name)
		end
		
		s.character = math.max(table.indexOf(charNames, mod_storage_load("character")), 1)
		
		s.exp = mod_storage_exists("exp") and math.min(mod_storage_load_number("exp"), 20000) or 0
		s.maxHP = math.floor(90 * (1 + (s.exp / 5000)))
		s.hp = s.maxHP
		
		s.costume = 1
		s.map = mod_storage_load("map", "kristalcastle1")
		s.bW = 0
		s.bH = 0
		
		local char = charList[s.character]
		local map = maps[s.map] or maps["kristalcastle1"]
		local spawn = get_map_spawn_pos(map, "spawn")
		s.x = spawn.x - char.boxW/2
		s.y = spawn.y - char.boxH/4
		
		s.flipX = false
	end
	
	if maps[s.map] == nil then
		s.map = "kristalcastle1"
	end
	
	s.attackCooldown = s.attackCooldown - 1
	
	local char = charList[s.character]
	local sprites = char.sprites[s.costume]
	local map = maps[s.map]
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
			if stick_x > 32 then dx, ldx = 1, 1 elseif stick_x < -32 then dx, ldx = -1, -1 end
			if stick_y > 32 then dy = -1 elseif stick_y < -32 then dy = 1 end
		end
	end
	
	local anim_frame = s.frame
	
	if s.walking then
		local anim = s.anim
		if dy < 0 then
			anim = "up"
		elseif dy > 0 then
			anim = "down"
		elseif dx > 0 then
			anim = "right"
		elseif dx < 0 then
			anim = "left"
		end
		playAnim(anim, false)
		lastAnim = anim
		s.flipX = false
	end
	
	if sprites[s.anim] == nil then
		s.walking = true
		playAnim(lastAnim, true)
	end
	
	if not s.battle and not freezeControls and (m.controller.buttonDown & X_BUTTON) ~= 0 and sprites["attack"] and s.attackCooldown <= 0 and not gGlobalSyncTable.disablePVP then
		s.walking = false
		s.attackCooldown = 30
		if ldx < 0 or anim == "left" then
			s.flipX = true
		end
		playAnim("attack", true)
		
		if sprites[s.anim].snd then
			audio_stream_play(sprites[s.anim].snd, true, 1)
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
			if ss ~= s and not ss.battle and gNetworkPlayers[i].connected and ss.map == s.map and overlap({x = s.x - (box_w * (s.flipX and 1 or 0)), y = s.y, width = box_w*2, height = box_h}, {x = ss.x, y = ss.y, width = ss.bW, height = ss.bH}) then
				ss.hp = ss.hp - ((15 * (1 + (s.exp / 5000))) * (ss.anim == "attack" and 0.25 or 1))
				if ss.anim == "attack" then
					s.attackCooldown = 60
				end
				audio_stream_play(snd_damage, true, 1)
				network_send(true, {
					type = "dmg",
					map = s.map
				})
				if ss.hp <= 0 and not ss.dead then
					s.exp = math.min(s.exp + math.random(50, 150), 20000)
					local newHP = math.floor(90 * (1 + (s.exp / 5000)))
					local hpDiff = newHP - s.maxHP
					s.maxHP = newHP
					s.hp = s.hp + hpDiff
					ss.dead = true
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
			playAnim("defeat", false)
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
		if not s.battle and not discard[i] and not (v.other == true) and keys[curKey] and not freezeControls and not useDpad then
			if (m.controller.buttonPressed & keys[curKey]) ~= 0 then
				emote(i, true)
			end
			curKey = curKey + 1
		end
	end
	
	local max_frames = sprites[s.anim].length or 4
	local fpsDist = (sprites[s.anim].fps or 12) / 30
	local loop = sprites[s.anim].loop or false
	local persistent = sprites[s.anim].persistent or false
	local repeatAmount = sprites[s.anim].repeatAmount or 1
	local other = sprites[s.anim].other or false
	
	if s.walking and not s.battle then
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
		if (not loop and not persistent and anim_timer >= (max_frames * repeatAmount)) or ((loop or persistent) and (m.controller.buttonPressed & A_BUTTON) ~= 0 and not other) then
			s.walking = not s.battle
			playAnim(s.battle and "right" or lastAnim)
		end
	end

	local sm64 = char.name == "Annoying Dog" or gGlobalSyncTable.accelMovement
	local mult = char.name == "Annoying Dog" and 2 or 1
	
	local speed = 3
	if run then speed = 4 end
	if not s.walking or s.battle then speed = 0 end
	
	coolspX = coolspX < speed * dx * mult and coolspX + 1 or (coolspX > speed * dx * mult and coolspX - 0.5 or coolspX)
	coolspY = coolspY < speed * dy * mult and coolspY + 1 or (coolspY > speed * dy * mult and coolspY - 0.5 or coolspY)
	
	local nx, ny = s.x, s.y
	
	nx = nx + (sm64 and coolspX or dx * speed)
	ny = ny + (sm64 and coolspY or dy * speed)
	
	for lay_id, layer in pairs(map.layers) do
		if layer.type == "objectgroup" then
			if layer.name == "collision" then
				for obj_id, obj in pairs(layer.objects) do
					if obj.shape ~= "polygon" then
						if overlap({x = nx, y = s.y, width = box_w, height = box_h}, {x = obj.x * mapScale, y = obj.y * mapScale, width = obj.width * mapScale, height = obj.height * mapScale}) then
							nx = s.x
						end
						if overlap({x = s.x, y = ny, width = box_w, height = box_h}, {x = obj.x * mapScale, y = obj.y * mapScale, width = obj.width * mapScale, height = obj.height * mapScale}) then
							ny = s.y
						end
					else
						local a = {
							x = obj.x * mapScale,
							y = obj.y * mapScale,
							polygon = {}
						}
						for i, v in pairs(obj.polygon) do
							table.insert(a.polygon, {x = v.x * mapScale, y = v.y * mapScale})
						end
						if overlapPolygon(a, {x = nx, y = s.y, width = box_w, height = box_h}) then
							nx = s.x
						end
						if overlapPolygon(a, {x = s.x, y = ny, width = box_w, height = box_h}) then
							ny = s.y
						end
					end
				end
			else
				for obj_id, obj in pairs(layer.objects) do
					local properties = propPresets[obj.name] or {}
					for i, v in pairs(properties) do
						obj.properties[i] = v
					end
					if obj.name == "transition" and not inTransition and overlap({x = s.x, y = s.y, width = box_w, height = box_h}, {x = obj.x * mapScale, y = obj.y * mapScale, width = obj.width * mapScale, height = obj.height * mapScale}) then
						change_map(obj.properties["map"], obj.properties["marker"])
					end
					if obj.name == "sprite" or obj.properties["sprite"] then
						local spr = obj.properties["sprite"] or {
							texture = obj.properties["texture"],
							length = 1,
							fps = 12 * obj.properties["speed"],
						}
						local t = {
							type = "sprite",
							x = ((obj.x + layer.offsetx) or 0) * mapScale,
							y = ((obj.y + layer.offsety) or 0) * mapScale,
							sprite = spr,
							scaleX = math.abs(obj.properties["scalex"] or 2) * mapScale,
							scaleY = (obj.properties["scaley"] or 2) * mapScale,
							scrollX = layer.parallaxx or 1,
							scrollY = layer.parallaxy or 1,
							frame = math.floor((get_global_timer() * ((spr.fps or 12) / 30)) % spr.length) + 1,
							bW = (obj.width or 0) * mapScale,
							bH = (obj.height or 0) * mapScale,
							flipX = obj.properties["flipX"],
							alpha = obj.properties["alpha"] or 1,
						}
						if t then
							table.insert(render_queue, t)
						end
						if obj.properties["solid"] and overlap({x = nx, y = s.y, width = box_w, height = box_h}, {x = obj.x * mapScale, y = obj.y * mapScale, width = obj.width * mapScale, height = obj.height * mapScale}) then
							nx = s.x
						end
						if obj.properties["solid"] and overlap({x = s.x, y = ny, width = box_w, height = box_h}, {x = obj.x * mapScale, y = obj.y * mapScale, width = obj.width * mapScale, height = obj.height * mapScale}) then
							ny = s.y
						end
					end
					if not freezeControls and (m.controller.buttonPressed & A_BUTTON ~= 0) and overlap({x = s.x-5, y = s.y-5, width = box_w+10, height = box_h+10}, {x = obj.x * mapScale, y = obj.y * mapScale, width = obj.width * mapScale, height = obj.height * mapScale}) then
						local data = {}
						for id, str in pairs(obj.properties) do
							if id:sub(1,4) == "text" then
								data[tonumber(id:sub(5, #id)) or (#data + 1)] = {text = str}
							end
						end
						if obj.properties["dialog"] then
							for id, v in pairs(obj.properties["dialog"]) do
								v.triggered = false
								table.insert(data, v)
							end
						end
						if #data >= 0 and dialog.num <= 0 or dialog.num > #dialog.data then
							dialog.data = data
							dialog.chars = 0
							dialog.num = 1
						end
					end
					call_custom_hook(HOOK_DELTA_OBJ_PROCESS, obj, obj_id)
				end
			end
		end
	end
	
	if not inTransition then
		if nx ~= s.x then
			s.x = nx
		end
		if ny ~= s.y then
			s.y = ny
		end
		if anim_frame ~= s.frame then
			s.frame = anim_frame
		end
	end
	
	if nx < - box_w/2 then nx = - box_w/2 end
	if nx > rW - box_w/2 then nx = rW - box_w/2 end
	if ny < - box_w/2 then ny = - box_w/2 end
	if ny > rH - box_h/2 then ny = rH - box_h/2 end
	
	local boundX = math.max(rW - sW, 0)
	local boundY = math.max(rH - sH, 0)
	if SURVEY_INTERFACE.inBattle then
		camPos.x = math.lerp(camPos.x, s.x - ((sW - box_w) / 2) - (screenOffset / 2) + 96, 0.1)
		camPos.y = math.lerp(camPos.y, s.y - ((sH - box_h) / 2) + 16, 0.1)
	else
		camPos.x = math.lerp(camPos.x, math.min(math.max(s.x - ((sW - box_w) / 2), 0), boundX) - (screenOffset / 2), (255-battleAlpha)/255)
		camPos.y = math.lerp(camPos.y, math.min(math.max(s.y - ((sH - (box_h / 2)) / 2), 0), boundY), (255-battleAlpha)/255)
	end
	
	djui_hud_set_color(0, 0, 0, 255)
	djui_hud_render_rect(-4, -4, djui_hud_get_screen_width() + 8, sH + 8)

	for i = 0, MAX_PLAYERS - 1 do
		local m = gMarioStates[i]
		local np = gNetworkPlayers[m.playerIndex]
		local ss = gPlayerSyncTable[m.playerIndex]
		if (not SURVEY_INTERFACE.inBattle or m.playerIndex == 0) and (np.connected or ss.deltarune) and ss.map == s.map then
			table.insert(render_queue, {
				type = "player",
				id = m.playerIndex or 0,
				x = ss.x or spawn_x,
				y = ss.y or spawn_y,
				anim = ss.anim or "down",
				frame = ss.frame or 1,
				character = ss.character or 1,
				costume = ss.costume or 1,
				name = np.name or "UNKNOWN",
				bW = ss.bW or 0,
				bH = ss.bH or 0,
				flipX = ss.flipX or false,
				hp = (ss.hp / ss.maxHP) or 0
			})
		end
	end
	
	call_custom_hook(HOOK_BEFORE_WORLD_RENDER)

	table.sort(render_queue, function(a, b)
		return a.y < b.y
	end)
	
	for i, layer in pairs(map.layers) do
		if layer.type == "tilelayer" then
			local default = {{firstgid = 1, name = "castle"}}
			draw_tile_layer(layer, map.tilesets or default, layer.x - camPos.x, layer.y - camPos.y, mapScale)
			call_custom_hook(HOOK_TILEMAP_RENDER, layer, map.tilesets or default, layer.x - camPos.x, layer.y - camPos.y, mapScale)
		end
		if layer.type == "imagelayer" then
			local l = {
				x = (layer.offsetx or 0) * mapScale,
				y = (layer.offsety or 0) * mapScale,
				texture = layer.image or layer.texture or nil,
				scrollX = layer.parallaxx or 1,
				scrollY = layer.parallaxy or 1,
				alpha = layer.visible and (layer.opacity * 255) or 0,
			}
			if l.texture and type(l.texture) == "string" then
				l.texture = get_texture_info(l.texture)
			end
			djui_hud_set_color(255,255,255,l.alpha)
			if l.texture and type(l.texture) ~= "string" and l.texture.width > 0 and l.texture.height > 0 then
				djui_hud_render_texture(l.texture, (l.x - camPos.x) * l.scrollX, (l.y - camPos.y) * l.scrollY, mapScale, mapScale)
			end
			djui_hud_set_color(255,255,255,255)
		end
		if layer.type == "objectgroup" and showCollisions then
			djui_hud_set_color(255, 255, 255, 32)
			for ii, obj in pairs(layer.objects) do
				djui_hud_render_rect((obj.x * mapScale) - camPos.x, (obj.y * mapScale) - camPos.y, obj.width * mapScale, obj.height* mapScale)
			end
			djui_hud_set_color(255, 255, 255, 255)
		end
	end
	
	battleAlpha = math.lerp(battleAlpha, SURVEY_INTERFACE.inBattle and 255 or 0, 0.1)
	if battleAlpha > 0 then
		djui_hud_set_color(0, 0, 0, battleAlpha)
		djui_hud_render_rect(-4, -4, djui_hud_get_screen_width() + 8, sH + 8)
		for i = 1, 32 do
			djui_hud_set_color(48, 24, 48, battleAlpha)
			djui_hud_render_rect((i * 24) - ((get_global_timer() * 2) % 24), math.sin((get_global_timer() + i) / 8) * 30, 1, 200)
			djui_hud_set_color(96, 24, 96, battleAlpha)
			djui_hud_render_rect((i * 16) - ((get_global_timer() * 2) % 16), math.sin((get_global_timer() + i) / 8) * 30, 1, 200)
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
		
		if sprite.image and type(sprite.image) == "string" then
			sprite.texture = get_texture_info(sprite.image)
		end
		if sprite.texture and type(sprite.texture) == "string" then
			sprite.texture = get_texture_info(sprite.texture)
		end
		
		local hasTex = sprite and sprite.texture and sprite.texture.width > 0 and sprite.texture.height > 0
		local scaleX = ent.scaleX or (ent.scale or (charList[ent.character or -1].scale ~= nil and (charList[ent.character or -1].scale * charScale) or 1))
		if ent.flipX then
			scaleX = -scaleX
		end
		log_to_console(tostring(scaleX),0)
		local scaleY = ent.scaleY or (ent.scale or (charList[ent.character or -1].scale ~= nil and (charList[ent.character or -1].scale * charScale) or 1))
		local alpha = ent.alpha or (ent.character and math.max((charList[ent.character].alpha or 1), 0.25) or 1)
		djui_hud_set_color(255, 255, 255, 255 * alpha)
		
		if hasTex then
			local spr_w = (sprite.width or (sprite.texture.width / (sprite.length or 4)))
			local tex_w = spr_w * math.abs(scaleX)
			local tex_h = sprite.texture.height * scaleY
			local center_x = (screen_x + (pw - tex_w) / 2) + (tex_w * (scaleX < 0 and 1 or 0))
			local center_y = screen_y + (ph - tex_h)
			call_custom_hook(HOOK_QUEUE_RENDER, ent)
			djui_hud_render_texture_tile(sprite.texture, center_x + ((sprite.offsetX or 0) * scaleX), center_y + ((sprite.offsetY or 0) * scaleY),scaleX, scaleY, spr_w * (math.min(ent.frame, sprite.length or 4) - 1), 0, spr_w, sprite.texture.height)
		end
		
		if showCollisions or not hasTex then
			djui_hud_set_color(255, 255, 255, 32)
			djui_hud_render_rect(screen_x, screen_y, pw, ph)
			djui_hud_set_color(255, 255, 255, 255)
		end
		
		djui_hud_set_font(FONT_SPECIAL)
		local text_scale = 0.3 * charScale
		local text_width = djui_hud_measure_text(ent.name or "") * text_scale
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
		
		if ent.type == "player" and player_chats[ent.id] then
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
	
	if dialog.data[dialog.num] and dialog.data[dialog.num].func and not dialog.data[dialog.num].triggered then
		dialog.data[dialog.num].triggered = true
		dialog.data[dialog.num].func()
	end
	
	if dialog.data[dialog.num] and dialog.data[dialog.num].text then
		render_dialog()
	end
	
	if not SURVEY_INTERFACE.inBattle and not is_game_paused() then
		djui_hud_set_font(FONT_SPECIAL)
		local x = (screenOffset / 2) + 6
		coolY = math.lerp(coolY, s.hp < s.maxHP and 0 or -26, 0.2)
		local f = s.hp / s.maxHP
		djui_hud_set_color(64, 32, 48, 255)
		djui_hud_render_rect(x - 6, coolY, 94, 26)
		djui_hud_set_color(0, 0, 0, 255)
		djui_hud_render_rect(x - 6, coolY, 93, 25)
		djui_hud_set_color(128, 0, 0, 255)
		djui_hud_render_rect(x+16, coolY + 6, 64, 12)
		djui_hud_set_color(255, 255, 0, 255)
		djui_hud_render_rect(x+16, coolY + 6, math.floor(64 * f), 12)
		djui_hud_set_color(255, 255, 255, 255)
		djui_hud_print_text("HP", x, coolY + 5, 0.45)
	end
	
	if inSaveMenu then
		render_save_menu()
	end
	
	call_custom_hook(HOOK_DC_UI_RENDER)
	
	sServerSettings.enablePlayerList = 0

	local enablePlayerList = gServerSettings.enablePlayerList
	if djui_attempting_to_open_playerlist() and enablePlayerList then
		render_playerlist()
	end
	
	djui_hud_set_color(0, 0, 0, transitionAlpha)
	djui_hud_render_rect(-4, -4, djui_hud_get_screen_width() + 8, sH + 8)
end

function render_dialog()
	local x, y = ((320 - 297) / 2) + (screenOffset / 2), djui_hud_get_screen_height() - 84
	local text = dialog.data[dialog.num].text or ""
	local displayText = ""
	local inSlash = false
	for i = 1, #text do
		local c = text:sub(i,i)
		local c2 = text:sub(math.min(i+1, #text),math.min(i+1, #text))
		if c == "\\" then
			inSlash = not inSlash
		end
		if (djui_hud_measure_text(displayText .. c) * 0.5) >= textbox.width - 32 and not inSlash then
			displayText = displayText .. "\n" .. c
		else
			displayText = displayText .. c
		end
		displayText = displayText:gsub([[\\nn]], "\n")
	end
	djui_hud_set_color(255, 255, 255, 255)
	djui_hud_render_texture(textbox, x, y, 1, 1)
	djui_hud_print_text(displayText:sub(1, math.floor(dialog.chars)), x + 16, y + 12, 0.5)
	local old_chars = math.floor(dialog.chars)
	local old_char = displayText:sub(math.floor(old_chars), math.floor(old_chars))
	dialog.chars = dialog.chars + (charsTimer[old_char] or 0.5) * 2
	local new_char = displayText:sub(math.floor(dialog.chars), math.floor(dialog.chars))
	if new_char == "\\" then
		dialog.chars = dialog.chars + 1
		new_char = displayText:sub(math.floor(dialog.chars), math.floor(dialog.chars))
		while new_char ~= "\\" and new_char ~= "n" do
			dialog.chars = dialog.chars + 1
			new_char = displayText:sub(math.floor(dialog.chars), math.floor(dialog.chars))
		end
		dialog.chars = dialog.chars + 1
		new_char = displayText:sub(math.floor(dialog.chars), math.floor(dialog.chars))
	end
	local max_chars = string.len(displayText)
	if dialog.chars > max_chars then dialog.chars = max_chars end
	local new_chars = math.floor(dialog.chars)
	if new_chars > old_chars then
		local snd = dialog.data[dialog.num].snd or snd_txt
		if type(snd) == "table" then
			snd = snd[math.random(1,#snd)]
		end
		audio_stream_play(snd, true, 1)
	end
	if dialog.chars >= max_chars and (m.controller.buttonPressed & A_BUTTON ~= 0) then
		dialog.chars = 0
		dialog.num = dialog.num + 1
	end 
	if dialog.chars < max_chars and (m.controller.buttonPressed & B_BUTTON ~= 0) then
		dialog.chars = max_chars
	end
end

function render_save_menu()
	local stick_x = m.controller.stickX
	local stick_y = m.controller.stickY
	local dx = 0
	local dy = 0
	
	if useDpad then
		if (m.controller.buttonDown & L_JPAD) ~= 0 then dx, ldx = -1, -1 elseif (m.controller.buttonDown & R_JPAD) ~= 0 then dx, ldx = 1, 1 end
		if (m.controller.buttonDown & U_JPAD) ~= 0 then dy = -1 elseif (m.controller.buttonDown & D_JPAD) ~= 0 then dy = 1 end
	else
		if stick_x > 32 then dx, ldx = 1, 1 elseif stick_x < -32 then dx, ldx = -1, -1 end
		if stick_y > 32 then dy = -1 elseif stick_y < -32 then dy = 1 end
	end
	
	local options = {"Save", "Return"}
	local x,y = (screenOffset/2) + ((320-240)/2), ((240-120)/2)
	djui_hud_set_color(0, 0, 0, 255)
	djui_hud_render_outlined_rect(x,y, 240, 120, {255,255,255,255}, 4)
	djui_hud_set_color(255, 255, not saveMenuHasSelected and 255 or 0, 255)
	djui_hud_print_text(np.name, x + 8, y + 8, 0.5)
	local lvtext = "\\#ffff00\\LV \\#ffffff\\"..math.floor(1 + (mod_storage_load_number("exp", 0) / 2000))
	djui_hud_print_text(lvtext,x + (djui_hud_measure_text(np.name) * 0.5) + 16, y + 8, 0.5)
	djui_hud_print_text(maps[mod_storage_load("map", "toby_fox")] and (maps[mod_storage_load("map", "toby_fox")].properties["name"] or "car pit") or "______", x + 8, y + 24, 0.5)
	for i, v in pairs(options) do
		local tx, ty = x + 64 + (64 * (i - 1)), y + 120 - 32
		djui_hud_set_color(255, 255, not saveMenuHasSelected and 255 or 0, 255)
		djui_hud_print_text(v, tx, ty, 0.5)
		if i == saveMenuSel then
			djui_hud_set_color(255, 0, 0, 255)
			djui_hud_render_texture(soul, tx - 10, ty + 4, 0.5, 0.5)
			if saveMenuCd <= 0 and not saveMenuHasSelected and (m.controller.buttonPressed & A_BUTTON ~= 0) then
				if v == "Save" then
					saveMenuHasSelected = true
					mod_storage_save("map", s.map)
					mod_storage_save_number("exp", s.exp)
					audio_stream_play(snd_save, true, 1)
					timer_start("save", 1, function()
						inSaveMenu = false
					end)
				else
					inSaveMenu = false
				end
			end
		end
	end

	if not saveMenuHasSelected and dx ~= 0 and saveMenuCd <= 0 then
		saveMenuSel = wrap(saveMenuSel + dx, 1, #options)
		saveMenuCd = 5
		audio_stream_play(snd_menumove, true, 1)
	elseif saveMenuCd > 0 then
		saveMenuCd = saveMenuCd - 1
	end
end

function render_playerlist()
	djui_hud_set_color(0, 0, 0, 128)
	djui_hud_render_rect((screenOffset / 2) + 4, 4, 240, djui_hud_get_screen_height() - 8)
	local yy = 0
	for i = 0, (MAX_PLAYERS - 1) do
		local np = gNetworkPlayers[i]
		local s = gPlayerSyncTable[i]
		if np.connected then
			djui_hud_set_color(0, 0, 0, 128)
			local x, y = (screenOffset / 2) + 6, 6 + yy
			djui_hud_set_scissor(x / 2, 0, 212, djui_hud_get_screen_height())
			djui_hud_render_rect(x, y, 236, 12)
			djui_hud_set_color(255, 255, 255, 255)
			djui_hud_print_text(np.name,x + 2, y, 0.40)
			local lvtext = "\\#ffff00\\LV \\#ffffff\\"..math.floor(1 + (s.exp / 2000))
			djui_hud_print_text(lvtext,x + (djui_hud_measure_text(np.name) * 0.40) + 16, y, 0.40)
			local maptext = (maps[s.map].properties["name"] or s.map)
			djui_hud_print_text(maptext,x + (djui_hud_measure_text(np.name) * 0.40) + (djui_hud_measure_text(lvtext) * 0.40) + 32, y, 0.40)
			yy = yy + 14
		end
	end
	djui_hud_reset_scissor()
	djui_hud_set_color(0, 0, 0, 128)
	djui_hud_render_rect((screenOffset / 2) + 248, 4, 240, djui_hud_get_screen_height() - 8)
	djui_hud_set_color(255, 255, 255, 128)
	djui_hud_print_text("Mods", (screenOffset / 2) + 252, 6, 0.4)
	local yy = 14
	for i = 1, #modList do
		local mod = modList[i]
		djui_hud_set_color(0, 0, 0, 128)
		local x, y = (screenOffset / 2) + 252, 6 + yy
		djui_hud_render_rect(x, y, 236, 12)
		djui_hud_set_color(255, 255, 255, 255)
		djui_hud_print_text(mod,x + 2, y, 0.40)
		yy = yy + 14
	end
	djui_hud_set_color(255, 255, 255, 255)
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
						if tileset.image and type(tileset.image) == "string" then
							tileset.texture = get_texture_info(tileset.image)
						end
						if tileset.texture and type(tileset.texture) == "string" then
							tileset.texture = get_texture_info(tileset.texture)
						end
						texture = tileset.texture
					end
					offset = tilesetList[i].firstgid
				end
			end
			if texture and tileset then
				local tX, tY = getGridPos((tile - offset) * tileset.tilewidth, texture.width, tileset.tileheight)
				local oX, oY = getGridPos((i - 1) * tileset.tilewidth, data.width * tileset.tilewidth, tileset.tileheight)
				local cX, cY = x + (oX * scale), y + (oY * scale)
				if not (cX < (screenOffset/2) - tileset.tilewidth or cY < - tileset.tileheight or cX >= (screenOffset/2) + 320 or cY >= 240) then
					djui_hud_render_texture_tile(texture, cX, cY, scale, scale, tX, tY, tileset.tilewidth, tileset.tileheight)
				end
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
	if d.type == "player" and not s.battle then
		local anim = d.anim
		local sprites = charList[d.character].sprites[d.costume]
		if sprites[anim] and sprites[anim].snd and d.map == s.map then
			audio_stream_play(sprites[anim].snd, true, 1)
		end
	elseif d.type == "attack" and not s.battle then
		if d.map == s.map then
			audio_stream_play(snd_slash, true, 1)
		end
	elseif d.type == "dmg" and not s.battle then
		if d.map == s.map then
			audio_stream_play(snd_damage, true, 1)
		end
	end
end

function reset_player(m)
	player_chats[m.playerIndex] = nil
	
	if not network_is_server() then return end
	
	local s = gPlayerSyncTable[m.playerIndex]
	s.deltarune = false
	
	s.x = 0
	s.y = 0
	s.anim = "down"
	s.walking = false
	s.battle = false
	s.frame = 1
	
	s.attackCooldown = 0
	s.character = 1
	
	s.exp = 0
	s.maxHP = 90
	s.hp = 90
	
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

function bg()
	djui_hud_set_resolution(RESOLUTION_N64)
	djui_hud_set_font(FONT_SPECIAL)
	
	local sW = 320
	local sH = djui_hud_get_screen_height()
	
	djui_hud_set_color(0, 0, 0, 255)
	djui_hud_render_rect(-4, -4, djui_hud_get_screen_width() + 8, sH + 8)
	djui_hud_set_color(255, 255, 255, 255)
	djui_hud_print_text("RENDER FAIL, PLEASE REJOIN!", screenOffset/2, 120, 0.5)
end

hook_event(HOOK_ON_HUD_RENDER_BEHIND, bg)
hook_event(HOOK_ON_HUD_RENDER_BEHIND, render_overworld)
hook_event(HOOK_ON_CHAT_MESSAGE, on_chat_message)
hook_event(HOOK_ON_PACKET_RECEIVE, on_packet)
hook_event(HOOK_ON_PLAYER_DISCONNECTED, reset_player)
hook_event(HOOK_ON_PLAYER_CONNECTED, reset_player)

function emote(anim)
	local anim = anim:lower()
	local sprites = charList[s.character].sprites[s.costume]
	if sprites[anim] and not sprites[anim].other then
		s.walking = false
		s.anim = anim
		anim_timer = 0
		s.frame = 1
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
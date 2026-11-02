submenu = ""
paused = false

_G.is_game_paused = function() return paused end

selectedOption = 1
lastMenuSelected = 1
lerpOption = 1
descChars = 1

local function close_menu()
    if paused then
        submenu = ""
        paused = false
        m.controller.buttonPressed = 0
    end
end

local cooldown = 5
local cooldownCounter = 0

local pauseMenuOptions = {
    {name = "Vessels", submenu = "vessels", tex = get_texture_info("pause_char")},
    {name = "Warps", submenu = "warper", tex = get_texture_info("pause_warp")},
    {name = "Options", submenu = "options", tex = get_texture_info("pause_config")},
    {name = "Instructions", tex = get_texture_info("pause_help"), func = function()
    	show_warning_screen = true
		is_fading = false
		fade_alpha = 255
		close_menu()
	end},
}

local pauseY = -48 

local function hud_render()
	pauseY = math.lerp(pauseY, paused and 0 or -48, 0.2)
	
    djui_hud_set_resolution(RESOLUTION_N64)
    local sW, sH = 320, djui_hud_get_screen_height()
    local dx, dy = 0, 0
    local stick_x = m.controller.stickX or 0
	local stick_y = m.controller.stickY or 0
    if (m.controller.buttonDown & L_JPAD) ~= 0 then dx, ldx = -1, -1 elseif (m.controller.buttonDown & R_JPAD) ~= 0 then dx, ldx = 1, 1 end
	if (m.controller.buttonDown & U_JPAD) ~= 0 then dy = -1 elseif (m.controller.buttonDown & D_JPAD) ~= 0 then dy = 1 end
	if stick_x > 32 then dx, ldx = 1, 1 elseif stick_x < -32 then dx, ldx = -1, -1 end
	if stick_y > 32 then dy = -1 elseif stick_y < -32 then dy = 1 end
    local x, y = 10 + (screenOffset / 2), pauseY
    
    djui_hud_set_color(0, 0, 0, 255)
    djui_hud_render_rect((screenOffset / 2), y, sW, 38)
    
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_set_font(FONT_SPECIAL)
    djui_hud_print_text("LV "..math.floor(s.exp/2000), (screenOffset / 2) + 280, pauseY + 12, 0.5)
    
    for i,v in pairs(pauseMenuOptions) do
		local optX = x + 60 + (45 * (i-1))
		djui_hud_render_texture_tile(v.tex, optX, pauseY + 7, 1, 1, i == lastMenuSelected and 0 or 33, 0, 33, 24)
	end
	djui_hud_render_texture_tile(pauseMenuOptions[lastMenuSelected].tex, x, pauseY + 7, 1, 1, 66, 0, 35, 24)
	
	if submenu ~= "" and submenu ~= "options" then
		djui_hud_set_color(0, 0, 0, 128)
		djui_hud_render_rect((screenOffset / 2), 0, sW, sH)
	end
	
	djui_hud_set_color(255, 255, 255, 255)
	    
    if submenu == "options" then
        local boxW = 280
        local boxH = 150
        local rowSpacing = _G.cheatsApi and 11 or 18
        local boxX = (sW - boxW) / 2 + ((screenOffset and screenOffset / 2) or 0)
        local boxY = (sH - boxH) / 1.7

        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_render_texture_rect(deltabox, boxX - 8, boxY - 8, boxW + 16, boxH + 16, 13)
        
        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_set_font(FONT_SPECIAL)
        local title = "CONFIG"
        local titleScale = 0.5
        local titleW = djui_hud_measure_text(title) * titleScale
        djui_hud_print_text(title, boxX + (boxW - titleW) / 2, boxY + 5, titleScale)

        local startY = (boxY + 30)
    	for i = 1, #settings do
			local v = settings[i]
			local text = v.name
			local value = ""
			if v.type == "bool" then
				value = v.value and "ON" or "OFF"
			elseif v.type == "number" then
				value = tostring(v.value)
			elseif v.type == "text" then
				value = v.texts[v.value] or "-"
			end

            local itemY = startY + ((i - 1) * rowSpacing)

            if i == selectedOption then
                djui_hud_set_color(255, 0, 0, 255)
                djui_hud_render_texture(soul, boxX + 28, itemY + 4, 0.5, 0.5)
            end

            djui_hud_set_color(255, 255, 255, 255)
			djui_hud_print_text(text, boxX + 40, itemY, 0.5)
			djui_hud_print_text(value, boxX + boxW - 40 - (djui_hud_measure_text(value) * 0.45), itemY, 0.46)
		end
		
		if cooldownCounter > 0 then
			cooldownCounter = cooldownCounter - 1
		else
	        if dy < 0 then
	            selectedOption = wrap(selectedOption - 1, 1, #settings)
	            audio_stream_play(snd_menumove, true, 1)
	            cooldownCounter = cooldown
	        elseif dy > 0 then
	            selectedOption = wrap(selectedOption + 1, 1, #settings)
	            audio_stream_play(snd_menumove, true, 1)
	            cooldownCounter = cooldown
	        end
	  
			if settings[selectedOption].type == "number" or settings[selectedOption].type == "text" then
				local min = settings[selectedOption].type == "text" and 1 or settings[selectedOption].min
				local max = settings[selectedOption].type == "text" and #settings[selectedOption].texts or settings[selectedOption].max
				if dx < 0 then
					settings[selectedOption].value = wrap(settings[selectedOption].value-1, min, max)
					if settings[selectedOption].on_value_change then
						settings[selectedOption].on_value_change(settings[selectedOption].value)
					end
					if settings[selectedOption].nonsave ~= true then
						mod_storage_save_number(settings[selectedOption].save_id, settings[selectedOption].value)
					end
					audio_stream_play(snd_menumove, true, 1)
					cooldownCounter = cooldown
				end
				if dx > 0 then
					settings[selectedOption].value = wrap(settings[selectedOption].value+1, min, max)
					if settings[selectedOption].on_value_change then
						settings[selectedOption].on_value_change(settings[selectedOption].value)
					end
					if settings[selectedOption].nonsave ~= true then
						mod_storage_save_number(settings[selectedOption].save_id, settings[selectedOption].value)
					end
					audio_stream_play(snd_menumove, true, 1)
					cooldownCounter = cooldown
				end
			end
			if settings[selectedOption].type == "bool" and (math.abs(stick_x) > 30 or (m.controller.buttonPressed & A_BUTTON) ~= 0) then
				settings[selectedOption].value = not settings[selectedOption].value
				if settings[selectedOption].on_value_change then
					settings[selectedOption].on_value_change(settings[selectedOption].value)
				end
				if settings[selectedOption].nonsave ~= true then
					mod_storage_save_bool(settings[selectedOption].save_id, settings[selectedOption].value)
				end
				cooldownCounter = cooldown
				audio_stream_play(snd_menumove, true, 1)
			end
		end
		if (m.controller.buttonPressed & A_BUTTON) ~= 0 then
			if settings[selectedOption].type == "button" then
				if settings[selectedOption].func then settings[selectedOption].func() end
				audio_stream_play(snd_menuaccept, true, 1)
			end
		end
		if (m.controller.buttonPressed & B_BUTTON) ~= 0 then
			submenu = ""
			selectedOption = lastMenuSelected
			lerpOption = 1
			audio_stream_play(snd_menuback, true, 1)
		end
    elseif submenu == "vessels" then
    	for i,v in pairs(charList) do
			local vx = (screenOffset / 2) + 10 + (38 * ((i - 1) % 4))
			local vy = 10 + (38 * (math.floor((i - 1) / 4) - lerpOption))
			local sprite = v.sprites[1]["down"]
			local spr_w = (sprite.width or (sprite.texture.width / (sprite.length or 4)))
			djui_hud_set_color(255, 255, 255, i ~= selectedOption and 128 or 255)
			djui_hud_render_texture(vessel_icon, vx, vy, 1, 1)
			djui_hud_render_texture_tile(sprite.texture, vx + ((32 - spr_w) / 2), vy + (30 - math.floor(sprite.texture.height/1.5)), 1, 1, 0, 0, spr_w, math.floor(sprite.texture.height/1.5))
			if i == selectedOption then
				djui_hud_print_text(v.name, (screenOffset / 2)  + (38 * 4.25), 10, 0.5)
				djui_hud_set_color(255, 255, 255, 128)
				djui_hud_print_text(v.desc and v.desc:sub(1, math.floor(descChars)) or "", (screenOffset / 2)  + (38 * 4.25), 26, 0.4)
			end
		end
		lerpOption = math.lerp(lerpOption, math.max(math.floor(selectedOption / 4) - 3, 1) - 1, 0.15)
		
	    if cooldownCounter > 0 then
	        cooldownCounter = cooldownCounter - 1
	    else
	        if dx < 0 then
	            selectedOption = wrap(selectedOption - 1, 1, #charList)
				descChars = 1
	            audio_stream_play(snd_menumove, true, 1)
	            cooldownCounter = cooldown
	        elseif dx > 0 then
	            selectedOption = wrap(selectedOption + 1, 1, #charList)
	            audio_stream_play(snd_menumove, true, 1)
				descChars = 1
	            cooldownCounter = cooldown
	        end
			if dy < 0 then
	            selectedOption = wrap(selectedOption - 4, 1, #charList)
	            audio_stream_play(snd_menumove, true, 1)
				descChars = 1
	            cooldownCounter = cooldown
	        elseif dy > 0 then
	            selectedOption = wrap(selectedOption + 4, 1, #charList)
	            audio_stream_play(snd_menumove, true, 1)
				descChars = 1
	            cooldownCounter = cooldown
	        end
  	  end
  	  
  	  if charList[selectedOption].desc and descChars < #charList[selectedOption].desc then
			descChars = descChars + 0.5
			if descChars % 1 == 0 then
				audio_stream_play(snd_txt, true, 1)
			end
		end
  
  	  if m.controller.buttonPressed & A_BUTTON ~= 0 then
	        audio_stream_play(snd_menuaccept, true, 1)
  		  s.character = selectedOption
 		   s.costume = 1
			mod_storage_save("character", charList[s.character].name)
		end
		
	    if m.controller.buttonPressed & B_BUTTON ~= 0 then
	        audio_stream_play(snd_menuback, true, 1)
			submenu = ""
			selectedOption = lastMenuSelected
			lerpOption = 1
	    end
	elseif submenu == "warper" then
		for i,v in pairs(warps) do
			local textX = x
			local textY = 10 + (16 * (i - lerpOption))
			djui_hud_set_color(255, 255, 255, i ~= selectedOption and 128 or 255)
			djui_hud_print_text(v.name, textX, textY, 0.5)
			lerpOption = math.lerp(lerpOption, math.max(selectedOption - 13, 1), 0.15)
		end
		
	    if cooldownCounter > 0 then
	        cooldownCounter = cooldownCounter - 1
	    else
	        if dy < 0 then
	            selectedOption = wrap(selectedOption - 1, 1, #warps)
	            audio_stream_play(snd_menumove, true, 1)
	            cooldownCounter = cooldown
	        elseif dy > 0 then
	            selectedOption = wrap(selectedOption + 1, 1, #warps)
	            audio_stream_play(snd_menumove, true, 1)
	            cooldownCounter = cooldown
	        end
  	  end
  
  	  if m.controller.buttonPressed & A_BUTTON ~= 0 then
	        audio_stream_play(snd_menuaccept, true, 1)
  		  change_map(warps[selectedOption].map, warps[selectedOption].spawn)
		end
		
	    if m.controller.buttonPressed & B_BUTTON ~= 0 then
	        audio_stream_play(snd_menuback, true, 1)
			submenu = ""
			selectedOption = lastMenuSelected
			lerpOption = 1
	    end
	elseif submenu == "warp_dev" then
		local list = {}
		for i,v in pairs(maps) do
			table.insert(list, i)
		end
		
		for i,v in pairs(list) do
			local textX = x
			local textY = 10 + (16 * (i - lerpOption))
			djui_hud_set_color(255, 255, 255, i ~= selectedOption and 128 or 255)
			djui_hud_print_text(v, textX, textY, 0.5)
			lerpOption = math.lerp(lerpOption, math.max(selectedOption - 13, 1), 0.15)
		end
		
	    if cooldownCounter > 0 then
	        cooldownCounter = cooldownCounter - 1
	    else
	        if dy < 0 then
	            selectedOption = wrap(selectedOption - 1, 1, #list)
	            audio_stream_play(snd_menumove, true, 1)
	            cooldownCounter = cooldown
	        elseif dy > 0 then
	            selectedOption = wrap(selectedOption + 1, 1, #list)
	            audio_stream_play(snd_menumove, true, 1)
	            cooldownCounter = cooldown
	        end
  	  end
  
  	  if m.controller.buttonPressed & A_BUTTON ~= 0 then
	        audio_stream_play(snd_menuaccept, true, 1)
  		  change_map(list[selectedOption], "spawn")
		end
		
	    if m.controller.buttonPressed & B_BUTTON ~= 0 then
	        audio_stream_play(snd_menuback, true, 1)
			submenu = "options"
			selectedOption = 1
			lerpOption = 1
	    end
	elseif paused then
		if cooldownCounter > 0 then
	        cooldownCounter = cooldownCounter - 1
	    else
	        if dx < 0 then
	            selectedOption = wrap(selectedOption - 1, 1, #pauseMenuOptions)
	            audio_stream_play(snd_menumove, true, 1)
	            cooldownCounter = cooldown
	        elseif dx > 0 then
	            selectedOption = wrap(selectedOption + 1, 1, #pauseMenuOptions)
	            audio_stream_play(snd_menumove, true, 1)
	            cooldownCounter = cooldown
	        end
  	  end
  
	    lastMenuSelected = selectedOption
  
	    if m.controller.buttonPressed & A_BUTTON ~= 0 then
	        audio_stream_play(snd_menuaccept, true, 1)
	        local option = pauseMenuOptions[selectedOption]
	        if option and option.func then
	            option.func()
	        end
			if option and option.submenu then
	            submenu = option.submenu
				selectedOption = 1
				lerpOption = 1
				descChars = 1
	        end
	    end
	
		if m.controller.buttonPressed & B_BUTTON ~= 0 then
	        audio_stream_play(snd_menuback, true, 1)
	        close_menu()
	    end
	
		lerpOption = math.lerp(lerpOption, selectedOption, 0.15)
	end
end

local function pressed_pause()
    if get_dialog_id() >= 0 or (_G.charSelectExists and _G.charSelect.is_menu_open()) then
        return false
    end

    return m.controller.buttonPressed & START_BUTTON ~= 0
end

function before_mario_update()
    local rTrigPressed = m.controller.buttonPressed & R_TRIG ~= 0
    
    if m.controller.buttonPressed & L_TRIG ~= 0 and paused then
    	game_pause()
    	m.controller.buttonPressed = L_TRIG
    end

    if pressed_pause() then
        if not paused and not freezeControls then
            submenu = ""
            paused = true
            selectedOption = 1
        end
        m.controller.buttonPressed = 0
    elseif rTrigPressed and paused then
        djui_open_pause_menu()
        m.controller.buttonPressed = 0
        audio_stream_play(snd_menumove, true, 1)
    end
    
    if inTransition then
    	close_menu()
    end
end

hook_event(HOOK_ON_HUD_RENDER_BEHIND, hud_render)
hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)

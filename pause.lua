menu = ""

_G.is_game_paused = function() return menu ~= "" end

local selectedOption = 1
local lerpOption = 1

local function close_menu()
    if menu ~= "" then
        menu = ""
        m.controller.buttonPressed = 0
    end
end

local cooldown = 5
local cooldownCounter = 0

local pauseMenuOptions = {
    {name = "Resume", func = close_menu},
    {name = "Vessels", menu = "vessels"},
    {name = "Warps", menu = "warper"},
    {name = "Options", menu = "options"},
    {name = "Instructions", func = function()
    	show_warning_screen = true
		is_fading = false
		fade_alpha = 255
		close_menu()
	end},
}

local function hud_render()
    if menu == "" then return end

    djui_hud_set_resolution(RESOLUTION_N64)
    local sW, sH = djui_hud_get_screen_width(), djui_hud_get_screen_height()
    local stickY = m.controller.stickY
    local stickX = m.controller.stickX
    local x, y = 10 + (screenOffset / 2), sH - 96

    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(0, 0, sW + 20, sH)
    
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_set_font(FONT_SPECIAL)
    
    if menu == "pause" then
	    djui_hud_print_text(np.name, x, 10, 0.5)
		local f = s.hp / s.maxHP
		djui_hud_set_color(128, 0, 0, 255)
		djui_hud_render_rect(x+16, 32, 64, 12)
		djui_hud_set_color(255, 255, 0, 255)
		djui_hud_render_rect(x+16, 32, math.floor(64 * f), 12)
		djui_hud_set_color(255, 255, 255, 255)
		djui_hud_print_text("HP", x, 30, 0.45)
		djui_hud_print_text(math.floor(s.hp).."/"..math.floor(s.maxHP), x, 48, 0.45)
		
		for i,v in pairs(pauseMenuOptions) do
			local textX = x
			local textY = y + 16 * i
			djui_hud_set_color(255, 255, 255, i ~= selectedOption and 128 or 255)
			djui_hud_print_text(v.name, textX, textY, 0.5)
			lerpOption = math.lerp(lerpOption, selectedOption, 0.15)
		end
		
	    if cooldownCounter > 0 then
	        cooldownCounter = cooldownCounter - 1
	    else
	        if stickY > 30 then
	            selectedOption = wrap(selectedOption - 1, 1, #pauseMenuOptions)
	            audio_stream_play(snd_menumove, true, 1)
	            cooldownCounter = cooldown
	        elseif stickY < -30 then
	            selectedOption = wrap(selectedOption + 1, 1, #pauseMenuOptions)
	            audio_stream_play(snd_menumove, true, 1)
	            cooldownCounter = cooldown
	        end
  	  end
  
	    if m.controller.buttonPressed & A_BUTTON ~= 0 then
	        audio_stream_play(snd_menuaccept, true, 1)
	        local option = pauseMenuOptions[selectedOption]
	        if option and option.func then
	            option.func()
	        end
			if option and option.menu then
	            menu = option.menu
				selectedOption = 1
				lerpOption = 1
	        end
	    end
    elseif menu == "options" then
    	for i = 1, #settings do
			local v = settings[i]
			local text = v.name
			local value = ""
			if i == selectedOption then
				text = "> "..text
			end
			if v.type == "bool" then
				value = v.value and "ON" or "OFF"
			end
			if v.type == "number" then
				value = tostring(v.value)
			end
			if v.type == "text" then
				value = v.texts[v.value] or "-"
			end
			djui_hud_print_text(text, x, -6 + (16 * i), 0.5)
			djui_hud_print_text(value, djui_hud_get_screen_width() - (djui_hud_measure_text(value) / 2) - 10 - (screenOffset/2), -6 + (16 * i), 0.5)
		end
		
		if cooldownCounter > 0 then
			cooldownCounter = cooldownCounter - 1
		else
	        if stickY > 30 then
	            selectedOption = wrap(selectedOption - 1, 1, #pauseMenuOptions)
	            audio_stream_play(snd_menumove, true, 1)
	            cooldownCounter = cooldown
	        elseif stickY < -30 then
	            selectedOption = wrap(selectedOption + 1, 1, #pauseMenuOptions)
	            audio_stream_play(snd_menumove, true, 1)
	            cooldownCounter = cooldown
	        end
	  
			if settings[selectedOption].type == "number" or settings[selectedOption].type == "text" then
				local min = settings[selectedOption].type == "text" and 1 or settings[selectedOption].min
				local max = settings[selectedOption].type == "text" and #settings[selectedOption].texts or settings[selectedOption].max
				if stickX < -30 then
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
				if stickX > 30 then
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
			if settings[selectedOption].type == "bool" and math.abs(stickX) > 30 then
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
			menu = "pause"
			selectedOption = 1
			lerpOption = 1
			audio_stream_play(snd_menuback, true, 1)
		end
    elseif menu == "vessels" then
    	for i,v in pairs(charList) do
			local textX = x
			local textY = 10 + (38 * (i - lerpOption))
			local sprite = v.sprites[1]["down"]
			djui_hud_set_color(255, 255, 255, i ~= selectedOption and 128 or 255)
			djui_hud_render_texture(vessel_icon, textX, textY, 1, 1)
			djui_hud_render_texture_tile(sprite.texture, textX + ((32 - sprite.width) / 2), textY + (30 - math.floor(sprite.texture.height/1.5)), 1, 1, 0, 0, sprite.width, math.floor(sprite.texture.height/1.5))
			djui_hud_print_text(v.name, textX + 36, textY + 10, 0.5)
			lerpOption = math.lerp(lerpOption, math.max(selectedOption - 5, 1), 0.15)
		end
		
	    if cooldownCounter > 0 then
	        cooldownCounter = cooldownCounter - 1
	    else
	        if stickY > 30 then
	            selectedOption = wrap(selectedOption - 1, 1, #charList)
	            audio_stream_play(snd_menumove, true, 1)
	            cooldownCounter = cooldown
	        elseif stickY < -30 then
	            selectedOption = wrap(selectedOption + 1, 1, #charList)
	            audio_stream_play(snd_menumove, true, 1)
	            cooldownCounter = cooldown
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
			menu = "pause"
			selectedOption = 1
			lerpOption = 1
	    end
	elseif menu == "warper" then
		for i,v in pairs(warps) do
			local textX = x
			local textY = 10 + (38 * (i - lerpOption))
			djui_hud_print_text(v.name, textX, textY, 0.5)
			lerpOption = math.lerp(lerpOption, math.max(selectedOption - 13, 1), 0.15)
		end
		
	    if cooldownCounter > 0 then
	        cooldownCounter = cooldownCounter - 1
	    else
	        if stickY > 30 then
	            selectedOption = wrap(selectedOption - 1, 1, #charList)
	            audio_stream_play(snd_menumove, true, 1)
	            cooldownCounter = cooldown
	        elseif stickY < -30 then
	            selectedOption = wrap(selectedOption + 1, 1, #charList)
	            audio_stream_play(snd_menumove, true, 1)
	            cooldownCounter = cooldown
	        end
  	  end
  
  	  if m.controller.buttonPressed & A_BUTTON ~= 0 then
	        audio_stream_play(snd_menuaccept, true, 1)
  		  change_room(warps[selectedOption].map, warps[selectedOption].spawn)
		end
		
	    if m.controller.buttonPressed & B_BUTTON ~= 0 then
	        audio_stream_play(snd_menuback, true, 1)
			menu = "pause"
			selectedOption = 1
			lerpOption = 1
	    end
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

    if pressed_pause() then
        if menu == "" then
            menu = "pause"
            selectedOption = 1
            audio_stream_play(snd_menumove, true, 1)
        end
        m.controller.buttonPressed = 0
    elseif rTrigPressed and menu ~= "" then
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
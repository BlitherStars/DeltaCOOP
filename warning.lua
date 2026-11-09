show_warning_screen = true
is_fading = false
fade_alpha = 255

local function on_hud_render()
    if not show_warning_screen then return end

    if is_fading then
        fade_alpha = fade_alpha - 8
        if fade_alpha <= 0 then
            fade_alpha = 0
            show_warning_screen = false
            return
        end
    end

    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_font(FONT_SPECIAL)

    local screen_w = djui_hud_get_screen_width()
    local screen_h = djui_hud_get_screen_height()

    djui_hud_set_color(0, 0, 0, fade_alpha)
    djui_hud_render_rect(0, 0, screen_w, screen_h)
	
	if dev then
	    local top_text = "WARNING!"
	    local top_scale = 1
	    local top_w = djui_hud_measure_text(top_text) * top_scale
	    djui_hud_set_color(255, 160, 160, fade_alpha)
	    djui_hud_print_text(top_text, (screen_w - top_w) / 2, screen_h * 0.10, top_scale)
	
	    djui_hud_set_color(255, 255, 255, fade_alpha)
	    local mid_scale = 0.35
	    
	    local lines = {
			"Hey, If you're seeing this mod from",
	    	"another server that isn't from BlitherDev or ErickCatmanuel,",
	    	"then quickly report the player hosting!",
	    	"It is wrong to steal unreleased mods without permission from the authors.",
	    	"If it might be an impersonator,",
	    	"check the coopnet id, character and palette,",
			"Blither uses Luigi with dark green cap, shirt and shoes and red overalls.",
			"Erick uses Luigi/Toad with dark teal cap,",
			"seafoam gloves, teal overalls, moss shoes and cyan shirt.",
		}
	    
	    local mid_y = screen_h / 4
		
		for i,v in pairs(lines) do
	    	djui_hud_print_text(v, (screen_w - (djui_hud_measure_text(v)*mid_scale)) / 2, mid_y + 12 * i, mid_scale)
		end
		
	    local bottom_text = "Press A to close this."
	    local bot_scale = 0.5
	    local bot_w = djui_hud_measure_text(bottom_text) * bot_scale
	    djui_hud_set_color(255, 255, 255, fade_alpha)
	    djui_hud_print_text(bottom_text, (screen_w - bot_w) / 2, screen_h - 32, bot_scale)
	else
		local bottom_text = "Press A to start."
	    local bot_scale = 0.5
	    local bot_w = djui_hud_measure_text(bottom_text) * bot_scale
	    djui_hud_set_color(255, 255, 255, fade_alpha)
		djui_hud_print_text(bottom_text, (screen_w - bot_w) / 2, screen_h - 32, bot_scale)
		if logo then
			djui_hud_render_texture(logo, (screen_w - logo.width) / 2, 16, 1, 1)
		end
		djui_hud_set_color(128, 128, 128, fade_alpha)
	    local mid_scale = 0.35
	    
	    local lines = {
			"[ INSTRUCTIONS ]",
	    	"L - Change Skin",
			"B - Run",
			"X - Attack",
			"Y - Emotes",
			"",
	    	"Go to the Char Menu on Config",
			"to select a vessel/character",
			"",
	    	"Go to the Warp Menu on Config",
			"to go to a place",
		}
	    
	    local mid_y = screen_h / 4
		
		for i,v in pairs(lines) do
	    	djui_hud_print_text(v, (screen_w - (djui_hud_measure_text(v)*mid_scale)) / 2, mid_y + 10 * i, mid_scale)
		end
	end
	
	if show_warning_screen then
        if not is_fading and (m.controller.buttonPressed & A_BUTTON) ~= 0 then
            is_fading = true
            audio_stream_play(snd_menuaccept, true, 1)
        end
    end
end

hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
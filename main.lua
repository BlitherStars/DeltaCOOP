-- name: DeltaCoop [WIP]
-- description: IN MARIO 64???

dev = false
debug = false

useNametags = true
useDpad = false
autoRun = false

settings = {
	{
		save_id = "useNametags",
		name = "Show Nametags",
		type = "bool",
		value = useNametags,
		on_value_change = function(v)
			useNametags = v
		end,
	},
	{
		save_id = "useDpad",
		name = "DPad to Move",
		type = "bool",
		value = useDpad,
		on_value_change = function(v)
			useDpad = v
		end,
	},
	{
		save_id = "autoRun",
		name = "Auto-Run",
		type = "bool",
		value = autoRun,
		on_value_change = function(v)
			autoRun = v
		end,
	},
	{
		nonsave = true,
		name = "Reset Settings",
		type = "button",
		func = function(v)
			for i, v in pairs(settings) do
				settings[i].value = settings[i].default
				if v.on_value_change ~= nil then
					v.on_value_change(settings[i].value)
				end
				if settings[i].type == "bool" then
					if settings[i].nonsave ~= true then
						mod_storage_save_bool(settings[i].save_id, settings[i].value)
					end
				end
				if settings[i].type == "number" or settings[i].type == "text" then
					if settings[i].nonsave ~= true then
						mod_storage_save_number(settings[i].save_id, settings[i].value)
					end
				end
			end
		end,
	},
}

for i, v in pairs(settings) do
	settings[i].default = settings[i].value
	if not v.nonsave and mod_storage_exists(v.save_id) then
		if v.type == "bool" then
			settings[i].value = mod_storage_load_bool(v.save_id)
		end
		if v.type == "number" or v.type == "text" then
			settings[i].value = mod_storage_load_number(v.save_id)
		end
	end
	if settings[i].on_value_change ~= nil then
		settings[i].on_value_change(settings[i].value)
	end
end

snd_menumove = audio_stream_load("snd_menumove.mp3")
snd_menuback = audio_stream_load("snd_menuback.ogg")
snd_menuaccept = audio_stream_load("snd_menuaccept.ogg")

snd_txt = audio_stream_load("txt_default.ogg")

snd_slash = audio_stream_load("slash.ogg")
snd_damage = audio_stream_load("damage.ogg")

vessel_icon = get_texture_info("vessel_icon")
logo = get_texture_info("logo")

warps = {
	{
		name = "Kristal Castle",
		map = "map1",
		spawn = "spawn"
	},
}

maps = {
	["kristalcastle1"] = require("/maps/kristalcastle1"),
	["kristalcastle2"] = require("/maps/kristalcastle2"),
}

tilesets = {
	["castle"] = require("/tilesets/castle"),
}

charList = {
	{
		name = "Kris",
		boxW = 19,
		boxH = 38,
		sprites = {
			{
			    ["left"] = {
					texture = get_texture_info("kris_light_walk_left"),
					width = 19,
				},
				["down"] = {
					texture = get_texture_info("kris_light_walk_down"),
					width = 19,
				},
				["up"] = {
					texture = get_texture_info("kris_light_walk_up"),
					width = 19,
				},
				["right"] = {
					texture = get_texture_info("kris_light_walk_right"),
					width = 19,
				},
				["defeat"] = {
					other = true,
					texture = get_texture_info("kris_light_down"),
					width = 43,
					length = 1,
					fps = 1,
					loop = true,
				},
			},
			{
			    ["left"] = {
					texture = get_texture_info("kris_dark_walk_left"),
					width = 19,
				},
				["down"] = {
					texture = get_texture_info("kris_dark_walk_down"),
					width = 19,
				},
				["up"] = {
					texture = get_texture_info("kris_dark_walk_up"),
					width = 19,
				},
				["right"] = {
					texture = get_texture_info("kris_dark_walk_right"),
					width = 19,
				},
				["splat"] = {
					texture = get_texture_info("kris_dark_splat"),
					width = 35,
					length = 1,
					fps = 1,
					loop = true,
				},
				["attack"] = {
					other = true,
					texture = get_texture_info("kris_dark_attack"),
					width = 63,
					length = 7,
					fps = 12,
					offsetX = 16,
					offsetY = 6,
				},
				["defeat"] = {
					other = true,
					texture = get_texture_info("kris_dark_down"),
					width = 32,
					length = 1,
					fps = 1,
					loop = true,
				},
			},
		}
	},
	{
		name = "Susie",
		boxW = 26,
		boxH = 46,
		snd = audio_stream_load("txt_susie.ogg"),
		sprites = {
			{
			    ["left"] = {
					texture = get_texture_info("susie_light_walk_left"),
					width = 25,
				},
				["down"] = {
					texture = get_texture_info("susie_light_walk_down"),
					width = 25,
				},
				["up"] = {
					texture = get_texture_info("susie_light_walk_up"),
					width = 25,
				},
				["right"] = {
					texture = get_texture_info("susie_light_walk_right"),
					width = 25,
				},
				["laugh"] = {
					texture = get_texture_info("susie_light_laugh"),
					width = 36,
					length = 2,
					repeatAmount = 3,
					fps = 4,
					
					snd = audio_stream_load("susie_laugh.ogg"),
				},
				["shocked"] = {
					texture = get_texture_info("susie_light_shocked"),
					width = 29,
					length = 1,
					fps = 1,
					
					snd = audio_stream_load("susie_shocked.ogg"),
				},
				["look"] = {
					texture = get_texture_info("susie_light_look"),
					width = 47,
					length = 1,
					fps = 1,
					
					snd = audio_stream_load("slap.ogg"),
				},
				["defeat"] = {
					other = true,
					texture = get_texture_info("susie_light_down"),
					width = 43,
					length = 1,
					fps = 1,
					loop = true,
				},
			},
			{
			    ["left"] = {
					texture = get_texture_info("susie_dark_walk_left"),
					width = 25,
				},
				["down"] = {
					texture = get_texture_info("susie_dark_walk_down"),
					width = 26,
				},
				["up"] = {
					texture = get_texture_info("susie_dark_walk_up"),
					width = 26,
				},
				["right"] = {
					texture = get_texture_info("susie_dark_walk_right"),
					width = 25,
				},
				["laugh"] = {
					texture = get_texture_info("susie_dark_laugh"),
					width = 36,
					length = 2,
					repeatAmount = 3,
					fps = 4,
					
					snd = audio_stream_load("susie_laugh.ogg"),
				},
				["shocked"] = {
					texture = get_texture_info("susie_dark_shocked"),
					width = 41,
					length = 1,
					fps = 1,
					
					snd = audio_stream_load("susie_shocked.ogg"),
				},
				["look"] = {
					texture = get_texture_info("susie_dark_look"),
					width = 47,
					length = 1,
					fps = 1,
					
					snd = audio_stream_load("slap.ogg"),
				},
				["splat"] = {
					texture = get_texture_info("susie_dark_splat"),
					width = 49,
					length = 1,
					fps = 1,
					loop = true,
				},
				["attack"] = {
					other = true,
					texture = get_texture_info("susie_dark_attack"),
					width = 103,
					length = 6,
					fps = 12,
					offsetX = 16,
					offsetY = 2,
				},
				["defeat"] = {
					other = true,
					texture = get_texture_info("susie_dark_down"),
					width = 43,
					length = 1,
					fps = 1,
					loop = true,
				},
			},
		}
	},
	{
		name = "Noelle",
		boxW = 23,
		boxH = 48,
		snd = audio_stream_load("txt_noelle.ogg"),
		sprites = {
			{
			    ["left"] = {
					texture = get_texture_info("noelle_light_walk_left"),
					width = 23,
				},
				["down"] = {
					texture = get_texture_info("noelle_light_walk_down"),
					width = 23,
				},
				["up"] = {
					texture = get_texture_info("noelle_light_walk_up"),
					width = 23,
				},
				["right"] = {
					texture = get_texture_info("noelle_light_walk_right"),
					width = 23,
				}
			},
			{
			    ["left"] = {
					texture = get_texture_info("noelle_dark_walk_left"),
					width = 23,
				},
				["down"] = {
					texture = get_texture_info("noelle_dark_walk_down"),
					width = 23,
				},
				["up"] = {
					texture = get_texture_info("noelle_dark_walk_up"),
					width = 23,
				},
				["right"] = {
					texture = get_texture_info("noelle_dark_walk_right"),
					width = 23,
				},
				["attack"] = {
					other = true,
					texture = get_texture_info("noelle_dark_attack"),
					width = 37,
					length = 5,
					fps = 12,
				},
				["defeat"] = {
					other = true,
					texture = get_texture_info("noelle_dark_down"),
					width = 23,
					length = 1,
					fps = 1,
					loop = true,
				},
			},
		}
	},
	{
		name = "Ralsei",
		boxW = 23,
		boxH = 44,
		snd = audio_stream_load("txt_ralsei.ogg"),
		sprites = {
			{
			    ["left"] = {
					texture = get_texture_info("ralsei_walk_left"),
					width = 19,
				},
				["down"] = {
					texture = get_texture_info("ralsei_walk_down"),
					width = 21,
				},
				["up"] = {
					texture = get_texture_info("ralsei_walk_up"),
					width = 21,
				},
				["right"] = {
					texture = get_texture_info("ralsei_walk_right"),
					width = 19,
				},
				["splat"] = {
					texture = get_texture_info("ralsei_splat"),
					width = 47,
					length = 1,
					fps = 1,
					loop = true,
				},
				["attack"] = {
					other = true,
					texture = get_texture_info("ralsei_attack"),
					width = 77,
					length = 4,
					fps = 12,
					offsetX = 16,
					offsetY = 2,
				},
				["defeat"] = {
					other = true,
					texture = get_texture_info("ralsei_down"),
					width = 29,
					length = 1,
					fps = 1,
					loop = true,
				},
			},
			{
			    ["left"] = {
					texture = get_texture_info("ralsei_ch1_walk_left"),
					width = 23,
				},
				["down"] = {
					texture = get_texture_info("ralsei_ch1_walk_down"),
					width = 23,
				},
				["up"] = {
					texture = get_texture_info("ralsei_ch1_walk_up"),
					width = 23,
				},
				["right"] = {
					texture = get_texture_info("ralsei_ch1_walk_right"),
					width = 23,
				},
				["splat"] = {
					texture = get_texture_info("ralsei_ch1_splat"),
					width = 47,
					length = 1,
					fps = 1,
					loop = true,
				},
				["attack"] = {
					other = true,
					texture = get_texture_info("ralsei_ch1_attack"),
					width = 77,
					length = 6,
					fps = 12,
					offsetX = 16,
					offsetY = 2,
				},
				["defeat"] = {
					other = true,
					texture = get_texture_info("ralsei_ch1_down"),
					width = 29,
					length = 1,
					fps = 1,
					loop = true,
				},
			},
		}
	},
	{
		name = "Lancer",
		boxW = 36,
		boxH = 35,
		snd = audio_stream_load("txt_lancer.mp3"),
		sprites = {
			{
			    ["left"] = {
					texture = get_texture_info("lancer_left"),
					width = 36,
					length = 1,
				},
				["down"] = {
					texture = get_texture_info("lancer_down"),
					width = 36,
					length = 1,
				},
				["up"] = {
					texture = get_texture_info("lancer_up"),
					width = 36,
					length = 1,
				},
				["right"] = {
					texture = get_texture_info("lancer_right"),
					width = 36,
					length = 1,
				},
				["sleep"] = {
					texture = get_texture_info("lancer_sleep"),
					width = 36,
					length = 2,
					loop = true,
					fps = 1,
				},
			},
		}
	},
	{
			name = "Seth",
		boxW = 30,
		boxH = 41,
		sprites = {
			{
			    ["left"] = {
					texture = get_texture_info("seth_walk_left"),
					width = 35,
					length = 2,
				},
				["down"] = {
					texture = get_texture_info("seth_walk_down"),
					width = 35,
				},
				["up"] = {
					texture = get_texture_info("seth_walk_up"),
					width = 35,
				},
				["right"] = {
					texture = get_texture_info("seth_walk_right"),
					width = 35,
					length = 2,
				}
			},
		}
	},
	{
		name = "Orange",
		boxW = 20,
		boxH = 16,
		sprites = {
			{
			    ["left"] = {
					texture = get_texture_info("orange_walk_left"),
					width = 33,
				},
				["down"] = {
					texture = get_texture_info("orange_walk_down"),
					width = 24,
					length = 2,
				},
				["up"] = {
					texture = get_texture_info("orange_walk_up"),
					width = 24,
					length = 2,
				},
				["right"] = {
					texture = get_texture_info("orange_walk_right"),
					width = 33,
				},
				["attack"] = {
					texture = get_texture_info("orange_attack"),
					width = 59,
					length = 6,
					offsetX = 14,
					offsetY = 4,
					fps = 20,
					other = true,
				},
			},
		}
	},
	{
		name = "Pink",
		boxW = 23,
		boxH = 43,
		sprites = {
			{
			    ["left"] = {
					texture = get_texture_info("pink_walk_left"),
					width = 23,
				},
				["down"] = {
					texture = get_texture_info("pink_walk_down"),
					width = 33,
				},
				["up"] = {
					texture = get_texture_info("pink_walk_up"),
					width = 33,
				},
				["right"] = {
					texture = get_texture_info("pink_walk_right"),
					width = 23,
				},
				["laugh"] = {
					texture = get_texture_info("pink_laugh"),
					width = 31,
					length = 2,
					repeatAmount = 12,
					fps = 12,
					
					snd = audio_stream_load("pink_laugh.ogg"),
				},
				["shocked"] = {
					texture = get_texture_info("pink_shocked"),
					width = 32,
					length = 1,
					fps = 1,
					loop = true,
					
					snd = audio_stream_load("pink_gasp.ogg"),
				},
				["hey"] = {
					texture = get_texture_info("pink_hey"),
					width = 32,
					length = 1,
					fps = 1,
					loop = true,
				},
			},
		}
	},
}

m = gMarioStates[0]
s = gPlayerSyncTable[0]
np = gNetworkPlayers[0]

hook_event(HOOK_UPDATE, hud_hide)

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
			"Erick uses Mario with dark teal cap,",
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
			"",
	    	"Go to the Pause Menu, then Vessels",
			"to Change your Character",
			"",
	    	"Go to the Pause Menu, then Warps",
			"to go to a location",
			"(also check commands for emotes)"
		}
	    
	    local mid_y = screen_h / 4
		
		for i,v in pairs(lines) do
	    	djui_hud_print_text(v, (screen_w - (djui_hud_measure_text(v)*mid_scale)) / 2, mid_y + 12 * i, mid_scale)
		end
	end
end

local function on_mario_update(m)
    if m.playerIndex ~= 0 then return end 
    
    m.freeze = 1

    if show_warning_screen then
        if not is_fading and (m.controller.buttonPressed & A_BUTTON) ~= 0 then
            is_fading = true
            audio_stream_play(snd_menuaccept, true, 1)
        end
    end
    
    set_audio_muted(1)
end

hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
hook_event(HOOK_MARIO_UPDATE, on_mario_update)

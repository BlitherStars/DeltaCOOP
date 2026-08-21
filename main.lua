-- name: DeltaCoop [WIP]
-- description: IN MARIO 64???

_G.useNametags = true
_G.useDpad = false
_G.autoRun = false

gGlobalSyncTable.disablePVP = false

_G.snd_menumove = audio_stream_load("snd_menumove.mp3")
_G.snd_menuback = audio_stream_load("snd_menuback.ogg")
_G.snd_menuaccept = audio_stream_load("snd_menuaccept.ogg")

_G.snd_txt = audio_stream_load("txt_default.ogg")

_G.snd_slash = audio_stream_load("slash.ogg")
_G.snd_damage = audio_stream_load("damage.ogg")
snd_splat = audio_stream_load("splat.ogg")

vessel_icon = get_texture_info("vessel_icon")
logo = get_texture_info("logo")

BmFont = require("/lib/bmfont")
_G.FONT_OPERATOR = BmFont.load_sheet("font_operator", 16, 33, 14)

settings = {
	{
		save_id = "useNametags",
		name = "Show Nametags",
		type = "bool",
		value = useNametags,
		on_value_change = function(v)
			_G.useNametags = v
		end,
	},
	{
		save_id = "useDpad",
		name = "DPad to Move",
		type = "bool",
		value = useDpad,
		on_value_change = function(v)
			_G.useDpad = v
		end,
	},
	{
		save_id = "autoRun",
		name = "Auto-Run",
		type = "bool",
		value = autoRun,
		on_value_change = function(v)
			_G.autoRun = v
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

if network_is_server() then
	table.insert(settings, {
		save_id = "disablePVP",
		name = "Disable PVP",
		type = "bool",
		value = gGlobalSyncTable.disablePVP,
		on_value_change = function(v)
			gGlobalSyncTable.disablePVP = v
		end,
	})
end

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

warps = {
	{
		name = "Kristal Castle",
		map = "kristalcastle1",
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
				},
				["down"] = {
					texture = get_texture_info("kris_light_walk_down"),
				},
				["up"] = {
					texture = get_texture_info("kris_light_walk_up"),
				},
				["right"] = {
					texture = get_texture_info("kris_light_walk_right"),
				},
				["defeat"] = {
					other = true,
					texture = get_texture_info("kris_light_down"),
					length = 1,
					fps = 1,
					loop = true,
				},
			},
			{
			    ["left"] = {
					texture = get_texture_info("kris_dark_walk_left"),
				},
				["down"] = {
					texture = get_texture_info("kris_dark_walk_down"),
				},
				["up"] = {
					texture = get_texture_info("kris_dark_walk_up"),
				},
				["right"] = {
					texture = get_texture_info("kris_dark_walk_right"),
				},
				["splat"] = {
					texture = get_texture_info("kris_dark_splat"),
					length = 1,
					fps = 1,
					loop = true,
					snd = snd_splat,
				},
				["attack"] = {
					other = true,
					texture = get_texture_info("kris_dark_attack"),
					length = 7,
					fps = 12,
					offsetX = 16,
					offsetY = 6,
				},
				["defeat"] = {
					other = true,
					texture = get_texture_info("kris_dark_down"),
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
				},
				["down"] = {
					texture = get_texture_info("susie_light_walk_down"),
				},
				["up"] = {
					texture = get_texture_info("susie_light_walk_up"),
				},
				["right"] = {
					texture = get_texture_info("susie_light_walk_right"),
				},
				["laugh"] = {
					texture = get_texture_info("susie_light_laugh"),
					length = 2,
					repeatAmount = 3,
					fps = 4,
					
					snd = audio_stream_load("susie_laugh.ogg"),
				},
				["shocked"] = {
					texture = get_texture_info("susie_light_shocked"),
					length = 1,
					fps = 1,
					
					snd = audio_stream_load("susie_shocked.ogg"),
				},
				["look"] = {
					texture = get_texture_info("susie_light_look"),
					length = 1,
					fps = 1,
					
					snd = audio_stream_load("slap.ogg"),
				},
				["defeat"] = {
					other = true,
					texture = get_texture_info("susie_light_down"),
					length = 1,
					fps = 1,
					loop = true,
				},
			},
			{
			    ["left"] = {
					texture = get_texture_info("susie_dark_walk_left"),
				},
				["down"] = {
					texture = get_texture_info("susie_dark_walk_down"),
				},
				["up"] = {
					texture = get_texture_info("susie_dark_walk_up"),
				},
				["right"] = {
					texture = get_texture_info("susie_dark_walk_right"),
				},
				["laugh"] = {
					texture = get_texture_info("susie_dark_laugh"),
					length = 2,
					repeatAmount = 3,
					fps = 4,
					
					snd = audio_stream_load("susie_laugh.ogg"),
				},
				["shocked"] = {
					texture = get_texture_info("susie_dark_shocked"),
					length = 1,
					fps = 1,
					
					snd = audio_stream_load("susie_shocked.ogg"),
				},
				["look"] = {
					texture = get_texture_info("susie_dark_look"),
					length = 1,
					fps = 1,
					
					snd = audio_stream_load("slap.ogg"),
				},
				["splat"] = {
					texture = get_texture_info("susie_dark_splat"),
					length = 1,
					fps = 1,
					loop = true,
					snd = snd_splat,
				},
				["attack"] = {
					other = true,
					texture = get_texture_info("susie_dark_attack"),
					length = 6,
					fps = 12,
					offsetX = 16,
					offsetY = 2,
				},
				["defeat"] = {
					other = true,
					texture = get_texture_info("susie_dark_down"),
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
				},
				["down"] = {
					texture = get_texture_info("noelle_light_walk_down"),
				},
				["up"] = {
					texture = get_texture_info("noelle_light_walk_up"),
				},
				["right"] = {
					texture = get_texture_info("noelle_light_walk_right"),
				}
			},
			{
			    ["left"] = {
					texture = get_texture_info("noelle_dark_walk_left"),
				},
				["down"] = {
					texture = get_texture_info("noelle_dark_walk_down"),
				},
				["up"] = {
					texture = get_texture_info("noelle_dark_walk_up"),
				},
				["right"] = {
					texture = get_texture_info("noelle_dark_walk_right"),
				},
				["attack"] = {
					other = true,
					texture = get_texture_info("noelle_dark_attack"),
					length = 5,
					fps = 12,
				},
				["defeat"] = {
					other = true,
					texture = get_texture_info("noelle_dark_down"),
					length = 1,
					fps = 1,
					loop = true,
				},
			},
		}
	},
	{
		name = "Berdly",
		boxW = 22,
		boxH = 40,
		snd = audio_stream_load("txt_berd.ogg"),
		sprites = {
			{
			    ["left"] = {
					texture = get_texture_info("berdly_light_walk_left"),
				},
				["down"] = {
					texture = get_texture_info("berdly_light_walk_down"),
				},
				["up"] = {
					texture = get_texture_info("berdly_light_walk_up"),
				},
				["right"] = {
					texture = get_texture_info("berdly_light_walk_right"),
				},
			},
			{
			    ["left"] = {
					texture = get_texture_info("berdly_dark_walk_left"),
				},
				["down"] = {
					texture = get_texture_info("berdly_dark_walk_down"),
				},
				["up"] = {
					texture = get_texture_info("berdly_dark_walk_up"),
				},
				["right"] = {
					texture = get_texture_info("berdly_dark_walk_right"),
				},
				["nerd"] = {
					texture = get_texture_info("berdly_dark_nerd"),
					length = 1,
					fps = 1,
					loop = true,
				},
				["no"] = {
					texture = get_texture_info("berdly_dark_no"),
					length = 1,
					fps = 1,
					loop = true,
				},
				["shocked"] = {
					texture = get_texture_info("berdly_dark_shocked"),
					length = 1,
					fps = 1,
					loop = true,
				},
					["frozen"] = {
					texture = get_texture_info("berdly_dark_ripbozo"),
					length = 1,
					fps = 1,
					loop = true,
				},
				["attack"] = {
					other = true,
					texture = get_texture_info("berdly_dark_attack"),
					offsetX = 16,
				},
				["defeat"] = {
					other = true,
					texture = get_texture_info("berdly_dark_down"),
					length = 1,
					fps = 1,
					loop = true,
				},
			},
		}
	},
	{
		name = "Annoying Dog",
		boxW = 29,
		boxH = 42,
		sprites = {
			{
			    ["left"] = {
					texture = get_texture_info("annoying_dog_walk_left"),
					width = 42,
					length = 2,
				},
				["down"] = {
					texture = get_texture_info("annoying_dog_walk_down"),
					width = 42,
					length = 2,
				},
				["up"] = {
					texture = get_texture_info("annoying_dog_walk_up"),
					width = 42,
					length = 2,
				},
				["right"] = {
					texture = get_texture_info("annoying_dog_walk_right"),
					width = 42,
					length = 2,
				}
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
				},
				["down"] = {
					texture = get_texture_info("ralsei_walk_down"),
				},
				["up"] = {
					texture = get_texture_info("ralsei_walk_up"),
				},
				["right"] = {
					texture = get_texture_info("ralsei_walk_right"),
				},
				["splat"] = {
					texture = get_texture_info("ralsei_splat"),
					length = 1,
					fps = 1,
					loop = true,
					snd = snd_splat,
				},
				["attack"] = {
					other = true,
					texture = get_texture_info("ralsei_attack"),
					length = 4,
					fps = 12,
					offsetX = 16,
					offsetY = 2,
				},
				["defeat"] = {
					other = true,
					texture = get_texture_info("ralsei_down"),
					length = 1,
					fps = 1,
					loop = true,
				},
			},
			{
			    ["left"] = {
					texture = get_texture_info("ralsei_ch1_walk_left"),
				},
				["down"] = {
					texture = get_texture_info("ralsei_ch1_walk_down"),
				},
				["up"] = {
					texture = get_texture_info("ralsei_ch1_walk_up"),
				},
				["right"] = {
					texture = get_texture_info("ralsei_ch1_walk_right"),
				},
				["splat"] = {
					texture = get_texture_info("ralsei_ch1_splat"),
					length = 1,
					fps = 1,
					loop = true,
					snd = snd_splat,
				},
				["dummy"] = {
					texture = get_texture_info("dummy"),
					length = 1,
					fps = 1,
					loop = true,
					snd = snd_menuback,
				},
				["attack"] = {
					other = true,
					texture = get_texture_info("ralsei_ch1_attack"),
					length = 6,
					fps = 12,
					offsetX = 16,
					offsetY = 2,
				},
				["defeat"] = {
					other = true,
					texture = get_texture_info("ralsei_ch1_down"),
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
					length = 1,
				},
				["down"] = {
					texture = get_texture_info("lancer_down"),
					length = 1,
				},
				["up"] = {
					texture = get_texture_info("lancer_up"),
					length = 1,
				},
				["right"] = {
					texture = get_texture_info("lancer_right"),
					length = 1,
				},
				["sleep"] = {
					texture = get_texture_info("lancer_sleep"),
					length = 2,
					loop = true,
					fps = 1,
				},
				["laugh"] = {
					texture = get_texture_info("lancer_laugh"),
					length = 2,
					repeatAmount = 12,
					fps = 12,
					
					snd = audio_stream_load("snd_lancerlaugh.ogg"),
				},
			},
		}
	},
	{
		name = "Rouxls Kaard",
		boxW = 24,
		boxH = 57,
		snd = audio_stream_load("txt_lancer.mp3"),
		sprites = {
			{
			    ["left"] = {
					texture = get_texture_info("roulxs_kaard"),
					length = 1,
				},
				["down"] = {
					texture = get_texture_info("roulxs_kaard"),
					length = 1,
				},
				["up"] = {
					texture = get_texture_info("roulxs_kaard"),
					length = 1,
				},
				["right"] = {
					texture = get_texture_info("roulxs_kaard"),
					length = 1,
				},
			},
		}
	},
{
		name = "Addison",
		boxW = 25,
		boxH = 45,
		sprites = {
			{
			    ["left"] = {
					texture = get_texture_info("addison_walk_left"),
					width = 45,
					length = 2,
				},
				["down"] = {
					texture = get_texture_info("addison_walk_down"),
					width = 45,
					length = 2,
				},
				["up"] = {
					texture = get_texture_info("addison_walk_up"),
					width = 45,
					length = 2,
				},
				["right"] = {
					texture = get_texture_info("addison_walk_right"),
					width = 45,
					length = 2,
				}
			},
		}
	},
	{
		name = "Flowery",
		boxW = 24,
		boxH = 59,
		sprites = {
			{
			    ["left"] = {
					texture = get_texture_info("flowery_walk_left"),
				},
				["down"] = {
					texture = get_texture_info("flowery_walk_down"),
				},
				["up"] = {
					texture = get_texture_info("flowery_walk_up"),
				},
				["right"] = {
					texture = get_texture_info("flowery_walk_right"),
				},
				["attack"] = {
					texture = get_texture_info("flowery_attack"),
					length = 4,
					offsetX = 14,
					offsetY = 0,
					fps = 12,
					other = true,
				},
			},
		}
	},
	{
		name = "Aqua",
		boxW = 20,
		boxH = 36,
		sprites = {
			{
			    ["left"] = {
					texture = get_texture_info("aqua_walk_left"),
				},
				["down"] = {
					texture = get_texture_info("aqua_walk_down"),
				},
				["up"] = {
					texture = get_texture_info("aqua_walk_up"),
				},
				["right"] = {
					texture = get_texture_info("aqua_walk_right"),
				}
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
					length = 2,
				},
				["down"] = {
					texture = get_texture_info("seth_walk_down"),
				},
				["up"] = {
					texture = get_texture_info("seth_walk_up"),
				},
				["right"] = {
					texture = get_texture_info("seth_walk_right"),
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
				},
				["down"] = {
					texture = get_texture_info("orange_walk_down"),
					length = 2,
				},
				["up"] = {
					texture = get_texture_info("orange_walk_up"),
					length = 2,
				},
				["right"] = {
					texture = get_texture_info("orange_walk_right"),
				},
				["attack"] = {
					texture = get_texture_info("orange_attack"),
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
		name = "Green",
		boxW = 32,
		boxH = 48,
		sprites = {
			{
			    ["left"] = {
					texture = get_texture_info("green_walk"),
				},
				["down"] = {
					texture = get_texture_info("green_walk"),
				},
				["up"] = {
					texture = get_texture_info("green_walk"),
				},
				["right"] = {
					texture = get_texture_info("green_walk"),
				},
				["attack"] = {
					texture = get_texture_info("green_attack"),
					length = 4,
					fps = 12,
					other = true,
				}
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
				},
				["down"] = {
					texture = get_texture_info("pink_walk_down"),
				},
				["up"] = {
					texture = get_texture_info("pink_walk_up"),
				},
				["right"] = {
					texture = get_texture_info("pink_walk_right"),
				},
				["laugh"] = {
					texture = get_texture_info("pink_laugh"),
					length = 2,
					repeatAmount = 12,
					fps = 12,
					
					snd = audio_stream_load("pink_laugh.ogg"),
				},
				["shocked"] = {
					texture = get_texture_info("pink_shocked"),
					length = 1,
					fps = 1,
					loop = true,
					
					snd = audio_stream_load("pink_gasp.ogg"),
				},
				["hey"] = {
					texture = get_texture_info("pink_hey"),
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

local customHooks = {}
local old_hook_event = hook_event
function new_hook_event(hook, call)
	if hook < HOOK_MAX then
		old_hook_event(hook, call)
	else
		if not customHooks[hook] then
			customHooks[hook] = {}
		end
		table.insert(customHooks[hook], call)
	end
end

_G.hook_event = new_hook_event

function call_custom_hook(hook, ...)
	if not customHooks[hook] then return end
	for i, func in pairs(customHooks[hook]) do
		func(...)
	end
end

_G.HOOK_TILEMAP_RENDER = HOOK_MAX + 1
_G.HOOK_DC_UI_RENDER = HOOK_MAX + 2
_G.HOOK_QUEUE_RENDER = HOOK_MAX + 3
_G.HOOK_DELTA_OBJ_PROCESS = HOOK_MAX + 4
_G.HOOK_BEFORE_WORLD_RENDER = HOOK_MAX + 5
_G.HOOK_DC_DEATH = HOOK_MAX + 5

hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
hook_event(HOOK_MARIO_UPDATE, on_mario_update)

dev = false
debug = false -- for the collisions

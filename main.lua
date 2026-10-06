-- name: DeltaCoop [WIP]
-- description: IN MARIO 64???

-- MOD LIST --
modList = {}
for i = 1, #gActiveMods do
    if gActiveMods[i] and gActiveMods[i].name and gActiveMods[i].name ~= get_active_mod().name then
        table.insert(modList, tostring(gActiveMods[i].name))
    end
end

-- CONFIG VARS --
useNametags = true
useDpad = false
autoRun = false

showCollisions = false
noclip = false

gGlobalSyncTable.disablePVP = false

-- ASSETS --
snd_ominous = audio_sample_load("snd_ominous.ogg")
snd_ominous_cancel = audio_sample_load("snd_ominous_cancel.ogg")

snd_menumove = audio_stream_load("snd_menumove.mp3")
snd_menuback = audio_stream_load("snd_menuback.ogg")
snd_menuaccept = audio_stream_load("snd_menuaccept.ogg")
snd_save = audio_stream_load("save.ogg")

snd_txt = audio_stream_load("txt_default.ogg")

snd_slash = audio_stream_load("slash.ogg")
snd_damage = audio_stream_load("damage.ogg")
snd_splat = audio_stream_load("splat.ogg")

vessel_icon = get_texture_info("vessel_icon")
logo = get_texture_info("logo")
textbox = get_texture_info("textbox")
soul = get_texture_info("heart")

FONT_SPECIAL = new_font(get_texture_info("font_operator"), [[ !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~¡¢£¥©«®°±µ¶·»¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ]], -1, 16, 32)
FONT_NAME = new_font(get_texture_info("font_name"), " ABCDEFGHIJKLMNOPQRSTUVWXYZ", -1, 11, 18)
FONT_TINYNUM = new_font(get_texture_info("font_tinynum"), " 0123456789+-%/.einfa", -1, 9, 10)

-- SETTINGS --
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
}

if _G.cheatsApi then
	table.insert(settings, {
		save_id = "showCollisions",
		name = "Show Collisions [DEBUG]",
		type = "bool",
		value = showCollisions,
		nonsave = true,
		on_value_change = function(v)
			showCollisions = v
		end,
	})
	table.insert(settings, {
		save_id = "noclip",
		name = "NoClip [DEBUG]",
		type = "bool",
		value = noclip,
		nonsave = true,
		on_value_change = function(v)
			noclip = v
		end,
	})
	table.insert(settings, {
		nonsave = true,
		name = "Warp To...",
		type = "button",
		func = function(v)
			submenu = "warp_dev"
			selectedOption = 1
			lerpOption = 1
		end,
	})
end

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
	table.insert(settings, {
		save_id = "accelMovement",
		name = "Accelerative Movement",
		type = "bool",
		value = gGlobalSyncTable.accelMovement,
		on_value_change = function(v)
			gGlobalSyncTable.accelMovement = v
		end,
	})
end

table.insert(settings, {
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
})

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

-- WARP LIST --
warps = {
	{
		name = "Fieldy Place (Lobby)",
		map = "lobby1",
		spawn = "spawn"
	},
}

-- MAP LIST --
entryMap = "lobby1"
maps = {
	["lobby1"] = require("/maps/lobby1"),
	["lobby2"] = require("/maps/lobby2"),
}

-- MAP TILESETS --
tilesets = {
	["castle"] = require("/tilesets/castle"),
	["field"] = require("/tilesets/field"),
	["forest"] = require("/tilesets/forest"),
}

-- PRESETS --
propPresets = {
	["savepoint"] = {
		["sprite"] = {
			texture = "savepoint",
			length = 6,
			fps = 6,
			loop = true,
		},
		["solid"] = true,
		["dialog"] = {
			{
				func = function()
					saveMenuCd = 5
					inSaveMenu = true
					saveMenuSel = 1
					saveMenuHasSelected = false
					nextDialog()
				end
			}
		}
	},
}

-- CHARACTERS --
charList = {
	{
		name = "Kris",
		desc = "* The first hero.\nThe Cage, with human soul\nand parts!",
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
				["hapi"] = {
					texture = get_texture_info("kris_light_hapi"),
					length = 1,
					fps = 1,
					loop = true,
					
					snd = audio_stream_load("snd_hapi.ogg"),
				},
				["splat"] = {
					texture = get_texture_info("kris_light_splat"),
					length = 1,
					loop = true,
					speed = 1,
					fps = 1,
					snd = snd_splat,
				},
				["diagonall"] = {
					texture = get_texture_info("kris_light_diagonal_left"),
					length = 1,
					fps = 1,
					loop = true,
				},
				["diagonalr"] = {
					texture = get_texture_info("kris_light_diagonal_right"),
					length = 1,
					fps = 1,
					loop = true,
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
					speed = 1,
					snd = snd_splat,
				},
				["dog_act"] = {
					texture = get_texture_info("kris_dark_idonttrustmyplayerbasewiththis"),
					length = 1,
					fps = 1,
					loop = true,
				},
				["dance_act"] = {
					texture = get_texture_info("kris_dark_dance"),
					length = 4,
					fps = 8,
					loop = true,
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
		desc = "* The second hero.\nThe girl, with hope crossed\non her heart.",
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
					loop = true,
					
					snd = audio_stream_load("slap.ogg"),
				},
				["diagonall"] = {
					texture = get_texture_info("susie_light_diagonal_left"),
					length = 1,
					fps = 1,
					loop = true,
				},
				["diagonalr"] = {
					texture = get_texture_info("susie_light_diagonal_right"),
					length = 1,
					fps = 1,
					loop = true,
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
					speed = 1,
					snd = snd_splat,
				},
				["chomp"] = {
					texture = get_texture_info("susie_dark_chomp"),
					length = 2,
					fps = 10,
					loop = true,
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
		desc = "* Coldwater fell from\nthe top of the sky.",
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
				},
				["scream"] = {
					texture = get_texture_info("noelle_light_scream"),
					length = 11,
					fps = 19,
					persistent = true,
					
					snd = audio_stream_load("snd_noelle_scared.ogg")
				},
				["hapi"] = {
					texture = get_texture_info("noelle_light_hapi"),
					length = 1,
					fps = 1,
					loop = true,
					
					snd = audio_stream_load("snd_hapi.ogg"),
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
				["hapi"] = {
					texture = get_texture_info("noelle_dark_hapi"),
					length = 1,
					fps = 1,
					loop = true,
					
					snd = audio_stream_load("snd_hapi.ogg"),
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
		desc = "* Valiant warrior of\nbrave intelligence!",
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
				["nerd"] = {
					texture = get_texture_info("berdly_light_nerd"),
					length = 1,
					fps = 1,
					loop = true,
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
		name = "Carol",
		desc = "* YOU Are welcome here \nanytime.",
		boxW = 26,
		boxH = 49,
		sprites = {
			{
			    ["left"] = {
					texture = get_texture_info("carol_walk_left"),
				},
				["down"] = {
					texture = get_texture_info("carol_walk_down"),
				},
				["up"] = {
					texture = get_texture_info("carol_walk_up"),
				},
				["right"] = {
					texture = get_texture_info("carol_walk_right"),
				}
			},
		}
	},
	{
		name = "Ralsei",
		desc = "* The third hero.\nThe prince, alone in the\ndeepest dark.",
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
					speed = 1,
					snd = snd_splat,
				},
				["nuzzle_act"] = {
					texture = get_texture_info("ralsei_nuzzle"),
					length = 8,
					fps = 8,
					loop = true,
				},
				["sing"] = {
					texture = get_texture_info("ralsei_sing"),
					length = 3,
					repeatAmount = 6,
					fps = 8,
					
					snd = audio_stream_load("snd_ralseising1.ogg")
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
					speed = 1,
					snd = snd_splat,
				},
				["dummy"] = {
					texture = get_texture_info("dummy"),
					length = 1,
					fps = 1,
					loop = true,
					speed = 1,
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
		name = "Annoying Dog",
		desc = "* bark bark",
		boxW = 29,
		boxH = 42,
		forceAccel = true,
		speedMult = 2,
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
		name = "Lancer",
		desc = '* The pointy headed will\nsay "TOOTHPASTE," and then\n"BOY."',
		boxW = 25,
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
				["tuba"] = {
					texture = get_texture_info("lancer_tuba"),
					length = 2,
					loop = true,
					speed = 1,
					fps = 8,
					
					snd = audio_stream_load("lancer_annoying.ogg")
				},
				["bike"] = {
					texture = get_texture_info("lancer_bike"),
					length = 6,
					loop = true,
					speed = 8,
					fps = 15,
					canFlip = true,
					
					snd = audio_stream_load("snd_lancerwhistle.ogg")
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
		name = "Rudinn",
		desc = "* A diamond in\nthe rough.",
		boxW = 20,
		boxH = 37,
		sprites = {
			{
			    ["left"] = {
					texture = get_texture_info("rudinn_walk_left"),
				},
				["down"] = {
					texture = get_texture_info("rudinn_walk_down"),
				},
				["up"] = {
					texture = get_texture_info("rudinn_walk_up"),
				},
				["right"] = {
					texture = get_texture_info("rudinn_walk_right"),
				}
			},
		}
	},
	{
		name = "Hathy",
		desc = "* A soft and gentle kiss.",
		boxW = 20,
		boxH = 38,
		sprites = {
			{
			    ["left"] = {
					texture = get_texture_info("hathy_walk_left"),
				},
				["down"] = {
					texture = get_texture_info("hathy_walk_left"),
				},
				["up"] = {
					texture = get_texture_info("hathy_walk_left"),
				},
				["right"] = {
					texture = get_texture_info("hathy_walk_right"),
				}
			},
		}
	},
	{
		name = "Jigsawry",
		desc = "* BARRY! THEY GOT\nBARRY!",
		boxW = 25,
		boxH = 29,
		sprites = {
			{
			    ["left"] = {
					texture = get_texture_info("jigsawry_walk"),
					length = 6,
				},
				["down"] = {
					texture = get_texture_info("jigsawry_walk"),
					length = 6,
				},
				["up"] = {
					texture = get_texture_info("jigsawry_walk"),
					length = 6,
				},
				["right"] = {
					texture = get_texture_info("jigsawry_walk"),
					length = 6,
				},
				["clobbered"] = {
					texture = get_texture_info("jigsawry_clobbered"),
					length = 1,
					fps = 1,
					loop = true,
					snd = snd_splat,
				},
				["theygotbarry"] = {
					texture = get_texture_info("jigsawry_barry"),
					length = 1,
					fps = 1,
					loop = true,
				},
				["defeat"] = {
					texture = get_texture_info("jigsawry_down"),
					length = 1,
					fps = 1,
					loop = true,
					other = true,
				},
			},
		}
	},
	{
		name = "Rudinn Ranger",
		desc = "* Likes throwing knifes.",
		boxW = 20,
		boxH = 37,
		sprites = {
			{
			    ["left"] = {
					texture = get_texture_info("rudinn_ranger_walk_left"),
				},
				["down"] = {
					texture = get_texture_info("rudinn_ranger_walk_left"),
				},
				["up"] = {
					texture = get_texture_info("rudinn_ranger_walk_up"),
				},
				["right"] = {
					texture = get_texture_info("rudinn_ranger_walk_right"),
				}
			},
		}
	},
	{
		name = "Rouxls Kaard",
		desc = "* Chips Ahoyeth Worms!",
		boxW = 24,
		boxH = 57,
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
		name = "Starwalker",
		desc = "* I'm the original      \nStarwalker",
		boxW = 24,
		boxH = 30,
		sprites = {
			{
			    ["left"] = {
					texture = get_texture_info("starwalker"),
					length = 1,
				},
				["down"] = {
					texture = get_texture_info("starwalker"),
					length = 1,
				},
				["up"] = {
					texture = get_texture_info("starwalker"),
					length = 1,
				},
				["right"] = {
					texture = get_texture_info("starwalker"),
					length = 1,
				},
			},
			{
			    ["left"] = {
					texture = get_texture_info("tropical_starwalker"),
					length = 1,
				},
				["down"] = {
					texture = get_texture_info("tropical_starwalker"),
					length = 1,
				},
				["up"] = {
					texture = get_texture_info("tropical_starwalker"),
					length = 1,
				},
				["right"] = {
					texture = get_texture_info("tropical_starwalker"),
					length = 1,
				},
			},
			{
			    ["left"] = {
					texture = get_texture_info("final_starwalker"),
					length = 1,
				},
				["down"] = {
					texture = get_texture_info("final_starwalker"),
					length = 1,
				},
				["up"] = {
					texture = get_texture_info("final_starwalker"),
					length = 1,
				},
				["right"] = {
					texture = get_texture_info("final_starwalker"),
					length = 1,
				},
			},
		}
	},
	{
		name = "Addison",
		desc = "* Spamton.... He's\n , well.",
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
		desc = "* It's me, Flowery!",
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
					
					snd = audio_stream_load("snd_flowery_voiceclip_jarona.mp3"),
				},
				["laddery"] = {
					texture = get_texture_info("flowery_laddery"),
					length = 1,
					loop = true,
				},
				["signery"] = {
					texture = get_texture_info("flowery_signery"),
					length = 1,
					loop = true,
					
					snd = audio_stream_load("snd_flowery_voiceclip_yes.mp3"),
				},
				["point"] = {
					texture = get_texture_info("flowery_pose_point"),
					length = 1,
					loop = true,
				},
				["pose"] = {
					texture = get_texture_info("flowery_pose"),
					length = 1,
					loop = true,
				},
				["kneel"] = {
					texture = get_texture_info("flowery_kneel"),
					length = 1,
					loop = true,
					
					snd = audio_stream_load("snd_flowery_voiceclip_hey.mp3"),
				},
			},
		}
	},
	{
		name = "Aqua",
		desc = "* Ooo, Are we playing a \nscreaming game?\nAAAAAAAAAAAAAAAAAAA",
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
				},
				["sit"] = {
					texture = get_texture_info("aqua_sit"),
					loop = true,
					length = 6,
				},
				["dance"] = {
					texture = get_texture_info("aqua_dance"),
					loop = true,
					fps = 8,
				},
				["hey"] = {
					texture = get_texture_info("aqua_hey"),
					loop = true,
					length = 6,
				},
				["wave"] = {
					texture = get_texture_info("aqua_wave"),
					loop = true,
					length = 4,
					loop = true,
				},
				["defeat"] = {
					other = true,
					texture = get_texture_info("aqua_down"),
					length = 1,
				},
				["spin"] = {
					texture = get_texture_info("aqua_spin"),
					length = 5,
					loop = true,
				},
				["bored"] = {
					texture = get_texture_info("aqua_bored"),
					length = 1,
					loop = true,
				},
				["no"] = {
					texture = get_texture_info("aqua_no"),
					length = 4,
					loop = true
				},
			},
		}
	},
	{
		name = "Seth",
		desc = "* Aqua, do\n THAT Attack!",
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
				},
				["upset"] = {
					texture = get_texture_info("seth_upset"),
					length = 1,
					loop = true,
				},
				["despair"] = {
					texture = get_texture_info("seth_despair"),
					length = 1,
					loop = true,
				},
				["collapsed"] = {
					texture = get_texture_info("seth_collapsed"),
					length = 1,
					loop = true,
				},
			},
		}
	},
	{
		name = "Yellow",
		desc = "* Hey there, pardner!",
		boxW = 27,
		boxH = 32,
		sprites = {
			{
			    ["right"] = {
					texture = get_texture_info("yellow_walk_left"),
				},
				["down"] = {
					texture = get_texture_info("yellow_walk_down"),
				},
				["up"] = {
					texture = get_texture_info("yellow_walk_up"),
				},
				["left"] = {
					texture = get_texture_info("yellow_walk_right"),
				},
				["waitamin"] = {
					texture = get_texture_info("yellow_waita"),
					length = 1,
					loop = true,
				},
				["shocked"] = {
					texture = get_texture_info("yellow_shocked"),
					length = 1,
					loop = true,
				},
				["waitamin"] = {
					texture = get_texture_info("yellow_waita"),
					length = 1,
					loop = true,
				},
				["wave"] = {
					texture = get_texture_info("yellow_hello"),
					length = 2,
					loop = true,
					fps = 6,
				},
				["defeat"] = {
					texture = get_texture_info("yellow_down"),
					length = 1,
					loop = true,
				},
			},
		}
	},
	{
		name = "Blue",
		desc = "* ...",
		boxW = 20,
		boxH = 60,
		sprites = {
			{
			    ["left"] = {
					texture = get_texture_info("blue_walk_left"),
					width = 49,
				},
				["down"] = {
					texture = get_texture_info("blue_walk_left"),
					width = 49,
				},
				["up"] = {
					texture = get_texture_info("blue_walk_up"),
					width = 49,
				},
				["right"] = {
					texture = get_texture_info("blue_walk_right"),
					width = 49,
				}
			},
		}
	},
	{
		name = "Orange",
		desc = "* SHUT UP\n CHIBI!",
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
				["thumbs_down"] = {
					texture = get_texture_info("orange_thumbs_down"),
					length = 1,
					loop = true,
				},
			},
		}
	},
	{
		name = "Green",
		desc = "* ...",
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
		desc = "* The prettiest of all\n flowers, PINK!",
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

-- CUSTOM HOOKS --
local customHooks = {}
local old_hook_event = hook_event
function new_hook_event(hook, call)
	if hook < OLD_HOOK_MAX then
		old_hook_event(hook, call)
	else
		if not customHooks[hook] then customHooks[hook] = {} end
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

OLD_HOOK_MAX = HOOK_MAX
function allocate_hook()
	_G.HOOK_MAX = HOOK_MAX + 1
	return HOOK_MAX - 1
end

_G.HOOK_TILEMAP_RENDER = allocate_hook()
_G.HOOK_DC_UI_RENDER = allocate_hook()
_G.HOOK_QUEUE_RENDER = allocate_hook()
_G.HOOK_DELTA_OBJ_PROCESS = allocate_hook()
_G.HOOK_BEFORE_WORLD_RENDER = allocate_hook()
_G.HOOK_DC_DEATH = allocate_hook()
_G.HOOK_ON_PVP_ATTACK = allocate_hook()

-- OTHER --
m = gMarioStates[0]
s = gPlayerSyncTable[0]
np = gNetworkPlayers[0]

hud_hide()










































dev = false

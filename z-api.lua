_G.Survey = {
	newVessel = function(data)
		table.insert(charList, data)
		return #charList
	end,
	newCostume = function(name, data)
		local id = type(name) == "number" and name or get_vessel_from_str(name)
		if id < 1 then return -1 end
		table.insert(charList[id].sprites, data)
		return #charList[id].sprites
	end,
	getVessel = function(name)
		local id = type(name) == "number" and name or get_vessel_from_str(name)
		if id < 1 then return -1 end
		return charList[id]
	end,
	getVesselNum = get_vessel_num_from_str,
	
	newTileset = function(name, data)
		tilesets[name] = data
	end,
	newMap = function(name, data)
		maps[name] = data
		if data.properties and data.properties["music"] and type(data.properties["music"]) == "string" then
			maps[name].properties["music"] = audio_stream_load(data.properties["music"]..".ogg")
		end
	end,
	getMap = function(name)
		return maps[name]
	end,
	getTileset = function(name)
		return tilesets[name]
	end,
	
	newWarp = function(name, map, spawn)
		table.insert(warps, {name = name, map = map, spawn = spawn})
		return #warps
	end,
	getWarp = function(id)
		return warps[id] or nil
	end,
	
	playAnim = playAnim,
	nextDialog = nextDialog,
	getOptionValue = function(name)
		for i, v in pairs(options) do
			if v.id == name then
				return v.value
			end
		end
	end,
	
	inBattle = false,
	
	assets = {
		snd_ominous = snd_ominous,
		snd_ominous_cancel = snd_ominous_cancel,
		
		snd_menumove = snd_menumove,
		snd_menuback = snd_menuback,
		snd_menuaccept = snd_menuaccept,
		snd_save = snd_save,
		
		snd_txt = snd_txt,
		
		snd_slash = snd_slash,
		snd_damage = snd_damage,
		snd_splat = snd_splat,
		
		vessel_icon = vessel_icon,
		logo = logo,
		textbox = textbox,
		soul = soul
	}
}

_G.gDeltaPlayerSyncTable = gPlayerSyncTable
_G.gDeltaSyncTable = gGlobalSyncTable
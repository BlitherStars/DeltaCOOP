_G.SURVEY_INTERFACE = {
	NEW_VESSEL = function(data)
		table.insert(charList, data)
		return #charList
	end,
	NEW_COSTUME = function(name, data)
		local id = type(name) == "number" and name or get_vessel_from_str(name)
		if id < 1 then return -1 end
		table.insert(charList[id].sprites, data)
		return #charList[id].sprites
	end,
	GET_VESSEL = function(name)
		local id = type(name) == "number" and name or get_vessel_from_str(name)
		if id < 1 then return -1 end
		return charList[id]
	end,
	GET_VESSEL_NUM = get_vessel_num_from_str,
	
	NEW_TILESET = function(name, data)
		tilesets[name] = data
	end,
	NEW_MAP = function(name, data)
		maps[name] = data
		if maps[name].properties["music"] and type(maps[name].properties["music"]) == "string" then
			maps[name].properties["music"] = audio_stream_load(maps[name].properties["music"]..".ogg")
		end
	end,
	GET_MAP = function(name)
		return maps[name]
	end,
	GET_TILESET = function(name)
		return tilesets[name]
	end,
	
	NEW_WARP = function(name, map, spawn)
		table.insert(warps, {name = name, map = map, spawn = spawn})
		return #warps
	end,
	GET_WARP = function(id)
		return warps[id] or nil
	end,
	
	PLAY_ANIM = playAnim,
	NEXT_DIALOG = nextDialog,
	
	inBattle = false,
}

_G.SURVEY = SURVEY_INTERFACE

_G.gDeltaPlayerSyncTable = gPlayerSyncTable
_G.gDeltaSyncTable = gGlobalSyncTable
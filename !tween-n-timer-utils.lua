easeTypes = {
	["sineIn"] = IN_SINE,
	["sineOut"] = OUT_SINE,
	["sineInOut"] = IN_OUT_SINE,
	["sineOutIn"] = OUT_IN_SINE,
	["quadIn"] = IN_QUAD,
	["quadOut"] = OUT_QUAD,
	["quadInOut"] = IN_OUT_QUAD,
	["quadOutIn"] = OUT_IN_QUAD,
	["cubicIn"] = IN_CUBIC,
	["cubicOut"] = OUT_CUBIC,
	["cubicInOut"] = IN_OUT_CUBIC,
	["cubicOutIn"] = OUT_IN_CUBIC,
	["quartIn"] = IN_QUART,
	["quartOut"] = OUT_QUART,
	["quartInOut"] = IN_OUT_QUART,
	["quartOutIn"] = OUT_IN_QUART,
	["quintIn"] = IN_QUINT,
	["quintOut"] = OUT_QUINT,
	["quintInOut"] = IN_OUT_QUINT,
	["quintOutIn"] = OUT_IN_QUINT,
	["expoIn"] = IN_EXPO,
	["expoOut"] = OUT_EXPO,
	["expoInOut"] = IN_OUT_EXPO,
	["expoOutIn"] = OUT_IN_EXPO,
	["circIn"] = IN_CIRC,
	["circOut"] = OUT_CIRC,
	["circInOut"] = IN_OUT_CIRC,
	["circOutIn"] = OUT_IN_CIRC,
	["backIn"] = IN_BACK,
	["backOut"] = OUT_BACK,
	["backInOut"] = IN_OUT_BACK,
	["backOutIn"] = OUT_IN_BACK,
	["elasticIn"] = IN_ELASTIC,
	["elasticOut"] = OUT_ELASTIC,
	["elasticInOut"] = IN_OUT_ELASTIC,
	["elasticOutIn"] = OUT_IN_ELASTIC,
	["bounceIn"] = IN_BOUNCE,
	["bounceOut"] = OUT_BOUNCE,
	["bounceInOut"] = IN_OUT_BOUNCE,
	["bounceOutIn"] = OUT_IN_BOUNCE,
}

local tweens = {}

function tween_start(name, from, to, duration, easingType, updateCallback, endCallback)
	tweens[name] = {
		points = {from, to},
		elapsed = 0,
		length = math.floor((duration*30)+0.5),
		value = from,
		updateCallback = updateCallback,
		endCallback = endCallback,
		ease = easingType or "linear",
		paused = false,
	}
end

function tween_cancel(name)
	tweens[name] = nil
end

function tween_pause(name)
	tweens[name].paused = true
end

function tween_resume(name)
	tweens[name].paused = false
end

function tween_get_data(name)
	return tweens[name]
end

local function tween_update()
	for index in pairs(tweens) do
		if tweens[index] and not tweens[index].paused then
			tweens[index].elapsed = tweens[index].elapsed + 1
			if easeTypes[tweens[index].ease] then
				tweens[index].value = math.tween(easeTypes[tweens[index].ease], tweens[index].points[1], tweens[index].points[2], tweens[index].elapsed / tweens[index].length) 
			else
				tweens[index].value = math.lerp(tweens[index].points[1], tweens[index].points[2], tweens[index].elapsed / tweens[index].length)
			end
			if tweens[index].updateCallback and tweens[index].value ~= nil then
				tweens[index].updateCallback(tweens[index].value)
			end
			if tweens[index].elapsed >= tweens[index].length then
				if tweens[index].endCallback and tweens[index].value ~= nil then
					tweens[index].endCallback(tweens[index])
				end
				tweens[index] = nil
			end
		end
	end
end

hook_event(HOOK_UPDATE, tween_update)

local timers = {}

function timer_start(name, duration, callback)
	timers[name] = {
		time = math.floor((duration*30)+0.5),
		callback = callback,
		paused = false,
	}
end

function timer_cancel(name)
	timers[name] = nil
end

function timer_pause(name)
	timers[name].paused = true
end

function timer_resume(name)
	timers[name].paused = false
end

function timer_get_data(name)
	return timers[name]
end

local function timer_update()
	for index in pairs(timers) do
		if timers[index] ~= nil and not timers[index].paused then
			timers[index].time = timers[index].time - 1
			if timers[index].time <= 0 then
				if timers[index].callback ~= nil then
					timers[index].callback(timers[index])
				end
				timers[index] = nil
			end
		end
	end
end

hook_event(HOOK_UPDATE, timer_update)
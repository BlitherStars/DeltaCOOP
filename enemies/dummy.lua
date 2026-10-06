-- example 1: a mario head falls --
local function test1()
	local time = 0
	for i = 0, 15 do
		timer_start("dumbBulletzers"..i, time, function()
			local dumbBullet = SURVEY_ENCOUNTER.NEW_BULLET("marioBullet", gTextures.mario_head, math.random(math.floor(arenaBox.x), math.floor(arenaBox.x + arenaBox.width - 16)), 4, 1, 1)
			dumbBullet.velY = 0
			dumbBullet.accelY = 0.5
			dumbBullet.velX = 1 * math.random(-1,1)
		end)
		time = time + 1 - (0.05 * i)
	end
	return (time * 30) + 5
end

-- example 2: mario follows your soul --
local dumbBullet2 = {}
local function test2()
	table.insert(dumbBullet2, SURVEY_ENCOUNTER.NEW_BULLET("marioBullet", gTextures.mario_head, 32, 32, 0.5, 0.5))
	return 5 * 30
end
local function test2_update()
	for _, bul in pairs(dumbBullet2) do
		--bul.x = math.lerp(bul.x, soulObj.x + math.random(-32, 32), math.random(1, 10)/100)
		--bul.y = math.lerp(bul.y, soulObj.y + math.random(-32, 32), math.random(1, 10)/100)
	end
end
hook_event(HOOK_UPDATE, test2_update)

return {
	name = "Dummy",
	sprites = {
		["idle"] = {
			texture = get_texture_info("dummy"),
			length = 1,
			loop = true,
		},
	},
	wave = function(self)
		local waves = {
			test1,
			test2,
		}
		return waves[math.random(1,#waves)]()
	end,
}
-- example 1: mario does a simple thing --
local function test1()
	local dumbBullet = SURVEY_ENCOUNTER.NEW_BULLET("marioBullet", gTextures.mario_head, -16, -16, 0.5, 2)
	tween_start("bulletMoveX", dumbBullet.x, 32, 0.5, "expoOut", function(v) dumbBullet.x = v end)
	tween_start("bulletMoveY", dumbBullet.y, 32, 0.5, "expoOut", function(v) dumbBullet.y = v end)
	timer_start("dumbBulletWow", 0.5, function()
		tween_start("bulletMoveX", dumbBullet.x, soulObj.x, 0.5, "backIn", function(v) dumbBullet.x = v end)
		tween_start("bulletMoveY", dumbBullet.y, soulObj.y, 0.5, "backIn", function(v) dumbBullet.y = v end)
		timer_start("dumbBulletWow2", 1, function()
			SURVEY_ENCOUNTER.END_WAVE()
		end)
	end)
end

-- example 2: mario follows your soul --
local dumbBullet2 = {}
local function test2()
	table.insert(dumbBullet2, SURVEY_ENCOUNTER.NEW_BULLET("marioBullet", gTextures.mario_head, 32, 32, 0.5, 0.5))
	
	timer_start("dumbBulletWow", 5, function()
		SURVEY_ENCOUNTER.END_WAVE()
	end)
end
local function test2_update()
	for _, bul in pairs(dumbBullet2) do
		bul.x = math.lerp(bul.x, soulObj.x + math.random(-32, 32), math.random(1, 10)/100)
		bul.y = math.lerp(bul.y, soulObj.y + math.random(-32, 32), math.random(1, 10)/100)
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
			--test1,
			test2,
		}
		waves[math.random(1,#waves)]()
	end,
}
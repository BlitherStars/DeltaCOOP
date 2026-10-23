-- example 1: a mario head falls --
local d = 0
local function test1()
	local time = 0
	for i = 0, 15 do
		timer_start("dumbBulletzers"..i.."_"..d, time, function()
			local dumbBullet = Bullet:new(math.random(math.floor(Battle.bulletArena.x), math.floor(Battle.bulletArena.x + Battle.bulletArena.width - 16)), 4, gTextures.mario_head)
			dumbBullet.vel.y = 0
			dumbBullet.accel.y = 0.5
			dumbBullet.vel.x = 1 * math.random(-1,1)
			Battle.addBullet(dumbBullet)
		end)
		time = time + 1 - (0.05 * i)
	end
	d = d + 1
	return (time * 30) + 5
end

-- example 2: mario follows your soul --
local dumbBullet2 = {}
local function test2()
	local b = Bullet:new(32, 32, gTextures.mario_head)
	b.scale.x = 0.5
	b.scale.y = 0.5
	b.breakable = false
	Battle.addBullet(b)
	table.insert(dumbBullet2, b)
	return 5 * 30
end
local function test2_update()
	if not Battle then
		return 
	end
	for _, bul in pairs(dumbBullet2) do
		bul.x = math.lerp(bul.x, Battle.soul.x + math.random(-32, 32), math.random(1, 10)/100)
		bul.y = math.lerp(bul.y, Battle.soul.y + math.random(-32, 32), math.random(1, 10)/100)
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
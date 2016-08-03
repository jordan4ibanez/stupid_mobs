local superpi = math.pi * 2 

local mob   = {
	physical     = true,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1, 0.4},
	visual = "mesh",
	mesh = "mobs_sheep.x",
	textures = {"mobs_sheep.png"},
	--automatic_face_movement_dir = 0.0,
	yaw = 0,
	turnspeed = 0,
	jump = false,
	fall = false,
	timer = 0,
}
--punch function
function mob.on_punch(self)
	self.object:remove()
end

--right click function
function mob.on_rightclick(self, clicker)
	self.turnspeed = (math.random(1,10) * 0.01) * math.random(-1,1)
end

--when the entity is created in world
function mob.on_activate(self, staticdata, dtime_s)
	self.object:setacceleration({x=0,y=-10,z=0})
	self.object:set_animation(
		{x=81,y=100},15, 0)
end

--what the minecart does in the world
function mob.on_step(self, dtime)
	self.timer = self.timer + dtime
	if self.timer > 2 then
		self.turnspeed = (math.random(1,10) * 0.01) * math.random(-1,1)
		self.timer = 0
	end
	self.yaw = self.yaw + self.turnspeed
	--correct to not create extreme numbers when turning
	if self.yaw > superpi then
		self.yaw = self.yaw - superpi
	elseif self.yaw < 0 then
		self.yaw = superpi - self.yaw 
	end

	self.object:setyaw(self.yaw)
	local x = math.sin(self.yaw) * -1 -- * speed
	local z = math.cos(self.yaw) * 1
	
	local vel = self.object:getvelocity()
	if (vel.x == 0 or vel.z == 0) and self.jump == false then
		print("jump")
		vel.y = 5
		self.jump = true
	elseif self.jump == true and vel.y == 0 and self.fall == true then
		self.jump = false
	else
		if vel.y < 0 then
			self.fall = true
		end
	end
	self.object:setvelocity({x=x,y=vel.y,z=z})
	self.object:setyaw(self.yaw)
end

minetest.register_entity("stupid_mobs:mob", mob)



minetest.override_item("default:stick", {
	on_place = function(itemstack, placer, pointed_thing)
		minetest.add_entity(pointed_thing.above, "stupid_mobs:mob")
	end,
})

--spawners
minetest.register_decoration({
	deco_type = "simple",
	place_on = "default:dirt_with_grass",
	sidelen = 8,
	fill_ratio = 0.001,
	decoration = "stupid_mobs:spawner",
	height = 1,
})

minetest.register_node("stupid_mobs:spawner", {
	description = "Shouldn't Have This",
	tiles = {"invisible_node.png","invisible_node.png","invisible_node.png","invisible_node.png","invisible_node.png","invisible_node.png"},
	drawtype = "glasslike",
	walkable = false,
	sunlight_propagates = true,
	buildable_to = true,
})
minetest.register_lbm({
	name = "stupid_mobs:mob_spawner",
	nodenames = {"stupid_mobs:spawner"},
	run_at_every_load = true,
	action = function(pos, node)
		minetest.remove_node(pos)
		minetest.add_entity(pos, "stupid_mobs:mob")
	end,
})
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
	makes_footstep_sound = true,
	stepheight = 1, --2 for not jumping
	collide_with_objects = false,
}
--punch function
function mob.on_punch(self)
	self.object:set_properties({mesh = "mobs_sheep_shaved.x", textures = {"mobs_sheep_shaved.png"}})
end

--right click function
function mob.on_rightclick(self, clicker)
	self.turnspeed = (math.random(1,10) * 0.01) * math.random(-1,1)
end

--when the entity is created in world
function mob.on_activate(self, staticdata, dtime_s)
	self.object:set_armor_groups({immortal = 1})
	self.object:setacceleration({x=0,y=-10,z=0})
	self.yaw = math.random()*math.random(0,6) -- will be corrected if over 6.28
	self.object:set_animation({x=81,y=100},15, 0)
	local pos = self.object:getpos()
	minetest.add_particlespawner({
		 amount = 40,
		 time = 0.1,
		 minpos = {x=pos.x-0.5, y=pos.y, z=pos.z-0.5},
		 maxpos = {x=pos.x+0.5, y=pos.y+1, z=pos.z+0.5},
		 minvel = {x=0, y=1, z=0},
		 maxvel = {x=0, y=2, z=0},
		 minacc = {x=0, y=0, z=0},
		 maxacc = {x=0, y=0, z=0},
		 minexptime = 1,
		 maxexptime = 1,
		 minsize = 1,
		 maxsize = 2,
		 collisiondetection = false,
		 vertical = false,
		 texture = "spawn_smoke.png",
	})
	minetest.sound_play("poof", {
		pos = pos,
		max_hear_distance = 100,
		gain = 10.0,
	})
end
function mob.get_staticdata(self)
	return minetest.serialize({
		timer = self.timer,

	})
end

--what the minecart does in the world
function mob.on_step(self, dtime)
	self.timer = self.timer + dtime
	---self.object:set_properties({visual_size = {x=self.timer, y=self.timer}})
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
	
	
	--jumping
	local vel = self.object:getvelocity()
	if (math.abs(vel.x)+0.1 < math.abs(x) or math.abs(vel.z)+0.1 < math.abs(z)) and self.jump == false then
		vel.y = 5
		self.jump = true
		self.fall = false
	--when landing, reset jump to false
	elseif self.jump == true and vel.y == 0 and self.fall == true then
		self.jump = false
	else
		--when falling, set fall to true
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

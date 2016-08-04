--the lightest mobs you can get
--built on simple mobs, with assets from simplemobs[pilzadam], mobs redo[tenplus1],mob spawn eggs[thefamilygrog66]

local superpi = math.pi * 2 
stupid_mobs_collide_with_each_other = false
stupid_mobs_chunksize = minetest.get_mapgen_params().chunksize


function register_stupid_mob(name, def)
	minetest.register_entity("stupid_mobs:"..name, {
	
	physical     = true,
	collisionbox = def.collisionbox,
	visual       = def.visual, --do this for "node monsters"
	mesh         = def.mesh,
	textures     = def.textures,
	hostile      = def.hostile,
	--automatic_face_movement_dir = -90.0, -- this is glitchy
	yaw = 0,
	turnspeed = 0,
	jump = false,
	fall = false,
	timer = 0,
	makes_footstep_sound = true,
	stepheight = 1, --2 for not jumping
	collide_with_objects = stupid_mobs_collide_with_each_other,
	
	--punch function
	on_punch = function(self)
		self.object:set_properties({mesh = "mobs_sheep_shaved.x", textures = {"mobs_sheep_shaved.png"}})
	end,

	--right click function
	on_rightclick = function(self, clicker)
		self.turnspeed = (math.random(1,10) * 0.01) * math.random(-1,1)
	end,

	--when the entity is created in world
	on_activate = function(self, staticdata, dtime_s)
		self.object:set_armor_groups({immortal = 1})
		self.object:setacceleration({x=0,y=-10,z=0})
		self.yaw = math.random()*math.random(0,6) -- will be corrected if over 6.28
		self.object:set_animation({x=def.walk_start,y=def.walk_end},def.normal_speed, 0)
		local pos = self.object:getpos()
		self.old_node = {x=math.floor(pos.x),y=math.floor(pos.y),z=math.floor(pos.z)}
		--Only do this when using a net/netball/or mob spawner
		--[[
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
		]]--
	end,
	get_staticdata = function(self)
		return minetest.serialize({
			timer = self.timer,

		})
	end,

	--what the minecart does in the world
	on_step = function(self, dtime)
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
		elseif vel.y < 0 then
			self.fall = true
		elseif self.jump == true and self.fall == true and vel.y == 0 then
			self.jump = false
			self.fall = false
		end
		self.object:setvelocity({x=x,y=vel.y,z=z})
		self.object:setyaw(self.yaw)
	end,
	})

	--spawners
	minetest.register_decoration({
		deco_type = "simple",
		place_on = def.spawn_on,
		sidelen = stupid_mobs_chunksize,--8
		fill_ratio = def.fill_ratio,--0.001
		decoration = "stupid_mobs:spawner_"..name,
		height = 1,
	})

	minetest.register_node("stupid_mobs:spawner_"..name, {
		description = "Shouldn't Have This",
		tiles = {"invisible_node.png","invisible_node.png","invisible_node.png","invisible_node.png","invisible_node.png","invisible_node.png"},
		drawtype = "glasslike",
		walkable = false,
		sunlight_propagates = true,
		buildable_to = true,
	})
	minetest.register_lbm({
		name = "stupid_mobs:mob_spawner_"..name,
		nodenames = {"stupid_mobs:spawner_"..name},
		run_at_every_load = true,
		action = function(pos, node)
			minetest.remove_node(pos)
			minetest.add_entity(pos, "stupid_mobs:"..name)
		end,
	})
	--spawnegg
	minetest.register_craftitem("stupid_mobs:"..name.."_spawn_egg",{
		description = name.." Spawn Egg",
		inventory_image = "spawn_egg.png",
		on_place = function(itemstack, placer, pointed_thing)
			minetest.add_entity(pointed_thing.above, "stupid_mobs:"..name)
		end,
	})
end
register_stupid_mob("sheep", {
--self params
collisionbox = {-0.4, -0.01, -0.4, 0.4, 1, 0.4},
visual       = "mesh",
mesh         = "mobs_sheep.x",
textures     = {"mobs_sheep.png"},

--animation params
normal_speed = 15,
stand_start  = 0,
stand_end    = 80,
walk_start   = 81,
walk_end     = 100,

--world/behavior params
hostile      = false,
spawn_on     = "default:dirt_with_grass",
fill_ratio   = 0.001, --amount of mobs to spawn

})

register_stupid_mob("cow", {
--self params
collisionbox = {-0.4, -0.01, -0.4, 0.4, 1, 0.4},
visual       = "mesh",
mesh         = "mobs_cow.x",
textures     = {"mobs_cow.png"},

--animation params
normal_speed = 15,
stand_start  = 0,
stand_end    = 30,
walk_start   = 35,
walk_end     = 65,

--world/behavior params
hostile      = false,
spawn_on     = "default:dirt_with_grass",
fill_ratio   = 0.001, --amount of mobs to spawn 

})

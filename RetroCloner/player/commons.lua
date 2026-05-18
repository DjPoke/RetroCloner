-- blocks types
blocks_types = {
	"background",
	"wall",
	"platform",
	"stairs",
	"death",
	"eatable"
}

-- types of player, with animations and parameters
player_types = {
	-- platformer
	{
		name = "platformer",
		idle = 0,
		walk = 0,
		jump = 0,
		climb = 0,
		hit = 0,
		die = 0,
		hflip = false,
		wound = 1,
		collision_box_x = 1,
		collision_box_y = 1,
		scale = 1
	},
	-- beat'em up
	{
		name = "beat'em up",
		idle = 0,
		walk = 0,
		jump = 0,
		punch = 0,
		kick = 0,
		jumping_kick = 0,
		wounded = 0,
		die = 0,
		hflip = false,
		wound = 1,
		collision_box_x = 1,
		collision_box_y = 1,
		scale = 1
	},
	-- run & gun (edge view)
	{
		name = "run & gun (edge view)",
		idle = 0,
		run = 0,
		jump = 0,
		fire1 = 0,
		fire2 = 0,
		crouch = 0,
		crouched_fire = 0,
		die = 0,
		hflip = false,
		wound = 1,
		collision_box_x = 1,
		collision_box_y = 1,
		scale = 1,
		weapon1 = 0,
		collision_box1 = 2,
		weapon2 = 0,
		collision_box2 = 2
	},
	-- run & gun (top view)
	{
		name = "run & gun (top view)",
		idle = 0,
		run = 0,
		fire1 = 0,
		fire2 = 0,
		die = 0,
		directions = 8,
		wound = 1,
		collision_box_x = 1,
		collision_box_y = 1,
		scale = 1,
		weapon1 = 0,
		collision_box1 = 2,
		weapon2 = 0,
		collision_box2 = 2
	},
	-- maze & chase
	{
		name = "maze & chase",
		idle = 0,
		move = 0,
		die = 0,
		wound = 1,
		collision_box_x = 1,
		collision_box_y = 1,
		scale = 1
	},
	-- fixed shooter
	{
		name = "fixed shooter",
		idle = 0,
		move = 0,
		fire1 = 0,
		die = 0,
		wound = 1,
		collision_box_x = 1,
		collision_box_y = 1,
		scale = 1,
		weapon1 = 0,
		collision_box1 = 2
	},
	-- horizontal shooter
	{
		name = "horizontal shooter",
		idle = 0,
		move = 0,
		fire1 = 0,
		fire2 = 0,
		die = 0,
		hflip = false,
		wound = 1,
		collision_box_x = 1,
		collision_box_y = 1,
		scale = 1,
		weapon1 = 0,
		collision_box1 = 2,
		weapon2 = 0,
		collision_box2 = 2
	},
	-- vertical shooter
	{
		name = "vertical shooter",
		idle = 0,
		move = 0,
		fire1 = 0,
		fire2 = 0,
		die = 0,
		vflip = false,
		wound = 1,
		collision_box_x = 1,
		collision_box_y = 1,
		scale = 1,
		weapon1 = 0,
		collision_box1 = 2,
		weapon2 = 0,
		collision_box2 = 2
	}
}

-- player animations and parameters
player_animations = {
	-- platformer
	{
		{parameter = "idle", infos = "idle animation"},
		{parameter = "walk", infos = "walk animation"},
		{parameter = "jump", infos = "jump animation"},
		{parameter = "climb", infos = "climb animation"},
		{parameter = "hit", infos = "hit animation"},
		{parameter = "die", infos = "die animation"},
		{parameter = "hflip", infos = "horizontal flipping is possible ?"},
		{parameter = "wound", infos = "wound points withdrawn from the opponent"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"},
		{parameter = "scale", infos = "scale value"}
	},
	-- beat'em up
	{
		{parameter = "idle", infos = "idle animation"},
		{parameter = "walk", infos = "walk animation"},
		{parameter = "jump", infos = "jump animation"},
		{parameter = "punch", infos = "punch animation"},
		{parameter = "kick", infos = "kick animation"},
		{parameter = "jumping_kick", infos = "jumping kick animation"},
		{parameter = "wounded", infos = "wounded animation"},
		{parameter = "die", infos = "die animation"},
		{parameter = "hflip", infos = "horizontal flipping is possible ?"},
		{parameter = "wound", infos = "wound points withdrawn from the opponent"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"},
		{parameter = "scale", infos = "scale value"}
	},
	-- run & gun (edge view)
	{
		{parameter = "idle", infos = "idle animation"},
		{parameter = "run", infos = "run animation"},
		{parameter = "jump", infos = "jump animation"},
		{parameter = "fire1", infos = "fire1 animation"},
		{parameter = "fire2", infos = "fire2 animation"},
		{parameter = "crouch", infos = "crouch animation"},
		{parameter = "crouched_fire", infos = "crouched fire animation"},
		{parameter = "die", infos = "die animation"},
		{parameter = "hflip", infos = "horizontal flipping is possible ?"},
		{parameter = "wound", infos = "wound points withdrawn from the opponent"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"},
		{parameter = "scale", infos = "scale value"},
		{parameter = "weapon1", infos = "weapon1 animation"},
		{parameter = "collision_box1", infos = "weapon1 collision box reducer"},
		{parameter = "weapon2", infos = "weapon2 animation"},
		{parameter = "collision_box2", infos = "weapon2 collision box reducer"}
	},
	-- run & gun (top view)
	{	
		{parameter = "idle", infos = "idle animation"},
		{parameter = "run", infos = "run animation"},
		{parameter = "fire1", infos = "fire1 animation"},
		{parameter = "fire2", infos = "fire2 animation"},
		{parameter = "die", infos = "die animation"},
		{parameter = "directions", infos = "possible directions"},
		{parameter = "wound", infos = "wound points withdrawn from the opponent"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"},
		{parameter = "scale", infos = "scale value"},
		{parameter = "weapon1", infos = "weapon1 animation"},
		{parameter = "collision_box1", infos = "weapon1 collision box reducer"},
		{parameter = "weapon2", infos = "weapon2 animation"},
		{parameter = "collision_box2", infos = "weapon2 collision box reducer"}
	},
	-- maze & chase
	{
		{parameter = "idle", infos = "idle animation"},
		{parameter = "move", infos = "move animation"},
		{parameter = "die", infos = "die animation"},
		{parameter = "wound", infos = "wound points withdrawn from the opponent"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"},
		{parameter = "scale", infos = "scale value"}
	},
	-- fixed shooter
	{
		{parameter = "idle", infos = "idle animation"},
		{parameter = "move", infos = "move animation"},
		{parameter = "die", infos = "die animation"},
		{parameter = "wound", infos = "wound points withdrawn from the opponent"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"},
		{parameter = "scale", infos = "scale value"},
		{parameter = "weapon1", infos = "weapon1 animation"},
		{parameter = "collision_box1", infos = "weapon1 collision box reducer"}
	},
	-- horizontal shooter
	{
		{parameter = "idle", infos = "idle animation"},
		{parameter = "move", infos = "move animation"},
		{parameter = "fire1", infos = "fire1 animation"},
		{parameter = "fire2", infos = "fire2 animation"},
		{parameter = "die", infos = "die animation"},
		{parameter = "hflip", infos = "horizontal flipping is possible ?"},
		{parameter = "wound", infos = "wound points withdrawn from the opponent"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"},
		{parameter = "scale", infos = "scale value"},
		{parameter = "weapon1", infos = "weapon1 animation"},
		{parameter = "collision_box1", infos = "weapon1 collision box reducer"},
		{parameter = "weapon2", infos = "weapon2 animation"},
		{parameter = "collision_box2", infos = "weapon2 collision box reducer"}
	},
	-- vertical shooter
	{
		{parameter = "idle", infos = "idle animation"},
		{parameter = "move", infos = "move animation"},
		{parameter = "fire1", infos = "fire1 animation"},
		{parameter = "fire2", infos = "fire2 animation"},
		{parameter = "die", infos = "die animation"},
		{parameter = "vflip", infos = "vertical flipping is possible ?"},
		{parameter = "wound", infos = "wound points withdrawn from the opponent"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"},
		{parameter = "scale", infos = "scale value"},
		{parameter = "weapon1", infos = "weapon1 animation"},
		{parameter = "collision_box1", infos = "weapon1 collision box reducer"},
		{parameter = "weapon2", infos = "weapon2 animation"},
		{parameter = "collision_box2", infos = "weapon2 collision box reducer"}
	}
}

-- maximum size (in screens) for the levels, by player types
player_levels_max_size = {
	{w = 16, h = 1},
	{w = 16, h = 1},
	{w = 16, h = 16},
	{w = 16, h = 16},
	{w = 1, h = 1},
	{w = 1, h = 1},
	{w = 16, h = 1},
	{w = 1, h = 16}
}


-- types of enemies, with animations and parameters
enemy_types = {
	-- static
	{
		name = "static",
		idle = 0,
		affraid = 0,
		die = 0,
		health = 1,
		wound = 1,
		collision_box_x = 1,
		collision_box_y = 1,
		scale = 1,
		bonus = 20
	},
	-- moving left-right
	{
		name = "moving left-right",
		idle = 0,
		walk_left = 0,
		walk_right = 0,
		affraid_left = 0,
		affraid_right = 0,
		die = 0,
		health = 1,
		wound = 1,
		collision_box_x = 1,
		collision_box_y = 1,
		scale = 1,
		gravity = false,
		steps = 32,
		bonus = 20
	},
	-- moving up-down
	{
		name = "moving up-down",
		idle = 0,
		walk_up = 0,
		walk_down = 0,
		affraid_up = 0,
		affraid_down = 0,
		die = 0,
		health = 1,
		wound = 1,
		collision_box_x = 1,
		collision_box_y = 1,
		scale = 1,
		steps = 32,
		bonus = 20
	},
	-- sniper
	{
		name = "sniper",
		idle = 0,
		fire = 0,
		affraid = 0,
		die = 0,
		direction = 180,
		health = 1,
		wound = 1,
		collision_box_x = 1,
		collision_box_y = 1,
		scale = 1,
		bonus = 20,
		weapon1 = 0,
		collision_box1 = 1
	},
	-- oscillate left-right
	{
		name = "oscillate left-right",
		idle = 0,
		walk = 0,
		fire = 0,
		affraid = 0,
		die = 0,
		health = 1,
		wound = 1,
		collision_box_x = 1,
		collision_box_y = 1,
		scale = 1,
		bonus = 20,
		weapon1 = 0,
		collision_box1 = 1
	},
	-- oscillate up-down
	{
		name = "oscillate up-down",
		idle = 0,
		walk = 0,
		fire = 0,
		affraid = 0,
		die = 0,
		health = 1,
		wound = 1,
		collision_box_x = 1,
		collision_box_y = 1,
		scale = 1,
		bonus = 20,
		weapon1 = 0,
		collision_box1 = 1
	},
	-- turn
	{
		name = "turn",
		idle = 0,
		walk = 0,
		fire = 0,
		affraid = 0,
		die = 0,
		health = 1,
		wound = 1,
		collision_box_x = 1,
		collision_box_y = 1,
		scale = 1,
		bonus = 20,
		weapon1 = 0,
		collision_box1 = 1
	},
	-- seek 4 directions
	{
		name = "seek 4 directions",
		idle = 0,
		walk_up = 0,
		walk_down = 0,
		walk_left = 0,
		walk_right = 0,
		fire_up = 0,
		fire_down = 0,
		fire_left = 0,
		fire_right = 0,
		affraid_up = 0,
		affraid_down = 0,
		affraid_left = 0,
		affraid_right = 0,
		die = 0,
		health = 1,
		wound = 1,
		collision_box_x = 1,
		collision_box_y = 1,
		scale = 1,
		bonus = 20,
		weapon1 = 0,
		collision_box1 = 1
	},
	-- seek 8 directions
	{
		name = "seek 8 directions",
		idle = 0,
		walk = 0,
		fire = 0,
		affraid = 0,
		die = 0,
		health = 1,
		wound = 1,
		collision_box_x = 1,
		collision_box_y = 1,
		scale = 1,
		bonus = 20,
		weapon1 = 0,
		collision_box1 = 1
	},
	-- random 4 directions
	{
		name = "random 4 directions",
		idle = 0,
		walk_up = 0,
		walk_down = 0,
		walk_left = 0,
		walk_right = 0,
		fire_up = 0,
		fire_down = 0,
		fire_left = 0,
		fire_right = 0,
		affraid_up = 0,
		affraid_down = 0,
		affraid_left = 0,
		affraid_right = 0,
		die = 0,
		health = 1,
		wound = 1,
		collision_box_x = 1,
		collision_box_y = 1,
		scale = 1,
		bonus = 20,
		weapon1 = 0,
		collision_box1 = 1
	},
	-- random 8 directions
	{
		name = "random 8 directions",
		idle = 0,
		walk = 0,
		fire = 0,
		affraid = 0,
		die = 0,
		health = 1,
		wound = 1,
		collision_box_x = 1,
		collision_box_y = 1,
		scale = 1,
		bonus = 20,
		weapon1 = 0,
		collision_box1 = 1
	},
	-- beat'em all fighter
	{
		name = "beat'em all fighter",
		idle = 0,
		walk = 0,
		punch = 0,
		kick = 0,
		jumping_kick = 0,
		wounded = 0,
		die = 0,
		health = 1,
		wound = 1,
		collision_box_x = 1,
		collision_box_y = 1,
		scale = 1,
		bonus = 20
	}
}

-- enemies animations and parameters
enemy_animations = {
	-- static
	{
		{parameter = "idle", infos = "idle animation"},
		{parameter = "affraid", infos = "affraid animation"},
		{parameter = "die", infos = "die animation"},
		{parameter = "health", infos = "health points"},
		{parameter = "wound", infos = "wound points withdrawn from the opponent"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"},
		{parameter = "scale", infos = "scale value"},
		{parameter = "bonus", infos = "bonus when the enemy die"}
	},
	-- moving left-right
	{
		{parameter = "idle", infos = "idle animation"},
		{parameter = "walk_left", infos = "walk left animation"},
		{parameter = "walk_right", infos = "walk right animation"},
		{parameter = "affraid_left", infos = "affraid left animation"},
		{parameter = "affraid_right", infos = "affraid right animation"},
		{parameter = "die", infos = "die animation"},
		{parameter = "health", infos = "health points"},
		{parameter = "wound", infos = "wound points withdrawn from the opponent"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"},
		{parameter = "scale", infos = "scale value"},
		{parameter = "gravity", infos = "does gravity apply to the enemy ?"},
		{parameter = "steps", infos = "how many steps to walk left and right?"},
		{parameter = "bonus", infos = "bonus when the enemy die"}
	},
	-- moving up-down
	{
		{parameter = "idle", infos = "idle animation"},
		{parameter = "walk_up", infos = "walk up animation"},
		{parameter = "walk_down", infos = "walk down animation"},
		{parameter = "affraid_up", infos = "affraid up animation"},
		{parameter = "affraid_down", infos = "affraid down animation"},
		{parameter = "die", infos = "die animation"},
		{parameter = "health", infos = "health points"},
		{parameter = "wound", infos = "wound points withdrawn from the opponent"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"},
		{parameter = "scale", infos = "scale value"},
		{parameter = "steps", infos = "how many steps to walk up and down?"},
		{parameter = "bonus", infos = "bonus when the enemy die"}
	},
	-- sniper
	{
		{parameter = "idle", infos = "idle animation"},
		{parameter = "fire", infos = "fire animation"},
		{parameter = "affraid", infos = "affraid animation"},
		{parameter = "die", infos = "die animation"},
		{parameter = "direction", infos = "direction to look at"},
		{parameter = "health", infos = "health points"},
		{parameter = "wound", infos = "wound points withdrawn from the opponent"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"},
		{parameter = "scale", infos = "scale value"},
		{parameter = "bonus", infos = "bonus when the enemy die"},
		{parameter = "weapon1", infos = "weapon1 animation"},
		{parameter = "collision_box1", infos = "weapon1 collision box reducer"}
	},
	-- oscillate left-right
	{
		{parameter = "idle", infos = "idle animation"},
		{parameter = "walk", infos = "walk animation"},
		{parameter = "fire", infos = "fire animation"},
		{parameter = "affraid", infos = "affraid animation"},
		{parameter = "die", infos = "die animation"},
		{parameter = "health", infos = "health points"},
		{parameter = "wound", infos = "wound points withdrawn from the opponent"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"},
		{parameter = "scale", infos = "scale value"},
		{parameter = "bonus", infos = "bonus when the enemy die"},
		{parameter = "weapon1", infos = "weapon1 animation"},
		{parameter = "collision_box1", infos = "weapon1 collision box reducer"}
	},
	-- oscillate up-down
	{
		{parameter = "idle", infos = "idle animation"},
		{parameter = "walk", infos = "walk animation"},
		{parameter = "fire", infos = "fire animation"},
		{parameter = "affraid", infos = "affraid animation"},
		{parameter = "die", infos = "die animation"},
		{parameter = "health", infos = "health points"},
		{parameter = "wound", infos = "wound points withdrawn from the opponent"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"},
		{parameter = "scale", infos = "scale value"},
		{parameter = "bonus", infos = "bonus when the enemy die"},
		{parameter = "weapon1", infos = "weapon1 animation"},
		{parameter = "collision_box1", infos = "weapon1 collision box reducer"}
	},
	-- turn
	{
		{parameter = "idle", infos = "idle animation"},
		{parameter = "walk", infos = "walk animation"},
		{parameter = "fire", infos = "fire animation"},
		{parameter = "affraid", infos = "affraid animation"},
		{parameter = "die", infos = "die animation"},
		{parameter = "health", infos = "health points"},
		{parameter = "wound", infos = "wound points withdrawn from the opponent"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"},
		{parameter = "scale", infos = "scale value"},
		{parameter = "bonus", infos = "bonus when the enemy die"},
		{parameter = "weapon1", infos = "weapon1 animation"},
		{parameter = "collision_box1", infos = "weapon1 collision box reducer"}
	},
	-- seek 4 directions
	{
		{parameter = "idle", infos = "idle animation"},
		{parameter = "walk_up", infos = "walk up animation"},
		{parameter = "walk_down", infos = "walk down animation"},
		{parameter = "walk_left", infos = "walk left animation"},
		{parameter = "walk_right", infos = "walk right animation"},
		{parameter = "fire_up", infos = "fire up animation"},
		{parameter = "fire_down", infos = "fire down animation"},
		{parameter = "fire_left", infos = "fire left animation"},
		{parameter = "fire_right", infos = "fire right animation"},
		{parameter = "affraid_up", infos = "affraid up animation"},
		{parameter = "affraid_down", infos = "affraid down animation"},
		{parameter = "affraid_left", infos = "affraid left animation"},
		{parameter = "affraid_right", infos = "affraid right animation"},
		{parameter = "die", infos = "die animation"},
		{parameter = "health", infos = "health points"},
		{parameter = "wound", infos = "wound points withdrawn from the opponent"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"},
		{parameter = "scale", infos = "scale value"},
		{parameter = "bonus", infos = "bonus when the enemy die"},
		{parameter = "weapon1", infos = "weapon1 animation"},
		{parameter = "collision_box1", infos = "weapon1 collision box reducer"}
	},
	-- seek 8 directions
	{
		{parameter = "idle", infos = "idle animation"},
		{parameter = "walk", infos = "walk animation"},
		{parameter = "fire", infos = "fire animation"},
		{parameter = "affraid", infos = "affraid animation"},
		{parameter = "die", infos = "die animation"},
		{parameter = "health", infos = "health points"},
		{parameter = "wound", infos = "wound points withdrawn from the opponent"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"},
		{parameter = "scale", infos = "scale value"},
		{parameter = "bonus", infos = "bonus when the enemy die"},
		{parameter = "weapon1", infos = "weapon1 animation"},
		{parameter = "collision_box1", infos = "weapon1 collision box reducer"}
	},
	-- random 4 directions
	{
		{parameter = "idle", infos = "idle animation"},
		{parameter = "walk_up", infos = "walk up animation"},
		{parameter = "walk_down", infos = "walk down animation"},
		{parameter = "walk_left", infos = "walk left animation"},
		{parameter = "walk_right", infos = "walk right animation"},
		{parameter = "fire_up", infos = "fire up animation"},
		{parameter = "fire_down", infos = "fire down animation"},
		{parameter = "fire_left", infos = "fire left animation"},
		{parameter = "fire_right", infos = "fire right animation"},
		{parameter = "affraid_up", infos = "affraid up animation"},
		{parameter = "affraid_down", infos = "affraid down animation"},
		{parameter = "affraid_left", infos = "affraid left animation"},
		{parameter = "affraid_right", infos = "affraid right animation"},
		{parameter = "die", infos = "die animation"},
		{parameter = "health", infos = "health points"},
		{parameter = "wound", infos = "wound points withdrawn from the opponent"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"},
		{parameter = "scale", infos = "scale value"},
		{parameter = "bonus", infos = "bonus when the enemy die"},
		{parameter = "weapon1", infos = "weapon1 animation"},
		{parameter = "collision_box1", infos = "weapon1 collision box reducer"}
	},
	-- random 8 directions
	{
		{parameter = "idle", infos = "idle animation"},
		{parameter = "walk", infos = "walk animation"},
		{parameter = "fire", infos = "fire animation"},
		{parameter = "affraid", infos = "affraid animation"},
		{parameter = "die", infos = "die animation"},
		{parameter = "health", infos = "health points"},
		{parameter = "wound", infos = "wound points withdrawn from the opponent"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"},
		{parameter = "scale", infos = "scale value"},
		{parameter = "bonus", infos = "bonus when the enemy die"},
		{parameter = "weapon1", infos = "weapon1 animation"},
		{parameter = "collision_box1", infos = "weapon1 collision box reducer"}
	},
	-- beat'em all fighter
	{
		{parameter = "idle", infos = "idle animation"},
		{parameter = "walk", infos = "walk animation"},
		{parameter = "punch", infos = "punch animation"},
		{parameter = "kick", infos = "kick animation"},
		{parameter = "jumping_kick", infos = "jumping kick animation"},
		{parameter = "wounded", infos = "wounded animation"},
		{parameter = "die", infos = "die animation"},
		{parameter = "health", infos = "health points"},
		{parameter = "wound", infos = "wound points withdrawn from the opponent"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"},
		{parameter = "scale", infos = "scale value"},
		{parameter = "bonus", infos = "bonus when the enemy die"},
	}
}

-- types of bonus-malus
bonus_types = {
	-- points bonus, to add to score
	{
		name = "points",
		bonus = 10,
		idle = 0,
		collision_box_x = 1,
		collision_box_y = 1
	},
	-- life bonus
	{
		name = "life",
		bonus = 1,
		idle = 0,
		collision_box_x = 1,
		collision_box_y = 1
	},
	-- health points bonus
	{
		name = "health",
		bonus = 20,
		idle = 0,
		collision_box_x = 1,
		collision_box_y = 1
	},
	-- invincible bonus
	{
		name = "invincible",
		duration = 10,
		idle = 0,
		collision_box_x = 1,
		collision_box_y = 1
	}
}

bonus_animations = {
	-- points bonus, to add to score
	{
		{parameter = "bonus", infos = "bonus points added to the player's score"},
		{parameter = "idle", infos = "idle animation"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"}
	},
	-- life bonus
	{
		{parameter = "bonus", infos = "bonus lives added to the player's lives"},
		{parameter = "idle", infos = "idle animation"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"}
	},
	-- health points bonus
	{
		{parameter = "bonus", infos = "bonus health added to the player's health"},
		{parameter = "idle", infos = "idle animation"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"}
	},
	-- invincible bonus
	{
		{parameter = "duration", infos = "time duration for invincibility, in seconds"},
		{parameter = "idle", infos = "idle animation"},
		{parameter = "collision_box_x", infos = "horizontal part of the collision box reducer"},
		{parameter = "collision_box_y", infos = "vertical part of the collision box reducer"}
	}
}

-- types of entities
entity_types = {
	"player",
	"enemy",
	"bonus"
}

-- game goals
game_goals = {
	"go to exit at right",
	"kill all enemies",
	"kill all enemies and exit at right",
	"take all bonus",
	"take a key and goto exit"
}

-- types of scrollings
scrolling_types = {
	"no scrolling",
	"scroll from screen's middle",
	"auto-scroll",
	"scroll screen by screen"
}

-- types of sounds to import
sound_types = {
	"player_walk",
	"player_run",
	"player_jump",
	"player_hit",
	"player_fire1",
	"player_fire2",
	"player_punch",
	"player_kick",
	"player_jumping_kick",
	"player_wounded",
	"player_die",
	"enemy_walk",
	"enemy_fire",
	"enemy_wounded",
	"enemy_die",
	"bonus_points",
	"bonus_lives",
	"bonus_health",
	"bonus_invincible"
}

-- types of musics to import
music_types = {
	"intro",
	"in_game",
	"winner",
	"game_over"
}

-- types of images to import
image_types = {
	"intro",
	"interface",
	"winner",
	"game_over",
	"interlude"
}

-- convert blocks to images
function ConvertBlocksToImages()
	-- convert blocks to images
	
	for i = 1, #game_data.blocks do
		local data_blocks = love.image.newImageData(game_data.block_width, game_data.block_height)
		
		for x = 0, game_data.block_width - 1 do
			for y = 0, game_data.block_height - 1 do
				local r, g, b = GetPenRGB(game_data.blocks[i][x][y])
				data_blocks:setPixel(x, y, r, g, b, 1)
			end
		end
		
		img_blocks[i] = love.graphics.newImage(data_blocks)
	end
end

-- convert sprites to images
function ConvertSpritesToImages()
	-- convert sprites to images	
	for i = 1, #game_data.sprites do
		local data_sprites = love.image.newImageData(game_data.sprite_width, game_data.sprite_height)
		
		for x = 0, game_data.sprite_width - 1 do
			for y = 0, game_data.sprite_height - 1 do
				local r, g, b = GetPenRGB(game_data.sprites[i][x][y])
				if game_data.sprites[i][x][y] == 0 then a = 0 else a = 1 end
				data_sprites:setPixel(x, y, r, g, b, a)
			end
		end

		img_sprites[i] = love.graphics.newImage(data_sprites)
	end
end

-- find current entity types
function FindCurrentEntityType(t)
	if current_entity_type == ENTITY_TYPE_PLAYER then
		for i = 1, #player_types do
			if t.actors[current_actor].type.name == player_types[i].name then
				current_player_type = i
				break
			end
		end
	elseif current_entity_type == ENTITY_TYPE_ENEMY then
		for i = 1, #enemy_types do
			if t.actors[current_actor].type.name == enemy_types[i].name then
				current_enemy_type = i
				break
			end
		end
	elseif current_entity_type == ENTITY_TYPE_BONUS then
		for i = 1, #bonus_types do
			if t.actors[current_actor].type.name == bonus_types[i].name then
				current_bonus_type = i
				break
			end
		end
	end
end

-- convert x to scaled x
function ScaleX(x, zoom)
	return WINDOW_BORDER + (x * game_data.pixel_size * zoom)
end

-- convert y to scaled y
function ScaleY(y, zoom)
	return WINDOW_BORDER + (y * zoom)
end

-- convert width to scaled width
function ScaleWidth(w, zoom)
	return w * game_data.pixel_size * zoom
end

-- convert height to scaled height
function ScaleHeight(h, zoom)
	return h * zoom
end

-- quantize value
function Quantize(v, q)
	return math.floor(v / q) * q
end

-- get actor's sprite using actor number, animation name and frame
function GetActorSprite(actor, animation_name, frame)
	local animation_number = game_data.actors[actor].type[animation_name]
	
	return game_data.animations[animation_number][frame]
end

-- get actor's animation number by giving the animation name
function GetActorAnimationNumber(actor, animation_name)
	return game_data.actors[actor].type[animation_name]
end

-- convert a number to a string, and add 0 before
function ToString2(n, z)
	local s = tostring(n)
	
	if #s > z then
		s = ""
		
		for i = 1, z do
			s = s .. "9"
		end
	elseif #s < z then
		while #s < z do
			s = "0" .. s
		end
	end
	
	return s
end

function DeepCopy(original)
    local copy = {}
	
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = DeepCopy(v)
        else
            copy[k] = v
        end
    end
	
    return copy
end

-- blocks types
blocks_types = {"background", "wall", "platform", "stairs", "death", "eatable"}

-- types of player
player_types = {
	{name = "platformer", idle = 0, walk = 0, jump = 0, climb = 0, hit = 0, die = 0, hflip = false, wound = 1},
	{name = "beat'em up", idle = 0, walk = 0, jump = 0, punch = 0, kick = 0, jumping_kick = 0, wounded = 0, die = 0, hflip = false, wound = 1},
	{name = "run & gun (edge view)", idle = 0, run = 0, jump = 0, fire1 = 0, fire2 = 0, crouch = 0, crouched_fire = 0, die = 0, hflip = false, wound = 1,
		weapon1 = 0, collision_box1 = 2, weapon2 = 0, collision_box2 = 2},
	{name = "run & gun (top view)", idle = 0, run = 0, fire1 = 0, fire2 = 0, die = 0, directions = 8, wound = 1,
		weapon1 = 0, collision_box1 = 2, weapon2 = 0, collision_box2 = 2},
	{name = "maze & chase", idle = 0, move = 0, die = 0, wound = 1},
	{name = "fixed shooter", idle = 0, move = 0, fire1 = 0, die = 0, wound = 1,
		weapon1 = 0, collision_box1 = 2},
	{name = "horizontal shooter", idle = 0, move = 0, fire1 = 0, fire2 = 0, die = 0, hflip = false, wound = 1,
		weapon1 = 0, collision_box1 = 2, weapon2 = 0, collision_box2 = 2},
	{name = "vertical shooter", idle = 0, move = 0, fire1 = 0, fire2 = 0, die = 0, vflip = false, wound = 1,
		weapon1 = 0, collision_box1 = 2, weapon2 = 0, collision_box2 = 2}
}

player_animations = {
	{"idle", "walk", "jump", "climb", "hit", "die", "hflip", "wound"},
	{"idle", "walk", "jump", "punch", "kick", "jumping_kick", "wounded", "die", "hflip", "wound"},
	{"idle", "run", "jump", "fire1", "fire2", "crouch", "crouched_fire", "die", "hflip", "wound",
		"weapon1", "collision_box1", "weapon2", "collision_box2"},
	{"idle", "run", "fire1", "fire2", "die", "directions", "wound",
		"weapon1", "collision_box1", "weapon2", "collision_box2"},
	{"idle", "move", "die", "wound"},
	{"idle", "move", "die", "wound",
		"weapon1", "collision_box1"},
	{"idle", "move", "fire1", "fire2", "die", "wound",
		"weapon1", "collision_box1", "weapon2", "collision_box2"},
	{"idle", "move", "fire1", "fire2", "die", "wound",
		"weapon1", "collision_box1", "weapon2", "collision_box2"}
}

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


-- types of enemies
enemy_types = {
	{name = "static", idle = 0, affraid = 0, die = 0, health = 1, wound = 1, bonus = 20},
	{name = "moving left-right", idle = 0, walk_left = 0, walk_right = 0, affraid_left = 0, affraid_right = 0, die = 0, health = 1, wound = 1, gravity = false, steps = 32, bonus = 20},
	{name = "moving up-down", idle = 0, walk_up = 0, walk_down = 0, affraid_up = 0, affraid_down = 0, die = 0, health = 1, wound = 1, steps = 32, bonus = 20},
	{name = "sniper", idle = 0, fire = 0, affraid = 0, die = 0, direction = 180, health = 1, wound = 1, bonus = 20},
	{name = "oscillate left-right", idle = 0, walk = 0, fire = 0, affraid = 0, die = 0, health = 1, wound = 1, bonus = 20},
	{name = "oscillate up-down", idle = 0, walk = 0, fire = 0, affraid = 0, die = 0, health = 1, wound = 1, bonus = 20},
	{name = "turn", idle = 0, walk = 0, fire = 0, affraid = 0, die = 0, health = 1, wound = 1, bonus = 20},
	{name = "seek 4 directions", idle = 0, walk_up = 0, walk_down = 0, walk_left = 0, walk_right = 0,
		fire_up = 0, fire_down = 0, fire_left = 0, fire_right = 0,
		affraid_up = 0, affraid_down = 0, affraid_left = 0, affraid_right = 0,
		die = 0, health = 1, wound = 1, bonus = 20},
	{name = "seek 8 directions", idle = 0, walk = 0, fire = 0, affraid = 0, die = 0, health = 1, wound = 1, bonus = 20},
	{name = "random 4 directions", idle = 0, walk_up = 0, walk_down = 0, walk_left = 0, walk_right = 0,
		fire_up = 0, fire_down = 0, fire_left = 0, fire_right = 0,
		affraid_up = 0, affraid_down = 0, affraid_left = 0, affraid_right = 0,
		die = 0, health = 1, wound = 1, bonus = 20},
	{name = "random 8 directions", idle = 0, walk = 0, fire = 0, affraid = 0, die = 0, health = 1, wound = 1, bonus = 20}
}

enemy_animations = {
	{"idle", "affraid", "die", "health", "wound", "bonus"},
	{"idle", "walk_left", "walk_right", "affraid_left", "affraid_right", "die", "health", "wound", "gravity", "steps", "bonus"},
	{"idle", "walk_up", "walk_down", "affraid_up", "affraid_down", "die", "health", "wound", "steps", "bonus"},
	{"idle", "fire", "affraid", "die", "direction", "health", "wound", "bonus"},
	{"idle", "walk", "fire", "affraid", "die", "health", "wound", "bonus"},
	{"idle", "walk", "fire", "affraid", "die", "health", "wound", "bonus"},
	{"idle", "walk", "fire", "affraid", "die", "health", "wound", "bonus"},
	{"idle", "walk_up", "walk_down", "walk_left", "walk_right",
		"fire_up", "fire_down", "fire_left", "fire_right",
		"affraid_up", "affraid_down", "affraid_left", "affraid_right", 
		"die", "health", "wound", "bonus"},
	{"idle", "walk", "fire", "affraid", "die", "health", "wound", "bonus"},
	{"idle", "walk_up", "walk_down", "walk_left", "walk_right",
		"fire_up", "fire_down", "fire_left", "fire_right",
		"affraid_up", "affraid_down", "affraid_left", "affraid_right", 
		"die", "health", "wound", "bonus"},
	{"idle", "walk", "fire", "affraid", "die", "health", "wound", "bonus"}
}

-- types of bonus-malus
bonus_types = {
	{name = "points", bonus = 10, idle = 0, collision_box = 1},
	{name = "life", bonus = 1, idle = 0, collision_box = 1},
	{name = "health", bonus = 20, idle = 0, collision_box = 1},
	{name = "invincible", duration = 10, idle = 0, collision_box = 1}
}

bonus_animations = {
	{"bonus", "idle", "collision_box"},
	{"bonus", "idle", "collision_box"},
	{"bonus", "idle", "collision_box"},
	{"duration", "idle", "collision_box"}
}

-- types of entities
entity_types = {"player", "enemy", "bonus"}

-- game goals
game_goals = {"go to exit at right", "kill all enemies", "kill all enemies and exit at right", "take all bonus", "take a key and goto exit"}

-- types of scrollings
scrolling_types = {"no scrolling", "scroll from screen's middle", "auto-scroll", "scroll screen by screen"}

-- types of images to import
image_types = {"intro", "interface", "winner", "game_over", "interlude"}

-- types of musics to import
music_types = {"intro", "in_game", "winner", "game_over"}

-- types of sounds to import
player_sound_types = {"walk", "run", "jump", "hit", "fire1", "fire2", "punch", "kick", "jumping_kick", "wounded", "die"}
enemies_sound_types = {"walk", "fire", "wounded", "die"}
bonus_sound_types = {"points", "lives", "health", "invincible"}

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

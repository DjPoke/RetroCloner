-- types of player
player_types = {
	{name = "platformer", idle = 0, walk = 0, jump = 0, climb = 0, hit = 0, die = 0, hflip = false },
	{name = "beat'em up", idle = 0, walk = 0, jump = 0, punch = 0, kick = 0, jumping_kick = 0, wounded = 0, die = 0, hflip = false },
	{name = "run & gun (edge view)", idle = 0, run = 0, jump = 0, fire = 0, crouch = 0, crouched_fire = 0, die = 0, hflip = false },
	{name = "run & gun (top view)", idle = 0, run = 0, fire1 = 0, fire2 = 0, die = 0, directions = 8 },
	{name = "maze & chase", idle = 0, run = 0, die = 0 },
	{name = "fixed shooter", idle = 0, move = 0, die = 0 },
	{name = "horizontal shooter", idle = 0, move = 0, fire1 = 0, fire2 = 0, die = 0, hflip = false },
	{name = "vertical shooter", idle = 0, move = 0, fire1 = 0, fire2 = 0, die = 0, vflip = false }
}

player_animations = {
	{"idle", "walk", "jump", "climb", "hit", "die", "hflip"},
	{"idle", "walk", "jump", "punch", "kick", "jumping_kick", "wounded", "die", "hflip"},
	{"idle", "run", "jump", "fire", "crouch", "crouched_fire", "die", "hflip"},
	{"idle", "run", "fire1", "fire2", "die", "directions"},
	{"idle", "run", "die"},
	{"idle", "move", "die"},
	{"idle", "move", "fire1", "fire2", "die"},
	{"idle", "move", "fire1", "fire2", "die"}
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
	{name = "static", idle = 0},
	{name = "moving left-right", idle = 0, walking = 0},
	{name = "sniper", idle = 0, fire = 0}
}

enemy_animations = {
	{"idle"},
	{"idle", "walking"},
	{"idle", "fire"}
}

-- types of bonus-malus
bonus_types = {
	{name = "points", bonus = 0, idle = 0},
	{name = "life", bonus = 0, idle = 0},
	{name = "health", bonus = 0, idle = 0}
}

bonus_animations = {
	{"bonus", "idle"},
	{"bonus", "idle"},
	{"bonus", "idle"}
}

-- types of entities
entity_types = {"player", "enemy", "bonus"}

-- game goals
game_goals = {"go to exit (right)", "kill all enemies", "kill all enemies and exit (right)", "take all bonus", "take a key and goto exit"}

-- types of scrollings
scrolling_types = {"no scrolling", "middle of screen", "auto", "screens scrolling"}

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
	if current_entity_type == 1 then
		for i = 1, #player_types do
			if t.actors[current_actor].type.name == player_types[i].name then
				current_player_type = i
				break
			end
		end
	elseif current_entity_type == 2 then
		for i = 1, #enemy_types do
			if t.actors[current_actor].type.name == enemy_types[i].name then
				current_enemy_type = i
				break
			end
		end
	elseif current_entity_type == 3 then
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

function SetDefaultGameData()
	game_data.vars.lives = 3
	game_data.vars.game_speed = 0.02
	game_data.vars.animations_speed = 0.30
	game_data.vars.game_goal = 1
	game_data.vars.scrolling_type = 1
	game_data.vars.scrolling_speed = 1
	game_data.vars.scrolling_horizontally = true
	game_data.vars.scrolling_vertically = false
	game_data.vars.gravity = 8
	game_data.vars.jump_power = 10
end

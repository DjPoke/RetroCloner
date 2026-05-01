local run = {}


-- run arrays
run.vars = {
	score = 0,
	level = 0,
	scrolling_x = 0,
	scrolling_y = 0,
	game_speed_timer = 0.0,
	animations_timer = 0.0,
	direction = 0,
	jump_power = 0,
	fall_power = 0,
	on_the_ground = false,
	on_stairs = false
}

-- run vars
local animations_tick = false
local game_speed_tick = false

-- run functions
function run.load()
	-- initialize player's data
	run.vars.score = 0
	run.vars.level = 1

	run.vars.direction = 0
	run.vars.jump_power = 0
	run.vars.fall_power = 0
	run.vars.on_the_ground = false
	run.vars.on_stairs = false
	
	-- scrolling values
	run.vars.scrolling_x = game_data.scrolling_start_x[run.vars.level]
	run.vars.scrolling_y = game_data.scrolling_start_y[run.vars.level]
	
	-- game speed and animation timer
	run.vars.game_speed_timer = 0.0
	run.vars.animation_timer = 0.0
	
	-- reset actors positions and animations
	for i = 1, #game_data.levels do
		for j = 1, #game_data.levels[i].actors do
			game_data.levels[i].actors[j].x = game_data.levels[i].actors[j].start_x
			game_data.levels[i].actors[j].y = game_data.levels[i].actors[j].start_y
			game_data.levels[i].actors[j].animation = GetActorAnimationNumber(game_data.levels[i].actors[j].number, "idle")
			game_data.levels[i].actors[j].frame = 1
		end
	end
end

function run.update(dt)
	run.vars.game_speed_timer = run.vars.game_speed_timer + dt
	run.vars.animations_timer = run.vars.animations_timer + dt
	animations_tick = false
	game_speed_tick = false
	
	if run.vars.game_speed_timer >= game_data.vars.game_speed then
		run.vars.game_speed_timer = 0.0
		game_speed_tick = true
	end

	if run.vars.animations_timer >= game_data.vars.animations_speed then
		run.vars.animations_timer = 0.0
		animations_tick = true
	end
		
	if #game_data.levels > 0 then
		local old_x = game_data.levels[run.vars.level].actors[1].x
		local old_y = game_data.levels[run.vars.level].actors[1].y
		local new_x = old_x
		local new_y = old_y
		
		if game_speed_tick == true then	
			-- move the player
			local actor_number = game_data.levels[run.vars.level].actors[1].number
			
			-- (TODO!)
			if game_data.actors[actor_number].type.name == "platformer" then
				local moving = false

				if CanClimb(old_x, old_y, game_data.sprite_width, game_data.sprite_height, game_data.levels[run.vars.level], game_data.block_width, game_data.block_height) == true then
					run.vars.on_stairs = true
				else
					run.vars.on_stairs = false
				end
			
				if love.keyboard.isDown("left") then
					game_data.levels[run.vars.level].actors[1].hflip = true
					run.vars.direction = 180
					moving = true
					
					-- change animation if needed
					if game_data.levels[run.vars.level].actors[1].animation == 1 then
						game_data.levels[run.vars.level].actors[1].animation = 2
						game_data.levels[run.vars.level].actors[1].frame = 1
						
					end

					-- walk left
					new_x = new_x - 1
				elseif love.keyboard.isDown("right") then
					game_data.levels[run.vars.level].actors[1].hflip = false
					run.vars.direction = 0
					moving = true
					
					-- change animation if needed
					if game_data.levels[run.vars.level].actors[1].animation == 1 then
						game_data.levels[run.vars.level].actors[1].animation = 2
						game_data.levels[run.vars.level].actors[1].frame = 1
					end
					
					-- walk right
					new_x = new_x + 1
				elseif love.keyboard.isDown("up") then
					-- climb up
					run.vars.direction = 270
					moving = true

					if run.vars.on_stairs == true then
						if game_data.levels[run.vars.level].actors[1].animation == 1 or game_data.levels[run.vars.level].actors[1].animation == 2 then
							game_data.levels[run.vars.level].actors[1].animation = 4
						end
						
						new_y = new_y - 1
					end
				elseif love.keyboard.isDown("down") then
					-- climb down
					run.vars.direction = 90
					moving = true

					if run.vars.on_stairs == true then
						if game_data.levels[run.vars.level].actors[1].animation == 1 or game_data.levels[run.vars.level].actors[1].animation == 2 then
							game_data.levels[run.vars.level].actors[1].animation = 4
						end
						
						new_y = new_y + 1
					end
				end
				
				if run.vars.on_the_ground == true then
					if moving == false then
						if game_data.levels[run.vars.level].actors[1].animation == 2 then
							-- on the ground ? not moving ?
							game_data.levels[run.vars.level].actors[1].animation = 1
							game_data.levels[run.vars.level].actors[1].frame = 1
						end
					end
				end
				
				-- jumping ?
				if run.vars.jump_power < 0 then
					run.vars.jump_power = run.vars.jump_power + 1
				end

				-- increase gravity force
				if run.vars.on_the_ground == false then
					if run.vars.jump_power == 0 then
						if run.vars.fall_power < game_data.vars.gravity then
							run.vars.fall_power = run.vars.fall_power + 1
						end
					end
				elseif run.vars.on_the_ground == true then
					run.vars.fall_power = 1
				end

				-- on stairs ? no more fall
				if run.vars.on_stairs == true then
					run.vars.fall_power = 0
				end

				-- apply gravity
				new_y = new_y + run.vars.fall_power + run.vars.jump_power
				
				-- check for player's collisions with blocks, because may be he has moved
				new_y, run.vars.on_the_ground = GroundCollision(old_x, new_y, game_data.sprite_width, game_data.sprite_height, game_data.levels[run.vars.level], game_data.block_width, game_data.block_height)
				new_y = CeilingCollision(old_x, new_y, game_data.sprite_width, game_data.sprite_height, game_data.levels[run.vars.level], game_data.block_width, game_data.block_height)
				new_x = LeftCollision(new_x, old_y, game_data.sprite_width, game_data.sprite_height, game_data.levels[run.vars.level], game_data.block_width, game_data.block_height)
				new_x = RightCollision(new_x, old_y, game_data.sprite_width, game_data.sprite_height, game_data.levels[run.vars.level], game_data.block_width, game_data.block_height)
				new_x, run.vars.on_the_ground = CornerCollision(new_x, new_y, game_data.sprite_width, game_data.sprite_height, game_data.levels[run.vars.level], game_data.block_width, game_data.block_height, run.vars.on_the_ground)

				-- restore idle animation
				if run.vars.on_the_ground == true then
					local actor_number = game_data.levels[run.vars.level].actors[1].number

					-- (TODO!)
					if game_data.actors[actor_number].type.name == "platformer" then
						if game_data.levels[run.vars.level].actors[1].animation == 3 then
							game_data.levels[run.vars.level].actors[1].animation = 1
							game_data.levels[run.vars.level].actors[1].frame = 1
						end
					end
				end
			elseif game_data.actors[actor_number].type.name == "run & gun (top view)" then
				local dir = run.vars.direction
				local dir_x = 0
				local dir_y = 0
				
				if love.keyboard.isDown("up") then
					if love.keyboard.isDown("left") then
						dir = 225
						dir_x = -1
						dir_y = -1
					elseif love.keyboard.isDown("right") then
						dir = 315
						dir_x = 1
						dir_y = -1
					else
						dir = 270
						dir_x = 0
						dir_y = -1
					end
				elseif love.keyboard.isDown("down") then
					if love.keyboard.isDown("left") then
						dir = 135
						dir_x = -1
						dir_y = 1
					elseif love.keyboard.isDown("right") then
						dir = 45
						dir_x = 1
						dir_y = 1
					else
						dir = 90
						dir_x = 0
						dir_y = 1
					end
				elseif love.keyboard.isDown("left") then
					if love.keyboard.isDown("up") then
						dir = 225						
						dir_x = -1
						dir_y = -1
					elseif love.keyboard.isDown("down") then
						dir = 135
						dir_x = -1
						dir_y = 1
					else
						dir = 180
						dir_x = -1
						dir_y = 0
					end
				elseif love.keyboard.isDown("right") then
					if love.keyboard.isDown("up") then
						dir = 315
						dir_x = 1
						dir_y = -1
					elseif love.keyboard.isDown("down") then
						dir = 45
						dir_x = 1
						dir_y = 1
					else
						dir = 0
						dir_x = 1
						dir_y = 0
					end
				end

				-- update real direction
				run.vars.direction = dir

				if dir_x == -1 then
					-- change animation if needed
					if game_data.levels[run.vars.level].actors[1].animation == 1 then
						game_data.levels[run.vars.level].actors[1].animation = 2
						game_data.levels[run.vars.level].actors[1].frame = 1
						
					end

					-- walk left
					new_x = new_x - 1
				elseif dir_x == 1 then
					-- change animation if needed
					if game_data.levels[run.vars.level].actors[1].animation == 1 then
						game_data.levels[run.vars.level].actors[1].animation = 2
						game_data.levels[run.vars.level].actors[1].frame = 1
					end
					
					-- walk right
					new_x = new_x + 1
				end
					
				if dir_y == -1 then
					-- change animation if needed
					if game_data.levels[run.vars.level].actors[1].animation == 1 then
						game_data.levels[run.vars.level].actors[1].animation = 2
						game_data.levels[run.vars.level].actors[1].frame = 1
						
					end

					-- walk left
					new_y = new_y - 1
				elseif dir_y == 1 then
					-- change animation if needed
					if game_data.levels[run.vars.level].actors[1].animation == 1 then
						game_data.levels[run.vars.level].actors[1].animation = 2
						game_data.levels[run.vars.level].actors[1].frame = 1
					end
					
					-- walk right
					new_y = new_y + 1
				end
				
				-- check for player's collisions with blocks, because may be he has moved
				new_x = SlidingCollisionX(new_x, old_y, game_data.sprite_width, game_data.sprite_height, run.vars.direction, game_data.levels[run.vars.level], game_data.block_width, game_data.block_height)
				new_y = SlidingCollisionY(old_x, new_y, game_data.sprite_width, game_data.sprite_height, run.vars.direction, game_data.levels[run.vars.level], game_data.block_width, game_data.block_height)
				new_x, new_y = SlidingCollisionZ(new_x, new_y, game_data.sprite_width, game_data.sprite_height, run.vars.direction, game_data.levels[run.vars.level], game_data.block_width, game_data.block_height)
			end
			
			-- update coordinates of the player
			game_data.levels[run.vars.level].actors[1].x = new_x
			game_data.levels[run.vars.level].actors[1].y = new_y
		end

		-- it is time to animate characters
		if animations_tick == true then
			for i = 1, #game_data.levels[run.vars.level].actors do
				if game_data.levels[run.vars.level].actors[i].frame < #game_data.animations[game_data.levels[run.vars.level].actors[i].animation] then
					game_data.levels[run.vars.level].actors[i].frame = game_data.levels[run.vars.level].actors[i].frame + 1
				elseif game_data.levels[run.vars.level].actors[i].frame == #game_data.animations[game_data.levels[run.vars.level].actors[i].animation] then
					game_data.levels[run.vars.level].actors[i].frame = 1
				end
			end
		end
	end
		
	-- move enemies
	-- TODO!
	
	-- check for enemies collisions with blocks
	-- TODO!

	-- check for player collisions with enemies
	-- TODO!
	
	-- check for player collisions with bonus
	-- TODO!

	-- perform scrolling
	if game_data.vars.scrolling_type == 2 then
		-- scroll when the player is in the middle of the screen
		if game_data.vars.scrolling_horizontally == true and game_data.vars.scrolling_vertically == false then
			if game_data.levels[run.vars.level].actors[1].x + run.vars.scrolling_x > (game_data.levels_data.sw * game_data.block_width / 2) then
				if -run.vars.scrolling_x < ((game_data.levels_data.w - 1) * game_data.levels_data.sw * game_data.block_width) then
					local scroll_value = game_data.levels[run.vars.level].actors[1].x - (game_data.levels_data.sw * game_data.block_width / 2) + run.vars.scrolling_x
					
					run.vars.scrolling_x = run.vars.scrolling_x - game_data.vars.scrolling_speed
					game_data.levels[run.vars.level].actors[1].x = game_data.levels[run.vars.level].actors[1].x - scroll_value + game_data.vars.scrolling_speed
				end
			end
		elseif game_data.vars.scrolling_horizontally == false and game_data.vars.scrolling_vertically == true then
			if game_data.levels[run.vars.level].actors[1].y + run.vars.scrolling_y > (game_data.levels_data.sh * game_data.block_height / 2) then
				if -run.vars.scrolling_y < ((game_data.levels_data.h - 1) * game_data.levels_data.sh * game_data.block_height) then
					local scroll_value = game_data.levels[run.vars.level].actors[1].y - (game_data.levels_data.sh * game_data.block_height / 2) + run.vars.scrolling_y
					
					run.vars.scrolling_y = run.vars.scrolling_y - game_data.vars.scrolling_speed
					game_data.levels[run.vars.level].actors[1].y = game_data.levels[run.vars.level].actors[1].y - scroll_value + game_data.vars.scrolling_speed
				end
			end
		elseif game_data.vars.scrolling_horizontally == true and game_data.vars.scrolling_vertically == true then
			if game_data.levels[run.vars.level].actors[1].x + run.vars.scrolling_x > (game_data.levels_data.sw * game_data.block_width / 2) then
				if -run.vars.scrolling_x < ((game_data.levels_data.w - 1) * game_data.levels_data.sw * game_data.block_width) then
					local scroll_value = game_data.levels[run.vars.level].actors[1].x - (game_data.levels_data.sw * game_data.block_width / 2) + run.vars.scrolling_x
					
					run.vars.scrolling_x = run.vars.scrolling_x - game_data.vars.scrolling_speed
					game_data.levels[run.vars.level].actors[1].x = game_data.levels[run.vars.level].actors[1].x - scroll_value + game_data.vars.scrolling_speed
				end
			end

			if game_data.levels[run.vars.level].actors[1].y + run.vars.scrolling_y > (game_data.levels_data.sh * game_data.block_height / 2) then
				if -run.vars.scrolling_y < ((game_data.levels_data.h - 1) * game_data.levels_data.sh * game_data.block_height) then
					local scroll_value = game_data.levels[run.vars.level].actors[1].y - (game_data.levels_data.sh * game_data.block_height / 2) + run.vars.scrolling_y
					
					run.vars.scrolling_y = run.vars.scrolling_y - game_data.vars.scrolling_speed
					game_data.levels[run.vars.level].actors[1].y = game_data.levels[run.vars.level].actors[1].y - scroll_value + game_data.vars.scrolling_speed
				end
			end
		end
	elseif game_data.vars.scrolling_type == 3 then
		-- auto scroll
		if anim_tick == true then
			if game_data.vars.scrolling_horizontally == true and game_data.vars.scrolling_vertically == false then
				if game_data.levels[run.vars.level].actors[1].x > math.abs(run.vars.scrolling_x) then
					if -run.vars.scrolling_x < ((game_data.levels_data.w - 1) * game_data.levels_data.sw * game_data.block_width) then
						run.vars.scrolling_x = run.vars.scrolling_x - game_data.vars.scrolling_speed
					end
				end
			elseif game_data.vars.scrolling_horizontally == false and game_data.vars.scrolling_vertically == true then
				if game_data.levels[run.vars.level].actors[1].y > math.abs(run.vars.scrolling_y) then
					if -run.vars.scrolling_y < ((game_data.levels_data.h - 1) * game_data.levels_data.sh * game_data.block_height) then
						run.vars.scrolling_y = run.vars.scrolling_y - game_data.vars.scrolling_speed
					end
				end
			elseif game_data.vars.scrolling_horizontally == true and game_data.vars.scrolling_vertically == true then
				if game_data.levels[run.vars.level].actors[1].x > math.abs(run.vars.scrolling_x) then
					if -run.vars.scrolling_x < ((game_data.levels_data.w - 1) * game_data.levels_data.sw * game_data.block_width) then
						run.vars.scrolling_x = run.vars.scrolling_x - game_data.vars.scrolling_speed
					end
				end

				if game_data.levels[run.vars.level].actors[1].y > math.abs(run.vars.scrolling_y) then
					if -run.vars.scrolling_y < ((game_data.levels_data.h - 1) * game_data.levels_data.sh * game_data.block_height) then
						run.vars.scrolling_y = run.vars.scrolling_y - game_data.vars.scrolling_speed
					end
				end
			end
		end
	elseif game_data.vars.scrolling_type == 4 then
		-- scroll when the player go out of a screen
		if game_data.vars.scrolling_horizontally == true and game_data.vars.scrolling_vertically == false then
			run.vars.scrolling_x = -math.floor(game_data.levels[run.vars.level].actors[1].x / (game_data.levels_data.sw * game_data.block_width)) * (game_data.levels_data.sw * game_data.block_width)

			if -run.vars.scrolling_x > ((game_data.levels_data.w - 1) * game_data.levels_data.sw * game_data.block_width) then
				run.vars.scrolling_x = -((game_data.levels_data.w - 1) * game_data.levels_data.sw * game_data.block_width)
			end			
		elseif game_data.vars.scrolling_horizontally == false and game_data.vars.scrolling_vertically == true then
			run.vars.scrolling_y = -math.floor(game_data.levels[run.vars.level].actors[1].y / (game_data.levels_data.sh * game_data.block_height)) * (game_data.levels_data.sh * game_data.block_height)

			if -run.vars.scrolling_y > ((game_data.levels_data.h - 1) * game_data.levels_data.sh * game_data.block_height) then
				run.vars.scrolling_y = -((game_data.levels_data.h - 1) * game_data.levels_data.sh * game_data.block_height)
			end
		elseif game_data.vars.scrolling_horizontally == true and game_data.vars.scrolling_vertically == true then
			run.vars.scrolling_x = -math.floor(game_data.levels[run.vars.level].actors[1].x / (game_data.levels_data.sw * game_data.block_width)) * (game_data.levels_data.sw * game_data.block_width)

			if -run.vars.scrolling_x > ((game_data.levels_data.w - 1) * game_data.levels_data.sw * game_data.block_width) then
				run.vars.scrolling_x = -((game_data.levels_data.w - 1) * game_data.levels_data.sw * game_data.block_width)
			end
			
			run.vars.scrolling_y = -math.floor(game_data.levels[run.vars.level].actors[1].y / (game_data.levels_data.sh * game_data.block_height)) * (game_data.levels_data.sh * game_data.block_height)

			if -run.vars.scrolling_y > ((game_data.levels_data.h - 1) * game_data.levels_data.sh * game_data.block_height) then
				run.vars.scrolling_y = -((game_data.levels_data.h - 1) * game_data.levels_data.sh * game_data.block_height)
			end
		end
	end
end

function run.draw()
  	-- adapt resolution to window (or fullscreen)
    love.graphics.scale(love.graphics.getWidth() / (WINDOW_WIDTH + (WINDOW_BORDER * 2)), love.graphics.getHeight() / (WINDOW_HEIGHT + (WINDOW_BORDER * 2)))

	-- ===========================================================================================================================================================================

	-- disable scissor
	love.graphics.setScissor()

	-- clear with border color
	r, g, b = GetPenRGB(game_data.border_paper)
	love.graphics.clear(r, g, b)

	-- ===========================================================================================================================================================================
	
	-- set scissor without the border
	love.graphics.setScissor(WINDOW_BORDER, WINDOW_BORDER, WINDOW_WIDTH, WINDOW_HEIGHT)

	-- clear the background with background paper color
	r, g, b = GetPenRGB(game_data.background_paper)
	love.graphics.clear(r, g, b)

	-- draw game area
	r, g, b = GetPenRGB(game_data.game_paper)
	love.graphics.setColor(r, g, b)
	love.graphics.rectangle("fill", ScaleX(game_data.areas[GAME_AREA].x, WINDOW_ZOOM), ScaleY(game_data.areas[GAME_AREA].y, WINDOW_ZOOM), ScaleWidth(game_data.areas[GAME_AREA].width, WINDOW_ZOOM), ScaleHeight(game_data.areas[GAME_AREA].height, WINDOW_ZOOM))

	-- ===========================================================================================================================================================================

	-- set scissor to game area
	love.graphics.setScissor(ScaleX(game_data.areas[GAME_AREA].x, WINDOW_ZOOM), ScaleY(game_data.areas[GAME_AREA].y, WINDOW_ZOOM), ScaleWidth(game_data.areas[GAME_AREA].width, WINDOW_ZOOM), ScaleHeight(game_data.areas[GAME_AREA].height, WINDOW_ZOOM))

	-- draw the game
	DrawGame()

	-- ===========================================================================================================================================================================
	
	-- disable scissor
	love.graphics.setScissor()

	-- draw score area
	
	FontsPrint("SCORE " .. ToString2(run.vars.score, 7), ScaleX(game_data.areas[SCORE_AREA].x, WINDOW_ZOOM), ScaleY(game_data.areas[SCORE_AREA].y, WINDOW_ZOOM), game_data.areas[SCORE_AREA].width * WINDOW_ZOOM, game_data.areas[SCORE_AREA].height * WINDOW_ZOOM, GAME_FONT, FONT_DOWN_SCALE / WINDOW_ZOOM, game_data.text_paper, game_data.text_pen)

	-- draw lives area
	FontsPrint("LIVES " .. ToString2(game_data.vars.lives, 2), ScaleX(game_data.areas[LIVES_AREA].x, WINDOW_ZOOM), ScaleY(game_data.areas[LIVES_AREA].y, WINDOW_ZOOM), game_data.areas[LIVES_AREA].width * WINDOW_ZOOM, game_data.areas[LIVES_AREA].height * WINDOW_ZOOM, GAME_FONT, FONT_DOWN_SCALE / WINDOW_ZOOM, game_data.text_paper, game_data.text_pen)

	-- draw level area
	FontsPrint("LEVEL " .. ToString2(run.vars.level, 3), ScaleX(game_data.areas[LEVEL_AREA].x, WINDOW_ZOOM), ScaleY(game_data.areas[LEVEL_AREA].y, WINDOW_ZOOM), game_data.areas[LEVEL_AREA].width * WINDOW_ZOOM, game_data.areas[LEVEL_AREA].height * WINDOW_ZOOM, GAME_FONT, FONT_DOWN_SCALE / WINDOW_ZOOM, game_data.text_paper, game_data.text_pen)
end

function run.keypressed(key, scancode, isrepeat)
	local actor_number = game_data.levels[run.vars.level].actors[1].number

	-- fire with keyboard
	if key == "x" then
		-- fire 1: x (TODO!)
		if game_data.actors[actor_number].type.name == "platformer" then
			-- the player is on the ground ?
			if run.vars.on_the_ground == true or run.vars.on_stairs == true then
				-- the player is idle or walking or climbing ?
				if game_data.levels[run.vars.level].actors[1].animation == 1 or game_data.levels[run.vars.level].actors[1].animation == 2 or game_data.levels[run.vars.level].actors[1].animation == 4 then
					-- jump
					game_data.levels[run.vars.level].actors[1].animation = 3
					game_data.levels[run.vars.level].actors[1].frame = 1
					run.vars.jump_power = -game_data.vars.jump_power
				end
			end
		end
	elseif key == "c" then
		-- fire 2: c
	end
end

-- draw the game
function DrawGame()
	love.graphics.setColor(1, 1, 1)
	
	-- game area position
	local px = ScaleX(game_data.areas[GAME_AREA].x, WINDOW_ZOOM)
	local py = ScaleY(game_data.areas[GAME_AREA].y, WINDOW_ZOOM)
	
	local offset_x = math.floor((game_data.areas[GAME_AREA].width - (game_data.levels_data.sw * game_data.block_width)) / 2)
	local offset_y = math.floor((game_data.areas[GAME_AREA].height - (game_data.levels_data.sh * game_data.block_height)) / 2)

	px = px + ScaleWidth(offset_x, game_data.pixel_size, WINDOW_ZOOM)
	py = py + ScaleHeight(offset_y, WINDOW_ZOOM)
	
	if #game_data.levels > 0 then
		-- draw blocks
		for x = 0, (game_data.levels_data.sw * game_data.levels_data.w) - 1 do
			for y = 0, (game_data.levels_data.sh * game_data.levels_data.h) - 1 do
				local block = game_data.levels[run.vars.level].blocks[x][y]
				local xc = ScaleWidth(x * game_data.block_width, WINDOW_ZOOM)
				local yc = ScaleHeight(y * game_data.block_height, WINDOW_ZOOM)

				-- scrolling
				xc = xc + ScaleWidth(run.vars.scrolling_x, WINDOW_ZOOM)
				yc = yc + ScaleHeight(run.vars.scrolling_y, WINDOW_ZOOM)
				
				if block > 0 then
					love.graphics.draw(img_blocks[block], px + xc, py + yc, 0, game_data.pixel_size * WINDOW_ZOOM, WINDOW_ZOOM)
				end
			end
		end
	
		-- draw actors
		for i = 1, #game_data.levels[run.vars.level].actors do
			local actor_number = game_data.levels[run.vars.level].actors[i].number
			local animation = game_data.levels[run.vars.level].actors[i].animation
			local frame = game_data.levels[run.vars.level].actors[i].frame
			
			if animation > 0 and frame > 0 then
				local sprite = game_data.animations[animation][frame]
				local xc = ScaleWidth(game_data.levels[run.vars.level].actors[i].x, WINDOW_ZOOM)
				local yc = ScaleHeight(game_data.levels[run.vars.level].actors[i].y, WINDOW_ZOOM)

				-- scrolling
				xc = xc + ScaleWidth(run.vars.scrolling_x, WINDOW_ZOOM)
				yc = yc + ScaleHeight(run.vars.scrolling_y, WINDOW_ZOOM)

				-- flipped ?
				local hflip = 1
				local vflip = 1
				
				if game_data.levels[run.vars.level].actors[i].hflip == true then hflip = -1 end
				if game_data.levels[run.vars.level].actors[i].vflip == true then vflip = -1 end

				local flip_offset_x = 0
				local flip_offset_y = 0
				
				-- what kind of player ? (TODO!)
				if game_data.actors[actor_number].type.name == "platformer" then
					if hflip == -1 then flip_offset_x = ScaleWidth(game_data.sprite_width, WINDOW_ZOOM) end
					
					love.graphics.draw(img_sprites[sprite], px + xc + flip_offset_x, py + yc, 0, game_data.pixel_size * WINDOW_ZOOM * hflip, WINDOW_ZOOM)
				elseif game_data.actors[actor_number].type.name == "run & gun (top view)" then
					flip_offset_x = ScaleWidth(game_data.sprite_width, WINDOW_ZOOM) / 2
					flip_offset_y = ScaleHeight(game_data.sprite_height, WINDOW_ZOOM) / 2
					
					love.graphics.draw(img_sprites[sprite], px + xc + flip_offset_x, py + yc + flip_offset_y, math.rad(run.vars.direction), game_data.pixel_size * WINDOW_ZOOM, WINDOW_ZOOM, game_data.sprite_width / 2, game_data.sprite_height / 2)
				else
					--draw monsters and bonus
					love.graphics.draw(img_sprites[sprite], px + xc, py + yc, 0, game_data.pixel_size * WINDOW_ZOOM, WINDOW_ZOOM)
				end
			end
		end
	end
end

-- check collision
function Collision(x1, y1, w1, h1, x2, y2, w2, h2)
   return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end

-- check block collision
function BlockCollision(x, y, map)
	-- collisions with game limits
	if x < 0 or x > (game_data.levels_data.sw * game_data.levels_data.w) - 1 then return true end
	if y < 0 or y > (game_data.levels_data.sh * game_data.levels_data.h) - 1 then return true end
	
	-- is there a block ?
	if map.blocks[x][y] > 0 then
		local block_number = map.blocks[x][y]
		
		-- collision with a wall
		if game_data.blocks_data[block_number].type == "wall" then
			return true
		end
	end
	
	return false
end

-- check platform collision
function PlatformCollision(x, y, map)
	-- collisions with game limits
	if x < 0 or x > (game_data.levels_data.sw * game_data.levels_data.w) - 1 then return true end
	if y < 0 or y > (game_data.levels_data.sh * game_data.levels_data.h) - 1 then return true end
	
	-- is there a block ?
	if map.blocks[x][y] > 0 then
		local block_number = map.blocks[x][y]
		
		-- collision with a platform
		if game_data.blocks_data[block_number].type == "platform" then
			return true
		end
	end
	
	return false
end

-- check stairway collision
function StairsCollision(x, y, map)
	-- collisions with game limits
	if x < 0 or x > (game_data.levels_data.sw * game_data.levels_data.w) - 1 then return true end
	if y < 0 or y > (game_data.levels_data.sh * game_data.levels_data.h) - 1 then return true end
	
	-- is there a block ?
	if map.blocks[x][y] > 0 then
		local block_number = map.blocks[x][y]
		
		-- collision with a stairway
		if game_data.blocks_data[block_number].type == "stairs" then
			return true
		end
	end
	
	return false
end

-- checking if the player is on the ground
function GroundCollision(x1, y1, w1, h1, map, w2, h2)
	-- offset with hotspot
	local actor_number = game_data.levels[run.vars.level].actors[1].number
	
	-- player's position, in blocks
	local x3 = math.floor(x1 / w2)
	local y3 = math.floor(y1 / h2)

	-- how many blocks in the player's sprite ?
	local w3 = math.floor(w1 / w2)
	local h3 = math.floor(h1 / h2)
	
	if x3 * w2 ~= x1 then w3 = w3 + 1 end
	if y3 * h2 ~= y1 then h3 = h3 + 1 end
	
	-- check if on the ground
	for x = x3, x3 + w3 - 1 do
		y = y3 + h3 - 1
		
		if BlockCollision(x, y, map) == true or PlatformCollision(x, y, map) == true then
			y1 = (y * h2) - h1

			return y1, true
		end
	end
	
	return y1, false
end

-- checking if the player collision with the ceiling
function CeilingCollision(x1, y1, w1, h1, map, w2, h2)
	-- offset with hotspot
	local actor_number = game_data.levels[run.vars.level].actors[1].number
	
	-- player's position, in blocks
	local x3 = math.floor(x1 / w2)
	local y3 = math.floor(y1 / h2)

	-- how many blocks in the player's sprite ?
	local w3 = math.floor(w1 / w2)
	local h3 = math.floor(h1 / h2)
	
	if x3 * w2 ~= x1 then w3 = w3 + 1 end
	if y3 * h2 ~= y1 then h3 = h3 + 1 end
	
	-- check if on the ground
	for x = x3, x3 + w3 - 1 do
		y = y3
		
		if BlockCollision(x, y, map) == true then
			y1 = (y + 1) * h2

			return y1
		end
	end
	
	return y1
end

-- checking if the player collision on left walls
function LeftCollision(x1, y1, w1, h1, map, w2, h2)
	-- offset with hotspot
	local actor_number = game_data.levels[run.vars.level].actors[1].number
	
	-- player's position, in blocks
	local x3 = math.floor(x1 / w2)
	local y3 = math.floor(y1 / h2)

	-- how many blocks in the player's sprite ?
	local w3 = math.floor(w1 / w2)
	local h3 = math.floor(h1 / h2)
	
	if x3 * w2 ~= x1 then w3 = w3 + 1 end
	if y3 * h2 ~= y1 then h3 = h3 + 1 end
	
	-- left
	for y = y3, y3 + h3 - 1 do
		x = x3
			
		if BlockCollision(x, y, map) == true then
			x1 = ((x + 1) * w2)
					
			return x1
		end
	end
	
	return x1
end

-- checking if the player collision on right walls
function RightCollision(x1, y1, w1, h1, map, w2, h2)
	-- offset with hotspot
	local actor_number = game_data.levels[run.vars.level].actors[1].number
	
	-- player's position, in blocks
	local x3 = math.floor(x1 / w2)
	local y3 = math.floor(y1 / h2)

	-- how many blocks in the player's sprite ?
	local w3 = math.floor(w1 / w2)
	local h3 = math.floor(h1 / h2)
	
	if x3 * w2 ~= x1 then w3 = w3 + 1 end
	if y3 * h2 ~= y1 then h3 = h3 + 1 end
	
	-- right
	for y = y3, y3 + h3 - 1 do
		x = x3 + w3 - 1
			
		if BlockCollision(x, y, map) == true then
			x1 = (x * w2) - w1
					
			return x1
		end
	end
	
	return x1
end

-- sliding collision between player's sprite and corners
function CornerCollision(x1, y1, w1, h1, map, w2, h2, on_the_ground)
	-- offset with hotspot
	local actor_number = game_data.levels[run.vars.level].actors[1].number
	
	-- player's position, in blocks
	local x3 = math.floor(x1 / w2)
	local y3 = math.floor(y1 / h2)

	-- how many blocks in the player's sprite ?
	local w3 = math.floor(w1 / w2)
	local h3 = math.floor(h1 / h2)
	
	if x3 * w2 ~= x1 then w3 = w3 + 1 end
	if y3 * h2 ~= y1 then h3 = h3 + 1 end
	
	-- right-down
	x = x3 + w3 - 1
	y = y3 + h3 - 1
		
	if BlockCollision(x, y, map) == true then
		x1 = (x * w2) - w1
		y1 = (y * h2) - h1
				
		return x1, false
	end

	-- left-down
	x = x3
	y = y3 + h3 - 1
		
	if BlockCollision(x, y, map) == true then
		x1 = ((x + 1) * w2)
		y1 = (y * h2) - h1
				
		return x1, false
	end

	-- left-up
	x = x3
	y = y3
		
	if BlockCollision(x, y, map) == true then
		x1 = ((x + 1) * w2)
		y1 = ((y + 1) * h2)
				
		return x1, false
	end

	-- right-up
	x = x3 + w3 - 1
	y = y3
		
	if BlockCollision(x, y, map) == true then
		x1 = (x * w2) - w1
		y1 = ((y + 1) * h2)
				
		return x1, false
	end
	
	return x1, on_the_ground
end

-- check if the player can climb
function CanClimb(x1, y1, w1, h1, map, w2, h2)
	-- offset with hotspot
	local actor_number = game_data.levels[run.vars.level].actors[1].number
	
	-- player's position, in blocks
	local x3 = math.floor(x1 / w2)
	local y3 = math.floor(y1 / h2)

	-- how many blocks in the player's sprite ?
	local w3 = math.floor(w1 / w2)
	local h3 = math.floor(h1 / h2)
	
	if x3 * w2 ~= x1 then w3 = w3 + 1 end
	if y3 * h2 ~= y1 then h3 = h3 + 1 end

	for x = x3, x3 + w3 - 1 do
		for y = y3, y3 + h3 - 1 do
			if StairsCollision(x, y, map) == true then
				return true
			end
		end
	end
	
	return false
end

-- sliding collision between player's sprite and max 6 blocks inside the player
function SlidingCollisionX(x1, y1, w1, h1, d1, map, w2, h2)
	-- offset with hotspot
	local actor_number = game_data.levels[run.vars.level].actors[1].number
	
	-- player's position, in blocks
	local x3 = math.floor(x1 / w2)
	local y3 = math.floor(y1 / h2)

	-- how many blocks in the player's sprite ?
	local w3 = math.floor(w1 / w2)
	local h3 = math.floor(h1 / h2)
	
	if x3 * w2 ~= x1 then w3 = w3 + 1 end
	if y3 * h2 ~= y1 then h3 = h3 + 1 end
	
	-- check for collisions on x axis
	if d1 == 0 or d1 == 45 or d1 == 315 then
		-- right
		for y = y3, y3 + h3 - 1 do
			x = x3 + w3 - 1
			
			if BlockCollision(x, y, map) == true then
				x1 = (x * w2) - w1
					
				return x1
			end
		end
	elseif d1 == 180 or d1 == 135 or d1 == 225 then
		-- left
		for y = y3, y3 + h3 - 1 do
			x = x3
			
			if BlockCollision(x, y, map) == true then
				x1 = ((x + 1) * w2)
					
				return x1
			end
		end
	end
	
	return x1
end

-- sliding collision between player's sprite and max 6 blocks inside the player
function SlidingCollisionY(x1, y1, w1, h1, d1, map, w2, h2)
	-- offset with hotspot
	local actor_number = game_data.levels[run.vars.level].actors[1].number
	
	-- player's position, in blocks
	local x3 = math.floor(x1 / w2)
	local y3 = math.floor(y1 / h2)

	-- how many blocks in the player's sprite ?
	local w3 = math.floor(w1 / w2)
	local h3 = math.floor(h1 / h2)
	
	if x3 * w2 ~= x1 then w3 = w3 + 1 end
	if y3 * h2 ~= y1 then h3 = h3 + 1 end
	
	-- check for collisions on y axis
	if d1 == 90 or d1 == 45 or d1 == 135 then
		-- down
		for x = x3, x3 + w3 - 1 do
			y = y3 + h3 - 1
			
			if BlockCollision(x, y, map) == true or PlatformCollision(x, y, map) == true then
				y1 = (y * h2) - h1
				
				return y1
			end
		end
	elseif d1 == 270 or d1 == 225 or d1 == 315 then
		-- up
		for x = x3, x3 + w3 - 1 do
			y = y3
			
			if BlockCollision(x, y, map) == true then
				y1 = ((y + 1) * h2)
					
				return y1
			end
		end
	end
	
	return y1
end

-- sliding collision between player's sprite and corners
function SlidingCollisionZ(x1, y1, w1, h1, d1, map, w2, h2)
	-- offset with hotspot
	local actor_number = game_data.levels[run.vars.level].actors[1].number
	
	-- player's position, in blocks
	local x3 = math.floor(x1 / w2)
	local y3 = math.floor(y1 / h2)

	-- how many blocks in the player's sprite ?
	local w3 = math.floor(w1 / w2)
	local h3 = math.floor(h1 / h2)
	
	if x3 * w2 ~= x1 then w3 = w3 + 1 end
	if y3 * h2 ~= y1 then h3 = h3 + 1 end
	
	-- check for collisions within corners
	if d1 == 45 then
		-- right-down
		x = x3 + w3 - 1
		y = y3 + h3 - 1
		
		if BlockCollision(x, y, map) == true or PlatformCollision(x, y, map) == true then
			x1 = (x * w2) - w1
			y1 = (y * h2) - h1
				
			return x1, y1
		end
	elseif d1 == 135 then
		-- left-down
		x = x3
		y = y3 + h3 - 1
		
		if BlockCollision(x, y, map) == true or PlatformCollision(x, y, map) == true then
			x1 = ((x + 1) * w2)
			y1 = (y * h2) - h1
				
			return x1, y1
		end
	elseif d1 == 225 then
		-- left-up
		x = x3
		y = y3
		
		if BlockCollision(x, y, map) == true then
			x1 = ((x + 1) * w2)
			y1 = ((y + 1) * h2)
				
			return x1, y1
		end
	elseif d1 == 315 then
		-- right-up
		x = x3 + w3 - 1
		y = y3
		
		if BlockCollision(x, y, map) == true then
			x1 = (x * w2) - w1
			y1 = ((y + 1) * h2)
				
			return x1, y1
		end
	end
	
	return x1, y1
end

return run

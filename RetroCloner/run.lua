local run = {}


local MODE_INTRO = 1
local MODE_IN_GAME = 2
local MODE_WINNER = 3
local MODE_GAME_OVER = 4

local DT_CORRECTION = 60
local SCROLLING_SLOW_DOWN = 4

local ENTITY_TYPE_PLAYER = 1
local ENTITY_TYPE_ENEMY = 2
local ENTITY_TYPE_BONUS = 3

local ENEMY_SEEK_MODE = 0
local ENEMY_RANDOM_MODE = 1

local GOAL_EXIT_RIGHT = 1
local GOAL_KILL_ALL_ENEMIES = 2
local GOAL_KILL_ALL_ENEMIES_EXIT_RIGHT = 3
local GOAL_TAKE_ALL_BONUS = 4
local GOAL_TAKE_KEY_AND_EXIT = 5

-- run arrays
run.vars = {
	level_actors = {},
	game_mode = 0,
	score = 0,
	level = 0,
	health = 0,
	scrolling_x = 0,
	scrolling_y = 0,
	game_speed_timer = 0.0,
	animations_timer = 0.0,
	blink_timer = 0.0,
	jump_power = 0,
	fall_power = 0,
	dir = 0,
	dir_x = 0,
	dir_y = 0,
	requested_dir = 0,
	on_the_ground = false,
	on_stairs = false,
	invincible = false,
	invincibility_duration = 0,
	enemy_move_timer = 0.0,
	sounds = { player = {walk = "", run = "", jump = "", hit = "", fire1 = "", fire2 = ""},
			   enemies = {},
			   bonus = {}
	},
	musics = { intro = "", ingame = "", winner = "", game_over = "" },
	images = { intro = "", interface = "", winner = "", game_over = "" }
}

-- run vars
local animations_tick = false
local game_speed_tick = false

local moving = false
local moving_down = false

local joysticks = nil
local joy = nil

-- run functions
function run.load()
	-- initialize game mode
	run.vars.game_mode = MODE_INTRO
	
	-- initialize player's data
	run.vars.score = 0
	run.vars.level = 1
	run.vars.health = 100
	
	-- initialize all
	CommonInit()

	-- load musics
	for i = 1, #music_types do
		local filename = game_data.musics[music_types[i]]
		
		if filename ~= "-" then
			if project_name ~= nil then
				run.vars.musics[music_types[i]] = love.audio.newSource("saves/" .. project_name .. "/" .. filename, "stream")
			else
				run.vars.musics[music_types[i]] = love.audio.newSource("saves/game/" .. filename, "stream")
			end
		else
			run.vars.musics[music_types[i]] = nil
		end
	end
	
	-- load images
	for i = 1, #image_types do
		local filename = game_data.images[image_types[i]]
		
		if filename ~= "-" then
			if project_name ~= nil then
				run.vars.images[image_types[i]] = love.graphics.newImage("saves/" .. project_name .. "/" .. filename)
			else
				run.vars.images[image_types[i]] = love.graphics.newImage("saves/game/" .. filename)
			end
		else
			run.vars.images[image_types[i]] = nil
		end
	end
	
	-- get joystick
	joysticks = love.joystick.getJoysticks()
    joy = joysticks[1]
	
	-- hide mouse
	love.mouse.setVisible(false)
end

function run.update(dt)
	if run.vars.game_mode == MODE_INTRO then
		-- stop all musics and start intro music, if needed
		if run.vars.musics.intro ~= nil then
			if not run.vars.musics.intro:isPlaying() then
				run.vars.musics.intro:play()
				run.vars.musics.intro:setLooping(true)
			end
		end

		if run.vars.musics.in_game ~= nil then
			if run.vars.musics.in_game:isPlaying() then
				run.vars.musics.in_game:stop()
			end
		end

		if run.vars.musics.winner ~= nil then
			if run.vars.musics.winner:isPlaying() then
				run.vars.musics.winner:stop()
			end
		end

		if run.vars.musics.game_over ~= nil then
			if run.vars.musics.game_over:isPlaying() then
				run.vars.musics.game_over:stop()
			end
		end
		
		-- press start to play blinks
		if run.vars.images.intro == nil or run.vars.images.intro == "" then
			run.vars.blink_timer = run.vars.blink_timer + dt
			
			if run.vars.blink_timer >= 1.0 then
				run.vars.blink_timer = 0.0
			end
		end
	elseif run.vars.game_mode == MODE_IN_GAME then
		-- stop all musics and start in_game music, if needed
		if run.vars.musics.intro ~= nil then
			if run.vars.musics.intro:isPlaying() then
				run.vars.musics.intro:stop()
			end
		end

		if run.vars.musics.in_game ~= nil then
			if not run.vars.musics.in_game:isPlaying() then
				run.vars.musics.in_game:play()
				run.vars.musics.in_game:setLooping(true)
			end
		end

		if run.vars.musics.winner ~= nil then
			if run.vars.musics.winner:isPlaying() then
				run.vars.musics.winner:stop()
			end
		end

		if run.vars.musics.game_over ~= nil then
			if run.vars.musics.game_over:isPlaying() then
				run.vars.musics.game_over:stop()
			end
		end

		-- update timers
		run.vars.game_speed_timer = run.vars.game_speed_timer + dt
		run.vars.animations_timer = run.vars.animations_timer + dt
		run.vars.enemy_move_timer = run.vars.enemy_move_timer + dt
		
		if run.vars.invincibility_duration > 0.0 then
			run.vars.invincibility_duration = run.vars.invincibility_duration - dt
			
			if run.vars.invincibility_duration < 0.0 then
				run.vars.invincibility_duration = 0.0
			end
			
			if run.vars.invincibility_duration == 0.0 then
				run.vars.invincible = false
			end
		end
		
		animations_tick = false
		game_speed_tick = false
		
		local max_game_timer = 0.05 / game_data.vars.game_speed
		
		if run.vars.game_speed_timer >= max_game_timer then
			run.vars.game_speed_timer = run.vars.game_speed_timer - max_game_timer
			game_speed_tick = true
		end
		
		local max_animations_timer = 0.5 / game_data.vars.animations_speed

		if run.vars.animations_timer >= max_animations_timer then
			run.vars.animations_timer = run.vars.animations_timer - max_animations_timer
			animations_tick = true
		end
		
		if run.vars.enemy_move_timer >= 2.0 then
			run.vars.enemy_move_timer = 0.0
		end
			
		if #game_data.levels > 0 then
			local old_x = run.vars.level_actors[1].x
			local old_y = run.vars.level_actors[1].y
			local new_x = old_x
			local new_y = old_y
			
			local joy_up = false
			local joy_down = false
			local joy_left = false
			local joy_right = false

				-- move the player
			local actor_number = run.vars.level_actors[1].number
		
			if game_speed_tick == true then	
				-- get keyboard fist
				joy_up = love.keyboard.isDown("up")
				joy_down = love.keyboard.isDown("down")
				joy_left = love.keyboard.isDown("left")
				joy_right = love.keyboard.isDown("right")
				
				-- get joystick after, is keyboard is not used
				if joy ~= nil then
					-- using dpad
					if joy_up == false then joy_up = joy:isGamepadDown("dpup") end
					if joy_down == false then joy_down = joy:isGamepadDown("dpdown") end
					if joy_left == false then joy_left = joy:isGamepadDown("dpleft") end
					if joy_right == false then joy_right = joy:isGamepadDown("dpright") end
					
					-- using left joystick
					if joy_up == false then
						if joy:getGamepadAxis("lefty") < 0 then
							joy_up = true
						end
					end

					if joy_down == false then
						if joy:getGamepadAxis("lefty") > 0 then
							joy_down = true
						end
					end

					if joy_left == false then
						if joy:getGamepadAxis("leftx") < 0 then
							joy_left = true
						end
					end

					if joy_right == false then
						if joy:getGamepadAxis("leftx") > 0 then
							joy_right = true
						end
					end
				end
				
				-- (TODO! set all player's type gameplay)
				if game_data.actors[actor_number].type.name == "platformer" then
					moving = false
					moving_down = false
					
					if CanClimb(old_x, old_y, game_data.sprite_width, game_data.sprite_height, game_data.levels[run.vars.level], game_data.block_width, game_data.block_height) == true then
						run.vars.on_stairs = true
					else
						run.vars.on_stairs = false
					end
				
					if joy_left == true then
						if run.vars.level_actors[1].animation == GetActorAnimationNumber(actor_number, "idle") or 
														run.vars.level_actors[1].animation == GetActorAnimationNumber(actor_number, "walk") or 
														run.vars.level_actors[1].animation == GetActorAnimationNumber(actor_number, "jump") or 
														run.vars.level_actors[1].animation == GetActorAnimationNumber(actor_number, "climb") then						
							run.vars.level_actors[1].hflip = true
							run.vars.dir = 180
							moving = true
							
							-- change animation if needed
							if run.vars.level_actors[1].animation == GetActorAnimationNumber(actor_number, "idle") then
								run.vars.level_actors[1].animation = GetActorAnimationNumber(actor_number, "walk")
								run.vars.level_actors[1].frame = 1
							end

							-- walk left
							new_x = new_x - game_data.vars.player_speed
						end
					elseif joy_right == true then
						if run.vars.level_actors[1].animation == GetActorAnimationNumber(actor_number, "idle") or 
														run.vars.level_actors[1].animation == GetActorAnimationNumber(actor_number, "walk") or 
														run.vars.level_actors[1].animation == GetActorAnimationNumber(actor_number, "jump") or 
														run.vars.level_actors[1].animation == GetActorAnimationNumber(actor_number, "climb") then						
							run.vars.level_actors[1].hflip = false
							run.vars.dir = 0
							moving = true
							
							-- change animation if needed
							if run.vars.level_actors[1].animation == GetActorAnimationNumber(actor_number, "idle") then
								run.vars.level_actors[1].animation = GetActorAnimationNumber(actor_number, "walk")
								run.vars.level_actors[1].frame = 1
							end
							
							-- walk right
							new_x = new_x + game_data.vars.player_speed
						end
					elseif joy_up == true then
						-- climb up
						run.vars.dir = 270
						moving = true

						if run.vars.on_stairs == true then
							if run.vars.level_actors[1].animation == GetActorAnimationNumber(actor_number, "idle") or 
															run.vars.level_actors[1].animation == GetActorAnimationNumber(actor_number, "walk") then
								run.vars.level_actors[1].animation = GetActorAnimationNumber(actor_number, "climb")
								run.vars.level_actors[1].frame = 1
							end
							
							new_y = new_y - game_data.vars.player_speed
						end
					elseif joy_down == true then
						-- climb down
						run.vars.dir = 90
						moving = true
						moving_down = true

						if run.vars.on_stairs == true then
							if run.vars.level_actors[1].animation == GetActorAnimationNumber(actor_number, "idle") or 
															run.vars.level_actors[1].animation == GetActorAnimationNumber(actor_number, "walk") then
								run.vars.level_actors[1].animation = GetActorAnimationNumber(actor_number, "climb")
								run.vars.level_actors[1].frame = 1
							end
							
							new_y = new_y + game_data.vars.player_speed
						end
					end
					
					if run.vars.on_the_ground == true then
						if moving == false then
							if run.vars.level_actors[1].animation == GetActorAnimationNumber(actor_number, "walk") then
								-- on the ground ? not moving ?
								run.vars.level_actors[1].animation = GetActorAnimationNumber(actor_number, "idle")
								run.vars.level_actors[1].frame = 1
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
					if run.vars.on_stairs == false then
						new_y = new_y + run.vars.fall_power + run.vars.jump_power
					end
					
					-- check for player's collisions with blocks, because may be he has moved
					new_y, run.vars.on_the_ground = GroundCollision(old_x, new_y, game_data.sprite_width, game_data.sprite_height, game_data.levels[run.vars.level], game_data.block_width, game_data.block_height, run.vars.on_stairs, moving_down)
					new_y = CeilingCollision(old_x, new_y, game_data.sprite_width, game_data.sprite_height, game_data.levels[run.vars.level], game_data.block_width, game_data.block_height)
					new_x = LeftCollision(new_x, old_y, game_data.sprite_width, game_data.sprite_height, game_data.levels[run.vars.level], game_data.block_width, game_data.block_height)
					new_x = RightCollision(new_x, old_y, game_data.sprite_width, game_data.sprite_height, game_data.levels[run.vars.level], game_data.block_width, game_data.block_height)
					new_x, run.vars.on_the_ground = CornerCollision(new_x, new_y, game_data.sprite_width, game_data.sprite_height, game_data.levels[run.vars.level], game_data.block_width, game_data.block_height, run.vars.on_the_ground)

					-- restore idle animation
					if run.vars.on_the_ground == true then
						local actor_number = run.vars.level_actors[1].number

						if run.vars.level_actors[1].animation == GetActorAnimationNumber(actor_number, "jump") then
							run.vars.level_actors[1].animation = GetActorAnimationNumber(actor_number, "idle")
							run.vars.level_actors[1].frame = 1
						end
					end
					
					-- no jump if we are on stairs
					if run.vars.on_stairs == true then
						local actor_number = run.vars.level_actors[1].number

						if run.vars.level_actors[1].animation == GetActorAnimationNumber(actor_number, "jump") then
							run.vars.level_actors[1].animation = GetActorAnimationNumber(actor_number, "climb")
							run.vars.level_actors[1].frame = 1
							run.vars.jump_power = 0
							run.vars.fall_power = 0
						end
					end

					-- restore idle animation
					if run.vars.on_stairs == false then
						if run.vars.level_actors[1].animation == GetActorAnimationNumber(actor_number, "climb") then
							run.vars.level_actors[1].animation = GetActorAnimationNumber(actor_number, "idle")
							run.vars.level_actors[1].frame = 1
						end
					end
				elseif game_data.actors[actor_number].type.name == "beat'em up" then
				
				elseif game_data.actors[actor_number].type.name == "run & gun (edge view)" then
				
				elseif game_data.actors[actor_number].type.name == "run & gun (top view)" then
					-- automove
					if game_data.vars.automove == false then
						if joy_up == false and joy_down == false and joy_left == false and joy_right == false then
							run.vars.dir_x = 0
							run.vars.dir_y = 0
						end
					end
					
					if joy_up == true then
						if joy_left == true then
							run.vars.dir = 225
							run.vars.dir_x = -1
							run.vars.dir_y = -1
						elseif joy_right == true then
							run.vars.dir = 315
							run.vars.dir_x = 1
							run.vars.dir_y = -1
						else
							run.vars.dir = 270
							run.vars.dir_x = 0
							run.vars.dir_y = -1
						end
					elseif joy_down == true then
						if joy_left == true then
							run.vars.dir = 135
							run.vars.dir_x = -1
							run.vars.dir_y = 1
						elseif joy_right == true then
							run.vars.dir = 45
							run.vars.dir_x = 1
							run.vars.dir_y = 1
						else
							run.vars.dir = 90
							run.vars.dir_x = 0
							run.vars.dir_y = 1
						end
					elseif joy_left == true then
						if joy_up == true then
							run.vars.dir = 225						
							run.vars.dir_x = -1
							run.vars.dir_y = -1
						elseif joy_down == true then
							run.vars.dir = 135
							run.vars.dir_x = -1
							run.vars.dir_y = 1
						else
							run.vars.dir = 180
							run.vars.dir_x = -1
							run.vars.dir_y = 0
						end
					elseif joy_right == true then
						if joy_up == true then
							run.vars.dir = 315
							run.vars.dir_x = 1
							run.vars.dir_y = -1
						elseif joy_down == true then
							run.vars.dir = 45
							run.vars.dir_x = 1
							run.vars.dir_y = 1
						else
							run.vars.dir = 0
							run.vars.dir_x = 1
							run.vars.dir_y = 0
						end
					end
					
					if run.vars.dir_x == -1 then
						moving = true
						
						-- change animation if needed
						if run.vars.level_actors[1].animation == GetActorAnimationNumber(actor_number, "idle") then
							run.vars.level_actors[1].animation = GetActorAnimationNumber(actor_number, "run")
							run.vars.level_actors[1].frame = 1
							
						end

						-- walk left
						new_x = new_x - game_data.vars.player_speed
					elseif run.vars.dir_x == 1 then
						moving = true
						
						-- change animation if needed
						if run.vars.level_actors[1].animation == GetActorAnimationNumber(actor_number, "idle") then
							run.vars.level_actors[1].animation = GetActorAnimationNumber(actor_number, "run")
							run.vars.level_actors[1].frame = 1
						end
						
						-- walk right
						new_x = new_x + game_data.vars.player_speed
					end
						
					if run.vars.dir_y == -1 then
						moving = true
						
						-- change animation if needed
						if run.vars.level_actors[1].animation == GetActorAnimationNumber(actor_number, "idle") then
							run.vars.level_actors[1].animation = GetActorAnimationNumber(actor_number, "run")
							run.vars.level_actors[1].frame = 1
							
						end

						-- walk left
						new_y = new_y - game_data.vars.player_speed
					elseif run.vars.dir_y == 1 then
						moving = true
						
						-- change animation if needed
						if run.vars.level_actors[1].animation == GetActorAnimationNumber(actor_number, "idle") then
							run.vars.level_actors[1].animation = GetActorAnimationNumber(actor_number, "run")
							run.vars.level_actors[1].frame = 1
						end
						
						-- walk right
						new_y = new_y + game_data.vars.player_speed
					end
					
					-- check for player's collisions with blocks, because may be he has moved
					new_x, collision = SlidingCollisionX(new_x, old_y, game_data.sprite_width, game_data.sprite_height, run.vars.dir, game_data.levels[run.vars.level], game_data.block_width, game_data.block_height)
					new_y, collision = SlidingCollisionY(old_x, new_y, game_data.sprite_width, game_data.sprite_height, run.vars.dir, game_data.levels[run.vars.level], game_data.block_width, game_data.block_height)
					new_x, new_y = SlidingCollisionZ(new_x, new_y, game_data.sprite_width, game_data.sprite_height, run.vars.dir, game_data.levels[run.vars.level], game_data.block_width, game_data.block_height)
				elseif game_data.actors[actor_number].type.name == "maze & chase" then
					-- get inputs
					if run.vars.dir == 0 then
						if joy_up == true then
							run.vars.requested_dir = 270
						elseif joy_down == true then
							run.vars.requested_dir = 90
						elseif joy_right == true then
							run.vars.requested_dir = 0
						elseif joy_left == true then
							run.vars.requested_dir = 180
						end
					elseif run.vars.dir == 90 then
						if joy_left == true then
							run.vars.requested_dir = 180
						elseif joy_right == true then
							run.vars.requested_dir = 0
						elseif joy_down == true then
							run.vars.requested_dir = 90
						elseif joy_up == true then
							run.vars.requested_dir = 270
						end
					elseif run.vars.dir == 180 then
						if joy_up == true then
							run.vars.requested_dir = 270
						elseif joy_down == true then
							run.vars.requested_dir = 90
						elseif joy_left == true then
							run.vars.requested_dir = 180
						elseif joy_right == true then
							run.vars.requested_dir = 0
						end
					elseif run.vars.dir == 270 then
						if joy_left == true then
							run.vars.requested_dir = 180
						elseif joy_right == true then
							run.vars.requested_dir = 0
						elseif joy_up == true then
							run.vars.requested_dir = 270
						elseif joy_down == true then
							run.vars.requested_dir = 90
						end
					end

					-- can we turn ?
					local can_turn = false

					if run.vars.requested_dir == 0 or run.vars.requested_dir == 180 then
						local dir_sign = (run.vars.requested_dir == 0) and 1 or -1
						local test_x = old_x + dir_sign * game_data.vars.player_speed

						local _, collision = SlidingCollisionX(
							test_x,
							old_y,
							game_data.sprite_width,
							game_data.sprite_height,
							run.vars.requested_dir,
							game_data.levels[run.vars.level],
							game_data.block_width,
							game_data.block_height
						)

						if collision == false then
							can_turn = true
						end

					elseif run.vars.requested_dir == 90 or run.vars.requested_dir == 270 then
						local dir_sign = (run.vars.requested_dir == 90) and 1 or -1
						local test_y = old_y + dir_sign * game_data.vars.player_speed

						local _, collision = SlidingCollisionY(
							old_x,
							test_y,
							game_data.sprite_width,
							game_data.sprite_height,
							run.vars.requested_dir,
							game_data.levels[run.vars.level],
							game_data.block_width,
							game_data.block_height
						)

						if collision == false then
							can_turn = true
						end
					end

					-- appliquer le turn si possible
					if can_turn == true then
						run.vars.dir = run.vars.requested_dir
					end

					-- calculate movements
					local target_x = old_x
					local target_y = old_y

					if run.vars.dir == 180 then
						if joy_left == true or game_data.vars.automove == true then
							moving = true
							target_x = target_x - game_data.vars.player_speed
						end

					elseif run.vars.dir == 0 then
						if joy_right == true or game_data.vars.automove == true then
							moving = true
							target_x = target_x + game_data.vars.player_speed
						end

					elseif run.vars.dir == 270 then
						if joy_up == true or game_data.vars.automove == true then
							moving = true
							target_y = target_y - game_data.vars.player_speed
						end

					elseif run.vars.dir == 90 then
						if joy_down == true or game_data.vars.automove == true then
							moving = true
							target_y = target_y + game_data.vars.player_speed
						end
					end

					-- animating
					if moving == true then
						if run.vars.level_actors[1].animation == GetActorAnimationNumber(actor_number, "idle") then
							run.vars.level_actors[1].animation = GetActorAnimationNumber(actor_number, "move")
							run.vars.level_actors[1].frame = 1
						end
					end

					-- collision after movements
					local collision = false

					if run.vars.dir == 0 or run.vars.dir == 180 then
						new_x, collision = SlidingCollisionX(
							target_x,
							old_y,
							game_data.sprite_width,
							game_data.sprite_height,
							run.vars.dir,
							game_data.levels[run.vars.level],
							game_data.block_width,
							game_data.block_height
						)
						new_y = old_y

					elseif run.vars.dir == 90 or run.vars.dir == 270 then
						new_y, collision = SlidingCollisionY(
							old_x,
							target_y,
							game_data.sprite_width,
							game_data.sprite_height,
							run.vars.dir,
							game_data.levels[run.vars.level],
							game_data.block_width,
							game_data.block_height
						)
						new_x = old_x
					end
				elseif game_data.actors[actor_number].type.name == "fixed shooter" then
				
				elseif game_data.actors[actor_number].type.name == "horizontal shooter" then
				
				elseif game_data.actors[actor_number].type.name == "vertical shooter" then
				
				end
				
				local screen_width = game_data.levels_data.sw * game_data.block_width
				local screen_height = game_data.levels_data.sh * game_data.block_height

				-- clamp left / right (in the screen)
				if new_x + run.vars.scrolling_x < 0 then
					new_x = -run.vars.scrolling_x
				end

				if new_x + run.vars.scrolling_x > screen_width - game_data.sprite_width then
					new_x = screen_width - game_data.sprite_width - run.vars.scrolling_x
				end

				-- clamp up / down (in the screen)
				if new_y + run.vars.scrolling_y < 0 then
					new_y = -run.vars.scrolling_y
				end

				if new_y + run.vars.scrolling_y > screen_height - game_data.sprite_height then
					new_y = screen_height - game_data.sprite_height - run.vars.scrolling_y
				end

				-- update coordinates of the player
				run.vars.level_actors[1].x = new_x
				run.vars.level_actors[1].y = new_y
			end

			-- it is time to animate the player
			if animations_tick == true then
				-- animation not looping and ended ?
				if AnimateCharacter(1, moving) == true then
					run.vars.level_actors[1].animation = GetActorAnimationNumber(actor_number, "idle")
					run.vars.level_actors[1].frame = 1
				end
			end
		end

		-- perform scrolling
		if game_data.vars.scrolling_type == 2 then
			local center_x = (game_data.levels_data.sw * game_data.block_width / 2)
			local center_y = (game_data.levels_data.sh * game_data.block_height / 2)
			local max_limit_x = ((game_data.levels_data.w - 1) * game_data.levels_data.sw * game_data.block_width)
			local max_limit_y = ((game_data.levels_data.h - 1) * game_data.levels_data.sh * game_data.block_height)
			local scroll_speed = game_data.vars.player_speed
			
			-- scroll when the player is in the middle of the screen
			if game_data.vars.scrolling_horizontally == true and game_data.vars.scrolling_vertically == false then
				-- scroll forward x
				if run.vars.level_actors[1].x + run.vars.scrolling_x > center_x then
					if -run.vars.scrolling_x < max_limit_x then
						local scroll_value = run.vars.level_actors[1].x - center_x + run.vars.scrolling_x
						
						run.vars.scrolling_x = run.vars.scrolling_x - scroll_speed
						run.vars.level_actors[1].x = run.vars.level_actors[1].x - scroll_value + scroll_speed
					end
				end

				-- scroll backward x
				if game_data.vars.scroll_backward == true then
					if run.vars.level_actors[1].x + run.vars.scrolling_x < center_x then
						if -run.vars.scrolling_x > 0 then
							local scroll_value = run.vars.level_actors[1].x - center_x + run.vars.scrolling_x
							
							run.vars.scrolling_x = run.vars.scrolling_x + scroll_speed
							run.vars.level_actors[1].x = run.vars.level_actors[1].x + scroll_value + scroll_speed
						end
					end
				end
			elseif game_data.vars.scrolling_horizontally == false and game_data.vars.scrolling_vertically == true then
				-- scroll forward y
				if run.vars.level_actors[1].y + run.vars.scrolling_y > center_y then
					if -run.vars.scrolling_y < max_limit_y then
						local scroll_value = run.vars.level_actors[1].y - center_y + run.vars.scrolling_y
						
						run.vars.scrolling_y = run.vars.scrolling_y - scroll_speed
						run.vars.level_actors[1].y = run.vars.level_actors[1].y - scroll_value + scroll_speed
					end
				end

				-- scroll backward y
				if game_data.vars.scroll_backward == true then
					if run.vars.level_actors[1].y + run.vars.scrolling_y < center_y then
						if -run.vars.scrolling_y > 0 then
							local scroll_value = run.vars.level_actors[1].y - center_y + run.vars.scrolling_y
							
							run.vars.scrolling_y = run.vars.scrolling_y + scroll_speed
							run.vars.level_actors[1].y = run.vars.level_actors[1].y + scroll_value + scroll_speed
						end
					end
				end
			elseif game_data.vars.scrolling_horizontally == true and game_data.vars.scrolling_vertically == true then
				-- scroll forward x
				if run.vars.level_actors[1].x + run.vars.scrolling_x > center_x then
					if -run.vars.scrolling_x < max_limit_x then
						local scroll_value = run.vars.level_actors[1].x - center_x + run.vars.scrolling_x
						
						run.vars.scrolling_x = run.vars.scrolling_x - scroll_speed
						run.vars.level_actors[1].x = run.vars.level_actors[1].x - scroll_value + scroll_speed
					end
				end

				-- scroll backward x
				if game_data.vars.scroll_backward == true then
					if run.vars.level_actors[1].x + run.vars.scrolling_x < center_x then
						if -run.vars.scrolling_x > 0 then
							local scroll_value = run.vars.level_actors[1].x - center_x + run.vars.scrolling_x
							
							run.vars.scrolling_x = run.vars.scrolling_x + scroll_speed
							run.vars.level_actors[1].x = run.vars.level_actors[1].x + scroll_value + scroll_speed
						end
					end
				end

				-- scroll forward y
				if run.vars.level_actors[1].y + run.vars.scrolling_y > center_y then
					if -run.vars.scrolling_y < max_limit_y then
						local scroll_value = run.vars.level_actors[1].y - center_y + run.vars.scrolling_y
						
						run.vars.scrolling_y = run.vars.scrolling_y - scroll_speed
						run.vars.level_actors[1].y = run.vars.level_actors[1].y - scroll_value + scroll_speed
					end
				end

				-- scroll backward y
				if game_data.vars.scroll_backward == true then
					if run.vars.level_actors[1].y + run.vars.scrolling_y < center_y then
						if -run.vars.scrolling_y > 0 then
							local scroll_value = run.vars.level_actors[1].y - center_y + run.vars.scrolling_y
							
							run.vars.scrolling_y = run.vars.scrolling_y + scroll_speed
							run.vars.level_actors[1].y = run.vars.level_actors[1].y + scroll_value + scroll_speed
						end
					end
				end
			end
		elseif game_data.vars.scrolling_type == 3 then
			local scroll_speed = ((2 ^ game_data.vars.scrolling_speed) / SCROLLING_SLOW_DOWN)
			local max_limit_x = ((game_data.levels_data.w - 1) * game_data.levels_data.sw * game_data.block_width)
			local max_limit_y = ((game_data.levels_data.h - 1) * game_data.levels_data.sh * game_data.block_height)
			
			-- auto scroll
			if animations_tick == true then
				if game_data.vars.scrolling_horizontally == true and game_data.vars.scrolling_vertically == false then
					if run.vars.level_actors[1].x > math.abs(run.vars.scrolling_x) then
						if -run.vars.scrolling_x < max_limit_x then
							run.vars.scrolling_x = run.vars.scrolling_x - scroll_speed
						end
					end
				elseif game_data.vars.scrolling_horizontally == false and game_data.vars.scrolling_vertically == true then
					if run.vars.level_actors[1].y > math.abs(run.vars.scrolling_y) then
						if -run.vars.scrolling_y < max_limit_y then
							run.vars.scrolling_y = run.vars.scrolling_y - scroll_speed
						end
					end
				elseif game_data.vars.scrolling_horizontally == true and game_data.vars.scrolling_vertically == true then
					if run.vars.level_actors[1].x > math.abs(run.vars.scrolling_x) then
						if -run.vars.scrolling_x < max_limit_x then
							run.vars.scrolling_x = run.vars.scrolling_x - scroll_speed
						end
					end

					if run.vars.level_actors[1].y > math.abs(run.vars.scrolling_y) then
						if -run.vars.scrolling_y < max_limit_y then
							run.vars.scrolling_y = run.vars.scrolling_y - scroll_speed
						end
					end
				end
			end
		elseif game_data.vars.scrolling_type == 4 then
			-- scroll when the player go out of a screen
			if game_data.vars.scrolling_horizontally == true and game_data.vars.scrolling_vertically == false then
				run.vars.scrolling_x = -math.floor(run.vars.level_actors[1].x / (game_data.levels_data.sw * game_data.block_width)) * (game_data.levels_data.sw * game_data.block_width)

				if -run.vars.scrolling_x > ((game_data.levels_data.w - 1) * game_data.levels_data.sw * game_data.block_width) then
					run.vars.scrolling_x = -((game_data.levels_data.w - 1) * game_data.levels_data.sw * game_data.block_width)
				end			
			elseif game_data.vars.scrolling_horizontally == false and game_data.vars.scrolling_vertically == true then
				run.vars.scrolling_y = -math.floor(run.vars.level_actors[1].y / (game_data.levels_data.sh * game_data.block_height)) * (game_data.levels_data.sh * game_data.block_height)

				if -run.vars.scrolling_y > ((game_data.levels_data.h - 1) * game_data.levels_data.sh * game_data.block_height) then
					run.vars.scrolling_y = -((game_data.levels_data.h - 1) * game_data.levels_data.sh * game_data.block_height)
				end
			elseif game_data.vars.scrolling_horizontally == true and game_data.vars.scrolling_vertically == true then
				run.vars.scrolling_x = -math.floor(run.vars.level_actors[1].x / (game_data.levels_data.sw * game_data.block_width)) * (game_data.levels_data.sw * game_data.block_width)

				if -run.vars.scrolling_x > ((game_data.levels_data.w - 1) * game_data.levels_data.sw * game_data.block_width) then
					run.vars.scrolling_x = -((game_data.levels_data.w - 1) * game_data.levels_data.sw * game_data.block_width)
				end
				
				run.vars.scrolling_y = -math.floor(run.vars.level_actors[1].y / (game_data.levels_data.sh * game_data.block_height)) * (game_data.levels_data.sh * game_data.block_height)

				if -run.vars.scrolling_y > ((game_data.levels_data.h - 1) * game_data.levels_data.sh * game_data.block_height) then
					run.vars.scrolling_y = -((game_data.levels_data.h - 1) * game_data.levels_data.sh * game_data.block_height)
				end
			end
		end
		
		-- check for player collision with death blocks
		-- TODO!

		-- check for player collision with eatable blocks
		-- TODO!
		
		-- move enemies
		for i = 2, #run.vars.level_actors do
			local actor_number = run.vars.level_actors[i].number
				
			if game_data.actors[actor_number].entity == ENTITY_TYPE_ENEMY then
				if game_speed_tick == true then
					-- get enemy position
					local old_x = run.vars.level_actors[i].x
					local old_y = run.vars.level_actors[i].y
					local new_x = old_x
					local new_y = old_y

					-- move left to right
					if game_data.actors[actor_number].type.name == "moving left-right" then
						if run.vars.enemy_move_timer < 0.5 then
							if run.vars.invincible == false then
								if run.vars.level_actors[i].animation ~= GetActorAnimationNumber(actor_number, "idle") then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "idle")
									run.vars.level_actors[i].frame = 1
								end
							elseif run.vars.invincible == true then
								if run.vars.level_actors[i].dir == 180 then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "affraid_left")
								elseif run.vars.level_actors[i].dir == 0 then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "affraid_right")
								end
								
								run.vars.level_actors[i].frame = 1
							end
							
							moving = false
						elseif run.vars.enemy_move_timer >= 0.5 and run.vars.enemy_move_timer < 1.0 then
							if run.vars.invincible == false then
								if run.vars.level_actors[i].animation ~= GetActorAnimationNumber(actor_number, "walk_left") then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "walk_left")
									run.vars.level_actors[i].frame = 1
								end
							elseif run.vars.invincible == true then
								if run.vars.level_actors[i].animation ~= GetActorAnimationNumber(actor_number, "affraid_left") then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "affraid_left")
									run.vars.level_actors[i].frame = 1
								end
							end

							new_x = new_x - 1
							requested_dir = 180
							moving = true
						elseif run.vars.enemy_move_timer >= 1.0 and run.vars.enemy_move_timer < 1.5 then
							if run.vars.invincible == false then
								if run.vars.level_actors[i].animation ~= GetActorAnimationNumber(actor_number, "idle") then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "idle")
									run.vars.level_actors[i].frame = 1
								end
							elseif run.vars.invincible == true then
								if run.vars.level_actors[i].dir == 180 then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "affraid_left")
								else
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "affraid_right")
								end
								
								run.vars.level_actors[i].frame = 1
							end
							
							moving = false
						elseif run.vars.enemy_move_timer >= 1.5 then
							if run.vars.invincible == false then
								if run.vars.level_actors[i].animation ~= GetActorAnimationNumber(actor_number, "walk_right") then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "walk_right")
									run.vars.level_actors[i].frame = 1
								end
							elseif run.vars.invincible == true then
								if run.vars.level_actors[i].animation ~= GetActorAnimationNumber(actor_number, "affraid_right") then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "affraid_right")
									run.vars.level_actors[i].frame = 1
								end
							end
							
							new_x = new_x + 1
							requested_dir = 0
							moving = true
						end
					elseif game_data.actors[actor_number].type.name == "moving up-down" then
						if run.vars.enemy_move_timer < 0.5 then
							if run.vars.invincible == false then
								if run.vars.level_actors[i].animation ~= GetActorAnimationNumber(actor_number, "idle") then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "idle")
									run.vars.level_actors[i].frame = 1
								end
							elseif run.vars.invincible == true then
								if run.vars.level_actors[i].dir == 270 then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "affraid_up")
								elseif run.vars.level_actors[i].dir == 90 then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "affraid_down")
								end
								
								run.vars.level_actors[i].frame = 1
							end
							
							moving = false
						elseif run.vars.enemy_move_timer >= 0.5 and run.vars.enemy_move_timer < 1.0 then
							if run.vars.invincible == false then
								if run.vars.level_actors[i].animation ~= GetActorAnimationNumber(actor_number, "walk_down") then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "walk_down")
									run.vars.level_actors[i].frame = 1
								end
							elseif run.vars.invincible == true then
								if run.vars.level_actors[i].animation ~= GetActorAnimationNumber(actor_number, "affraid_down") then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "affraid_down")
									run.vars.level_actors[i].frame = 1
								end
							end

							new_y = new_y + 1
							requested_dir = 90
							moving = true
						elseif run.vars.enemy_move_timer >= 1.0 and run.vars.enemy_move_timer < 1.5 then
							if run.vars.invincible == false then
								if run.vars.level_actors[i].animation ~= GetActorAnimationNumber(actor_number, "idle") then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "idle")
									run.vars.level_actors[i].frame = 1
								end
							elseif run.vars.invincible == true then
								if run.vars.level_actors[i].dir == 270 then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "affraid_up")
								elseif run.vars.level_actors[i].dir == 90 then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "affraid_down")
								end
								
								run.vars.level_actors[i].frame = 1
							end
							
							moving = false
						elseif run.vars.enemy_move_timer >= 1.5 then
							if run.vars.invincible == false then
								if run.vars.level_actors[i].animation ~= GetActorAnimationNumber(actor_number, "walk_up") then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "walk_up")
									run.vars.level_actors[i].frame = 1
								end
							elseif run.vars.invincible == true then
								if run.vars.level_actors[i].animation ~= GetActorAnimationNumber(actor_number, "affraid_up") then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "affraid_up")
									run.vars.level_actors[i].frame = 1
								end
							end
							
							new_y = new_y - 1
							requested_dir = 270
							moving = true
						end
					elseif game_data.actors[actor_number].type.name == "sniper" then
						
					elseif game_data.actors[actor_number].type.name == "oscillate left-right" then

					elseif game_data.actors[actor_number].type.name == "oscillate up_down" then

					elseif game_data.actors[actor_number].type.name == "turn" then
						-- get turn angle
						requested_dir = math.floor(math.floor((run.vars.enemy_move_timer * 180) / 45) * 45)
						
						new_x = new_x + math.cos(math.rad(requested_dir))
						new_y = new_y + math.sin(math.rad(requested_dir))
						
						moving = false
						
						if new_x ~= old_x or new_y ~= old_y then
							moving = true
						end
						
						-- set animation to walk
						if run.vars.invincible == false then
							if run.vars.level_actors[i].animation ~= GetActorAnimationNumber(actor_number, "walk") then
								run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "walk")
								run.vars.level_actors[i].frame = 1
							end
						elseif run.vars.invincible == true then
							if run.vars.level_actors[i].animation ~= GetActorAnimationNumber(actor_number, "affraid") then
								run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "affraid")
								run.vars.level_actors[i].frame = 1
							end
						end
					elseif game_data.actors[actor_number].type.name == "seek 4 directions" then
						local xa = run.vars.level_actors[1].x
						local ya = run.vars.level_actors[1].y
						local xe = run.vars.level_actors[i].x
						local ye = run.vars.level_actors[i].y
						
						requested_dir = 0
						
						-- affraid mode
						if run.vars.invincible == true and run.vars.invincibility_duration > 0.0 then
							run.vars.level_actors[i].param = ENEMY_RANDOM_MODE
						end
						
						-- seek
						if run.vars.level_actors[i].param == ENEMY_SEEK_MODE then
							if xe < xa then
								requested_dir = 0
							elseif xe > xa then
								requested_dir = 180
							elseif xe == xa then
								requested_dir = run.vars.level_actors[i].dir
							end
							
							local dist = math.abs(xe - xa)
							
							if math.abs(ye - ya) > dist then
								if ye > ya then
									requested_dir = 270
								elseif ye < ya then
									requested_dir = 90
								else
									requested_dir = run.vars.level_actors[i].dir
								end
							end
							
							-- switch to random mode
							if math.random(1, 100) == 1 then
								run.vars.level_actors[i].param = ENEMY_RANDOM_MODE
							end
						elseif run.vars.level_actors[i].param == ENEMY_RANDOM_MODE then
							requested_dir = run.vars.level_actors[i].dir
							
							-- randomize
							if math.random(1, 50) == 1 then
								requested_dir = math.random(0, 3) * 90
							end

							-- switch to seek mode
							if math.random(1, 100) == 1 then
								run.vars.level_actors[i].param = ENEMY_SEEK_MODE
							end
						end
						
						if requested_dir == 0 then
							new_x = new_x + game_data.vars.player_speed
						elseif requested_dir == 180 then
							new_x = new_x - game_data.vars.player_speed
						elseif requested_dir == 90 then
							new_y = new_y + game_data.vars.player_speed
						elseif requested_dir == 270 then
							new_y = new_y - game_data.vars.player_speed
						end

						moving = true
					elseif game_data.actors[actor_number].type.name == "seek 8 directions" then

					elseif game_data.actors[actor_number].type.name == "random 4 directions" then
						
					elseif game_data.actors[actor_number].type.name == "random 8 directions" then

					end

					-- check for enemies collisions with blocks
					if moving == true then						
						local quantized_dir = math.floor(requested_dir / 45) * 45
						local move_x = 0
						local move_y = 0
						
						if quantized_dir == 0 or quantized_dir == 45 or quantized_dir == 315 then
							move_x = 1
						elseif quantized_dir == 180 or quantized_dir == 135 or quantized_dir == 225 then
							move_x = -1
						end

						if quantized_dir == 90 or quantized_dir == 45 or quantized_dir == 135 then
							move_y = 1
						elseif quantized_dir == 270 or quantized_dir == 225 or quantized_dir == 315 then
							move_y = -1
						end

						-- check if the enemy can move or not on x axis
						if move_x ~= 0 then
							local collision = false
							
							_, collision = SlidingCollisionX(
								new_x,
								old_y,
								game_data.sprite_width,
								game_data.sprite_height,
								quantized_dir,
								game_data.levels[run.vars.level],
								game_data.block_width,
								game_data.block_height
							)
							
							-- if the enemy collide, he do not move on x
							if collision == true then
								new_x = old_x
								
								-- collides ? get old dir
								requested_dir = run.vars.level_actors[i].dir

								-- change behaviour on collision
								if run.vars.invincible == false then
									if run.vars.level_actors[i].param == ENEMY_SEEK_MODE then
										run.vars.level_actors[i].param = ENEMY_RANDOM_MODE
									elseif run.vars.level_actors[i].param == ENEMY_RANDOM_MODE then
										run.vars.level_actors[i].param = ENEMY_SEEK_MODE
									end
								else
									requested_dir = (requested_dir + 90) % 360
								end
							end
						end

						-- check if the enemy can move or not on y axis
						if move_y ~= 0 then
							local collision = false
							
							_, collision = SlidingCollisionY(
								old_x,
								new_y,
								game_data.sprite_width,
								game_data.sprite_height,
								quantized_dir,
								game_data.levels[run.vars.level],
								game_data.block_width,
								game_data.block_height
							)
							
							-- if the enemy collide, he do not move on y
							if collision == true then
								new_y = old_y
								
								-- collides ? get old dir
								requested_dir = run.vars.level_actors[i].dir

								-- change behaviour on collision
								if run.vars.invincible == false then
									if run.vars.level_actors[i].param == ENEMY_SEEK_MODE then
										run.vars.level_actors[i].param = ENEMY_RANDOM_MODE
									elseif run.vars.level_actors[i].param == ENEMY_RANDOM_MODE then
										run.vars.level_actors[i].param = ENEMY_SEEK_MODE
									end
								else
									requested_dir = (requested_dir + 90) % 360
								end
							end
						end

						-- collide with corners
						new_x, new_y = SlidingCollisionZ(
							new_x,
							new_y,
							game_data.sprite_width,
							game_data.sprite_height,
							quantized_dir,
							game_data.levels[run.vars.level],
							game_data.block_width,
							game_data.block_height
						)
						
						-- change enemy coordinates
						run.vars.level_actors[i].x = new_x
						run.vars.level_actors[i].y = new_y
						
						-- change enemy direction
						run.vars.level_actors[i].dir = requested_dir
						
						-- change enemy animation, depending on the type of enemy
						if run.vars.invincible == false then
							if game_data.actors[actor_number].type.name == "seek 4 directions" then
								if run.vars.level_actors[i].dir == 270 then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "walk_up")
								elseif run.vars.level_actors[i].dir == 90 then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "walk_down")
								elseif run.vars.level_actors[i].dir == 180 then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "walk_left")
								elseif run.vars.level_actors[i].dir == 0 then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "walk_right")
								end
							end
						elseif run.vars.invincible == true then
							if game_data.actors[actor_number].type.name == "seek 4 directions" then
								if run.vars.level_actors[i].dir == 270 then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "affraid_up")
								elseif run.vars.level_actors[i].dir == 90 then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "affraid_down")
								elseif run.vars.level_actors[i].dir == 180 then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "affraid_left")
								elseif run.vars.level_actors[i].dir == 0 then
									run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "affraid_right")
								end
							end
						end
					end
				end
		
				-- it is time to animate enemies
				if animations_tick == true then
					-- animation not looping and ended ?
					if AnimateCharacter(i, moving) == true then
						run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "idle")
						run.vars.level_actors[i].frame = 1
					end
				end
			end
		end

		-- check for player collisions with enemies
		-- TODO!
		
		-- animate bonus
		for i = 2, #run.vars.level_actors do
			local actor_number = run.vars.level_actors[i].number
			
			if game_data.actors[actor_number].entity == ENTITY_TYPE_BONUS then
				-- it is time to animate bonus
				if animations_tick == true then
					-- animation not looping and ended ?
					if AnimateCharacter(i, moving) == true then
						run.vars.level_actors[i].animation = GetActorAnimationNumber(actor_number, "idle")
						run.vars.level_actors[i].frame = 1
					end
				end
			end
		end

		-- check for player collisions with bonus
		for i = #run.vars.level_actors, 2, -1 do
			local actor_number = run.vars.level_actors[i].number
			
			if game_data.actors[actor_number].entity == ENTITY_TYPE_BONUS then
				local px = run.vars.level_actors[1].x
				local py = run.vars.level_actors[1].y
				local pw = game_data.sprite_width
				local ph = game_data.sprite_height
				
				local bx = run.vars.level_actors[i].x
				local by = run.vars.level_actors[i].y
				local bw = game_data.sprite_width
				local bh = game_data.sprite_height

				local div = game_data.actors[actor_number].type.collision_box

				bx = bx + math.floor((bw - (bw / div)) / 2)
				by = by + math.floor((bh - (bh / div)) / 2)

				bw = bw / div
				bh = bh / div
				
				if Collision(px, py, pw, ph, bx, by, bw, bh) == true then
					-- add points, lives or health
					if game_data.actors[actor_number].type.name == "points" then
						-- add points to the score
						run.vars.score = run.vars.score + game_data.actors[actor_number].type.bonus
						
						-- play bonus sound here
						-- TODO!
					elseif game_data.actors[actor_number].type.name == "life" then
						-- add lives
						run.vars.lives = run.vars.lives + game_data.actors[actor_number].type.bonus
						
						-- limit to 99 lives
						if run.vars.lives > 99 then run.vars.lives = 99 end
						
						-- play bonus sound here
						-- TODO!
					elseif game_data.actors[actor_number].type.name == "health" then
						-- add health, if there is a health bar
						run.vars.health = run.vars.health + game_data.actors[actor_number].type.bonus
						
						-- limit to 100% health
						if run.vars.health > 100 then run.vars.health = 100 end
						
						-- play bonus sound here
						-- TODO!
					elseif game_data.actors[actor_number].type.name == "invincible" then
						-- start invincibility
						run.vars.invincible = true
						run.vars.invincibility_duration = game_data.actors[actor_number].type.duration
						
						-- set enemies to affraid
						for j = 2, #run.vars.level_actors do
							local actor_number = run.vars.level_actors[j].number

							if game_data.actors[actor_number].entity == ENTITY_TYPE_ENEMY then
								if game_data.actors[actor_number].type.name == "static" then
									run.vars.level_actors[j].animation = GetActorAnimationNumber(actor_number, "affraid")
								elseif game_data.actors[actor_number].type.name == "moving left-right" then
									if run.vars.level_actors[i].dir == 180 then
										run.vars.level_actors[j].animation = GetActorAnimationNumber(actor_number, "affraid_left")
									elseif run.vars.level_actors[i].dir == 0 then
										run.vars.level_actors[j].animation = GetActorAnimationNumber(actor_number, "affraid_right")
									end
								elseif game_data.actors[actor_number].type.name == "moving up-down" then
									if run.vars.level_actors[i].dir == 270 then
										run.vars.level_actors[j].animation = GetActorAnimationNumber(actor_number, "affraid_up")
									elseif run.vars.level_actors[i].dir == 90 then
										run.vars.level_actors[j].animation = GetActorAnimationNumber(actor_number, "affraid_down")
									end
								elseif game_data.actors[actor_number].type.name == "sniper" then
									run.vars.level_actors[j].animation = GetActorAnimationNumber(actor_number, "affraid")
								elseif game_data.actors[actor_number].type.name == "oscillate left-right" then
									run.vars.level_actors[j].animation = GetActorAnimationNumber(actor_number, "affraid")
								elseif game_data.actors[actor_number].type.name == "oscillate up-down" then
									run.vars.level_actors[j].animation = GetActorAnimationNumber(actor_number, "affraid")
								elseif game_data.actors[actor_number].type.name == "turn" then
									run.vars.level_actors[j].animation = GetActorAnimationNumber(actor_number, "affraid")
								elseif game_data.actors[actor_number].type.name == "seek 4 directions" then
									if run.vars.level_actors[i].dir == 270 then
										run.vars.level_actors[j].animation = GetActorAnimationNumber(actor_number, "affraid_up")
									elseif run.vars.level_actors[i].dir == 90 then
										run.vars.level_actors[j].animation = GetActorAnimationNumber(actor_number, "affraid_down")
									elseif run.vars.level_actors[i].dir == 180 then
										run.vars.level_actors[j].animation = GetActorAnimationNumber(actor_number, "affraid_left")
									elseif run.vars.level_actors[i].dir == 0 then
										run.vars.level_actors[j].animation = GetActorAnimationNumber(actor_number, "affraid_right")
									end
								elseif game_data.actors[actor_number].type.name == "seek 8 directions" then
									run.vars.level_actors[j].animation = GetActorAnimationNumber(actor_number, "affraid")
								elseif game_data.actors[actor_number].type.name == "random 4 directions" then
									if run.vars.level_actors[i].dir == 270 then
										run.vars.level_actors[j].animation = GetActorAnimationNumber(actor_number, "affraid_up")
									elseif run.vars.level_actors[i].dir == 90 then
										run.vars.level_actors[j].animation = GetActorAnimationNumber(actor_number, "affraid_down")
									elseif run.vars.level_actors[i].dir == 180 then
										run.vars.level_actors[j].animation = GetActorAnimationNumber(actor_number, "affraid_left")
									elseif run.vars.level_actors[i].dir == 0 then
										run.vars.level_actors[j].animation = GetActorAnimationNumber(actor_number, "affraid_right")
									end
								elseif game_data.actors[actor_number].type.name == "random 8 directions" then
									run.vars.level_actors[j].animation = GetActorAnimationNumber(actor_number, "affraid")
								end
							end
						end

						
						-- play bonus sound here
						-- TODO!
					end

					-- remove the bonus from the level
					table.remove(run.vars.level_actors, i)
				end
			end
		end
		
		-- test victory
		if game_data.vars.game_goal == GOAL_EXIT_RIGHT then
			if run.vars.level_actors[1].x >= (game_data.levels_data.sw * game_data.levels_data.w * game_data.block_width) - game_data.sprite_width then
				GotoNextLevel()
			end
		elseif game_data.vars.game_goal == GOAL_KILL_ALL_ENEMIES then
			local flag = false
			
			for i = 2, #run.vars.level_actors do
				local actor_number = run.vars.level_actors[i].number
					
				if game_data.actors[actor_number].entity == ENTITY_TYPE_ENEMY then
					flag = true
				end
			end
			
			if flag == false then
				GotoNextLevel()
			end
		elseif game_data.vars.game_goal == GOAL_KILL_ALL_ENEMIES_EXIT_RIGHT then
			if run.vars.level_actors[1].x >= (game_data.levels_data.sw * game_data.levels_data.w * game_data.block_width) - game_data.sprite_width then
				local flag = false
				
				for i = 2, #run.vars.level_actors do
					local actor_number = run.vars.level_actors[i].number
						
					if game_data.actors[actor_number].entity == ENTITY_TYPE_ENEMY then
						flag = true
					end
				end
					
				if flag == false then
					GotoNextLevel()
				end
			end
		elseif game_data.vars.game_goal == GOAL_TAKE_ALL_BONUS then
			local flag = false
			
			for i = 2, #run.vars.level_actors do
				local actor_number = run.vars.level_actors[i].number
					
				if game_data.actors[actor_number].entity == ENTITY_TYPE_BONUS then
					flag = true
				end
			end
				
			if flag == false then
				GotoNextLevel()
			end
		elseif game_data.vars.game_goal == GOAL_TAKE_KEY_AND_EXIT then
			-- TODO!
		end
	elseif run.vars.game_mode == MODE_WINNER then
		-- stop all musics and start winner music, if needed
		if run.vars.musics.winner ~= nil then
			if run.vars.musics.intro:isPlaying() then
				run.vars.musics.intro:stop()
			end
		end

		if run.vars.musics.in_game ~= nil then
			if run.vars.musics.in_game:isPlaying() then
				run.vars.musics.in_game:stop()
			end
		end
		
		if run.vars.musics.winner ~= nil then
			if not run.vars.musics.winner:isPlaying() then
				run.vars.musics.winner:play()
				run.vars.musics.winner:setLooping(true)
			end
		end

		if run.vars.musics.game_over ~= nil then
			if run.vars.musics.game_over:isPlaying() then
				run.vars.musics.game_over:stop()
			end
		end	
	end
end

function run.draw()
	-- adapt resolution to window (or fullscreen)
	local sx = love.graphics.getWidth() / (WINDOW_WIDTH + (WINDOW_BORDER * 2))
	local sy = love.graphics.getHeight() / (WINDOW_HEIGHT + (WINDOW_BORDER * 2))
	
	love.graphics.scale(sx, sy)
	
	-- show what should be shown
	if run.vars.game_mode == MODE_INTRO then
		-- disable scissor
		love.graphics.setScissor()

		-- clear the background with game paper
		r, g, b = GetPenRGB(game_data.game_paper)
		love.graphics.clear(r, g, b)
		
		-- show intro image if it exists else show game title
		if run.vars.images.intro ~= nil and run.vars.images.intro ~= "" then
			-- show intro image
			love.graphics.setColor(1, 1, 1)
			love.graphics.draw(run.vars.images.intro, WINDOW_BORDER, WINDOW_BORDER, 0, game_data.pixel_size * WINDOW_ZOOM, WINDOW_ZOOM)
		else
			-- show game title
			local virtual_width = WINDOW_WIDTH + (WINDOW_BORDER * 2)
			local virtual_height = WINDOW_HEIGHT + (WINDOW_BORDER * 2)
			
			love.graphics.setFont(GAME_TITLE_FONT)
			r, g, b = GetPenRGB(1)
			love.graphics.setColor(r, g, b)
			
			local scale = 1.0 / 16

			love.graphics.printf(game_data.game_name, 0, virtual_height / 4, virtual_width / scale, "center", 0, scale, scale)

			love.graphics.setFont(GAME_FONT)
			scale = 1.0 / 32
			love.graphics.printf("Keys: [Arrows][Space][x][c][v]", 0, virtual_height * 48 / 100, virtual_width / scale, "center", 0, scale, scale)
			love.graphics.printf("or Joystick/Gamepad", 0, virtual_height * 52 / 100, virtual_width / scale, "center", 0, scale, scale)

			-- show press start to play
			if run.vars.blink_timer < 0.5 then
				love.graphics.printf("PRESS START TO PLAY", 0, virtual_height * 80 / 100, virtual_width / scale, "center", 0, scale, scale)
			end
		end
	elseif run.vars.game_mode == MODE_IN_GAME then
		-- ===========================================================================================================================================================================

		-- disable scissor
		love.graphics.setScissor()

		-- clear with border color
		r, g, b = GetPenRGB(game_data.border_paper)
		love.graphics.clear(r, g, b)

		-- ===========================================================================================================================================================================
		
		-- set scissor without the border
		love.graphics.setScissor(WINDOW_BORDER * sx, WINDOW_BORDER * sy, WINDOW_WIDTH * sx, WINDOW_HEIGHT * sy)

		-- clear the background with background paper color
		r, g, b = GetPenRGB(game_data.background_paper)
		love.graphics.clear(r, g, b)

		-- draw game area
		r, g, b = GetPenRGB(game_data.game_paper)
		love.graphics.setColor(r, g, b)
		love.graphics.rectangle("fill", ScaleX(game_data.areas[GAME_AREA].x, WINDOW_ZOOM), ScaleY(game_data.areas[GAME_AREA].y, WINDOW_ZOOM), ScaleWidth(game_data.areas[GAME_AREA].width, WINDOW_ZOOM), ScaleHeight(game_data.areas[GAME_AREA].height, WINDOW_ZOOM))

		-- ===========================================================================================================================================================================

		-- set scissor to game area
		love.graphics.setScissor(ScaleX(game_data.areas[GAME_AREA].x, WINDOW_ZOOM) * sx, ScaleY(game_data.areas[GAME_AREA].y, WINDOW_ZOOM) * sy, ScaleWidth(game_data.areas[GAME_AREA].width, WINDOW_ZOOM) * sx, ScaleHeight(game_data.areas[GAME_AREA].height, WINDOW_ZOOM) * sy)

		-- draw the game
		DrawGame()

		-- ===========================================================================================================================================================================
		
		-- disable scissor
		love.graphics.setScissor()

		-- draw score area
		
		FontsPrint("SCORE " .. ToString2(run.vars.score, 7), ScaleX(game_data.areas[SCORE_AREA].x, WINDOW_ZOOM), ScaleY(game_data.areas[SCORE_AREA].y, WINDOW_ZOOM), game_data.areas[SCORE_AREA].width * game_data.pixel_size * WINDOW_ZOOM, game_data.areas[SCORE_AREA].height * WINDOW_ZOOM, GAME_FONT, FONT_DOWN_SCALE / WINDOW_ZOOM, game_data.text_paper, game_data.text_pen)

		-- draw lives area
		FontsPrint("LIVES " .. ToString2(game_data.vars.lives, 2), ScaleX(game_data.areas[LIVES_AREA].x, WINDOW_ZOOM), ScaleY(game_data.areas[LIVES_AREA].y, WINDOW_ZOOM), game_data.areas[LIVES_AREA].width * game_data.pixel_size * WINDOW_ZOOM, game_data.areas[LIVES_AREA].height * WINDOW_ZOOM, GAME_FONT, FONT_DOWN_SCALE / WINDOW_ZOOM, game_data.text_paper, game_data.text_pen)

		-- draw level area
		FontsPrint("LEVEL " .. ToString2(run.vars.level, 3), ScaleX(game_data.areas[LEVEL_AREA].x, WINDOW_ZOOM), ScaleY(game_data.areas[LEVEL_AREA].y, WINDOW_ZOOM), game_data.areas[LEVEL_AREA].width * game_data.pixel_size * WINDOW_ZOOM, game_data.areas[LEVEL_AREA].height * WINDOW_ZOOM, GAME_FONT, FONT_DOWN_SCALE / WINDOW_ZOOM, game_data.text_paper, game_data.text_pen)
	
		-- draw health bar
		if game_data.health_area == true then
			r, g, b = GetPenRGB(game_data.health_paper)
			love.graphics.setColor(r, g, b)

			love.graphics.rectangle("fill", ScaleX(game_data.areas[HEALTH_AREA].x, WINDOW_ZOOM), ScaleY(game_data.areas[HEALTH_AREA].y, WINDOW_ZOOM), ScaleWidth(game_data.areas[HEALTH_AREA].width, WINDOW_ZOOM), ScaleHeight(game_data.areas[HEALTH_AREA].height, WINDOW_ZOOM))

			r, g, b = GetPenRGB(game_data.health_pen)
			love.graphics.setColor(r, g, b)

			local health = game_data.areas[HEALTH_AREA].width * run.vars.health / 100
			
			if health >= 0 then
				love.graphics.rectangle("fill", ScaleX(game_data.areas[HEALTH_AREA].x, WINDOW_ZOOM), ScaleY(game_data.areas[HEALTH_AREA].y, WINDOW_ZOOM), ScaleWidth(health, WINDOW_ZOOM), ScaleHeight(game_data.areas[HEALTH_AREA].height, WINDOW_ZOOM))
			end
		end
	end
end

-- keyboard buttons
function run.keypressed(key, scancode, isrepeat)
	if run.vars.game_mode == MODE_INTRO then
		-- space to enter the game
		if key == "space" then
			run.vars.game_mode = MODE_IN_GAME
		end
	elseif run.vars.game_mode == MODE_IN_GAME then
		-- fire with keyboard
		if key == "x" then
			local actor_number = run.vars.level_actors[1].number
			
			-- fire 1: "a"
			Fire1(actor_number)
		elseif key == "c" then
			local actor_number = run.vars.level_actors[1].number
			
			-- fire 2: "b"
			Fire2(actor_number)
		end
	end
end

-- gamepad buttons
function run.gamepadpressed(joystick, button)
	if run.vars.game_mode == MODE_INTRO then
		if joy == joystick then
			-- start to enter the game
			if button == "start" then
				run.vars.game_mode = MODE_IN_GAME
			end
		end
	elseif run.vars.game_mode == MODE_IN_GAME then
		if joy == joystick then
			-- fire with keyboard
			if button == "a" then
				local actor_number = run.vars.level_actors[1].number
			
				-- fire 1: "a"
				Fire1(actor_number)
			elseif button == "b" then
				local actor_number = run.vars.level_actors[1].number
			
				-- fire 2: "b"
				Fire2(actor_number)
			end
		end
	end
end

function run.quit()
	for i = 1, #music_types do
		if run.vars.musics[music_types[i]] ~= nil then
			run.vars.musics[music_types[i]]:stop()
		end
	end
end

-- fire 1 button (TODO! add other kinds of players)
function Fire1(a)
	if game_data.actors[a].type.name == "platformer" then
		-- the player is on the ground ?
		if run.vars.on_the_ground == true or run.vars.on_stairs == true then
			-- the player is idle or walking or climbing ?
			if run.vars.level_actors[1].animation == GetActorAnimationNumber(a, "idle") or
										run.vars.level_actors[1].animation == GetActorAnimationNumber(a, "walk") then
				-- jump
				run.vars.level_actors[1].animation = GetActorAnimationNumber(a, "jump")
				run.vars.level_actors[1].frame = 1
				run.vars.jump_power = -game_data.vars.jump_power
				
				-- play jump sound
				-- TODO!
			end
		end
	end
end

-- fire 2 button (TODO! add other kinds of players)
function Fire2(a)
	if game_data.actors[a].type.name == "platformer" then
		-- the player is on the ground ?
		if run.vars.on_the_ground == true then
			-- the player is idle or walking ?
			if run.vars.level_actors[1].animation == GetActorAnimationNumber(a, "idle") or
										run.vars.level_actors[1].animation == GetActorAnimationNumber(a, "walk") then
				-- hit
				run.vars.level_actors[1].animation = GetActorAnimationNumber(a, "hit")
				run.vars.level_actors[1].frame = 1
				
				-- play hit sound
				-- TODO!
			end
		end
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
	
		-- draw bonus first
		for i = 2, #run.vars.level_actors do
			local actor_number = run.vars.level_actors[i].number
			
			if game_data.actors[actor_number].entity == ENTITY_TYPE_BONUS then
				DrawActors(i, actor_number, px, py)
			end
		end

		-- draw enemies
		for i = 2, #run.vars.level_actors do
			local actor_number = run.vars.level_actors[i].number
			
			if game_data.actors[actor_number].entity == ENTITY_TYPE_ENEMY then
				DrawActors(i, actor_number, px, py)
			end
		end

		-- draw player last
		local actor_number = run.vars.level_actors[1].number
			
		DrawActors(1, actor_number, px, py)
	end
end

function DrawActors(i, actor_number, px, py)
	local animation = run.vars.level_actors[i].animation
	local frame = run.vars.level_actors[i].frame
	
	if animation > 0 and frame > 0 then
		local sprite = game_data.animations[animation][frame]
		local xc = ScaleWidth(run.vars.level_actors[i].x, WINDOW_ZOOM)
		local yc = ScaleHeight(run.vars.level_actors[i].y, WINDOW_ZOOM)

		-- scrolling
		xc = xc + ScaleWidth(run.vars.scrolling_x, WINDOW_ZOOM)
		yc = yc + ScaleHeight(run.vars.scrolling_y, WINDOW_ZOOM)

		-- flipped ?
		local hflip = 1
		local vflip = 1
		
		if run.vars.level_actors[i].hflip == true then hflip = -1 end
		if run.vars.level_actors[i].vflip == true then vflip = -1 end

		local flip_offset_x = 0
		local flip_offset_y = 0
		
		-- what kind of player ? (TODO!)
		if game_data.actors[actor_number].type.name == "platformer" then
			if hflip == -1 then flip_offset_x = ScaleWidth(game_data.sprite_width, WINDOW_ZOOM) end
			
			love.graphics.draw(img_sprites[sprite], px + xc + flip_offset_x, py + yc, 0, game_data.pixel_size * WINDOW_ZOOM * hflip, WINDOW_ZOOM)
		elseif game_data.actors[actor_number].type.name == "run & gun (top view)" then
			flip_offset_x = ScaleWidth(game_data.sprite_width, WINDOW_ZOOM) / 2
			flip_offset_y = ScaleHeight(game_data.sprite_height, WINDOW_ZOOM) / 2
			
			love.graphics.draw(img_sprites[sprite], px + xc + flip_offset_x, py + yc + flip_offset_y, math.rad(run.vars.dir), game_data.pixel_size * WINDOW_ZOOM, WINDOW_ZOOM, game_data.sprite_width / 2, game_data.sprite_height / 2)
		elseif game_data.actors[actor_number].type.name == "maze & chase" then
			flip_offset_x = ScaleWidth(game_data.sprite_width, WINDOW_ZOOM) / 2
			flip_offset_y = ScaleHeight(game_data.sprite_height, WINDOW_ZOOM) / 2
			
			love.graphics.draw(img_sprites[sprite], px + xc + flip_offset_x, py + yc + flip_offset_y, math.rad(run.vars.dir), game_data.pixel_size * WINDOW_ZOOM, WINDOW_ZOOM, game_data.sprite_width / 2, game_data.sprite_height / 2)
		else
			--draw monsters and bonus
			love.graphics.draw(img_sprites[sprite], px + xc, py + yc, 0, game_data.pixel_size * WINDOW_ZOOM, WINDOW_ZOOM)
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
function GroundCollision(x1, y1, w1, h1, map, w2, h2, on_stairs, moving_down)
	-- offset with hotspot
	local actor_number = run.vars.level_actors[1].number
	
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
		
		if BlockCollision(x, y, map) == true or PlatformCollision(x, y, map) == true or (StairsCollision(x, y, map) == true and on_stairs == false and moving_down == false) then
			y1 = (y * h2) - h1

			return y1, true
		end
	end
	
	return y1, false
end

-- checking if the player collision with the ceiling
function CeilingCollision(x1, y1, w1, h1, map, w2, h2)
	-- offset with hotspot
	local actor_number = run.vars.level_actors[1].number
	
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
	local actor_number = run.vars.level_actors[1].number
	
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
	local actor_number = run.vars.level_actors[1].number
	
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
	local actor_number = run.vars.level_actors[1].number
	
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
	local actor_number = run.vars.level_actors[1].number
	
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
	local actor_number = run.vars.level_actors[1].number
	
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
					
				return x1, true
			end
		end
	elseif d1 == 180 or d1 == 135 or d1 == 225 then
		-- left
		for y = y3, y3 + h3 - 1 do
			x = x3
			
			if BlockCollision(x, y, map) == true then
				x1 = ((x + 1) * w2)
					
				return x1, true
			end
		end
	end
	
	return x1, false
end

-- sliding collision between player's sprite and max 6 blocks inside the player
function SlidingCollisionY(x1, y1, w1, h1, d1, map, w2, h2)
	-- offset with hotspot
	local actor_number = run.vars.level_actors[1].number
	
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
				
				return y1, true
			end
		end
	elseif d1 == 270 or d1 == 225 or d1 == 315 then
		-- up
		for x = x3, x3 + w3 - 1 do
			y = y3
			
			if BlockCollision(x, y, map) == true then
				y1 = ((y + 1) * h2)
					
				return y1, true
			end
		end
	end
	
	return y1, false
end

-- sliding collision between player's sprite and corners
function SlidingCollisionZ(x1, y1, w1, h1, d1, map, w2, h2)
	-- offset with hotspot
	local actor_number = run.vars.level_actors[1].number
	
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

-- animate characters, return true if animation just ended
function AnimateCharacter(i, moving)
	local actor_number = run.vars.level_actors[i].number
	local animation = run.vars.level_actors[i].animation
	
	-- animation not configured ? exit
	if animation == 0 then return false end
	
	local loop = game_data.animations_loop[animation].loop
	local v1  = game_data.animations_loop[animation].v1
	local v2  = game_data.animations_loop[animation].v2
	
	-- animation just ended
	if loop == false then
		if run.vars.level_actors[i].frame < #game_data.animations[animation] then
			run.vars.level_actors[i].frame = run.vars.level_actors[i].frame + 1
		elseif run.vars.level_actors[i].frame == #game_data.animations[animation] then
			return true
		end
	elseif loop == true then
		-- loop animation if it is idle or another animation but with a movement
		if animation == GetActorAnimationNumber(actor_number, "idle") or moving == true then
			if run.vars.level_actors[i].frame < v2 then
				run.vars.level_actors[i].frame = run.vars.level_actors[i].frame + 1
			elseif run.vars.level_actors[i].frame == v2 then
				run.vars.level_actors[i].frame = v1
			end
		end
	end
	
	return false
end

-- common initialization
function CommonInit()
	run.vars.dir = 0
	run.vars.dir_x = 1
	run.vars.dir_y = 0
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
	
	-- invincibility is false at beginning
	run.vars.invincible = false
	run.vars.invincibility_duration = 0
	
	-- enemy timer for movements and animations
	run.vars.enemy_move_timer = 0.0
	
	-- reset actors positions and animations
	for i = 1, #game_data.levels do
		for j = 1, #game_data.levels[i].actors do
			game_data.levels[i].actors[j].x = game_data.levels[i].actors[j].start_x
			game_data.levels[i].actors[j].y = game_data.levels[i].actors[j].start_y
			game_data.levels[i].actors[j].animation = GetActorAnimationNumber(game_data.levels[i].actors[j].number, "idle")
			game_data.levels[i].actors[j].frame = 1
		end
	end
	
	-- create a copy of the current level
	run.vars.level_actors = DeepCopy(game_data.levels[run.vars.level].actors)
end

-- go to next level, if possible
function GotoNextLevel()
	-- initialize player's data
	run.vars.health = 100
	
	-- go to next level
	run.vars.level = run.vars.level + 1

	-- win the game ?
	if run.vars.level > #game_data.levels then
		run.vars.game_mode = MODE_WINNER
		
		return
	end
	
	-- initialize all
	CommonInit()
end

return run


local run = {}


-- run arrays
run.vars = {
	score = 0,
	level = 0,
	scrolling_x = 0,
	scrolling_y = 0,
	animation_timer = 0.0
}

-- run vars
tick = false

-- run functions
function run.load()
	-- initialize player's data
	run.vars.score = 0
	run.vars.level = 1
	
	run.vars.scrolling_x = game_data.scrolling_start_x[run.vars.level]
	run.vars.scrolling_y = game_data.scrolling_start_y[run.vars.level]
	
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
	run.vars.animation_timer = run.vars.animation_timer + dt
	tick = false
	
	if run.vars.animation_timer >= game_data.vars.game_speed then
		run.vars.animation_timer = 0.0
		tick = true
	end
	
	if tick == true then
		-- animate characters
		if #game_data.levels > 0 then
			for i = 1, #game_data.levels[run.vars.level].actors do
				if game_data.levels[run.vars.level].actors[i].frame < #game_data.animations[game_data.levels[run.vars.level].actors[i].animation] then
					game_data.levels[run.vars.level].actors[i].frame = game_data.levels[run.vars.level].actors[i].frame + 1
				elseif game_data.levels[run.vars.level].actors[i].frame == #game_data.animations[game_data.levels[run.vars.level].actors[i].animation] then
					game_data.levels[run.vars.level].actors[i].frame = 1
				end
			end
		end
	end
	
	-- move the player
	if game_data.actors[1].type.name == "platformer" then
		if love.keyboard.isDown("left") then
			game_data.levels[run.vars.level].actors[1].x = game_data.levels[run.vars.level].actors[1].x - 1
		elseif love.keyboard.isDown("right") then
			game_data.levels[run.vars.level].actors[1].x = game_data.levels[run.vars.level].actors[1].x + 1
		end
	end

	--local instance_number = game_data.levels[run.vars.level].actors[1].number
	
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
		if tick == true then
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
			local animation = game_data.levels[run.vars.level].actors[i].animation
			local frame = game_data.levels[run.vars.level].actors[i].frame
			
			if animation > 0 and frame > 0 then
				local sprite = game_data.animations[animation][frame]
				local xc = ScaleWidth(game_data.levels[run.vars.level].actors[i].x, WINDOW_ZOOM)
				local yc = ScaleHeight(game_data.levels[run.vars.level].actors[i].y, WINDOW_ZOOM)

				-- scrolling
				xc = xc + ScaleWidth(run.vars.scrolling_x, WINDOW_ZOOM)
				yc = yc + ScaleHeight(run.vars.scrolling_y, WINDOW_ZOOM)

				love.graphics.draw(img_sprites[sprite], px + xc, py + yc, 0, game_data.pixel_size * WINDOW_ZOOM, WINDOW_ZOOM)
			end
		end
	end
end

return run

local run = {}


-- run constants
local RUN_MAX_ANIMATION_SPEED = 0.25

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
	
	if run.vars.animation_timer >= RUN_MAX_ANIMATION_SPEED then
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
	FontsPrint("SCORE 0000000", ScaleX(game_data.areas[SCORE_AREA].x, WINDOW_ZOOM), ScaleY(game_data.areas[SCORE_AREA].y, WINDOW_ZOOM), game_data.areas[SCORE_AREA].width * WINDOW_ZOOM, game_data.areas[SCORE_AREA].height * WINDOW_ZOOM, GAME_FONT, FONT_DOWN_SCALE / WINDOW_ZOOM, game_data.text_paper, game_data.text_pen)

	-- draw lives area
	FontsPrint("LIVES 03", ScaleX(game_data.areas[LIVES_AREA].x, WINDOW_ZOOM), ScaleY(game_data.areas[LIVES_AREA].y, WINDOW_ZOOM), game_data.areas[LIVES_AREA].width * WINDOW_ZOOM, game_data.areas[LIVES_AREA].height * WINDOW_ZOOM, GAME_FONT, FONT_DOWN_SCALE / WINDOW_ZOOM, game_data.text_paper, game_data.text_pen)

	-- draw level area
	FontsPrint("LEVEL 1", ScaleX(game_data.areas[LEVEL_AREA].x, WINDOW_ZOOM), ScaleY(game_data.areas[LEVEL_AREA].y, WINDOW_ZOOM), game_data.areas[LEVEL_AREA].width * WINDOW_ZOOM, game_data.areas[LEVEL_AREA].height * WINDOW_ZOOM, GAME_FONT, FONT_DOWN_SCALE / WINDOW_ZOOM, game_data.text_paper, game_data.text_pen)
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
			
				love.graphics.draw(img_sprites[sprite], px + xc, py + yc, 0, game_data.pixel_size * WINDOW_ZOOM, WINDOW_ZOOM)
			end
		end
	end
end

return run

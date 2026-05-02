-- reset vars and arrays for the editor
function ResetAll()
	game_data.blocks = {}
	game_data.blocks_data = {}
	game_data.sprites = {}
	game_data.animations = {}
	game_data.animations_loop = {}
	game_data.actors = {}
	game_data.levels = {}
	game_data.levels_data = {}
	game_data.sounds = {}
	game_data.musics = {}
	game_data.images = {}
	
	img_blocks = {}
	img_sprites = {}
	
	block_copy = {}
	sprite_copy = {}
	frame_copy = {}
	block_data_copy = {}
	
	game_data.background_paper = 1
	game_data.game_paper = 0
	game_data.text_paper = 0
	game_data.text_pen = 1
	game_data.border_paper = 1
	
	pen_color = 1
	selected_color = 0

	maxx = 0
	maxy = 0

	current_block = 0
	current_sprite = 0
	current_animation = 0
	current_frame = 0
	current_actor = 0
	current_entity_type = 0
	current_player_type = 0
	current_enemy_type = 0
	current_bonus_type = 0
	current_property = 0
	current_level = 0
	current_level_mode = 0
	current_level_selected_block = 0
	current_level_selected_actor = 0
	current_level_edited_actor_instance = 0
	current_level_actors_edit_mode = false
	current_level_scroll_x = 0
	current_level_scroll_y = 0
	current_parameter = 0
	current_page = 0

	block_x = 0
	block_y = 0
	sprite_x = 0
	sprite_y = 0
	
	block_too_many_color = false
	sprite_too_many_color = false
end

-- load a preset
function LoadPreset(path)
	-- remove preset data
	preset_data = {}
	
	-- load preset data
	for line in love.filesystem.lines(path) do
		local a1 = {}
		local a2 = {}
		local a3 = {}
	
		a1 = split_string(line, ":")
		a2 = split_string(a1[2], ",")
		
		table.insert(a3, a1[1])
		
		for i = 1, #a2 do
			table.insert(a3, a2[i])
		end
		
		table.insert(preset_data, a3)
	end
	
	-- get editable palette
	local n = PresetValue("EditablePalette")
	
	if n > 0 then
		if preset_data[n][2] == "true" then
			game_data.editable_palette = true
		else
			game_data.editable_palette = false
		end
	else
		print("EditablePalette missing!")
	end
	
	-- get max inks
	local n = PresetValue("MaxInks")
	
	if n > 0 then
		game_data.max_inks = tonumber(preset_data[n][2])
	else
		print("MaxInks missing!")
	end

	-- get full palette
	local n = PresetValue("InksPalette")
	
	if n > 0 then
		-- clear old full palette
		game_data.inks_palette = {}
		
		-- fill new full palette
		for i = 2, #preset_data[n] do
			table.insert(game_data.inks_palette, preset_data[n][i])
		end
	else
		print("InksPalette missing!")
	end

	-- get max palette colors
	local n = PresetValue("MaxPens")
	
	if n > 0 then
		game_data.max_pens = tonumber(preset_data[n][2])
	else
		print("MaxPens missing!")
	end

	-- get default palette
	local n = PresetValue("PensPalette")
	
	if n > 0 then
		-- clear old palette
		game_data.pens_palette = {}
		
		-- fill new palette
		for i = 2, #preset_data[n] do
			table.insert(game_data.pens_palette, tonumber(preset_data[n][i]))
		end
	else
		print("PensPalette missing!")
	end
		
	-- get pixel doubled
	local n = PresetValue("PixelDoubled")
	
	if n > 0 then
		if preset_data[n][2] == "true" then
			game_data.pixel_doubled = true
			game_data.pixel_size = 2
		else
			game_data.pixel_doubled = false
			game_data.pixel_size = 1
		end
	else
		print("PixelDoubled missing!")
	end

	-- get colors by block
	local n = PresetValue("ColorsByBlock")
	
	if n > 0 then
		game_data.colors_by_block = tonumber(preset_data[n][2])
	else
		print("ColorsByBlock missing!")
	end

	-- get colors by sprite
	local n = PresetValue("ColorsBySprite")
	
	if n > 0 then
		game_data.colors_by_sprite = tonumber(preset_data[n][2])
	else
		print("ColorsBySprite missing!")
	end

	-- get block width
	local n = PresetValue("BlockWidth")
	
	if n > 0 then
		game_data.block_width = tonumber(preset_data[n][2])
	else
		print("BlockWidth missing!")
	end

	-- get block height
	local n = PresetValue("BlockHeight")
	
	if n > 0 then
		game_data.block_height = tonumber(preset_data[n][2])
	else
		print("BlockHeight missing!")
	end

	-- get sprite width
	local n = PresetValue("SpriteWidth")
	
	if n > 0 then
		game_data.sprite_width = tonumber(preset_data[n][2])
	else
		print("SpriteWidth missing!")
	end

	-- get sprite height
	local n = PresetValue("SpriteHeight")
	
	if n > 0 then
		game_data.sprite_height = tonumber(preset_data[n][2])
	else
		print("SpriteHeight missing!")
	end

	-- get max blocks
	local n = PresetValue("MaxBlocks")
	
	if n > 0 then
		game_data.max_blocks = tonumber(preset_data[n][2])
	else
		print("MaxBlocks missing!")
	end

	-- get max sprites
	local n = PresetValue("MaxSprites")
	
	if n > 0 then
		game_data.max_sprites = tonumber(preset_data[n][2])
	else
		print("MaxSprites missing!")
	end

	-- get max animations
	local n = PresetValue("MaxAnimations")
	
	if n > 0 then
		game_data.max_animations = tonumber(preset_data[n][2])
	else
		print("MaxAnimations missing!")
	end

	-- get max actors
	local n = PresetValue("MaxActors")
	
	if n > 0 then
		game_data.max_actors = tonumber(preset_data[n][2])
	else
		print("MaxActors missing!")
	end

	-- get max levels
	local n = PresetValue("MaxLevels")
	
	if n > 0 then
		game_data.max_levels = tonumber(preset_data[n][2])
	else
		print("MaxLevels missing!")
	end

	-- get screen width
	local n = PresetValue("ScreenWidth")
	
	if n > 0 then
		game_data.screen_width = tonumber(preset_data[n][2])
	else
		print("ScreenWidth missing!")
	end

	-- get screen height
	local n = PresetValue("ScreenHeight")
	
	if n > 0 then
		game_data.screen_height = tonumber(preset_data[n][2])
	else
		print("ScreenHeight missing!")
	end

	-- get border
	local n = PresetValue("Border")
	
	if n > 0 then
		if preset_data[n][2] == "true" then
			game_data.border = true
		else
			game_data.border = false
		end
	else
		print("Border missing!")
	end

	-- get game area x
	local n = PresetValue("GameAreaX")
	
	if n > 0 then
		table.insert(game_data.areas, {x = tonumber(preset_data[n][2])})
	else
		print("GameAreaX missing!")
	end

	-- get game area y
	local n = PresetValue("GameAreaY")
	
	if n > 0 then
		game_data.areas[GAME_AREA].y = tonumber(preset_data[n][2])
	else
		print("GameAreaY missing!")
	end

	-- get game area width
	local n = PresetValue("GameAreaWidth")
	
	if n > 0 then
		game_data.areas[GAME_AREA].width = tonumber(preset_data[n][2])
	else
		print("GameAreaWidth missing!")
	end

	-- get game area height
	local n = PresetValue("GameAreaHeight")
	
	if n > 0 then
		game_data.areas[GAME_AREA].height = tonumber(preset_data[n][2])
	else
		print("GameAreaHeight missing!")
	end

	-- get score area x
	local n = PresetValue("ScoreAreaX")
	
	if n > 0 then
		table.insert(game_data.areas, {x = tonumber(preset_data[n][2])})
	else
		print("ScoreAreaX missing!")
	end

	-- get score area y
	local n = PresetValue("ScoreAreaY")
	
	if n > 0 then
		game_data.areas[SCORE_AREA].y = tonumber(preset_data[n][2])
	else
		print("ScoreAreaY missing!")
	end

	-- get score area width
	local n = PresetValue("ScoreAreaWidth")
	
	if n > 0 then
		game_data.areas[SCORE_AREA].width = tonumber(preset_data[n][2])
	else
		print("ScoreAreaWidth missing!")
	end

	-- get score area height
	local n = PresetValue("ScoreAreaHeight")
	
	if n > 0 then
		game_data.areas[SCORE_AREA].height = tonumber(preset_data[n][2])
	else
		print("ScoreAreaHeight missing!")
	end

	-- get lives area x
	local n = PresetValue("LivesAreaX")
	
	if n > 0 then
		table.insert(game_data.areas, {x = tonumber(preset_data[n][2])})
	else
		print("LivesAreaX missing!")
	end

	-- get lives area y
	local n = PresetValue("LivesAreaY")
	
	if n > 0 then
		game_data.areas[LIVES_AREA].y = tonumber(preset_data[n][2])
	else
		print("LivesAreaY missing!")
	end

	-- get lives area width
	local n = PresetValue("LivesAreaWidth")
	
	if n > 0 then
		game_data.areas[LIVES_AREA].width = tonumber(preset_data[n][2])
	else
		print("LivesAreaWidth missing!")
	end

	-- get lives area height
	local n = PresetValue("LivesAreaHeight")
	
	if n > 0 then
		game_data.areas[LIVES_AREA].height = tonumber(preset_data[n][2])
	else
		print("LivesAreaHeight missing!")
	end

	-- get level area x
	local n = PresetValue("LevelAreaX")
	
	if n > 0 then
		table.insert(game_data.areas, {x = tonumber(preset_data[n][2])})
	else
		print("LevelAreaX missing!")
	end

	-- get level area y
	local n = PresetValue("LevelAreaY")
	
	if n > 0 then
		game_data.areas[LEVEL_AREA].y = tonumber(preset_data[n][2])
	else
		print("LevelAreaY missing!")
	end

	-- get level area width
	local n = PresetValue("LevelAreaWidth")
	
	if n > 0 then
		game_data.areas[LEVEL_AREA].width = tonumber(preset_data[n][2])
	else
		print("LevelAreaWidth missing!")
	end

	-- get level area height
	local n = PresetValue("LevelAreaHeight")
	
	if n > 0 then
		game_data.areas[LEVEL_AREA].height = tonumber(preset_data[n][2])
	else
		print("LevelAreaHeight missing!")
	end

	-- get fonts
	local n = PresetValue("Fonts")
	
	if n > 0 then
		game_data.fonts = preset_data[n][2]
	else
		print("Fonts missing!")
	end
	
	ResetAll()
end

-- find preset value
function PresetValue(v)
	for i = 1, #preset_data do
		if preset_data[i][1] == v then
			return i
		end
	end
	
	return 0
end

-- change pen's ink
function ChangePensInk(p, incdec)
	if incdec > 0 and game_data.pens_palette[p + 1] < game_data.max_inks - 1 then
		game_data.pens_palette[p + 1] = game_data.pens_palette[p + 1] + incdec
	elseif incdec < 0 and game_data.pens_palette[p + 1] > 0 then
		game_data.pens_palette[p + 1] = game_data.pens_palette[p + 1] + incdec
	end
end

-- show a cursor to draw, or other stuffs
function ShowCursor(x, y, w, h, r, g, b)
	love.graphics.setColor(r, g, b)
	love.graphics.rectangle("line", x + 1, y + 1, w - 2, h - 2)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("line", x, y, w, h)
end

-- return if they are too many colors
function TooManyColorsInBlock(t)
	local col = {}
	local cpt = 0
	
	for x = 0, game_data.block_width - 1 do
		for y = 0, game_data.block_height - 1 do
			local flag = false
			
			for i = 1, #col do
				if col[i] == t[x][y] then
					flag = true
				end
			end
			
			if flag == false then
				table.insert(col, t[x][y])
				cpt = cpt + 1
			end
		end
	end
	
	if cpt <= game_data.colors_by_block then
		return false
	end
	
	return true
end

function TooManyColorsInSprite(t)
	local col = {}
	local cpt = 0
	
	for x = 0, game_data.sprite_width - 1 do
		for y = 0, game_data.sprite_height - 1 do
			local flag = false
			
			for i = 1, #col do
				if col[i] == t[x][y] then
					flag = true
				end
			end
			
			if flag == false then
				table.insert(col, t[x][y])
				cpt = cpt + 1
			end
		end
	end
	
	if cpt <= game_data.colors_by_sprite then
		return false
	end
	
	return true
end

-- fill a block or a sprite
function FloodFill(t, w, h, x, y, newColor, oldColor)
	if x >= 0 and x < w and y >= 0 and y < h and t[x][y] == oldColor and t[x][y] ~= newColor then
		t[x][y] = newColor
		
		FloodFill(t, w, h, x + 1, y, newColor, oldColor)
		FloodFill(t, w, h, x - 1, y, newColor, oldColor)
		FloodFill(t, w, h, x, y + 1, newColor, oldColor)
		FloodFill(t, w, h, x, y - 1, newColor, oldColor)
	end
end

-- count actor's types
function CountAnimationsPairs()
	local counter = 0
	
	for k, v in pairs(game_data.actors[current_actor].type) do
		counter = counter + 1
	end
	
	return counter
end

-- update level_data and delete all level's blocks and sprites!
function UpdateLevelsData()
	game_data.levels_data = {
		w = 1,
		h = 1,
		sw = math.floor(game_data.areas[GAME_AREA].width / game_data.block_width),
		sh = math.floor(game_data.areas[GAME_AREA].height / game_data.block_height)
	}
	
	local cpt_levels = #game_data.levels
	
	game_data.levels = {}

	-- prepare void level
	local t = {
		blocks = {},
		actors = {}
	}
					
	-- fill void level
	for x = 0, (game_data.levels_data.sw * game_data.levels_data.w) - 1 do
		t.blocks[x] = {}
				
		for y = 0, (game_data.levels_data.sh * game_data.levels_data.h) - 1 do
			t.blocks[x][y] = 0
		end
	end
	
	-- add player actor to the level
	table.insert(t.actors, {startx = 0, starty = 0, x = 0, y = 0, animation = 0, frame = 0})
	
	for i = 1, cpt_levels do
		table.insert(game_data.levels, t)
	end
end

-- scroll the screen to show edited actor instance
function GetActorInstanceScrolling()
	current_level_scroll_x = math.floor(game_data.levels[current_level].actors[current_level_edited_actor_instance].start_x / game_data.block_width)
		
	if current_level_scroll_x >= game_data.levels_data.sw * (game_data.levels_data.w - 1) then
		current_level_scroll_x = game_data.levels_data.sw * (game_data.levels_data.w - 1)
	end
		
	current_level_scroll_x = -current_level_scroll_x

	current_level_scroll_y = math.floor(game_data.levels[current_level].actors[current_level_edited_actor_instance].start_y / game_data.block_height)
		
	if current_level_scroll_y >= game_data.levels_data.sh * (game_data.levels_data.h - 1) then
		current_level_scroll_y = game_data.levels_data.sw * (game_data.levels_data.h - 1)
	end

	current_level_scroll_y = -current_level_scroll_y
end

-- get the page list of all game data (parameters)
function GetParametersPage(page)
	local list = {}
	
	local page_start = 1 + ((page - 1) * PARAMETERS_BY_PAGE)
	local page_end = page_start + PARAMETERS_BY_PAGE - 1
	
	for i = 1, #vars_values do
		if i >= page_start and i <= page_end then
			table.insert(list, vars_values[i])
		end
	end
	
	return list
end

-- set default game data (parameters)
function SetDefaultGameData()
	for i = 1, #vars_values do
		game_data.vars[vars_values[i].name] = vars_values[i].default_value
	end
end

-- convert an imported image to the chosen preset
function ConvertImageToPreset(img)
	return img
end

require("tools")

function LoadGame(d, f, t)	
	-- check for errors
	if love.filesystem.getInfo(d .. "/" .. f) == nil then
		return nil
	end
	
	-- read the file
	file = love.filesystem.newFile(d .. "/" .. f)
	file:open("r")
	
	local file_string = ""
	
	-- read data
	file_string = file:read()
	
	-- close file
	file:close()
	
	-- explode file string
	local ts = split_string(file_string, "\r\n")
	local cpt = 0
	
	-- editable palette ?
	cpt = cpt + 1
	
	if ts[cpt] == "true" then
		t.editable_palette = true
	elseif ts[cpt] == "false" then
		t.editable_palette = false
	else
		return nil
	end
	
	-- max inks
	cpt = cpt + 1
	t.max_inks = tonumber(ts[cpt])
	
	-- ink's palette
	for i = 1, t.max_inks do
		cpt = cpt + 1
		t.inks_palette[i] = ts[cpt]
	end

	-- max pens
	cpt = cpt + 1
	t.max_pens = tonumber(ts[cpt])
	
	-- pen's palette
	for i = 1, t.max_pens do
		cpt = cpt + 1
		t.pens_palette[i] = tonumber(ts[cpt])
	end
	
	-- block width
	cpt = cpt + 1
	t.block_width = tonumber(ts[cpt])
	
	-- block height
	cpt = cpt + 1
	t.block_height = tonumber(ts[cpt])
	
	-- max blocks
	cpt = cpt + 1
	t.max_blocks = tonumber(ts[cpt])	
	
	-- blocks count
	cpt = cpt + 1
	local cpt_blocks = tonumber(ts[cpt])
	
	-- blocks data
	for i = 1, cpt_blocks do
		local ttemp = {}
		
		for x = 0, t.block_width - 1 do
			ttemp[x] = {}
			
			for y = 0, t.block_height - 1 do
				cpt = cpt + 1
				ttemp[x][y] = tonumber(ts[cpt])
			end
		end
		
		table.insert(t.blocks, ttemp)
	end
	
	current_block = cpt_blocks

	-- sprite width
	cpt = cpt + 1
	t.sprite_width = tonumber(ts[cpt])
	
	-- sprite height
	cpt = cpt + 1
	t.sprite_height = tonumber(ts[cpt])
	
	-- max sprites
	cpt = cpt + 1
	t.max_sprites = tonumber(ts[cpt])	
	
	-- sprite's count
	cpt = cpt + 1
	local cpt_sprites = tonumber(ts[cpt])
	
	-- sprites data
	for i = 1, cpt_sprites do
		local ttemp = {}

		for x = 0, t.sprite_width - 1 do
			ttemp[x] = {}
			
			for y = 0, t.sprite_height - 1 do
				cpt = cpt + 1
				ttemp[x][y] = tonumber(ts[cpt])
			end
		end
						
		table.insert(t.sprites, ttemp)
	end
		
	current_sprite = cpt_sprites
	
	-- max animations
	cpt = cpt + 1
	t.max_animations = tonumber(ts[cpt])

	-- animation's count
	cpt = cpt + 1
	local cpt_animations = tonumber(ts[cpt])

	for i = 1, cpt_animations do
		cpt = cpt + 1
		local cpt_frames = tonumber(ts[cpt])
		
		local ttemp = {}
		
		for j = 1, cpt_frames do		
			cpt = cpt + 1
			table.insert(ttemp, tonumber(ts[cpt]))
		end
		
		table.insert(t.animations, ttemp)
	end

	for i = 1, cpt_animations do
		cpt = cpt + 1
		
		local loop = false
		local v1 = 0
		local v2 = 0
		
		if ts[cpt] == "true" then loop = true end

		cpt = cpt + 1
		v1 = tonumber(ts[cpt])

		cpt = cpt + 1
		v2 = tonumber(ts[cpt])
		
		table.insert(t.animations_loop, {loop = loop, v1 = v1, v2 = v2})
	end
	
	current_animation = cpt_animations
	current_frame = 1
	
	-- max actors
	cpt = cpt + 1
	t.max_actors = tonumber(ts[cpt])

	-- actor's count
	cpt = cpt + 1
	local cpt_actors = tonumber(ts[cpt])
	
	for i = 1, cpt_actors do
		cpt = cpt + 1
		local e = tonumber(ts[cpt])
		
		table.insert(t.actors, {entity = e, type = {nil}})
		
		local tp = {}
		
		while true do
			cpt = cpt + 1
			local k = ts[cpt]
			
			if k ~= "END" then
				cpt = cpt + 1
				
				local v = nil
				
				if k == "name" then
					v = ts[cpt]
				else
					local vs = ts[cpt]
					
					if vs == "true" then
						v = true
					elseif vs == "false" then
						v = false
					else
						v = tonumber(vs)
					end
				end

				tp[k] = v
			else
				break
			end
		end
		
		t.actors[i].type = tp
	end
	
	current_actor = cpt_actors
	
	if current_actor > 0 then
		current_entity_type = t.actors[current_actor].entity
		
		FindCurrentEntityType(t)
	end
	
	-- max levels
	cpt = cpt + 1
	t.max_levels = tonumber(ts[cpt])

	-- level's count
	cpt = cpt + 1
	local cpt_levels = tonumber(ts[cpt])
	
	-- level's size
	cpt = cpt + 1
	t.levels_data.w = tonumber(ts[cpt])

	cpt = cpt + 1
	t.levels_data.h = tonumber(ts[cpt])

	cpt = cpt + 1
	t.levels_data.sw = tonumber(ts[cpt])

	cpt = cpt + 1
	t.levels_data.sh = tonumber(ts[cpt])

	-- get levels
	for i = 1, cpt_levels do
		-- prepare void level
		local t2 = {
			blocks = {},
			actors = {}
		}
		
		for x = 0, (t.levels_data.sw * t.levels_data.w) - 1 do
			t2.blocks[x] = {}

			for y = 0, (t.levels_data.sh * t.levels_data.h) - 1 do
				cpt = cpt + 1
				t2.blocks[x][y] = tonumber(ts[cpt])
			end
		end
				
		cpt = cpt + 1
		local cpt_actors = tonumber(ts[cpt])
		
		for j = 1, cpt_actors do
			cpt = cpt + 1
			local number = tonumber(ts[cpt])

			cpt = cpt + 1
			local start_x = tonumber(ts[cpt])

			cpt = cpt + 1
			local start_y = tonumber(ts[cpt])

			cpt = cpt + 1
			local x = tonumber(ts[cpt])

			cpt = cpt + 1
			local y = tonumber(ts[cpt])

			cpt = cpt + 1
			local animation = tonumber(ts[cpt])

			cpt = cpt + 1
			local frame = tonumber(ts[cpt])
			
			table.insert(t2.actors, {number = number, start_x = start_x, start_y = start_y, x = x, y = y, animation = animation, frame = frame})
		end
		
		table.insert(t.levels, t2)
	end
	
	current_level = cpt_levels
	current_level_mode = 0
	current_level_selected_block = 1
	current_level_selected_actor = 1
	current_level_scroll_x = 0
	current_level_scroll_y = 0

	-- pixel doubled ?
	cpt = cpt + 1

	if ts[cpt] == "true" then
		t.pixel_doubled = true
		t.pixel_size = 2
	elseif ts[cpt] == "false" then
		t.pixel_doubled = false
		t.pixel_size = 1
	else
		return nil
	end

	-- colors by blocks
	cpt = cpt + 1
	t.colors_by_block = tonumber(ts[cpt])
	
	-- colors by sprites
	cpt = cpt + 1
	t.colors_by_sprite = tonumber(ts[cpt])

	-- screen width
	cpt = cpt + 1
	t.screen_width = tonumber(ts[cpt])
	
	-- screen height
	cpt = cpt + 1
	t.screen_height = tonumber(ts[cpt])

	-- border ?
	cpt = cpt + 1

	if ts[cpt] == "true" then
		t.border = true
	elseif ts[cpt] == "false" then
		t.border = false
	else
		return nil
	end

	-- background paper
	cpt = cpt + 1
	t.background_paper = tonumber(ts[cpt])

	-- game paper
	cpt = cpt + 1
	t.game_paper = tonumber(ts[cpt])

	-- text paper
	cpt = cpt + 1
	t.text_paper = tonumber(ts[cpt])

	-- text pen
	cpt = cpt + 1
	t.text_pen = tonumber(ts[cpt])

	-- border paper
	cpt = cpt + 1
	t.border_paper = tonumber(ts[cpt])

	-- game area x
	cpt = cpt + 1
	table.insert(t.areas, {x = tonumber(ts[cpt])})

	-- game area y
	cpt = cpt + 1
	t.areas[GAME_AREA].y = tonumber(ts[cpt])

	-- game area width
	cpt = cpt + 1
	t.areas[GAME_AREA].width = tonumber(ts[cpt])

	-- game area height
	cpt = cpt + 1
	t.areas[GAME_AREA].height = tonumber(ts[cpt])

	-- score area x
	cpt = cpt + 1
	table.insert(t.areas, {x = tonumber(ts[cpt])})

	-- score area y
	cpt = cpt + 1
	t.areas[SCORE_AREA].y = tonumber(ts[cpt])

	-- score area width
	cpt = cpt + 1
	t.areas[SCORE_AREA].width = tonumber(ts[cpt])

	-- score area height
	cpt = cpt + 1
	t.areas[SCORE_AREA].height = tonumber(ts[cpt])

	-- lives area x
	cpt = cpt + 1
	table.insert(t.areas, {x = tonumber(ts[cpt])})

	-- lives area y
	cpt = cpt + 1
	t.areas[LIVES_AREA].y = tonumber(ts[cpt])

	-- lives area width
	cpt = cpt + 1
	t.areas[LIVES_AREA].width = tonumber(ts[cpt])

	-- lives area height
	cpt = cpt + 1
	t.areas[LIVES_AREA].height = tonumber(ts[cpt])

	-- level area x
	cpt = cpt + 1
	table.insert(t.areas, {x = tonumber(ts[cpt])})

	-- level area y
	cpt = cpt + 1
	t.areas[LEVEL_AREA].y = tonumber(ts[cpt])

	-- level area width
	cpt = cpt + 1
	t.areas[LEVEL_AREA].width = tonumber(ts[cpt])

	-- level area height
	cpt = cpt + 1
	t.areas[LEVEL_AREA].height = tonumber(ts[cpt])
	
	-- fonts
	cpt = cpt + 1
	t.fonts = ts[cpt]

	-- get blocks data
	for i = 1, cpt_blocks do
		cpt = cpt + 1
		table.insert(t.blocks_data, {type = ts[cpt]})
	end

	-- load level's scrolling positions
	for i = 1, cpt_levels do
		-- scrolling start x
		cpt = cpt + 1
		t.scrolling_start_x[i] = tonumber(ts[cpt])
		
		-- scrolling start y
		cpt = cpt + 1
		t.scrolling_start_y[i] = tonumber(ts[cpt])
	end
	
	return t
end

function SaveGame(d, f, t)
	-- get info about directory, does it exists ?
	local success = true
	
	-- create a new directory
	if love.filesystem.getInfo(d) == nil then
		success = love.filesystem.createDirectory("saves/" .. d)
	end
	
	-- write the file
	if success then
		file = love.filesystem.newFile("saves/" .. d .. "/" .. f)
		file:open("w")
		
		local ts = ""
		
		-- game name
		ts = ts .. t.game_name .. "\r\n"

		-- editable palette boolean
		ts = ts .. tostring(t.editable_palette) .. "\r\n"
		
		-- max inks in the inks palette
		ts = ts .. tostring(t.max_inks) .. "\r\n"

		-- full inks palette
		for i = 1, t.max_inks do
			ts = ts .. t.inks_palette[i] .. "\r\n"
		end

		-- max pens in the pens palette
		ts = ts .. tostring(t.max_pens) .. "\r\n"

		-- full pens palette
		for i = 1, t.max_pens do
			ts = ts .. tostring(t.pens_palette[i]) .. "\r\n"
		end

		-- size of a block, in pixels
		ts = ts .. tostring(t.block_width) .. "\r\n"
		ts = ts .. tostring(t.block_height) .. "\r\n"
		
		-- max blocks usable
		ts = ts .. tostring(t.max_blocks) .. "\r\n"
		
		-- number of blocks used
		ts = ts .. tostring(#t.blocks) .. "\r\n"
		
		-- blocks data
		for i = 1, #t.blocks do
			for x = 0, t.block_width - 1 do
				for y = 0, t.block_height - 1 do
					ts = ts .. tostring(t.blocks[i][x][y]) .. "\r\n"
				end
			end
		end

		-- size of a sprite, in pixels
		ts = ts .. tostring(t.sprite_width) .. "\r\n"
		ts = ts .. tostring(t.sprite_height) .. "\r\n"
		
		-- max sprites usable
		ts = ts .. tostring(t.max_sprites) .. "\r\n"

		-- number of sprites used
		ts = ts .. tostring(#t.sprites) .. "\r\n"
		
		-- sprites data
		for i = 1, #t.sprites do
			for x = 0, t.sprite_width - 1 do
				for y = 0, t.sprite_height - 1 do
					ts = ts .. tostring(t.sprites[i][x][y]) .. "\r\n"
				end
			end
		end
		
		-- max animations usable
		ts = ts .. tostring(t.max_animations) .. "\r\n"
		
		-- number of used animations
		ts = ts .. tostring(#t.animations) .. "\r\n"
		
		-- animations data
		for i = 1, #t.animations do
			ts = ts .. tostring(#t.animations[i]) .. "\r\n"
			
			for j = 1, #t.animations[i] do
				ts = ts .. tostring(t.animations[i][j]) .. "\r\n"
			end
		end

		-- animations loop vars
		for i = 1, #t.animations do
			ts = ts .. tostring(t.animations_loop[i].loop) .. "\r\n"
			ts = ts .. tostring(t.animations_loop[i].v1) .. "\r\n"
			ts = ts .. tostring(t.animations_loop[i].v2) .. "\r\n"
		end

		-- max actors usable
		ts = ts .. tostring(t.max_actors) .. "\r\n"
		
		-- number of used actors
		ts = ts .. tostring(#t.actors) .. "\r\n"
		
		-- actor's data
		for i = 1, #t.actors do
			ts = ts .. tostring(t.actors[i].entity) .. "\r\n"
			
			for k, v in pairs(t.actors[i].type) do
				ts = ts .. k .. "\r\n"
				
				if k == "name" then
					ts = ts .. v .. "\r\n"
				else
					ts = ts .. tostring(v) .. "\r\n"
				end
			end

			ts = ts .. "END\r\n"
		end
		
		-- max levels data
		ts = ts .. tostring(t.max_levels) .. "\r\n"
		
		-- number of used levels
		ts = ts .. tostring(#t.levels) .. "\r\n"

		-- levels size (in screens)
		ts = ts .. tostring(t.levels_data.w) .. "\r\n"
		ts = ts .. tostring(t.levels_data.h) .. "\r\n"
		
		-- size of a level's screen
		ts = ts .. tostring(t.levels_data.sw) .. "\r\n"
		ts = ts .. tostring(t.levels_data.sh) .. "\r\n"

		-- level's data
		for i = 1, #t.levels do
			for x = 0, (t.levels_data.sw * t.levels_data.w) - 1 do
				for y = 0, (t.levels_data.sh * t.levels_data.h) - 1 do
					ts = ts .. tostring(t.levels[i].blocks[x][y]) .. "\r\n"
				end
			end

			ts = ts .. tostring(#t.levels[i].actors) .. "\r\n"

			for j = 1, #t.levels[i].actors do
				ts = ts .. tostring(t.levels[i].actors[j].number) .. "\r\n"
				ts = ts .. tostring(t.levels[i].actors[j].start_x) .. "\r\n"
				ts = ts .. tostring(t.levels[i].actors[j].start_y) .. "\r\n"
				ts = ts .. tostring(t.levels[i].actors[j].x) .. "\r\n"
				ts = ts .. tostring(t.levels[i].actors[j].y) .. "\r\n"
				ts = ts .. tostring(t.levels[i].actors[j].animation) .. "\r\n"
				ts = ts .. tostring(t.levels[i].actors[j].frame) .. "\r\n"
				ts = ts .. tostring(t.levels[i].actors[j].hflip) .. "\r\n"
				ts = ts .. tostring(t.levels[i].actors[j].vflip) .. "\r\n"
			end
		end
		
		-- pixel are double size horizontally ?
		ts = ts .. tostring(t.pixel_doubled) .. "\r\n"
		
		-- how many colors max for a block
		ts = ts .. tostring(t.colors_by_block) .. "\r\n"
		
		-- how many colors max for a sprite
		ts = ts .. tostring(t.colors_by_sprite) .. "\r\n"
		
		-- screen size
		ts = ts .. tostring(t.screen_width) .. "\r\n"
		ts = ts .. tostring(t.screen_height) .. "\r\n"
		
		-- is there a border
		ts = ts .. tostring(t.border) .. "\r\n"
		
		-- papers, pens, border color
		ts = ts .. tostring(t.background_paper) .. "\r\n"
		ts = ts .. tostring(t.game_paper) .. "\r\n"
		ts = ts .. tostring(t.text_paper) .. "\r\n"
		ts = ts .. tostring(t.text_pen) .. "\r\n"
		ts = ts .. tostring(t.border_paper) .. "\r\n"
		
		-- game areas data
		for i = GAME_AREA, LEVEL_AREA do
			ts = ts .. tostring(t.areas[i].x) .. "\r\n"
			ts = ts .. tostring(t.areas[i].y) .. "\r\n"
			ts = ts .. tostring(t.areas[i].width) .. "\r\n"
			ts = ts .. tostring(t.areas[i].height) .. "\r\n"
		end

		-- font name
		ts = ts .. t.fonts .. "\r\n"

		-- blocks data
		for i = 1, #t.blocks do
			ts = ts .. t.blocks_data[i].type .. "\r\n"
		end
		
		-- save scrolling start
		for i = 1, #t.levels do
			ts = ts .. tostring(t.scrolling_start_x[i]) .. "\r\n"
			ts = ts .. tostring(t.scrolling_start_y[i]) .. "\r\n"
		end
		
		-- save game data
		ts = ts .. tostring(t.vars.lives) .. "\r\n" 					-- lives of the player
		ts = ts .. tostring(t.vars.game_speed) .. "\r\n"				-- game speed
		ts = ts .. tostring(t.vars.animations_speed) .. "\r\n"			-- animations speed
		ts = ts .. tostring(t.vars.game_goal) .. "\r\n"					-- game goal
		ts = ts .. tostring(t.vars.scrolling_type) .. "\r\n"			-- scrolling type
		ts = ts .. tostring(t.vars.scrolling_speed) .. "\r\n"			-- scrolling speed
		ts = ts .. tostring(t.vars.scrolling_horizontally) .. "\r\n"	-- scrolling horizontally
		ts = ts .. tostring(t.vars.scrolling_vertically) .. "\r\n"		-- scrolling vertically
		ts = ts .. tostring(t.vars.scroll_backward) .. "\r\n"			-- scroll backward
		ts = ts .. tostring(t.vars.gravity) .. "\r\n"					-- gravity
		ts = ts .. tostring(t.vars.jump_power) .. "\r\n"				-- jump power

		-- save music names
		for i = 1, #music_types do
			local value = game_data.musics[music_types[i]]
			
			if value ~= nil and value ~= "" then
				ts = ts .. value .. "\r\n"
			else
				ts = ts .. "\r\n"
			end
		end

		-- save image names
		for i = 1, #image_types do
			local value = game_data.images[image_types[i]]
			
			if value ~= nil and value ~= "" then
				ts = ts .. value .. "\r\n"
			else
				ts = ts .. "\r\n"
			end
		end
		
		-- write data
		file:write(ts)
	
		-- close file
		file:close()
	end
end

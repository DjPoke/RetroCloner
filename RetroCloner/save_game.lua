function SaveGame(d, f, t)
	-- get info about directory, does it exists ?
	local success = true
	
	-- create a new directory
	if love.filesystem.getInfo(d) == nil then
		success = love.filesystem.createDirectory(d)
	end
	
	-- write the file
	if success then
		file = love.filesystem.newFile(d .. "/" .. f)
		file:open("w")
		
		local ts = tostring(t.editable_palette) .. "\r\n"
		ts = ts .. tostring(t.max_inks) .. "\r\n"

		for i = 1, t.max_inks do
			ts = ts .. t.inks_palette[i] .. "\r\n"
		end

		ts = ts .. tostring(t.max_pens) .. "\r\n"

		for i = 1, t.max_pens do
			ts = ts .. tostring(t.pens_palette[i]) .. "\r\n"
		end

		ts = ts .. tostring(t.block_width) .. "\r\n"
		ts = ts .. tostring(t.block_height) .. "\r\n"
		ts = ts .. tostring(t.max_blocks) .. "\r\n"
		ts = ts .. tostring(#t.blocks) .. "\r\n"
		
		for i = 1, #t.blocks do
			for x = 0, t.block_width - 1 do
				for y = 0, t.block_height - 1 do
					ts = ts .. tostring(t.blocks[i][x][y]) .. "\r\n"
				end
			end
		end

		ts = ts .. tostring(t.sprite_width) .. "\r\n"
		ts = ts .. tostring(t.sprite_height) .. "\r\n"
		ts = ts .. tostring(t.max_sprites) .. "\r\n"
		ts = ts .. tostring(#t.sprites) .. "\r\n"
		
		for i = 1, #t.sprites do
			for x = 0, t.sprite_width - 1 do
				for y = 0, t.sprite_height - 1 do
					ts = ts .. tostring(t.sprites[i][x][y]) .. "\r\n"
				end
			end
		end
		
		ts = ts .. tostring(t.max_animations) .. "\r\n"
		ts = ts .. tostring(#t.animations) .. "\r\n"
		
		for i = 1, #t.animations do
			ts = ts .. tostring(#t.animations[i]) .. "\r\n"
			
			for j = 1, #t.animations[i] do
				ts = ts .. tostring(t.animations[i][j]) .. "\r\n"
			end
		end

		for i = 1, #t.animations do
			ts = ts .. tostring(t.animations_loop[i].loop) .. "\r\n"
			ts = ts .. tostring(t.animations_loop[i].v1) .. "\r\n"
			ts = ts .. tostring(t.animations_loop[i].v2) .. "\r\n"
		end

		ts = ts .. tostring(t.max_actors) .. "\r\n"
		ts = ts .. tostring(#t.actors) .. "\r\n"
		
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
		
		ts = ts .. tostring(t.max_levels) .. "\r\n"
		ts = ts .. tostring(#t.levels) .. "\r\n"

		ts = ts .. tostring(t.levels_data.w) .. "\r\n"
		ts = ts .. tostring(t.levels_data.h) .. "\r\n"
		ts = ts .. tostring(t.levels_data.sw) .. "\r\n"
		ts = ts .. tostring(t.levels_data.sh) .. "\r\n"

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
			end
		end
		
		ts = ts .. tostring(t.pixel_doubled) .. "\r\n"
		ts = ts .. tostring(t.colors_by_block) .. "\r\n"
		ts = ts .. tostring(t.colors_by_sprite) .. "\r\n"
		ts = ts .. tostring(t.screen_width) .. "\r\n"
		ts = ts .. tostring(t.screen_height) .. "\r\n"
		ts = ts .. tostring(t.border) .. "\r\n"
		ts = ts .. tostring(t.background_paper) .. "\r\n"
		ts = ts .. tostring(t.game_paper) .. "\r\n"
		ts = ts .. tostring(t.text_paper) .. "\r\n"
		ts = ts .. tostring(t.text_pen) .. "\r\n"
		ts = ts .. tostring(t.border_paper) .. "\r\n"
		
		for i = GAME_AREA, LEVEL_AREA do
			ts = ts .. tostring(t.areas[i].x) .. "\r\n"
			ts = ts .. tostring(t.areas[i].y) .. "\r\n"
			ts = ts .. tostring(t.areas[i].width) .. "\r\n"
			ts = ts .. tostring(t.areas[i].height) .. "\r\n"
		end

		ts = ts .. t.fonts .. "\r\n"

		for i = 1, #t.blocks do
			ts = ts .. t.blocks_data[i].type .. "\r\n"
		end
		
		for i = 1, #t.levels do
			ts = ts .. tostring(t.scrolling_start_x[i]) .. "\r\n"
			ts = ts .. tostring(t.scrolling_start_y[i]) .. "\r\n"
		end

		-- write data
		file:write(ts)
	
		-- close file
		file:close()
	end
end

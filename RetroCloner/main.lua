------------------------------
--
--         ============
--         Retro Cloner
--         ============
--
--       by Bruno Vignoli
--    (c) 2026 M.I.T Licence
--
--  A tool to make retro games
-- for PC that looks like retro
--        computer games
--
------------------------------

-- constants
EDITOR_WINDOW_WIDTH = 800
EDITOR_WINDOW_HEIGHT = 600
EDITOR_WINDOW_TITLE = "Retro Cloner"

WINDOW_WIDTH = 0
WINDOW_HEIGHT = 0
WINDOW_BORDER = 0
WINDOW_ZOOM = 3

GAME_TITLE_FONT_SIZE = 16
GAME_FONT_SIZE = 8
FONT_DOWN_SCALE = 64

GAME_TITLE_FONT = nil
GAME_FONT = nil

EDITOR_TITLE_FONT = love.graphics.newFont("fonts/CPCMode1.ttf", 32)
EDITOR_FONT = love.graphics.newFont("fonts/CPCMode1.ttf", 16)

MODE_MENU = 0
MODE_NEW_PROJECT = 1
MODE_LOAD_PROJECT = 2
MODE_SAVE_PROJECT = 3
MODE_EXPORT_EXECUTABLE_GAME = 4
MODE_TEST_GAME = 5
MODE_EDIT_PALETTE = 6
MODE_EDIT_SCREEN = 7
MODE_EDIT_BLOCKS = 8
MODE_EDIT_SPRITES = 9
MODE_EDIT_ANIMATIONS = 10
MODE_EDIT_ACTORS = 11
MODE_EDIT_LEVELS = 12
MODE_EDIT_GAMES_DATA = 13
MODE_IMPORT_SOUNDS = 14
MODE_IMPORT_MUSICS = 15
MODE_IMPORT_IMAGES = 16

NEW_PROJECT_MODE = 0
NEW_PROJECT_MODE_INPUT = 1
NEW_PROJECT_MODE_CHOOSE_PRESET = 2

LEVEL_MODE_BLOCKS = 0
LEVEL_MODE_ACTORS = 1

PALETTE_ZOOM = 16
SCREEN_ZOOM = 2
BLOCKS_ZOOM = 32
SPRITES_ZOOM = 16
ANIMATION_ZOOM = 2
LEVELS_ZOOM = 2

GAME_AREA = 1
SCORE_AREA = 2
LIVES_AREA = 3
LEVEL_AREA = 4

ENTITY_TYPE_PLAYER = 1
ENTITY_TYPE_ENEMY = 2
ENTITY_TYPE_BONUS = 3

MAX_ANIMATION_TIME = 2.0
MAX_FRAMES_BY_ANIMATION = 8

MAX_BLINK_TIME = 0.5
MID_BLINK_TIME = 0.25

-- arrays
presets = { "CPC-Mode0", "CPC-Mode1", "C64", "ZX-Spectrum" }
preset_data = {}

-- shared game's data
game_data = {
	editable_palette = false,
	max_inks = 0,
	inks_palette = {},
	max_pens = 0,
	pens_palette = {},
	blocks = {},
	blocks_data = {},
	sprites = {},
	animations = {},
	animations_loop = {},
	actors = {},
	levels = {},
	levels_data = {},
	pixel_doubled = false,
	pixel_size = 0,
	colors_by_block = 0,
	colors_by_sprite = 0,
	block_width = 0,
	block_height = 0,
	sprite_width = 0,
	sprite_height = 0,
	max_blocks = 0,
	max_sprites = 0,
	max_animations = 0,
	max_levels = 0,
	screen_width = 0,
	screen_height = 0,
	border = false,
	background_paper = 0,
	game_paper = 0,
	text_paper = 0,
	text_pen = 0,
	border_paper = 0,
	areas = {},
	fonts = "",
	scrolling_start_x = {},
	scrolling_start_y = {},
	-- Edit Game Data
	vars = {
		lives = 0,
		game_speed = 0.0
	}
}

-- blocks & sprites, converted to images
img_blocks = {}
img_sprites = {}

block_copy = {}
block_data_copy = {}
sprite_copy = {}
frame_copy = {}

-- different blocks types
blocks_types = {"background", "wall", "platform", "stairs", "death"}

-- vars
old_project_name = ""
project_name = ""
new_project_mode = NEW_PROJECT_MODE

selected_preset = 1
mode = MODE_MENU

area_selected = GAME_AREA

pen_color = 1
selected_color = 0

maxx = 0 -- relative to palette
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

block_x = 0
block_y = 0
sprite_x = 0
sprite_y = 0

block_too_many_color = false
sprite_too_many_color = false

file_list = {}
file_number = 0
text_message = ""

beep = nil

animation_timer = 0.0
blink_timer = 0.0

animation_playing = false
animation_frame = 0

-- requires
require("tools")
require("fonts")
require("functions")
require("load_game")
require("save_game")
require("commons")
run = require("run")

-- löve2d functions
function love.load()
	-- activate pixel art filter
	love.graphics.setDefaultFilter('nearest', 'nearest')

	-- set editor window size
	if not love.window.setMode(EDITOR_WINDOW_WIDTH, EDITOR_WINDOW_HEIGHT, {fullscreen = false, resizable = false, vsync = 1}) then
		print("Can't activate editor window !")
		
		love.event.quit(1)
	end
	
	-- set window title
	love.window.setTitle(EDITOR_WINDOW_TITLE)
	
	-- load beep sound
	beep = love.audio.newSource("sounds/beep.wav", "static")
end

function love.update(dt)
	if mode == MODE_LOAD_PROJECT then
		if file_number == 0 then
			old_project_name = project_name
			project_name = ""
			file_list = {}
			
			-- get folder's list in the save directory (Linux/MacOS only)
			for file in io.popen("ls -- " .. love.filesystem.getSaveDirectory()):lines() do
				table.insert(file_list, file)
			end
			
			if #file_list == 0 then
				project_name = old_project_name
				
				beep:stop()
				beep:play()
				mode = MODE_MENU
			else
				file_number = 1
				project_name = file_list[file_number]
			end
		end
	elseif mode == MODE_TEST_GAME then
		-- update the game test
		run.update(dt)
	elseif mode == MODE_EDIT_SCREEN then
		-- move or resize the selected area
		if love.keyboard.isDown("up") then
			if love.keyboard.isDown("lshift") then
				game_data.areas[area_selected].height = game_data.areas[area_selected].height - 1
				
				if area_selected == GAME_AREA then UpdateLevelsData() end
			else
				game_data.areas[area_selected].y = game_data.areas[area_selected].y - 1
			end
		elseif love.keyboard.isDown("down") then
			if love.keyboard.isDown("lshift") then
				game_data.areas[area_selected].height = game_data.areas[area_selected].height + 1
				
				if area_selected == GAME_AREA then UpdateLevelsData() end
			else
				game_data.areas[area_selected].y = game_data.areas[area_selected].y + 1
			end
		end
		
		if love.keyboard.isDown("left") then
			if love.keyboard.isDown("lshift") then
				game_data.areas[area_selected].width = game_data.areas[area_selected].width - 1
				
				if area_selected == GAME_AREA then UpdateLevelsData() end
			else
				game_data.areas[area_selected].x = game_data.areas[area_selected].x - 1
			end		
		elseif love.keyboard.isDown("right") then
			if love.keyboard.isDown("lshift") then
				game_data.areas[area_selected].width = game_data.areas[area_selected].width + 1
				
				if area_selected == GAME_AREA then UpdateLevelsData() end
			else
				game_data.areas[area_selected].x = game_data.areas[area_selected].x + 1
			end
		end
	elseif mode == MODE_EDIT_BLOCKS then
		if current_block > 0 then
			local mx = love.mouse.getX()
			local my = love.mouse.getY()

			local xc = 400 - (game_data.block_width * game_data.pixel_size * BLOCKS_ZOOM / 2)
			local yc = 160
			
			block_x = math.floor((mx - xc) / (game_data.pixel_size * BLOCKS_ZOOM))
			block_y = math.floor((my - yc) / BLOCKS_ZOOM)
			
			-- draw
			if love.mouse.isDown(1) == true then
				if block_x >= 0 and block_x < game_data.block_width then
					if block_y >= 0 and block_y < game_data.block_height then
						game_data.blocks[current_block][block_x][block_y] = pen_color

						block_too_many_color = TooManyColorsInBlock(game_data.blocks[current_block])
					end
				end
			elseif love.mouse.isDown(2) == true then
				if block_x >= 0 and block_x < game_data.block_width then
					if block_y >= 0 and block_y < game_data.block_height then
						game_data.blocks[current_block][block_x][block_y] = 0
						
						block_too_many_color = TooManyColorsInBlock(game_data.blocks[current_block])
					end
				end
			end
		end
	elseif mode == MODE_EDIT_SPRITES then
		if current_sprite > 0 then
			local mx = love.mouse.getX()
			local my = love.mouse.getY()

			local xc = 400 - (game_data.sprite_width * game_data.pixel_size * SPRITES_ZOOM / 2)
			local yc = 160
			
			sprite_x = math.floor((mx - xc) / (game_data.pixel_size * SPRITES_ZOOM))
			sprite_y = math.floor((my - yc) / SPRITES_ZOOM)
			
			-- draw
			if love.mouse.isDown(1) == true then
				if sprite_x >= 0 and sprite_x < game_data.sprite_width then
					if sprite_y >= 0 and sprite_y < game_data.sprite_height then
						game_data.sprites[current_sprite][sprite_x][sprite_y] = pen_color
						
						sprite_too_many_color = TooManyColorsInSprite(game_data.sprites[current_sprite])
					end
				end
			elseif love.mouse.isDown(2) == true then
				if sprite_x >= 0 and sprite_x < game_data.sprite_width then
					if sprite_y >= 0 and sprite_y < game_data.sprite_height then
						game_data.sprites[current_sprite][sprite_x][sprite_y] = 0

						sprite_too_many_color = TooManyColorsInSprite(game_data.sprites[current_sprite])
					end
				end
			end
		end
	elseif mode == MODE_EDIT_ANIMATIONS then
		if current_animation > 0 then
			if animation_playing == true then
				animation_timer = animation_timer + dt
				
				if animation_timer >= (MAX_ANIMATION_TIME / MAX_FRAMES_BY_ANIMATION) then
					animation_timer = 0.0
					animation_frame = animation_frame + 1
					
					if game_data.animations_loop[current_animation].loop == false then
						if animation_frame > #game_data.animations[current_animation] then
							animation_playing = false
							animation_frame = 0
						end
					elseif game_data.animations_loop[current_animation].loop == true then
						if animation_frame > game_data.animations_loop[current_animation].v2 then
							animation_frame = game_data.animations_loop[current_animation].v1
						end
					end
				end
			end
		end
	elseif mode == MODE_EDIT_LEVELS then
		if current_level > 0 then
			-- blink in editor mode
			blink_timer = blink_timer + dt
			if blink_timer >= MAX_BLINK_TIME then blink_timer = 0 end
			
			-- get mouse coordinates
			local mx = love.mouse.getX()
			local my = love.mouse.getY()
			
			-- draw blocks with the mouse
			if current_level_mode == LEVEL_MODE_BLOCKS then
				local xc = 400 - (game_data.levels_data.sw * game_data.block_width * game_data.pixel_size * LEVELS_ZOOM / 2)
				local yc = 160
				
				local bx = math.floor((mx - xc) / (game_data.block_width * game_data.pixel_size * LEVELS_ZOOM))
				local by = math.floor((my - yc) / (game_data.block_height * LEVELS_ZOOM))

				if love.mouse.isDown(1) == true then
					-- draw blocks in the level
					if bx >= 0 and bx < game_data.levels_data.sw then
						if by >= 0 and by < game_data.levels_data.sh then
							game_data.levels[current_level].blocks[bx - current_level_scroll_x][by - current_level_scroll_y] = current_level_selected_block
						end
					end
				elseif love.mouse.isDown(2) == true then
					-- clear blocks in the level
					if bx >= 0 and bx < game_data.levels_data.sw then
						if by >= 0 and by < game_data.levels_data.sh then
							game_data.levels[current_level].blocks[bx - current_level_scroll_x][by - current_level_scroll_y] = 0
						end
					end
				end
			end

			-- scroll the level's (in blocks)
			if love.keyboard.isDown("up") == true then
				if current_level_scroll_y < 0 then
					current_level_scroll_y = current_level_scroll_y + 1
				end
			elseif love.keyboard.isDown("down") == true then
				if current_level_scroll_y > -(game_data.levels_data.sh * (game_data.levels_data.h - 1)) then
					current_level_scroll_y = current_level_scroll_y - 1
				end
			end

			if love.keyboard.isDown("left") == true then
				if current_level_scroll_x < 0 then
					current_level_scroll_x = current_level_scroll_x + 1
				end
			elseif love.keyboard.isDown("right") == true then
				if current_level_scroll_x > -(game_data.levels_data.sw * (game_data.levels_data.w - 1)) then
					current_level_scroll_x = current_level_scroll_x - 1
				end
			end
		end
	end
end

function love.draw()
	-- set grey background
	love.graphics.setColor(0, 0.5, 1)
	love.graphics.rectangle("fill", 0, 0, EDITOR_WINDOW_WIDTH, EDITOR_WINDOW_HEIGHT)
	
	if mode == MODE_MENU then
		-- draw title
		love.graphics.setFont(EDITOR_TITLE_FONT)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print("RETRO CLONER", 208, 32)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("RETRO CLONER", 209, 33)

		-- draw menu
		love.graphics.setFont(EDITOR_FONT)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("a", 200, 120)
		love.graphics.print("b", 200, 140)
		love.graphics.print("c", 200, 160)
		love.graphics.print("d", 200, 180)
		love.graphics.print("e", 200, 200)
		love.graphics.print("f", 200, 240)
		love.graphics.print("g", 200, 260)
		love.graphics.print("h", 200, 280)
		love.graphics.print("i", 200, 300)
		love.graphics.print("j", 200, 320)
		love.graphics.print("k", 200, 340)
		love.graphics.print("l", 200, 380)
		love.graphics.print("m", 200, 400)
		love.graphics.print("n", 200, 440)
		love.graphics.print("o", 200, 460)
		love.graphics.print("p", 200, 480)
		love.graphics.print("q", 200, 520)

		love.graphics.setColor(0, 0, 1)
		love.graphics.print(")", 216, 120)
		love.graphics.print(")", 216, 140)
		love.graphics.print(")", 216, 160)
		love.graphics.print(")", 216, 180)
		love.graphics.print(")", 216, 200)
		love.graphics.print(")", 216, 240)
		love.graphics.print(")", 216, 260)
		love.graphics.print(")", 216, 280)
		love.graphics.print(")", 216, 300)
		love.graphics.print(")", 216, 320)
		love.graphics.print(")", 216, 340)
		love.graphics.print(")", 216, 380)
		love.graphics.print(")", 216, 400)
		love.graphics.print(")", 216, 440)
		love.graphics.print(")", 216, 460)
		love.graphics.print(")", 216, 480)
		love.graphics.print(")", 216, 520)

		love.graphics.setColor(0, 1, 1)
		love.graphics.print("New Project", 250, 120)
		love.graphics.print("Load Project", 250, 140)
		
		if project_name == "" then love.graphics.setColor(1, 0, 0) end
		
		love.graphics.print("Save Project", 250, 160)
		love.graphics.print("Export Executable Game", 250, 180)
		love.graphics.print("Test Game", 250, 200)
		love.graphics.print("Edit Palette", 250, 240)
		love.graphics.print("Edit Screen", 250, 260)
		love.graphics.print("Edit Blocks", 250, 280)
		love.graphics.print("Edit Sprites", 250, 300)
		love.graphics.print("Edit Animations", 250, 320)
		love.graphics.print("Edit Actors", 250, 340)
		love.graphics.print("Edit Levels", 250, 380)
		love.graphics.print("Edit Game Data", 250, 400)
		love.graphics.print("Import Sounds", 250, 440)
		love.graphics.print("Import Musics", 250, 460)
		love.graphics.print("Import Images", 250, 480)

		love.graphics.setColor(0, 1, 1)
		love.graphics.print("Quit", 250, 520)
		
		love.graphics.setColor(0, 0, 0.5)
		love.graphics.rectangle("line", 16, 16, EDITOR_WINDOW_WIDTH - 32, EDITOR_WINDOW_HEIGHT - 32)
	elseif mode == MODE_NEW_PROJECT then
		-- draw title
		love.graphics.setFont(EDITOR_TITLE_FONT)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print("NEW PROJECT", 224, 32)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("NEW PROJECT", 225, 33)

		if new_project_mode == NEW_PROJECT_MODE_INPUT then
			-- show project name
			love.graphics.setFont(EDITOR_FONT)
			love.graphics.setColor(0, 1, 1)
			love.graphics.print("Project name: " .. project_name, 200, 120)
		elseif new_project_mode == NEW_PROJECT_MODE_CHOOSE_PRESET then
			-- draw presets selection
			love.graphics.setFont(EDITOR_FONT)
			love.graphics.setColor(0, 1, 1)
			love.graphics.print("Please choose a game preset:", 200, 120)
			
			for i = 1, #presets do
				love.graphics.setColor(1, 1, 1)
				love.graphics.print(string.char(96 + i), 200, 160 + ((i - 1) * 20))
				love.graphics.setColor(0, 0, 1)
				love.graphics.print(")", 216, 160 + ((i - 1) * 20))
				love.graphics.setColor(0, 1, 1)
				love.graphics.print(presets[i], 250, 160 + ((i - 1) * 20))
			end
		end
	elseif mode == MODE_LOAD_PROJECT then
		-- draw title
		love.graphics.setFont(EDITOR_TITLE_FONT)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print("LOAD PROJECT", 208, 32)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("LOAD PROJECT", 209, 33)
		
		-- draw filename
		love.graphics.setFont(EDITOR_FONT)
		love.graphics.setColor(0, 1, 1)
		love.graphics.print("Project name: " .. project_name, 200, 120)
		love.graphics.print("[Tab] to change...", 200, 140)
	elseif mode == MODE_SAVE_PROJECT then
		-- draw title
		love.graphics.setFont(EDITOR_TITLE_FONT)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print("SAVE PROJECT", 208, 32)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("SAVE PROJECT", 209, 33)
		
		-- draw message
		love.graphics.setFont(EDITOR_FONT)
		love.graphics.setColor(0, 1, 1)
		love.graphics.print(text_message, 100, 120)
	elseif mode == MODE_EXPORT_EXECUTABLE_GAME then
	elseif mode == MODE_TEST_GAME then
		run.draw()
	elseif mode == MODE_EDIT_PALETTE then
		-- draw title
		love.graphics.setFont(EDITOR_TITLE_FONT)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print("EDIT PALETTE", 208, 32)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("EDIT PALETTE", 209, 33)
		
		-- draw palette
		love.graphics.setFont(EDITOR_FONT)
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("fill", 400 - (8 * 2 * PALETTE_ZOOM) - 2, 120 - 2, (2 * PALETTE_ZOOM * maxx) + 4, (PALETTE_ZOOM * maxy) + 4)

		if maxx > 0 and maxy > 0 then
			for y = 0, maxy - 1 do
				for x = 0, maxx - 1 do
					local r, g, b = GetPenRGB(x + (y * 16))
					love.graphics.setColor(r, g, b)
					love.graphics.rectangle("fill", 400 + (x * 2 * PALETTE_ZOOM) - (8 * 2 * PALETTE_ZOOM), 120 + (y * PALETTE_ZOOM), 2 * PALETTE_ZOOM, PALETTE_ZOOM)
					
					-- draw a selection rectangle on top of the selected color
					if selected_color == x + (y * 16) then
						local xc = 400 + (x * 2 * PALETTE_ZOOM) - (8 * 2 * PALETTE_ZOOM)
						local yc = 120 + (y * PALETTE_ZOOM)
						local wc = 2 * PALETTE_ZOOM
						local hc = PALETTE_ZOOM
						
						ShowCursor(xc, yc, wc, hc, 1, 1, 1)
					end
				end
			end
			
			-- draw informations
			love.graphics.setColor(0, 1, 1)
			love.graphics.print("Pen " .. tostring(selected_color) .. " Ink " .. tostring(game_data.pens_palette[selected_color + 1]), 300, 220)
			
		
			-- draw shortcuts
			love.graphics.print("[Left/Right] Change pen [Up/Down] Change ink", 10, 500)
			love.graphics.print("[Esc] Back", 10, 520)
		end
	elseif mode == MODE_EDIT_SCREEN then
		-- draw title
		love.graphics.setFont(EDITOR_TITLE_FONT)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print("EDIT SCREEN", 224, 32)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("EDIT SCREEN", 225, 33)
		
		-- draw screen
		local r, g, b = GetPenRGB(game_data.background_paper)
		love.graphics.setColor(r, g, b)

		local screen_x = math.floor((800 - game_data.screen_width * game_data.pixel_size * SCREEN_ZOOM) / 2)
		local screen_y = 75
		
		love.graphics.rectangle("fill", screen_x, screen_y, game_data.screen_width * game_data.pixel_size * SCREEN_ZOOM, game_data.screen_height * SCREEN_ZOOM)
		
		-- draw areas
		local r, g, b = GetPenRGB(game_data.game_paper)
		love.graphics.setColor(r, g, b)
		
		love.graphics.rectangle("fill", screen_x + (game_data.areas[GAME_AREA].x * game_data.pixel_size * SCREEN_ZOOM), screen_y + (game_data.areas[GAME_AREA].y * SCREEN_ZOOM), game_data.areas[GAME_AREA].width * game_data.pixel_size * SCREEN_ZOOM, game_data.areas[GAME_AREA].height * SCREEN_ZOOM)
				
		-- draw text's areas
		FontsPrint("SCORE " .. ToString2(run.vars.score, 7), screen_x + (game_data.areas[SCORE_AREA].x * game_data.pixel_size * SCREEN_ZOOM), screen_y + (game_data.areas[SCORE_AREA].y * SCREEN_ZOOM), game_data.areas[SCORE_AREA].width * SCREEN_ZOOM, game_data.areas[SCORE_AREA].height * SCREEN_ZOOM, GAME_FONT, FONT_DOWN_SCALE / SCREEN_ZOOM, game_data.text_paper, game_data.text_pen)
		FontsPrint("LIVES " .. ToString2(game_data.vars.lives, 2), screen_x + (game_data.areas[LIVES_AREA].x * game_data.pixel_size * SCREEN_ZOOM), screen_y + (game_data.areas[LIVES_AREA].y * SCREEN_ZOOM), game_data.areas[LIVES_AREA].width * SCREEN_ZOOM, game_data.areas[LIVES_AREA].height * SCREEN_ZOOM, GAME_FONT, FONT_DOWN_SCALE / SCREEN_ZOOM, game_data.text_paper, game_data.text_pen)
		FontsPrint("LEVEL " .. ToString2(run.vars.level, 3), screen_x + (game_data.areas[LEVEL_AREA].x * game_data.pixel_size * SCREEN_ZOOM), screen_y + (game_data.areas[LEVEL_AREA].y * SCREEN_ZOOM), game_data.areas[LEVEL_AREA].width * SCREEN_ZOOM, game_data.areas[LEVEL_AREA].height * SCREEN_ZOOM, GAME_FONT, FONT_DOWN_SCALE / SCREEN_ZOOM, game_data.text_paper, game_data.text_pen)
			
		for i = 1, LEVEL_AREA do
			if area_selected == i then
				ShowCursor(screen_x + (game_data.areas[i].x * game_data.pixel_size * SCREEN_ZOOM), screen_y + (game_data.areas[i].y * SCREEN_ZOOM), game_data.areas[i].width * game_data.pixel_size * SCREEN_ZOOM, game_data.areas[i].height * SCREEN_ZOOM, 1, 1, 1)
			end
		end
		
		-- draw shortcuts
		love.graphics.setFont(EDITOR_FONT)
		love.graphics.setColor(0, 1, 1)
		local infos = tostring(game_data.areas[area_selected].x) .. "," .. tostring(game_data.areas[area_selected].y) .. " - " .. tostring(game_data.areas[area_selected].width) .. "," .. tostring(game_data.areas[area_selected].height)
		love.graphics.print(infos, 200, 480)
		local r, g, b = GetPenRGB(game_data.border_paper)
		love.graphics.setColor(r, g, b)
		love.graphics.print("Border color: " .. tostring(game_data.border_paper), 500, 480)
		love.graphics.setColor(0, 1, 1)
		love.graphics.print("[Tab] Select area to edit - [Arrows] Position ", 10, 520)
		love.graphics.print("[Arrows+Shift] Resize - [f1-f5] Change colors", 10, 540)
		love.graphics.print("[Esc] Back", 10, 560)
	elseif mode == MODE_EDIT_BLOCKS then
		-- draw title
		love.graphics.setFont(EDITOR_TITLE_FONT)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print("EDIT BLOCKS", 224, 32)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("EDIT BLOCKS", 225, 33)
		
		-- draw pen
		love.graphics.setFont(EDITOR_FONT)
		love.graphics.setColor(0, 1, 1)
		love.graphics.print("Pen " .. pen_color, 140, 100)
		local r, g, b = GetPenRGB(pen_color)
		love.graphics.setColor(r, g, b)
		love.graphics.rectangle("fill", 260, 100, 32, 16)
		
		-- draw current block number
		love.graphics.setColor(0, 1, 1)

		if current_block > 0 then
			love.graphics.print("Block " .. tostring(current_block) .. " : " .. game_data.blocks_data[current_block].type, 320, 100)
		else
			love.graphics.print("No blocks!", 320, 100)
		end

		-- draw error message if too many colors
		if block_too_many_color == true then
			love.graphics.setColor(1, 0, 0)
			love.graphics.print("Error: too many colors for this preset!", 80, 120)
		end
		
		-- draw current block
		if current_block > 0 then
			for x = 0, game_data.block_width - 1 do				
				for y = 0, game_data.block_height - 1 do
					local xc = 400 + (x * game_data.pixel_size * BLOCKS_ZOOM) - (game_data.block_width * game_data.pixel_size * BLOCKS_ZOOM / 2)
					local yc = 160 + (y * BLOCKS_ZOOM)
					local wc = BLOCKS_ZOOM * game_data.pixel_size
					local hc = BLOCKS_ZOOM
					local r, g, b = GetPenRGB(game_data.blocks[current_block][x][y])
					love.graphics.setColor(r, g, b)
					love.graphics.rectangle("fill", xc, yc, wc, hc)
				end
			end
		end

		-- draw shortcuts
		love.graphics.setColor(0, 1, 1)
		love.graphics.print("[A]dd a block - [C]opy block - [P]aste block", 10, 460)
		love.graphics.print("[D]elete block - [T]ype - [Tab] Change pen", 10, 480)
		love.graphics.print("[Mouse] Move - [LClick] Draw - [RClick] Clear", 10, 500)
		love.graphics.print("[F]ill", 10, 520)
		love.graphics.print("[PgDown] Previous block - [PgUp] Next block", 10, 540)
		love.graphics.print("[Esc] Back", 10, 560)
	elseif mode == MODE_EDIT_SPRITES then
		-- draw title
		love.graphics.setFont(EDITOR_TITLE_FONT)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print("EDIT SPRITES", 208, 32)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("EDIT SPRITES", 209, 33)
		
		-- draw pen
		love.graphics.setFont(EDITOR_FONT)
		love.graphics.setColor(0, 1, 1)
		love.graphics.print("Pen " .. pen_color, 240, 100)
		local r, g, b = GetPenRGB(pen_color)
		love.graphics.setColor(r, g, b)
		love.graphics.rectangle("fill", 360, 100, 32, 16)
		
		-- draw current sprite number
		love.graphics.setColor(0, 1, 1)

		if current_sprite > 0 then
			love.graphics.print("Sprite " .. tostring(current_sprite), 420, 100)
		else
			love.graphics.print("No sprites!", 420, 100)
		end
		
		if pen_color == 0 then
			love.graphics.print("(Transparent) ", 240, 120)
		end

		-- draw error message if too many colors
		if sprite_too_many_color == true then
			love.graphics.setColor(1, 0, 0)
			love.graphics.print("Error: too many colors for this preset!", 80, 140)
		end
		
		-- draw current sprite
		if current_sprite > 0 then
			for x = 0, game_data.sprite_width - 1 do
				for y = 0, game_data.sprite_height - 1 do
					local xc = 400 + (x * game_data.pixel_size * SPRITES_ZOOM) - (game_data.sprite_width * game_data.pixel_size * SPRITES_ZOOM / 2)
					local yc = 160 + (y * SPRITES_ZOOM)
					local wc = SPRITES_ZOOM * game_data.pixel_size
					local hc = SPRITES_ZOOM
					local r, g, b = GetPenRGB(game_data.sprites[current_sprite][x][y])
					love.graphics.setColor(r, g, b)
					love.graphics.rectangle("fill", xc, yc, wc, hc)
				end
			end
		end

		-- draw shortcuts
		love.graphics.setColor(0, 1, 1)
		love.graphics.print("[A]dd a sprite - [C]opy sprite - [P]aste sprite", 10, 460)
		love.graphics.print("[D]elete sprite", 10, 480)
		love.graphics.print("[Mouse] Move - [LClick] Draw - [RClick] Clear", 10, 500)
		love.graphics.print("[F]ill", 10, 520)
		love.graphics.print("[PgDown] Previous sprite - [PgUp] Next sprite", 10, 540)
		love.graphics.print("[Esc] Back", 10, 560)
	elseif mode == MODE_EDIT_ANIMATIONS then
		-- draw title
		love.graphics.setFont(EDITOR_TITLE_FONT)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print("EDIT ANIMATIONS", 192, 32)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("EDIT ANIMATIONS", 193, 33)
		
		-- draw current animation
		love.graphics.setFont(EDITOR_FONT)
		love.graphics.setColor(0, 1, 1)
		
		if current_animation > 0 then
			-- draw texts
			love.graphics.print("Animation " .. tostring(current_animation), 300, 80)

			local ani_list = ""
			local sel_list = ""
			
			for i = 1, #game_data.animations[current_animation] do
				ani_list = ani_list .. tostring(game_data.animations[current_animation][i])
				
				if i == current_frame then
					sel_list = sel_list .. "*"
				else
					sel_list = sel_list .. " "
				end
				
				if i < #game_data.animations[current_animation] then
					ani_list = ani_list .. ", "
					sel_list = sel_list .. "  "
				end
			end
			
			love.graphics.print(ani_list, 10, 120)

			-- show selected frame
			love.graphics.setColor(1, 1, 1)
			love.graphics.print(sel_list, 10, 140)
			
			-- draw current image
			local f = game_data.animations[current_animation][current_frame]
			
			if img_sprites[f] ~= nil then
				love.graphics.setColor(1, 1, 1)
				love.graphics.draw(img_sprites[f], 288, 180, 0, ANIMATION_ZOOM * game_data.pixel_size, ANIMATION_ZOOM)
			else
				love.graphics.setColor(0, 1, 1)
				love.graphics.print("No sprite!", 320, 180)
			end
			
			-- draw current animated animation
			if animation_playing == true then
				love.graphics.draw(img_sprites[game_data.animations[current_animation][animation_frame]], 496, 180, 0, ANIMATION_ZOOM * game_data.pixel_size, ANIMATION_ZOOM)
			end
			
			-- show loop mode
			love.graphics.setColor(0, 1, 1)
			local loop = "off"
			if game_data.animations_loop[current_animation].loop == true then loop = "on" end
			love.graphics.print("Loop mode " .. tostring(loop) .. " v1 " .. tostring(game_data.animations_loop[current_animation].v1) .. " v2 " .. tostring(game_data.animations_loop[current_animation].v2), 200, 280)
			
		else
			love.graphics.print("No animations!", 300, 80)
		end		

		-- draw shortcuts
		love.graphics.setColor(0, 1, 1)
		love.graphics.print("[A]dd an animation - [C]opy animation", 10, 420)
		love.graphics.print("[P]aste animation - [D]elete animation", 10, 440)
		love.graphics.print("[F] Add a frame - [Backspace] Delete last frame", 10, 460)
		love.graphics.print("[Arrows] Navigate between frames and sprites", 10, 480)
		love.graphics.print("[PgDown] Previous anim. - [PgUp] Next anim.", 10, 500)
		love.graphics.print("[L]oop On/Off - [F1-F2] Set loop limits", 10, 520)
		love.graphics.print("[Space] Play current animation", 10, 540)
		love.graphics.print("[Esc] Back", 10, 560)
	elseif mode == MODE_EDIT_ACTORS then
		-- draw title
		love.graphics.setFont(EDITOR_TITLE_FONT)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print("EDIT ACTORS", 224, 32)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("EDIT ACTORS", 225, 33)

		-- draw actor's parameters
		love.graphics.setFont(EDITOR_FONT)
		love.graphics.setColor(0, 1, 1)
		
		if #game_data.actors > 0 then
			-- show actor's entity type
			love.graphics.print("Actor " .. tostring(current_actor) .. " as " .. entity_types[game_data.actors[current_actor].entity], 200, 80)

			-- show entity type
			if game_data.actors[current_actor].entity == ENTITY_TYPE_PLAYER then
				love.graphics.print("Player type " .. game_data.actors[current_actor].type.name, 200, 120)				

				-- show animation's names list
				for i = 1, #player_animations[current_player_type] do
					love.graphics.setColor(0, 1, 1)
					if current_property == i then love.graphics.setColor(1, 1, 0) end

					local k = player_animations[current_player_type][i]
					local v = game_data.actors[current_actor].type[player_animations[current_player_type][i]]

					love.graphics.print(k .. ": " .. tostring(v), 200, 160 + ((i - 1) * 20))
				end
			elseif game_data.actors[current_actor].entity == ENTITY_TYPE_ENEMY then
				love.graphics.print("Enemy type " .. game_data.actors[current_actor].type.name, 200, 120)
				
				-- show animation's names list
				for i = 1, #enemy_animations[current_enemy_type] do
					love.graphics.setColor(0, 1, 1)
					if current_property == i then love.graphics.setColor(1, 1, 0) end

					local k = enemy_animations[current_enemy_type][i]
					local v = game_data.actors[current_actor].type[enemy_animations[current_enemy_type][i]]

					love.graphics.print(k .. ": " .. tostring(v), 200, 160 + ((i - 1) * 20))
				end
			elseif game_data.actors[current_actor].entity == ENTITY_TYPE_BONUS then
				love.graphics.print("Bonus type " .. game_data.actors[current_actor].type.name, 200, 120)
				
				-- show animation's names list
				for i = 1, #bonus_animations[current_bonus_type] do
					love.graphics.setColor(0, 1, 1)
					if current_property == i then love.graphics.setColor(1, 1, 0) end

					local k = enemy_animations[current_bonus_type][i]
					local v = game_data.actors[current_actor].type[bonus_animations[current_bonus_type][i]]

					love.graphics.print(k .. ": " .. tostring(v), 200, 160 + ((i - 1) * 20))
				end
			end

		else
			love.graphics.print("No actors!", 260, 80)
		end
		
		-- draw shortcuts
		love.graphics.setColor(0, 1, 1)
		love.graphics.print("[A]dd actor - [D]elete actor", 10, 480)
		love.graphics.print("[Tab] Change entity kind - [T] Select type", 10, 500)
		love.graphics.print("[Arrows] Change animation", 10, 520)
		love.graphics.print("[PgDown] Previous actor - [PgUp] Next actor", 10, 540)
		love.graphics.print("[Esc] Back", 10, 560)
	elseif mode == MODE_EDIT_LEVELS then
		-- draw title
		love.graphics.setFont(EDITOR_TITLE_FONT)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print("EDIT LEVELS", 224, 32)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("EDIT LEVELS", 225, 33)

		-- draw level's parameters
		love.graphics.setFont(EDITOR_FONT)
		love.graphics.setColor(0, 1, 1)
		
		if current_level > 0 then
			-- print level number
			love.graphics.print("Level " .. tostring(current_level), 320, 80)

			-- print level size
			love.graphics.print("Level size (in screens): width " .. tostring(game_data.levels_data.w) .. " height " .. tostring(game_data.levels_data.h), 80, 120)
			
			-- draw the game area
			local r, g, b = GetPenRGB(game_data.game_paper)
			love.graphics.setColor(r, g, b)

			local area_x = 400 - math.floor((game_data.areas[GAME_AREA].width * game_data.pixel_size * SCREEN_ZOOM) / 2)
			local area_y = 160
		
			love.graphics.rectangle("fill", area_x, area_y, game_data.areas[GAME_AREA].width * game_data.pixel_size * SCREEN_ZOOM, game_data.areas[GAME_AREA].height * SCREEN_ZOOM)

			-- calculate blocks offset
			local offset_x = math.floor((game_data.areas[GAME_AREA].width - (game_data.levels_data.sw * game_data.block_width)) / 2)
			local offset_y = math.floor((game_data.areas[GAME_AREA].height - (game_data.levels_data.sh * game_data.block_height)) / 2)
						
			local pos_x = area_x + offset_x
			local pos_y = area_y + offset_y
			
			local area_width = (game_data.levels_data.sw * game_data.block_width) * game_data.pixel_size * SCREEN_ZOOM
			local area_height = (game_data.levels_data.sh * game_data.block_height) * SCREEN_ZOOM
			
			-- enable scissor for the game window
			love.graphics.setScissor(pos_x, pos_y, area_width, area_height)
			
			-- draw level's blocks
			love.graphics.setColor(1, 1, 1)
			
			for x = 0, game_data.levels_data.sw - 1 do
				for y = 0, game_data.levels_data.sh - 1 do
					local bx = x - current_level_scroll_x
					local by = y - current_level_scroll_y
					local real_x = pos_x + (x * game_data.block_width * game_data.pixel_size * SCREEN_ZOOM)
					local real_y = pos_y + (y * game_data.block_height * SCREEN_ZOOM)
					
					if game_data.levels[current_level].blocks[bx][by] > 0 then
						if #img_blocks > 0 then
							love.graphics.draw(img_blocks[game_data.levels[current_level].blocks[bx][by]], real_x, real_y, 0, game_data.pixel_size * SCREEN_ZOOM, SCREEN_ZOOM)
						end
					end
				end
			end

			-- draw level's actors
			love.graphics.setColor(1, 1, 1)

			for i = 1, #game_data.levels[current_level].actors do
				local actor = game_data.levels[current_level].actors[i].number
				local sprite = GetActorSprite(actor, "idle", 1)

				local x = (game_data.levels[current_level].actors[i].start_x + (current_level_scroll_x * game_data.block_width)) * game_data.pixel_size * SCREEN_ZOOM
				local y = (game_data.levels[current_level].actors[i].start_y + (current_level_scroll_y * game_data.block_height)) * SCREEN_ZOOM
				local real_x = pos_x + x
				local real_y = pos_y + y
				
				if #img_sprites > 0 then
					if current_level_actors_edit_mode == false then
						-- draw all actors
						love.graphics.draw(img_sprites[sprite], real_x, real_y, 0, game_data.pixel_size * SCREEN_ZOOM, SCREEN_ZOOM)
					elseif current_level_actors_edit_mode == true then
						-- editing actor instance i
						if i == current_level_edited_actor_instance then
							if blink_timer < MID_BLINK_TIME then
								love.graphics.draw(img_sprites[sprite], real_x, real_y, 0, game_data.pixel_size * SCREEN_ZOOM, SCREEN_ZOOM)
							end
						else
							love.graphics.draw(img_sprites[sprite], real_x, real_y, 0, game_data.pixel_size * SCREEN_ZOOM, SCREEN_ZOOM)
						end
					end
					

				end
			end

			-- disable scissor
			love.graphics.setScissor()
			
			-- print the scroll values
			love.graphics.setColor(0, 1, 1)
			love.graphics.print("ScrollX = " .. tostring(math.abs(current_level_scroll_x)) .. " ScrollY = " .. tostring(math.abs(current_level_scroll_y)), 210, 420)

			-- print current block or current actor
			if current_level_mode == LEVEL_MODE_BLOCKS then
				love.graphics.print("Block " .. tostring(current_level_selected_block), 620, 240)
				
				if #img_blocks > 0 then
					love.graphics.setColor(1, 1, 1)
					love.graphics.draw(img_blocks[current_level_selected_block], 680, 280, 0, game_data.pixel_size * SCREEN_ZOOM, SCREEN_ZOOM)

					ShowCursor(680, 280, game_data.block_width * game_data.pixel_size * SCREEN_ZOOM, game_data.block_height * SCREEN_ZOOM, 1, 1, 1)
				end
			elseif current_level_mode == LEVEL_MODE_ACTORS then
				love.graphics.print("Actor " .. tostring(current_level_selected_actor), 620, 240)
				
				if #img_sprites > 0 then
					local sprite = GetActorSprite(current_level_selected_actor, "idle", 1)
					
					if sprite > 0 then
						love.graphics.setColor(1, 1, 1)
						love.graphics.draw(img_sprites[sprite], 660, 280, 0, game_data.pixel_size * SCREEN_ZOOM, SCREEN_ZOOM)

						ShowCursor(660, 280, game_data.sprite_width * game_data.pixel_size * SCREEN_ZOOM, game_data.sprite_height * SCREEN_ZOOM, 1, 1, 1)
					end
				end
			end
		else
			love.graphics.print("No levels!", 320, 80)
		end

		-- draw shortcuts
		love.graphics.setColor(0, 1, 1)
		love.graphics.print("[A]dd a level - [D]elete level", 10, 460)
		love.graphics.print("[W]idth - [H]eight - [L][Shift] Set level", 10, 480)
		love.graphics.print("[Tab] Set block/actor - [S]wap blocks/actors", 10, 500)
		love.graphics.print("[M]emorize scrolling - [R]emember scrolling", 10, 520)
		love.graphics.print("[F]ill blocks - [E]dit actor - [Del] actor", 10, 540)
		love.graphics.print("[Esc] Back", 10, 560)
	elseif mode == MODE_EDIT_GAMES_DATA then
	end
end

function love.textinput(t)
	if mode == MODE_NEW_PROJECT then
		if new_project_mode == NEW_PROJECT_MODE then
			old_project_name = project_name
			project_name = ""
			new_project_mode = NEW_PROJECT_MODE_INPUT
		elseif new_project_mode == NEW_PROJECT_MODE_INPUT then
			if (t >= "A" and t <= "Z") or (t >= "a" and t <= "z") or (t >= "0" and t <= "9") or t == "_" or t == "-" then
				if #project_name < 16 then
					project_name = project_name .. t
				else
					beep:stop()
					beep:play()
				end
			else
				beep:stop()
				beep:play()
			end
		end
	end
end

function love.keypressed(key)
	if mode == MODE_MENU then
		if key == "a" then
			mode = MODE_NEW_PROJECT
		elseif key == "b" then
			mode = MODE_LOAD_PROJECT
		elseif key == "c" then
			if project_name ~= "" then
				SaveGame(project_name, "game.txt", game_data)
				text_message = "Project saved! Press [RETURN]"
				mode = MODE_SAVE_PROJECT
			else
				beep:stop()
				beep:play()
			end
		elseif key == "d" then
			if project_name ~= "" then
				mode = MODE_EXPORT_EXECUTABLE_GAME
			else
				beep:stop()
				beep:play()
			end
		elseif key == "e" then
			if project_name ~= "" then
				-- set game window size
				WINDOW_WIDTH = game_data.screen_width * game_data.pixel_size * WINDOW_ZOOM
				WINDOW_HEIGHT = game_data.screen_height * WINDOW_ZOOM
	
				WINDOW_BORDER = math.floor(WINDOW_WIDTH / 8)
				if not game_data.border then WINDOW_BORDER = 0 end
	
				love.window.setMode(WINDOW_WIDTH + (WINDOW_BORDER * 2), WINDOW_HEIGHT + (WINDOW_BORDER * 2), {fullscreen = false, resizable = true, vsync = 1})
				
				-- set window title
				love.window.setTitle("Game test")
	
					-- load fonts
				GAME_TITLE_FONT = love.graphics.newFont("fonts/" .. game_data.fonts, GAME_TITLE_FONT_SIZE * FONT_DOWN_SCALE)
				GAME_FONT = love.graphics.newFont("fonts/" .. game_data.fonts, GAME_FONT_SIZE * FONT_DOWN_SCALE)
				
				-- set fonts filter
				GAME_TITLE_FONT:setFilter("nearest", "nearest")
				GAME_FONT:setFilter("nearest", "nearest")

				-- reset actors positions
				for i = 1, #game_data.levels do
					for j = 1, #game_data.levels[i].actors do
						game_data.levels[i].actors[j].x = game_data.levels[i].actors[j].start_x
						game_data.levels[i].actors[j].y = game_data.levels[i].actors[j].start_y
						game_data.levels[i].actors[j].animation = GetActorAnimationNumber(game_data.levels[i].actors[j].number, "idle")
						game_data.levels[i].actors[j].frame = 1
					end
				end
				
				-- initialize the game
				run.load()

				mode = MODE_TEST_GAME
			else
				beep:stop()
				beep:play()
			end
		elseif key == "f" then
			if project_name ~= "" then
				if game_data.editable_palette == true then
					maxx = ((game_data.max_pens - 1) % 16) + 1
					maxy = math.floor(game_data.max_pens / 16)
	
					mode = MODE_EDIT_PALETTE
				else
					beep:stop()
					beep:play()
				end
			else
				beep:stop()
				beep:play()
			end
		elseif key == "g" then
			if project_name ~= "" then
				-- load fonts
				GAME_TITLE_FONT = love.graphics.newFont("fonts/" .. game_data.fonts, GAME_TITLE_FONT_SIZE * FONT_DOWN_SCALE)
				GAME_FONT = love.graphics.newFont("fonts/" .. game_data.fonts, GAME_FONT_SIZE * FONT_DOWN_SCALE)
		
				-- set fonts filter
				GAME_TITLE_FONT:setFilter("nearest", "nearest")
				GAME_FONT:setFilter("nearest", "nearest")
				
				-- initialize player's data
				run.vars.score = 0
				game_data.vars.lives = 3
				run.vars.level = 1
	
				mode = MODE_EDIT_SCREEN
			else
				beep:stop()
				beep:play()
			end			
		elseif key == "h" then
			if project_name ~= "" then
				mode = MODE_EDIT_BLOCKS
			else
				beep:stop()
				beep:play()
			end			
		elseif key == "i" then
			if project_name ~= "" then
				mode = MODE_EDIT_SPRITES
			else
				beep:stop()
				beep:play()
			end			
		elseif key == "j" then
			if project_name ~= "" then
				if current_animation > 0 then
					animation_playing = true
					animation_frame = 1
					animation_timer = 0.0
				end
				
				mode = MODE_EDIT_ANIMATIONS
			else
				beep:stop()
				beep:play()
			end			
		elseif key == "k" then
			if project_name ~= "" then
				current_property = 1
				
				mode = MODE_EDIT_ACTORS
			else
				beep:stop()
				beep:play()
			end			
		elseif key == "l" then
			if project_name ~= "" then
				mode = MODE_EDIT_LEVELS
			else
				beep:stop()
				beep:play()
			end			
		elseif key == "m" then
			if project_name ~= "" then
				mode = MODE_EDIT_GAMES_DATA
			else
				beep:stop()
				beep:play()
			end			
		elseif key == "n" then
			if project_name ~= "" then
				mode = MODE_IMPORT_SOUNDS
			else
				beep:stop()
				beep:play()
			end			
		elseif key == "o" then
			if project_name ~= "" then
				mode = MODE_IMPORT_MUSICS
			else
				beep:stop()
				beep:play()
			end			
		elseif key == "p" then
			if project_name ~= "" then
				mode = MODE_IMPORT_IMAGES
			else
				beep:stop()
				beep:play()
			end			
		elseif key == "q" then
			love.event.quit(0)
		end
	elseif mode == MODE_NEW_PROJECT then
		if new_project_mode == NEW_PROJECT_MODE_INPUT then
			if key == "backspace" then
				if #project_name > 0 then
					project_name = string.sub(project_name, 1, #project_name - 1)
				end
			elseif key == "return" then
				if #project_name > 0 then
					new_project_mode = NEW_PROJECT_MODE_CHOOSE_PRESET
				end
			elseif key == "escape" then
				project_name = old_project_name
				new_project_mode = NEW_PROJECT_MODE
				mode = MODE_MENU
			end
		elseif new_project_mode == NEW_PROJECT_MODE_CHOOSE_PRESET then
			for i = 1, #presets do
				if key == string.char(96 + i) then
					selected_preset = i
	
					LoadPreset("presets/" .. presets[selected_preset] .. ".txt")
					
					-- update level's data
					UpdateLevelsData()
					
					-- set default game data
					SetDefaultGameData()
					
					new_project_mode = NEW_PROJECT_MODE
					mode = MODE_MENU
				end
			end

			if key == "escape" then
				project_name = old_project_name
				new_project_mode = NEW_PROJECT_MODE
				mode = MODE_MENU
			end
		end
	elseif mode == MODE_LOAD_PROJECT then
		if key == "tab" then
			if file_number < #file_list then
				file_number = file_number + 1
			else
				file_number = 1
			end
			
			project_name = file_list[file_number]
		end
		
		if key == "return" then
			if project_name ~= "" then
				file_number = 0
				file_list = {}
				
				ResetAll()
				
				game_data = LoadGame(project_name, "game.txt", game_data)
				
				ConvertBlocksToImages()
				ConvertSpritesToImages()

				mode = MODE_MENU
			end
		end

		if key == "escape" then
			file_number = 0
			file_list = {}
			project_name = old_project_name
			mode = MODE_MENU
		end
	elseif mode == MODE_SAVE_PROJECT then
		if key == "return" then
			mode = MODE_MENU
		end
	elseif mode == MODE_EXPORT_EXECUTABLE_GAME then
	elseif mode == MODE_TEST_GAME then
		if key == "escape" then
			-- set editor window size
			love.window.setMode(EDITOR_WINDOW_WIDTH, EDITOR_WINDOW_HEIGHT, {fullscreen = false, resizable = false, vsync = 1})
			
			-- set window title
			love.window.setTitle(EDITOR_WINDOW_TITLE)

			mode = MODE_MENU
		end		
	elseif mode == MODE_EDIT_PALETTE then
		if key == "left" then
			-- select left color
			if selected_color > 0 then
				selected_color = selected_color - 1
			end
		elseif key == "right" then
			-- select right color
			if selected_color < game_data.max_pens - 1 then
				selected_color = selected_color + 1
			end
		elseif key == "up" then
			-- increase color in the full palette
			ChangePensInk(selected_color, 1)
		elseif key == "down" then
			-- decrease color in the full palette
			ChangePensInk(selected_color, -1)
		elseif key == "escape" then
			mode = MODE_MENU
		end
	elseif mode == MODE_EDIT_SCREEN then
		-- change area to edit
		if key == "tab" then
			if love.keyboard.isDown("lshift") then
				if area_selected == GAME_AREA then
					area_selected = LEVEL_AREA
				else
					area_selected = area_selected - 1
				end
			else
				if area_selected == LEVEL_AREA then
					area_selected = GAME_AREA
				else
					area_selected = area_selected + 1
				end
			end
		end
		
		if key == "f1" then
			if game_data.background_paper == game_data.max_pens - 1 then
				game_data.background_paper = 0
			else
				game_data.background_paper = game_data.background_paper + 1
			end
		end

		if key == "f2" then
			if game_data.game_paper == game_data.max_pens - 1 then
				game_data.game_paper = 0
			else
				game_data.game_paper = game_data.game_paper + 1
			end
		end

		if key == "f3" then
			if game_data.text_paper == game_data.max_pens - 1 then
				game_data.text_paper = 0
			else
				game_data.text_paper = game_data.text_paper + 1
			end
		end

		if key == "f4" then
			if game_data.text_pen == game_data.max_pens - 1 then
				game_data.text_pen = 0
			else
				game_data.text_pen = game_data.text_pen + 1
			end
		end

		if key == "f5" then
			if game_data.border_paper == game_data.max_pens - 1 then
				game_data.border_paper = 0
			else
				game_data.border_paper = game_data.border_paper + 1
			end
		end

		if key == "escape" then
			mode = MODE_MENU
		end
	elseif mode == MODE_EDIT_BLOCKS then
		if key == "a" then
			-- add a new block
			if #game_data.blocks < game_data.max_blocks then
				local t = {}
				
				for x = 0, game_data.block_width - 1 do
					t[x] = {}
					
					for y = 0, game_data.block_height - 1 do
						t[x][y] = 0
					end
				end
				
				-- add void block
				table.insert(game_data.blocks, t)
				
				-- add block data
				table.insert(game_data.blocks_data, {type = blocks_types[1]})
				
				current_block = current_block + 1
			end
		elseif key == "c" then
			-- copy current block
			if current_block > 0 then
				block_copy = {}
				
				for x = 0, game_data.block_width - 1 do
					block_copy[x] = {}
					
					for y = 0, game_data.block_height - 1 do
						block_copy[x][y] = game_data.blocks[current_block][x][y]
					end
				end
				
				-- copy current block data
				block_data_copy = {}
				
				block_data_copy.type = game_data.blocks_data[current_block].type
			end
		elseif key == "p" then
			-- paste to current block
			if current_block > 0 then
				for x = 0, game_data.block_width - 1 do
					for y = 0, game_data.block_height - 1 do
						game_data.blocks[current_block][x][y] = block_copy[x][y]
					end
				end

				game_data.blocks_data[current_block].type = block_data_copy.type
			end
		elseif key == "d" then
			-- delete current block
			if current_block > 0 then
				table.remove(game_data.blocks, current_block)
				table.remove(game_data.blocks_data, current_block)
				current_block = #game_data.blocks
			end
		elseif key == "pagedown" then
			-- edit previous block
			if current_block > 1 then
				current_block = current_block - 1
			elseif current_block == 1 then
				current_block = #game_data.blocks
			end
		elseif key == "pageup" then
			-- edit next block
			if current_block < #game_data.blocks then
				current_block = current_block + 1
			elseif current_block == #game_data.blocks then
				current_block = 1
			end
		elseif key == "tab" then
			if love.keyboard.isDown("lshift") then
				if pen_color == 0 then
					pen_color = game_data.max_pens - 1
				else
					pen_color = pen_color - 1
				end
			else
				if pen_color == game_data.max_pens - 1 then
					pen_color = 0
				else
					pen_color = pen_color + 1
				end
			end		
		elseif key == "t" then
			if current_block > 0 then
				local tp = 0
				
				for i = 1, #blocks_types do
					if game_data.blocks_data[current_block].type == blocks_types[i] then
						tp = i
						break
					end
				end
				
				if tp > 0 then
					if tp < #blocks_types then
						tp = tp + 1
					else
						tp = 1
					end
					
					game_data.blocks_data[current_block].type = blocks_types[tp]
				end
			end
		elseif key == "f" then
			if current_block > 0 then
				if block_x >= 0 and block_x < game_data.block_width then
					if block_y >= 0 and block_y < game_data.block_height then
						FloodFill(game_data.blocks[current_block], game_data.block_width, game_data.block_height, block_x, block_y, pen_color, game_data.blocks[current_block][block_x][block_y])
						block_too_many_color = TooManyColorsInBlock(game_data.blocks[current_block])
					end
				end
			end
		elseif key == "escape" then
			ConvertBlocksToImages()

			mode = MODE_MENU
		end
	elseif mode == MODE_EDIT_SPRITES then
		if key == "a" then
			-- add a new sprite
			if #game_data.sprites < game_data.max_sprites then
				local t = {}
				
				for x = 0, game_data.sprite_width - 1 do
					t[x] = {}
					
					for y = 0, game_data.sprite_height - 1 do
						t[x][y] = 0
					end
				end
				
				table.insert(game_data.sprites, t)
				
				current_sprite = current_sprite + 1
			end
		elseif key == "c" then
			-- copy current sprite
			if current_sprite > 0 then
				sprite_copy = {}
				
				for x = 0, game_data.sprite_width - 1 do
					sprite_copy[x] = {}
					
					for y = 0, game_data.sprite_height - 1 do
						sprite_copy[x][y] = game_data.sprites[current_sprite][x][y]
					end
				end
			end
		elseif key == "p" then
			-- paste to current sprite
			if current_sprite > 0 then
				for x = 0, game_data.sprite_width - 1 do
					for y = 0, game_data.sprite_height - 1 do
						game_data.sprites[current_sprite][x][y] = sprite_copy[x][y]
					end
				end
			end
		elseif key == "d" then
			-- delete current sprite
			if current_sprite > 0 then
				table.remove(game_data.sprites, current_sprite)
				current_sprite = #game_data.sprites
			end
		elseif key == "pagedown" then
			-- edit previous sprite
			if current_sprite > 1 then
				current_sprite = current_sprite - 1
			elseif current_sprite == 1 then
				current_sprite = #game_data.sprites
			end
		elseif key == "pageup" then
			-- edit next sprite
			if current_sprite < #game_data.sprites then
				current_sprite = current_sprite + 1
			elseif current_sprite == #game_data.sprites then
				current_sprite = 1
			end
		elseif key == "tab" then
			if love.keyboard.isDown("lshift") then
				if pen_color == 0 then
					pen_color = game_data.max_pens - 1
				else
					pen_color = pen_color - 1
				end
			else
				if pen_color == game_data.max_pens - 1 then
					pen_color = 0
				else
					pen_color = pen_color + 1
				end
			end		
		elseif key == "f" then
			if current_sprite > 0 then
				FloodFill(game_data.sprites[current_sprite], game_data.sprite_width, game_data.sprite_height, sprite_x, sprite_y, pen_color, game_data.sprites[current_sprite][sprite_x][sprite_y])
				sprite_too_many_color = TooManyColorsInSprite(game_data.sprites[current_sprite])
			end
		elseif key == "escape" then
			ConvertSpritesToImages()
			
			mode = MODE_MENU
		end
	elseif mode == MODE_EDIT_ANIMATIONS then
		if key == "a" then
			-- add a new animation
			if #game_data.animations < game_data.max_animations then
				table.insert(game_data.animations, {1})
				table.insert(game_data.animations_loop, {loop = false, v1 = 0, v2 = 0})
				
				current_animation = current_animation + 1
				current_frame = 1
			end			
		elseif key == "c" then
			-- copy current frame
			if current_animation > 0 then
				frame_copy = game_data.animations[current_animation][current_frame]
			end
		elseif key == "p" then
			-- paste current frame
			if current_animation > 0 then
				game_data.animations[current_animation][current_frame] = frame_copy
			end
		elseif key == "d" then
			-- delete current animation
			if current_animation > 0 then
				table.remove(game_data.animations, current_animation)
				table.remove(game_data.animations_loop, current_animation)
				current_animation = #game_data.animations
			end
		elseif key == "f" then
			if current_animation > 0 then
				if #game_data.animations[current_animation] < MAX_FRAMES_BY_ANIMATION then
					table.insert(game_data.animations[current_animation], 1)
				end
			end
		elseif key == "backspace" then
			if current_animation > 0 then
				if #game_data.animations[current_animation] > 1 then
					table.remove(game_data.animations[current_animation], #game_data.animations[current_animation])
					current_frame = #game_data.animations[current_animation]
				end
			end
		elseif key == "l" then
			if current_animation > 0 then
				if game_data.animations_loop[current_animation].loop == false then
					game_data.animations_loop[current_animation].loop = true
					game_data.animations_loop[current_animation].v1 = 1
					game_data.animations_loop[current_animation].v2 = #game_data.animations[current_animation]
					animation_playing = true
					animation_frame = 1
					animation_timer = 0.0
				else
					game_data.animations_loop[current_animation].loop = false
					game_data.animations_loop[current_animation].v1 = 0
					game_data.animations_loop[current_animation].v2 = 0
				end
			end
		elseif key == "f1" then
			if current_animation > 0 then
				if game_data.animations_loop[current_animation].loop == true then
					if game_data.animations_loop[current_animation].v1 == #game_data.animations[current_animation] then
						game_data.animations_loop[current_animation].v1 = 1
					else
						game_data.animations_loop[current_animation].v1 = game_data.animations_loop[current_animation].v1 + 1
					end
					
					if game_data.animations_loop[current_animation].v2 < game_data.animations_loop[current_animation].v1 then
						game_data.animations_loop[current_animation].v2 = game_data.animations_loop[current_animation].v1
					end
				end
			end
		elseif key == "f2" then
			if current_animation > 0 then
				if game_data.animations_loop[current_animation].loop == true then
					if game_data.animations_loop[current_animation].v2 == #game_data.animations[current_animation] then
						game_data.animations_loop[current_animation].v2 = 1
					else
						game_data.animations_loop[current_animation].v2 = game_data.animations_loop[current_animation].v2 + 1
					end
					
					if game_data.animations_loop[current_animation].v2 < game_data.animations_loop[current_animation].v1 then
						game_data.animations_loop[current_animation].v2 = game_data.animations_loop[current_animation].v1
					end
				end
			end
		elseif key == "pagedown" then
			-- edit previous animation
			if current_animation > 1 then
				current_animation = current_animation - 1
			elseif current_animation == 1 then
				current_animation = #game_data.animations
			end			
		elseif key == "pageup" then
			-- edit next animation
			if current_animation < #game_data.animations then
				current_animation = current_animation + 1
			elseif current_animation == #game_data.animations then
				current_animation = 1
			end
		elseif key == "down" then
			if current_animation > 0 then
				if current_frame > 0 then
					if game_data.animations[current_animation][current_frame] > 1 then
						game_data.animations[current_animation][current_frame] = game_data.animations[current_animation][current_frame] - 1
					elseif game_data.animations[current_animation][current_frame] == 1 then
						game_data.animations[current_animation][current_frame] = game_data.max_animations
					end
				end
			end			
		elseif key == "up" then
			if current_animation > 0 then
				if current_frame > 0 then
					if game_data.animations[current_animation][current_frame] < game_data.max_animations then
						game_data.animations[current_animation][current_frame] = game_data.animations[current_animation][current_frame] + 1
					else
						game_data.animations[current_animation][current_frame] = 1
					end					
				end
			end
		elseif key == "left" then
			if current_animation > 0 then
				if current_frame > 1 then
					current_frame = current_frame - 1
				elseif current_frame == 1 then
					current_frame = #game_data.animations[current_animation]
				end
			end
		elseif key == "right" then
			if current_animation > 0 then
				if current_frame < #game_data.animations[current_animation] then
					current_frame = current_frame + 1
				elseif current_frame == #game_data.animations[current_animation] then
					current_frame = 1
				end
			end			
		elseif key == "space" then
			if current_animation > 0 then
				animation_playing = true
				animation_frame = 1
				animation_timer = 0.0
			end
		elseif key == "escape" then
			mode = MODE_MENU
		end
	elseif mode == MODE_EDIT_ACTORS then
		if key == "a" then
			-- add a new actor
			if #game_data.actors < game_data.max_actors then
				if current_actor == 0 then
					current_entity_type = ENTITY_TYPE_PLAYER
					current_player_type = 1
					
					table.insert(game_data.actors, {entity = current_entity_type, type = player_types[current_player_type]})
				else
					current_entity_type = ENTITY_TYPE_ENEMY
					current_enemy_type = 1
					
					table.insert(game_data.actors, {entity = current_entity_type, type = enemy_types[current_enemy_type]})
				end

				current_actor = current_actor + 1
				current_property = 1
			end			

		elseif key == "d" then
			-- delete selected actor
			if current_actor > 0 then
				table.remove(game_data.actors, current_actor)
				current_actor = #game_data.actors
				
				if current_actor == 0 then
					current_entity_type = 0
					current_player_type = 0
					current_enemy_type = 0
					current_bonus_type = 0
					current_property = 0
				else
					current_entity_type = game_data.actors[current_actor].entity
					
					-- update type for current actor
					if current_entity_type == ENTITY_TYPE_PLAYER then
						if current_player_type == 0 then current_player_type = 1 end
					elseif current_entity_type == ENTITY_TYPE_ENEMY then
						if current_enemy_type == 0 then current_enemy_type = 1 end
					elseif current_entity_type == ENTITY_TYPE_BONUS then
						if current_bonus_type == 0 then current_bonus_type = 1 end
					end
				end
			end
		elseif key == "tab" then
			-- change entity type
			if current_actor > 1 then
				if current_entity_type < #entity_types then
					current_entity_type = current_entity_type + 1
				else
					current_entity_type = ENTITY_TYPE_ENEMY
				end

				game_data.actors[current_actor].entity = current_entity_type				

				-- remove type
				game_data.actors[current_actor].type = {}
				
				-- update type for current actor
				if current_entity_type == ENTITY_TYPE_PLAYER then
					if current_player_type == 0 then current_player_type = 1 end
					game_data.actors[current_actor].type = player_types[current_player_type]
				elseif current_entity_type == ENTITY_TYPE_ENEMY then
					if current_enemy_type == 0 then current_enemy_type = 1 end
					game_data.actors[current_actor].type = enemy_types[current_enemy_type]
				elseif current_entity_type == ENTITY_TYPE_BONUS then
					if current_bonus_type == 0 then current_bonus_type = 1 end
					game_data.actors[current_actor].type = bonus_types[current_bonus_type]
				end
			end
		elseif key == "t" then
			if current_actor > 0 then
				if current_entity_type == ENTITY_TYPE_PLAYER then
					if current_player_type < #player_types then
						current_player_type = current_player_type + 1
					elseif current_player_type == #player_types then
						current_player_type = 1
					end
				elseif current_entity_type == ENTITY_TYPE_ENEMY then
					if current_enemy_type < #enemy_types then
						current_enemy_type = current_enemy_type + 1
					elseif current_enemy_type == #enemy_types then
						current_enemy_type = 1
					end
				elseif current_entity_type == ENTITY_TYPE_BONUS then
					if current_bonus_type < #bonus_types then
						current_bonus_type = current_bonus_type + 1
					elseif current_bonus_type == #bonus_types then
						current_bonus_type = 1
					end
				end
				
				game_data.actors[current_actor].type = {}
				
				if current_entity_type == ENTITY_TYPE_PLAYER then
					game_data.actors[current_actor].type = player_types[current_player_type]
				elseif current_entity_type == ENTITY_TYPE_ENEMY then
					game_data.actors[current_actor].type = enemy_types[current_enemy_type]
				elseif current_entity_type == ENTITY_TYPE_BONUS then
					game_data.actors[current_actor].type = bonus_types[current_bonus_type]
				end
			end
		elseif key == "up" then
			if current_actor > 0 then
				if current_entity_type == ENTITY_TYPE_PLAYER then
					if current_property > 1 then
						current_property = current_property - 1
					elseif current_property == 1 then
						current_property = #player_animations[current_player_type]
					end
				elseif current_entity_type == ENTITY_TYPE_ENEMY then
					if current_property > 1 then
						current_property = current_property - 1
					elseif current_property == 1 then
						current_property = #enemy_animations[current_enemy_type]
					end
				elseif current_entity_type == ENTITY_TYPE_BONUS then
					if current_property > 1 then
						current_property = current_property - 1
					elseif current_property == 1 then
						current_property = #bonus_animations[current_bonus_type]
					end
					current_property = 1
				end
			end
		elseif key == "down" then
			if current_actor > 0 then
				if current_entity_type == ENTITY_TYPE_PLAYER then
					if current_property < #player_animations[current_player_type] then
						current_property = current_property + 1
					elseif current_property == #player_animations[current_player_type] then
						current_property = 1
					end
				elseif current_entity_type == ENTITY_TYPE_ENEMY then
					if current_property < #enemy_animations[current_enemy_type] then
						current_property = current_property + 1
					elseif current_property == #enemy_animations[current_enemy_type] then
						current_property = 1
					end
				elseif current_entity_type == ENTITY_TYPE_BONUS then
					if current_property < #bonus_animations[current_bonus_type] then
						current_property = current_property + 1
					elseif current_property == #bonus_animations[current_bonus_type] then
						current_property = 1
					end
					current_property = 1
				end
			end
		elseif key == "left" then
			if current_actor > 0 then
				if current_entity_type == ENTITY_TYPE_PLAYER then
					if player_animations[current_player_type][current_property] == "hflip" then
						game_data.actors[current_actor].type.hflip = not game_data.actors[current_actor].type.hflip
					elseif player_animations[current_player_type][current_property] == "directions" then
						if game_data.actors[current_actor].type.directions == 8 then
							game_data.actors[current_actor].type.directions = 4
						else
							game_data.actors[current_actor].type.directions = 8
						end
					elseif game_data.actors[current_actor].type[player_animations[current_player_type][current_property]] > 0 then
						game_data.actors[current_actor].type[player_animations[current_player_type][current_property]] = game_data.actors[current_actor].type[player_animations[current_player_type][current_property]] - 1
					elseif game_data.actors[current_actor].type[player_animations[current_player_type][current_property]] == 0 then
						game_data.actors[current_actor].type[player_animations[current_player_type][current_property]] = game_data.max_animations
					end
				elseif current_entity_type == ENTITY_TYPE_ENEMY then
					if game_data.actors[current_actor].type[enemy_animations[current_enemy_type][current_property]] > 0 then
						game_data.actors[current_actor].type[enemy_animations[current_enemy_type][current_property]] = game_data.actors[current_actor].type[enemy_animations[current_enemy_type][current_property]] - 1
					elseif game_data.actors[current_actor].type[enemy_animations[current_enemy_type][current_property]] == 0 then
						game_data.actors[current_actor].type[enemy_animations[current_enemy_type][current_property]] = game_data.max_animations
					end
				elseif current_entity_type == ENTITY_TYPE_BONUS then
					if bonus_animations[current_bonus_type][current_property] == "bonus" then
						if love.keyboard.isDown("lshift") == true then
							game_data.actors[current_actor].type.bonus = game_data.actors[current_actor].type.bonus - 10
						else
							game_data.actors[current_actor].type.bonus = game_data.actors[current_actor].type.bonus - 1
						end
					elseif game_data.actors[current_actor].type[bonus_animations[current_bonus_type][current_property]] > 0 then
						game_data.actors[current_actor].type[bonus_animations[current_bonus_type][current_property]] = game_data.actors[current_actor].type[bonus_animations[current_bonus_type][current_property]] - 1
					elseif game_data.actors[current_actor].type[bonus_animations[current_bonus_type][current_property]] == 0 then
						game_data.actors[current_actor].type[bonus_animations[current_bonus_type][current_property]] = game_data.max_animations
					end
				end
			end
		elseif key == "right" then
			if current_actor > 0 then
				if current_entity_type == ENTITY_TYPE_PLAYER then
					if player_animations[current_player_type][current_property] == "hflip" then
						game_data.actors[current_actor].type.hflip = not game_data.actors[current_actor].type.hflip
					elseif player_animations[current_player_type][current_property] == "directions" then
						if game_data.actors[current_actor].type.directions == 8 then
							game_data.actors[current_actor].type.directions = 4
						else
							game_data.actors[current_actor].type.directions = 8
						end
					elseif game_data.actors[current_actor].type[player_animations[current_player_type][current_property]] < game_data.max_animations then
						game_data.actors[current_actor].type[player_animations[current_player_type][current_property]] = game_data.actors[current_actor].type[player_animations[current_player_type][current_property]] + 1
					elseif game_data.actors[current_actor].type[player_animations[current_player_type][current_property]] == game_data.max_animations then
						game_data.actors[current_actor].type[player_animations[current_player_type][current_property]] = 0
					end
				elseif current_entity_type == ENTITY_TYPE_ENEMY then
					if game_data.actors[current_actor].type[enemy_animations[current_enemy_type][current_property]] < game_data.max_animations then
						game_data.actors[current_actor].type[enemy_animations[current_enemy_type][current_property]] = game_data.actors[current_actor].type[enemy_animations[current_enemy_type][current_property]] + 1
					elseif game_data.actors[current_actor].type[enemy_animations[current_enemy_type][current_property]] == game_data.max_animations then
						game_data.actors[current_actor].type[enemy_animations[current_enemy_type][current_property]] = 0
					end
				elseif current_entity_type == ENTITY_TYPE_BONUS then
					if bonus_animations[current_bonus_type][current_property] == "bonus" then
						if love.keyboard.isDown("lshift") == true then
							game_data.actors[current_actor].type.bonus = game_data.actors[current_actor].type.bonus + 10
						else
							game_data.actors[current_actor].type.bonus = game_data.actors[current_actor].type.bonus + 1
						end
					elseif game_data.actors[current_actor].type[bonus_animations[current_bonus_type][current_property]] < game_data.max_animations then
						game_data.actors[current_actor].type[bonus_animations[current_bonus_type][current_property]] = game_data.actors[current_actor].type[bonus_animations[current_bonus_type][current_property]] + 1
					elseif game_data.actors[current_actor].type[bonus_animations[current_bonus_type][current_property]] == game_data.max_animations then
						game_data.actors[current_actor].type[bonus_animations[current_bonus_type][current_property]] = 0
					end
				end
			end
		elseif key == "pagedown" then
			-- edit previous actor
			if current_actor > 0 then
				if current_actor > 1 then
					current_actor = current_actor - 1
				elseif current_actor == 1 then
					current_actor = #game_data.actors
				end
				
				current_entity_type = game_data.actors[current_actor].entity

				FindCurrentEntityType(game_data)
			end
		elseif key == "pageup" then
			-- edit next actor
			if current_actor > 0 then
				if current_actor < #game_data.actors then
					current_actor = current_actor + 1
				elseif current_actor == #game_data.actors then
					current_actor = 1
				end
				
				current_entity_type = game_data.actors[current_actor].entity

				FindCurrentEntityType(game_data)
			end
		elseif key == "escape" then
			mode = MODE_MENU
		end
	elseif mode == MODE_EDIT_LEVELS then
		-- choose the level to edit
		if #game_data.actors > 0 then
			if key == "a" then
				-- add a new level
				if #game_data.levels < game_data.max_levels then
					-- disable edit mode
					current_level_actors_edit_mode = false
					
					if current_level == 0 then
						game_data.levels_data = {
							w = 1,
							h = 1,
							sw = math.floor(game_data.areas[GAME_AREA].width / game_data.block_width),
							sh = math.floor(game_data.areas[GAME_AREA].height / game_data.block_height)
						}
					end

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
					table.insert(t.actors, {number = 1, start_x = 0, start_y = 0, x = 0, y = 0, animation = 0, frame = 0})

					-- add new void level
					table.insert(game_data.levels, t)

					current_level = current_level + 1
					
					game_data.scrolling_start_x[current_level] = 0
					game_data.scrolling_start_y[current_level] = 0
					
					if current_level_selected_block == 0 then
						current_level_selected_block = 1
					end					

					if current_level_selected_actor == 0 then
						current_level_selected_actor = 1
					end					
				end
			end
			
			if key == "d" then
				-- delete current level
				if current_level > 0 then
					-- disable edit mode
					current_level_actors_edit_mode = false

					table.remove(game_data.scrolling_start_x, current_level)
					table.remove(game_data.scrolling_start_y, current_level)
					table.remove(game_data.levels, current_level)
					
					current_level = #game_data.levels
					
				end
			end
			
			if key == "l" then
				-- change level to edit
				if current_level > 0 then
					-- disable edit mode
					current_level_actors_edit_mode = false
					
					if love.keyboard.isDown("lshift") then
						if current_level > 1 then
							current_level = current_level - 1
						else
							current_level = #game_data.levels
						end
					else
						if current_level < #game_data.levels then
							current_level = current_level + 1
						elseif current_level == #game_data.levels then
							current_level = 1
						end
					end
				end
			end

			if key == "w" then
				-- change width of the level, if possible, in screens
				if current_level > 0 then
					-- disable edit mode
					current_level_actors_edit_mode = false

					local player_type = 0
					
					for i = 1, #player_types do
						if game_data.actors[1].type.name == player_types[i].name then
							player_type = i
							break
						end
					end

					if game_data.levels_data.w < player_levels_max_size[player_type].w then
						game_data.levels_data.w = game_data.levels_data.w * 2
					elseif game_data.levels_data.w == player_levels_max_size[player_type].w then
						game_data.levels_data.w = 1
					end
					
					-- resize level
					game_data.levels[current_level].blocks = {}
					
					-- fill void level
					for x = 0, (game_data.levels_data.sw * game_data.levels_data.w) - 1 do
						game_data.levels[current_level].blocks[x] = {}
						
						for y = 0, (game_data.levels_data.sh * game_data.levels_data.h) - 1 do
							game_data.levels[current_level].blocks[x][y] = 0
						end
					end
				end
			end

			if key == "h" then
				-- change height of the level, if possible, in screens
				if current_level > 0 then
					-- disable edit mode
					current_level_actors_edit_mode = false

					local player_type = 0
					
					for i = 1, #player_types do
						if game_data.actors[1].type.name == player_types[i].name then
							player_type = i
							break
						end
					end

					if game_data.levels_data.h < player_levels_max_size[player_type].h then
						game_data.levels_data.h = game_data.levels_data.h * 2
					elseif game_data.levels_data.h == player_levels_max_size[player_type].h then
						game_data.levels_data.h = 1
					end
					
					-- resize level
					game_data.levels[current_level].blocks = {}
					
					-- fill void level
					for x = 0, (game_data.levels_data.sw * game_data.levels_data.w) - 1 do
						game_data.levels[current_level].blocks[x] = {}
						
						for y = 0, (game_data.levels_data.sh * game_data.levels_data.h) - 1 do
							game_data.levels[current_level].blocks[x][y] = 0
						end
					end
				end
			end
			
			-- swap between modes
			if key == "s" then
				-- disable edit mode
				current_level_actors_edit_mode = false

				if current_level_mode == LEVEL_MODE_BLOCKS then
					current_level_mode = LEVEL_MODE_ACTORS
				elseif current_level_mode == LEVEL_MODE_ACTORS then
					current_level_mode = LEVEL_MODE_BLOCKS
				end
			end
			
			-- change selected block/actor, or change edited actor instance
			if key == "tab" then
				if current_level_actors_edit_mode == false then
					if current_level_mode == LEVEL_MODE_BLOCKS then
						if current_level_selected_block > 0 then
							if love.keyboard.isDown("lshift") then
								if current_level_selected_block > 1 then
									current_level_selected_block = current_level_selected_block - 1
								elseif current_level_selected_block == 1 then
									current_level_selected_block = #game_data.blocks
								end
							else
								if current_level_selected_block < #game_data.blocks then
									current_level_selected_block = current_level_selected_block + 1
								elseif current_level_selected_block == #game_data.blocks then
									current_level_selected_block = 1
								end
							end
						end
					elseif current_level_mode == LEVEL_MODE_ACTORS then
						if current_level_selected_actor > 0 then
							if love.keyboard.isDown("lshift") then
								if current_level_selected_actor > 1 then
									current_level_selected_actor = current_level_selected_actor - 1
								elseif current_level_selected_actor == 1 then
									current_level_selected_actor = #game_data.actors
								end
							else
								if current_level_selected_actor < #game_data.actors then
									current_level_selected_actor = current_level_selected_actor + 1
								elseif current_level_selected_actor == #game_data.actors then
									current_level_selected_actor = 1
								end
							end
						end
					end
				elseif current_level_actors_edit_mode == true then
					if love.keyboard.isDown("lshift") then
						if current_level_edited_actor_instance > 1 then
							current_level_edited_actor_instance = current_level_edited_actor_instance - 1
						elseif current_level_edited_actor_instance == 1 then
							current_level_edited_actor_instance = #game_data.levels[current_level].actors
						end
					else
						if current_level_edited_actor_instance < #game_data.levels[current_level].actors then
							current_level_edited_actor_instance = current_level_edited_actor_instance + 1
						elseif current_level_edited_actor_instance == #game_data.levels[current_level].actors then
							current_level_edited_actor_instance = 1
						end
					end

					-- scroll the screen to show edited actor instance
					GetActorInstanceScrolling()
				end
			end

			if key == "m" then
				-- memorize scrolling for the level
				game_data.scrolling_start_x[current_level] = current_level_scroll_x
				game_data.scrolling_start_y[current_level] = current_level_scroll_y
			end

			if key == "r" then
				-- remember scrolling start position for the level
				current_level_scroll_x = game_data.scrolling_start_x[current_level]
				current_level_scroll_y = game_data.scrolling_start_y[current_level]
			end
			
			if key == "e" then
				-- set edit mode for actors
				current_level_actors_edit_mode = true
				current_level_edited_actor_instance = 1
				
				-- scroll the screen to show edited actor instance
				GetActorInstanceScrolling()
			end

			if key == "delete" then
				if current_level_actors_edit_mode == true then
					if current_level_edited_actor_instance > 1 then
						table.remove(game_data.levels[current_level].actors, current_level_edited_actor_instance)
						
						current_level_edited_actor_instance = current_level_edited_actor_instance - 1
						
						-- scroll the screen to show edited actor instance
						GetActorInstanceScrolling()
					elseif current_level_edited_actor_instance == 1 then
						beep:stop()
						beep:play()
					end
				end
			end
			
			if key == "f" then
				-- disable edit mode
				current_level_actors_edit_mode = false

				-- floodfill the level
				local mx = love.mouse.getX()
				local my = love.mouse.getY()

				local xc = 400 - (game_data.levels_data.sw * game_data.block_width * game_data.pixel_size * LEVELS_ZOOM / 2)
				local yc = 160
				
				local bx = math.floor((mx - xc) / (game_data.block_width * game_data.pixel_size * LEVELS_ZOOM))
				local by = math.floor((my - yc) / (game_data.block_height * LEVELS_ZOOM))
				
				bx = bx - current_level_scroll_x
				by = by - current_level_scroll_y
				
				local w = game_data.levels_data.sw * game_data.levels_data.w
				local h = game_data.levels_data.sh * game_data.levels_data.h

				FloodFill(game_data.levels[current_level].blocks, w, h, bx, by, current_level_selected_block, game_data.levels[current_level].blocks[bx][by])
			end
		elseif key ~= "escape" then
			beep:stop()
			beep:play()
		end
		
		if key == "escape" then
			if current_level_actors_edit_mode == false then
				mode = MODE_MENU
			elseif current_level_actors_edit_mode == true then
				current_level_actors_edit_mode = false
				current_level_edited_actor_instance = 0
			end
		end
	elseif mode == MODE_EDIT_GAMES_DATA then
	end
end

function love.mousepressed(x, y, button, istouch, presses)
	if mode == MODE_EDIT_LEVELS then
		-- position actors
		if button == 1 then
			if current_level_actors_edit_mode == false then
				if current_level_mode == LEVEL_MODE_ACTORS then
					if current_level_selected_actor == 1 then
						beep:stop()
						beep:play()
					else
						-- top left corner
						local xc = 400 - (game_data.levels_data.sw * game_data.block_width * game_data.pixel_size * LEVELS_ZOOM / 2)
						local yc = 160
						
						-- position = mouse - top-left corner - scrolling
						local x_pos = (x - xc - (current_level_scroll_x * game_data.block_width * game_data.pixel_size * LEVELS_ZOOM)) / (game_data.pixel_size * LEVELS_ZOOM)
						local y_pos = (y - yc - (current_level_scroll_y * game_data.block_height * LEVELS_ZOOM)) / (LEVELS_ZOOM)
						
						x_pos = Quantize(x_pos, game_data.block_width)
						y_pos = Quantize(y_pos, game_data.block_height)

						table.insert(game_data.levels[current_level].actors, {number = current_level_selected_actor, start_x = x_pos, start_y = y_pos, x = x_pos, y = y_pos, animation = GetActorAnimationNumber(current_level_selected_actor, "idle"), frame = 1})
					end
				end
			elseif current_level_actors_edit_mode == true then
				-- top left corner
				local xc = 400 - (game_data.levels_data.sw * game_data.block_width * game_data.pixel_size * LEVELS_ZOOM / 2)
				local yc = 160
					
				-- position = mouse - top-left corner - scrolling
				local x_pos = (x - xc - (current_level_scroll_x * game_data.block_width * game_data.pixel_size * LEVELS_ZOOM)) / (game_data.pixel_size * LEVELS_ZOOM)
				local y_pos = (y - yc - (current_level_scroll_y * game_data.block_height * LEVELS_ZOOM)) / (LEVELS_ZOOM)
					
				x_pos = Quantize(x_pos, game_data.block_width)
				y_pos = Quantize(y_pos, game_data.block_height)

				-- change start coordinates
				game_data.levels[current_level].actors[current_level_edited_actor_instance].start_x = x_pos
				game_data.levels[current_level].actors[current_level_edited_actor_instance].start_y = y_pos
			end
		end
	end
end

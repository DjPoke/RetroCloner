------------------------------
--
--     ===================
--     Retro Cloner Player
--     ===================
--
--       by Bruno Vignoli
--    (c) 2026 M.I.T Licence
--
--  A tool to play retro games
-- for PC that looks like retro
--        computer games
--
------------------------------

-- constants
WINDOW_WIDTH = 0
WINDOW_HEIGHT = 0
WINDOW_TITLE = "Retro Cloner Player"
WINDOW_ZOOM = 3

GAME_TITLE_FONT_SIZE = 16
GAME_FONT_SIZE = 8
FONT_DOWN_SCALE = 64

GAME_AREA = 1
SCORE_AREA = 2
LIVES_AREA = 3
LEVEL_AREA = 4

-- arrays
game_data = {
	game_name = "",
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
		game_speed = 0,
		animations_speed = 0,
		player_speed = 0,
		game_goal = 0,
		scrolling_type = 0,
		scrolling_speed = 0,
		scrolling_horizontally = false,
		scrolling_vertically = false,
		scroll_backward = false,
		gravity = 0,
		jump_power = 0,
		automove = false
	},
	sounds = { player = {walk = "", run = "", jump = "", hit = "", fire1 = "", fire2 = ""},
			   enemies = {},
			   bonus = {}
	},
	musics = { intro = "", in_game = "", winner = "", game_over = "" },
	images = { intro = "", interface = "", winner = "", game_over = "" }
}

img_blocks = {}
img_sprites = {}

-- vars
pd = 1

-- requires
require("tools")
require("fonts")
require("load_game")
require("commons")
run = require("run")

-- löve2d functions
function love.load()
	-- activate pixel art filter
	love.graphics.setDefaultFilter('nearest', 'nearest')
	
	-- load game data
	game_data = LoadGame("game", "game.txt", game_data)

	-- get blocks and sprites images
	ConvertBlocksToImages()
	ConvertSpritesToImages()

	-- set game window size
	WINDOW_WIDTH = game_data.screen_width * game_data.pixel_size * WINDOW_ZOOM
	WINDOW_HEIGHT = game_data.screen_height * WINDOW_ZOOM
	
	WINDOW_BORDER = math.floor(WINDOW_WIDTH / 8)
	if not game_data.border then WINDOW_BORDER = 0 end
	
	if not love.window.setMode(WINDOW_WIDTH + (WINDOW_BORDER * 2), WINDOW_HEIGHT + (WINDOW_BORDER * 2), {fullscreen = false, resizable = true, vsync = 1}) then
		print("Can't activate game window !")
		
		love.event.quit(1)
	end
	
	-- set window title
	love.window.setTitle(WINDOW_TITLE)
		
	-- load fonts
	GAME_TITLE_FONT = love.graphics.newFont("fonts/" .. game_data.fonts, GAME_TITLE_FONT_SIZE * FONT_DOWN_SCALE)
	GAME_FONT = love.graphics.newFont("fonts/" .. game_data.fonts, GAME_FONT_SIZE * FONT_DOWN_SCALE)
	
	-- set fonts filter
	GAME_TITLE_FONT:setFilter("nearest", "nearest")
	GAME_FONT:setFilter("nearest", "nearest")
	
	-- initialize the game
	run.load()
end

function love.update(dt)
	-- update the game
	run.update(dt)
end

function love.draw()
	-- draw the game
	run.draw()
end

function love.keypressed(key, scancode, isrepeat)
	run.keypressed(key, scancode, isrepeat)
end

function love.gamepadpressed(joystick, button)
	run.gamepadpressed(joystick, button)
end

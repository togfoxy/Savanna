gstrGameVersion = "0.01"

Inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

TLfres = require 'lib.tlfres'
-- https://love2d.org/wiki/TLfres

Concord = require 'lib.concord'
-- https://github.com/Tjakka5/Concord

Cf = require 'lib.commonfunctions'
Profi = require 'lib.profi'
Ccord = require 'ccord'
Enum = require 'enum'
Fun = require 'functions'

SCREEN_WIDTH = 1440 -- 1920
SCREEN_HEIGHT = 900 -- 1080
SCREEN_STACK = {}

NUMBER_OF_HERBIVORES = 100
NUMBER_OF_CARNIVORES = 1
COUNT_GRASS_TILES = 0
TILE_SIZE = 50

MAP = {}			-- a 2d table of tiles
ANIMALS = {}		-- a table of animals
CARCAS = {}			-- a table of dead animals


NUMBER_OF_ROWS = (Cf.round(SCREEN_HEIGHT / TILE_SIZE)) - 1
NUMBER_OF_COLS = (Cf.round(SCREEN_WIDTH / TILE_SIZE)) - 1

print("There are " .. NUMBER_OF_ROWS .. " rows and " .. NUMBER_OF_COLS .. " columns.")

IMAGES = {}

function love.keyreleased( key, scancode )
	if key == "escape" then
		Cf.RemoveScreen(SCREEN_STACK)
	end
end

function love.load()

    if love.filesystem.isFused( ) then
        void = love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
        gbolDebug = false
    else
        void = love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT,{fullscreen=false,display=2,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
    end

	love.window.setTitle("Savanna " .. gstrGameVersion)

	Cf.AddScreen("MainMenu", SCREEN_STACK)

	love.graphics.setPointSize( 1 )

	IMAGES[Enum.terrainBurned] = love.graphics.newImage("assets/images/grass_burned_block_256x.png")
	IMAGES[Enum.terrainGrassDry] = love.graphics.newImage("assets/images/grass_dry_block_256x.png")
	IMAGES[Enum.terrainGrassGreen] = love.graphics.newImage("assets/images/grass_green_block_256x.png")
	IMAGES[Enum.terrainTeal] = love.graphics.newImage("assets/images/grass_teal_block_256x.png")
	IMAGES[Enum.terrainHighlights] = love.graphics.newImage("assets/images/highlights for colorizing.png")


	for row = 1, NUMBER_OF_ROWS do
		MAP[row] = {}
	end
	for col = 1, NUMBER_OF_COLS do
		for row = 1,NUMBER_OF_ROWS do
			MAP[row][col] = {}
		end
	end

	Ccord.init()
	WORLD:emit("init")

end

function love.draw()

	TLfres.beginRendering(SCREEN_WIDTH,SCREEN_HEIGHT)

	WORLD:emit("draw")

	TLfres.endRendering({0, 0, 0, 1})
end

function love.update(dt)

	WORLD:emit("update", dt)

	if COUNT_GRASS_TILES < 5 then
		local row = love.math.random(1, NUMBER_OF_ROWS)
		local col = love.math.random(1, NUMBER_OF_COLS)

		MAP[row][col].terrainType.value = Enum.terrainTeal
		MAP[row][col].age.value = 0
		MAP[row][col].maxAge.value = love.math.random(270, 330)
		MAP[row][col].hasEdibleGrass = true
		MAP[row][col].spread.timer = 5

		print("Creating grass")
	end

end

gstrGameVersion = "0.01"

Inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

TLfres = require 'lib.tlfres'
-- https://love2d.org/wiki/TLfres

Concord = require 'lib.concord'
-- https://github.com/Tjakka5/Concord

Cf = require 'lib.commonfunctions'
Ccord = require 'ccord'
Enum = require 'enum'

SCREEN_WIDTH = 1920
SCREEN_HEIGHT = 1080
SCREEN_STACK = {}

NUMBER_OF_BOTS = 10
TILE_SIZE = 50
-- MAP = {}
NUMBER_OF_ROWS = (Cf.round(SCREEN_HEIGHT / TILE_SIZE)) - 1
NUMBER_OF_COLS = (Cf.round(SCREEN_WIDTH / TILE_SIZE))

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
        void = love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
    end

	love.window.setTitle("Savanna " .. gstrGameVersion)

	Cf.AddScreen("MainMenu", SCREEN_STACK)

	love.graphics.setPointSize( 1 )

	IMAGES[Enum.terrainBurned] = love.graphics.newImage("assets/images/grass_burned_block_256x.png")
	IMAGES[Enum.terrainGrassDry] = love.graphics.newImage("assets/images/grass_dry_block_256x.png")
	IMAGES[Enum.terrainGrassGreen] = love.graphics.newImage("assets/images/grass_green_block_256x.png")
	IMAGES[Enum.terrainTeal] = love.graphics.newImage("assets/images/grass_teal_block_256x.png")

	Ccord.init()

end


function love.draw()

	TLfres.beginRendering(SCREEN_WIDTH,SCREEN_HEIGHT)

	WORLD:emit("draw")

	TLfres.endRendering({0, 0, 0, 1})
end


function love.update(dt)
	WORLD:emit("update", dt)
end

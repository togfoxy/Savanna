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

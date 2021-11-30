ccord = {}


function ccord.init()

    -- Create the World
    WORLD = Concord.world()
    BOTS = {}


    -- define components
    Concord.component("drawable")
    Concord.component("position", function(c, x, y)
        c.x = x or 10
        c.y = y or 10
    end)
    Concord.component("terrainType", function(c, ttype)
        c.value = ttype or love.math.random(1, Enum.terrainNumberOfTypes)
    end)




    -- define Systems
    systemDraw = Concord.system({
        pool = {"position", "drawable"}
    })
    function systemDraw:draw()
        love.graphics.setColor(1,1,1,1)

        for k, e in ipairs(self.pool) do
            local terraintype = e.terrainType.value
            if terraintype ~= nil then
                local img = IMAGES[e.terrainType.value]
                local x = (e.position.x * TILE_SIZE) - 50
                local y = (e.position.y * TILE_SIZE) - 50
                love.graphics.draw(img, x, y, 0, TILE_SIZE / 256)
            end
        end
    end









    -- Add the Systems
    WORLD:addSystems(systemDraw)


    -- Create entitites

    -- create tiles
    for col = 1, NUMBER_OF_COLS do
        for row = 1, NUMBER_OF_ROWS do
            TILES = Concord.entity(WORLD)
            :give("drawable")
            :give("position", col, row)
            :give("terrainType")
        end
    end

    -- create agents
    for i = 1, NUMBER_OF_BOTS do
        BOTS = Concord.entity(WORLD)
        -- assign components




    end

end

return ccord

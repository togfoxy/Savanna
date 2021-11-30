ccord = {}


function ccord.init()

    -- Create the World
    WORLD = Concord.world()
    BOTS = {}


    -- define components
    Concord.component("drawable")
    Concord.component("isTile")
    Concord.component("position", function(c, row, col)
        c.row = row or 10
        c.col = col or 10
    end)
    Concord.component("terrainType", function(c, ttype)
        c.value = ttype or love.math.random(1, Enum.terrainNumberOfTypes)
    end)
    Concord.component("age", function(c, number)
        c.value = number or 0
    end)
    Concord.component("maxAge", function(c, number)
        c.value = number or love.math.random(270, 330) -- seconds
    end)
    Concord.component("spread", function(c)
        c.timer = love.math.random((Enum.timerSpreadTimer / 2), Enum.timerSpreadTimer)
    end)


    -- define Systems
    systemDraw = Concord.system({
        pool = {"position", "drawable"}
    })
    function systemDraw:draw()
        love.graphics.setColor(1,1,1,1)
        for _, e in ipairs(self.pool) do
            local terraintype = e.terrainType.value
            if terraintype ~= nil then
                local img = IMAGES[e.terrainType.value]
                local x = (e.position.col * TILE_SIZE) - 50
                local y = (e.position.row * TILE_SIZE) - 50
                love.graphics.draw(img, x, y, 0, TILE_SIZE / 256)
            end
        end
    end

    systemAge = Concord.system({
        pool = {"age"}
    })
    function systemAge:update(dt)
        for _, e in ipairs(self.pool) do
            e.age.value = e.age.value + dt
            -- check for maturity
            if e.terrainType.value ~= nil then
                -- age the grass
                if e.age.value > (e.maxAge.value / 2) and e.terrainType.value == Enum.terrainGrassGreen then
                    e.terrainType.value = Enum.terrainTeal
                end
                if e.age.value > e.maxAge.value and e.terrainType.value ~= Enum.terrainBurned then
                    -- kill grass and reset
                    e.terrainType.value = Enum.terrainGrassDry
                end
            end
        end
    end

    systemIsTile = Concord.system({
        pool = {"isTile"}
    })
    function systemIsTile:init()
        self.pool.onEntityAdded = function(_, entity)
            local row = entity.position.row
            local col = entity.position.col
            MAP[row][col] = entity
        end
    end

    systemSpread = Concord.system({
        pool = {"spread"}
    })
    function systemSpread:update(dt)
        for _, e in ipairs(self.pool) do
            e.spread.timer = e.spread.timer - dt
            if e.spread.timer < 0 then
                if e.terrainType.value == Enum.terrainTeal and love.math.random(1,150) == 1 then -- slow down the spread
                    -- grass spreads
                    local eastwestdirection = 0
                    local northsouthdirection = 0
                    repeat
                        eastwestdirection = love.math.random(-1, 1)
                        northsouthdirection = love.math.random(-1, 1)
                    until eastwestdirection ~= 0 or northsouthdirection ~= 0
                    local row = e.position.row + northsouthdirection
                    local col = e.position.col + eastwestdirection

                    if row > 0 and row <= NUMBER_OF_ROWS and col > 0 and col <= NUMBER_OF_COLS then
                        if MAP[row][col].terrainType.value == Enum.terrainGrassDry then
                            MAP[row][col].terrainType.value = Enum.terrainGrassGreen
                            MAP[row][col].age.value = 0
                            MAP[row][col].maxAge.value = love.math.random(Enum.terrainMinMaxAge, Enum.terrainMaxMaxAge)
                        end
                    end
                end
            end
        end
    end

    -- Add the Systems
    WORLD:addSystems(systemDraw, systemAge, systemSpread, systemIsTile)



    -- Create entitites
    -- create tiles
    for col = 1, NUMBER_OF_COLS do
        for row = 1, NUMBER_OF_ROWS do
            TILES = Concord.entity(WORLD)
            :give("drawable")
            :give("position", row, col)
            :give("terrainType")
            :give("age")
            :give("maxAge", love.math.random(Enum.terrainMinMaxAge, Enum.terrainMaxMaxAge))
            :give("spread")
            :give("isTile")
        end
    end

    -- create agents
    for i = 1, NUMBER_OF_BOTS do
        BOTS = Concord.entity(WORLD)
        -- assign components




    end

end

return ccord

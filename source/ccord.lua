ccord = {}


function ccord.init()

    -- Create the World
    WORLD = Concord.world()
    BOTS = {}
    TRAIL = {}

    -- define components



    Concord.component("lifetimer", function(c,time)
        c.value = time or Enum.timerTrail
    end)
    Concord.component("isBot", function(c,bol)
        c.value = bol
    end)
    Concord.component("position", function(c, x, y)
        c.x = x or love.math.random(10, 500)
        c.y = y or love.math.random(10, 500)
    end)
    Concord.component("velocity", function(c, x, y)
        c.x = x or 0
        c.y = y or 0
    end)
    Concord.component("acceleration", function(c, value)
        c.acceleration = value or 0.3
    end)
    Concord.component("topSpeed", function(c, value)
        c.topSpeed = value or 1
    end)
    Concord.component("gender", function(c, value)
        c.gender = value
    end)
    Concord.component("isCarnivore", function(c, bol)
        c.isCarnivore = bol
    end)
    Concord.component("isHerbivore", function(c, bol)
        c.isHerbivore = bol or true
    end)
    Concord.component("currentAction", function(c, action)
        c.currentAction = action or 0
        local mintimer = Enum.timerActionTimer - 1
        local maxtimer = Enum.timerActionTimer + 1
        c.currentActionTimer = love.math.random(mintimer,maxtimer)
    end)
    Concord.component("drawable")

    -- define Systems
    -- creaete the system and pool
    systemDecideAction = Concord.system({
        pool = {"currentAction"}
    })
    function systemDecideAction:update(dt)
        for k,e in ipairs(self.pool) do
            local ca = e.currentAction.currentAction
            if e.currentAction.currentAction == 0 then
                e.currentAction.currentAction = love.math.random(1,9)
            end
            e.currentAction.currentActionTimer = e.currentAction.currentActionTimer - dt
            if e.currentAction.currentActionTimer < 0 then
                local mintimer = Enum.timerActionTimer - 1
                local maxtimer = Enum.timerActionTimer + 1
                e.currentAction.currentActionTimer = love.math.random(mintimer,maxtimer)
                e.currentAction.currentAction = 0
            end
        end
    end

    systemMove = Concord.system({
        pool = {"position", "acceleration", "topSpeed"}
    })
    function systemMove:update(dt)
        for k,e in ipairs(self.pool) do
            if e.currentAction.currentAction == 1 then
                -- north west
                e.velocity.x = e.velocity.x - (e.acceleration.acceleration * dt)
                e.velocity.y = e.velocity.y - (e.acceleration.acceleration * dt)

                if e.velocity.x < (e.topSpeed.topSpeed * -1) then
                      e.velocity.x = (e.topSpeed.topSpeed * -1)
                end
                if e.velocity.y < (e.topSpeed.topSpeed * -1) then
                      e.velocity.y = (e.topSpeed.topSpeed * -1)
                end
            end
            if e.currentAction.currentAction == 2 then
                -- north
                e.velocity.y = e.velocity.y - (e.acceleration.acceleration * dt)
                if e.velocity.x < 0 then
                    e.velocity.x = e.velocity.x + (e.acceleration.acceleration * dt)
                    if e.velocity.x > 0 then e.velocity.x = 0 end
                else
                    e.velocity.x = e.velocity.x - (e.acceleration.acceleration * dt)
                    if e.velocity.x < 0 then e.velocity.x = 0 end
                end
                if e.velocity.y < (e.topSpeed.topSpeed * -1) then
                      e.velocity.y = (e.topSpeed.topSpeed * -1)
                end
            end
            if e.currentAction.currentAction == 3 then
                -- north east
                e.velocity.x = e.velocity.x + (e.acceleration.acceleration * dt)
                e.velocity.y = e.velocity.y - (e.acceleration.acceleration * dt)

                if e.velocity.x > (e.topSpeed.topSpeed * 1) then
                      e.velocity.x = (e.topSpeed.topSpeed * 1)
                end
                if e.velocity.y < (e.topSpeed.topSpeed * -1) then
                      e.velocity.y = (e.topSpeed.topSpeed * -1)
                end
            end
            if e.currentAction.currentAction == 4 then
                -- west
                e.velocity.x = e.velocity.x - (e.acceleration.acceleration * dt)
                if e.velocity.y < 0 then
                    e.velocity.y = e.velocity.y + (e.acceleration.acceleration * dt)
                    if e.velocity.y > 0 then e.velocity.y = 0 end
                else
                    e.velocity.y = e.velocity.y - (e.acceleration.acceleration * dt)
                    if e.velocity.y < 0 then e.velocity.y = 0 end
                end
                if e.velocity.x < (e.topSpeed.topSpeed * -1) then
                      e.velocity.x = (e.topSpeed.topSpeed * -1)
                end
            end
            if e.currentAction.currentAction == 5 then
                -- stop
                if e.velocity.x < 0 then
                    e.velocity.x = e.velocity.x + (e.acceleration.acceleration * dt)
                    if e.velocity.x > 0 then e.velocity.x = 0 end
                else
                    e.velocity.x = e.velocity.x - (e.acceleration.acceleration * dt)
                    if e.velocity.x < 0 then e.velocity.x = 0 end
                end
                if e.velocity.y < 0 then
                    e.velocity.y = e.velocity.y + (e.acceleration.acceleration * dt)
                    if e.velocity.y > 0 then e.velocity.y = 0 end
                else
                    e.velocity.y = e.velocity.y - (e.acceleration.acceleration * dt)
                    if e.velocity.y < 0 then e.velocity.y = 0 end
                end
            end
            if e.currentAction.currentAction == 6 then
                -- east
                e.velocity.x = e.velocity.x + (e.acceleration.acceleration * dt)
                if e.velocity.y < 0 then
                    e.velocity.y = e.velocity.y + (e.acceleration.acceleration * dt)
                    if e.velocity.y > 0 then e.velocity.y = 0 end
                else
                    e.velocity.y = e.velocity.y - (e.acceleration.acceleration * dt)
                    if e.velocity.y < 0 then e.velocity.y = 0 end
                end
                if e.velocity.x > (e.topSpeed.topSpeed * 1) then
                      e.velocity.x = (e.topSpeed.topSpeed * 1)
                end
            end
            if e.currentAction.currentAction == 8 then
                -- north
                e.velocity.y = e.velocity.y + (e.acceleration.acceleration * dt)
                if e.velocity.x < 0 then
                    e.velocity.x = e.velocity.x + (e.acceleration.acceleration * dt)
                    if e.velocity.x > 0 then e.velocity.x = 0 end
                else
                    e.velocity.x = e.velocity.x - (e.acceleration.acceleration * dt)
                    if e.velocity.x < 0 then e.velocity.x = 0 end
                end
                if e.velocity.y > (e.topSpeed.topSpeed * 1) then
                      e.velocity.y = (e.topSpeed.topSpeed * 1)
                end
            end
            if e.currentAction.currentAction == 9 then
                -- north west
                e.velocity.x = e.velocity.x + (e.acceleration.acceleration * dt)
                e.velocity.y = e.velocity.y + (e.acceleration.acceleration * dt)

                if e.velocity.x > (e.topSpeed.topSpeed * 1) then
                      e.velocity.x = (e.topSpeed.topSpeed * 1)
                end
                if e.velocity.y > (e.topSpeed.topSpeed * 1) then
                      e.velocity.y = (e.topSpeed.topSpeed * 1)
                end
            end

            e.position.x = e.position.x + e.velocity.x
            e.position.y = e.position.y + e.velocity.y

            newTrail = Concord.entity(WORLD)
            :give("isBot", false)
            :give("position", e.position.x, e.position.y)
            :give("drawable")
            :give("lifetimer")
        end
    end

    systemTrail = Concord.system({
        pool = {"lifetimer"}
    })
    function systemTrail:update(dt)
        for k,e in ipairs(self.pool) do
            e.lifetimer.value = e.lifetimer.value - dt
            if e.lifetimer.value < 0 then
                e:destroy()
            end
        end
    end

    systemDraw = Concord.system({
        pool = {"position", "drawable"}
    })
    function systemDraw:draw()
        love.graphics.setColor(1,1,1,1)

        for _, e in ipairs(self.pool) do
            if e.isBot.value == true then
                love.graphics.circle("fill", e.position.x, e.position.y, 5)
            else
                love.graphics.points(e.position.x, e.position.y)
            end
        end
    end

    -- Add the Systems
    WORLD:addSystems(systemMove, systemDraw, systemDecideAction, systemTrail)

    -- create agents
    local numOfBots = 10
    for i = 1, numOfBots do
        BOTS[i] = Concord.entity(WORLD)
        -- assign components
        :give("isBot", true)
        :give("position")
        :give("acceleration")
        :give("velocity", 0,0)
        :give("topSpeed")
        :give("gender", 1)
        :give("isCarnivore", 0)
        :give("isHerbivore", 1)
        :give("drawable")
        :give("currentAction")
    end

end
return ccord

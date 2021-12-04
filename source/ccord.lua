ccord = {}


function ccord.init()

    -- Create the World
    WORLD = Concord.world()

    -- define components
    Concord.component("uid", function(c)
        c.value = Cf.Getuuid()
    end)
    Concord.component("drawable")
    Concord.component("isTile")
    Concord.component("isAnimal")
    Concord.component("hasEdibleGrass")
    Concord.component("isHerbivore")
    Concord.component("isCarnivore")
    Concord.component("isCarcas")
    Concord.component("currentAction", function(c, text)
        c.value = ""
    end)
    Concord.component("hasTargetTile", function(c, row, col)
        c.row = row
        c.col = col
        c.traveltime = 0
    end)
    Concord.component("canEat", function(c)
        c.currentCalories = love.math.random(25,100)
        c.calorieConsumptionRate = 1    -- calaries lost per second
        c.nextCheckTimer = Enum.timerNextEatCheck            -- how often to check if hungry
    end)
    Concord.component("position", function(c, row, col)
        c.row = row or love.math.random(1,NUMBER_OF_ROWS)
        c.col = col or love.math.random(1,NUMBER_OF_COLS)
		c.maxSpeed = love.math.random(10,20)
    end)
    Concord.component("terrainType", function(c, ttype)
        c.value = ttype or love.math.random(1, Enum.terrainNumberOfTypes)
    end)
    Concord.component("age", function(c, number)
        c.value = number or love.math.random(1, 250)
    end)
    Concord.component("maxAge", function(c, number)
        c.value = number or love.math.random(475, 525) -- seconds
    end)
    Concord.component("spread", function(c)
        c.timer = love.math.random((Enum.timerSpreadTimer / 2), Enum.timerSpreadTimer)
    end)
	Concord.component("hasGender", function(c)
		c.value = love.math.random(1,2)
		c.breedtimer = love.math.random(1, 30)		 --c.maxAge.value / 3	-- when can next breed
	end)


    -- define Systems
    systemDraw = Concord.system({
        pool = {"position", "drawable"}
    })
    function systemDraw:draw()
        love.graphics.setColor(1,1,1,1)
        COUNT_GRASS_TILES = 0
        for _, e in ipairs(self.pool) do
            if e.isTile then
                local x = (e.position.col * TILE_SIZE) - 25
                local y = (e.position.row * TILE_SIZE) - 25
                local img = IMAGES[e.terrainType.value]
                love.graphics.draw(img, x, y, 0, TILE_SIZE / 256)
                if e.terrainType.value == Enum.terrainGrassGreen or e.terrainType.value == Enum.terrainTeal then
                    COUNT_GRASS_TILES = COUNT_GRASS_TILES + 1
                end
            end
            if e.isAnimal then
				-- make circle larger with age

				local drawwidth = Cf.round((e.age.value / e.maxAge.value) * 10)
				if drawwidth < 3 then drawwidth = 3 end

                local x = (e.position.col * TILE_SIZE)
                local y = (e.position.row * TILE_SIZE)

				if e.isHerbivore then
					if e.hasGender.value == Enum.genderFemale then
						love.graphics.setColor(1,125/255,125/255,1)
					else
						love.graphics.setColor(0,1,1,1)
					end
                    love.graphics.circle("line", x, y, drawwidth)
				else
                    -- carnivore
					love.graphics.setColor(1,85/255,0,1)
                    love.graphics.rectangle("line", x, y, 15, 15)
				end

                if e:has("currentAction") and e.currentAction ~= nil then
                    love.graphics.setColor(1, 1, 1, 1)
                    love.graphics.print(e.currentAction, x + 10, y - 8)
                end
            end
            if e.isCarcas then
                local x = (e.position.col * TILE_SIZE)
                local y = (e.position.row * TILE_SIZE)
                local drawwidth = 8
                love.graphics.setColor(146/255, 115/255, 30/255, 1)
                love.graphics.circle("fill", x, y, drawwidth)
            end
        end

        -- ** debugging **
        -- for q,w in pairs(ANIMALS) do
        --     local x = (w.position.col * TILE_SIZE)
        --     local y = (w.position.row * TILE_SIZE)
        --     love.graphics.rectangle("line", x, y, 10, 10)
        -- end
    end

    systemAge = Concord.system({
        pool = {"age"}
    })
    function systemAge:update(dt)
        for _, e in ipairs(self.pool) do
            e.age.value = e.age.value + dt
            -- check for maturity
            if e.isTile then
                -- age the grass
                if e.age.value > (e.maxAge.value / 2) and e.terrainType.value == Enum.terrainGrassGreen then
                    e.terrainType.value = Enum.terrainTeal
                    e:ensure("hasEdibleGrass")
                    MAP[Cf.round(e.position.row)][Cf.round(e.position.col)].hasEdibleGrass = true
                end
                if e.age.value > e.maxAge.value and e.terrainType.value ~= Enum.terrainBurned then
                    -- kill grass and reset
                    e.terrainType.value = Enum.terrainGrassDry
                    e:remove("hasEdibleGrass")
                    MAP[Cf.round(e.position.row)][Cf.round(e.position.col)].hasEdibleGrass = false
                end
            end
            if e.isAnimal then
                if e.age.value > e.maxAge.value then
                    print("Dead from age")
                    Fun.destroyAnimal(e)

				end
            end
            if e.isCarcas and e.age.value > e.maxAge.value then
                print("Carcas dead from age")
                Fun.destroyCarcas(e)
            end

            if e.canEat then
                e.canEat.currentCalories = e.canEat.currentCalories - (e.canEat.calorieConsumptionRate * dt)
                if e.canEat.currentCalories < 0 then
					print("Dead from hunger")
                    Fun.destroyAnimal(e)
				end
            end
        end
    end

    systemcanEat = Concord.system({
        pool = {"canEat", "position"}
    })
    function systemcanEat:update(dt)

        for k, e in ipairs(self.pool) do
            e.canEat.nextCheckTimer = e.canEat.nextCheckTimer - dt
            if e.canEat.nextCheckTimer < 0 then
                e.canEat.nextCheckTimer = Enum.timerNextEatCheck

                local rndnum = love.math.random(100)
                if  rndnum > e.canEat.currentCalories then
                    -- time to eat
                    local animalrow = Cf.round(e.position.row,0)
                    local animalcol = Cf.round(e.position.col,0)
    				if e.isHerbivore then
    					local hasEdibleGrass = (MAP[animalrow][animalcol].hasEdibleGrass or nil)
    					if hasEdibleGrass ~= nil then
    						-- can eat
    						MAP[animalrow][animalcol].terrainType.value = Enum.terrainGrassDry
    						MAP[animalrow][animalcol].age.value = 0
    						MAP[animalrow][animalcol].maxAge.value = love.math.random(Enum.terrainMinMaxAge, Enum.terrainMaxMaxAge)
    						MAP[animalrow][animalcol].hasEdibleGrass = false
    						e.canEat.currentCalories = e.canEat.currentCalories + Enum.grassCalories
                            e.currentAction = ""
    					else
    						-- not on edible grass but still hungry
    						local targetTile = {}
    						targetTile.row, targetTile.col = Fun.getClosestTile(animalrow, animalcol, Enum.terrainTeal)
                            if targetTile.row ~= 0 then
    						    e:ensure("hasTargetTile", targetTile.row, targetTile.col)
                                e.currentAction = "Moving to grass"
                            end
    					end
    				else
    					-- carnivore
                        local closestcarcass, carcasdistance = Fun.getClosestCarcass(e)
                        if carcasdistance >=0 then
print(carcasdistance)

                            if carcasdistance <= 3 then
                                e.canEat.currentCalories = e.canEat.currentCalories + Enum.carcasCalories
                                e.currentAction = ""
                                Fun.destroyCarcas(closestcarcass)
                            else
                                e:ensure("hasTargetTile", closestcarcass.position.row, closestcarcass.position.col)
                                e.currentAction = "Moving to carcas"
                            end
                        end
    				end
                end
            end
        end
    end

    systemMove = Concord.system({
        pool = {"position", "hasTargetTile", "isAnimal"}
    })
    function systemMove:update(dt)
        for k, e in ipairs(self.pool) do
            -- adjust x and y
            Fun.applyMovement(e, e.position.maxSpeed, dt)
            -- remove hasTargetTile if at destination
            if e:has("hasTargetTile") then
                if (Cf.round(e.position.row,1) == Cf.round(e.hasTargetTile.row,1)) and Cf.round(e.position.col,1) == Cf.round(e.hasTargetTile.col,1) then
                    e:remove("hasTargetTile")
                    -- print("Target tile removed " ..  dt)
                else
                    e.hasTargetTile.traveltime = e.hasTargetTile.traveltime + dt
                    if e.hasTargetTile.traveltime > Enum.timerTravelTimeThreshold then
                        e.hasTargetTile.traveltime = 0
                        e:remove("hasTargetTile")
                        e.currentAction = ""
                    end
                end
            end
        end
    end

    systemSpread = Concord.system({
        pool = {"spread"}
    })
    function systemSpread:update(dt)
        for _, e in ipairs(self.pool) do
            e.spread.timer = e.spread.timer - dt
            if e.spread.timer < 0 then
                if e.terrainType.value == Enum.terrainTeal and love.math.random(1,2) == 1 then -- slow down the spread
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
                        e.spread.timer = love.math.random((Enum.timerSpreadTimer / 2), Enum.timerSpreadTimer)
                    end
                end
            end
        end
    end

	systemBreed = Concord.system({
		pool = {"hasGender"}
	})
	function systemBreed:update(dt)
		for _, e in ipairs(self.pool) do
			e.hasGender.breedtimer = e.hasGender.breedtimer - dt
			if e.hasGender.breedtimer <= 0 then
                -- candidate to breed
                e.hasGender.breedtimer = 0

    			if Fun.entityCanBreed(e) then
    				local targetgender = ""
    				if e.hasGender.value == Enum.genderMale then
    					targetgender = Enum.genderFemale
    				else
    					targetgender = Enum.genderMale
    				end

    				-- returns an entity
    				f = Fun.getClosestGender(e, targetgender)

    				if f ~= nil and e:has("hasTargetTile") == false then
                        -- print("Seeking opposite gender")
    					e:ensure("hasTargetTile", Cf.round(f.position.row,1), Cf.round(f.position.col,1))
                        e.currentAction = "Seeking mate at " .. e.hasTargetTile.row .. " " .. e.hasTargetTile.col

    					if Cf.round(e.position.row,1) == Cf.round(f.position.row,1) and Cf.round(e.position.col,1) == Cf.round(f.position.col,1) then
    						-- check if can still breed after travel timer
                            e.currentAction = ""
                            if Fun.entityCanBreed(e) and Fun.entityCanBreed(f) then
    							Fun.breed(e, f)	-- e and f are entities
    							-- reset timer even if breeding failed
                                -- females need to rest longer after breeding
                                if e.hasGender.value == Enum.genderFemale then
                                    e.hasGender.breedtimer = Enum.timerBreedTimer
                                else
                                    e.hasGender.breedtimer = Enum.timerBreedTimer / 2
                                end
                                if f.hasGender.value == Enum.genderFemale then
                                    f.hasGender.breedtimer = Enum.timerBreedTimer
                                else
                                    f.hasGender.breedtimer = Enum.timerBreedTimer / 2
                                end
                                e.currentAction = ""
    						end
    					end
                    else

    				end
    			end
            end
		end
	end

    systemIsTile = Concord.system({
        pool = {"isTile"},
		poolB = {"isAnimal"}
    })
    function systemIsTile:init()
        for _, e in ipairs(self.pool) do
            if e.terrainType.value == Enum.terrainTeal then
                e:ensure("hasEdibleGrass")
            else
                e:remove("hasEdibleGrass")
            end
        end
        self.pool.onEntityAdded = function(_, entity)
            local row = entity.position.row
            local col = entity.position.col
            MAP[row][col] = entity
        end
		self.poolB.onEntityAdded = function(_, entity)
			table.insert(ANIMALS, entity)
		end
    end

    -- Add the Systems
    WORLD:addSystems(systemDraw, systemAge, systemSpread, systemIsTile, systemcanEat, systemMove, systemBreed)

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

    -- create animals
    for i = 1, NUMBER_OF_HERBIVORES do
        local BOTS = Concord.entity(WORLD)
        -- assign components
        :give("position")
        :give("drawable")
        :give("isAnimal")
        :give("age")
        :give("maxAge")
        :give("canEat")
		:give("hasGender")
		:give("isHerbivore")
        :give("currentAction")
        :give("uid")
    end

    for i = 1, NUMBER_OF_CARNIVORES do
        local BOTS = Concord.entity(WORLD)
        -- assign components
        :give("position")
        :give("drawable")
        :give("isAnimal")
        :give("age")
        :give("maxAge")
        :give("canEat")
		:give("hasGender")
		:give("isCarnivore")
        :give("currentAction")
        :give("uid")
        BOTS.canEat.currentCalories = 180

		MAP[BOTS.position.row][BOTS.position.col].hasGender = BOTS.hasGender
		MAP[BOTS.position.row][BOTS.position.col].hasGender.value = BOTS.hasGender.value

    end
end

return ccord

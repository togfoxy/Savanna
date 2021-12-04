functions = {}



function functions.getClosestTile(startrow, startcol, terrainType)
    -- starting at row/col, find the closest tile with terrainType
    -- uses the MAP global table

    m = MAP
    -- candidate tiles are stored here
    local candidates = {}

    local boundary = math.max(#m, #m[1])

	for i = 1, boundary do
		-- do the top row only
		row = (startrow - i)
		if row < 1 then row = 1 end
		for col = (startcol - i), (startcol + i) do
			if col < 1 then col = 1 end
			if col > #m[1] then col = #m[1] end
			if m[row][col].terrainType.value == terrainType then
                local mytile = {}
                mytile.row = row
                mytile.col = col
                table.insert(candidates, mytile)
			end
		end

		-- do the bottom row
		row = (startrow + i)
		if row > #m then row = #m end
		for col = (startcol - i), (startcol + i) do
			if col < 1 then col = 1 end
			if col > #m[1] then col = #m[1] end
			if m[row][col].terrainType.value == terrainType then
                local mytile = {}
                mytile.row = row
                mytile.col = col
                table.insert(candidates, mytile)
			end
		end

		-- do the left column
		for row = (startrow - i), (startrow + i) do
			if row < 1 then row = 1 end
			if row > #m then row = #m end
			col = (startcol - i)
			if col < 1 then col = 1 end
			if m[row][col].terrainType.value == terrainType then
                local mytile = {}
                mytile.row = row
                mytile.col = col
                table.insert(candidates, mytile)
			end
		end

		-- do the right column
		for row = (startrow - i), (startrow + i) do
			if row < 1 then row = 1 end
			if row > #m then row = #m end
			col = (startcol + i)
			if col > #m[1] then col = #m[1] end
			if m[row][col].terrainType.value == terrainType then
                local mytile = {}
                mytile.row = row
                mytile.col = col
                table.insert(candidates, mytile)
			end
		end

        -- see if we have at least one candidates
        if #candidates > 0 then
            local rndnum = love.math.random(1, #candidates)
            return candidates[rndnum].row, candidates[rndnum].col
        end
	end

	return 0,0
end

function functions.applyMovement(e, velocity, dt)
    -- assumes an entity has a position and a target.
    -- return a new row/col that progresses towards that target

    local distancemovedthisstep = velocity * dt
    -- map row/col to x/y
    local currentx = (e.position.col * TILE_SIZE)
    local currenty = (e.position.row * TILE_SIZE)
    local targetx = (e.hasTargetTile.col * TILE_SIZE)
    local targety = (e.hasTargetTile.row * TILE_SIZE)

    -- get the vector that moves the entity closer to the destination
    local xvector = targetx - currentx  -- tiles
    local yvector = targety - currenty  -- tiles

--print(distancemovedthisstep, currentx,currenty,targetx,targety,xvector,yvector)

    local xscale = math.abs(xvector / distancemovedthisstep)
    local yscale = math.abs(yvector / distancemovedthisstep)
    local scale = math.max(xscale, yscale)

    if scale > 1 then
        xvector = xvector / scale
        yvector = yvector / scale
    end

    currentx = Cf.round(currentx + xvector, 1)
    currenty = Cf.round(currenty + yvector, 1)

-- print(currentx, currenty, xvector  , yvector  )

    e.position.row = (currenty / TILE_SIZE)
    e.position.col = (currentx / TILE_SIZE)
    if e.position.row < 1 then e.position.row = 1 end
    if e.position.col < 1 then e.position.col = 1 end
    if e.position.row > NUMBER_OF_ROWS then e.position.row = NUMBER_OF_ROWS end
    if e.position.col > NUMBER_OF_COLS then e.position.col = NUMBER_OF_COLS end
end

function functions.entityCanBreed(e)
	-- determines if the provided entity can breed
	if e.canEat.currentCalories > 50 and e.hasGender.breedtimer <= 0 and (e.age.value >= e.maxAge.value / 3) then	-- 50 is 50% (half full)
		return true
	end
	return false
end

function functions.breed(e, f)
    -- e and f are parents
	local spawn = Concord.entity(WORLD)
	:give("drawable")
	:give("isAnimal")
	:give("canEat")
	:give("position", e.position.row, e.position.col)
	:give("age", 0)
	:give("maxAge")
	:give("hasGender")
    :give("currentAction")
    :give("uid")

	if e:has("isHerbivore") then spawn:give("isHerbivore") end
	if e:has("isCarnivore") then spawn:give("isCarnivore") end

	e.hasGender.breedtimer = Enum.timerBreedTimer
	f.hasGender.breedtimer = Enum.timerBreedTimer
	spawn.hasGender.breedtimer = Enum.timerBreedTimer

    print("Bonk")

    table.insert(ANIMALS, spawn)

end

function functions.getClosestGender(entity, targetgender)

	local entityrow = entity.position.row
	local entitycol = entity.position.col
	local closestentity = nil

	local closestdistance = -1
	for i = 1, #ANIMALS do
		if ANIMALS[i] ~= entity then
			if (ANIMALS[i].isHerbivore and entity.isHerbivore) or (ANIMALS[i].isCarnivore and entity.isCarnivore) then
				if ANIMALS[i].hasGender.value == targetgender then
                    if (ANIMALS[i].age.value >= (ANIMALS[i].maxAge.value / 3)) then
    					local dist = Cf.GetDistance(entitycol, entityrow, ANIMALS[i].position.col, ANIMALS[i].position.row)
    					if closestdistance < 0 or dist < closestdistance then
    						closestdistance = dist
    						closestentity = ANIMALS[i]
    					end
                    end
				end
			end
		end
	end

	return closestentity


end

return functions

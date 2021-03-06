

Config = {
    ADU1 = {},
    ADU2 = {
        -- config options for ADU2
        ShiftWarn = 80 -- % of RPM (of Limiter) when RPM Bar should turn Red
    },
    ADU3 = {
        -- config options for ADU3
        ShiftWarn = 85 -- % of RPM (of Limiter) when RPM Bar should turn Red
    }
}

sim = ac.getSim()
SmoothedAccel = {x = 0, z = 0} -- global default value definition for x and z axis of vec() car.acceleration.

function modeA(dt) -- first screem of the ADU, part of the switching function at the very bottom
    display.image {
        image = "assets/ADU1.dds",
        pos = vec2(0, -1), -- coordinates of top left corner
        size = vec2(2048, 2048)
    }
    -- rainbow rpm gauge
    local value = math.saturate(car.rpm / 8000) -- saturate clamps value between 0 and 1
    display.image {
        image = "assets/RPM.dds", -- name of the texture to display
        pos = vec2(1, 397), -- coordinates of top left corner of the texture, pay attention to resolution of that texture
        size = vec2(2048 * value, 209), -- size of the image, "value *" makes it expand towards that maximum value
        uvStart = vec2(0, 0), -- uv coordinate of the top left corner (default is 0, 0)
        uvEnd = vec2(value, 1) -- uv coordinate of the bottom right corner (default is 1, 1), 0-8000rpms = value, 1 as range for the "uncovering fo the texture"
    }
    -- battery gauge
    local value = math.saturate(car.batteryVoltage / 15) -- saturate clamps value between 0 and 1
    display.image {
        image = "assets/BATTERY.dds",
        pos = vec2(63, 789),
        size = vec2(515 * value, 66),
        uvStart = vec2(0, 0),
        uvEnd = vec2(value, 1)
    }
    -- fuel gauge
    local value = math.saturate(car.fuel / 20) -- saturate clamps value between 0 and 1
    display.image {
        image = "assets/FUEL.dds",
        pos = vec2(63, 998),
        size = vec2(515 * value, 66),
        uvStart = vec2(0, 0),
        uvEnd = vec2(value, 1)
    }
    -- oil pressure gauge
    local value = math.saturate(car.oilPressure / 10) -- saturate clamps value between 0 and 1
    display.image {
        image = "assets/OIL.dds",
        pos = vec2(63, 1206),
        size = vec2(515 * value, 66),
        uvStart = vec2(0, 0),
        uvEnd = vec2(value, 1)
    }
    -- gforce dot with smoothing
    SmoothedAccel.x = math.applyLag(SmoothedAccel.x, car.acceleration.x, 0.92, dt)
    SmoothedAccel.z = math.applyLag(SmoothedAccel.z, car.acceleration.z, 0.92, dt)
    local gDotPos = vec2(1577, 1056) -- define the center of our dot
    local gDotMovementScaleX = 100 -- just a scale parameter, 100 is fine here
    local gDotMovementScaleZ = 100
    -- make sure our dot doesnt move past bounds
    gDotPos.x = gDotPos.x + (math.max(math.min(SmoothedAccel.x, 2), -2) * gDotMovementScaleX)
    gDotPos.y = gDotPos.y + (math.max(math.min(SmoothedAccel.z, 2), -2) * gDotMovementScaleZ)
    display.image {
        image = "assets/GF.dds",
        pos = vec2(gDotPos.x, gDotPos.y),
        size = vec2(50, 50)
    }
    -- gear display
    local gearText = tostring(car.gear) -- needs to be converted so that neutral and reverse display correctly (-1 = R, 0 = N)
    if car.gear == -1 then
        gearText = "R"
    end
    if car.gear == 0 then
        gearText = "N"
    end
    display.text {
        text = gearText,
        pos = vec2(650, 620),
        letter = vec2(500, 830),
        font = "c7_new",
        width = 46,
        alignment = 0.5,
        spacing = 0
    }
    -- numeric battery gauge
    display.text {
        text = string.format("%.1f", car.batteryVoltage), -- %.1f = 1 digit after comma, %.2f = 2 digits etc
        pos = vec2(430, 715),
        letter = vec2(40, 80),
        font = "c7_new",
        width = 46,
        alignment = 1,
        spacing = 0
    }
    -- numeric fuel gauge
    display.text {
        text = string.format("%.1f", car.fuel),
        pos = vec2(430, 925),
        letter = vec2(40, 80),
        font = "c7_new",
        width = 46,
        alignment = 1,
        spacing = 0
    }
    -- numeric oil pressure gauge
    display.text {
        text = string.format("%.1f", car.oilPressure),
        pos = vec2(470, 1130),
        letter = vec2(40, 80),
        font = "c7_new",
        width = 46,
        alignment = 1,
        spacing = 0
    }
    --numeric gforce gauges
    display.text {
        text = string.format("%.1f", (math.max(SmoothedAccel.x, 0))), -- SmoothedAccel.xyz replaces car.acceleration.xyz, math.max() calculates the biggest value from a list of numbers, "0" prevents the displayed value from going <0
        pos = vec2(1908, 1030),
        letter = vec2(50, 110),
        font = "c7_new",
        width = 46,
        alignment = 1,
        spacing = -10,
        color = rgbm(1, 0.5, 0, 1) -- rgbm is 0-1
    }
    display.text {
        text = string.format("%.1f", (math.max(SmoothedAccel.x * -1, 0))), -- *-1 to invert values for the opposite direction to prevent it from displaying negative values.
        pos = vec2(1165, 1030),
        letter = vec2(50, 110),
        font = "c7_new",
        width = 46,
        alignment = 1,
        spacing = -10,
        color = rgbm(1, 1, 1, 1)
    }
    display.text {
        text = string.format("%.1f", (math.max(SmoothedAccel.z * -1, 0))), -- z axis is actually forward/backward, y is up/down
        pos = vec2(1540, 685),
        letter = vec2(50, 110),
        font = "c7_new",
        width = 46,
        alignment = 1,
        spacing = -10,
        color = rgbm(1, 0.5, 0, 1)
    }
    display.text {
        text = string.format("%.1f", (math.max(SmoothedAccel.z, 0))),
        pos = vec2(1540, 1375),
        letter = vec2(50, 110),
        font = "c7_new",
        width = 46,
        alignment = 1,
        spacing = -10,
        color = rgbm(1, 1, 1, 1)
    }
    -- laptime gauge
    local time = car.lapTimeMs -- preparation for conversion from ms to minutes, seconds, milliseconds
    local formattedTime =
        string.format(
        "%02d:%02d:%02d",
        math.floor((time / (1000 * 60))) % 60,
        math.floor((time / 1000)) % 60,
        math.floor((time % 1000) / 100)
    )
    display.text {
        text = formattedTime,
        pos = vec2(40, 1535),
        letter = vec2(60, 120),
        font = "c7_new",
        width = 46,
        alignment = 1,
        spacing = -3
    }
    -- fastest lap gauge
    local time = car.bestLapTimeMs
    local formattedTime =
        string.format(
        "%02d:%02d:%02d",
        math.floor((time / (1000 * 60))) % 60,
        math.floor((time / 1000)) % 60,
        math.floor((time % 1000) / 100)
    )
    display.text {
        text = formattedTime,
        pos = vec2(1450, 1535),
        letter = vec2(60, 120),
        font = "c7_new",
        width = 46,
        alignment = 1,
        spacing = -3
    }
    -- clock
    display.text {
        text = string.format("%02d:%02d:%02d", sim.timeHours, sim.timeMinutes, sim.timeSeconds),
        pos = vec2(730, 1480),
        letter = vec2(70, 180),
        font = "c7_new",
        width = 46,
        alignment = 0.5,
        spacing = -3
    }
    -- speed gauge (with formatting for correct digit positions with additional digits appearing)
    digitCoords = {
        -- define your coords here
        vec2(670, 1230), -- the leftmost digit
        vec2(770, 1230), -- the center digit
        vec2(870, 1230) -- the rightmost digit
    }
    -- preparing our table of speed digits
    local displayspeed = tostring(math.floor(car.poweredWheelsSpeed)) -- math.floor rounds to the next full number
    local speedTable = {}
    for i = 1, string.len(displayspeed) do
        speedTable[i] = displayspeed:sub(i, i)
    end
    if string.len(displayspeed) == 1 then
        display.text {
            -- rightmost digit
            text = speedTable[1],
            pos = digitCoords[3],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0
        }
    elseif string.len(displayspeed) == 2 then
        display.text {
            -- rightmost digit
            text = speedTable[2],
            pos = digitCoords[3],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0
        }
        display.text {
            -- center digit
            text = speedTable[1],
            pos = digitCoords[2],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0
        }
    elseif string.len(displayspeed) == 3 then
        display.text {
            -- rightmost digit
            text = speedTable[3],
            pos = digitCoords[3],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0
        }
        display.text {
            -- center digit
            text = speedTable[2],
            pos = digitCoords[2],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0
        }
        display.text {
            -- leftmost digit
            text = speedTable[1],
            pos = digitCoords[1],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0
        }
    end
    -- oil pressure warning light
    if (car.oilPressure <= 1) then -- if oil pressure equals or drops below 1bar image gets displayed at defined position
        display.image {
            image = "assets/OILW.dds",
            pos = vec2(1287, 1367), -- coordinates of top left corner
            size = vec2(175, 95)
        }
    end
    -- check engine light
    if (car.engineLifeLeft <= 600) then -- if engine life equals or drops below 600 life points image gets displayed, engine life is 0-1000
        display.image {
            image = "assets/ENG.dds",
            pos = vec2(1853, 1348), -- coordinates of top left corner
            size = vec2(180, 125)
        }
    end
end

function modeB(dt)
    display.rect {
        pos = vec2(9, 405), 
        size = vec2(1400, 940),
        color = rgbm(0.55, 0.55, 0.55, 1)
    }

local value = math.saturate(math.min(car.rpm, 7000) / 8000) -- saturate clamps value between 0 and 1
    display.rect {
        color =rgbm(1, 0.8, 0, 1),
        pos = vec2(50, 1350), -- coordinates of top left corner of the texture, pay attention to resolution of that texture
        size = vec2(1400,  -value * 905), -- size of the image, "value *" makes it expand towards that maximum value
        uvStart = vec2(0, 0), -- uv coordinate of the top left corner (default is 0, 0)
        uvEnd = vec2(1, 1) -- uv coordinate of the bottom right corner (default is 1, 1), 0-8000rpms = value, 1 as range for the "uncovering fo the texture"
    }

local value = math.saturate((math.min(car.rpm, 8000)-7000) / 8000) -- saturate clamps value between 0 and 1
    display.rect {
        color =rgbm(1, 0, 0, 1),
        pos = vec2(50, 562), -- coordinates of top left corner of the texture, pay attention to resolution of that texture
        size = vec2(1400,  -value * 1150), -- size of the image, "value *" makes it expand towards that maximum value
        uvStart = vec2(0, 0), -- uv coordinate of the top left corner (default is 0, 0)
        uvEnd = vec2(1, 1) -- uv coordinate of the bottom right corner (default is 1, 1), 0-8000rpms = value, 1 as range for the "uncovering fo the texture"
    }

    display.image {
        image = "assets/ADU4.dds",
        pos = vec2(0, 399), -- coordinates of top left corner
        size = vec2(2048, 1248)
    }

    local value = math.saturate((car.oilTemperature / 140) - 0.32)
    display.rect {
        pos = vec2(140, 1478),
        size = vec2(value * 409, 69),
        color = rgbm(1, 0.8, 0, 1),
        uvStart = vec2(0, 0),
        uvEnd = vec2(value, 1)
    }
    display.text {
        text = string.format("%.1f", car.oilTemperature),
        pos = vec2(147, 1471),
        letter = vec2(45, 90),
        font = "c7_new",
        width = 1,
        alignment = 1,
        spacing = -10,
        color = rgbm(0, 0, 0, 1)
    }
    local value = math.saturate((car.waterTemperature / 120) - 0.16)
    display.rect {
        pos = vec2(820, 1478),
        size = vec2(value * 409, 69),
        color = rgbm(1, 0.8, 0, 1),
        uvStart = vec2(0, 0),
        uvEnd = vec2(value, 1)
    }
    display.text {
        text = string.format("%.1f", car.waterTemperature),
        pos = vec2(825, 1471),
        letter = vec2(45, 90),
        font = "c7_new",
        width = 1,
        alignment = 1,
        spacing = -10,
        color = rgbm(0, 0, 0, 1)
    }
    local value = math.saturate(car.oilPressure / 8)
    display.rect {
        pos = vec2(1498, 1478),
        size = vec2(value * 409, 69),
        color = rgbm(1, 0.8, 0, 1),
        uvStart = vec2(0, 0),
        uvEnd = vec2(value, 1)
    }
    display.text {
        text = string.format("%.1f", car.oilPressure),
        pos = vec2(1505, 1471),
        letter = vec2(45, 90),
        font = "c7_new",
        width = 1,
        alignment = 1,
        spacing = -10,
        color = rgbm(0, 0, 0, 1)
    }
    -- speed gauge (with formatting for correct digit positions with additional digits appearing)
    digitCoords = {
        -- define your coords here
        vec2(1430, 1130), -- the leftmost digit
        vec2(1530, 1130), -- the center digit
        vec2(1630, 1130) -- the rightmost digit
    }
    -- preparing our table of speed digits
    local displayspeed = tostring(math.floor(car.poweredWheelsSpeed)) -- math.floor rounds to the next full number
    local speedTable = {}
    for i = 1, string.len(displayspeed) do
        speedTable[i] = displayspeed:sub(i, i)
    end
    if string.len(displayspeed) == 1 then
        display.text {
            -- rightmost digit
            text = speedTable[1],
            pos = digitCoords[3],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0,
            color = rgbm(0, 0, 0, 1)
        }
    elseif string.len(displayspeed) == 2 then
        display.text {
            -- rightmost digit
            text = speedTable[2],
            pos = digitCoords[3],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0,
            color = rgbm(0, 0, 0, 1)
        }
        display.text {
            -- center digit
            text = speedTable[1],
            pos = digitCoords[2],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0,
            color = rgbm(0, 0, 0, 1)
        }
    elseif string.len(displayspeed) == 3 then
        display.text {
            -- rightmost digit
            text = speedTable[3],
            pos = digitCoords[3],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0,
            color = rgbm(0, 0, 0, 1)
        }
        display.text {
            -- center digit
            text = speedTable[2],
            pos = digitCoords[2],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0,
            color = rgbm(0, 0, 0, 1)
        }
        display.text {
            -- leftmost digit
            text = speedTable[1],
            pos = digitCoords[1],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0,
            color = rgbm(0, 0, 0, 1)
        }
    end
		-- gear display
		local gearText = tostring(car.gear) -- needs to be converted so that neutral and reverse display correctly (-1 = R, 0 = N)
		if car.gear == -1 then
			gearText = "R"
		end
		if car.gear == 0 then
			gearText = "N"
		end
		display.text {
			text = gearText,
			pos = vec2(1500, 380),
			letter = vec2(500, 830),
			font = "c7_new",
			width = 46,
			alignment = 0.5,
			spacing = 0
		}
		-- numeric rpm gauge
		display.text {
			text = math.floor(car.rpm),
			pos = vec2(15, 400),
			letter = vec2(90, 180),
			font = "c7_new",
			width = 1,
			alignment = 1,
			spacing = -12,
			color = rgbm(0, 0, 0, 1)
		}
	end

function modeC(dt)
	-- grey background for second screen, draws on top of mesh texture so pay attention to transparency, might need layering depending on what youre doing
    display.rect {
        pos = vec2(9, 405), 
        size = vec2(1800, 990),
        color = rgbm(0.55, 0.55, 0.55, 1)
    }
    -- rpm gauge
    local rpmPercentage = (car.rpm / 8000 * 100) -- conversion to %


    local amountOfSquares = math.ceil(rpmPercentage/6.25) -- only render the squares the user will actually see, for performance.

    local color = rgbm(1, 0.8, 0, 1) -- normal colour of the displayed rectangle
    if Config.ADU2.ShiftWarn < (car.rpm / car.rpmLimiter * 100) then -- if rpms exceed Configured Value colour switches
        color = rgbm(255, 0, 0, 255)
    end
    local rpmPos = vec2(610, 1216)
    local rpmSize = vec2(200, 200)
    local rpmPivot = vec2(1028, 1028)

    for i = 1, amountOfSquares do
        local thisRotation = (-rpmPercentage) * 2.7 -- "-" turns rotation counter clockwise
        ui.beginRotation()
        ui.beginRotation()
        display.rect {
            -- draws rectangle
            pos = rpmPos,
            size = rpmSize,
            color = color
        }
        ui.endRotation(28)
        if rpmPercentage > (100 / 16 * i) then
            thisRotation = -(100 / 16 * i) * 2.7
        end
        ui.endPivotRotation(thisRotation + 107, rpmPivot)
    end


    -- actual background for second screen, last in line since script runs top to bottom and transparency layer needs to be at the very top of the stack
    display.image {
        image = "assets/ADU5.dds",
        pos = vec2(0, 399), -- coordinates of top left corner
        size = vec2(2048, 1248)    
	}	
	local value = math.saturate((car.oilTemperature / 140) - 0.32)
    display.rect {
        pos = vec2(1575, 526),
        size = vec2(value * 411, 71),
        color = rgbm(1, 0.8, 0, 1),
        uvStart = vec2(0, 0),
        uvEnd = vec2(value, 1)
    }
    display.text {
        text = string.format("%.1f", car.oilTemperature),
        pos = vec2(1585, 520),
        letter = vec2(45, 90),
        font = "c7_new",
        width = 1,
        alignment = 1,
        spacing = -10,
        color = rgbm(0, 0, 0, 1)
    }
    local value = math.saturate((car.waterTemperature / 120) - 0.16)
    display.rect {
        pos = vec2(56, 527),
        size = vec2(value * 408, 69),
        color = rgbm(1, 0.8, 0, 1),
        uvStart = vec2(0, 0),
        uvEnd = vec2(value, 1)
    }
    display.text {
        text = string.format("%.1f", car.waterTemperature),
        pos = vec2(65, 522),
        letter = vec2(45, 90),
        font = "c7_new",
        width = 1,
        alignment = 1,
        spacing = -10,
        color = rgbm(0, 0, 0, 1)
    }
    local value = math.saturate(car.oilPressure / 8)
    display.rect {
        pos = vec2(1684, 828),
        size = vec2(value * 311, 70),
        color = rgbm(1, 0.8, 0, 1),
        uvStart = vec2(0, 0),
        uvEnd = vec2(value, 1)
    }
    display.text {
        text = string.format("%.1f", car.oilPressure),
        pos = vec2(1690, 822),
        letter = vec2(45, 90),
        font = "c7_new",
        width = 1,
        alignment = 1,
        spacing = -10,
        color = rgbm(0, 0, 0, 1)
    }
	local value = math.saturate(car.fuel / car.maxFuel) -- in %
    display.rect {
        pos = vec2(56, 828),
        size = vec2(value * 306, 69),
        color = rgbm(1, 0.8, 0, 1),
        uvStart = vec2(0, 0),
        uvEnd = vec2(value, 1)
    }
	display.text {
        text = string.format("%.0f", car.fuel/car.maxFuel*100), -- in %
        pos = vec2(65, 822),
        letter = vec2(45, 90),
        font = "c7_new",
        width = 1,
        alignment = 1,
        spacing = -6,
        color = rgbm(0, 0, 0, 1)
    }
	 -- gear display
    local gearText = tostring(car.gear) -- needs to be converted so that neutral and reverse display correctly (-1 = R, 0 = N)
    if car.gear == -1 then
        gearText = "R"
    end
    if car.gear == 0 then
        gearText = "N"
    end
    display.text {
        text = gearText,
        pos = vec2(820, 670),
        letter = vec2(400, 730),
        font = "c7_new",
        width = 46,
        alignment = 0.5,
        spacing = 0
    }

	-- speed gauge (with formatting for correct digit positions with additional digits appearing)
    digitCoords = {
        -- define your coords here
        vec2(1530, 1470), -- the leftmost digit
        vec2(1610, 1470), -- the center digit
        vec2(1700, 1470) -- the rightmost digit
    }
    -- preparing our table of speed digits
    local displayspeed = tostring(math.floor(car.poweredWheelsSpeed)) -- math.floor rounds to the next full number
    local speedTable = {}
    for i = 1, string.len(displayspeed) do
        speedTable[i] = displayspeed:sub(i, i)
    end
    if string.len(displayspeed) == 1 then
        display.text {
            -- rightmost digit
            text = speedTable[1],
            pos = digitCoords[3],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0,
            color = rgbm(0, 0, 0, 1)
        }
    elseif string.len(displayspeed) == 2 then
        display.text {
            -- rightmost digit
            text = speedTable[2],
            pos = digitCoords[3],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0,
            color = rgbm(0, 0, 0, 1)
        }
        display.text {
            -- center digit
            text = speedTable[1],
            pos = digitCoords[2],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0,
            color = rgbm(0, 0, 0, 1)
        }
    elseif string.len(displayspeed) == 3 then
        display.text {
            -- rightmost digit
            text = speedTable[3],
            pos = digitCoords[3],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0,
            color = rgbm(0, 0, 0, 1)
        }
        display.text {
            -- center digit
            text = speedTable[2],
            pos = digitCoords[2],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0,
            color = rgbm(0, 0, 0, 1)
        }
        display.text {
            -- leftmost digit
            text = speedTable[1],
            pos = digitCoords[1],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0,
            color = rgbm(0, 0, 0, 1)
        }
    end
		digitCoords = {
        -- define your coords here
        vec2(755, 1260), --left quad
        vec2(815, 1260), --left triple
        vec2(875, 1260), --left dual
        vec2(935, 1260), --center
        vec2(995, 1260), --right dual
        vec2(1055, 1260),--right triple    
        vec2(1115, 1260) --right quad
    }
    -- preparing our table of rpm digits
    local displayrpm = tostring(math.floor(car.rpm))
    local rpmTable = {}
    for i = 1, string.len(displayrpm) do
        rpmTable[i] = displayrpm:sub(i, i)
    end
    if string.len(displayrpm) == 1 then
        display.text {
            -- rightmost digit
            text = rpmTable[1],
            pos = digitCoords[4],
            letter = vec2(145, 240),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = 1.0
        }
    elseif string.len(displayrpm) == 2 then
        display.text {
            -- rightmost digit
            text = rpmTable[2],
            pos = digitCoords[5],
            letter = vec2(145, 240),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = 1.0
        }
        display.text {
            -- leftmost digit
            text = rpmTable[1],
            pos = digitCoords[3],
            letter = vec2(145, 240),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = 1.0
        }
    elseif string.len(displayrpm) == 3 then
        display.text {
            -- rightmost digit
            text = rpmTable[3],
            pos = digitCoords[6],
            letter = vec2(145, 240),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = 1.0
        }
        display.text {
            -- center digit
            text = rpmTable[2],
            pos = digitCoords[4],
            letter = vec2(145, 240),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = 1.0
        }
        display.text {
            -- leftmost digit
            text = rpmTable[1],
            pos = digitCoords[2],
            letter = vec2(145, 240),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = 1.0
        }
    elseif string.len(displayrpm) == 4 then
        display.text {
            -- rightmost digit
            text = rpmTable[4],
            pos = digitCoords[7],
            letter = vec2(145, 240),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = 1.0
        }
        display.text {
            -- center digit
            text = rpmTable[3],
            pos = digitCoords[5],
            letter = vec2(145, 240),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = 1.0
        }
        display.text {
            -- leftmost digit
            text = rpmTable[2],
            pos = digitCoords[3],
            letter = vec2(145, 240),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = 1.0
        }
        display.text {
            -- leftmost digit
            text = rpmTable[1],
            pos = digitCoords[1],
            letter = vec2(145, 240),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = 1.0
        }
    end
		display.text {
			text = string.format("%02d:%02d:%02d", sim.timeHours, sim.timeMinutes, sim.timeSeconds),
			pos = vec2(95, 1494),
			letter = vec2(65, 160),
			font = "c7_new",
			width = 1,
			alignment = 0.5,
			spacing = -10,
			color = rgbm(0,0,0,1)
    }
	 -- check engine light
    if (car.engineLifeLeft <= 600) then -- if engine life equals or drops below 600 life points image gets displayed, engine life is 0-1000
        display.image {
            image = "assets/ENG.dds",
            pos = vec2(57, 1320), -- coordinates of top left corner
            size = vec2(180, 125)
        }
    end
	
	 if (car.batteryVoltage <= 9) then
        display.image {
            image = "assets/BATTERYW.dds",
            pos = vec2(1817, 1324), -- coordinates of top left corner
            size = vec2(150, 113)
        }
    end
end	

-- didplay switch
local listOfModes = {modeA, modeB, modeC} -- you can add infinite displays, their elements need to be inside function modeN(dt)
local currentMode = tonumber(ac.loadDisplayValue("displayMode", 1))
local lastExtraCState = false

function update(dt)
    ac.debug("Update Delta", dt)
    if car.extraC ~= lastExtraCState then -- switching is bound to extraC key, this tracks the state of extraC
        currentMode = currentMode + 1 -- you start at mode 1 and each extraC press adds +1 to the mode count
        if currentMode > #listOfModes then -- as soon as your mode counter exceeds the number of modes inside listOfModes it defaults back to mode 1
            currentMode = 1 -- should be the same as local currentMode =
        end
        ac.saveDisplayValue("displayMode", currentMode)
    end
    ac.debug("Current Page", currentMode)
    lastExtraCState = car.extraC
    listOfModes[currentMode](dt)
end

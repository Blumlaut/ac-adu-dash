
colors = { -- helper table to define some colours
blue = rgbm(0.05,0.1,1,1),
green = rgbm(0,1,0,1),
yellow = rgbm(0.95,1,0,1),
orange = rgbm(1,0.5,0,1),
darkorange = rgbm(1,0.2,0,1),
red = rgbm(1,0,0,1)
}


ledConfig = {
[1] = {
	-- menu number
	FlashAll = 95, -- or -1, for off.
	FlashAllColor = colors.red, -- color for all LEDs flashing
	FlashDelay = 5, -- more is slower
	[4] = {
		-- number of the led, left to right
		rpm = 70, -- percentage of rpm
		color = colors.green -- color of light
	},
	[12] = {
		rpm = 70,
		color = colors.green
	},
	[5] = {
		rpm = 80,
		color = colors.yellow
	},
	[11] = {
		rpm = 80,
		color = colors.yellow
	},
	[6] = {
		rpm = 84,
		color = colors.orange
	},
	[10] = {
		rpm = 84,
		color = colors.orange
	},
	[7] = {
		rpm = 88,
		color = colors.darkorange
	},
	[9] = {
		rpm = 88,
		color = colors.darkorange
	},
	[8] = {
		rpm = 92,
		color = colors.red       
	}
},
[2] = {
	-- menu number
	FlashAll = 95, -- or -1, for off.
	FlashAllColor = colors.blue, -- color for all LEDs flashing
	FlashDelay = 5, -- more is slower
	[4] = {
		-- number of the led, left to right
		rpm = 50, -- percentage of rpm
		color = colors.blue -- color of light
	},
	[5] = {
		rpm = 55,
		color = colors.blue
	},
	[6] = {
		rpm = 60,
		color = colors.blue
	},
	[7] = {
		rpm = 65,
		color = colors.yellow
	},
	[8] = {
		rpm = 70,
		color = colors.yellow
	},
	[9] = {
		rpm = 75,
		color = colors.yellow
	},
	[10] = {
		rpm = 80,
		color = colors.red
	},
	[11] = {
		rpm = 85,
		color = colors.red
	},
	[12] = {
		rpm = 90,
		color = colors.red
	},
	 [1] = {
		rpm = 100,
		color = colors.red
	},
	 [2] = {
		rpm = 100,
		color = colors.red
	},
	 [3] = {
		rpm = 100,
		color = colors.red
	},
	 [13] = {
		rpm = 100,
		color = colors.red
	},
	 [14] = {
		rpm = 100,
		color = colors.red
	}, 
	[15] = {
		rpm = 100,
		color = colors.red
	}
},
}



ledArray = { -- helper table for each LED
[1] = {
	pos = vec2(0, 0),
	size = vec2(24,24),
},
[2] = {
	pos = vec2(24, 0),
	size = vec2(24,24),
},
[3] = {
	pos = vec2(49, 0),
	size = vec2(24,24),
},
[4] = {
	pos = vec2(74, 0),
	size = vec2(24,24),
},
[5] = {
	pos = vec2(0, 24),
	size = vec2(24,24),
},
[6] = {
	pos = vec2(24, 24),
	size = vec2(24,24),
},
[7] = {
	pos = vec2(49, 24),
	size = vec2(24,24),
},
[8] = {
	pos = vec2(74, 24),
	size = vec2(24,24),
},
[9] = {
	pos = vec2(0, 49),
	size = vec2(24,24),
},
[10] = {
	pos = vec2(24, 49),
	size = vec2(24,24),
},
[11] = {
	pos = vec2(49, 49),
	size = vec2(24,24),
},
[12] = {
	pos = vec2(74, 49),
	size = vec2(24,24),
},
[13] = {
	pos = vec2(0, 73),
	size = vec2(24,24),
},
[14] = {
	pos = vec2(24, 73),
	size = vec2(24,24),
},
[15] = {
	pos = vec2(49, 73),
	size = vec2(24,24),
}
}

local shiftWarnOn = true
local shiftWarnCycle = 0


local displayMode = tonumber(ac.loadDisplayValue("rpmMode", 1))
local lastExtraBState = false


function update(dt)

if car.extraB ~= lastExtraBState then
	displayMode = displayMode + 1
	if displayMode > #ledConfig then
		displayMode = 1
	end
	ac.saveDisplayValue("rpmMode", displayMode)
end
ac.debug("Current LED Mode", displayMode)
lastExtraBState = car.extraB

local rpmPercentage = (car.rpm / car.rpmLimiter * 100)
local currentConfig = ledConfig[displayMode] -- dont need to find it in table every time

if shiftWarnCycle < currentConfig.FlashDelay and currentConfig.FlashAll < rpmPercentage then
	shiftWarnCycle = shiftWarnCycle +1
else
	shiftWarnCycle = 0
	shiftWarnOn = not shiftWarnOn
end

for i, led in pairs(ledArray) do
	if currentConfig[i] then
		local ledColor = currentConfig[i].color
		if currentConfig.FlashAll > 0 and currentConfig.FlashAll < rpmPercentage then
			if shiftWarnOn then
				ledColor = currentConfig.FlashAllColor
			end
		else 
			shiftWarnOn = true
		end

		if (not (currentConfig.FlashAll < rpmPercentage) and currentConfig[i].rpm < rpmPercentage) or (currentConfig.FlashAll < rpmPercentage and shiftWarnOn) then
			display.rect {
				pos = led.pos,
				size = led.size,
				color = ledColor
			}
		end
	end
end
end

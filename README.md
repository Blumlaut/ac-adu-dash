# ac-adu-dash
ECUMaster ADU Dash for Assetto Corsa, utilising CSP

ac-adu-dash is a replica of a ECUMaster ADU5 Dash, made in Assetto Corsa, it is designed to be added to existing cars using the car's `ext_config.ini`

![edu](https://user-images.githubusercontent.com/13604413/155331867-91d6e980-a3f7-4507-a513-cfcb7799fd63.gif)



## Features

ac-adu-dash features 3 dashboards by default, with different layouts and information, including but not limited to:
- Different types of RPM Display
- G-Meter 
- Vehicle Information such as Oil, Water, Fuel, Battery Voltage
- RPM Lights with 2 different modes

## Requirements

ac-adu-dash expects a CSP Version above or equal to 1.76. 


## Installation

Due to ac-adu-dash's nature, it can be added to _any_ car by editing the `ext_config.ini`, here is an example for the Kunos BMW E30:

```
[INCLUDE: ADU.ini]

[MODEL_REPLACEMENT_...]
ACTIVE = 1
FILE = bmw_m3_e30.kn5 ; model name of the car
INSERT = ADU5.kn5 ; ADU model, do not change
INSERT_IN = COCKPIT_HR ; insert it in cockpit
; Options to transform inserted model:
SCALE = 1.2,1.1,1.1     ; change size: X, Y and Z axis (for car, X is left-right, Y and up-down)
ROTATION = 0, 23, 0  ; rotate: heading, pitch and roll, in degress
OFFSET = 0.317, 0.893, 0.520    ; move: X, Y and Z axis, in meters
```

The KN5, .lua files and assets folder have to also be added to the `extension` folder.

## Usage

After loading into the game, the Dash should be visible:

![image](https://user-images.githubusercontent.com/13604413/155333634-553a6bcd-e660-437c-a8c4-b3076a02c9c1.png)

Menus can be cycled with ALT+Numpad9, the RPM Lights can be cycled with ALT+Numpad8. (ExtraC and ExtraB respectively.)


## License

You are allowed to use, edit and redistribute modified versions of `ac-adu-dash`, however, we require that you give credit and link to this original project when doing so.

Please do not sell, or ship ac-adu-dash alongside paid models, cars or software.

Contributions via Pull Requests are very much encouraged.

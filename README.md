# ac-adu-dash
ECUMaster ADU Dash for Assetto Corsa, utilising CSP


TODO: explain how this works


Example Config for the E30 Drift:

```
[MODEL_REPLACEMENT_...]
ACTIVE = 1
FILE = bmw_m3_e30.kn5 ; you can find the name of the car kn5 in the folder of your car.
INSERT = ADU5.kn5
INSERT_IN = COCKPIT_HR ; insert it in cockpit
; Options to transform inserted model:
SCALE = 1.2,1.1,1.1     ; change size: X, Y and Z axis (for car, X is left-right, Y and up-down)
ROTATION = 0, 23, 0  ; rotate: heading, pitch and roll, in degress
OFFSET = 0.317, 0.893, 0.520    ; move: X, Y and Z axis, in meters
```

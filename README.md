Irrigation
----------
Adds a level of difficulty to farming with the addition of
non-spilling and self-exhausing water group nodes to wet dry soil.

Keep their water supplies full, or let the farm dry up.

Optionally discourages water griefing by limiting bucket spilling.

monk (c.2024)

Details
-------
## well.lua
  - Fills with water based on timer.
  - Provides 100 buckets of water when filled.
  - For one bucket, time is 14.4 minutes
  - Time to fill to max capacity: 24 hours

## barrel.lua
  - Wets dry soil like water node for up to 4 hours
  - 4 buckets to fill max capacity

## reservoir.lua
  - Wets dry soil like water node for up to 8 hours
  - 8 buckets to fill max capacity

## pipe.lua (Incomplete)
  - Connects to Reservoir node to extend watering
    - How to transfer node group from Reservoir?
    - ?


Attributes
----------
```
Irrigation is Based on the Rainbarrel mod
  https://notabug.org/Piezo_/rainbarrel
  GNU Lesser General Public License, version 2.1
  Copyright (C) 2019 Piezo_

`irrigation_well.obj` model obtained from Rainbarrel mod
  https://notabug.org/Piezo_/rainbarrel
  Attribution-ShareAlike 4.0 (CC BY-SA 4.0)
  Copyright (C) 2019 "Piezo_"

`irrigation_barrel_*.png` textures modified by monk without endorsement obtained from:
  https://codeberg.org/Wuzzy/xdecor-libre
  CC0 1.0 Universal
  Copyright (c) 2015-2021 kilbith <jeanpatrick.guerrero@gmail.com>
  CC0 (credits: Gambit, kilbith, Cisoun)
```

##
**`0.0.1`**

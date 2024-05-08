Irrigation
----------
monk | 2024

Adds a level of difficulty to farming with the addition of
non-spilling and self-exhausing water group nodes to wet dry soil.

Keep their water supplies full, or let the farm dry up.

Optionally discourages water griefing by limiting bucket spilling.

Based on the Rainbarrel mod https://notabug.org/Piezo_/rainbarrel
  Copyright (C) 2019 Piezo_

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

## bucket.lua (Bucket from minetest_game)
  - Disabled by default to avoid conflict with minetest_game
    - If it is enabled, add protector dependency to mod.conf
  - Modified to limit placing liquids at height
  - Disallows spilling liquid if area is not protected,
    also if y-50 contains protector not owned by player

##
**`0.0.1`**
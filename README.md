Irrigation
----------
Add a level of difficulty to farming with the addition of
contained and self-exhausing water group nodes to wet dry soil.

Keep their water supplies full, or let the farm dry up.

MIT © 2026 monk https://github.com/monk-afk/irrigation

Details
-------

## well.lua
  - Fills with water based on timer
  - Provides 100 buckets of water when full
  - For one bucket, time is 14.4 minutes
  - Time to fill to max capacity: 24 hours

## barrel.lua
  - Hydrates soil for up to 3 hours
  - 3 buckets to fill max capacity

## reservoir.lua
  - Hydrates soil for up to 8 hours
  - 4 buckets to fill max capacity

## pipe.lua
  - Linked pipes from Reservoir extend hydration range
  - Maximum transfer length is 14 nodes
  - Water cannot pass through an empty reservoir
  - Pipes connect only on the same Y axis


Attributions
----------

```
Originally inspired by Rainbarrel mod
  https://notabug.org/Piezo_/rainbarrel
  GNU Lesser General Public License, version 2.1
  Copyright (C) 2019 Piezo_

"irrigation_well.obj" model (renamed from rainbarrel_well.obj)
License: CC BY-SA 4.0
Copyright (C) 2019 Piezo_

Modified barrel textures from X-Decor-libre
License: CC0 1.0
Credits: Gambit, kilbith, Cisoun
```

##
**`0.0.2`**

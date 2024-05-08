local path = minetest.get_modpath(minetest.get_current_modname()).."/"

dofile(path.."well.lua")

dofile(path.."barrel.lua")

dofile(path.."reservoir.lua")

-- dofile(path.."pipe.lua") -- to do, allows extending the reservoir watering range

-- dofile(path.."bucket.lua")

-- 
-- minetest.override_item("default:water_source", {
-- 	liquid_renewable = false,
-- })

-- minetest.override_item("default:water_flowing", {
-- 	liquid_renewable = false,
-- })

minetest.register_alias("homedecor:well", "irrigation:well")
minetest.register_alias("xdecor:barrel", "irrigation:water_barrel")

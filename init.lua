local path = core.get_modpath(core.get_current_modname()) .. "/"

dofile(path.."well.lua")

dofile(path.."barrel.lua")

dofile(path.."reservoir.lua")

-- dofile(path.."pipe.lua") -- to do, allows extending the reservoir watering range

core.register_alias("homedecor:well", "irrigation:well")
core.register_alias("xdecor:barrel", "irrigation:water_barrel")

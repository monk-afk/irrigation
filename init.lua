-- Irrigation
local path = core.get_modpath(core.get_current_modname())

dofile(path .. "/well.lua")
dofile(path .. "/barrel.lua")

local on_construct_or_destruct = dofile(path .. "/pipe.lua")

dofile(path .. "/reservoir.lua")(on_construct_or_destruct)

  -- aliases to remove ambiguity, no dependency lost if removed
core.register_alias("homedecor:well", "irrigation:well")
core.register_alias("xdecor:barrel", "irrigation:water_barrel")

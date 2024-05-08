--[[ Piping is supposed to connect to the reservoir to supply water to the farm area.
  But I haven't gotten around to figuring out how to make this work. ]]

local S = minetest.get_translator("irrigation")

local set_nodebox = function(box)
	local fixed = {}
		local x, y, z, w, h, l = unpack(box)
		fixed = {
			(x / 16) - 0.5,
			(y / 16) - 0.5,
			(z / 16) - 0.5,
			((x + w) / 16) - 0.5,
			((y + h) / 16) - 0.5,
			((z + l) / 16) - 0.5
		}
	return fixed
end

minetest.register_node("irrigation:water_pipe", {
    description = S("Irrigation Line"),
    paramtype = "light",
    walkable = true,
    sunlight_propagates = true,
    tiles = {"default_coral_skeleton.png"},
    drawtype = "nodebox",
    node_box = {
        type = "connected",
        fixed = {},
        connect_front = { -1/16, -0.5, -8/16, 1/16, -4/16, 1/16 },
        connect_left =  { -8/16, -0.5, -1/16, 1/16, -4/16, 1/16 },
        connect_back =  { -1/16, -0.5, -1/16, 1/16, -4/16, 8/16 },
        connect_right = { -1/16, -0.5, -1/16, 8/16, -4/16, 1/16 },
        disconnected_sides = {
            { -6/16, 8/16, -6/16, -4/16, 6/16,  6/16 },
            {  4/16, 8/16, -6/16,  6/16, 6/16,  6/16 },
            { -6/16, 8/16, -6/16,  6/16, 6/16, -4/16 },
            { -6/16, 8/16,  4/16,  6/16, 6/16,  6/16 }
        },
    },
    connects_to = {"irrigation:water_pipe", "irrigation:water_reservoir",},
    groups = {oddly_breakable_by_hand = 1},
    drop = {"irrigation:water_pipe"},
})
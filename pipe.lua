local S = core.get_translator(core.get_current_modname())

local active_pipe   = "irrigation:water_pipe_active"
local inactive_pipe = "irrigation:water_pipe"
local active_reservoir   = "irrigation:water_reservoir_active"
local inactive_reservoir = "irrigation:water_reservoir"
local default_radius = 14 -- active reservoir effective radius

  -- depth-first by recursion, breadth controlled by the coroutine with state mutation shared across stack frames
  -- activation_handler(A) starts
  -- get_next_pos(A) starts scanning neighbors
  -- first connected pipe B is found
      -- removed from pipes_in_area immediately
  -- coroutine yield(B)
  -- activation_handler(A) receives B
  -- activation_handler(B) starts before get_next_pos(A) finishes
  -- recursion until it hits a dead end
  -- return to resume after yield for B
  -- scanning continues for other neighbors of A

  -- target_state: true to activate inactive pipes, false to deactivate, nil does no swap
local function apply_pipe_state(pos, target_state)
  if target_state ~= nil then
    local swap_target = target_state and active_pipe or inactive_pipe
    if core.get_node(pos).name ~= swap_target then
        core.swap_node(pos, { name = swap_target })
    end
  end
end


local function adjacent_positions(pos)
  return {
    { x = pos.x + 1, y = pos.y, z = pos.z },
    { x = pos.x - 1, y = pos.y, z = pos.z },
    { x = pos.x,     y = pos.y, z = pos.z + 1 },
    { x = pos.x,     y = pos.y, z = pos.z - 1 },
  }
end

  -- serial traversal from a starting position
local function get_next_pos(pos, pipes_in_area)
  return coroutine.wrap(function()
    for _, adj_pos in ipairs(adjacent_positions(pos)) do
      local adj_pos_str = core.pos_to_string(adj_pos)

      if pipes_in_area[adj_pos_str] then
        local next_pos = pipes_in_area[adj_pos_str]
        pipes_in_area[adj_pos_str] = nil  -- dont re-visit
        coroutine.yield(next_pos)
      end
    end
  end)
end

  -- to travel a line starting at a given position, only touching nodes in pipes_in_area
local function activation_handler(current_pos, pipes_in_area, target_pipe_state)
  for next_pos in get_next_pos(current_pos, pipes_in_area) do
    if next_pos then
      apply_pipe_state(next_pos, target_pipe_state)
      activation_handler(next_pos, pipes_in_area, target_pipe_state)
    end
  end
end


local function add_radius_to_pos(pos, radius)
  return { x = pos.x + radius, y = pos.y, z = pos.z + radius },
         { x = pos.x - radius, y = pos.y, z = pos.z - radius }
end

  -- find nodes and index their coordinates
local function get_node_positions(center_pos, radius, find_nodes, known_positions)
  local pos1, pos2 = add_radius_to_pos(center_pos, radius)
  local nodes_in_area,_ = core.find_nodes_in_area(pos1, pos2, find_nodes, false)

  for _, node_pos in ipairs(nodes_in_area) do
    local pos_string = core.pos_to_string(node_pos)
    if not known_positions[pos_string] then
      known_positions[pos_string] = node_pos
    end
  end
end


local function on_construct_or_destruct(pos, node_name, target_state)
  local pipes_in_area = {}

    -- active_reservoir placed (function place_reservoir)
  if node_name == active_reservoir and target_state == true then
      -- find and activate connected pipes
    get_node_positions(pos, default_radius, {active_pipe, inactive_pipe}, pipes_in_area)
    activation_handler(pos, pipes_in_area, true)
    return
  end

  local reservoirs_in_area = {}

  -- inactive_pipe placed (node on_construct)
  if node_name == inactive_pipe and target_state == true then
    -- find active reservoirs in range
    get_node_positions(pos, default_radius, {active_reservoir}, reservoirs_in_area)

    if next(reservoirs_in_area) == nil then
      -- not connected to an active system
      return
    end

      -- collect pipes around each reservoir and activate their networks
    for _, reservoir_pos in pairs(reservoirs_in_area) do
      get_node_positions(reservoir_pos, default_radius, {active_pipe, inactive_pipe}, pipes_in_area)
    end

    for _, reservoir_pos in pairs(reservoirs_in_area) do
      activation_handler(reservoir_pos, pipes_in_area, true)
    end

    return
  end

    -- active_reservoir removed (node after_destruct) OR becomes inactive (node on_timer -> place_reservoir)
  if (node_name == active_reservoir or node_name == inactive_reservoir)
      and target_state == false then

      -- deactivate pipes connected to this reservoir position
    get_node_positions(pos, default_radius, {active_pipe, inactive_pipe}, pipes_in_area)
    activation_handler(pos, pipes_in_area, false)

      -- search wider area for other active reservoirs
    get_node_positions(pos, default_radius * 2, {active_reservoir}, reservoirs_in_area)

    if next(reservoirs_in_area) == nil then
      -- no remaining active reservoirs; everything stays off
      return
    end

      -- reactivate pipes connected to the remaining active reservoirs
    for _, reservoir_pos in pairs(reservoirs_in_area) do
      get_node_positions(reservoir_pos, default_radius, {active_pipe, inactive_pipe}, pipes_in_area)
    end

    for _, reservoir_pos in pairs(reservoirs_in_area) do
      activation_handler(reservoir_pos, pipes_in_area, true)
    end

    return
  end

    -- active_pipe removed (node after_destruct)
  if node_name == active_pipe and target_state == nil then
      -- find active reservoirs that might still feed the network
    get_node_positions(pos, default_radius, {active_reservoir}, reservoirs_in_area)

    if next(reservoirs_in_area) == nil then  -- none left, deactivate nearby pipes
      get_node_positions(pos, default_radius, {active_pipe, inactive_pipe}, pipes_in_area)

      for _, pipe_pos in pairs(pipes_in_area) do
        apply_pipe_state(pipe_pos, false)
      end
      return
    end

      -- collect pipes near those reservoirs
    for _, reservoir_pos in pairs(reservoirs_in_area) do
      get_node_positions(reservoir_pos, default_radius, {active_pipe, inactive_pipe}, pipes_in_area)
    end

      -- traverse without swap
    for _, reservoir_pos in pairs(reservoirs_in_area) do
      activation_handler(reservoir_pos, pipes_in_area, nil)
    end

    -- remaining pipes are assumed to be disconnected
    for _, pipe_pos in pairs(pipes_in_area) do
      apply_pipe_state(pipe_pos, false)
    end

    return
  end
end


core.register_node(inactive_pipe, {
  short_description = S("Irrigation Pipe"),
  description = S("Extends watering range from Reservoir"),
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
      { -6/16, -8/16, -6/16, -4/16, -6/16,  6/16 },
      {  4/16, -8/16, -6/16,  6/16, -6/16,  6/16 },
      { -6/16, -8/16, -6/16,  6/16, -6/16, -4/16 },
      { -6/16, -8/16,  4/16,  6/16, -6/16,  6/16 }
    },
  },
  connects_to = {
    inactive_reservoir, active_reservoir,
    inactive_pipe, active_pipe,
  },
  groups = {choppy = 2},
  on_construct = function(pos)
    on_construct_or_destruct(pos, inactive_pipe, true)
  end
})


core.register_node(active_pipe, {
  description = S("Irrigation Pipe (Active)"),
  tiles = {"default_coral_skeleton.png^[colorize:#3cf:100"},
  paramtype = "light",
  walkable = true,
  drawtype = "nodebox",
  sunlight_propagates = true,
  node_box = {
    type = "connected",
    fixed = {},
    connect_front = { -1/16, -0.5, -8/16, 1/16, -4/16, 1/16 },
    connect_left =  { -8/16, -0.5, -1/16, 1/16, -4/16, 1/16 },
    connect_back =  { -1/16, -0.5, -1/16, 1/16, -4/16, 8/16 },
    connect_right = { -1/16, -0.5, -1/16, 8/16, -4/16, 1/16 },
    disconnected_sides = {
      { -6/16, -8/16, -6/16, -4/16, -6/16,  6/16 },
      {  4/16, -8/16, -6/16,  6/16, -6/16,  6/16 },
      { -6/16, -8/16, -6/16,  6/16, -6/16, -4/16 },
      { -6/16, -8/16,  4/16,  6/16, -6/16,  6/16 }
    },
  },
  connects_to = {
    inactive_reservoir, active_reservoir,
    inactive_pipe, active_pipe
  },
  groups = { choppy = 2, water = 1, not_in_creative_inventory = 1 },
  drop = inactive_pipe, -- don’t drop the active version

  after_destruct = function(pos)
    on_construct_or_destruct(pos, active_pipe, nil)
  end
})

core.register_craft({
  output = inactive_pipe,
  recipe = {
    {"default:tin_ingot","default:tin_ingot", "default:tin_ingot"},
  }
})

return on_construct_or_destruct
-- MIT © 2026 monk https://github.com/monk-afk/irrigation

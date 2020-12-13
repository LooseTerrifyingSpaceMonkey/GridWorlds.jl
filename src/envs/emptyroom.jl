export EmptyRoom

mutable struct EmptyRoom{R} <: AbstractGridWorld
    world::GridWorldBase{Tuple{Empty, Wall, Goal}}
    agent::Agent
    reward::Float64
    rng::R
    goal_reward::Float64
    goal_pos::CartesianIndex
end

function EmptyRoom(; height = 8, width = 8, rng = Random.GLOBAL_RNG)
    objects = (EMPTY, WALL, GOAL)
    world = GridWorldBase(objects, height, width)
    room = Room(CartesianIndex(1, 1), height, width)
    place_room!(world, room)

    goal_pos = CartesianIndex(height - 1, width - 1)
    world[GOAL, goal_pos] = true
    world[EMPTY, goal_pos] = false

    agent = Agent(pos = CartesianIndex(2, 2), dir = RIGHT)
    reward = 0.0
    goal_reward = 1.0

    env = EmptyRoom(world, agent, reward, rng, goal_reward, goal_pos)

    reset!(env)

    return env
end

function RLBase.reset!(env::EmptyRoom)
    world = get_world(env)
    rng = get_rng(env)

    old_goal_pos = get_goal_pos(env)
    world[GOAL, old_goal_pos] = false
    world[EMPTY, old_goal_pos] = true

    new_goal_pos = rand(rng, pos -> !world[WALL, pos], world)

    set_goal_pos!(env, new_goal_pos)
    world[GOAL, new_goal_pos] = true
    world[EMPTY, new_goal_pos] = false

    agent_start_pos = rand(rng, pos -> !(world[WALL, pos] || world[GOAL, pos]), world)
    agent_start_dir = rand(rng, DIRECTIONS)

    set_agent_pos!(env, agent_start_pos)
    set_agent_dir!(env, agent_start_dir)

    set_reward!(env, 0.0)

    return env
end

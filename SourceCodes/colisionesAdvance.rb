def tick args
  tick_instructions args, "Use LEFT and RIGHT arrow keys to move and SPACE to jump."
  defaults args
  render args
  calc args
  input args
end


def defaults args
  fiddle args
  args.state.enemy.hammers ||= []
  args.state.enemy.hammer_queue ||= []
  args.state.tick_count = args.state.tick_count
  args.state.bridge_top = 128
  args.state.player.x  ||= 0                        # initializes player's properties
  args.state.player.y  ||= args.state.bridge_top
  args.state.player.w  ||= 64
  args.state.player.h  ||= 64
  args.state.player.dy ||= 0
  args.state.player.dx ||= 0
  args.state.enemy.x   ||= 800                      # initializes enemy's properties
  args.state.enemy.y   ||= 0
  args.state.enemy.w   ||= 128
  args.state.enemy.h   ||= 128
  args.state.enemy.dy  ||= 0
  args.state.enemy.dx  ||= 0
  args.state.game_over_at ||= 0
end

def fiddle args
  args.state.gravity                     = -0.3
  args.state.enemy_jump_power            = 10    # sets enemy values
  args.state.enemy_jump_interval         = 60
  args.state.hammer_throw_interval       = 40       # sets hammer values
  args.state.hammer_launch_power_default = 5
  args.state.hammer_launch_power_near    = 2
  args.state.hammer_launch_power_far     = 7
  args.state.hammer_upward_launch_power  = 15
  args.state.max_hammers_per_volley      = 10
  args.state.gap_between_hammers         = 10
  args.state.player_jump_power           = 10    # sets player values
  args.state.player_jump_power_duration  = 10
  args.state.player_max_run_speed        = 10
  args.state.player_speed_slowdown_rate  = 0.9
  args.state.player_acceleration         = 1
  args.state.hammer_size                 = 32
end
def render args
  args.outputs.solids << 20.map_with_index do |i| # uses 20 squares to form bridge
    # sets x by multiplying 64 to index to find pixel value (places all squares side by side)
    # subtracts 64 from bridge_top because position is denoted by bottom left corner
    [i * 64, args.state.bridge_top - 64, 64, 64]
  end

  args.outputs.solids << [args.state.x, args.state.y, args.state.w, args.state.h, 145, 100, 0]
  args.outputs.solids << [args.state.player.x, args.state.player.y, args.state.player.w, args.state.player.h, 255, 0, 0] # outputs player onto screen (red box)
  args.outputs.solids << [args.state.enemy.x,args.state.enemy.y,  args.state.enemy.w , args.state.enemy.h, 15,53,2 ]
  args.outputs.solids << args.state.enemy.hammers # outputs enemy's hammers onto screen
end
def calc args

  # Since velocity is the change in position, the change in x increases by dx. Same with y and dy.
  args.state.player.x  += args.state.player.dx
  args.state.player.y  += args.state.player.dy

  # Since acceleration is the change in velocity, the change in y (dy) increases every frame
  args.state.player.dy += args.state.gravity

  # player's y position is either current y position or y position of top of
  # bridge, whichever has a greater value
  # ensures that the player never goes below the bridge
  args.state.player.y  = args.state.player.y.greater(args.state.bridge_top)

  # player's x position is either the current x position or 0, whichever has a greater value
  # ensures that the player doesn't go too far left (out of the screen's scope)
  args.state.player.x  = args.state.player.x.greater(0)

  # player is not falling if it is located on the top of the bridge
  args.state.player.falling = false if args.state.player.y == args.state.bridge_top
  args.state.player.rect = [args.state.player.x, args.state.player.y, args.state.player.h, args.state.player.w] # sets definition for player

  args.state.enemy.x += args.state.enemy.dx # velocity; change in x increases by dx
  args.state.enemy.y += args.state.enemy.dy # same with y and dy

  # ensures that the enemy never goes below the bridge
  args.state.enemy.y  = args.state.enemy.y.greater(args.state.bridge_top)

  # ensures that the enemy never goes too far left (outside the screen's scope)
  args.state.enemy.x  = args.state.enemy.x.greater(0)

  # objects that go up must come down because of gravity
  args.state.enemy.dy += args.state.gravity

  args.state.enemy.y  = args.state.enemy.y.greater(args.state.bridge_top)

  #sets definition of enemy
  args.state.enemy.rect = [args.state.enemy.x, args.state.enemy.y, args.state.enemy.h, args.state.enemy.w]

  if args.state.enemy.y == args.state.bridge_top # if enemy is located on the top of the bridge
    args.state.enemy.dy = 0 # there is no change in y
  end

  # if 60 frames have passed and the enemy is not moving vertically
  if args.state.tick_count.mod_zero?(args.state.enemy_jump_interval) && args.state.enemy.dy == 0
    args.state.enemy.dy = args.state.enemy_jump_power # the enemy jumps up
  end

  # if 40 frames have passed or 5 frames have passed since the game ended
  if args.state.tick_count.mod_zero?(args.state.hammer_throw_interval) || args.state.game_over_at.elapsed_time == 5
    # rand will return a number greater than or equal to 0 and less than given variable's value (since max is excluded)
    # that is why we're adding 1, to include the max possibility
    volley_dx   = (rand(args.state.hammer_launch_power_default) + 1) * -1 # horizontal movement (follow order of operations)

    # if the horizontal distance between the player and enemy is less than 128 pixels
    if (args.state.player.x - args.state.enemy.x).abs < 128
      # the change in x won't be that great since the enemy and player are closer to each other
      volley_dx = (rand(args.state.hammer_launch_power_near) + 1) * -1
    end

    # if the horizontal distance between the player and enemy is greater than 300 pixels
    if (args.state.player.x - args.state.enemy.x).abs > 300
      # change in x will be more drastic since player and enemy are so far apart
      volley_dx = (rand(args.state.hammer_launch_power_far) + 1) * -1 # more drastic change
    end

    (rand(args.state.max_hammers_per_volley) + 1).map_with_index do |i|
      args.state.enemy.hammer_queue << { # stores hammer values in a hash
        x: args.state.enemy.x,
        w: args.state.hammer_size,
        h: args.state.hammer_size,
        dx: volley_dx, # change in horizontal position
        # multiplication operator takes precedence over addition operator
        throw_at: args.state.tick_count + i * args.state.gap_between_hammers
      }
    end
  end

  # add elements from hammer_queue collection to the hammers collection by
  # finding all hammers that were thrown before the current frame (have already been thrown)
  args.state.enemy.hammers += args.state.enemy.hammer_queue.find_all do |h|
    h[:throw_at] < args.state.tick_count
  end

  args.state.enemy.hammers.each do |h| # sets values for all hammers in collection
    h[:y]  ||= args.state.enemy.y + 130
    h[:dy] ||= args.state.hammer_upward_launch_power
    h[:dy]  += args.state.gravity # acceleration is change in gravity
    h[:x]   += h[:dx] # incremented by change in position
    h[:y]   += h[:dy]
    h[:rect] = [h[:x], h[:y], h[:w], h[:h]] # sets definition of hammer's rect
  end

  # reject hammers that have been thrown before current frame (have already been thrown)
  args.state.enemy.hammer_queue = args.state.enemy.hammer_queue.reject do |h|
    h[:throw_at] < args.state.tick_count
  end

  # any hammers with a y position less than 0 are rejected from the hammers collection
  # since they have gone too far down (outside the scope's screen)
  args.state.enemy.hammers = args.state.enemy.hammers.reject { |h| h[:y] < 0 }

  # if there are any hammers that intersect with (or hit) the player,
  # the reset_player method is called (so the game can start over)
  if args.state.enemy.hammers.any? { |h| h[:rect].intersect_rect?(args.state.player.rect) }
    reset_player args
  end

  # if the enemy's rect intersects with (or hits) the player,
  # the reset_player method is called (so the game can start over)
  if args.state.enemy.rect.intersect_rect? args.state.player.rect
    reset_player args
  end
end

  # Resets the player by changing its properties back to the values they had at initialization
def reset_player args
  args.state.player.x = 0
  args.state.player.y = args.state.bridge_top
  args.state.player.dy = 0
  args.state.player.dx = 0
  args.state.enemy.hammers.clear # empties hammer collection
  args.state.enemy.hammer_queue.clear # empties hammer_queue
  args.state.game_over_at = args.state.tick_count # game_over_at set to current frame (or passage of time)
end
# Processes input from the user to move the player
def input args
  if args.inputs.keyboard.space # if the user presses the space bar
    args.state.player.jumped_at ||= args.state.tick_count # jumped_at is set to current frame

    # if the time that has passed since the jump is less than the player's jump duration and
    # the player is not falling
    if args.state.player.jumped_at.elapsed_time < args.state.player_jump_power_duration && !args.state.player.falling
      args.state.player.dy = args.state.player_jump_power # change in y is set to power of player's jump
    end
  end

  # if the space bar is in the "up" state (or not being pressed down)
  if args.inputs.keyboard.key_up.space
    args.state.player.jumped_at = nil # jumped_at is empty
    args.state.player.falling = true # the player is falling
  end

  if args.inputs.keyboard.left # if left key is pressed
    args.state.player.dx -= args.state.player_acceleration # dx decreases by acceleration (player goes left)
    # dx is either set to current dx or the negative max run speed (which would be -10),
    # whichever has a greater value
    args.state.player.dx = args.state.player.dx.greater(-args.state.player_max_run_speed)
  elsif args.inputs.keyboard.right # if right key is pressed
    args.state.player.dx += args.state.player_acceleration # dx increases by acceleration (player goes right)
    # dx is either set to current dx or max run speed (which would be 10),
    # whichever has a lesser value
    args.state.player.dx = args.state.player.dx.lesser(args.state.player_max_run_speed)
  else
    args.state.player.dx *= args.state.player_speed_slowdown_rate # dx is scaled down
  end
end
def tick_instructions args, text, y = 715
  return if args.state.key_event_occurred
  if args.inputs.mouse.click ||
     args.inputs.keyboard.directional_vector ||
     args.inputs.keyboard.key_down.enter ||
     args.inputs.keyboard.key_down.space ||
     args.inputs.keyboard.key_down.escape
    args.state.key_event_occurred = true
  end

  args.outputs.debug << [0, y - 50, 1280, 60].solid
  args.outputs.debug << [640, y, text, 1, 1, 255, 255, 255].label
  args.outputs.debug << [640, y - 25, "(click to dismiss instructions)" , -2, 1, 255, 255, 255].label
end





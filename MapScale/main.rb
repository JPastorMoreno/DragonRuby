def tick args
 
  args.state.world.w      ||= 1280
  args.state.world.h      ||= 720
  
  args.state.player.x     ||= 0
  args.state.player.y     ||= 0
  args.state.player.size  ||= 32


  args.state.camera.x                ||= 640
  args.state.camera.y                ||= 300
  args.state.camera.scale            = 1.5
  #IF empty space is enable, camera would be able to show what is not in the screen.
  args.state.camera.show_empty_space ||= :no

  args.outputs[:scene].w = args.state.world.w
  args.outputs[:scene].h = args.state.world.h


  args.outputs[:scene].sprites << { x: 0, y: 0, w: args.state.world.w, h: args.state.world.h, path: "tfgSprites/Arkanos.png"}
  args.outputs[:scene].primitives << { x: args.state.player.x, y: args.state.player.y,
    w: args.state.player.size, h: args.state.player.size, r: 80, g: 155, b: 80 }.solid

  scene_position = calc_scene_position args
  args.outputs.sprites << { x: scene_position.x,
    y: scene_position.y,
    w: scene_position.w,
    h: scene_position.h,
    path: :scene }

  args.state.camera.scale = args.state.camera.scale.greater(0.1)
    if args.inputs.directional_angle
      args.state.player.x += args.inputs.directional_angle.vector_x * 5
      args.state.player.y += args.inputs.directional_angle.vector_y * 5
      args.state.player.x  = args.state.player.x.clamp(0, args.state.world.w - args.state.player.size)
      args.state.player.y  = args.state.player.y.clamp(0, args.state.world.h - args.state.player.size)
      
      
    end
    save_game args
    load_game args
    start_music args
end

def calc_scene_position args
  result = { x: args.state.camera.x - (args.state.player.x * args.state.camera.scale),
             y: args.state.camera.y - (args.state.player.y * args.state.camera.scale),
             w: args.state.world.w * args.state.camera.scale,
             h: args.state.world.h * args.state.camera.scale,
             scale: args.state.camera.scale }

  return result if args.state.camera.show_empty_space == :yes

  if result.w < args.grid.w
    result.merge!(x: (args.grid.w - result.w).half)
  elsif (args.state.player.x * result.scale) < args.grid.w.half
    result.merge!(x: 10)
  elsif (result.x + result.w) < args.grid.w
    result.merge!(x: - result.w + (args.grid.w - 10))
  end

  if result.h < args.grid.h
    result.merge!(y: (args.grid.h - result.h).half)
  elsif (result.y) > 10
    result.merge!(y: 10)
  elsif (result.y + result.h) < args.grid.h
    result.merge!(y: - result.h + (args.grid.h - 10))
  end

  result
end

def start_music args
  args.audio[:my_audio] ||= {
    input: "sounds/Final Fantasy VIII - Disc 1 - 02 - Balamb Garden.wav",  # Filename
    x: 0.0, y: 0.0, z: 0.0,   # Relative position to the listener, x, y, z from -1.0 to 1.0
    gain: 0.5,                # Volume (0.0 to 1.0)
    pitch: 1.0,               # Pitch of the sound (1.0 = original pitch)
    paused: false,            # Set to true to pause the sound at the current playback position
    looping: false,           # Set to true to loop the sound/music until you stop it
  }
end
def save_game args
  args.gtk.save_state if args.inputs.keyboard.j
end

def load_game args
  args.gtk.load_state if args.inputs.keyboard.l
  args.audio = {} if args.inputs.keyboard.l
end

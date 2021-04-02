=begin

 Reminders:

 - String interpolation: Uses #{} syntax; everything between the #{ and the } is evaluated
   as Ruby code, and the placeholder is replaced with its corresponding value or result.

   In this sample app, we're using string interpolation to iterate through images in the
   sprites folder using their image path names.

 - args.outputs.sprites: An array. Values in this array generate sprites on the screen.
   The parameters are [X, Y, WIDTH, HEIGHT, IMAGE PATH]
   For more information about sprites, go to mygame/documentation/05-sprites.md.

 - args.outputs.labels: An array. Values in the array generate labels on the screen.
   The parameters are [X, Y, TEXT, SIZE, ALIGNMENT, RED, GREEN, BLUE, ALPHA, FONT STYLE]
   For more information about labels, go to mygame/documentation/02-labels.md.

 - args.inputs.keyboard.key_down.KEY: Determines if a key is in the down state, or pressed.
   Stores the frame that key was pressed on.
   For more information about the keyboard, go to mygame/documentation/06-keyboard.md.

=end

# This sample app demonstrates how sprite animations work.
# There are two sprites that animate forever and one sprite
# that *only* animates when you press the "f" key on the keyboard.

# This is the entry point to your game. The `tick` method
# executes at 60 frames per second. There are two methods
# in this tick "entry point": `looping_animation`, and the
# second method is `one_time_animation`.
def tick args
  looping_animation args
  one_time_animation args
end

def running_sprite args
  args.state.prueba ||= 0
  args.state.pruebaMove ||= 0
  tile_index = 0
  how_many_frames_in_sprite_sheet = 8
    how_many_ticks_to_hold_each_frame = 9
    should_the_index_repeat = true
    tile_index = args.state
                     .player
                     .started_running_at
                     .frame_index(how_many_frames_in_sprite_sheet,
                                  how_many_ticks_to_hold_each_frame,
                                  should_the_index_repeat)
  {
    x: 100 + args.state.pruebaMove,
    y: 200,
    w: 100,
    h: 100,
    path: 'tfgSprites/Prueba/ImagePrueba.png',
    tile_x: 0 + args.state.prueba,
    tile_y: 710,
    tile_w: 50,
    tile_h: 60,
    
  }
end
# This function shows how to animate a sprite that loops forever.
def looping_animation args
  # Here we define a few local variables that will be sent
  # into the magic function that gives us the correct sprite image
  # over time. There are four things we need in order to figure
  # out which sprite to show.

  # 1. When to start the animation.
  start_looping_at = 0

  # 2. The number of pngs that represent the full animation.
  number_of_sprites = 9

  # 3. How long to show each png.
  number_of_frames_to_show_each_sprite = 7

  # 4. Whether the animation should loop once, or forever.
  does_sprite_loop = true

  # With the variables defined above, we can get a number
  # which represents the sprite to show by calling the `frame_index` function.
  # In this case the number will be between 0, and 5 (you can see the sprites
  # in the ./sprites directory).
  sprite_index = start_looping_at.frame_index number_of_sprites,
                                              number_of_frames_to_show_each_sprite,
                                              does_sprite_loop

  # Now that we have `sprite_index, we can present the correct file.
  args.outputs.sprites << [100, 100, 100, 100, "sprites/misc/dragon-#{sprite_index}.png"]

  # Try changing the numbers below to see how the animation changes:
  args.outputs.sprites << running_sprite(args)
  #Seguimos el esquema del sprite index, primero el numero de sprites que tenemos disponibles, y despues el numero de frames 
  #que queremos que se muestre ese sprite, a más frames, mayor tiempo se tardará en llevar a cabo la animación.
end

# This function shows how to animate a sprite that executes
# only once when the "f" key is pressed.
def one_time_animation args
  # This is just a label the shows instructions within the game.
  args.outputs.labels << [220, 350, "(press f to animate)"]

  # If "f" is pressed on the keyboard...
  if args.inputs.keyboard.key_down.f
    # Print the frame that "f" was pressed on.
    puts "Hello from main.rb! The \"f\" key was in the down state on frame: #{args.inputs.keyboard.key_down.f}"

    # And MOST IMPORTANTLY set the point it time to start the animation,
    # equal to "now" which is represented as args.state.tick_count.

    # Also IMPORTANT, you'll notice that the value of when to start looping
    # is stored in `args.state`. This construct's values are retained across
    # executions of the `tick` method.
    args.state.start_looping_at = args.state.tick_count #Esta es la linea importante. 
    args.state.prueba = args.state.prueba + 64
    args.state.pruebaMove = args.state.pruebaMove + 10
    if  args.state.prueba > 510
      args.state.prueba=0
    end
  end
  # These are the same local variables that were defined
  # for the `looping_animation` function.
  number_of_sprites = 6
  number_of_frames_to_show_each_sprite = 4
  # Except this sprite does not loop again. If the animation time has passed,
  # then the frame_index function returns nil.
  does_sprite_loop = false
  sprite_index = args.state
                     .start_looping_at
                     .frame_index number_of_sprites,
                                  number_of_frames_to_show_each_sprite,
                                  does_sprite_loop

  # This line sets the frame index to zero, if
  # the animation duration has passed (frame_index returned nil).

  # Remeber: we are not looping forever here.
  sprite_index ||= 0

  # Present the sprite.
  args.outputs.sprites << [100, 300, 100, 100, "sprites/misc/dragon-#{sprite_index}.png"]

  tick_instructions args, "Sample app shows how to use Numeric#frame_index and string interpolation to animate a sprite over time."
end

def tick_instructions args, text, y = 715
  return if args.state.key_event_occurred
  if args.inputs.mouse.click ||
     args.inputs.keyboard.directional_vector ||
     args.inputs.keyboard.key_down.enter ||
     args.inputs.keyboard.key_down.escape
    args.state.key_event_occurred = true
  end

  args.outputs.debug << [0, y - 50, 1280, 60].solid
  args.outputs.debug << [640, y, text, 1, 1, 255, 255, 255].label
  args.outputs.debug << [640, y - 25, "(click to dismiss instructions)" , -2, 1, 255, 255, 255].label
end



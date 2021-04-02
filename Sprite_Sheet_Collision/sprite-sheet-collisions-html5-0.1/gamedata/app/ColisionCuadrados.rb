def tick args
  defaults args
  render args
  calc args
end


def defaults args
  #LLevaremos a cabo los distintos valores del cuadrado que vamos a realizar.
  args.state.moving_box_speed = 10
  args.state.moving_box_size = 100
  args.state.moving_box_dx ||= 1
  args.state.moving_box_dy ||= 1
  args.state.moving_box ||= [0, 0, args.state.moving_box_size, args.state.moving_box_size , 90, 60, 90] # moving_box_size is set as the width and height
  
  #Curiosamente es referida como un objeto global 

  # These values represent the center box.
  args.state.center_box ||= [540, 260, 200, 200, 180]
  args.state.center_box_collision ||= false # initially no collision
end

def render args
  if args.state.center_box_collision
    args.outputs.solids << args.state.center_box
  else
    args.outputs.borders << args.state.center_box
  end

  args.outputs.solids << args.state.moving_box
end

def calc args
  position_moving_box args
  determine_collision_center_box args
end

def position_moving_box args
  args.state.moving_box.x  += args.state.moving_box_dx * args.state.moving_box_speed
  args.state.moving_box.y  += args.state.moving_box_dy * args.state.moving_box_speed
  #Tamaño de la ventana para el juego.
  screen_width  = 1280
  screen_height = 720
  #Vamos a hacer los calculos para los limites Coordenada X
  if args.state.moving_box.x > screen_width - args.state.moving_box_size
      args.state.moving_box_dx = -1
  elsif args.state.moving_box.x < 0
    args.state.moving_box_dx = 1
  end
  #Limites Coordenadad Y 
  if args.state.moving_box.y > screen_height - args.state.moving_box_size
    args.state.moving_box_dy = -1
  elsif args.state.moving_box.y < 0
    args.state.moving_box_dy = 1
  end 
end


def determine_collision_center_box args
  # Collision is handled by the engine. You simply have to call the
  # `intersect_rect?` function.
  if args.state.moving_box.intersect_rect? args.state.center_box
    args.state.center_box_collision = true
  else 
    args.state.center_box_collision = false

  end
end

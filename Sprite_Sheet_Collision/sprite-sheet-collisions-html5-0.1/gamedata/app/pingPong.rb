

def tick args
  defaults args
  render args
  calc args
  input args
end

def defaults args
    args.state.racket_one.x = 120
    args.state.racket_one.y ||= 200
    args.state.racket_one.w = 30
    args.state.racket_one.h = 140
    args.state.racket_one_speed = 3
    args.state.racket_one.dy ||= 1
    
    
    args.state.racket_two.x = 1000
    args.state.racket_two.y ||= 200
    args.state.racket_two.w = 30
    args.state.racket_two.h = 140
    args.state.racket_two.dy ||= 1
   
    args.state.ball.dx ||= 1
    args.state.ball.dy ||= 1
    args.state.ball.w = 40
    args.state.ball_speed = 5
    args.state.center_box_collision ||= false
    args.state.contador1 ||= 0 
    args.state.contador2 ||=0
    contador = [args.state.contador1,args.state.contador2]
    args.outputs.labels << [150  + 250, 690 - 50,contador[0],0, 0, 255,   0,   0]
    args.outputs.labels << [600  + 150, 690 - 50,contador[1],0, 0, 255,   0,   0]
    
    args.state.racket_one.rect ||= [args.state.racket_one.x, args.state.racket_one.y, args.state.racket_one.w, args.state.racket_one.h, 80,200,100]
    args.state.racket_two.rect ||= [args.state.racket_two.x, args.state.racket_two.y, args.state.racket_two.w, args.state.racket_two.h, 180,200,100]
    args.state.balls ||= [300,200,args.state.ball.w,args.state.ball.w , 90, 60, 90]
    args.outputs.solids << args.state.balls

end
def render args
  args.outputs.solids << args.state.racket_one.rect
  args.outputs.solids << args.state.racket_two.rect
  
end

def calc args
  position_moving_box args
  determine_collision_center_box args
end

def position_moving_box args
  args.state.balls.x  += args.state.ball.dx * args.state.ball_speed
  args.state.balls.y  += args.state.ball.dy * args.state.ball_speed

  if args.state.ball.dy > 0 and args.state.ball.dy < 0.5
    args.state.racket_two.dy = args.state.ball.dy + 0.4
    args.state.racket_two.rect.y += args.state.racket_two.dy * 3
  elsif args.state.ball.dy > 0.5
    args.state.racket_two.dy =1
    args.state.racket_two.rect.y += args.state.racket_two.dy * 3
  elsif args.state.ball.dy <0 and args.state.ball.dy < (-0.5)
    args.state.racket_two.dy =args.state.ball.dy - 0.4
    args.state.racket_two.rect.y += args.state.racket_two.dy * 6
  elsif args.state.ball.dy < (-0.5 )
    args.state.racket_two.dy = args.state.ball.dy
    args.state.racket_two.rect.y += args.state.racket_two.dy * 3
  end
  

  args.state.racket_one.y += args.state.racket_one.dy * args.state.racket_one_speed

  args.outputs.sprites << 
      [args.state.balls.x - 15,args.state.balls.y - 8,70,70,
        'samples/02_sprite_animation_and_keyboard_input/sprites/descarga2.png',args.state.tick_count % 360]
  
  #Tamaño de la ventana para el juego.
  screen_width  = 1280
  screen_height = 720

  #Vamos a hacer los calculos para los limites Coordenada X
  if args.state.balls.x > screen_width - args.state.ball.w
    args.state.ball.dx = -1
  elsif args.state.balls.x < 0
    args.state.ball.dx = 1
  end
  #Limites Coordenadad Y 
  if args.state.balls.y > screen_height - args.state.ball.w
    args.state.ball.dy = -1
  elsif args.state.balls.y <= 0
    args.state.ball.dy = 1
  end 

  if args.state.balls.x < args.state.racket_one.x - 70
    args.state.contador2 += 1
    args.state.balls.x = 500
    args.state.balls.y = 400
    args.state.ball.dy = (rand * 1.2) - 1

  elsif args.state.balls.x > args.state.racket_two.x + 70
    args.state.contador1 += 1
    args.state.balls.x = 500
    args.state.balls.y = 400
    args.state.ball.dy = (rand * 1.2) - 1
  end
  #Tope para las raquetas.
  if args.state.racket_one.rect.y > screen_height - args.state.racket_one.h
    args.state.racket_one.rect.y = screen_height - args.state.racket_one.h
  end
  if args.state.racket_one.rect.y < 0
    args.state.racket_one.rect.y = 0
  end
  if args.state.racket_two.rect.y > screen_height - args.state.racket_one.h
    args.state.racket_two.rect.y = screen_height - args.state.racket_one.h
  end
  if args.state.racket_two.rect.y < 0
    args.state.racket_two.rect.y = 0
  end

  
end

def determine_collision_center_box args
  # Collision is handled by the engine. You simply have to call the
  # `intersect_rect? function.
  if args.state.balls.intersect_rect? args.state.racket_one.rect
    args.state.ball.dx = 1
    
  elsif args.state.balls.intersect_rect? args.state.racket_two.rect
    args.state.ball.dx = -1
  end
end

def input args
  if args.inputs.keyboard.up
    args.state.racket_one.rect.y += args.state.racket_one.dy * 3
  elsif args.inputs.keyboard.down
    args.state.racket_one.rect.y -= args.state.racket_one.dy * 3
  end
end

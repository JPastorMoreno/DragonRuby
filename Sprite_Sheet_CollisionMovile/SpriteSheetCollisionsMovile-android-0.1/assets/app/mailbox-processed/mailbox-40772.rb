suggestions = $gtk.suggest_autocompletion index: 579, text: <<-S
def tick args
  defaults args
  render args
  calc args
end

def defaults args
    args.state.racket_one.x = 120
    args.state.racket_one.y = 200
    args.state.racket_one.w ||= 30
    args.state.racket_one.h = 140
    
    args.state.racket_two.x = 1000
    args.state.racket_two.y = 200

   
    args.state.ball.dx ||= 1
    args.state.ball.dy ||= 1
    args.state.ball.w = 40
    args.state.ball_speed = 5
    args.state.center_box_collision ||= false
    args.state.contador = {0,0}
    args.outputs.labels << [600  + 150, 590 - 50, args.sate.contador.,0, 0, 255,   0,   0]
    args.outputs.labels << [600  + 150, 570 - 50, "Green Label.",     0, 0,   0, 255,   0]
    args.outputs.labels << [600  + 150, 550 - 50, "Blue Label.",      0, 0,   0,   0, 255]
    args.outputs.labels << [600  + 150, 530 - 50, "Faded Label.",     0, 0,   0,   0,   0, 128]
    
    args.state.racket_one = [args.state.racket_one, args.state.racket_one.y, args.state.racket_one.w, args.state.racket_one.h, 180,200,100]
    args.state.racket_two = [args.state.racket_two.x, args.state.racket_two.y, args.state.racket_one.w, args.state.racket_one.h, 180,200,100]
    args.state.balls ||= [500,200,args.state.ball.w,args.state.ball.w , 90, 60, 90]
    args.state.center_box ||= [540, 260, 200, 200, 180]
    args.outputs.solids << args.state.racket_one
    args.outputs.solids << args.state.racket_two
end
def render args
  args.outputs.solids << args.state.balls
end

def calc args
  position_moving_box args
  determine_collision_center_box args
end

def position_moving_box args
  args.state.balls.x  += args.state.ball.dx * args.state.ball_speed
  args.state.balls.y  += args.state.ball.dy * args.state.ball_speed
  
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
  elsif args.state.balls.y < 0
    args.state.ball.dy = 1
  end 
end

def determine_collision_center_box args
  # Collision is handled by the engine. You simply have to call the
  # `intersect_rect?` function.
  if args.state.balls.intersect_rect? args.state.racket_one
    args.state.ball.dx = 1
  elsif args.state.balls.intersect_rect? args.state.racket_two
    args.state.ball.dx = -1
  end
end


S
$gtk.write_file 'app/autocomplete.txt', suggestions.join("\n")
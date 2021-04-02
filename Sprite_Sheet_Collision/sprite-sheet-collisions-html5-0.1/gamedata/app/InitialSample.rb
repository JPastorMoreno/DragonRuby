
def tick args
  args.state.x ||= 576
  args.state.y ||= 310
    if args.inputs.mouse.click
      args.state.x = args.inputs.mouse.point.x
      args.state.y = args.inputs.mouse.point.y
    end
  
  args.outputs.labels << [ 580, 500, 'MARIO ES MI PELUCHITO!!']
    
    args.outputs.labels << [ 475, 150, '(Consider reading README.txt now.)' ]
  
    args.outputs.sprites <<[args.state.x-50,args.state.y-50, 128, 101, 'dragonruby.png',args.state.tick_count % 360]
    args.outputs.solids << [910,200,100,100,255,0,0]
    #  get            add   X    Y Weig Heig R  G B
    args.outputs.solids << [300,150,100,100,220,40,240]
  
    args.outputs.sprites << 
      [110,400,300,300,
        'samples/02_sprite_animation_and_keyboard_input/sprites/dragon_fly_0.png']
  
    args.outputs.labels << [1210,500,args.state.tick_count,0,0,0]
    args.state.sprite_frame = args.state.tick_count.idiv(4).mod(6)
    args.outputs.labels << [1210,400,args.state.sprite_frame,0,0,0]
  
    args.state.sprite_path = "samples/02_sprite_animation_and_keyboard_input/sprites/dragon_fly_#{args.state.sprite_frame}.png"
    args.outputs.labels << [ 200,330,"path: #{args.state.sprite_path}",0,0,0]
    args.outputs.sprites << [args.state.x-150,args.state.y-100,300,300,args.state.sprite_path]
    
  
  end
  
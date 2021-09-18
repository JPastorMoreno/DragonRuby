def tick args
  # variables you can play around with
  args.state.world.w      ||= 1280
  args.state.world.h      ||= 720

  args.state.player.x     ||= 0
  args.state.player.y     ||= 200
  args.state.player.size  ||= 60
  args.state.hitbox = {x: args.state.player.x,y: args.state.player.y,w: args.state.player.size ,h: args.state.player.size }
  args.outputs.borders << args.state.hitbox

  args.state.camera.x                ||= 640
  args.state.camera.y                ||= 300
  args.state.camera.scale            ||= 1.0
  args.state.camera.show_empty_space ||= :yes

  args.state.actualScene ||= "Scene1"

  # instructions
  args.outputs.primitives << { x: 0, y:  80.from_top, w: 360, h: 80, r: 0, g: 0, b: 0, a: 128 }.solid
  args.outputs.primitives << { x: 10, y: 10.from_top, text: "arrow keys to move around", r: 255, g: 255, b: 255}.label
  args.outputs.primitives << { x: 10, y: 30.from_top, text: args.state.player.y, r: 255, g: 255, b: 255}.label
  changeScene args
  renderScenes args
  renderCharacter args
  movement args
end
def renderScenes args
  # render scene
  if args.state.actualScene == "Scene1"
    scene1 args
    else
    scene2 args
  end
  
end
def scene1 args
  args.outputs[:scene].w = args.state.world.w
  args.outputs[:scene].h = args.state.world.h


  #Scene1
  args.state[:scene].floor = {x:  0, y: 0, w: args.state.world.w, h: 100, r: 50, g: 100, b: 70}
  
  args.outputs[:scene].sprites << { x: 0, y: 0, w: args.state.world.w, h: args.state.world.h, path: "tfgSprites/Free Pixel Art Forest/PNG/Background layers/Layer_0010_1.png"}
  args.outputs[:scene].sprites << { x: 0, y: 0, w: args.state.world.w, h: args.state.world.h, path: "tfgSprites/Free Pixel Art Forest/PNG/Background layers/Layer_0009_2.png"}
  args.outputs[:scene].sprites << { x: 0, y: 0, w: args.state.world.w, h: args.state.world.h, path: "tfgSprites/Free Pixel Art Forest/PNG/Background layers/Layer_0008_3.png"}
  args.outputs[:scene].sprites << { x: 0, y: 0, w: args.state.world.w, h: args.state.world.h, path: "tfgSprites/Free Pixel Art Forest/PNG/Background layers/Layer_0006_4.png"}
  args.outputs[:scene].sprites << { x: 0, y: 0, w: args.state.world.w, h: args.state.world.h, path: "tfgSprites/Free Pixel Art Forest/PNG/Background layers/Layer_0005_5.png"}
  args.outputs[:scene].sprites << { x: 0, y: 0, w: args.state.world.w, h: args.state.world.h, path: "tfgSprites/Free Pixel Art Forest/PNG/Background layers/Layer_0004_Lights.png"}
  args.outputs[:scene].sprites << { x: 0, y: 0, w: args.state.world.w, h: args.state.world.h, path: "tfgSprites/Free Pixel Art Forest/PNG/Background layers/Layer_0003_6.png"}
  args.outputs[:scene].sprites << { x: 0, y: 0, w: args.state.world.w, h: args.state.world.h, path: "tfgSprites/Free Pixel Art Forest/PNG/Background layers/Layer_0002_7.png"}
  args.outputs[:scene].sprites << { x: 0, y: 0, w: args.state.world.w, h: args.state.world.h, path: "tfgSprites/Free Pixel Art Forest/PNG/Background layers/Layer_0001_8.png"}
  args.outputs[:scene].sprites << { x: 0, y: 0, w: args.state.world.w, h: args.state.world.h, path: "tfgSprites/Free Pixel Art Forest/PNG/Background layers/Layer_0000_9.png"}

  args.outputs[:scene].solids << args.state[:scene].floor

  
  args.state.player.y = args.state[:scene].floor.h if args.state.hitbox.intersect_rect? args.state[:scene].floor
  
  args.outputs.sprites << { x: 0,
                            y: 0,
                            w: args.state.world.w,
                            h: args.state.world.h,
                            path: :scene}
end

def scene2 args
    #Secen2
  args.state.actualScene = "Scene2"
  args.outputs[:scene2].sprites << { x: 0, y: 0, w: args.state.world.w, h: args.state.world.h, path: "tfgSprites/bullkhead-walls/layers/bulkhead-walls-back.png"}
  args.outputs[:scene2].sprites << { x: 0, y: 0, w: args.state.world.w, h: args.state.world.h, path: "tfgSprites/bullkhead-walls/layers/bulkhead-walls-pipes.png"}
  args.outputs[:scene2].sprites << { x: 0, y: 0, w: args.state.world.w, h: args.state.world.h, path: "tfgSprites/bullkhead-walls/layers/cols.png"}
  args.outputs[:scene2].sprites << { x: 0, y: 0, w: args.state.world.w, h: args.state.world.h, path: "tfgSprites/bullkhead-walls/layers/bulkhead-walls-platform.png"}
  args.outputs.sprites << { x: 0,
    y: 0,
    w: args.state.world.w,
    h: args.state.world.h,
    path: :scene2}
end

def changeScene args
  if(args.state.player.x + 40 > 1255) 
    args.state.player.x = 0;
     if args.state.actualScene =="Scene2"
      args.state.actualScene = "Scene1"
     else
      args.state.actualScene = "Scene2" 
     end

    
  end
end

def renderCharacter args
  args.outputs.sprites << { x:args.state.player.x,y:args.state.player.y,w: args.state.player.size, h: args.state.player.size,path:"tfgSprites/Prueba/prueba-0.png"}
end
def movement args
  # move player
  if args.inputs.directional_angle
    args.state.player.x += args.inputs.directional_angle.vector_x * 5
    args.state.player.y += args.inputs.directional_angle.vector_y * 5
    args.state.player.x  = args.state.player.x.clamp(0, args.state.world.w - args.state.player.size)
    args.state.player.y  = args.state.player.y.clamp(0, args.state.world.h - args.state.player.size)
  end
end



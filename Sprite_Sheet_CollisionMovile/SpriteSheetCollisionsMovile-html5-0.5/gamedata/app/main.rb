def tick args
    @gtk
    args.state.player.x ||= 100 
    args.state.player.y ||= 100
    args.state.player.w ||= 150
    args.state.player.h ||= 150
    args.state.prueba ||= 0 
    args.state.player.directon ||= 1
    args.state.enemies ||= []
    args.state.player.tile  ||= 64
    args.state.player.slash_collision_rect ||= [args.state.player.x + 130,args.state.player.y + 170,-108,  -40]
    args.state.player.slash_frames  = 16
    args.state.player.is_moving = false
    args.state.player.is_attacking = false
    args.state.movey_finger ||= nil
    args.state.shooty_finger ||= nil
    
    render args
    input args
    calc_slash args
    cal_enemy args
   
    
end 

def render_enemies args
    args.outputs.borders << args.state.enemies
end

def cal_enemy args
    add_enemy args if args.state.enemies.length == 0
    render_enemies args
end

def add_enemy args
    args.state.enemies << {x: 1200 * rand, y: 600 * rand, w: 64, h: 64 }
    
end

def movement args
    #Movementto the rigth and up
    if (args.inputs.keyboard.right) && (args.inputs.keyboard.up ) 
        args.state.player.x += 5
        args.state.player.y += 3.33
        args.state.player.direction = 1
        args.state.player.started_running_at ||= args.state.tick_count
        args.outputs.sprites << running_sprite(args)
    
    #Movement the rigth and down 
    elsif (args.inputs.keyboard.right) && (args.inputs.keyboard.down)
        args.state.player.x += 5
        args.state.player.y -= 3.33
        args.state.player.direction = 1
        args.state.player.started_running_at ||= args.state.tick_count
        args.outputs.sprites << running_sprite(args)
    #Movement only to the right

    elsif (args.inputs.keyboard.right) && (!args.inputs.keyboard.up)
        args.state.player.x += 5
        args.state.player.direction = 1
        args.state.player.started_running_at ||= args.state.tick_count
        args.outputs.sprites << running_sprite(args)


    #Movement to the  left and up 
    elsif (args.inputs.keyboard.left) && (args.inputs.keyboard.up)
        args.state.player.x -= 5
        args.state.player.y += 3.33
        args.state.player.direction = -1
        args.state.player.started_running_at ||= args.state.tick_count
        args.outputs.sprites << running_sprite(args)
    

    #Movement to the  left and down
    elsif (args.inputs.keyboard.left) && (args.inputs.keyboard.down)
        args.state.player.x -= 5
        args.state.player.y -= 3.33
        args.state.player.direction = -1
        args.state.player.started_running_at ||= args.state.tick_count
        args.outputs.sprites << running_sprite(args)
    
    #Movement only to the left   
    elsif (args.inputs.keyboard.left) && (!args.inputs.keyboard.up)
        args.state.player.x -= 5
        args.state.player.direction = -1
        args.state.player.started_running_at ||= args.state.tick_count
        args.outputs.sprites << running_sprite(args)
    
    end
    #Movement up.
    if (args.inputs.keyboard.up) && ((!args.inputs.keyboard.right)&&(!args.inputs.keyboard.left))
        args.state.player.direction = 2
        args.state.player.y += 3.33
        args.state.player.started_running_at ||= args.state.tick_count
        args.outputs.sprites << running_sprite(args)
    
     
    #Movement down
    elsif args.inputs.keyboard.down && ((!args.inputs.keyboard.right)&&(!args.inputs.keyboard.left))
        args.state.player.direction = -2
        args.state.player.y -= 3.33
        args.state.player.started_running_at ||= args.state.tick_count
        args.outputs.sprites << running_sprite(args)
    
    #Movement For Movile Devices.
    elsif !args.inputs.finger_one.nil?
        args.state.movey_finger = args.inputs.finger_one 
        #Movement to the right
        if (args.inputs.finger_one.x >= 155 && args.inputs.finger_one.x <=  225 && args.inputs.finger_one.y >= 120 && args.inputs.finger_one.y <= 180)
            args.state.player.x += 5
            args.state.player.direction = 1
            args.state.player.started_running_at ||= args.state.tick_count
            args.outputs.sprites << running_sprite(args)
        #movement to the left
        elsif (args.inputs.finger_one.x >= 0 && args.inputs.finger_one.x <= 65 && args.inputs.finger_one.y >= 120 && args.inputs.finger_one.y <= 180 )
            args.state.player.x -= 5
            args.state.player.direction = -1
            args.state.player.started_running_at ||= args.state.tick_count
            args.outputs.sprites << running_sprite(args)
        #Movement Up
        elsif (args.inputs.finger_one.x >= 80 && args.inputs.finger_one.x <= 150 && args.inputs.finger_one.y >= 180 && args.inputs.finger_one.y <= 260)
            args.state.player.direction = 2
            args.state.player.y += 3.33
            args.state.player.started_running_at ||= args.state.tick_count
            args.outputs.sprites << running_sprite(args)
        #Movement Down
        elsif(args.inputs.finger_one.x >= 70 && args.inputs.finger_one.x <= 140 && args.inputs.finger_one.y >= 55 && args.inputs.finger_one.y <= 125)
            args.state.player.direction = -2
            args.state.player.y -= 3.33
            args.state.player.started_running_at ||= args.state.tick_count
            args.outputs.sprites << running_sprite(args)
        #Movement right and up
        elsif (args.inputs.finger_one.x >= 160 && args.inputs.finger_one.x <=  225 && args.inputs.finger_one.y >= 180 && args.inputs.finger_one.y <= 250)
            args.state.player.x += 5
            args.state.player.y += 3.33
            args.state.player.direction = 1
            args.state.player.started_running_at ||= args.state.tick_count
            args.outputs.sprites << running_sprite(args)
        #Right and down
        elsif (args.inputs.finger_one.x >= 160 && args.inputs.finger_one.x <= 220 && args.inputs.finger_one.y >= 55 && args.inputs.finger_one.y <= 120)
            args.state.player.x += 5
            args.state.player.y -= 3.33
            args.state.player.direction = 1
            args.state.player.started_running_at ||= args.state.tick_count
            args.outputs.sprites << running_sprite(args)
        #Left and up
        elsif (args.inputs.finger_one.x >= 0 && args.inputs.finger_one.x <= 65 && args.inputs.finger_one.y >= 180 && args.inputs.finger_one.y <= 240)
            args.state.player.x -= 5
            args.state.player.y += 3.33
            args.state.player.direction = -1
            args.state.player.started_running_at ||= args.state.tick_count
            args.outputs.sprites << running_sprite(args)
        #Left and down
        elsif   (args.inputs.finger_one.x >= 0 && args.inputs.finger_one.x <= 65 && args.inputs.finger_one.y >= 55 && args.inputs.finger_one.y <= 120)
            args.state.player.x -= 5
            args.state.player.y -= 3.33
            args.state.player.direction = -1
            args.state.player.started_running_at ||= args.state.tick_count
            args.outputs.sprites << running_sprite(args)
        else
            args.state.player.started_running_at = nil
        end

    end
    
   
    #Controlling the character not getting out of the screen.
    if args.state.player.y > 720
        args.state.player.y = -64
        args.state.player.started_running_at ||= args.state.tick_count
    elsif args.state.player.y < -64
        args.state.player.y = 720
        args.state.player.started_running_at ||= args.state.tick_count
    
    elsif args.state.player.x > 1280
        args.state.player.x = -64
        args.state.player.started_running_at ||= args.state.tick_count
    elsif args.state.player.x < -64
        args.state.player.x = 1280
        args.state.player.started_running_at ||= args.state.tick_count
    end
    
    # if no arrow keys are being pressed, set the player as not moving
    if args.inputs.finger_one.nil? #(!args.inputs.keyboard.directional_vector) 
        args.state.player.started_running_at = nil
    end
    # render player as standing or running
    if !args.state.player.started_running_at 
        args.outputs.sprites << standing_sprite(args)
    end
    args.outputs.labels << [30, 700, "Use arrow keys to move around."]

end
def render args
    args.outputs.borders  << [10,120,60,60]
    args.outputs.borders  << [160,120,60,60]
    args.outputs.borders  << [85,180,60,60]
    args.outputs.borders  << [85,60,60,60]
    args.outputs.borders  << [1080,120,90,90]
    if args.state.player.slash_at
        args.outputs.sprites << attack_move(args)
        args.outputs.borders << args.state.player.slash_collision_rect
    end
    
end

def slash_initiate? args
    # buffalo usb controller has a button and b button swapped lol
    
    if args.inputs.controller_one.key_down.a || args.inputs.keyboard.key_down.j 
    return args.state.tick_count
    end
=begin

    if (!args.inputs.finger_one.nil?&&(args.inputs.finger_one.x >= 1095 && args.inputs.finger_one.x <= 1170 && args.inputs.finger_one.y >= 120 && args.inputs.finger_one.y <= 190 ))
        args.outputs.labels << [30, 700, "Testing #{args.inputs.finger_one}"]
        args.inputs.finger_one.down_at
        
    elsif (!args.inputs.finger_two.nil?&&(args.inputs.finger_two.x >=  1095  && args.inputs.finger_two.x <= 1170 && args.inputs.finger_two.y >= 120 && args.inputs.finger_two.y <= 190 ))
        args.outputs.labels << [30, 700, "Testing #{args.inputs.finger_two}"]
        args.inputs.finger_two.down_at
    
    end
=end

    if args.inputs.touch.each { |_,v|
        args.outputs.labels << [30, 700, "Use arrow keys to move around.#{v}"]
        if (v.x >= 1060 && v.x <= 1170 && v.y >= 115 && v.y <= 220 )
        return v.down_at
        end 
        # logic!
    }
    end
end

def input args
    # player movement. Player won't move until the slash animation has ended.
    if (slash_complete? args)
       movement args
    end
    
    args.state.player.slash_at = slash_initiate? args if slash_initiate? args
end

def slash_complete? args
    !args.state.player.slash_at || args.state.player.slash_at.elapsed?(args.state.player.slash_frames)
end
def calc_slash args
    #Calculating the direction of the slash
    if args.state.player.direction == 1
        args.state.player.slash_collision_rect = [ args.state.player.x + 95,
                                       args.state.player.y + 56,
                                       113, 40]
    elsif  args.state.player.direction == -1
        args.state.player.slash_collision_rect = [args.state.player.x - 60,args.state.player.y + 60,113,  40]
    elsif  args.state.player.direction == 2
        args.state.player.slash_collision_rect = [args.state.player.x + 15,args.state.player.y + 92,120,80]
    elsif  args.state.player.direction == -2
        args.state.player.slash_collision_rect = [args.state.player.x + 26,args.state.player.y - 23, 120, 80]
    end

    args.state.player.slash_at = nil if slash_complete? args

     # determine collision if the sword is at it's point of damaging
    return unless slash_can_damage? args
    args.state.enemies.reject! { |e| e.intersect_rect? args.state.player.slash_collision_rect}
    
end
def slash_can_damage? args
    # damage occurs half way into the slash animation
    return false if slash_complete? args
    return false if (args.state.player.slash_at + args.state.player.slash_frames.idiv(6)) != args.state.tick_count
    return true
end


def running_sprite args
    #Direction means the tile_y of the png where the sprite can be found. depending on if the player goes right, left, up or down
    # It will take a different tile_y. The animations of the same row (same movement like going to the right) are separated by 64.
    if args.state.player.direction == 1
        direction = 710
    elsif args.state.player.direction == -1
        direction = 585
    elsif args.state.player.direction == 2
        direction = 520
    elsif args.state.player.direction == -2
        direction = 645
    end
    if !args.state.player.started_running_at
        tile_index = 0
    else
        how_many_frames_in_sprite_sheet = 8
        how_many_ticks_to_hold_each_frame = 10
        should_the_index_repeat = true
        tile_index = args.state
                         .player
                         .started_running_at
                         .frame_index(how_many_frames_in_sprite_sheet,
                                      how_many_ticks_to_hold_each_frame,
                                      should_the_index_repeat)
    end

    {
      x: args.state.player.x,
      y: args.state.player.y,
      w: args.state.player.w,
      h: args.state.player.h,
      path: 'tfgSprites/Warrior/warrior.png',
      tile_x: 64 +  (tile_index * 64),
      tile_y: direction,
      tile_w: 65,
      tile_h: 65,
    }
end

def standing_sprite args
    
    if args.state.player.direction == 1
        direction = 710
    elsif args.state.player.direction == -1
        direction = 585
    elsif args.state.player.direction == 2
        direction = 520
    elsif args.state.player.direction == -2
        direction = 645
    end

     {
      x: args.state.player.x,
      y: args.state.player.y,
      w: args.state.player.w,
      h: args.state.player.h,
      tile_x: -1,
      tile_y: direction,
      tile_w: 65,
      tile_h: 65,
      path: "tfgSprites/Warrior/warrior.png",
    }
end

def attack_move args
    #Attacking animation needed some corrections for the character to stay in the same place and not be moved around
    if args.state.player.direction == 1
        correction = 0
        correctiony = 0
        directionx = 64
        directiony = 1992
    elsif args.state.player.direction == -1
        correction = -75
        correctiony = 0
        directionx = 30
        directiony = 1612
    elsif args.state.player.direction == 2
        correction = -18
        correctiony = 30
        directionx = 58
        directiony = 1405
    elsif args.state.player.direction == -2
        correction = -5
        correctiony = 0
        directionx = 60
        directiony = 1800
    end

        how_many_frames_in_sprite_sheet = 6
        should_the_index_repeat = false
        tile_index = args.state.player.slash_at.frame_index(how_many_frames_in_sprite_sheet,
                                    args.state.player.slash_frames.idiv(6),
                                      should_the_index_repeat) || 0

    {
      x: args.state.player.x + 10 + correction,
      y: args.state.player.y - 10 + correctiony,
      w: args.state.player.w + 50 ,
      h: args.state.player.h ,
      path: 'tfgSprites/Warrior/warrior.png',
      tile_x: directionx +  (tile_index * 192),
      tile_y: directiony,
      tile_w: 96,
      tile_h: 66,
    }
end

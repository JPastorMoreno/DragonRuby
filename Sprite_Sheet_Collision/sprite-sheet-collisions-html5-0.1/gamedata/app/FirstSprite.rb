def tick args
    args.state.player.x ||= 100 
    args.state.player.y ||= 100
    args.state.player.w ||= 150
    args.state.player.h ||= 150
    args.state.prueba ||= 0 
    args.state.player.directon ||= 1
    args.state.player.is_moving = false
    args.state.player.is_attacking = false
    
    movement args
    

end

def movement args
    if args.inputs.keyboard.j
        args.state.player.started_running_at ||= args.state.tick_count
        args.outputs.sprites << attack_move(args)
        
    elsif (args.inputs.keyboard.j) && (args.inputs.keyboard.right)
        args.state.player.x += 5
        args.outputs.sprites << attack_move(args)
         #Movement to the right and up
    else 
        if (args.inputs.keyboard.right) && (args.inputs.keyboard.up )
            args.state.player.x += 5
            args.state.player.y += 3.33
            args.state.player.direction = 1
            args.state.player.started_running_at ||= args.state.tick_count
            args.outputs.sprites << running_sprite(args)
        #Movement the left and down 
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

        if (args.inputs.keyboard.up) && ((!args.inputs.keyboard.right)&&(!args.inputs.keyboard.left))
            args.state.player.direction = 2
            args.state.player.y += 3.33
            args.state.player.started_running_at ||= args.state.tick_count
            args.outputs.sprites << running_sprite(args)

        elsif args.inputs.keyboard.down && ((!args.inputs.keyboard.right)&&(!args.inputs.keyboard.left))
            args.state.player.direction = -2
            args.state.player.y -= 3.33
            args.state.player.started_running_at ||= args.state.tick_count
            args.outputs.sprites << running_sprite(args)


        end
        # if no arrow keys are being pressed, set the player as not moving
        if  (!args.inputs.keyboard.directional_vector) && (!args.inputs.keyboard.j)
            args.state.player.started_running_at = nil
        end
        if args.state.player.y > 720
            args.state.player.y = -64
            args.state.player.started_running_at ||= args.state.tick_count
        elsif args.state.player.y < -64
            args.state.player.y = 720
            args.state.player.started_running_at ||= args.state.tick_count
        end

        # render player as standing or running
        if !args.state.player.started_running_at 
            args.outputs.sprites << standing_sprite(args)
        end
        args.outputs.labels << [30, 700, "Use arrow keys to move around."]
        end

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
      tile_x: 64 ,
      tile_y: direction,
      tile_w: 65,
      tile_h: 65,
      path: "tfgSprites/Warrior/warrior.png",
    }
end

def running_sprite args
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
        how_many_ticks_to_hold_each_frame = 12
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

def attack_move args
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


    if !args.state.player.started_running_at
        tile_index = 0
    else
        how_many_frames_in_sprite_sheet = 6
        how_many_ticks_to_hold_each_frame = 2.5
        should_the_index_repeat = false
        tile_index = args.state
                         .player
                         .started_running_at
                         .frame_index(how_many_frames_in_sprite_sheet,
                                      how_many_ticks_to_hold_each_frame,
                                      should_the_index_repeat)
        tile_index ||= 0
    end
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
$gtk.reset
attr_gtk

require 'app/Character.rb'

def tick args
    combat_Scene args
    defaults args if args.state.tick_count == 0
    
    args.outputs.background_color = [100,100,100]
    args.state.win.draw 
    args.state.lastIndex ||= 0
    args.state.triangle ||= false
    args.state.acutalPosition ||= nil
    args.state.page ||= 0 
    args.state.lastObjective ||= nil
    checkForItems args
    click_events args
    info args
    checkingMouse args
    args.outputs.primitives << {x:args.inputs.mouse.x, y:args.inputs.mouse.y-10, text: args.inputs.mouse.y}.label
   
    args.state.actualCharacterIndex ||= 0
   
    one_time_animation args
    
    args.state.timevariable ||= nil

end

class Window
    attr_accessor :x, :y, :w, :h,
                  :elements

    def initialize args, x, y, w, h
        @args = args
        @x = x
        @y = y
        @w = w
        @h = h

        @elements = []
    end

    def add element
        element.parent = self
        @elements << element
    end

    def draw

        args.outputs.sprites <<  {x: 269,y: 10,w: 977,h: 190,path: 'tfgSprites/Menus/FFVII_Skin_ByEthanFox.png',tile_x: 0,tile_y: 0,tile_w: 60,tile_h: 60,}

        args.outputs.sprites <<  {x: 225,y: 5, w: 1055,h: 200,path: 'tfgSprites/Menus/FFVII_Skin_ByEthanFox.png',tile_x: 96,tile_y: 0,tile_w:95,tile_h: 95,}

        args.outputs.sprites <<{x: 269,y: 18,w: 898,h:165,path: 'tfgSprites/Menus/FFVII_Skin_ByEthanFox.png',tile_x: 0,tile_y: 0,tile_w: 60,tile_h: 60,}

        args.outputs.sprites <<  {x: @x+8,y: @y+12,w: 231,h: 185,path: 'tfgSprites/Menus/FFVII_Skin_ByEthanFox.png',tile_x: 0,tile_y: 0,tile_w: 60,tile_h: 60,}

        args.outputs.sprites <<  {x: @x,y: @y+5,w: 245,h: 200,path: 'tfgSprites/Menus/FFVII_Skin_ByEthanFox.png',tile_x: 96,tile_y: 0,tile_w:95,tile_h: 95,}

        args.outputs.sprites <<  {x: @x+11,y: @y+12,w: 210,h: 170,path: 'tfgSprites/Menus/FFVII_Skin_ByEthanFox.png',tile_x: 0,tile_y: 0,tile_w: 60,tile_h: 60,}
        
         
        
        @elements.each do |element|
            element.draw if element.show == true
        end
    end
end

class Button
    attr_accessor :x, :y,
                  :text, :keybinds, :parent,:show, :time_shown

    def initialize args, x, y, text
        @args = args
        @x = x
        @y = y

        @text = text
        @keybinds = []
        @parent = nil
        @show = true
        @time_shown = 0
        @y2 = 0
       
    end
    
    def clicked_on?
        pixel = args.state.pixel
        pixel_s = args.state.pixel_s
        click_area = {
            x: (@parent.x+@x)*pixel_s,
            y: (@parent.y+@y)*pixel_s-5,
            w: 53*pixel_s,
            h: 10*pixel_s
          }
        if @show 

            if inputs.mouse.point.inside_rect?(click_area)
                args.outputs.primitives << {x:(@parent.x+@x)*args.state.pixel_s-5,y:(@parent.y+@y)*args.state.pixel_s,w:53*args.state.pixel_s,h:10*args.state.pixel_s, r: 0, g: 0, b: 0, a: (args.tick_count + 40)% 120,}.solid 
            
                tile_index = ControllerButtonSprite(args)
                args.outputs.primitives << {
                    x: 185,
                    y: (@parent.y+@y)*args.state.pixel_s - 6,
                    w: 50,
                    h:50,
                    path: 'tfgSprites/Controllers/Ps4.png',
                    tile_x: 0 +  tile_index*16,
                    tile_y: 15,
                    tile_w: 16,
                    tile_h: 20,
                }
            
                
            end
        end
        if @show && args.state.tick_count > @time_shown 
            if args.inputs.controller_one.key_down.a
            
                return inputs.mouse.point.inside_rect?({x:(@parent.x+@x)*args.state.pixel_s,y:(@parent.y+@y)*args.state.pixel_s,w:53*text.length*args.state.pixel_s,h:10*args.state.pixel_s})
            end
        end
        
           
        return unless inputs.mouse.click
        if @show && args.state.tick_count > @time_shown 
            return inputs.mouse.point.inside_rect?({x:(@parent.x+@x)*args.state.pixel_s,y:(@parent.y+@y)*args.state.pixel_s,w:53*args.state.pixel_s,h:10*args.state.pixel_s})
        end
        
        
    end

    def keybind_pressed?
        return unless args.inputs.keyboard.truthy_keys.length > 0
        return args.inputs.keyboard.key_down.any? @keybinds
    end

    def left_of element, offset = element.text.length/2
        @x = element.x - 8 - offset*8
    end

    def right_of element, offset = element.text.length/2
        @x = element.x + offset*8
    end

    def set_keybind key_symbol
        @keybinds << key_symbol
    end

    def draw
        if @show
            args.outputs.primitives << { x:(@parent.x+@x)*args.state.pixel_s, y: (@parent.y+@y+7)*args.state.pixel_s,r: 255, g: 255, b: 255,
            text: @text,font:"tfgSprites/font/EightBitDragon-anqx.ttf"}.label 
        end
    end

    
end

class List
    attr_accessor :x, :y, :w, :h,
                  :elements, :highlighted, :parent,:show, :actualType, :current_elements, :actualElementType, :flag, :objectiveIndex, :current_objectives

    def initialize args, x, y, w, h, center_x = true
        @args = args
        @x = x
        @y = y
        @w = w
        @h = h
        @center_x = center_x
        @elements = []
        @objectives = []
        @current_elements = []
        @current_objectives = []
        @actualElementType = []
        @actualType = :actualType
        @highlighted = {name:"", type:"", amount:0, tooltip:"",character:0}
        @show = false
        @parent = nil
        @selecteCharacter = nil
        @flag = false
        @selectedItem = nil 
        @eleapsedForAction = 10
        @firstAction  = nil
        @objectiveIndex = 0
        
    end

    def add_element element
        element[:selected] = false
        @show = false
        @elements << element
    end
    
    def add_objective objective
        
        @objectives << objective
    end

    def update_current_objectives 
        @current_objectives = []
       
        @objectives.each_with_index do |element,j| 
            
            if @objectiveIndex == 1
                @current_objectives << element if j < 3
            elsif @objectiveIndex == 0
                @current_objectives << element if j > 2 unless element.dead
            end

            
           
        end
    end

    def deselect_all
        @elements.each_with_index do |element, j|
            element[:selected] = false
        end
    end

    def clear
        @elements = []
    end

    def update_current_elements type
        @current_elements = []
        @actualElementType = []
        @elements.each_with_index do |element| 
            if element[:type] == @actualType && element[:character].turn == true
                @actualElementType << element
            end
        end
        @actualElementType.each_with_index do |element,j| 
            if element[:type] == @actualType && element[:character].turn == true
                if args.state.page == 0
                    @current_elements << element if j <= 3
                elsif args.state.page == 1
                    @current_elements << element if j > 3 
                end
            end
        end
    end

    def update_current_objective_page
        @objectiveIndex = (@objectiveIndex + 1) % 2 
    end

    def mouse_over?
        
        variable = 0;
        if @show
            
            @current_elements.each_with_index do |element, j|
                
                if j<4 && @flag == false
                    if inputs.mouse.point.inside_rect?({x:(@parent.x+@x)*args.state.pixel_s, y: (@parent.y+@y-11*(j))*args.state.pixel_s + 150, w:54*args.state.pixel_s, h: 10*args.state.pixel_s})

        
                        args.outputs.primitives << { x:(@parent.x+@x+2)*args.state.pixel_s, y: (@parent.y+@y-11*(j))*args.state.pixel_s + 150, w:54*args.state.pixel_s, h: 10*args.state.pixel_s, r: 0, g: 0, b: 0, a: (args.tick_count + 70)% 120,}.solid
                
                        args.outputs.primitives << { x:500, y: (@parent.y+@y-11*j)*args.state.pixel_s,text:element[:name], r: 0, g: 0, b: 0, a: 70 }.label
                        args.state.lastIndex = j
                        tile_index = ControllerButtonSprite(args)
                        args.outputs.primitives << {
                            x: 185,
                            y:(@parent.y+@y-11*(j))*args.state.pixel_s + 145,
                            w: 50,
                            h:50,
                            path: 'tfgSprites/Controllers/Ps4.png',
                            tile_x: 0 +  tile_index*16,
                            tile_y: 15,
                            tile_w: 16,
                            tile_h: 20,
                        }
                       
                      
                        if args.inputs.mouse.click  || args.inputs.controller_one.key_down.a
                            @selecteCharacter = element[:character]
                            @selectedItem = element
                            @flag = true
                            @firstAction = args.tick_count
                            update_current_objectives
                        end
                        
                    end

                end
    
            end
        end

        return false
    end
    
    def item_selected? 
      
        if @show
            
            @current_objectives.each_with_index do |element, j|
               
                if j<3 && @flag 
                    if inputs.mouse.point.inside_rect?({x:(@parent.x+@x)*args.state.pixel_s, y: (@parent.y + 51*j) + 55, w:54*args.state.pixel_s, h: 10*args.state.pixel_s})
                        args.outputs.primitives << {x:(@parent.x+@x+2)*args.state.pixel_s, y: (@parent.y + 51*j) + 55, w:54*args.state.pixel_s, h: 10*args.state.pixel_s, r: 0, g: 0, b: 0, a: (args.tick_count + 70)% 120,}.solid
                
                        tile_index = ControllerButtonSprite(args)
                        args.outputs.primitives << {
                            x: 185,
                            y:(@parent.y+@y + 12.5*j)*args.state.pixel_s + 48,
                            w: 50,
                            h:50,
                            path: 'tfgSprites/Controllers/Ps4.png',
                            tile_x: 0 +  tile_index*16,
                            tile_y: 15,
                            tile_w: 16,
                            tile_h: 20,
                        }
                      
                        if (args.inputs.mouse.click  || args.inputs.controller_one.key_down.a) && @firstAction.elapsed?(10)
                            calculateAction element
                           
                            return true
                        end
                        #añadir aqui una opcion para cancelar.
                        
                    end

                end
               
    
            end
        end

        return false
    end

    def calculateAction element
        if @selectedItem[:type] == "ATTACK"
                               
            element.hp = (element.hp - @selectedItem[:number] * @selecteCharacter.attackStat).clamp(0,element.maxHP)

        elsif @selectedItem[:type] == "MG" && @selectedItem[:name] != "HEAL"
           
            element.hp = (element.hp - @selectedItem[:number] * @selecteCharacter.mgStat).clamp(0,element.maxHP)
            @selecteCharacter.mg = (@selecteCharacter.mg - @selectedItem[:uses]).clamp(0,@selecteCharacter.maxMg)
            
        elsif @selectedItem[:type] == "MG" && @selectedItem[:name] == "HEAL"

            element.hp = (element.hp + @selectedItem[:number]).clamp(0,element.maxHP)
            @selecteCharacter.mg = (@selecteCharacter.mg - @selectedItem[:uses]).clamp(0,@selecteCharacter.maxMg)

        elsif @selectedItem[:type] == "ITEM" 
           
            if (@selectedItem[:name] == "POTION" || @selectedItem[:name] == "HIGH POTION") && (@selectedItem[:amount] > 0) && (element.hp > 0)
                element.hp = (element.hp + @selectedItem[:number]).clamp(0,element.maxHP)

            elsif (@selectedItem[:name] == "SERUM" || @selectedItem[:name] == "SUPER SERUM") && (@selectedItem[:amount] > 0) && (element.hp > 0)

                element.mg = (element.mg + @selectedItem[:number]).clamp(0,element.maxMg)

            elsif (@selectedItem[:name] == "PHOENIX DOWN") && (@selectedItem[:amount] > 0) && (element.hp == 0)
                element.dead = false
               element.hp = (element.hp + @selectedItem[:number]).clamp(0,element.maxHP)
               

            end
            @selectedItem[:amount] = (@selectedItem[:amount] - 1).clamp(0,999999)
            

        end

        if !element.dead
            element.dead = true  if element.hp == 0 
            element.dying = true if element.hp == 0
        end
        args.state.lastObjective = element
       
    end

    def draw

        if @flag == false
            @current_elements.each_with_index do |element,j|
                if j<4
                    args.outputs.primitives << {x: (@parent.x+@x+3)*args.state.pixel_s, y: (@parent.y+@y+7-11*j)*args.state.pixel_s + 150,r: 255, g: 255, b: 255,
                        text: element[:name].upcase,font:"tfgSprites/font/EightBitDragon-anqx.ttf"}.label 
                    
                end
                
            end
        else  
            @current_objectives.each.with_index do |element, j|
                if j<3 
                    args.outputs.primitives << {x:10*args.state.pixel_s, y: (@parent.y + 51*j) + 79,r: 255, g: 255, b: 255,
                        text: element.text.upcase,font:"tfgSprites/font/EightBitDragon-anqx.ttf"}.label 
                end
  
            end

        end


        if mouse_over?
            @flag = true
        end
        
        if item_selected?
            @flag = false
            @selecteCharacter.attack = true
            pass_turn args
            selected = false
            ringTone
            args.state.list.show = false
            args.state.timevariable = args.tick_count

        end
      
    end
    
    def ringTone
        args.state.button_List.each_with_index do |element|
            element.show = true
            element.time_shown = args.state.tick_count
        end
    end

end

class SmallButton
    attr_accessor :x, :y,
                  :text, :keybinds, :parent,:show, :time_shown,:spriteX,:spriteY
                  :multiplier


    def initialize args, x, y, text,spriteX,spriteY,multiplier
        @args = args
        @x = x
        @y = y

        @text = text
        @keybinds = []
        @parent = nil
        @show = false
        @time_shown = 0
       @spriteX = spriteX
       @spriteY = spriteY
       @multiplier = multiplier
    end
    
    def clicked_on?
        if @show 
            if inputs.mouse.point.inside_rect?({x:(@parent.x+@x)*args.state.pixel_s-5,y:(@parent.y+@y)*args.state.pixel_s,w:12.5*args.state.pixel_s,h:12.5*args.state.pixel_s})
                
                args.outputs.primitives << { x:(@parent.x+@x)*args.state.pixel_s-5,y:(@parent.y+@y)*args.state.pixel_s,w:12.5*args.state.pixel_s,h:12.5*args.state.pixel_s, r: 0, g: 0, b: 0, a: 70,}.solid
            end
            
        end

        return unless inputs.mouse.click
        if @show 
            return inputs.mouse.point.inside_rect?({  x:(@parent.x+@x)*args.state.pixel_s-5,y:(@parent.y+@y)*args.state.pixel_s,w:12.5*args.state.pixel_s,h:12.5*args.state.pixel_s})
        end
        
    end

    def keybind_pressed?
        return unless args.inputs.keyboard.truthy_keys.length > 0
        return args.inputs.keyboard.key_down.any? @keybinds
    end

    def left_of element, offset = element.text.length/2
        @x = element.x - 8 - offset*8
    end

    def right_of element, offset = element.text.length/2
        @x = element.x + offset*8
    end

    def set_keybind key_symbol
        @keybinds << key_symbol
    end
    

    def draw
        if @show
            tile_index = ControllerButtonSprite(args)
            args.outputs.primitives << {
                x: (@parent.x+@x)*args.state.pixel_s-5,
                y: (@parent.y+@y)*args.state.pixel_s - 6,
                w: 50,
                h:50,
                path: 'tfgSprites/Controllers/Ps4.png',
                tile_x: (@spriteX +  (tile_index*@multiplier)*16),
                tile_y: spriteY,
                tile_w: 16,
                tile_h: 20,
            }
        end
    end
end

def defaults args
    args.state.pixel_s = 4

    args.state.win = Window.new(args, 2, 0,231, 185)
    args.outputs.background_color = [100,100,100]
    args.state.attack_button = Button.new(args, 5, 37, "ATTACK")
    args.state.win.add(args.state.attack_button)
    args.state.magic_button = Button.new(args, 5,26, "MG")
    args.state.win.add(args.state.magic_button)

    args.state.item_button = Button.new(args, 5, 15, "ITEMS")
    args.state.win.add(args.state.item_button)

    args.state.leave_button = Button.new(args, 5, 4, "LEAVE")
    args.state.win.add(args.state.leave_button)
    
    args.state.triangle_button = SmallButton.new(args, 20, 50, "TRIANGLE",0,80,1)
    args.state.win.add(args.state.triangle_button)

    args.state.nextPage_button = SmallButton.new(args, 40, 50, "NEXT",208,65,3)
    args.state.win.add(args.state.nextPage_button)
   
    args.state.button_List = [args.state.attack_button,args.state.magic_button,args.state.item_button,args.state.leave_button]
    args.state.smallButton_List = [args.state.triangle_button,args.state.nextPage_button]

    args.state.menu_names = ["ATTACK","MG","equipables","quest items","misc"]

    args.state.list = List.new(args, 0, 0, 200, 100,"idk")
    args.state.win.add(args.state.list)

#Character Creation
    args.state.character1  = Character.new(args,200,375,150,150,100,200,50,100,20,15,"tfgSprites/Warrior/warrior.png","JAWFTD")
    args.state.character2 = Character.new(args,120,300,150,150,100,200,50,100,30,10,"tfgSprites/Warrior/knight.png","Char2")
    args.state.character3 = Character.new(args,50,220,150,150,100,200,50,100,10,20,"tfgSprites/Warrior/elf_girl_sprites.png","Char3")
    args.state.enemy = Enemy.new(args,800,375,90,90,200,200,30,"tfgSprites/Monsters/Monster.png","Enemy1")
    args.state.characterArray = [args.state.character1,args.state.character2,args.state.character3,args.state.enemy]
    args.state.characterArray.each_with_index do |character|
        puts character.text
        args.state.list.add_objective character
    end
    puts args.state.enemy.hp

    defaultItems args
    args.state.character1.turn ||= true  

#Updating the list of elements
    args.state.list.update_current_elements args

end

def click_events args
    if args.state.attack_button.clicked_on? 
       
        args.state.button_List.each_with_index do |element|
                element.show = false
                element.time_shown = args.state.tick_count
        end
        args.state.list.elements.each_with_index do |element, j|
       
            args.state.list.show = true
            args.state.list.actualType = "ATTACK"
            args.state.list.update_current_elements args

        end
    end
       
    if args.state.magic_button.clicked_on?
        puts "blanco"
        args.state.button_List.each_with_index do |element|
                    element.show = false
                    element.time_shown = args.state.tick_count
        end

        args.state.list.elements.each_with_index do |element, j|
        
                    args.state.list.show = true
                    args.state.list.actualType = "MG"
                    args.state.list.update_current_elements args
        end

    end

    if args.state.item_button.clicked_on? 

        args.state.button_List.each_with_index do |element|
            element.show = false
            element.time_shown = args.state.tick_count
        end

        args.state.list.elements.each_with_index do |element, j|
    
            args.state.list.show = true
            args.state.list.actualType = "ITEM"
            args.state.list.update_current_elements args
    
        end
       
      
    end
    if args.state.leave_button.clicked_on? 
    end

    if args.state.triangle_button.clicked_on? || args.inputs.controller_one.key_down.y
        
        if args.state.triangle == false
            args.state.triangle = true
        else
            args.state.triangle = false
        end

    end
    
    if args.state.nextPage_button.clicked_on? || args.inputs.controller_one.key_down.right 
        if args.state.nextPage.show = true &&  !args.state.list.flag 
            args.state.page = (args.state.page + 1) % 2
            args.state.list.update_current_elements  args.state.list.actualType
        end
        if args.state.nextPage.show = true &&  args.state.list.flag
            args.state.list.update_current_objective_page
            args.state.list.update_current_objectives
        end
   end

   if args.state.list.show == true 
        if args.inputs.controller_one.key_down.b 
            args.state.list.elements.each_with_index do |element, j|
   
                args.state.list.show = false
            end
            args.state.button_List.each_with_index do |element|
                element.show = true
                element.time_shown = args.state.tick_count
            end
        end
    end

end

def combat_Scene args
    args.outputs.sprites <<  
    {
        x: 0,
        y: 0,
        w: 1280,
        h: 720,
        path: 'tfgSprites/BatleTiles/DemonCastle1.png',
    }
    args.outputs.sprites <<  
    {
        x: 0,
        y: 0,
        w: 1280,
        h: 720,
        path: 'tfgSprites/BatleTiles/DemonCastle3.png',
    }
 
end

def checkForItems  args
   if args.state.list.show == true 

        args.state.smallButton_List.each_with_index do |element|
            element.show = true
            element.time_shown = args.state.tick_count
        end
    else
        args.state.smallButton_List.each_with_index do |element|
            element.show = false
            element.time_shown = args.state.tick_count
        end
    end
 
end

def info args
    if args.state.triangle == true && args.state.triangle_button.show == true
        
        if  args.state.lastIndex < args.state.list.current_elements.length

            args.outputs.primitives << {x: (300), y: 180,r: 255, g: 255, b: 255,
            text: args.state.list.current_elements[args.state.lastIndex].tooltip,font:"tfgSprites/font/EightBitDragon-anqx.ttf"}.label
        end
    else 
        args.state.characterArray.each_with_index do |element,j|
            if j < 3
                args.outputs.primitives << {x: (300), y: 60*j + 50,r: 255, g: 255, b: 255,
                text: element.text , font:"tfgSprites/font/EightBitDragon-anqx.ttf"}.label
              
                args.outputs.primitives << {x: (600), y: 60*j + 50,r: 255, g: 255, b: 255,
                text: "HP: " + element.hp.to_s + "/" + element.maxHP.to_s,font:"tfgSprites/font/EightBitDragon-anqx.ttf"}.label

                args.outputs.primitives << {x: 900, y: 60*j + 50,r: 255, g: 255, b: 255,
                text: "MG: " + element.mg.to_s + "/" + element.maxMg.to_s,font:"tfgSprites/font/EightBitDragon-anqx.ttf"}.label
            end
        end
    end

end 
def ControllerButtonSprite args

    start_looping_at  = 0
    how_many_frames_in_sprite_sheet = 2

    number_of_frames_to_show_each_sprite = 25
    should_the_index_repeat = true
    tile_index = start_looping_at.frame_index(how_many_frames_in_sprite_sheet,
                                    number_of_frames_to_show_each_sprite,
                                  should_the_index_repeat) || 0
          
end

def checkingMouse args

    if args.state.acutalPosition == nil
        args.state.acutalPosition = 0
    end
    
    if args.inputs.controller_one.key_down.down || args.inputs.controller_one.key_down.up
        args.state.acutalPosition  = (args.state.acutalPosition - 1) % 4 if args.inputs.controller_one.key_down.up
        args.state.acutalPosition  = (args.state.acutalPosition + 1) % 4 if args.inputs.controller_one.key_down.down
        
        puts args.state.acutalPosition
        
        if args.state.acutalPosition == 0
            args.inputs.mouse.x = 50
            args.inputs.mouse.y = 150
        elsif args.state.acutalPosition == 1
            args.inputs.mouse.x = 50
            args.inputs.mouse.y = 125
        elsif args.state.acutalPosition == 2
            args.inputs.mouse.x = 50
            args.inputs.mouse.y = 84
        elsif args.state.acutalPosition == 3
            args.inputs.mouse.x = 50
            args.inputs.mouse.y = 47
        end
    end
  
end


def pass_turn args

    if args.state.character1.dead && args.state.character2.dead && args.state.character2.dead 
        puts "YOU ARE DEAD"
    else
        args.state.characterArray[args.state.actualCharacterIndex].turn = false
        args.state.actualCharacterIndex  = (args.state.actualCharacterIndex + 1) % 3 
        args.state.characterArray[args.state.actualCharacterIndex].turn = true
        if args.state.characterArray[args.state.actualCharacterIndex].dead 
            pass_turn args
        end
    end

end

def actualTurn args
    return args.state.characterArray[args.state.actualCharacterIndex]
end

def one_time_animation args

    args.state.characterArray.each_with_index do |element, j |
        if !element.dead 
            if element.attack
                element.start_looping_at = args.state.tick_count   
            end
        
            if element.start_looping_at
                if element.start_looping_at.elapsed?(50)
                    element.start_looping_at = nil
                end
    
                if args.state.list.actualType == "ATTACK"
                    args.outputs.primitives << element.attack_move.sprite
                    args.outputs.primitives << selectAnimation( args, element.start_looping_at).sprite

                elsif args.state.list.actualType == "MG"
                    args.outputs.primitives << element.magic_move.sprite
                elsif args.state.list.actualType == "ITEM"
                    args.outputs.primitives << element.item_move.sprite
                    
                
                end
                element.attack = false
            else 
                args.outputs.primitives << element.standing_sprite.sprite
                if element.turn == true
                    args.outputs.primitives << element.standing_sprite.sprite
                    args.outputs.primitives << 
                    { x:element.x + 35, 
                    y: element.y,
                    w:element.w - 70,
                    h:element.h, 
                    r: 0, g: 0, b: 0, a: (args.tick_count + 70)% 120,}.solid
                end

            end
        else
            if element.dying
                element.start_looping_at = args.state.timevariable   
            end
            if element.start_looping_at

                if element.start_looping_at.elapsed?(50)
                    element.start_looping_at = nil
                end
                
                args.outputs.primitives << element.dying_move.sprite
               
                element.dying = false
            else
                args.outputs.primitives << element.is_dead.sprite
            end
            

            if  element.enemy
                args.state.characterArray.reject{element}
            end
            
        end
        
    end
end
def selectAnimation args, tempo
  
    how_many_frames_in_sprite_sheet = 5
    number_of_frames_to_show_each_sprite = 5
    should_the_index_repeat = false
    tile_index = tempo.frame_index how_many_frames_in_sprite_sheet,
                                number_of_frames_to_show_each_sprite,
                                should_the_index_repeat
    
    tile_index ||= 0                             

    {
      x: args.state.lastObjective.x ,
      y: args.state.lastObjective.y- 10,
      w: 90,
      h: 90 ,
      path: "tfgSprites/AttackSprites/Slash - copia.png",
      tile_x:20 +  (tile_index * 192.4),
      tile_y: 0,
      tile_w: 192.4,
      tile_h: 280,
    }
end


def defaultItems args
#Character1 
    #attack
    args.state.character1.character_add_element({name:"SLASH", type:"ATTACK", amount:5,number:5,uses:0,tooltip:"DEALS SOME DAMAGE TO THE ENEMY",character: args.state.character1})
    args.state.character1.character_add_element({name:"SHOOT", type:"ATTACK", amount:1,number:10,uses:0, tooltip:"PIUM PIUM",character: args.state.character1})
    args.state.character1.character_add_element({name:"CODING In C", type:"ATTACK", amount:5,number:16,uses:0,tooltip:"WHY WOULD YOU DO THIS?",character: args.state.character1})
    args.state.character1.character_add_element({name:"ARROW", type:"ATTACK", amount:1,number:0,uses:20, tooltip:"SHOOTS AN ARROW",character: args.state.character1})
    #MG
    args.state.character1.character_add_element({name:"FIRE", type:"MG", amount:2,number:10,uses:5, tooltip:"FIRAGA!",character: args.state.character1})
    args.state.character1.character_add_element({name:"ICE", type:"MG", amount:2,number:15,uses:5, tooltip:"ICEGA",character: args.state.character1})
    args.state.character1.character_add_element({name:"THUNDER", type:"MG", amount:2,number:20,uses:5, tooltip:"THOR HAS COME TO HEARTH",character: args.state.character1})
    args.state.character1.character_add_element({name:"HEAL", type:"MG", amount:2,number:30,uses:10, tooltip:"DONALD DUCKS NEVER USES IT",character: args.state.character1})
    args.state.character1.character_add_element({name:"SLOW", type:"MG", amount:2,number:40,uses:20, tooltip:"SLOW DOWN FELLA",character: args.state.character1})
    args.state.character1.character_add_element({name:"DEATH", type:"MG", amount:2,number:50,uses:20, tooltip:"GUESS I'LL DIE",character: args.state.character1})
    #Items
    args.state.character1.character_add_element({name:"POTION", type:"ITEM", amount:2,number:15,uses:0, tooltip:"HEAL 10 HP",character: args.state.character1})
    args.state.character1.character_add_element({name:"HIGH POTION", type:"ITEM",number:40, amount:2, tooltip:"HEAL 50 HP",character: args.state.character1})
    args.state.character1.character_add_element({name:"SERUM", type:"ITEM", amount:2,number:15,uses:0, tooltip:"RESTORES 20 MP",character: args.state.character1})
    args.state.character1.character_add_element({name:"SUPER SERUM", type:"ITEM", amount:2,number:20,uses:0, tooltip:"RESTORES 20 MP",character: args.state.character1})
    args.state.character1.character_add_element({name:"PHOENIX DOWN", type:"ITEM", amount:2, number:70,uses:4,tooltip:"OPENS THE CAR",character: args.state.character1})
    args.state.character1.character_add_element({name:"ARTORIAS RING", type:"ITEM", amount:2, number:0,uses:0,tooltip:"BELONGS TO A GREAT WARRIOR OF OLD",character: args.state.character1})
    args.state.character1.character_add_element({name:"LIGHTER", type:"ITEM", amount:2, number:0,uses:0,tooltip:"WILL BRIGHT WHEN EVERYTHING IS DARK",character: args.state.character1})
 #character2 
    args.state.character2.character_add_element({name:"SLASH", type:"ATTACK", amount:5,number:0,uses:0, tooltip:"DEALS SOME DAMAGE TO THE ENEMY",character: args.state.character2})
    args.state.character2.character_add_element({name:"SHOOT", type:"ATTACK", amount:1,number:0,uses:0, tooltip:"PIUM PIUM",character: args.state.character2})
    args.state.character2.character_add_element({name:"CODING In C", type:"ATTACK", amount:5, number:0,uses:0,tooltip:"WHY WOULD YOU DO THIS?",character: args.state.character2})
    args.state.character2.character_add_element({name:"ARROW", type:"ATTACK", amount:1, number:0,uses:0,tooltip:"SHOOTS AN ARROW",character: args.state.character2})
    #MG
    args.state.character2.character_add_element({name:"FIRE", type:"MG", amount:2,number:15,uses:5, tooltip:"FIRAGA!",character: args.state.character2})
    args.state.character2.character_add_element({name:"ICE", type:"MG", amount:2, number:15,uses:5,tooltip:"ICEGA",character: args.state.character2})
    args.state.character2.character_add_element({name:"THUNDER", type:"MG", amount:2,number:15,uses:5,tooltip:"THOR HAS COME TO HEARTH",character: args.state.character2})
    args.state.character2.character_add_element({name:"HEAL", type:"MG", amount:2,number:20,uses:5, tooltip:"DONALD DUCKS NEVER USES IT",character: args.state.character2})
    args.state.character2.character_add_element({name:"SLOW", type:"MG", amount:2,number:15,uses:5, tooltip:"SLOW DOWN FELLA",character: args.state.character2})
    args.state.character2.character_add_element({name:"DEATH", type:"MG", amount:2, number:16,uses:5,tooltip:"GUESS I'LL DIE",character: args.state.character2})
    #Items
    args.state.character2.character_add_element({name:"POTION", type:"ITEM", amount:2, number:15,uses:5,tooltip:"HEAL 10 HP",character: args.state.character2})
    args.state.character2.character_add_element({name:"HIGH POTION", type:"ITEM", amount:2,number:20,uses:5, tooltip:"HEAL 50 HP",character: args.state.character2})
    args.state.character2.character_add_element({name:"SERUM", type:"ITEM", amount:2,number:15,uses:5, tooltip:"RESTORES 20 MP",character: args.state.character2})
    args.state.character2.character_add_element({name:"SUPER SERUM", type:"ITEM", amount:2,uses:20,uses:0, tooltip:"RESTORES 20 MP",character: args.state.character2})
    args.state.character2.character_add_element({name:"PHOENIX DOWN", type:"ITEM", amount:2, number:70,uses:4,tooltip:"OPENS THE CAR",character: args.state.character2})
    args.state.character2.character_add_element({name:"ARTORIAS RING", type:"ITEM", amount:2,number:0,uses:0, tooltip:"BELONGS TO A GREAT WARRIOR OF OLD",character: args.state.character2})
    args.state.character2.character_add_element({name:"LIGHTER", type:"ITEM", amount:2,number:0,uses:0, tooltip:"WILL BRIGHT WHEN EVERYTHING IS DARK",character: args.state.character2}) 
#character3 
    args.state.character3.character_add_element({name:"PECHUGA", type:"ATTACK", amount:5,number:0,uses:5, tooltip:"DEALS SOME DAMAGE TO THE ENEMY",character: args.state.character3})
    args.state.character3.character_add_element({name:"SHOOT", type:"ATTACK", amount:1,number:0,uses:5, tooltip:"PIUM PIUM",character: args.state.character3})
    args.state.character3.character_add_element({name:"CODING In C", type:"ATTACK", amount:5, number:0,uses:0,tooltip:"WHY WOULD YOU DO THIS?",character: args.state.character3})
    args.state.character3.character_add_element({name:"ARROW", type:"ATTACK", amount:1,number:0,uses:0, tooltip:"SHOOTS AN ARROW",character: args.state.character3})
    #MG
    args.state.character3.character_add_element({name:"FIRE", type:"MG", amount:2, number:5,uses:5,tooltip:"FIRAGA!",character: args.state.character3})
    args.state.character3.character_add_element({name:"ICE", type:"MG", amount:2, number:10,uses:5,tooltip:"ICEGA",character: args.state.character3})
    args.state.character3.character_add_element({name:"THUNDER", type:"MG", amount:2,number:15,uses:5, tooltip:"THOR HAS COME TO HEARTH",character: args.state.character3})
    args.state.character3.character_add_element({name:"HEAL", type:"MG", amount:2, number:10,uses:5,tooltip:"DONALD DUCKS NEVER USES IT",character: args.state.character3})
    args.state.character3.character_add_element({name:"SLOW", type:"MG", amount:2,number:0,uses:5, tooltip:"SLOW DOWN FELLA",character: args.state.character3})
    args.state.character3.character_add_element({name:"DEATH", type:"MG", amount:2, number:0,uses:5,tooltip:"GUESS I'LL DIE",character: args.state.character3})
    #Items
    args.state.character3.character_add_element({name:"POTION", type:"ITEM", amount:2, number:15,uses:0,tooltip:"HEAL 10 HP",character: args.state.character3})
    args.state.character3.character_add_element({name:"HIGH POTION", type:"ITEM", amount:2,number:20,uses:0, tooltip:"HEAL 50 HP",character: args.state.character3})
    args.state.character3.character_add_element({name:"SERUM", type:"ITEM", amount:2,number:15,uses:0, tooltip:"RESTORES 20 MP",character: args.state.character3})
    args.state.character3.character_add_element({name:"SUPER SERUM", type:"ITEM", amount:2, number:20,uses:0,tooltip:"RESTORES 20 MP",character: args.state.character3})
    args.state.character3.character_add_element({name:"PHOENIX DOWN", type:"ITEM", amount:2, number:70,uses:4,tooltip:"OPENS THE CAR",character: args.state.character3})
    args.state.character3.character_add_element({name:"ARTORIAS RING", type:"ITEM", amount:2,number:0,uses:0, tooltip:"BELONGS TO A GREAT WARRIOR OF OLD",character: args.state.character3})
    args.state.character3.character_add_element({name:"LIGHTER", type:"ITEM", amount:2, number:0,uses:0,tooltip:"WILL BRIGHT WHEN EVERYTHING IS DARK",character: args.state.character3})    
 


 #Introducing everything to the list
    args.state.characterArray.each_with_index do |element|
        element.items2.each_with_index do |item|
            args.state.list.add_element(item)
        end
    end
    
end




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
    args.state.lastObject ||= nil
    args.state.lastNumber ||= nil
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
         
        #This will paint all the combat interface for the squares in the button of the screen.
        args.outputs.sprites <<  {x: 269,y: 10,w: 977,h: 190,path: 'tfgSprites/Menus/FFVII_Skin_ByEthanFox.png',tile_x: 0,tile_y: 0,tile_w: 60,tile_h: 60,}

        args.outputs.sprites <<  {x: 225,y: 5, w: 1055,h: 200,path: 'tfgSprites/Menus/FFVII_Skin_ByEthanFox.png',tile_x: 96,tile_y: 0,tile_w:95,tile_h: 95,}

        args.outputs.sprites <<{x: 269,y: 18,w: 898,h:165,path: 'tfgSprites/Menus/FFVII_Skin_ByEthanFox.png',tile_x: 0,tile_y: 0,tile_w: 60,tile_h: 60,}

        args.outputs.sprites <<  {x: @x+8,y: @y+12,w: 231,h: 185,path: 'tfgSprites/Menus/FFVII_Skin_ByEthanFox.png',tile_x: 0,tile_y: 0,tile_w: 60,tile_h: 60,}

        args.outputs.sprites <<  {x: @x,y: @y+5,w: 245,h: 200,path: 'tfgSprites/Menus/FFVII_Skin_ByEthanFox.png',tile_x: 96,tile_y: 0,tile_w:95,tile_h: 95,}

        args.outputs.sprites <<  {x: @x+11,y: @y+12,w: 210,h: 170,path: 'tfgSprites/Menus/FFVII_Skin_ByEthanFox.png',tile_x: 0,tile_y: 0,tile_w: 60,tile_h: 60,}
        
        #Will load all the elements in windows.
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
            #While this element inside window and the boolean show is true, it will allow to select between the different buttons that have been created.
            if inputs.mouse.point.inside_rect?(click_area)

                #if the mouse is inside one of the areas of the different buttons, it will display a translucid rectangle that will be glowing whie the frames passes
                args.outputs.primitives << {x:(@parent.x+@x)*args.state.pixel_s-5,y:(@parent.y+@y)*args.state.pixel_s,w:53*args.state.pixel_s,h:10*args.state.pixel_s, r: 0, g: 0, b: 0, a: (args.tick_count + 40)% 120,}.solid 
                
                #Loading all the data for the ControllerButtonSprite.
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
        #args.state.tick_count < @time_shown is in case the mouse is over the button zone in the first frame. It can give errors.
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

    #List os a class that will contain a list of all the elements related to ATTACK,MG,ITEMS.
    #It will display every element of the list when is a players turn aswelll as the objective of the action when it needs to be selected.
    #Elements can be introduced in the list at any given time. 
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
        #This method will be introducing the different ATTACKS/MG/ITEMS
        element[:selected] = false
        @show = false
        @elements << element
    end
    
    def add_objective objective
        #The different possible targets of an action will be introduced here.
        @objectives << objective
    end

    def update_current_objectives 
        #This funciton will update the page of the current targets of an action.
        @current_objectives = []
       
        @objectives.each_with_index do |element,j| 
            
            if @objectiveIndex == 1
                @current_objectives << element if j < 3
            elsif @objectiveIndex == 0
                @current_objectives << element if j > 2 unless element.dead
            end

            
           
        end
    end


    def update_current_elements type
        
        #This method will be updating the action depending on which one was selected (Attack/mg/item)
        #Will also update the page showed as there are only 4 slots for showing the action in each page.

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
        #Updates the index of the target page 
        #In one of the pages the enemy will be shownn, an in the other the main characters.
        @objectiveIndex = (@objectiveIndex + 1) % 2 
    end

    def mouse_over?
        #This function will controll the item of the action selectedd wheather it is a normal attack, a magic or an item.
        #Whenever the mouse is positiones over any of the different options, it will show a glowing rectangle
        #It will also display the X button of the controller for it to be pressed to confirm the action.

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

                            #When one of the options is selected, the character an the action selected are both stored in variables.
                            #@flag is a boolean that will mark if an action has been selected in order to start working 
                            #and displaying the targets of the action.
                            #@firstAction will store the frame in which the action was clicked on. 
                            #Whenever two different click_events must take place in the same place one after another.
                            #A delay is needed, so for the next action an elapsed time will take care after the @firstAction

                            soundButton args, "sounds/Cursor2.ogg"
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
        #This function works the same way as mouse_over and will take place one flag is true
        #Will allow the user to select the target of the action.

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
                            #this action will take place 10 frames after the @firstAction ocurred.
                            calculateAction element
                            soundButton args,"sounds/Cursor2.ogg"
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
         #This method will calculate all the damage or item action.

        if @selectedItem[:type] == "ATTACK"
                               
            element.hp = (element.hp - @selectedItem[:number] * @selecteCharacter.attackStat).clamp(0,element.maxHP)
            args.state.lastNumber = (@selectedItem[:number] * @selecteCharacter.attackStat).clamp(0,element.maxHP)
            
        elsif @selectedItem[:type] == "MG" && @selectedItem[:name] != "HEAL"
           
            element.hp = (element.hp - @selectedItem[:number] * @selecteCharacter.mgStat).clamp(0,element.maxHP)
            @selecteCharacter.mg = (@selecteCharacter.mg - @selectedItem[:uses]).clamp(0,@selecteCharacter.maxMg)
            args.state.lastNumber = (@selectedItem[:number] * @selecteCharacter.mgStat).clamp(0,@selecteCharacter.maxMg)
            
        elsif @selectedItem[:type] == "MG" && @selectedItem[:name] == "HEAL"

            element.hp = (element.hp + @selectedItem[:number]).clamp(0,element.maxHP)
            @selecteCharacter.mg = (@selecteCharacter.mg - @selectedItem[:uses]).clamp(0,@selecteCharacter.maxMg)
            args.state.lastNumber = (@selecteCharacter.attackStat).clamp(0,@selecteCharacter.maxMg)

        elsif @selectedItem[:type] == "ITEM" 
           
            if (@selectedItem[:name] == "POTION" || @selectedItem[:name] == "HIGH POTION") && (@selectedItem[:amount] > 0) && (!element.dead)
                element.hp = (element.hp + @selectedItem[:number]).clamp(0,element.maxHP)
                args.state.lastNumber = (@selectedItem[:number]).clamp(0,element.maxHP)
            elsif (@selectedItem[:name] == "SERUM" || @selectedItem[:name] == "SUPER SERUM") && (@selectedItem[:amount] > 0) && (element.hp > 0)

                element.mg = (element.mg + @selectedItem[:number]).clamp(0,element.maxMg)
                args.state.lastNumber = (@selectedItem[:number]).clamp(0,element.maxMg)
            elsif (@selectedItem[:name] == "PHOENIX DOWN") && (@selectedItem[:amount] > 0) && (element.dead)
                element.dead = false
               element.hp = (element.hp + @selectedItem[:number]).clamp(0,element.maxHP)
               args.state.lastNumber = (@selectedItem[:number]).clamp(0,element.maxHP)

            end
            @selectedItem[:amount] = (@selectedItem[:amount] - 1).clamp(0,999999)
            

        end

        if !element.dead

            #if the element is not dead, it kills and set two boolean to true.
            #dead will remain active during the whole time a character is dead
            #dying will only be active during the dead animation of the character.

            element.dead = true  if element.hp == 0 
            element.dying = true if element.hp == 0
        end

        #storing both the selectedItem and the target to get the apropiate animation later.

        args.state.lastObject = @selectedItem
        args.state.lastObjective = element
       
    end

    def draw

        if @flag == false

            #While @firstAction has not taken place yet, the name of the actions will be displayed

            @current_elements.each_with_index do |element,j|
                if j<4
                    args.outputs.primitives << {x: (@parent.x+@x+3)*args.state.pixel_s, y: (@parent.y+@y+7-11*j)*args.state.pixel_s + 150,r: 255, g: 255, b: 255,
                        text: element[:name].upcase,font:"tfgSprites/font/EightBitDragon-anqx.ttf"}.label 
                    
                end
                
            end
        else  

            #The moment @firstAction has taken place, the target names will be displayed.
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

    #This class works in the same way of Button.
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

    #Actions for pressing the buttons are controlled here
    #Depending on which button is pressed the args.state.atualType will be changed
    #For displaying the selected option when showing the element of the list.

    if args.state.attack_button.clicked_on? 
       soundButton args, "sounds/Cursor2.ogg"
       
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
        soundButton args, "sounds/Cursor2.ogg"
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
        soundButton args, "sounds/Cursor2.ogg"
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
        #Introducir algo de random y combate acabao o pasar turno.
    end

    if args.state.triangle_button.clicked_on? || args.inputs.controller_one.key_down.y
        soundButton args, "sounds/Cursor2.ogg"
        #This will control whenever the information is displayed while list.show is true.
        if args.state.triangle == false
            args.state.triangle = true
        else
            args.state.triangle = false
        end

    end
    
    if args.state.nextPage_button.clicked_on? || args.inputs.controller_one.key_down.right 
        soundButton args, "sounds/Cursor2.ogg"
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
    
        #allows to go back and change the action.
        if args.inputs.controller_one.key_down.b || args.inputs.keyboard.key_down.escape
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

     #Displays information of the items when they are on screen.

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

    if args.state.character1.dead && args.state.character2.dead && args.state.character3.dead 
        puts "YOU ARE DEAD"
    else
        args.state.characterArray[args.state.actualCharacterIndex].turn = false
        args.state.actualCharacterIndex  = (args.state.actualCharacterIndex + 1) % args.state.characterArray.length
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

    #Animations of every character will take place depending on the action
    #If an enemy is eleminated, it will be deleted from the array of characters.
    args.state.characterArray.each_with_index do |element, j |
        if !element.dead 

            if element.turn && element.enemy
                args.state.letFinish ||= args.tick_count if args.state.letFinish == nil
                if args.tick_count > args.state.letFinish  + 60
                    args.state.time ||= args.tick_count if args.state.time == nil
                    if args.tick_count < args.state.time + 1
                    enemySelectTarget args,element
                    end
                    if(args.tick_count < args.state.time + 150)
                     enemyTurn args,element,element.attackStat
                    
                    else 
                        args.state.letFinish = nil
                        args.state.time = nil
                        pass_turn args
                    end
                else args.outputs.sprites << element.standing_sprite
                end
            
            else
                
                if element.attack
                    element.start_looping_at = args.state.tick_count   
                end
        
                if !element.start_looping_at
                    args.outputs.sprites << element.standing_sprite
                    if element.turn == true
                        

                        args.outputs.primitives << 
                        { x:element.x + 35, 
                        y: element.y,
                        w:element.w - 70,
                        h:element.h, 
                        r: 0, g: 0, b: 0, a: (args.tick_count + 70)% 120,}.solid

                    end
                    
                else 
                    
                    if element.start_looping_at.elapsed?(50)
                        element.start_looping_at = nil
                    end

                    if args.state.list.actualType == "ATTACK"
                        args.outputs.primitives << element.attack_move.sprite

                    elsif args.state.list.actualType == "MG"
                        args.outputs.primitives << element.magic_move.sprite
                        
                    elsif args.state.list.actualType == "ITEM"
                        args.outputs.primitives << element.item_move.sprite
                        

                    end
                    selectAnimation args,element.start_looping_at,args.state.lastObject
                    args.outputs.primitives << displayDamage(args)
                    element.attack = false
                end
            end

        else
            if !element.enemy
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
            end

            if  element.enemy
                args.state.characterArray.reject{element}
            end
            
        end
        
    end
end

def selectAnimation args, tempo,item

    #Will display an animation depending on the action
    #That will be taking place. 
    how_many_frames_in_sprite_sheet = 5
    number_of_frames_to_show_each_sprite = 13
    should_the_index_repeat = false
    tile_index = tempo.frame_index how_many_frames_in_sprite_sheet,
                                number_of_frames_to_show_each_sprite,
                                should_the_index_repeat
    
    tile_index ||= 0                             
    if item[:type] == "ATTACK"
        soundButton args, "sounds/Slash1.ogg"
        args.outputs.primitives << {
        x: args.state.lastObjective.x ,
        y: args.state.lastObjective.y- 10,
        w: args.state.lastObjective.w,
        h: args.state.lastObjective.h ,
        path: "tfgSprites/AttackSprites/Slash - copia.png",
        tile_x:20 +  (tile_index * 192.4),
        tile_y: 0,
        tile_w: 192.4,
        tile_h: 280,
        }.sprite
        
    elsif item[:name] == "FIRE"

        soundButton args, "sounds/Fire1.ogg"
        args.outputs.primitives <<  {
            x: args.state.lastObjective.x ,
            y: args.state.lastObjective.y- 10,
            w: args.state.lastObjective.w,
            h: args.state.lastObjective.h ,
            path: "tfgSprites/AttackSprites/Fire2.png",
            tile_x: 20 +  (tile_index * 192),
            tile_y: 20,
            tile_w: 192,
            tile_h:170,
        }.sprite
    elsif item[:name] == "ICE"
        soundButton args, "sounds/Ice1.ogg"
        args.outputs.primitives << {
            x: args.state.lastObjective.x ,
            y: args.state.lastObjective.y- 10,
            w: args.state.lastObjective.w,
            h: args.state.lastObjective.h ,
            path: "tfgSprites/AttackSprites/Ice5.png",
            tile_x: 0 +  (tile_index * 192),
            tile_y: 384 ,
            tile_w: 192,
            tile_h:192,
        }.sprite
    elsif item[:name] == "THUNDER"
        soundButton args, "sounds/Thunder1.ogg"
        args.outputs.primitives << {
            x: args.state.lastObjective.x ,
            y: args.state.lastObjective.y- 10,
            w: args.state.lastObjective.w,
            h: args.state.lastObjective.h ,
            path: "tfgSprites/AttackSprites/Thunder5 - copia.png",
            tile_x: 0 +  (tile_index * 192),
            tile_y: 384 ,
            tile_w: 192,
            tile_h:192,
        }.sprite
    else 
        soundButton args, "sounds/Heal1.ogg"
        args.outputs.primitives << {
            x: args.state.lastObjective.x ,
            y: args.state.lastObjective.y- 10,
            w: args.state.lastObjective.w,
            h: args.state.lastObjective.h ,
            path: "tfgSprites/AttackSprites/Recovery1.png",
            tile_x: 0 +  (tile_index * 192),
            tile_y: 576 ,
            tile_w: 192,
            tile_h:192,
        }.sprite

    end
    
   
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

def displayDamage args
    {x:args.state.lastObjective.x + 70,
        y:args.state.lastObjective.y + 175,
        w:args.state.lastObjective.w,
        h:args.state.lastObjective.h,
        text: args.state.lastNumber,
        r: 255, g: 255, b: 255,
        font:"tfgSprites/font/EightBitDragon-anqx.ttf"}
end

def enemyTurn args,element,number
    args.outputs.primitives << element.standing_sprite
    args.outputs.primitives <<  args.outputs.primitives << 
    { x:element.x + 35, 
    y: element.y,
    w:element.w - 70,
    h:element.h, 
    r: 0, g: 0, b: 0, a: (args.tick_count + 70)% 120,}.solid

    args.outputs.primitives <<  {x:args.state.lastObjective.x + 70,
        y:args.state.lastObjective.y + 175,
        w:args.state.lastObjective.w,
        h:args.state.lastObjective.h,
        text: element.attackStat,
        r: 255, g: 255, b: 255,
        font:"tfgSprites/font/EightBitDragon-anqx.ttf"}

end 

def enemySelectTarget args,element
    randomObjective = rand(3)
    args.state.lastObjective =  args.state.characterArray[randomObjective]
    if !args.state.lastObjective.dead
        args.state.lastObjective.hp = (args.state.lastObjective.hp - element.attackStat).clamp(0,args.state.characterArray[randomObjective].maxHP)
        args.state.lastObjective.dying = true if args.state.lastObjective.hp == 0
        args.state.lastObjective.dead = true if args.state.lastObjective.hp == 0
    else
         if args.state.character1.dead && args.state.character2.dead && args.state.character3.dead
            puts "GAME OVER"
        else    
            enemySelectTarget args, element
        end
    end
end

def soundButton args, inputSource
    args.audio[:my_audio] ||= {
        input: inputSource,  # Filename
        x: 0.0, y: 0.0, z: 0.0,   # Relative position to the listener, x, y, z from -1.0 to 1.0
        gain: 0.5,                # Volume (0.0 to 1.0)
        pitch: 1.0,               # Pitch of the sound (1.0 = original pitch)
        paused: false,            # Set to true to pause the sound at the current playback position
        looping: false,           # Set to true to loop the sound/music until you stop it
      }
end

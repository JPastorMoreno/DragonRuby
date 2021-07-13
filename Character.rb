

class Character
    attr_accessor :x, :y, :w, :h,
                  :elements, :text,:standing_sprite, :sprite_path, :items,:items2, :turn, :attack, :start_looping_at, :hp, :maxHP, :mg, :maxMg,
                  :attackStat,:mgStat,:dead,:enemy,:dying

    def initialize args, x, y, w, h,hp,maxHP,mg,maxMg,attackStat,mgStat,sprite_path,text
       
            @args = args
            @x = x
            @y = y
            @w = w
            @h = h
            @elements = []
            @text = text
            @hp = hp
            @maxHP = maxHP
            @mg = mg
            @maxMg = maxMg
            @sprite_path = sprite_path
            @items =  {name:"", type:"",amount:0,number:0,uses:0, tooltip:"",character: 0}
            @items2 = []
            @turn = false
            @attack = false 
            @start_looping_at = start_looping_at
            @attackStat = attackStat
            @mgStat = mgStat
            @dead = false
            @enemy = false
            @dying = false
           
    end
    def standing_sprite 
         {
          x:@x,
          y: @y,
          w: @w,
          h: @h,
          tile_x: -1,
          tile_y: 710,
          tile_w: 65,
          tile_h: 65,
          path: @sprite_path,
        }
    end
    def attack_move
            directionx = 64
            directiony = 1992
            
    
            how_many_frames_in_sprite_sheet = 6
            number_of_frames_to_show_each_sprite = 5
            should_the_index_repeat = false
            tile_index = @start_looping_at.frame_index how_many_frames_in_sprite_sheet,
                                        number_of_frames_to_show_each_sprite,
                                          should_the_index_repeat
            
            tile_index ||= 0                             

        {
          x: @x + 100,
          y: @y - 10,
          w: @w + 50 ,
          h: @h ,
          path: @sprite_path,
          tile_x: 64 +  (tile_index * 192),
          tile_y: 1992,
          tile_w: 96,
          tile_h: 66,
        }
    end
    def magic_move
        directionx = 64
        directiony = 1992
        

        how_many_frames_in_sprite_sheet = 7
        number_of_frames_to_show_each_sprite = 10
        should_the_index_repeat = false
        tile_index = @start_looping_at.frame_index how_many_frames_in_sprite_sheet,
                                    number_of_frames_to_show_each_sprite,
                                      should_the_index_repeat
        
        tile_index ||= 0                             
     
      {
        x: @x + 100,
        y: @y - 10,
        w: @w ,
        h: @h ,
        path: @sprite_path,
        tile_x: 64 +  (tile_index * 64),
        tile_y: 196,
        tile_w: 65,
        tile_h: 66,
      }
    end

    def item_move
            directionx = 64
            directiony = 1992
            

            how_many_frames_in_sprite_sheet = 7
            number_of_frames_to_show_each_sprite = 10
            should_the_index_repeat = false
            tile_index = @start_looping_at.frame_index how_many_frames_in_sprite_sheet,
                                        number_of_frames_to_show_each_sprite,
                                        should_the_index_repeat
            
            tile_index ||= 0                             
        

        {
        x: @x + 100,
        y: @y - 10,
        w: @w ,
        h: @h ,
        path: @sprite_path,
        tile_x: 64 +  (tile_index * 64),
        tile_y: 960,
        tile_w: 65,
        tile_h: 66,
        }
    end
    def character_add_element element  
        @items2 << element
    end
    def start_looping 
        @start_looping_at = args.state.tick_count
    end

    def dying_move 
      directionx = 64
      directiony = 1992
      
      how_many_frames_in_sprite_sheet = 7
      number_of_frames_to_show_each_sprite = 10
      should_the_index_repeat = false
      tile_index = @start_looping_at.frame_index how_many_frames_in_sprite_sheet,
                                  number_of_frames_to_show_each_sprite,
                                  should_the_index_repeat
      
      tile_index ||= 0                             
  
      {
        x: @x ,
        y: @y - 10,
        w: @w ,
        h: @h ,
        path: @sprite_path,
        tile_x: 64 +  (tile_index * 64),
        tile_y: 1280,
        tile_w: 65,
        tile_h: 66,
      }
      
    end
    def is_dead
      {
        x: @x ,
        y: @y - 10,
        w: @w ,
        h: @h ,
        path: @sprite_path,
        tile_x: 320,
        tile_y: 1280,
        tile_w: 65,
        tile_h: 66,
      }
    end


end
class Enemy  
  attr_accessor :x, :y, :w, :h,
                  :elements, :text,:standing_sprite, :sprite_path, :items,:items2, :turn, :attack, :start_looping_at,
                  :hp, :maxHP, :mg, :maxMg,
                  :attackStat,:mgStat,:dead,:enemy,:dying
  def initialize args,x,y,w,h,hp,maxHP,attackStat,sprite_path,text
    @args = args
    @x = x
    @y = y
    @w = w
    @h = h
    @elements = []
    @text = text
    @attackStat = attackStat
    @mgStat = mgStat
    
    @hp = hp
    @mg = maxHP
    @sprite_path = sprite_path
    @items =  {name:"", type:"", amount:0, tooltip:"",character: 0}
    @items2 = []
    @turn = false
    @attack = false 
    @start_looping_at = start_looping_at
    @dead = false
    @enemy = true
    @dying = false
  end
  def standing_sprite

    how_many_frames_in_sprite_sheet = 3
      number_of_frames_to_show_each_sprite = 20
      should_the_index_repeat = true
      tile_index = 0.frame_index how_many_frames_in_sprite_sheet,
                                  number_of_frames_to_show_each_sprite,
                                    should_the_index_repeat
      tile_index ||= 0   
#Each monster inside W = 50, h = 49,w,h  = 150
#Pig Tile_x = 189
#zubat = -5         Tile Y   = 48
#Slime = 140

#Demon Y = 242
    {
     x:@x,
     y: @y,
     w: 150,
     h: 150,
     tile_x: -5 + (tile_index * 50),
     tile_y: 242,
     tile_w: 49,
     tile_h: 48,
     path: "tfgSprites/Monsters/monsters.png",
   }

  end
end

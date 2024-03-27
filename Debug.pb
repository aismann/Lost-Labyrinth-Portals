;-



; ;- modify attribute by tile structure
; ; update; reset_tile_type_db(), load_tile_type_definition()
; Structure modify_attribute_by_tile_struct
;   attribute.w ; id of ability that is changed when character enters field
;   attribute_name$ ; name of ability that is changed when character enters field
;   amount.w ; amount of increase
;   amount_randomized.b ; flag: 1=amount is randomized (default: 0)
;   amount_reduced_by_ability.w ; ID of ability that reduces amount (default: 0)
;   amount_reduced_by_ability_name$ ; name of ability that reduces amount (default: 0)
;   replenish.b ; flag: 1=restore depleted attribute to max value (default: 0)
;   trigger_hidden.b ; flag; 1=attribute modification are triggered even when tile is still hidden (e.g. traps) (default: 0)
;   turn_ends.b ; flag; 1=current turn ends if modification is triggered (default: 0)
; EndStructure
; 
; 
; ;- tile type database structure
; ; update; reset_tile_type_db(), load_tile_type_definition()
; Structure tile_type_db_struct
;   in_use.b ; flag: 0=tile type not in use, 1=tile type in use (default: 1)
;   name$ ; name of tile type
;   solid.b ; flag; 0=non-solid (can be passed through), 1=solid (blocks movement) (default: 0)
;   blocks_flight.b ; flag; 1=tile blocks flying creatures (default: 0)
;   transparent.b ; 0=non-transparent, 1=transparent (display background tile underneath)
;   message$ ; message that gets displayed when character enters tile
;   remove_after_entering.b ; flag; 1=tile is replaced by default tile after character enters
;   sound$ ; name of sound played when entering field
;   class$ ; name of class tile belongs to
;   transforms_into.w ; ID of new tile this tile can be transformed into (default: 0)
;   container.b ; number of items created when tile is transformed; items on this tile are not shown (default: 0)
;   hidden.b ; flag; 1=tile is displayed as background until detected (default: 0)
;   detection_message$ ; message displayed when hidden tile is detected
;   detection_sound$ ; sound played when hidden tile is detected
;   animation_enter$ ; animation displayed when entering
;   modify_attribute.modify_attribute_by_tile_struct[#MAX_NUMBER_OF_ATTRIBUTES_MODIFIED_BY_TILE] ; modify attributes when entering tile
; EndStructure
; 
; 
; ;- tileset structure
; Structure tileset_struct
;   name$ ; name of tileset
;   image_filename$ ; filename of tileset
;   image.i ; pointer to tileset image
;   image_loaded.b ; flag: 1=tileset image already loaded
;   sprite.i ; pointer to tileset sprite
;   sprite_loaded.b ; flag: 1=tileset sprite already loaded
;   rows.w ; number of tile rows in tileset
;   columns.w ; number of tile columns in tileset
;   definition_filename$ ; filename of tile type definition xml file
;   tile_type_db.tile_type_db_struct[#MAX_NUMBER_OF_TILE_TYPES] ; tile type definition for this map
; EndStructure

; ;- map field structure
; ; update: reset_map(), load_map(), save_map()
; Structure mapfield_struct
;   tile_type.w ; ID of tile image
;   portal_mapfile.s ; filename of map portal leads to
;   portal_x.b ; target x of portal
;   portal_y.b ; target y of portal
;   message_line1$ ; message displayed when entering/pushing field; first line
;   message_line2$ ; message displayed when entering/pushing field; second line
;   message_tile.w ; ID of tile image displayed with message
;   event$ ; name of map event triggered by this field
;   event_xp.b ; flag: 1=event causes character to gain experience (default:0)
;   power_used$ ; string list of powers already used on this field (default: "")
;   hidden.b ; flag; 1=field is displayed as background tile (default: 0)
;   visited.b ; flag; 1=character has been adjacent to this field (default: 0)
; EndStructure
; 
; 
; ;- map structure
; Structure map_struct
;   name.s ; name of map
;   filename$ ; filename of map
;   tileset.tileset_struct ; tileset used in map
;   mapfield.mapfield_struct[#MAP_DIMENSION_X*#MAP_DIMENSION_Y] ; map tiles
;   tile_outside_map.w ; ID of tile used to display outside of map dimensions
;   default_tile.w ; ID of tile used as default map tile
;   background_tile.w ; ID of tile image used as background for transparent tiles
;   spawn_monster_level.w ; level of monsters spawn on map (0=no new monsters are spawn)
;   spawn_monster_chance.w ; percentage of chance that a random new monster is spawn each turn
;   visited.b ; flag: 1=character has already visited map (default: 0)
;   lighting.b ; default lighting of map (from 0=no light to 8=full light; default: 0)
; EndStructure




Procedure draw_debug_infos_4_Developers() 
  ;- 
  If LabyDebugFlag = 0: ProcedureReturn: EndIf
  
  Protected *map.map_struct = @current_map
  Protected x_offset.b=0, y_offset.b=0, fade.w=0, char_y_offset.b=0
  
  Protected i.w = 1, j.w, x.b, y.b, row.b = 0, column.b = 0, text$, text2$, column_width.w=160, attribute_current_val.w
  Protected NewList tile_list.tile_list_struct(), display.b = 0
  Protected tile_type.w, display_message.b, lighting.b
  
;   tile_type = read_map_tile_type(*map, current_character\xpos +1, current_character\ypos)
;   Debug tile_type
  
  
  For y = 0 To 12
    For x = 0 To 12
      tile_type = read_map_tile_type(*map, current_character\xpos - 6 + x, current_character\ypos - 6 + y)
      If read_map_hidden(*map, current_character\xpos - 6 + x, current_character\ypos - 6 + y) = 1
        ;   tile_type = *map\background_tile
      EndIf
      If *map\tileset\tile_type_db[tile_type]\transparent = 1
        clip_tile_sprite(*map, current_map\background_tile)
        DisplaySprite(*map\tileset\sprite, wWidth - xDebug +56 + x*32 + x_offset, y*32 + y_offset)
        clip_tile_sprite(*map, tile_type)
        DisplayTransparentSprite(*map\tileset\sprite, wWidth - xDebug +56 +x*32 + x_offset, y*32 + y_offset)
      ElseIf tile_type <> *Map\background_tile
          clip_tile_sprite(*map, tile_type)
          DisplaySprite(*map\tileset\sprite, wWidth - xDebug +56+ x*32 + x_offset, y*32 + y_offset)
      ElseIf  *map\mapfield[x + (y * #MAP_DIMENSION_Y)]\hidden = 1
          clip_tile_sprite(*map, tile_type)
          DisplaySprite(*map\tileset\sprite, wWidth - xDebug +56+ x*32 + x_offset, y*32 + y_offset)
      EndIf
    Next
  Next
  
  ; display items
  Protected xxx.l = 0
  ForEach item_on_map()
    
    If item_on_map()\xpos >= current_character\xpos-7 And item_on_map()\xpos <= current_character\xpos+6 And item_on_map()\ypos >= current_character\ypos-7 And item_on_map()\ypos <= current_character\ypos+6
      tile_type = read_map_tile_type(*map, item_on_map()\xpos, item_on_map()\ypos)
      
      ; If *map\tileset\tile_type_db[tile_type]\container = 0
      clip_item_tile_sprite(item_db(item_on_map()\type)\tile)
      DisplayTransparentSprite(#SPRITE_ITEMS, wWidth - xDebug +56 +(item_on_map()\xpos - current_character\xpos + 6) * 32 + x_offset, (item_on_map()\ypos - current_character\ypos + 6) * 32 + y_offset)
      ; EndIf
    EndIf
    If item_on_map()\xpos = current_character\xpos And item_on_map()\ypos = current_character\ypos
      tile_type = read_map_tile_type(*map, item_on_map()\xpos, item_on_map()\ypos)
      Debug tile_type
      ; If *map\tileset\tile_type_db[tile_type]\container = 0
      clip_item_tile_sprite(item_db(item_on_map()\type)\tile)
      DisplayTransparentSprite(#SPRITE_ITEMS, wWidth - xDebug + 50 + xxx, 16+32)
      xxx + 32
      ; EndIf
    EndIf    
  Next
  
  ; draw character
  ClipSprite(#SPRITE_Characters, current_character\facing*64 + current_character\frame*32, 0, 32, 32)
  DisplayTransparentSprite(#SPRITE_Characters, wWidth - xDebug +56 +6*32, 6*32 + y_offset)
  
  StartDrawing(ScreenOutput())
  DrawText(wWidth - xDebug + 50, 16, "PlayerPos (" + Str(current_character\xpos) + ", " + Str(current_character\ypos) + ")", RGB(255, 100, 0), RGB(0, 0, 0))
  
  If LabyDebugFlag = 2
    DrawingFont(FontID(#FONT_SMALL))
    For i = 1 To #MAX_NUMBER_OF_ABILITIES - 1
      attribute_current_val = attribute_current_val(i)
      For j = 0 To #MAX_NUMBER_OF_ABILITY_DISPLAYS - 1
        display = 1
        If ability_db(i)\display[j]\type <> 2
          display = 0
        EndIf
        
        If ability_db(i)\display[j]\type = 2 And ((ability_db(i)\display[j]\start_value <= attribute_current_val And ability_db(i)\display[j]\end_value >= attribute_current_val) Or (ability_db(i)\display[j]\start_value = 0 And ability_db(i)\display[j]\end_value = 0))
          text$ = ReplaceString(ability_db(i)\display[j]\message$, "[value]", Str(attribute_current_val))
          If ability_db(i)\display[j]\expanded_value_display = 1
            text$ = ReplaceString(ability_db(i)\display[j]\message$, "[value]", ability_expanded_value_display(i))
          EndIf
          DrawText(wWidth - xDebug +56 + column*column_width, 52 + row*32, text$, ability_db(i)\display[j]\color, 0)
          If ability_db(i)\display[j]\message2$ <> ""
            text$ = ReplaceString(ability_db(i)\display[j]\message2$, "[value]", Str(attribute_current_val))
            If ability_db(i)\display[j]\expanded_value_display = 1
              text$ = ReplaceString(ability_db(i)\display[j]\message2$, "[value]", ability_expanded_value_display(i))
            EndIf        
            
            DrawText(wWidth - xDebug +56 + column*column_width, 68 + row*32, text$ + " I:" + Str(i) + " J:" + Str(j), ability_db(i)\display[j]\color, 0)
          EndIf
          AddElement(tile_list())
          With tile_list()
            \x = wWidth +20 + (column * column_width)
            \y = 52 + (row * 32)
            \tile = ability_db(i)\tile
            \type = 1
          EndWith
          row = row + 1
          If row > 10
            row = 0
            column = column + 1
          EndIf
        EndIf
      Next
    Next
  EndIf 
  StopDrawing()
  
EndProcedure
; IDE Options = PureBasic 6.10 LTS beta 9 (Windows - x64)
; CursorPosition = 120
; FirstLine = 100
; Folding = -
; EnableXP
; DPIAware
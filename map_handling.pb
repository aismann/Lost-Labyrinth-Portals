; Lost Labyrinth VI: Portals
; map handling procedures
; written in PureBasic 4.20 (http://www.purebasic.com)
; created:  08.10.2008 Frank Malota <malota@web.de>
; modified: 22.12.2008 Frank Malota <malota@web.de>


; declaration of used procedures
Declare message(line1$, line2$, color.l=$ffffff, tile.w=-1, tile_type.b = 0, display_for.l=2000)
Declare fade_map_screen_out(*map.map_struct)
Declare fade_map_screen_in(*map.map_struct)
Declare.b add_monster(*map.map_struct, *new_monster.monster_struct)
Declare experience(experience_points.w = 1, game_start.b = 0)
Declare play_sound(sound_filename$)
Declare.w attribute_current_val(id.w, include_attribute_cap.b = 1, include_power_adjustment.b = 1, include_item_bonus_adjustment.b = 1)
Declare add_random_item(x.w, y.w, rarity.w = 5, class$ = "")
Declare.w random_item_type(rarity.l = 5, class$ = "", artefact.b = 0)
Declare place_random_monster(*map.map_struct, max_monster_level.w = 99999)
Declare.w magic_bonus()
Declare.w perception_val(tile_class$)
Declare.w modify_attribute(attribute_id.w, value.w)
Declare.b restore_attribute(id.w)
Declare animation(name$, x.b = 6, y.b = 6, animation_parameter.w = 0)
Declare.b field_contains_monster(x.b, y.b)


; resets a tile type definition db
Procedure reset_tile_type_db(*tileset.tileset_struct)
  Protected i.l, j.w
  For i=0 To #MAX_NUMBER_OF_TILE_TYPES-1
    With *tileset\tile_type_db[i]
      \in_use = 0
      \name$ = ""
      \solid = 0
      \blocks_flight = 0
      \transparent = 0
      \message$ = ""
      \remove_after_entering = 0
      \sound$ = ""
      \class$ = ""
      \transforms_into = 0
      \container = 0
      \hidden = 0
      \detection_message$ = ""
      \detection_sound$ = ""
      \animation_enter$ = ""
    EndWith
    For j = 0 To #MAX_NUMBER_OF_ATTRIBUTES_MODIFIED_BY_TILE - 1
      With *tileset\tile_type_db[i]\modify_attribute[j]
        \attribute = 0
        \attribute_name$ = ""
        \amount = 0
        \amount_randomized = 0
        \amount_reduced_by_ability = 0
        \amount_reduced_by_ability_name$ = ""
        \replenish = 0
        \trigger_hidden = 0
        \turn_ends = 0
      EndWith
    Next
  Next  
EndProcedure


; resolve ability names in tile type db
Procedure resolve_tile_type_definition_names(*tileset.tileset_struct)
  Protected i.w, j.w, k.w
  For i=0 To #MAX_NUMBER_OF_TILE_TYPES - 1
    For j = 0 To #MAX_NUMBER_OF_ATTRIBUTES_MODIFIED_BY_TILE - 1
      For k=0 To #MAX_NUMBER_OF_ABILITIES - 1
        If ability_db(k)\name$ = *tileset\tile_type_db[i]\modify_attribute[j]\attribute_name$
          *tileset\tile_type_db[i]\modify_attribute[j]\attribute = k
        EndIf
        If ability_db(k)\name$ = *tileset\tile_type_db[i]\modify_attribute[j]\amount_reduced_by_ability_name$
          *tileset\tile_type_db[i]\modify_attribute[j]\amount_reduced_by_ability = k
        EndIf        
      Next
    Next
  Next
EndProcedure


; resets a tileset
Procedure reset_tileset(*tileset.tileset_struct)
  *tileset\name$ = ""
  *tileset\image_filename$ = ""
  *tileset\definition_filename$ = ""
  If *tileset\image_loaded
    FreeImage(*tileset\image)
  EndIf
  *tileset\image_loaded = 0
  If *tileset\sprite_loaded
    FreeSprite(*tileset\sprite)
  EndIf
  *tileset\sprite_loaded = 0
  *tileset\rows = 0
  *tileset\columns = 0
  *tileset\definition_filename$ = ""
  reset_tile_type_db(*tileset)
EndProcedure


; load tile type definition into tile type database
Procedure load_tile_type_definition(*tileset.tileset_struct)
  Protected x.b, y.b, id.w=0, solid.b=0, transparent.b=0, ability.w, ability_name$
  Protected amount.w, amount_randomized.b, message$, remove_after_entering.b, replenish.b
  Protected sound$, amount_reduced_by_ability_name$, amount_reduced_by_ability.w
  Protected class$, transforms_into.w, container.b, modify_attribute_idx.b
  Protected new_tile_type.tile_type_db_struct
  Protected new_modify_attribute.modify_attribute_by_tile_struct
  Protected *mainnode, *node, val$, *childnode, val2$
  If CreateXML(0) = 0
    error_message("load_tile_type_defition(): could not create xml structure in memory!")
  EndIf
  If FileSize("tilesets\" + GetFilePart(*tileset\definition_filename$)) < 1
    error_message("load_tile_type_defition(): could not find tile type definition xml file: " + Chr(34) + *tileset\definition_filename$ + Chr(34))
  EndIf
  If LoadXML(0, "tilesets\" + GetFilePart(*tileset\definition_filename$)) = 0
    error_message("load_tile_type_defition(): could not open tile type definition xml file: " + Chr(34) + *tileset\definition_filename$ + Chr(34))
  EndIf
  If XMLStatus(0) <> 0
    error_message("load_tile_type_defition(): error in xml structure of map file " + Chr(34) + GetFilePart(*tileset\definition_filename$) + Chr(34) + ": " + XMLError(0))
  EndIf
  reset_tile_type_db(*tileset)
  *mainnode = MainXMLNode(0)
  If ExamineXMLAttributes(*mainnode)
    While NextXMLAttribute(*mainnode)
      val$ = XMLAttributeValue(*mainnode)
      Select XMLAttributeName(*mainnode)
      
        Case "filename":
          ;tileset_filename$ = val$
          
        Case "Lost_Labyrinth_version":
        
        Default:
          error_message("load_tile_type_defition(): unknown attribute " + Chr(34) + XMLAttributeName(*mainnode) + Chr(34) + " in tileset definition file " + Chr(34) + *tileset\definition_filename$ + Chr(34))
          
      EndSelect
    Wend
  EndIf
  If *mainnode
    *node = ChildXMLNode(*mainnode)
    While *node <> 0
      Select GetXMLNodeName(*node)
      
        Case "tile_type":
          With new_tile_type
            \in_use = 0
            \name$ = ""
            \solid = 0
            \blocks_flight = 0
            \transparent = 0
            \message$ = ""
            \remove_after_entering = 0
            \sound$ = ""
            \class$ = ""
            \transforms_into = 0
            \container = 0
            \hidden = 0
            \detection_message$ = ""
            \detection_sound$ = ""
            \animation_enter$ = ""
          EndWith
          id = -1
          modify_attribute_idx = 0
          If ExamineXMLAttributes(*node)
            While NextXMLAttribute(*node)
              val$ = XMLAttributeValue(*node)
              Select XMLAttributeName(*node)
              
                Case "id":
                  id = Val(val$)
                
                Case "solid":
                  If val$ = "yes"
                    new_tile_type\solid = 1
                  EndIf
                  
                Case "blocks_flight":
                  If val$ = "yes"
                    new_tile_type\blocks_flight = 1
                  EndIf
                  
                Case "name":
                  new_tile_type\name$ = val$
                  
                Case "transparent":
                  If val$ = "yes"
                    new_tile_type\transparent = 1
                  EndIf
                  
                Case "message":
                  new_tile_type\message$ = val$
                  
                Case "remove_after_entering":
                  If val$="yes"
                    new_tile_type\remove_after_entering = 1
                  EndIf
                  
                Case "sound":
                  new_tile_type\sound$ = val$
                  
                Case "transforms_into":
                  new_tile_type\transforms_into = Val(val$)
                  
                Case "class":
                  new_tile_type\class$ = val$
                  
                Case "container":
                  new_tile_type\container = Val(val$)
                  
                Case "hidden":
                  If val$ = "yes"
                    new_tile_type\hidden = 1
                  EndIf
                  
                Case "detection_message":
                  new_tile_type\detection_message$ = val$
                  
                Case "detection_sound":
                  new_tile_type\detection_sound$ = val$
                  
                Case "animation_enter":
                  new_tile_type\animation_enter$ = val$
                    
                Default:
                  error_message("load_tile_type_definition(): unknown attribute " + Chr(34) + XMLAttributeName(*node) + Chr(34) + " for tile_type tag in file " + Chr(34) + *tileset\definition_filename$ + Chr(34))
                  
              EndSelect
            Wend
          EndIf
          If id >= 0 And id < #MAX_NUMBER_OF_TILE_TYPES
            With *tileset\tile_type_db[id]
              \name$ = new_tile_type\name$
              \solid = new_tile_type\solid
              \transparent = new_tile_type\transparent
              \in_use = 1
              \message$ = new_tile_type\message$
              \remove_after_entering = new_tile_type\remove_after_entering
              \sound$ = new_tile_type\sound$
              \transforms_into = new_tile_type\transforms_into
              \class$ = new_tile_type\class$
              \container = new_tile_type\container
              \hidden = new_tile_type\hidden
              \detection_message$ = new_tile_type\detection_message$
              \detection_sound$ = new_tile_type\detection_sound$
              \animation_enter$ = new_tile_type\animation_enter$
            EndWith
          EndIf
          *childnode = ChildXMLNode(*node)
          While *childnode <> 0
            Select GetXMLNodeName(*childnode)
            
              Case "name":
                If ExamineXMLAttributes(*childnode)
                  While NextXMLAttribute(*childnode)
                    val2$ = XMLAttributeValue(*childnode)
                    Select XMLAttributeName(*childnode)
                      
                      Case "language":
                        If val2$ = preferences\language$
                          *tileset\tile_type_db[id]\name$ = GetXMLNodeText(*childnode)
                        EndIf
                        
                      Default:
                        error_message("load_tile_type_definition(): unknown attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in name tag in tileset xml file " + Chr(34) + *tileset\definition_filename$ + Chr(34))
                        
                    EndSelect
                  Wend
                EndIf
                
              Case "message":
                If ExamineXMLAttributes(*childnode)
                  While NextXMLAttribute(*childnode)
                    val2$ = XMLAttributeValue(*childnode)
                    Select XMLAttributeName(*childnode)
                      
                      Case "language":
                        If val2$ = preferences\language$
                          *tileset\tile_type_db[id]\message$ = GetXMLNodeText(*childnode)
                        EndIf
                        
                      Default:
                        error_message("load_tile_type_definition(): unknown attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in message tag in tileset xml file " + Chr(34) + *tileset\definition_filename$ + Chr(34))
                        
                    EndSelect
                  Wend
                EndIf

              Case "detection_message":
                If ExamineXMLAttributes(*childnode)
                  While NextXMLAttribute(*childnode)
                    val2$ = XMLAttributeValue(*childnode)
                    Select XMLAttributeName(*childnode)
                      
                      Case "language":
                        If val2$ = preferences\language$
                          *tileset\tile_type_db[id]\detection_message$ = GetXMLNodeText(*childnode)
                        EndIf
                        
                      Default:
                        error_message("load_tile_type_definition(): unknown attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in detection_message tag in tileset xml file " + Chr(34) + *tileset\definition_filename$ + Chr(34))
                        
                    EndSelect
                  Wend
                EndIf
                
              Case "modify_attribute":
                With new_modify_attribute
                  \attribute = 0
                  \attribute_name$ = ""
                  \amount = 0
                  \amount_randomized = 0
                  \amount_reduced_by_ability = 0
                  \amount_reduced_by_ability_name$ = ""
                  \replenish = 0
                  \trigger_hidden = 0
                  \turn_ends = 0
                EndWith
                If ExamineXMLAttributes(*childnode)
                  While NextXMLAttribute(*childnode)
                    val2$ = XMLAttributeValue(*childnode)
                    Select XMLAttributeName(*childnode)
                      
                      Case "attribute":
                        new_modify_attribute\attribute = Val(val2$)
                        
                      Case "attribute_name":
                        new_modify_attribute\attribute_name$ = val2$
                        
                      Case "amount":
                        new_modify_attribute\amount = Val(val2$)
                        
                      Case "amount_randomized":
                        If val2$ = "yes"
                          new_modify_attribute\amount_randomized = 1
                        EndIf
                        
                      Case "amount_reduced_by_ability":
                        new_modify_attribute\amount_reduced_by_ability = 0
                        
                      Case "amount_reduced_by_ability_name":
                        new_modify_attribute\amount_reduced_by_ability_name$ = val2$
                        
                      Case "replenish":
                        If val2$ = "yes"
                          new_modify_attribute\replenish = 1
                        EndIf
                        
                      Case "trigger_hidden":
                        If val2$ = "yes"
                          new_modify_attribute\trigger_hidden = 1
                        EndIf
                        
                      Case "turn_ends":
                        If val2$ = "yes"
                          new_modify_attribute\turn_ends = 1
                        EndIf
                        
                      Default:
                        error_message("load_tile_type_definition(): unknown attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in detection_message tag in tileset xml file " + Chr(34) + *tileset\definition_filename$ + Chr(34))
                        
                    EndSelect
                  Wend
                  If new_modify_attribute\attribute > 0  Or new_modify_attribute\attribute_name$ <> ""
                    If modify_attribute_idx >= #MAX_NUMBER_OF_ATTRIBUTES_MODIFIED_BY_TILE
                      error_message("load_tile_type_definition(): too much modify_attribute tags for one tile type in tileset xml file " + Chr(34) + *tileset\definition_filename$ + Chr(34))
                    EndIf
                    With *tileset\tile_type_db[id]\modify_attribute[modify_attribute_idx]
                      \attribute = new_modify_attribute\attribute
                      \attribute_name$ = new_modify_attribute\attribute_name$
                      \amount = new_modify_attribute\amount
                      \amount_randomized = new_modify_attribute\amount_randomized
                      \amount_reduced_by_ability = new_modify_attribute\amount_reduced_by_ability
                      \amount_reduced_by_ability_name$ = new_modify_attribute\amount_reduced_by_ability_name$
                      \replenish = new_modify_attribute\replenish
                      \trigger_hidden = new_modify_attribute\trigger_hidden
                      \turn_ends = new_modify_attribute\turn_ends
                    EndWith
                  EndIf
                EndIf
              
              Default:
                error_message("load_tile_type_definition(): unknown tag " + Chr(34) + GetXMLNodeName(*childnode) + Chr(34) + " in tileset xml file " + *tileset\definition_filename$ + Chr(34))
            
            EndSelect
            *childnode = NextXMLNode(*childnode)
          Wend
          
        Default:
          error_message("load_tile_type_definition(): unknown tag " + Chr(34) + GetXMLNodeName(*node) + Chr(34) + " in file " + *tileset\definition_filename$ + Chr(34))
          
      EndSelect
      *node = NextXMLNode(*node)
    Wend
  EndIf
  FreeXML(0)
  resolve_tile_type_definition_names(*tileset)
EndProcedure


; loads a new tileset
Procedure load_tileset(*tileset.tileset_struct, load_sprite.b=1, load_image.b=0)
  If FileSize("tilesets\" + GetFilePart(*tileset\image_filename$)) < 0
    error_message("load_tileset: cannot find tileset image file " + Chr(34) + "tiles\" + GetFilePart(*tileset\image_filename$) + Chr(34))
  EndIf
  If *tileset\image_loaded = 1
    If IsImage(*tileset\image)
      FreeImage(*tileset\image)
    EndIf
  EndIf
  If tileset\sprite_loaded = 1
    If IsSprite(*tileset\sprite)
      FreeSprite(*tileset\sprite)
    EndIf
  EndIf
  tileset\image_loaded = 0
  tileset\sprite_loaded = 0
  If load_image = 1
    *tileset\image = LoadImage(#PB_Any, "tilesets\" + GetFilePart(*tileset\image_filename$))
    *tileset\columns = Int(ImageWidth(*tileset\image) / 32)
    *tileset\rows = Int(ImageHeight(*tileset\image) / 32)
    *tileset\image_loaded = 1
  EndIf
  If load_sprite = 1
    *tileset\sprite = LoadSprite(#PB_Any, "tilesets\" + GetFilePart(*tileset\image_filename$))
    *tileset\columns = Int(SpriteWidth(*tileset\sprite) / 32)
    *tileset\rows = Int(SpriteHeight(*tileset\sprite) / 32)
    *tileset\sprite_loaded = 1
  EndIf
  load_tile_type_definition(*tileset)
EndProcedure


; returns tile type for current map on position x/y
Procedure.w read_map_tile_type(*map.map_struct, x.b, y.b)
  Protected tile_type.w
  tile_type = 0
  If x<0 Or x>=#MAP_DIMENSION_X Or y<0 Or y>=#MAP_DIMENSION_Y
    tile_type = *map\tile_outside_map
  Else
    tile_type = *map\mapfield[x+y*#MAP_DIMENSION_Y]\tile_type
  EndIf
  ProcedureReturn tile_type
EndProcedure


; search for random field with tile type; returns 1 if successfull, else 0
Procedure.b random_field(*map.map_struct, *coordinates.coordinates_struct, tile_type.w = -1, limit_x.w =#MAP_DIMENSION_X, limit_y.w = #MAP_DIMENSION_Y)
  Protected rc.b = 0, x.w = 0, y.w = 0, timeout.w = 0
  If tile_type = -1
    tile_type = *map\background_tile
  EndIf
  Repeat
    x = Random(limit_x - 1)
    y = Random(limit_y - 1)
    timeout = timeout + 1
  Until read_map_tile_type(*map, x, y) = tile_type Or timeout > 100
  If timeout <= 100
    rc = 1
    *coordinates\x = x
    *coordinates\y = y
  EndIf
  ProcedureReturn rc
EndProcedure


; sets tile type for current map on position x/y
Procedure set_map_tile_type(*map.map_struct, x.b, y.b, tile_type.w)
  If tile_type<0 Or tile_type>=#MAX_NUMBER_OF_TILE_TYPES
    error_message("set_map_tile_type: wrong tile_type: " + Str(tile_type))
  EndIf
  ;If *map\tileset\tile_type_db[tile_type]\in_use = 0
    ;error_message("set_map_tile_type: tile type not in tile type definition db: " + Str(tile_type))
  ;EndIf
  If x<0 Or x>#MAP_DIMENSION_X Or y<0 Or y>#MAP_DIMENSION_Y
    error_message("set_map_tile_type: wrong parameters: x="+Str(x)+"; y="+Str(y))
  EndIf
  *map\mapfield[x+y*#MAP_DIMENSION_Y]\tile_type = tile_type
EndProcedure


; sets portal for current map on position x/y
Procedure set_map_portal(*map.map_struct, x.b, y.b, map_filename$="", target_x.b=0, target_y.b=0)
  If x<0 Or x>#MAP_DIMENSION_X Or y<0 Or y>#MAP_DIMENSION_Y
    error_message("set_map_portal: wrong parameters: x="+Str(x)+"; y="+Str(y))
  EndIf
  If target_x<0 Or target_x>#MAP_DIMENSION_X Or target_y<0 Or target_y>#MAP_DIMENSION_Y
    error_message("set_map_portal: wrong parameters: target_x="+Str(x)+"; target_y="+Str(y))
  EndIf
  *map\mapfield[x+y*#MAP_DIMENSION_Y]\portal_mapfile = map_filename$
  *map\mapfield[x+y*#MAP_DIMENSION_Y]\portal_x = target_x
  *map\mapfield[x+y*#MAP_DIMENSION_Y]\portal_y = target_y
EndProcedure


; sets message for field when entering/pushing
Procedure set_map_message(*map.map_struct, x.b, y.b, message_line1$, message_line2$, message_tile.w=0)
  If x >= 0 And x < #MAP_DIMENSION_X And y >= 0 And  y< #MAP_DIMENSION_Y
    *map\mapfield[x + y * #MAP_DIMENSION_Y]\message_line1$ = message_line1$
    *map\mapfield[x + y * #MAP_DIMENSION_Y]\message_line2$ = message_line2$
    *map\mapfield[x + y * #MAP_DIMENSION_Y]\message_tile = message_tile
  EndIf
EndProcedure


; sets a map event trigger for field
Procedure set_map_event(*map.map_struct, x.b, y.b, event$, event_xp.b=0)
  If x >= 0 And x < #MAP_DIMENSION_X And y >= 0 And y < #MAP_DIMENSION_Y
    *map\mapfield[x + y * #MAP_DIMENSION_Y]\event$ = event$
    *map\mapfield[x + y * #MAP_DIMENSION_Y]\event_xp = event_xp
  EndIf
EndProcedure


; set power used for map position x/y
Procedure set_map_power_used(*map.map_struct, x.b, y.b, power_used$)
  If x >= 0 And x < #MAP_DIMENSION_X And y >= 0 And y < #MAP_DIMENSION_Y
    *map\mapfield[x + y * #MAP_DIMENSION_Y]\power_used$ = power_used$
  EndIf
EndProcedure


; add power used for map position x/y
Procedure add_map_power_used(*map.map_struct, x.b, y.b, power$)
  If x >= 0 And x < #MAP_DIMENSION_X And y >= 0 And y < #MAP_DIMENSION_Y
    If compare_string_lists(*map\mapfield[x + y * #MAP_DIMENSION_Y]\power_used$, power$) = 0
      If *map\mapfield[x + y * #MAP_DIMENSION_Y]\power_used$ <> ""
        *map\mapfield[x + y * #MAP_DIMENSION_Y]\power_used$ = *map\mapfield[x + y * #MAP_DIMENSION_Y]\power_used$ + "|"
      EndIf
      *map\mapfield[x + y * #MAP_DIMENSION_Y]\power_used$ = *map\mapfield[x + y * #MAP_DIMENSION_Y]\power_used$ + power$
    EndIf
  EndIf
EndProcedure


; sets visited flag for map position x/y
Procedure set_map_visited(*map.map_struct, x.b, y.w, visited.b = 1)
  If x >= 0 And x < #MAP_DIMENSION_X And y >= 0 And y < #MAP_DIMENSION_Y
    *map\mapfield[x + y * #MAP_DIMENSION_Y]\visited = visited
  EndIf
EndProcedure


; sets hidden flag for map position x/y
Procedure set_map_hidden(*map.map_struct, x.b, y.w, hidden.b = 1)
  If x >= 0 And x < #MAP_DIMENSION_X And y >= 0 And y < #MAP_DIMENSION_Y
    *map\mapfield[x + y * #MAP_DIMENSION_Y]\hidden = hidden
  EndIf
EndProcedure


; reads first line of message for field when entering/pushing
Procedure.s read_map_message_line1(*map.map_struct, x.b, y.b)
  If x<0 Or x>#MAP_DIMENSION_X Or y<0 Or y>#MAP_DIMENSION_Y
    error_message("read_map_message_line1: wrong parameters: x="+Str(x)+"; y="+Str(y))
  EndIf
  ProcedureReturn *map\mapfield[x+y*#MAP_DIMENSION_Y]\message_line1$
EndProcedure


; reads second line of message for field when entering/pushing
Procedure.s read_map_message_line2(*map.map_struct, x.b, y.b)
  If x<0 Or x>#MAP_DIMENSION_X Or y<0 Or y>#MAP_DIMENSION_Y
    error_message("read_map_message_line2: wrong parameters: x="+Str(x)+"; y="+Str(y))
  EndIf
  ProcedureReturn *map\mapfield[x+y*#MAP_DIMENSION_Y]\message_line2$
EndProcedure


; reads message tile for field displayed when entering/pushing
Procedure.w read_map_message_tile(*map.map_struct, x.b, y.b)
  If x<0 Or x>#MAP_DIMENSION_X Or y<0 Or y>#MAP_DIMENSION_Y
    error_message("read_map_message_tile: wrong parameters: x="+Str(x)+"; y="+Str(y))
  EndIf
  ProcedureReturn *map\mapfield[x+y*#MAP_DIMENSION_Y]\message_tile
EndProcedure


; returns name of map event for pos x/y
Procedure.s read_map_event(*map.map_struct, x.b, y.b)
  If x < 0 Or x >= #MAP_DIMENSION_X Or y < 0 Or y >= #MAP_DIMENSION_Y
    error_message("read_map_event(): wrong parameters: x="+Str(x)+"; y="+Str(y))
  EndIf
  ProcedureReturn *map\mapfield[x+y*#MAP_DIMENSION_Y]\event$
EndProcedure


; returns xp gain of map event for pos x/y
Procedure.b read_map_event_xp(*map.map_struct, x.b, y.b)
  If x < 0 Or x >= #MAP_DIMENSION_X Or y < 0 Or y >= #MAP_DIMENSION_Y
    error_message("read_map_event_xp(): wrong parameters: x="+Str(x)+"; y="+Str(y))
  EndIf
  ProcedureReturn *map\mapfield[x + (y * #MAP_DIMENSION_Y)]\event_xp
EndProcedure


; reads power used string on map field on position x/y
Procedure.s read_map_power_used(*map.map_struct, x.b, y.b)
  Protected rc$ = ""
  If x >= 0 And x < #MAP_DIMENSION_X And y >= 0 And y < #MAP_DIMENSION_Y
    rc$ = *map\mapfield[x + (y * #MAP_DIMENSION_Y)]\power_used$
  EndIf
  ProcedureReturn rc$
EndProcedure


; reads if power was used on map field on position x/y
Procedure.b read_map_if_power_used(*map.map_struct, x.b, y.b, power$)
  Protected rc.b = 0
  If x >= 0 And x < #MAP_DIMENSION_X And y >= 0 And y < #MAP_DIMENSION_Y
    rc = compare_string_lists(*map\mapfield[x + (y * #MAP_DIMENSION_Y)]\power_used$, power$)
  EndIf
  ProcedureReturn rc
EndProcedure


; returns visited flag for map position x/y
Procedure.b read_map_visited(*map.map_struct, x.b, y.b)
  Protected rc.b = 0
  If x < 0 Or x >= #MAP_DIMENSION_X Or y < 0 Or y >= #MAP_DIMENSION_Y
    rc = 0
  Else
    rc =  *map\mapfield[x + (y * #MAP_DIMENSION_Y)]\visited
  EndIf
  ProcedureReturn rc
EndProcedure


; returns hidden flag for map position x/y
Procedure.b read_map_hidden(*map.map_struct, x.b, y.b)
  Protected rc.b = 0
  If x < 0 Or x >= #MAP_DIMENSION_X Or y < 0 Or y >= #MAP_DIMENSION_Y
    rc = 0
  Else
    rc = *map\mapfield[x + (y * #MAP_DIMENSION_Y)]\hidden
  EndIf
  ProcedureReturn rc
EndProcedure


; returns 1 if event has already been triggered, else 0
Procedure.b event_triggered(event$)
  Protected rc.b = 0
  ForEach map_event()
    If map_event()\name$ = event$ And map_event()\triggered = 1
      rc = 1
    EndIf
  Next
  ProcedureReturn rc
EndProcedure


; returns experience gain for event
Procedure.b event_xp(event$)
  Protected rc.b = 0
  ForEach map_event()
    If map_event()\name$ = event$
      rc = map_event()\xp
    EndIf
  Next
  ProcedureReturn rc
EndProcedure


; returns 1 if transformation list contains a transformation for coordinates x/y, else 0
Procedure.b field_contains_transformation(x.b, y.b)
  Protected rc.b = 0
  If x<0 Or x>#MAP_DIMENSION_X Or y<0 Or y>#MAP_DIMENSION_Y
    error_message("field_contains_transformation: wrong parameters: x="+Str(x)+"; y="+Str(y))
  EndIf
  ForEach map_transformation()
    If map_transformation()\x = x And map_transformation()\y = y
      rc = 1
    EndIf
  Next
  ProcedureReturn rc
EndProcedure


; triggers message when entering/pushing field; returns 1 if message has been triggered
Procedure.b trigger_map_message(*map.map_struct, x.b, y.b)
  Protected rc.b, message_line1$, message_line2$
  rc.b = 0
  If x<0 Or x>#MAP_DIMENSION_X Or y<0 Or y>#MAP_DIMENSION_Y
  Else
    message_line1$ = read_map_message_line1(*map, x, y)
    message_line2$ = read_map_message_line2(*map, x, y)
    If message_line1$ <> "" Or message_line2$ <> ""
      message(message_line1$, message_line2$, RGB(255,255,255), read_map_message_tile(*map, x, y), 0)
      rc = 1
    EndIf
  EndIf
  ProcedureReturn rc
EndProcedure


; returns filename of map file portal leads to
Procedure.s read_map_portal_mapfilename(*map.map_struct, x.b, y.b)
  Protected map_filename$
  map_filename$ = ""
  If x<0 Or x>#MAP_DIMENSION_X Or y<0 Or y>#MAP_DIMENSION_Y
    error_message("read_map_portal_mapfilename: wrong parameters: x="+Str(x)+"; y="+Str(y))
  EndIf
  map_filename$ = *map\mapfield[x+y*#MAP_DIMENSION_Y]\portal_mapfile
  ProcedureReturn map_filename$
EndProcedure


; returns x target of portal
Procedure.b read_map_portal_target_x(*map.map_struct, x.b, y.b)
  Protected target_x.b
  target_x = 0
  If x<0 Or x>#MAP_DIMENSION_X Or y<0 Or y>#MAP_DIMENSION_Y
    error_message("read_map_portal_target_x: wrong parameters: x="+Str(x)+"; y="+Str(y))
  EndIf
  target_x = *map\mapfield[x+y*#MAP_DIMENSION_Y]\portal_x
  ProcedureReturn target_x
EndProcedure


; returns y target of portal
Procedure.b read_map_portal_target_y(*map.map_struct, x.b, y.b)
  Protected target_y.b
  target_y = 0
  If x<0 Or x>#MAP_DIMENSION_X Or y<0 Or y>#MAP_DIMENSION_Y
    error_message("read_map_portal_target_y: wrong parameters: x="+Str(x)+"; y="+Str(y))
  EndIf
  target_y = *map\mapfield[x+y*#MAP_DIMENSION_Y]\portal_y
  ProcedureReturn target_y
EndProcedure


; returns 1 if way is blocked, else 0
Procedure.b field_is_blocked(*map.map_struct, x.b, y.b)
  Protected rc.b = 0, tile_type.w
  tile_type = read_map_tile_type(*map, x, y)
  If *map\tileset\tile_type_db[tile_type]\solid = 1
    rc = 1
  EndIf
  ProcedureReturn rc
EndProcedure


; returns 1 if field is blocked for a monster, else 0
Procedure.b field_is_blocked_for_monster(*map.map_struct, x.b, y.b, monster_type)
  Protected rc.b = 0, tile_type.w
  tile_type = read_map_tile_type(*map, x, y)
  If *map\tileset\tile_type_db[tile_type]\solid = 1 And monster_type_db(monster_type)\flying = 0
    rc = 1
  EndIf
  If *map\tileset\tile_type_db[tile_type]\blocks_flight = 1 And monster_type_db(monster_type)\flying = 1
    rc = 1
  EndIf
  If rc = 0
    If field_contains_monster(x, y) = 1
      rc = 1
    EndIf
  EndIf
  ProcedureReturn rc
EndProcedure


; returns 1 if tile type blocks flight, else 0
Procedure.b field_blocks_flight(*map.map_struct, x.b, y.b)
  Protected rc.b = 0, tile_type.w = 0
  tile_type = read_map_tile_type(*map, x, y)
  If *map\tileset\tile_type_db[tile_type]\blocks_flight = 1
    rc = 1
  EndIf
  ProcedureReturn rc
EndProcedure


; returns 1 if field is an open portal, else 0
Procedure.b field_is_open_portal(*map.map_struct, x.b, y.b)
  Protected rc.b
  rc.b = 0
  If read_map_portal_mapfilename(*map, x, y) <> ""
    rc = 1
  EndIf
  ProcedureReturn rc
EndProcedure


; returns 1 if field contains a dungeon entrance, else 0
Procedure.b field_contains_dungeon_entrance(x.w, y.w)
  Protected rc.b
  ForEach dungeon_on_map()
    If dungeon_on_map()\xpos = x And dungeon_on_map()\ypos = y
      rc = 1
    EndIf
  Next
  ProcedureReturn rc
EndProcedure


; fills complete map with one tile type
Procedure fill_map(*map.map_struct, tile_type.w)
  Protected x.b,y.b
  For y=0 To #MAP_DIMENSION_Y-1
    For x=0 To #MAP_DIMENSION_X-1
      set_map_tile_type(*map, x, y, tile_type)
      set_map_portal(*map, x, y, "", 0, 0)
      set_map_message(*map, x, y, "", "")
    Next
  Next
EndProcedure


; returns most used tile in a map
Procedure.w most_used_tile(*map.map_struct)
  Protected Dim tile_count(#MAX_NUMBER_OF_TILE_TYPES)
  Protected x.b, y.b, i.w, tile_type.w, rc.w, max_tile_count.l
  For y=0 To #MAP_DIMENSION_Y-1
    For x=0 To #MAP_DIMENSION_X-1
      tile_type = read_map_tile_type(*map, x, y)
      tile_count(tile_type) = tile_count(tile_type) + 1
    Next
  Next
  rc = -1
  max_tile_count = 0
  For i=0 To #MAX_NUMBER_OF_TILE_TYPES-1
    If tile_count(i) > max_tile_count
      max_tile_count = tile_count(i)
      rc = i
    EndIf
  Next
  Dim tile_count(0) ; free array
  ProcedureReturn rc
EndProcedure


; adds a new event to the map event list; returns 1 if event has been successfully added, else 0
Procedure.b add_map_event(event$, triggered.b = 0, xp.b = 0)
  Protected event_found.b = 0, rc.b = 0
  ForEach map_event()
    If map_event()\name$ = event$
      event_found = 1
    EndIf
  Next
  If event_found = 0
    AddElement(map_event())
    map_event()\name$ = event$
    map_event()\triggered = triggered
    map_event()\xp = xp
    rc = 1
  EndIf
  ProcedureReturn rc
EndProcedure


; build map event list from map
Procedure build_map_event_list(*map.map_struct, include_transformation_events.b=1)
  Protected x.b, y.b, event_found.b, event$, event_xp.b
  ClearList(map_event())
  For y.b=0 To #MAP_DIMENSION_Y-1
    For x.b=0 To #MAP_DIMENSION_X-1
      event$ = read_map_event(*map, x, y)
      event_xp = read_map_event_xp(*map, x, y)
      If event$ <> ""
        add_map_event(event$, 0, event_xp)
      EndIf
    Next
  Next
  If include_transformation_events = 1
    ForEach map_transformation()
      If map_transformation()\new_field\event$ <> ""
        add_map_event(map_transformation()\new_field\event$, 0)
      EndIf
    Next
  EndIf
EndProcedure


; adds a new map transformation; returns 1 if transformation has successfully been added, else 0
Procedure.b add_map_transformation(*new_transformation.map_transformation_struct)
  Protected transformation_found.b = 0, rc.b=0
  ForEach map_transformation()
    If map_transformation()\x = *new_transformation\x And map_transformation()\y = *new_transformation\y And map_transformation()\event$ = *new_transformation\event$
      transformation_found = 1
    EndIf
  Next
  If transformation_found = 0
    AddElement(map_transformation())
    map_transformation()\x = *new_transformation\x
    map_transformation()\y = *new_transformation\y
    map_transformation()\triggered = *new_transformation\triggered
    map_transformation()\event$ = *new_transformation\event$
    map_transformation()\new_field\tile_type = *new_transformation\new_field\tile_type
    map_transformation()\new_field\portal_mapfile = *new_transformation\new_field\portal_mapfile
    map_transformation()\new_field\portal_x = *new_transformation\new_field\portal_x
    map_transformation()\new_field\portal_y = *new_transformation\new_field\portal_y
    map_transformation()\new_field\message_line1$ = *new_transformation\new_field\message_line1$
    map_transformation()\new_field\message_line2$ = *new_transformation\new_field\message_line2$
    map_transformation()\new_field\message_tile = *new_transformation\new_field\message_tile   
    map_transformation()\new_field\event$ = *new_transformation\new_field\event$
    rc = 1
  EndIf
  ProcedureReturn rc
EndProcedure


; triggers a transformation; returns 1 if transformation has successfully been triggered, else 0
Procedure.b trigger_map_transformation(*map.map_struct, event$)
  Protected x.b, y.b, tile_type.w, portal_mapfile$, portal_x.b, portal_y.b
  Protected message_line1$, message_line2$, message_tile.w, new_event$
  ForEach map_transformation()
    If map_transformation()\event$ = event$ And map_transformation()\triggered = 0
      x = map_transformation()\x
      y = map_transformation()\y
      tile_type = map_transformation()\new_field\tile_type
      portal_mapfile$ = map_transformation()\new_field\portal_mapfile
      portal_x = map_transformation()\new_field\portal_x
      portal_y = map_transformation()\new_field\portal_y
      message_line1$ = map_transformation()\new_field\message_line1$
      message_line2$ = map_transformation()\new_field\message_line2$
      message_tile = map_transformation()\new_field\message_tile
      new_event$ = map_transformation()\new_field\event$
      set_map_tile_type(*map, x, y, tile_type)
      set_map_portal(*map, x, y, portal_mapfile$, portal_x, portal_y)
      set_map_message(*map, x, y, message_line1$, message_line2$, message_tile)
      If new_event$ <> ""
        set_map_event(*map, x, y, new_event$)
        add_map_event(new_event$, 0)
      EndIf
    EndIf
  Next
EndProcedure


; triggers a map event; returns 1 if event has successfully been triggered, else 0
Procedure.b trigger_map_event(*map.map_struct, x.b, y.b)
  Protected event$ = "", rc.b = 0, xp.b
  If x<0 Or x>#MAP_DIMENSION_X Or y<0 Or y>#MAP_DIMENSION_Y
    error_message("trigger_map_event: wrong parameters: x="+Str(x)+"; y="+Str(y))
  EndIf
  event$ = read_map_event(*map, x, y)
  If event$ <> ""
    ForEach map_event()
      If map_event()\name$ = event$
        If map_event()\triggered <> 1
          map_event()\triggered = 1
          rc = 1
        EndIf
      EndIf
    Next
  EndIf
  If rc = 1
    xp = event_xp(event$)
    If xp > 0
      experience(xp)
    EndIf  
    trigger_map_transformation(*map, event$)
  EndIf
  ProcedureReturn rc
EndProcedure


; resets all map parameter
Procedure reset_map(*map.map_struct)
  Protected x.w, y.w
  *map\name = ""
  *map\filename$ = ""
  ClearList(map_event())
  ClearList(map_transformation())
  ClearList(monster())
  ClearList(item_on_map())
  ClearList(dungeon_on_map())
  reset_tileset(*map\tileset)
  For y=0 To #MAP_DIMENSION_Y-1
    For x=0 To #MAP_DIMENSION_X-1
      *map\mapfield[x+y*#MAP_DIMENSION_Y]\tile_type = 0
      set_map_portal(*map, x, y, "", 0, 0)
      set_map_message(*map, x, y, "", "", 0)
      set_map_event(*map, x, y, "")
      set_map_hidden(*map, x, y, 0)
      set_map_visited(*map, x, y, 0)
      *map\mapfield[x+y*#MAP_DIMENSION_Y]\event_xp = 0
    Next
  Next
  *map\tile_outside_map = 0
  *map\default_tile = 0
  *map\background_tile = 0
  *map\spawn_monster_level = 0
  *map\spawn_monster_chance = 0
  *map\visited = 0
EndProcedure


; loads map from file
Procedure load_map(*map.map_struct, map_filename$ = "maps\map_start.xml", load_tileset.b=1)
  Protected x.b, y.b, portal_mapfile$, portal_x.b, portal_y.b, event$, event_found.b, tile_type.w, event_triggered.b
  Protected new_event$, transformation_triggered.b, transformation.map_transformation_struct
  Protected message_tile.w, new_monster.monster_struct, event_xp.b, tried.b, lighting.b
  Protected new_item.item_on_map_struct, new_dungeon.dungeon_struct
  Protected visited.b, hidden.b, power_used$, *mainnode, *node, val$
  Protected message_line1$, message_line2$
  reset_map(*map)
  ClearList(map_event())
  ClearList(map_transformation())
  ClearList(monster())
  If CreateXML(0) = 0
    error_message("load_map(): could not create xml structure in memory!")
  EndIf
  If LoadXML(0, map_filename$) = 0
    error_message("load_map(): could not open map xml file: " + Chr(34) + map_filename$ + Chr(34))
  EndIf
  If XMLStatus(0) <> 0
    error_message("load_map(): error in xml structure of map file " + Chr(34) + map_filename$ + Chr(34) + ": " + XMLError(0))
  EndIf
  *mainnode = MainXMLNode(0)
  If ExamineXMLAttributes(*mainnode)
    While NextXMLAttribute(*mainnode)
      val$ = XMLAttributeValue(*mainnode)
      Select XMLAttributeName(*mainnode)
      
        Case "name": 
          *map\name = val$
          
        Case "Lost_Labyrinth_version":
          
        Case "filename":
          
        Case "tileset_definition_filename":
          *map\tileset\definition_filename$ = GetFilePart(val$)
          
        Case "tileset_image_filename":
          *map\tileset\image_filename$ = GetFilePart(val$)
          
        Case "default_tile":
          *map\default_tile = Val(val$)
          
        Case "background_tile"
          *map\background_tile = Val(val$)
          
        Case "tile_outside_map":
          *map\tile_outside_map = Val(val$)
          
        Case "spawn_monster_level":
          *map\spawn_monster_level = Val(val$)
          
        Case "spawn_monster_chance":
          *map\spawn_monster_chance = Val(val$)
          
        Case "visited":
          If val$ = "yes"
            *map\visited = 1
          EndIf
          
        Case "lighting":
          If Val(val$) < 0 Or Val(val$) > 8
            error_message("load_map(): wrong lighting attribute " + Chr(34) + val$ + Chr(34) + " in map file " + Chr(34) + map_filename$ + Chr(34))
          EndIf
          *map\lighting = Val(val$)
          
        Default:
          error_message("load_map(): unknown attribute " + Chr(34) + XMLAttributeName(*mainnode) + Chr(34) + " in main node in map file " + Chr(34) + map_filename$ + Chr(34))
          
      EndSelect
    Wend
  EndIf
  fill_map(*map, *map\default_tile)
  If *mainnode
    *node = ChildXMLNode(*mainnode)
    While *node <> 0
      
      Select GetXMLNodeName(*node)
        
        Case "field":
          x = -1
          y = -1
          portal_mapfile$ = ""
          portal_x = 0
          portal_y = 0
          message_line1$ = ""
          message_line2$ = ""
          event$ = ""
          event_triggered = 0
          message_tile = 0
          event_xp = 0
          tried = 0
          visited = 0
          hidden = 0
          power_used$ = ""
          If ExamineXMLAttributes(*node)
            While NextXMLAttribute(*node)
              val$ = XMLAttributeValue(*node)
              Select XMLAttributeName(*node)
              
                Case "x":
                  x = Val(val$)
                  
                Case "y":
                  y = Val(val$)
                  
                Case "portal_mapfile":
                  portal_mapfile$ = val$
                  
                Case "portal_x":
                  portal_x = Val(val$)
                  
                Case "portal_y":
                  portal_y = Val(val$)
                  
                Case "message_line1":
                  message_line1$ = val$
                  
                Case "message_line2":
                  message_line2$ = val$
                  
                Case "event":
                  event$ = val$
                  
                Case "event_triggered":
                  event_triggered = Val(val$)
                  
                Case "message_tile":
                  message_tile = Val(val$)
                  
                Case "event_xp":
                  event_xp = Val(val$)
                  
                Case "power_used":
                  power_used$ = val$
                  
                Case "visited":
                  If val$ = "yes"
                    visited = 1
                  EndIf
                  
                Case "hidden":
                  If val$ = "yes"
                    hidden = 1
                  EndIf
                  
                Default:
                  error_message("load_map(): unknown attribute " + Chr(34) + XMLAttributeName(*node) + Chr(34) + " in field tag in map file " + Chr(34) + map_filename$ + Chr(34))
                  
              EndSelect
            Wend
          EndIf
          If x<>-1 And y<>-1
            set_map_tile_type(*map, x, y, Val(GetXMLNodeText(*node)))
          EndIf
          If portal_mapfile$ <> ""
            set_map_portal(*map, x, y, portal_mapfile$, portal_x, portal_y)
          EndIf
          set_map_message(*map, x, y, message_line1$, message_line2$, message_tile)
          set_map_power_used(*map, x, y, power_used$)
          set_map_hidden(*map, x, y, hidden)
          set_map_visited(*map, x, y, visited)
          If event$ <> ""
            set_map_event(*map, x, y, event$, event_xp)
            add_map_event(event$, event_triggered, event_xp)
          EndIf
          
        Case "transformation":
          transformation\x = -1
          transformation\y = -1
          transformation\event$ = ""
          transformation\triggered = 0
          transformation\new_field\portal_mapfile = ""
          transformation\new_field\portal_x = 0
          transformation\new_field\portal_y = 0
          transformation\new_field\message_line1$ = ""
          transformation\new_field\message_line2$ = ""
          transformation\new_field\message_tile = 0
          transformation\new_field\event$ = ""
          transformation\new_field\tile_type = 0
          If ExamineXMLAttributes(*node)
            While NextXMLAttribute(*node)
              val$ = XMLAttributeValue(*node)
              Select XMLAttributeName(*node)

                Case "x":
                  transformation\x = Val(val$)
                  
                Case "y":
                  transformation\y = Val(val$)
                  
                Case "portal_mapfile":
                  transformation\new_field\portal_mapfile = val$
                  
                Case "portal_x":
                  transformation\new_field\portal_x = Val(val$)
                  
                Case "portal_y":
                  transformation\new_field\portal_y = Val(val$)
                  
                Case "message_line1":
                  transformation\new_field\message_line1$ = val$
                  
                Case "message_line2":
                  transformation\new_field\message_line2$ = val$
                  
                Case "message_tile":
                  transformation\new_field\message_tile = Val(val$)
                  
                Case "event":
                  transformation\event$ = val$
                  
                Case "new_event":
                  transformation\new_field\event$ = val$
                  
                Case "tile_type":
                  transformation\new_field\tile_type = Val(val$)
                  
                Case "triggered":
                  transformation\triggered = Val(val$)
                  
                Default:
                  error_message("load_map(): unknown attribute " + Chr(34) + XMLAttributeName(*node) + Chr(34) + " in transformation tag in map file " + Chr(34) + map_filename$ + Chr(34))
                
              EndSelect
            Wend
          EndIf
          add_map_transformation(@transformation)
          
        Case "monster":
          new_monster\type = 0
          new_monster\xpos = 0
          new_monster\ypos = 0
          new_monster\hitpoints = 0
          new_monster\alerted = 0
          new_monster\y_offset = 0
          If ExamineXMLAttributes(*node)
            While NextXMLAttribute(*node)
              val$ = XMLAttributeValue(*node)
              Select XMLAttributeName(*node)
                
                Case "type":
                  new_monster\type = Val(val$)
                  
                Case "xpos":
                  new_monster\xpos = Val(val$)
                  
                Case "ypos":
                  new_monster\ypos = Val(val$)
                  
                Case "hitpoints":
                  new_monster\hitpoints = Val(val$)
                  
                Case "alerted":
                  If val$ = "yes"
                    new_monster\alerted = 1
                  EndIf
                  
                Case "effect":
                  new_monster\effect$ = val$
                  
                Default:
                  error_message("load_map(): unknown attribute " + Chr(34) + XMLAttributeName(*node) + Chr(34) + " in monster tag in map file " + Chr(34) + map_filename$ + Chr(34))
              
              EndSelect
            Wend
            If new_monster\type > 0
              add_monster(*map, @new_monster)
            EndIf
          EndIf
          
        Case "item":
          new_item\xpos = 0
          new_item\ypos = 0
          new_item\type = 0
          If ExamineXMLAttributes(*node)
            While NextXMLAttribute(*node)
              val$ = XMLAttributeValue(*node)
              Select XMLAttributeName(*node)
                
                Case "xpos":
                  new_item\xpos = Val(val$)
                  
                Case "ypos":
                  new_item\ypos = Val(val$)
                  
                Case "type":
                  new_item\type = Val(val$)
                  
                Default:
                  error_message("load_map(): unknown attribute " + Chr(34) + XMLAttributeName(*node) + Chr(34) + " in item tag in map xml file " + Chr(34) + map_filename$ + Chr(34))
                  
              EndSelect
            Wend
            If new_item\type > 0
              AddElement(item_on_map())
              item_on_map()\xpos = new_item\xpos
              item_on_map()\ypos = new_item\ypos
              item_on_map()\type = new_item\type
            EndIf
          EndIf
          
        Case "dungeon":
          new_dungeon\xpos = -1
          new_dungeon\ypos = -1
          new_dungeon\name$ = ""
          new_dungeon\map_filename$ = ""
          new_dungeon\number_of_levels = 0
          new_dungeon\dimension_x = 0
          new_dungeon\dimension_y = 0
          new_dungeon\entrance_to_level = 1
          new_dungeon\difficulty_level = 1
          new_dungeon\lighting = 0
          new_dungeon\default_tile = 1
          new_dungeon\background_tile = 4
          new_dungeon\tile_outside_map = 1
          new_dungeon\bottom_portal$ = ""
          new_dungeon\bottom_portal_tile = 0
          new_dungeon\traps_per_level = 0
          If ExamineXMLAttributes(*node)
            While NextXMLAttribute(*node)
              val$ = XMLAttributeValue(*node)
              Select XMLAttributeName(*node)
              
                Case "xpos":
                  new_dungeon\xpos = Val(val$)
                  
                Case "ypos":
                  new_dungeon\ypos = Val(val$)
                  
                Case "name":
                  new_dungeon\name$ = val$
                  
                Case "map_filename":
                  new_dungeon\map_filename$ = val$
                  
                Case "number_of_levels":
                  new_dungeon\number_of_levels = Val(val$)
                  
                Case "dimension_x":
                  new_dungeon\dimension_x = Val(val$)
                  
                Case "dimension_y":
                  new_dungeon\dimension_y = Val(val$)
                  
                Case "entrance_to_level":
                  new_dungeon\entrance_to_level = Val(val$)
                  
                Case "difficulty_level":
                  new_dungeon\difficulty_level = Val(val$)
                  
                Case "lighting":
                  new_dungeon\lighting = Val(val$)
                  
                Case "default_tile":
                  new_dungeon\default_tile = Val(val$)
                  
                Case "background_tile":
                  new_dungeon\background_tile = Val(val$)
                  
                Case "tile_outside_map":
                  new_dungeon\tile_outside_map = Val(val$)
                  
                Case "main_treasure":
                  new_dungeon\main_treasure = Val(val$)
                  
                Case "bottom_portal":
                  new_dungeon\bottom_portal$ = val$
                  
                Case "bottom_portal_target_x":
                  new_dungeon\bottom_portal_target_x = Val(val$)
                  
                Case "bottom_portal_target_y":
                  new_dungeon\bottom_portal_target_y = Val(val$)
                  
                Case "bottom_portal_tile":
                  new_dungeon\bottom_portal_tile = Val(val$)
                  
                Case "traps_per_level":
                  new_dungeon\traps_per_level = Val(val$)
                  
                Default:
                  error_message("load_map(): unknown attribute " + Chr(34) + XMLAttributeName(*node) + Chr(34) + " in dungeon tag in map xml file " + Chr(34) + map_filename$ + Chr(34))
                  
              EndSelect
            Wend
            If new_dungeon\name$ <> ""
              AddElement(dungeon_on_map())
              With dungeon_on_map()
                \xpos = new_dungeon\xpos
                \ypos = new_dungeon\ypos
                \name$ = new_dungeon\name$
                \map_filename$ = new_dungeon\map_filename$
                \number_of_levels = new_dungeon\number_of_levels
                \dimension_x = new_dungeon\dimension_x
                \dimension_y = new_dungeon\dimension_y
                \entrance_to_level = new_dungeon\entrance_to_level
                \difficulty_level = new_dungeon\difficulty_level
                \lighting = new_dungeon\lighting
                \default_tile = new_dungeon\default_tile
                \background_tile = new_dungeon\background_tile
                \tile_outside_map = new_dungeon\tile_outside_map
                \main_treasure = new_dungeon\main_treasure
                \bottom_portal$ = new_dungeon\bottom_portal$
                \bottom_portal_target_x = new_dungeon\bottom_portal_target_x
                \bottom_portal_target_y = new_dungeon\bottom_portal_target_y
                \bottom_portal_tile = new_dungeon\bottom_portal_tile
                \traps_per_level = new_dungeon\traps_per_level
              EndWith
            EndIf
          EndIf

        Default:
          error_message("load_map(): unknown tag " + Chr(34) + GetXMLNodeName(*node) + Chr(34) + " in map file " + Chr(34) + map_filename$ + Chr(34))
        
      EndSelect
      *node = NextXMLNode(*node)
    Wend
  EndIf
  FreeXML(0)
  If load_tileset = 1
    If *map\tileset\definition_filename$ = ""
      error_message("load_map: could not find a tileset definition in map file " + Chr(34) + GetFilePart(map_filename$) + Chr(34))
    EndIf
    If *map\tileset\image_filename$ = ""
      error_message("load_map: could not find a tileset image in map file " + Chr(34) + GetFilePart(map_filename$) + Chr(34))
    EndIf
    load_tileset(*map\tileset)
  EndIf
  *map\filename$ = GetFilePart(map_filename$)
EndProcedure


; saves map into xml file
Procedure save_map(*map.map_struct, map_filename$)
  Protected val.s, x.b, y.b, tile.w, portal_mapfile$, portal_x.b, portal_y.b
  Protected message_line1$, message_line2$, message_tile.w, event$, event_xp.b
  Protected *mainnode, power_used$, visited.b, hidden.b, *node
  *map\default_tile = most_used_tile(*map)
  If CreateXML(0) = 0
    error_message("save_map(): could not create xml structure in memory!")
  EndIf
  *mainnode = CreateXMLNode(RootXMLNode(0),"")
  SetXMLNodeName(*mainnode, "map")
  SetXMLAttribute(*mainnode, "Lost_Labyrinth_version", version_number$)
  SetXMLAttribute(*mainnode, "name", *map\name)
  SetXMLAttribute(*mainnode, "filename", GetFilePart(map_filename$))
  SetXMLAttribute(*mainnode, "tileset_definition_filename", *map\tileset\definition_filename$)
  SetXMLAttribute(*mainnode, "tileset_image_filename", *map\tileset\image_filename$)
  SetXMLAttribute(*mainnode, "tile_outside_map", Str(*map\tile_outside_map))
  SetXMLAttribute(*mainnode, "default_tile", Str(*map\default_tile))
  SetXMLAttribute(*mainnode, "background_tile", Str(*map\background_tile))
  SetXMLAttribute(*mainnode, "spawn_monster_level", Str(*map\spawn_monster_level))
  SetXMLAttribute(*mainnode, "spawn_monster_chance", Str(*map\spawn_monster_chance))
  SetXMLAttribute(*mainnode, "lighting", Str(*map\lighting))
  If *map\visited
    SetXMLAttribute(*mainnode, "visited", "yes")
  EndIf
  For y=0 To #MAP_DIMENSION_Y-1
    For x=0 To #MAP_DIMENSION_X-1
      tile = read_map_tile_type(*map, x, y)
      portal_mapfile$ = read_map_portal_mapfilename(*map, x, y)
      portal_x = read_map_portal_target_x(*map, x, y)
      portal_y = read_map_portal_target_y(*map, x, y)
      message_line1$ = read_map_message_line1(*map, x, y)
      message_line2$ = read_map_message_line2(*map, x, y)
      message_tile = read_map_message_tile(*map, x, y)
      event$ = read_map_event(*map, x, y)
      power_used$ = read_map_power_used(*map, x, y)
      visited = read_map_visited(*map, x, y)
      hidden = read_map_hidden(*map, x, y)
      If tile <> *map\default_tile Or portal_mapfile$ <> "" Or event$ <> "" Or message_line1$ <> "" Or message_line2$ <> "" Or visited = 1 Or hidden = 1
        *node = CreateXMLNode(*mainnode, "")
        SetXMLNodeName(*node, "field")
        SetXMLAttribute(*node, "x", Str(x))
        SetXMLAttribute(*node, "y", Str(y))
        SetXMLNodeText(*node, Str(tile))
        If portal_mapfile$ <> ""
          SetXMLAttribute(*node, "portal_mapfile", portal_mapfile$)
          SetXMLAttribute(*node, "portal_x", Str(portal_x))
          SetXMLAttribute(*node, "portal_y", Str(portal_y))
        EndIf
        If message_line1$ <> "" Or message_line2$ <> ""
          SetXMLAttribute(*node, "message_line1", message_line1$)
          SetXMLAttribute(*node, "message_line2", message_line2$)
          SetXMLAttribute(*node, "message_tile", Str(message_tile))
        EndIf
        If power_used$ <> ""
          SetXMLAttribute(*node, "power_used", power_used$)
        EndIf
        If visited = 1
          SetXMLAttribute(*node, "visited", "yes")
        EndIf
        If hidden = 1
          SetXMLAttribute(*node, "hidden", "yes")
        EndIf
        If event$ <> ""
          SetXMLAttribute(*node, "event", event$)
          If event_triggered(event$)
            SetXMLAttribute(*node, "event_triggered", "1")
          EndIf
          event_xp = read_map_event_xp(*map, x, y)
          If event_xp> 0
            SetXMLAttribute(*node, "event_xp", Str(event_xp))
          EndIf
        EndIf
      EndIf
    Next
  Next
  ForEach map_transformation()
    *node = CreateXMLNode(*mainnode, "")
    SetXMLNodeName(*node, "transformation")
    SetXMLAttribute(*node, "event", map_transformation()\event$)
    SetXMLAttribute(*node, "x", Str(map_transformation()\x))
    SetXMLAttribute(*node, "y", Str(map_transformation()\y))
    SetXMLAttribute(*node, "tile_type", Str(map_transformation()\new_field\tile_type))
    SetXMLAttribute(*node, "portal_mapfile", map_transformation()\new_field\portal_mapfile)
    SetXMLAttribute(*node, "portal_x", Str(map_transformation()\new_field\portal_x))
    SetXMLAttribute(*node, "portal_y", Str(map_transformation()\new_field\portal_y))
    SetXMLAttribute(*node, "message_line1", map_transformation()\new_field\message_line1$)
    SetXMLAttribute(*node, "message_line2", map_transformation()\new_field\message_line2$)
    SetXMLAttribute(*node, "message_tile", Str(map_transformation()\new_field\message_tile))
    SetXMLAttribute(*node, "new_event", map_transformation()\new_field\event$)
    SetXMLAttribute(*node, "triggered", Str(map_transformation()\triggered))
  Next
  ForEach monster()
    *node = CreateXMLNode(*mainnode, "")
    SetXMLNodeName(*node, "monster")
    SetXMLAttribute(*node, "type", Str(monster()\type))
    SetXMLAttribute(*node, "xpos", Str(monster()\xpos))
    SetXMLAttribute(*node, "ypos", Str(monster()\ypos))
    SetXMLAttribute(*node, "hitpoints", Str(monster()\hitpoints))
    If monster()\alerted = 1
      SetXMLAttribute(*node, "alerted", "yes")
    EndIf
    If monster()\effect$ <> ""
      SetXMLAttribute(*node, "effect", monster()\effect$)
    EndIf
  Next
  ForEach item_on_map()
    *node = CreateXMLNode(*mainnode, "")
    SetXMLNodeName(*node, "item")
    SetXMLAttribute(*node, "xpos", Str(item_on_map()\xpos))
    SetXMLAttribute(*node, "ypos", Str(item_on_map()\ypos))
    SetXMLAttribute(*node, "type", Str(item_on_map()\type))
  Next
  ForEach dungeon_on_map()
    *node = CreateXMLNode(*mainnode, "")
    SetXMLNodeName(*node, "dungeon")
    SetXMLAttribute(*node, "xpos", Str(dungeon_on_map()\xpos))
    SetXMLAttribute(*node, "ypos", Str(dungeon_on_map()\ypos))
    SetXMLAttribute(*node, "name", dungeon_on_map()\name$)
    SetXMLAttribute(*node, "map_filename", dungeon_on_map()\map_filename$)
    SetXMLAttribute(*node, "number_of_levels", Str(dungeon_on_map()\number_of_levels))
    SetXMLAttribute(*node, "dimension_x", Str(dungeon_on_map()\dimension_x))
    SetXMLAttribute(*node, "dimension_y", Str(dungeon_on_map()\dimension_y))
    SetXMLAttribute(*node, "entrance_to_level", Str(dungeon_on_map()\entrance_to_level))
    SetXMLAttribute(*node, "difficulty_level", Str(dungeon_on_map()\difficulty_level))
    SetXMLAttribute(*node, "lighting", Str(dungeon_on_map()\lighting))
    SetXMLAttribute(*node, "default_tile", Str(dungeon_on_map()\default_tile))
    SetXMLAttribute(*node, "background_tile", Str(dungeon_on_map()\background_tile))
    SetXMLAttribute(*node, "tile_outside_map", Str(dungeon_on_map()\tile_outside_map))
    SetXMLAttribute(*node, "main_treasure", Str(dungeon_on_map()\main_treasure))
    SetXMLAttribute(*node, "bottom_portal", dungeon_on_map()\bottom_portal$)
    SetXMLAttribute(*node, "bottom_portal_target_x", Str(dungeon_on_map()\bottom_portal_target_x))
    SetXMLAttribute(*node, "bottom_portal_target_y", Str(dungeon_on_map()\bottom_portal_target_y))
    SetXMLAttribute(*node, "bottom_portal_tile", Str(dungeon_on_map()\bottom_portal_tile))
    SetXMLAttribute(*node, "traps_per_level", Str(dungeon_on_map()\traps_per_level))
  Next
  If SaveXML(0, map_filename$) = 0
    error_message("Could not save map data to file " + Chr(34) + map_filename$ + Chr(34))
  EndIf
  FreeXML(0)
EndProcedure


; digs a tunnel in the current dungeon level
Procedure dig_tunnel(*map.map_struct, *dungeon.dungeon_struct, *tunnel.dungeon_tunnel_struct)
  Protected tile_type.w, stop_digging.b = 0, count.b = 0, direction.b, x.w, y.w
  Protected tunnel_found.b = 0
  x = *tunnel\start_xpos
  y = *tunnel\start_ypos
  tile_type = read_map_tile_type(*map, x, y)
  If tile_type = *map\background_tile
    stop_digging = 1
  Else
    set_map_tile_type(*map, x, y, *map\background_tile)  
  EndIf
  While stop_digging = 0
    direction = Random(3)
    count = 0
    tunnel_found = 0
    While stop_digging = 0 And tunnel_found = 0
      Select direction
      
        Case 0: ; tunnel up
          If y > 1
            If read_map_tile_type(*map, x, y - 2) = *map\default_tile
              set_map_tile_type(*map, x, y - 1, *map\background_tile)
              set_map_tile_type(*map, x, y - 2, *map\background_tile)
              tunnel_found = 1
              y = y - 2
              *tunnel\length = *tunnel\length + 2
            EndIf
          EndIf
          
        Case 1: ; tunnel right
          If x < *dungeon\dimension_x - 2
            If read_map_tile_type(*map, x + 2, y) = *map\default_tile
              set_map_tile_type(*map, x + 1, y, *map\background_tile)
              set_map_tile_type(*map, x + 2, y, *map\background_tile)
              tunnel_found = 1
              x = x + 2
              *tunnel\length = *tunnel\length + 2
            EndIf
          EndIf
        
        Case 2: ; tunnel down
          If y < *dungeon\dimension_y - 2
            If read_map_tile_type(*map, x, y + 2) = *map\default_tile
              set_map_tile_type(*map, x, y + 1, *map\background_tile)
              set_map_tile_type(*map, x, y + 2, *map\background_tile)
              tunnel_found = 1
              y = y + 2
              *tunnel\length = *tunnel\length + 2
            EndIf
          EndIf
        
        Case 3: ; tunnel left
          If x > 1
            If read_map_tile_type(*map, x - 2, y) = *map\default_tile
              set_map_tile_type(*map, x - 1, y, *map\background_tile)
              set_map_tile_type(*map, x - 2, y, *map\background_tile)
              tunnel_found = 1
              x = x - 2
              *tunnel\length = *tunnel\length + 2
            EndIf
          EndIf
        
      EndSelect
      If tunnel_found = 0
        direction = direction + 1
        If direction > 3
          direction = 0
        EndIf
        count = count + 1
        If count > 3
          stop_digging = 1
        EndIf
      EndIf
    Wend
  Wend
  *tunnel\end_xpos = x
  *tunnel\end_ypos = y
EndProcedure


; creates a new dungeon level
Procedure create_dungeon_level(*map.map_struct, *dungeon.dungeon_struct)
  Protected stop_digging.b = 0, x.w = 0, y.w = 0, i.w = 0, j.w = 0, tunnel.dungeon_tunnel_struct
  Protected direction.b = 0, count.b = 0, tunnel_connected.b = 0, tile_type.w = 0
  Protected coordinates.coordinates_struct, NewList traps.w(), new_map_filename$
  Protected item_rarity.w
  new_map_filename$ = *dungeon\map_filename$ + "_" + Str(*dungeon\entrance_to_level) + ".xml"
  reset_map(@current_map)
  fill_map(@current_map, *dungeon\default_tile)
  *map\name = *dungeon\name$ + " " + message_list$(#MESSAGE_LEVEL) + " " + Str(*dungeon\entrance_to_level)
  *map\filename$ = new_map_filename$
  *map\tileset\definition_filename$ = "tiles_standard.xml"
  *map\tileset\image_filename$ = "tiles_standard.png"
  *map\default_tile = *dungeon\default_tile
  *map\background_tile = *dungeon\background_tile
  *map\tile_outside_map = *dungeon\tile_outside_map
  *map\lighting = *dungeon\lighting
  load_tileset(*map\tileset)
  tunnel\start_xpos = 1
  tunnel\start_ypos = 1
  tunnel\length = 0
  dig_tunnel(*map, *dungeon, @tunnel) ; main tunnel
  set_map_portal(*map, tunnel\start_xpos, tunnel\start_ypos, current_character\map_filename$, current_character\xpos, current_character\ypos)
  set_map_tile_type(*map, tunnel\start_xpos, tunnel\start_ypos, 3)
  If *dungeon\entrance_to_level < *dungeon\number_of_levels
    set_map_tile_type(*map, tunnel\end_xpos, tunnel\end_ypos, 2)
    AddElement(dungeon_on_map())
    With dungeon_on_map()
      \xpos = tunnel\end_xpos
      \ypos = tunnel\end_ypos
      \name$ = *dungeon\name$
      \map_filename$ = *dungeon\map_filename$
      \number_of_levels = *dungeon\number_of_levels
      \dimension_x = *dungeon\dimension_x
      \dimension_y = *dungeon\dimension_y
      \entrance_to_level = *dungeon\entrance_to_level + 1
      \difficulty_level = *dungeon\difficulty_level
      \lighting = *dungeon\lighting
      \default_tile = *dungeon\default_tile
      \background_tile = *dungeon\background_tile
      \tile_outside_map = *dungeon\tile_outside_map
      \main_treasure = *dungeon\main_treasure
      \bottom_portal$ = *dungeon\bottom_portal$
      \bottom_portal_target_x = *dungeon\bottom_portal_target_x
      \bottom_portal_target_y = *dungeon\bottom_portal_target_y
      \bottom_portal_tile = *dungeon\bottom_portal_tile
      \traps_per_level = *dungeon\traps_per_level
    EndWith
  Else ; final level of dungeon reached
    AddElement(item_on_map())
    item_on_map()\xpos = tunnel\end_xpos
    item_on_map()\ypos = tunnel\end_ypos
    If *dungeon\main_treasure > 0
      item_on_map()\type = *dungeon\main_treasure
    Else
      item_on_map()\type = random_item_type(*dungeon\difficulty_level * 1000, "", 1)
    EndIf
    item_on_map()\amount = 1
    item_on_map()\fuel = item_db(item_on_map()\type)\fuel
    If item_db(item_on_map()\type)\artefact = 1
      item_on_map()\magic_bonus = magic_bonus()
    EndIf
  EndIf
  For y = 1 To *dungeon\dimension_y Step 2
    For x = 1 To *dungeon\dimension_x Step 2
      If read_map_tile_type(*map, x, y) = *map\default_tile

        direction = Random(3)
        count = 0
        tunnel_connected = 0
        While count < 4 And tunnel_connected = 0
          Select direction
            
            Case 0: ; connect upwards
              If y > 1
                If read_map_tile_type(*map, x, y - 2) = *map\background_tile
                  set_map_tile_type(*map, x, y - 1, *map\background_tile)
                  tunnel_connected = 1
                EndIf
              EndIf
 
             Case 1: ; connect to the right
              If x < *dungeon\dimension_x - 2
                If read_map_tile_type(*map, x + 2, y) = *map\background_tile
                  set_map_tile_type(*map, x + 1, y, *map\background_tile)
                  tunnel_connected = 1
                EndIf
              EndIf
              
             Case 2: ; connect downwards
              If y < *dungeon\dimension_y - 2
                If read_map_tile_type(*map, x, y + 2) = *map\background_tile
                  set_map_tile_type(*map, x, y + 1, *map\background_tile)
                  tunnel_connected = 1
                EndIf
              EndIf
              
             Case 3: ; connect to the left
              If x > 1
                If read_map_tile_type(*map, x - 2, y) = *map\background_tile
                  set_map_tile_type(*map, x - 1, y, *map\background_tile)
                  tunnel_connected = 1
                EndIf
              EndIf               
            
          EndSelect
          If tunnel_connected = 0
            direction = direction + 1
            If direction > 3
              direction = 0
            EndIf
          count = count + 1
          Else
            tunnel\start_xpos = x
            tunnel\start_ypos = y
            tunnel\length = 0
            dig_tunnel(*map, *dungeon, @tunnel)
            item_rarity = *dungeon\entrance_to_level + (*dungeon\difficulty_level * 10)
            Select Random(3)
              
              Case 0: ; gold
                set_map_tile_type(*map, tunnel\end_xpos, tunnel\end_ypos, 9)
                
              Case 1: ; random item
                add_random_item(tunnel\end_xpos, tunnel\end_ypos, item_rarity)
                
              Case 2: ; treasure chest
                set_map_tile_type(*map, tunnel\end_xpos, tunnel\end_ypos, 6)
                add_random_item(tunnel\end_xpos, tunnel\end_ypos, item_rarity)
                add_random_item(tunnel\end_xpos, tunnel\end_ypos, item_rarity)
                add_random_item(tunnel\end_xpos, tunnel\end_ypos, item_rarity)
                
              Default:
                
            EndSelect
          EndIf
        Wend
      EndIf
    Next
  Next
  ; place traps
  If *dungeon\traps_per_level > 0
    ClearList(traps())
    For i=0 To #MAX_NUMBER_OF_TILE_TYPES - 1
      If compare_string_lists(*map\tileset\tile_type_db[i]\class$, "trap") = 1
        AddElement(traps())
        traps() = i
      EndIf
    Next
    If ListSize(traps()) > 0
      For i = 1 To *dungeon\traps_per_level
        SelectElement(traps(), Random(ListSize(traps()) - 1))
        If random_field(*map, @coordinates, -1, *dungeon\dimension_x, *dungeon\dimension_y) = 1
          set_map_tile_type(*map.map_struct, coordinates\x, coordinates\y, traps())
          set_map_hidden(*map, coordinates\x, coordinates\y, 1)
        EndIf
      Next
    EndIf
  EndIf
  ; place monsters & hidden fields 
  For i=0 To (*dungeon\dimension_x * *dungeon\dimension_y) / (5 * 5)
    place_random_monster(*map, *dungeon\entrance_to_level + *dungeon\difficulty_level - 1)
    If random_field(*map, @coordinates, -1, *dungeon\dimension_x, *dungeon\dimension_y) = 1
      set_map_tile_type(*map.map_struct, coordinates\x, coordinates\y, #TILE_STANDARD_GOLD)
      set_map_hidden(*map, coordinates\x, coordinates\y, 1)
    EndIf
  Next
  If random_field(*map, @coordinates, -1, *dungeon\dimension_x, *dungeon\dimension_y) = 1
    set_map_tile_type(*map, coordinates\x, coordinates\y, #TILE_STANDARD_SANCTUM)
  EndIf
  If random_field(*map, @coordinates, -1, *dungeon\dimension_x, *dungeon\dimension_y) = 1
    set_map_tile_type(*map, coordinates\x, coordinates\y, #TILE_STANDARD_NEXUS)
  EndIf  
  If *dungeon\entrance_to_level >= *dungeon\number_of_levels
    If *dungeon\bottom_portal$ <> ""
      If random_field(*map, @coordinates, *dungeon\default_tile, *dungeon\dimension_x, *dungeon\dimension_y) = 1
        set_map_tile_type(*map, coordinates\x, coordinates\y, *dungeon\bottom_portal_tile)
        set_map_portal(*map, coordinates\x, coordinates\y, *dungeon\bottom_portal$, *dungeon\bottom_portal_target_x, *dungeon\bottom_portal_target_y)
      EndIf
    EndIf
  EndIf
  save_map(*map, "savegame\" + new_map_filename$)
  ClearList(traps())
EndProcedure


; character enters a portal
Procedure enter_portal()
  Protected target_x.b, target_y.b, new_map_filename$
  fade_map_screen_out(@current_map)
  save_map(@current_map, "savegame\" + GetFilePart(current_map\filename$))
  new_map_filename$ = read_map_portal_mapfilename(@current_map, current_character\xpos, current_character\ypos)
  target_x = read_map_portal_target_x(@current_map, current_character\xpos, current_character\ypos)
  target_y = read_map_portal_target_y(@current_map, current_character\xpos, current_character\ypos)
  If FileSize("savegame\" + GetFilePart(new_map_filename$)) > 0
    load_map(@current_map, "savegame\" + GetFilePart(new_map_filename$))
  Else
    load_map(@current_map, "maps\" + GetFilePart(new_map_filename$))
  EndIf
  current_character\xpos = target_x
  current_character\ypos = target_y
  current_character\map_filename$ = GetFilePart(new_map_filename$)
  If current_map\visited <> 1
    current_map\visited = 1
  EndIf
  fade_map_screen_in(@current_map)
EndProcedure


; character enters a field; returns 1 if current turn ends, else 0
Procedure.b enter_field()
  Protected rc.b = 0, xpos.w, ypos.w, tile_type.w, message_line1$ = "", message_line2$ = "", ability.w=0
  Protected remove_after_entering.b = 0, amount_randomized.b = 0, replenish.b = 0
  Protected negative_amount.b=0, sound$, text$ = "", item_tile.w = 0, item_number.w = 0
  Protected *dungeon.dungeon_struct = 0, new_dungeon.dungeon_struct, animation_enter$
  Protected trigger_hidden.b = 0, effect_triggered.b = 0, i.w = 0, amount.w = 0
  Protected amount_reduced_by_ability.w = 0, turn_ends.b = 0
  xpos = current_character\xpos
  ypos = current_character\ypos
  tile_type = read_map_tile_type(@current_map, xpos, ypos)
  message_line1$ = current_map\tileset\tile_type_db[tile_type]\message$
  animation_enter$ = current_map\tileset\tile_type_db[tile_type]\animation_enter$
  sound$ = current_map\tileset\tile_type_db[tile_type]\sound$
  remove_after_entering = current_map\tileset\tile_type_db[tile_type]\remove_after_entering
  effect_triggered = 0  
  For i = 0 To #MAX_NUMBER_OF_ATTRIBUTES_MODIFIED_BY_TILE - 1
    ability = current_map\tileset\tile_type_db[tile_type]\modify_attribute[i]\attribute
    amount = current_map\tileset\tile_type_db[tile_type]\modify_attribute[i]\amount
    amount_randomized = current_map\tileset\tile_type_db[tile_type]\modify_attribute[i]\amount_randomized
    replenish = current_map\tileset\tile_type_db[tile_type]\modify_attribute[i]\replenish
    amount_reduced_by_ability = current_map\tileset\tile_type_db[tile_type]\modify_attribute[i]\amount_reduced_by_ability
    trigger_hidden = current_map\tileset\tile_type_db[tile_type]\modify_attribute[i]\trigger_hidden
    turn_ends = current_map\tileset\tile_type_db[tile_type]\modify_attribute[i]\turn_ends
    If read_map_hidden(@current_map, xpos, ypos) = 0 Or trigger_hidden = 1
      If turn_ends = 1
        rc = 1
      EndIf
      If amount < 0
        negative_amount = 1
      EndIf
      If ability > 0 And amount <> 0
        effect_triggered = 1
        If amount_randomized = 1 And amount <> 0
          amount = Random(Abs(amount)-1) + 1
        EndIf
        If negative_amount = 1
          amount = amount * (-1)
        EndIf
        If amount_reduced_by_ability > 0
          If negative_amount
            amount = min(0, amount + current_character\ability[amount_reduced_by_ability]\attribute_current_value)
          Else
            amount = max(0, amount - current_character\ability[amount_reduced_by_ability]\attribute_current_value)
          EndIf
        EndIf
        amount = modify_attribute(ability, amount)
        message_line2$ = ability_db(ability)\name_display$
        If negative_amount
          message_line2$ = message_line2$ + " - " + Str(Abs(amount))
        Else
          message_line2$ = message_line2$ + " + " + Str(amount)
        EndIf
      EndIf
      If ability > 0 And replenish = 1
        If restore_attribute(ability) = 1
          effect_triggered = 1
        EndIf
      EndIf
    EndIf
  Next
  If sound$<>"" And effect_triggered = 1
    play_sound(sound$)
  EndIf  
  If animation_enter$ <> "" And effect_triggered = 1
    animation(animation_enter$, 6, 6, amount)
  EndIf
  If message_line1$ <> "" And effect_triggered = 1
    message(current_map\tileset\tile_type_db[tile_type]\message$, message_line2$, $ffffff, tile_type, 0)
  EndIf
  If remove_after_entering = 1 And effect_triggered = 1
    set_map_tile_type(@current_map, xpos, ypos, current_map\background_tile)
  EndIf
  message_line2$ = ""
  item_tile = 0
  item_number = 0
  ForEach item_on_map()
    If item_on_map()\xpos = xpos And item_on_map()\ypos = ypos
      item_number = item_number + 1
      If message_line2$ <> ""
        message_line2$ = message_line2$ + ", "
      EndIf
      message_line2$ = message_line2$ + item_db(item_on_map()\type)\name$
      item_tile = item_db(item_on_map()\type)\tile
    EndIf
  Next
  If item_number > 0
    If item_number = 1
      message_line1$ = message_list$(#MESSAGE_AN_ITEM_LIES_ON_THE_GROUND) + ":" 
    Else
      message_line1$ = message_list$(#MESSAGE_SOME_ITEMS_LIE_ON_THE_GROUND) + ":"
    EndIf
    message(message_line1$, message_line2$, $ffffff, item_tile, 1)
  EndIf
  ProcedureReturn rc
EndProcedure


Procedure enter_dungeon()
  Protected *dungeon.dungeon_struct, new_dungeon.dungeon_struct, tile_type.w, text$ = ""
  Protected new_map_filename$
  *dungeon = 0
  tile_type = read_map_tile_type(current_map, current_character\xpos, current_character\ypos)
  ForEach dungeon_on_map()
    If dungeon_on_map()\xpos = current_character\xpos And dungeon_on_map()\ypos = current_character\ypos
      *dungeon = dungeon_on_map()
    EndIf
  Next
  If *dungeon > 0
    ChangeCurrentElement(dungeon_on_map(), *dungeon)
    text$ = ReplaceString(message_list$(#MESSAGE_ENTER_DUNGEON), "[dungeon_name]", dungeon_on_map()\name$)
    text$ = ReplaceString(text$, "[dungeon_level]", Str(dungeon_on_map()\entrance_to_level))
    message(text$, "", $ffffff, tile_type, 0)
    fade_map_screen_out(@current_map)
    save_map(@current_map, "savegame\" + GetFilePart(current_map\filename$))
    new_map_filename$ = dungeon_on_map()\map_filename$ + "_" + Str(dungeon_on_map()\entrance_to_level) + ".xml"
    If FileSize("savegame\" + GetFilePart(new_map_filename$)) > 0
      load_map(@current_map, "savegame\" + GetFilePart(new_map_filename$))
    Else
      If dungeon_on_map()\entrance_to_level > 1
        experience()
      EndIf
      With new_dungeon
        \name$ = dungeon_on_map()\name$
        \xpos = dungeon_on_map()\xpos
        \ypos = dungeon_on_map()\ypos
        \map_filename$ = dungeon_on_map()\map_filename$
        \number_of_levels = dungeon_on_map()\number_of_levels
        \dimension_x = dungeon_on_map()\dimension_x
        \dimension_y = dungeon_on_map()\dimension_y
        \entrance_to_level = dungeon_on_map()\entrance_to_level
        \difficulty_level = dungeon_on_map()\difficulty_level
        \lighting = dungeon_on_map()\lighting
        \default_tile = dungeon_on_map()\default_tile
        \background_tile = dungeon_on_map()\background_tile
        \tile_outside_map = dungeon_on_map()\tile_outside_map
        \main_treasure = dungeon_on_map()\main_treasure
        \bottom_portal$ = dungeon_on_map()\bottom_portal$
        \bottom_portal_target_x = dungeon_on_map()\bottom_portal_target_x
        \bottom_portal_target_y = dungeon_on_map()\bottom_portal_target_y
        \bottom_portal_tile = dungeon_on_map()\bottom_portal_tile
        \traps_per_level = dungeon_on_map()\traps_per_level
      EndWith
      create_dungeon_level(@current_map, @new_dungeon)
    EndIf
    current_character\xpos = 1
    current_character\ypos = 1
    current_character\map_filename$ = new_map_filename$
    fade_map_screen_in(@current_map)    
  EndIf
EndProcedure


; returns current light radius
Procedure.b current_light_radius()
  Protected rc.b = 0, i.w = 0, blind.b = 0
  rc = current_map\lighting
  For i =1 To #MAX_NUMBER_OF_ABILITIES - 1
    If ability_db(i)\lightradius > 0
      rc = rc + attribute_current_val(i)
      If current_character\ability[i]\adjustment_percentage = 0
        blind = 1
      EndIf
    EndIf
  Next
  If blind = 1
    rc = 0
  EndIf
  rc = max(0, min(8, rc))
  ProcedureReturn rc
EndProcedure


; character tries to detect hidden fields around her/him; returns 1 if something was found, else 0
Procedure.b detect_hidden_fields()
  Protected rc.b = 0, x.b, y.b, tile_type.w
  For x = current_character\xpos -1 To current_character\xpos + 1
    For y = current_character\ypos -1 To current_character\ypos + 1
      If read_map_visited(@current_map, x, y) = 0
        set_map_visited(@current_map, x, y)
        tile_type = read_map_tile_type(@current_map, x, y)
        If read_map_hidden(@current_map, x, y) = 1
          If Random(99) < perception_val(current_map\tileset\tile_type_db[tile_type]\class$)
            set_map_hidden(@current_map, x, y, 0)
            rc = 1
            If current_map\tileset\tile_type_db[tile_type]\detection_message$ <> ""
              message(current_map\tileset\tile_type_db[tile_type]\detection_message$, "", $ffffff, tile_type, 0)
            EndIf
            If current_map\tileset\tile_type_db[tile_type]\detection_sound$ <> ""
              play_sound(current_map\tileset\tile_type_db[tile_type]\detection_sound$)
            EndIf
          EndIf
        EndIf
      EndIf
    Next
  Next
  ProcedureReturn rc
EndProcedure


; returns 1 if line of sight exists between two coordinates, else 0
Procedure.b los(x1.b, y1.b, x2.b, y2.b)
  Protected rc.b = 0
  ProcedureReturn rc
EndProcedure
; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 17
; FirstLine = 13
; Folding = ----------
; CompileSourceDirectory
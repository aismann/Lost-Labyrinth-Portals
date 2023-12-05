; Lost Labyrinth VI: Portals
; monster
; written in PureBasic 4.20 (http://www.purebasic.com)
; created:  29.10.2008 Frank Malota <malota@web.de>
; modified: 27.12.2008 Frank Malota <malota@web.de>


; declarations
Declare play_sound(sound_filename$)


; reset single monster type
Procedure reset_monster_type(*monster.monster_type_db_struct)
  Protected i.w = 0
  With *monster
    \name$ = ""
    \class$ = ""
    \tile = 0
    \attack = 0
    \defense = 0
    \strength = 0
    \hitpoints = 0
    \armor = 0
    \level = 0
    \speed = 0
    \flying = 0
    \regeneration = 0
    \resistance_class$ = ""
    \immune_class$ = ""
    \vulnerable_class$ = ""
  EndWith
  For i = 0 To #MAX_NUMBER_OF_MONSTER_AFFLICTIONS - 1
    With *monster\affliction[i]
      \class$ = ""
      \chance = 0
      \attribute = 0
      \attribute_name$ = ""
      \value = 0
      \randomized = 0
      \animation$ = ""
      \sound$ = ""
      \message$ = ""
    EndWith
  Next
EndProcedure


; reset monster db
Procedure reset_monster_db()
  Protected i.w, j.w
  For i=0 To #MAX_NUMBER_OF_MONSTER_TYPES - 1
    reset_monster_type(@monster_type_db(i))
  Next
EndProcedure


; resolves name references in monster type db
Procedure resolve_monster_type_db_names(filename$)
  Protected i.w = 0, j.w = 0, k.w = 0
  For i=0 To #MAX_NUMBER_OF_MONSTER_TYPES - 1
    For j = 0 To #MAX_NUMBER_OF_MONSTER_AFFLICTIONS - 1
      If monster_type_db(i)\affliction[j]\attribute = 0 And monster_type_db(i)\affliction[j]\attribute_name$ <> ""
        For k=0 To #MAX_NUMBER_OF_ABILITIES - 1
          If ability_db(k)\name$ = monster_type_db(i)\affliction[j]\attribute_name$
            monster_type_db(i)\affliction[j]\attribute = k
          EndIf
        Next
        If monster_type_db(i)\affliction[j]\attribute = 0
          error_message("resolve_monster_type_db_names(): cannot find attribute " + Chr(34) + monster_type_db(i)\affliction[j]\attribute_name$ + Chr(34) + " in monster xml file " + Chr(34) + filename$ + Chr(34))
        EndIf
      EndIf
    Next
  Next
EndProcedure


; loads monster type db from xml file
Procedure load_monster_db(filename$ = "data\monster.xml")
  Protected val$, id.w, name$, tile.w, attack.w, strength.w, hitpoints.w, armor.w, level.w
  Protected resistance_class$, resistance_type.b, val2$, val3$, resistance_idx.w = 0, speed.b = 0
  Protected affliction_idx.w = 0, new_affliction.monster_affliction_struct, *mainnode
  Protected new_monster.monster_type_db_struct, *node, *childnode, *grandchildnode
  reset_monster_db()
  If CreateXML(0) = 0
    error_message("load_monster_db(): could not create xml structure in memory!")
  EndIf
  If LoadXML(0, filename$) = 0
    error_message("load_monster_db(): could not open monster xml file: " + Chr(34) + filename$ + Chr(34))
  EndIf
  If XMLStatus(0) <> 0
    error_message("load_monster_db(): error in xml structure of monster file " + Chr(34) + filename$ + Chr(34) + ": " + XMLError(0))
  EndIf
  *mainnode = MainXMLNode(0)
  If *mainnode
    *node = ChildXMLNode(*mainnode)
    While *node <> 0
      
      Select GetXMLNodeName(*node)
      
        Case "monster":
          id = 0
          reset_monster_type(@new_monster)
          If ExamineXMLAttributes(*node)
            While NextXMLAttribute(*node)
              val$ = XMLAttributeValue(*node)
              Select XMLAttributeName(*node)
                
                Case "id":
                  id = Val(val$)
                  If id < 1 Or id >= #MAX_NUMBER_OF_MONSTER_TYPES
                    error_message("load_monster_db(): wrong monster id " + Chr(34) + val$ + Chr(34) + " in monster file " + Chr(34) + filename$ + Chr(34))
                  EndIf
                  If monster_type_db(id)\name$ <> ""
                    error_message("load_monster_db(): monster id " + Chr(34) + val$ + Chr(34) + " not unique in monster file " + Chr(34) + filename$ + Chr(34))
                  EndIf
                  
                Case "name":
                  new_monster\name$ = val$
                  
                Case "class":
                  new_monster\class$ = val$
                  
                Case "tile":
                  new_monster\tile = Val(val$)
                  
                Case "attack":
                  new_monster\attack = Val(val$)
                  
                Case "defense":
                  new_monster\defense = Val(val$)
                  
                Case "strength":
                  new_monster\strength = Val(val$)
                  
                Case "hitpoints":
                  new_monster\hitpoints = Val(val$)
                  
                Case "armor":
                  new_monster\armor = Val(val$)
                  
                Case "level":
                  new_monster\level = Val(val$)
                  
                Case "speed":
                  new_monster\speed = Val(val$)
                  
                Case "flying":
                  If val$ = "yes"
                    new_monster\flying = 1
                  EndIf
                  
                Case "regeneration":
                  new_monster\regeneration = Val(val$)
                  
                Case "resistance":
                  new_monster\resistance_class$ = val$
                  
                Case "immune":
                  new_monster\immune_class$ = val$
                  
                Case "vulnerable":
                  new_monster\vulnerable_class$ = val$
                  
                Default:
                  error_message("load_monster_db(): unknown attribute " + Chr(34) + XMLAttributeName(*node) + Chr(34) + " in monster tag in file " + Chr(34) + filename$ + Chr(34))
              
              EndSelect
            Wend
            If id > 0 And new_monster\name$ <> ""
              With monster_type_db(id)
                \name$ = new_monster\name$
                \class$ = new_monster\class$
                \tile = new_monster\tile
                \attack = new_monster\attack
                \defense = new_monster\defense
                \strength = new_monster\strength
                \hitpoints = new_monster\hitpoints
                \armor = new_monster\armor
                \level = new_monster\level
                \speed = new_monster\speed
                \flying = new_monster\flying
                \regeneration = new_monster\regeneration
                \resistance_class$ = new_monster\resistance_class$
                \immune_class$ = new_monster\immune_class$
                \vulnerable_class$ = new_monster\vulnerable_class$
              EndWith
            Else
              error_message("load_monster_db(): monster tag without proper id or name in file " + Chr(34) + filename$ + Chr(34))
            EndIf
            affliction_idx = 0
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
                            monster_type_db(id)\name$ = GetXMLNodeText(*childnode)
                          EndIf
                          
                        Default:
                          error_message("load_monster_db(): unknown attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in name tag in monster xml file " + Chr(34) + filename$ + Chr(34))
                          
                      EndSelect
                    Wend
                  EndIf
                
                Case "affliction":
                  With new_affliction
                    \class$ = ""
                    \chance = 100
                    \attribute = 0
                    \attribute_name$ = ""
                    \value = 0
                    \randomized = 0
                    \animation$ = ""
                    \sound$ = ""
                    \message$ = ""
                  EndWith
                  If ExamineXMLAttributes(*childnode)
                    While NextXMLAttribute(*childnode)
                      val2$ = XMLAttributeValue(*childnode)
                      Select XMLAttributeName(*childnode)
                      
                        Case "class":
                          new_affliction\class$ = val2$
                          
                        Case "chance":
                          new_affliction\chance = Val(val2$)
                          
                        Case "attribute":
                          new_affliction\attribute = Val(val2$)
                          
                        Case "attribute_name":
                          new_affliction\attribute_name$ = val2$
                          
                        Case "value":
                          new_affliction\value = Val(val2$)
                          
                        Case "randomized":
                          If val2$ = "yes"
                            new_affliction\randomized = 1
                          EndIf
                          
                        Case "animation":
                          new_affliction\animation$ = val2$
                          
                        Case "sound":
                          new_affliction\sound$ = val2$
                          
                        Case "message":
                          new_affliction\message$ = val2$
                          
                        Default:
                          error_message("load_monster_db(): unknown attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in affliction tag in monster xml file " + Chr(34) + filename$ + Chr(34))
                          
                      EndSelect
                    Wend
                    If affliction_idx >= #MAX_NUMBER_OF_MONSTER_AFFLICTIONS
                      error_message("load_monster_db(): too much afflictions for one monster type in monster xml file " + Chr(34) + filename$ + Chr(34))
                    EndIf
                    With monster_type_db(id)\affliction[affliction_idx]
                      \class$ = new_affliction\class$
                      \chance = new_affliction\chance
                      \attribute = new_affliction\attribute
                      \attribute_name$ = new_affliction\attribute_name$
                      \value = new_affliction\value
                      \randomized = new_affliction\randomized
                      \animation$ = new_affliction\animation$
                      \sound$ = new_affliction\sound$
                      \message$ = new_affliction\message$
                    EndWith
                  EndIf
                  *grandchildnode = ChildXMLNode(*childnode)
                  While *grandchildnode <> 0
                    Select GetXMLNodeName(*grandchildnode)
                    
                      Case "message":
                        If ExamineXMLAttributes(*grandchildnode)
                          While NextXMLAttribute(*grandchildnode)
                            val3$ = XMLAttributeValue(*grandchildnode)
                            Select XMLAttributeName(*grandchildnode)
                            
                              Case "language":
                                If val3$ = preferences\language$
                                  monster_type_db(id)\affliction[affliction_idx]\message$ = GetXMLNodeText(*grandchildnode)
                                EndIf
                              
                              Default:
                                error_message("load_monster_db(): unknown attribute " + Chr(34) + XMLAttributeName(*grandchildnode) + Chr(34) + " in message tag in monster xml file " + Chr(34) + filename$ + Chr(34))
                            
                            EndSelect
                          Wend
                        EndIf
                      
                      Default:
                        error_message("load_monster_db(): unknown tag " + Chr(34) + GetXMLNodeName(*grandchildnode) + Chr(34) + " in monster xml file " + Chr(34) + filename$ + Chr(34))
                    
                    EndSelect
                  *grandchildnode = NextXMLNode(*grandchildnode)  
                  Wend
                  affliction_idx = affliction_idx + 1
                
                Default:
                  error_message("load_monster_db(): unknown tag " + Chr(34) + GetXMLNodeName(*childnode) + Chr(34) + " in monster xml file " + Chr(34) + filename$ + Chr(34))
                  
              EndSelect
              *childnode = NextXMLNode(*childnode)
            Wend

          EndIf          
        
        Default:
          error_message("load_monster_db(): unknown tag " + Chr(34) + GetXMLNodeName(*node) + Chr(34) + " in monster xml file " + Chr(34) + filename$ + Chr(34))
      
      EndSelect
      *node = NextXMLNode(*node)
    Wend
  EndIf
  FreeXML(0)
  resolve_monster_type_db_names(filename$)
EndProcedure


; returns 1 if field contains monster, else 0
Procedure.b field_contains_monster(x.b, y.b)
  Protected rc.b = 0, *last_monster
  If ListIndex(monster()) >= 0
    *last_monster = @monster()
  EndIf
  ForEach monster()
    If monster()\xpos = x And monster()\ypos = y
      rc = 1
    EndIf
  Next
  If *last_monster
    ChangeCurrentElement(monster(), *last_monster)
  EndIf
  ProcedureReturn rc
EndProcedure


; add monster to map; returns 1 if successful, else 0
Procedure.b add_monster(*map.map_struct, *new_monster.monster_struct)
  Protected rc.b = 0, monster_found.b = 0
  If *new_monster\xpos >= 0 And *new_monster\xpos < #MAP_DIMENSION_X And *new_monster\ypos >= 0 And *new_monster\ypos < #MAP_DIMENSION_Y
    ForEach monster()
      If monster()\xpos = *new_monster\xpos And monster()\ypos = *new_monster\ypos
        monster_found = 1
      EndIf
    Next
    If monster_found = 0
      AddElement(monster())
      monster()\type = *new_monster\type
      monster()\xpos = *new_monster\xpos
      monster()\ypos = *new_monster\ypos
      monster()\hitpoints = *new_monster\hitpoints
      monster()\alerted = *new_monster\alerted
      monster()\y_offset = *new_monster\y_offset
      monster()\effect$ = ""
      rc = 1
    EndIf
  EndIf
  ProcedureReturn rc
EndProcedure


; clears all selected monsters
Procedure clear_selected_monster()
  Protected *last_monster
  If ListIndex(monster())
    *last_monster = @monster()
  EndIf
  ForEach monster()
    monster()\selected = 0
  Next
  If *last_monster
    ChangeCurrentElement(monster(), *last_monster)
  EndIf
EndProcedure


; kills all monsters with hitpoints below 1 (or marked as selected); returns the number of monsters killed
Procedure.w kill_monster(kill_selected_monsters.b = 0)
  Protected rc.w = 0, i.w
  ResetList(monster())
  While NextElement(monster())
    If (monster()\selected = 1 And kill_selected_monsters = 1) Or monster()\hitpoints < 1
      DeleteElement(monster())
      rc = rc + 1
      For i=1 To #MAX_NUMBER_OF_ABILITIES - 1
        If ability_db(i)\modify_with_each_kill > 0
          modify_attribute(i, ability_db(i)\modify_with_each_kill)
        EndIf
      Next
    EndIf
  Wend
  ProcedureReturn rc
EndProcedure


; character attacks monster
Procedure character_attacks_monster(*map.map_struct, x.w, y.w)
  Protected attack.b = 0, i.w, chance_to_hit.w, hit.b = 0, damage = 0, x1.w, y1.w, text$
  Protected *attacked_monster, critical_hit.b = 0, backstab_attack.b = 0
  ForEach monster()
    monster()\selected = 0
    If monster()\xpos = x And monster()\ypos = y
      attack = 1
      *attacked_monster = @monster()
      monster()\selected = 1
    EndIf
  Next
  If attack = 1
    ChangeCurrentElement(monster(), *attacked_monster)
    For i=1 To #MAX_NUMBER_OF_ABILITIES - 1
      If ability_db(i)\attack_melee = 1
        chance_to_hit = attribute_current_val(i)
      EndIf
    Next
    chance_to_hit = chance_to_hit - monster_type_db(monster()\type)\defense
    If monster()\alerted = 0 And backstabbing_val(1) > 0 ; backstab attack
      chance_to_hit = sneaking_val(0)
      backstab_attack = 1
    EndIf
    chance_to_hit = max(10, min(90, chance_to_hit))
    monster()\alerted = 1    
    If Random(99) <= chance_to_hit
      hit = 1
      play_sound("hit")
      damage = max(0, random_damage_in_melee() - monster_type_db(monster()\type)\armor)
      If backstab_attack = 1
        damage = damage + backstabbing_val(0)
        message(ReplaceString(message_list$(#MESSAGE_SUCCESSFUL_BACKSTAB), "[damage]", Str(damage)), "")
      EndIf
      If damage > 0
        For i=1 To #MAX_NUMBER_OF_ABILITIES - 1
          If ability_db(i)\hit_multiplier > 0
            modify_attribute(i, ability_db(i)\hit_multiplier)
          EndIf
          If ability_db(i)\hit_attribute > 0
            modify_attribute(i, attribute_current_val(ability_db(i)\hit_attribute))
          EndIf
          If ability_db(i)\critical_hit_melee = 1
            If Random(99) <= attribute_current_val(i)
              critical_hit = 1
              damage = monster()\hitpoints
            EndIf
          EndIf
        Next
      EndIf
    Else
      play_sound("evasion")
    EndIf
    ClearScreen(0)
    draw_map_screen(@current_map)
    draw_frame_main_screen() 
    draw_right_panel()
    draw_character(-2)
    If hit = 1
      x1 = (6 + x - current_character\xpos) * 32
      y1 = (6 + y - current_character\ypos) * 32
      If critical_hit = 1
        clip_fx_tile_sprite(#SPRITE_FX_BLOOD_SKULL)
        DisplayTransparentSprite(#SPRITE_FX, x1, y1)
      Else
        clip_fx_tile_sprite(#SPRITE_FX_CLOUD_RED)
        DisplayTransparentSprite(#SPRITE_FX, x1, y1)
        StartDrawing(ScreenOutput())
        DrawingFont(#PB_Default)
        text$ = Str(damage)
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawText(x1 + 16 - TextWidth(text$)/2, y1 + 16 - TextHeight(text$)/2, text$, $ffffff, 0)
        StopDrawing()
      EndIf
      ChangeCurrentElement(monster(), *attacked_monster)
      monster()\hitpoints = monster()\hitpoints - damage
    EndIf
    FlipBuffers()
    Delay(250)
    ClearScreen(0)
    kill_monster()
    draw_map_screen(@current_map)
    draw_frame_main_screen() 
    draw_right_panel()
    draw_character()
    FlipBuffers()
    Delay(250)   
  EndIf
EndProcedure


; monster attacks character
Procedure monster_attacks_character(x.w, y.w)
  Protected attack.b, *attacking_monster, chance_to_hit.w, hit.b = 0, damage.w = 0
  Protected text$, i.w = 0, value.w = 0
  ForEach monster()
    If monster()\xpos = x And monster()\ypos = y
      *attacking_monster = @monster()
      monster()\y_offset = -2
      attack.b = 1
    EndIf
  Next
  If attack = 1
    ChangeCurrentElement(monster(), *attacking_monster)
    monster()\alerted = 1
    chance_to_hit = monster_type_db(monster()\type)\attack - defense_in_melee()
    chance_to_hit = max(10, min(90, chance_to_hit))
    If Random(99) <= chance_to_hit
      hit = 1
      play_sound("hit")
      damage = Random(monster_type_db(monster()\type)\strength + 2) + 1
      damage = character_damage_buffer(damage)
      damage = max(0, damage - random_armor_protection())
      character_takes_damage(damage, message_list$(#MESSAGE_YOU_WERE_KILLED_BY) + " " + monster_type_db(monster()\type)\name$)
      For i = 0 To #MAX_NUMBER_OF_MONSTER_AFFLICTIONS - 1
        If monster_type_db(monster()\type)\affliction[i]\chance > 0 And monster_type_db(monster()\type)\affliction[i]\attribute > 0 And damage > 0
          If Random(99) < monster_type_db(monster()\type)\affliction[i]\chance
            value = monster_type_db(monster()\type)\affliction[i]\value
            If monster_type_db(monster()\type)\affliction[i]\randomized = 1
              value = Random(Abs(value) - 1) + 1
              If monster_type_db(monster()\type)\affliction[i]\value < 0
                value = value * (-1)
              EndIf
              If value <> 0
                modify_attribute(monster_type_db(monster()\type)\affliction[i]\attribute, value)
              EndIf
            EndIf
          EndIf
        EndIf
      Next
    Else
      play_sound("evasion")
    EndIf
    monster()\y_offset = -2  
    ClearScreen(0)
    draw_map_screen(@current_map)
    draw_frame_main_screen() 
    draw_right_panel()
    draw_character()
    If hit = 1
      text$ = Str(damage)
      clip_fx_tile_sprite(#SPRITE_FX_CLOUD_RED)
      DisplayTransparentSprite(#SPRITE_FX, 6*32, 6*32)
      StartDrawing(ScreenOutput())
      DrawingFont(#PB_Default)
      text$ = Str(damage)
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawText(6*32 + 16 - TextWidth(text$)/2, 6*32 + 16 - TextHeight(text$)/2, text$, $ffffff)
      StopDrawing()  
    EndIf
    FlipBuffers()
    Delay(250)
    ChangeCurrentElement(monster(), *attacking_monster)
    monster()\y_offset = 0
    draw_map_screen(@current_map)
    draw_frame_main_screen() 
    draw_right_panel()
    draw_character()
    FlipBuffers()
    Delay(250)
  EndIf
EndProcedure


; returns a random monster type
Procedure.w random_monster_type(max_monster_level.w = 99999)
  Protected NewList monsterlist.w(), i.w = 0, count.w = 0, r.w, rc.w = 0, stop_count.b = 0, add_monster.b = 0
  ClearList(monsterlist())
  For i=1 To #MAX_NUMBER_OF_MONSTER_TYPES - 1
    add_monster = 0
    If monster_type_db(i)\name$ <> "" And monster_type_db(i)\level <= max_monster_level
      add_monster = 1
    EndIf
    If add_monster = 1
      AddElement(monsterlist())
      monsterlist() = i
      count = count + 1
    EndIf
  Next
  i = Random(ListSize(monsterlist()) - 1) + 1
  ResetList(monsterlist())
  While i > 0 And NextElement(monsterlist())
    rc = monsterlist()
    i = i - 1
  Wend
  ClearList(monsterlist())
  ProcedureReturn rc  
EndProcedure


; places a random monster on a random position on the map; returns 1 if successful, else 0
Procedure place_random_monster(*map.map_struct, max_monster_level.w = 99999)
  Protected rc.b = 0, i.w, m.w, type.w = 0, x.w, y.w, new_monster.monster_struct, stop_counter.w = 0
  Protected empty_field_found.b = 0
  type = random_monster_type(max_monster_level)
  Repeat
    x = Random(#MAP_DIMENSION_X - 1)
    y = Random(#MAP_DIMENSION_Y - 1)
    stop_counter = stop_counter + 1
    empty_field_found = 1
    If field_is_blocked_for_monster(*map, x, y, type) = 1
      empty_field_found = 0
    EndIf
  Until empty_field_found = 1 And stop_counter < 100
  If stop_counter < 100
    new_monster\type = type
    new_monster\xpos = x
    new_monster\ypos = y
    new_monster\hitpoints = monster_type_db(type)\hitpoints
    new_monster\alerted = 0
    new_monster\y_offset = 0
    new_monster\effect$ = ""
    add_monster(*map, @new_monster)
    rc = 1
  EndIf
  ProcedureReturn rc
EndProcedure


; spawn a random monster on the map
Procedure.b spawn_random_monster(*map.map_struct)
  Protected rc.b = 0, i.w, m.w, type.w = 0, x.w, y.w, new_monster.monster_struct
  If *map\spawn_monster_chance > 0 And *map\spawn_monster_level > 0
    If Random(99) <= *map\spawn_monster_chance
      m = 0
      For i=0 To #MAX_NUMBER_OF_MONSTER_TYPES-1
        If monster_type_db(i)\name$ <> ""
          m = i
        EndIf
      Next
      If m > 0
        Repeat
          type = Random(m)
        Until monster_type_db(type)\level = *map\spawn_monster_level
        Repeat
          x = #MAP_DIMENSION_X; Random(#MAP_DIMENSION_X-1)
          y = #MAP_DIMENSION_Y; Random(#MAP_DIMENSION_Y-1)
        Until field_is_blocked(*map, x, y) = 0 And field_contains_monster(x, y) = 0
        new_monster\type = type
        new_monster\xpos = x
        new_monster\ypos = y
        new_monster\hitpoints = monster_type_db(type)\hitpoints
        new_monster\alerted = 0
        new_monster\y_offset = 0
        new_monster\effect$ = ""
        add_monster(*map, @new_monster)
        rc = 1
      EndIf
    EndIf
  EndIf
  ProcedureReturn rc
EndProcedure


; returns -1 if exp < 0, else 1
Procedure.b sgn(exp.l)
  Protected rc.b = 1
  If exp < 0
    rc = -1
  EndIf
  ProcedureReturn rc
EndProcedure


; move all monster on the map
Procedure move_all_monster()
  Protected dx.b = 0, dy.b = 0, speed.b, monster_type.w, i.w = 0, *monster.monster_struct
  Protected x.w = 0, y.w = 0, char_x.w, char_y.w, direction.b = 0, count.b = 0, found.b = 0
  Protected random_move.b = 0
  char_x = current_character\xpos
  char_y = current_character\ypos
  ResetList(monster())
  While NextElement(monster())
    *monster = @monster()
    monster_type = monster()\type
    speed = monster_type_db(monster_type)\speed
    If compare_string_lists(monster()\effect$, "slowed") = 1
      speed = 1
    EndIf
    While speed > 0
      dx = 0
      dy = 0
      If monster()\alerted = 1
        If char_x <> monster()\xpos Or char_y <> monster()\ypos
          If Abs(char_y - monster()\ypos) > Abs(char_x - monster()\xpos)
            dy = sgn(current_character\ypos - monster()\ypos)
          Else
            dx = sgn(current_character\xpos - monster()\xpos)
          EndIf
          If monster()\xpos + dx = char_x And monster()\ypos + dy = char_y
            speed = 0
            dx = 0
            dy = 0
          EndIf
        EndIf
      Else
        speed = 0
      EndIf
      If dx <> 0 Or dy <> 0
        random_move = 0
        If field_is_blocked_for_monster(@current_map, monster()\xpos + dx, monster()\ypos + dy, monster_type) = 1
          random_move = 1
        EndIf
        If compare_string_lists(monster()\effect$, "confused") = 1
          random_move = 1
        EndIf
        If random_move = 1 ; random movement
          direction = Random(3)
          count = 0
          found = 0
          dx = 0
          dy = 0
          While count < 4 And found = 0
            Select direction
            
              Case 0:
                If field_is_blocked_for_monster(@current_map, monster()\xpos, monster()\ypos - 1, monster_type) = 0
                  dy = -1
                  found = 1
                EndIf
             
              Case 1:
                If field_is_blocked_for_monster(@current_map, monster()\xpos + 1, monster()\ypos, monster_type) = 0
                  dx = 1
                  found = 1
                EndIf
              
              Case 2:
                If field_is_blocked_for_monster(@current_map, monster()\xpos, monster()\ypos + 1, monster_type) = 0
                  dy = 1
                  found = 1
                EndIf
                
              Case 3:
                If field_is_blocked_for_monster(@current_map, monster()\xpos - 1, monster()\ypos, monster_type) = 0
                  dx = -1
                  found = 1
                EndIf
            
            EndSelect
            direction = direction + 1
            If direction > 3
              direction = 0
            EndIf
            count = count + 1
          Wend
          If found = 0
            speed = 0
          EndIf
        EndIf
      EndIf
      If speed > 0 And (dx <> 0 Or dy <> 0)
        ChangeCurrentElement(monster(), *monster)
        If monster()\xpos >= current_character\xpos - 7 And monster()\xpos <= current_character\xpos + 7 And monster()\ypos >= current_character\ypos - 7 And monster()\ypos <= current_character\ypos + 7
            For i = 2 To 32 Step 2
              ChangeCurrentElement(monster(), *monster)
              monster()\x_offset = i * dx
              monster()\y_offset = i * dy
              draw_map_screen(@current_map)
              draw_frame_main_screen()
              draw_right_panel()
              draw_character()
              FlipBuffers()
            Next
            Delay(250)   
          ChangeCurrentElement(monster(), *monster)
        EndIf
        ChangeCurrentElement(monster(), *monster)
        monster()\x_offset = 0
        monster()\y_offset = 0
        monster()\xpos = monster()\xpos + dx
        monster()\ypos = monster()\ypos + dy
      EndIf
      speed = speed - 1
    Wend
  Wend
EndProcedure


; update effects per turn for each monster
Procedure monster_turn_ends()
  Protected *last_monster, type.w, regeneration_value.w, text$
  If ListIndex(monster()) >= 0
    *last_monster = @monster()
  EndIf
  ForEach monster()
    type = monster()\type
    If monster_type_db(type)\regeneration > 0 And monster()\hitpoints < monster_type_db(type)\hitpoints
      regeneration_value = min(Random(monster_type_db(type)\regeneration - 1) + 1, monster_type_db(type)\hitpoints - monster()\hitpoints)
      If monster()\xpos >= current_character\xpos - 6 And monster()\xpos =< current_character\xpos + 6 And monster()\ypos >= current_character\ypos - 6 And monster()\ypos =< current_character\ypos + 6
        text$ = ReplaceString(message_list$(#MESSAGE_MONSTER_REGENERATES), "[value]", Str(regeneration_value))
        message(text$, "", $ffffff, monster_type_db(type)\tile, 3)
        star_circle_animation(4, monster()\xpos - current_character\xpos + 6, monster()\ypos - current_character\ypos + 6)
      EndIf
      monster()\hitpoints = min(monster()\hitpoints + regeneration_value, monster_type_db(type)\hitpoints)
    EndIf
  Next
  If *last_monster
    ChangeCurrentElement(monster(), *last_monster)
  EndIf  
EndProcedure


; sets monster at pos x/y to alerted; returns 1 if successfull, else 0
Procedure.b alert_monster(x.w, y.w)
  Protected rc.b = 0, *last_monster
  If ListIndex(monster()) > 0
    *last_monster = @monster()
  EndIf
  ForEach monster()
    If monster()\xpos = x And monster()\ypos = y
      monster()\alerted = 1
      rc = 1
    EndIf
  Next
  If *last_monster
    ChangeCurrentElement(monster(), *last_monster)
  EndIf
  ProcedureReturn rc
EndProcedure


; returns 1 if monster at pos x/y is alerted, else 0
Procedure.b monster_is_alerted(x.w, y.w)
  Protected rc.b = 0, *last_monster
  If ListIndex(monster()) > 0
    *last_monster = @monster()
  EndIf
  ForEach monster()
    If monster()\xpos = x And monster()\ypos = y
      If monster()\alerted = 1
        rc = 1
      EndIf
    EndIf
  Next
  If *last_monster
    ChangeCurrentElement(monster(), *last_monster)
  EndIf    
  ProcedureReturn rc
EndProcedure


; adjust damage done to a monster with resistances, vulnerabilities and immunities; returns adjusted damage
Procedure.w monster_adjust_damage(monster_type.w, damage.w, damage_class$, affects_only_monster_class$ = "")
  Protected rc.w = 0
  rc = damage
  If compare_string_lists(monster_type_db(monster_type)\resistance_class$, damage_class$) = 1
    rc = Int(rc / 2)
  EndIf
  If compare_string_lists(monster_type_db(monster_type)\vulnerable_class$, damage_class$) = 1
    damage = damage * 2
  EndIf
  If compare_string_lists(monster_type_db(monster_type)\immune_class$, damage_class$) = 1
    damage = 0
  EndIf
  If affects_only_monster_class$ <> ""
    If compare_string_lists(monster_type_db(monster_type)\class$, affects_only_monster_class$) = 0
      damage = 0
    EndIf
  EndIf  
  ProcedureReturn rc
EndProcedure
; IDE Options = PureBasic 6.04 beta 1 LTS (Windows - x64)
; CursorPosition = 642
; FirstLine = 625
; Folding = ----
; CompileSourceDirectory
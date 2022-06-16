; Lost Labyrinth VI: Portals
; character procedures
; written in PureBasic 4.20 (http://www.purebasic.com)
; created:  25.10.2008 Frank Malota <malota@web.de>
; modified: 20.02.2009 Frank Malota <malota@web.de>


XIncludeFile "constants.pb"
XIncludeFile "error_handling.pb"


; declarations
Declare character_gets_item(type.w, amount.w = 1, fuel.w = -1, magic_bonus.b = -1)
Declare.b power_available(power_id.w, gain_attribute.w = 0, gain_bonus.w = 0)
Declare update_abilities_adjustment_other()
Declare scramble_item_db_tiles(class$)


; initialize character
Procedure init_character(*char.char_struct)
  Protected i.w
  *char\xpos = 2
  *char\ypos = 4
  *char\facing = 0
  *char\frame = 0
  *char\map_filename$ = "map_start.xml"
  *char\inventory_cursor_x = 0
  *char\inventory_cursor_y = 0
  For i=0 To #MAX_NUMBER_OF_ABILITIES - 1
    With *char\ability[i]
      \ability_value = 0
      \attribute_max_value = ability_db(i)\attribute_start_value
      \attribute_current_value = ability_db(i)\attribute_start_value
      \power_adjustment = 0
      \adjustment_duration = 0
      \adjustment_name$ = ""
      \adjustment_power_id = 0
      \adjustment_item_id = 0
      \item_bonus = 0
      \activated = 0
      \adjustment_other = 0
      \adjustment_percentage = 100
    EndWith
  Next
  For i=0 To #MAX_NUMBER_OF_POWERS-1
    *char\power[i]\cooldown = 0
  Next
  For i = 0 To #MAX_NUMBER_OF_ITEMS - 1
    *char\item_identification[i]\identified = 0
  Next
  *char\game_end_message$ = ""
  ClearList(inventory())
  update_abilities_adjustment_other()
  scramble_item_db_tiles("Potion")
EndProcedure


; resets a single ability
Procedure reset_ability(*ability.ability_db_struct)
  Protected i.w = 0
  With *ability
    \name$ = ""
    \name_display$ = ""
    \description$ = ""
    \tile = 0
    \attribute = 0
    \color = $ffffff
    \attribute_start_value = 0
    \depletable = 0
    \percentage = 0
    \main_screen = 0
    \displayed_as_bonus = 0
    \randomizer_ability = 0
    \randomizer_ability_name$ = ""
    \xp = 0
    \not_shown_if_zero = 0
    \minimum = -1
    \change_per_turn_chance = 0
    \change_per_turn = 0
    \change_per_move = 0
    \turn_ends_if_lower = -32000
    \restore_at_end_of_turn = 0
    \game_ends = 0
    \game_ends_val = 0
    \game_ends_message$ = ""
    \critical_hit_melee = 0
    \attack_melee = 0
    \defense_melee = 0
    \modify_with_each_kill = 0
    \damage_in_melee = 0
    \lightradius = 0
    \modify_per_point_of_damage = 0
    \sneaking = 0
    \backstab = 0
    \perception_tile_class$ = ""
    \modify_attribute = 0
    \modify_attribute_name$ = ""
    \modify_multiplier = 1
    \modify_divisor = 1
    \modify_animation$ = ""
    \modify_sound$ = ""
    \armor = 0
    \movement = 0
    \buffer_for_attribute = 0
    \buffer_for_attribute_name$ = ""
    \buffer_animation$ = ""
    \hit_multiplier = 0
    \hit_attribute = 0
    \hit_attribute_name$ = ""
  EndWith
  For i=0 To #MAX_NUMBER_OF_ATTRIBUTE_BONI - 1
    With *ability\attribute_bonus[i]
      \attribute = 0
      \bonus = 0
      \displayed = 0
      \name$ = ""
    EndWith
  Next
  For i=0 To #MAX_NUMBER_OF_ABILITY_CAPS - 1
    With *ability\ability_cap[i]
      \ability = 0
      \name$ = ""
      \bonus = 0
      \multiplier = 0
      \divisor = 0
    EndWith
  Next
  For i=0 To #MAX_NUMBER_OF_ABILITY_REQUIREMENTS - 1
    With *ability\ability_requirement[i]
      \attribute = 0
      \value = 0
      \name$ = ""
    EndWith
  Next
  For i=0 To #MAX_NUMBER_OF_ABILITY_DISPLAYS - 1
    With *ability\display[i]
      \type = 0
      \start_value = 0
      \end_value = 0
      \message$ = ""
      \message2$ = ""
      \color = 0
      \expanded_value_display = 0
    EndWith
  Next
  For i=0 To #MAX_NUMBER_OF_ABILITY_ADJUSTMENTS - 1
    With *ability\adjustment[i]
      \attribute = 0
      \attribute_name$ = ""
      \value = 0
      \percentage = 100
      \percentage_attribute_multiplier = 0
      \percentage_bonus = 0
    EndWith
  Next
  For i = 0 To #MAX_NUMBER_OF_ABILITY_STARTING_EQUIPMENT - 1
    With *ability\starting_equipment[i]
      \item = 0
      \item_name$ = ""
      \amount = 1
    EndWith
  Next
EndProcedure


; resets abilities db
Procedure reset_ability_db()
  Protected i.w, j.w
  For i=0 To #MAX_NUMBER_OF_ABILITIES - 1
    reset_ability(@ability_db(i))
  Next
EndProcedure


; resolves name placeholders in ability boni and sets ability ID in
Procedure ability_db_resolve_names()
  Protected i.w, j.w, k.w
  For i=0 To #MAX_NUMBER_OF_ABILITIES - 1
    If ability_db(i)\randomizer_ability = 0 And ability_db(i)\randomizer_ability_name$ <> ""
      For k=0 To #MAX_NUMBER_OF_ABILITIES - 1
        If ability_db(k)\name$ = ability_db(i)\randomizer_ability_name$
          ability_db(i)\randomizer_ability = k
        EndIf
      Next 
      If ability_db(i)\randomizer_ability = 0
        error_message("ability_db_resolve_names(): cannot find ability " + Chr(34) + ability_db(i)\randomizer_ability_name$ + Chr(34))
      EndIf
    EndIf
    If ability_db(i)\modify_attribute = 0 And ability_db(i)\modify_attribute_name$ <> ""
      For k=0 To #MAX_NUMBER_OF_ABILITIES - 1
        If ability_db(k)\name$ = ability_db(i)\modify_attribute_name$
          ability_db(i)\modify_attribute = k
        EndIf
      Next 
      If ability_db(i)\modify_attribute = 0
        error_message("ability_db_resolve_names(): cannot find ability " + Chr(34) + ability_db(i)\modify_attribute_name$ + Chr(34))
      EndIf
    EndIf
    If ability_db(i)\buffer_for_attribute = 0 And ability_db(i)\buffer_for_attribute_name$ <> ""
      For k=0 To #MAX_NUMBER_OF_ABILITIES - 1
        If ability_db(k)\name$ = ability_db(i)\buffer_for_attribute_name$
          ability_db(i)\buffer_for_attribute = k
        EndIf
      Next 
      If ability_db(i)\buffer_for_attribute = 0
        error_message("ability_db_resolve_names(): cannot find ability " + Chr(34) + ability_db(i)\buffer_for_attribute_name$ + Chr(34))
      EndIf
    EndIf
    If ability_db(i)\hit_attribute = 0 And ability_db(i)\hit_attribute_name$ <> ""
      For k=0 To #MAX_NUMBER_OF_ABILITIES - 1
        If ability_db(k)\name$ = ability_db(i)\hit_attribute_name$
          ability_db(i)\hit_attribute = k
        EndIf
      Next 
      If ability_db(i)\hit_attribute = 0
        error_message("ability_db_resolve_names(): cannot find ability " + Chr(34) + ability_db(i)\hit_attribute_name$ + Chr(34))
      EndIf
    EndIf
    For j=0 To #MAX_NUMBER_OF_ATTRIBUTE_BONI - 1
      If ability_db(i)\attribute_bonus[j]\attribute = 0 And ability_db(i)\attribute_bonus[j]\name$ <> ""
        For k=0 To #MAX_NUMBER_OF_ABILITIES - 1
          If ability_db(k)\name$ = ability_db(i)\attribute_bonus[j]\name$
            ability_db(i)\attribute_bonus[j]\attribute = k
          EndIf
        Next
        If ability_db(i)\attribute_bonus[j]\attribute = 0
          error_message("ability_resolve_names(): could not find ability " + Chr(34) + ability_db(i)\attribute_bonus[j]\name$ + Chr(34))
        EndIf
      EndIf
    Next
    For j=0 To #MAX_NUMBER_OF_ABILITY_CAPS - 1
      If ability_db(i)\ability_cap[j]\ability = 0 And ability_db(i)\ability_cap[j]\name$ <> ""
        For k=0 To #MAX_NUMBER_OF_ABILITIES - 1
          If ability_db(k)\name$ = ability_db(i)\ability_cap[j]\name$
            ability_db(i)\ability_cap[j]\ability = k
          EndIf
        Next
        If ability_db(i)\ability_cap[j]\ability = 0
          error_message("ability_resolve_names(): could not find ability " + Chr(34) + ability_db(i)\ability_cap[j]\name$ + Chr(34))
        EndIf
      EndIf
    Next
    For j=0 To #MAX_NUMBER_OF_ABILITY_REQUIREMENTS - 1
      If ability_db(i)\ability_requirement[j]\attribute = 0 And ability_db(i)\ability_requirement[j]\name$ <> ""
        For k=0 To #MAX_NUMBER_OF_ABILITIES - 1
          If ability_db(k)\name$ = ability_db(i)\ability_requirement[j]\name$
            ability_db(i)\ability_requirement[j]\attribute = k
          EndIf
        Next
        If ability_db(i)\ability_requirement[j]\attribute = 0
          error_message("ability_resolve_names(): could not find ability " + Chr(34) + ability_db(i)\ability_requirement[j]\name$ + Chr(34))
        EndIf
      EndIf
    Next   
    For j=0 To #MAX_NUMBER_OF_ABILITY_ADJUSTMENTS - 1
      If ability_db(i)\adjustment[j]\attribute = 0 And ability_db(i)\adjustment[j]\attribute_name$ <> ""
        For k=0 To #MAX_NUMBER_OF_ABILITIES - 1
          If ability_db(k)\name$ = ability_db(i)\adjustment[j]\attribute_name$
            ability_db(i)\adjustment[j]\attribute = k
          EndIf
        Next
        If ability_db(i)\adjustment[j]\attribute = 0
          error_message("ability_resolve_names(): could not find ability " + Chr(34) + ability_db(i)\adjustment[j]\attribute_name$ + Chr(34))
        EndIf
      EndIf
    Next
    For j = 0 To #MAX_NUMBER_OF_ABILITY_STARTING_EQUIPMENT - 1
      If ability_db(i)\starting_equipment[j]\item_name$ <> "" And ability_db(i)\starting_equipment[j]\item = 0
        For k = 1 To #MAX_NUMBER_OF_ITEMS - 1
          If item_db(k)\name$ = ability_db(i)\starting_equipment[j]\item_name$
            ability_db(i)\starting_equipment[j]\item = k
          EndIf
        Next
        If ability_db(i)\starting_equipment[j]\item = 0
          error_message("ability_resolve_names(): could not find item " + Chr(34) + ability_db(i)\starting_equipment[j]\item_name$ + Chr(34))
        EndIf
      EndIf
    Next    
  Next 
EndProcedure


; load abilities into abilities db
Procedure load_abilities_db()
  Protected filename$ ="data\abilities.xml"
  Protected id.w, val$, val2$, name$, description$, tile.w, attribute_start_value.w, color.l
  Protected depletable.b, percentage.b, main_screen.b, displayed_as_bonus.b, bonus.w
  Protected randomizer_ability.w, attribute.b, attribute_bonus_idx.b, attribute_idx.w
  Protected ability_cap_idx.w, ability_idx.w, divisor.b, multiplier.w, xp.b, displayed.b
  Protected ability_req_idx.w, req_val.w, bonus_min_damage_in_melee.b
  Protected bonus_max_damage_in_melee.b, not_shown_if_zero.b, minimum.w, change_per_turn.w
  Protected display_idx.w, display_start_value.w, display_end_value.w, display_message$
  Protected display_message_color.l, display_main_display.b, game_ends.w, game_ends_val.w
  Protected game_ends_message$, critical_hit_melee.b, attack_melee.b, defense_melee.b
  Protected modify_with_each_kill.w, damage_in_melee.b, randomizer_ability_name$, lightradius.b
  Protected modify_per_point_of_damage.b, damage_buffer.b, sneaking.b, backstab.b, perception_tile_class$
  Protected new_ability.ability_db_struct, new_adjustment.ability_attribute_adjustment_struct
  Protected adjustment_idx.b, *mainnode, *node, *childnode, display_language$
  Protected new_ability_display.ability_display_struct
  Protected starting_equipment_item_id.w, starting_equipment_item_amount.w
  Protected starting_equipment_idx.w, starting_equipment_item_name$
  If CreateXML(0) = 0
    error_message("load_abilities_db(): could not create xml structure in memory!")
  EndIf
  If LoadXML(0, filename$) = 0
    error_message("load_abilities_db(): could not open abilites xml file: " + Chr(34) + filename$ + Chr(34))
  EndIf
  If XMLStatus(0) <> 0
    error_message("load_abilities_db(): error in xml structure of abilities file " + Chr(34) + filename$ + Chr(34) + ": " + XMLError(0))
  EndIf
  reset_ability_db()
  *mainnode = MainXMLNode(0)
  If *mainnode
    *node = ChildXMLNode(*mainnode)
    While *node <> 0
      Select GetXMLNodeName(*node)
        
        Case "ability":
          id = -1
          reset_ability(@new_ability)
          attribute_bonus_idx = 0
          ability_cap_idx = 0
          ability_req_idx = 0
          display_idx = 0
          adjustment_idx = 0
          starting_equipment_idx = 0
          If ExamineXMLAttributes(*node)
            While NextXMLAttribute(*node)
              val$ = XMLAttributeValue(*node)
              Select XMLAttributeName(*node)
                
                Case "id":
                  id = Val(val$)
                  
                Case "name":
                  new_ability\name$ = val$
                  
                Case "description":
                  new_ability\description$ = val$
                  
                Case "tile":
                  new_ability\tile = Val(val$)
                  
                Case "attribute_start_value":
                  new_ability\attribute_start_value = Val(val$)                 
                  
                Case "color":
                  new_ability\color = Val(val$)
                  
                Case "depletable":
                  If val$ = "yes"
                    new_ability\depletable = 1
                  EndIf
                  
                Case "percentage":
                  If val$ = "yes"
                    new_ability\percentage = 1
                  EndIf
                  
                Case "main_screen":
                  If val$ = "yes"
                    new_ability\main_screen = 1
                  EndIf
                  
                Case "displayed_as_bonus":
                  If val$= "yes"
                    new_ability\displayed_as_bonus = 1
                  EndIf
                  
                Case "randomizer_ability":
                  new_ability\randomizer_ability = Val(val$)
                  
                Case "attribute":
                  If val$ = "yes"
                    new_ability\attribute = 1
                  EndIf
                  
                Case "xp":
                  If val$ = "yes"
                    new_ability\xp = 1
                  EndIf
                
                Case "not_shown_if_zero":
                  If val$ = "yes"
                    new_ability\not_shown_if_zero = 1
                  EndIf
                  
                Case "minimum":
                  new_ability\minimum = Val(val$)
                  
                Case "change_per_turn_chance":
                  new_ability\change_per_turn_chance = Val(val$)
                  
                Case "change_per_turn":
                  new_ability\change_per_turn = Val(val$)
                  
                Case "change_per_move":
                  new_ability\change_per_move = Val(val$)
                  
                Case "turn_ends_if_lower":
                  new_ability\turn_ends_if_lower = Val(val$)
                  
                Case "restore_at_end_of_turn":
                  If val$ = "yes"
                    new_ability\restore_at_end_of_turn = 1
                  EndIf
                  
                Case "game_ends":
                  If val$="lower"
                    new_ability\game_ends = 1
                  EndIf
                  If val$="higher"
                    new_ability\game_ends = 2
                  EndIf

                Case "game_ends_val":
                  new_ability\game_ends_val = Val(val$)
                  
                Case "game_ends_message":
                  new_ability\game_ends_message$ = val$
                  
                Case "critical_hit_melee":
                  If val$ = "yes"
                    new_ability\critical_hit_melee = 1
                  EndIf
                  
                Case "attack_melee":
                  If val$ = "yes"
                    new_ability\attack_melee = 1
                  EndIf
                  
                Case "defense_melee":
                  If val$ = "yes"
                    new_ability\defense_melee = 1
                  EndIf
                  
                Case "modify_with_each_kill":
                  new_ability\modify_with_each_kill = Val(val$)
                  
                Case "damage_in_melee":
                  If val$ = "yes"
                    new_ability\damage_in_melee = 1
                  EndIf
                  
                Case "randomizer_ability_name":
                  new_ability\randomizer_ability_name$ = val$
                  
                Case "lightradius":
                  If val$ = "yes"
                    new_ability\lightradius = 1
                  EndIf
                  
                Case "modify_per_point_of_damage":
                  new_ability\modify_per_point_of_damage = Val(val$)
                  
                Case "sneaking":
                  If val$ = "yes"
                    new_ability\sneaking = 1
                  EndIf
                  
                Case "backstab":
                  If val$ = "yes"
                    new_ability\backstab = 1
                  EndIf
                  
                Case "perception_tile_class":
                  new_ability\perception_tile_class$ = val$
                  
                Case "modify_atribute":
                  new_ability\modify_attribute = Val(val$)
                  
                Case "modify_attribute_name":
                  new_ability\modify_attribute_name$ = val$
                
                Case "modify_multiplier":
                  new_ability\modify_multiplier = Val(val$)
                  
                Case "modify_divisor":
                  new_ability\modify_divisor = Val(val$)
                  
                Case "modify_animation":
                  new_ability\modify_animation$ = val$
                  
                Case "modify_sound":
                  new_ability\modify_sound$ = val$
                  
                Case "armor":
                  If val$ = "yes"
                    new_ability\armor = 1
                  EndIf
                  
                Case "movement":
                  If val$ = "yes"
                    new_ability\movement = 1
                  EndIf
                  
                Case "buffer_for_attribute":
                  new_ability\buffer_for_attribute = Val(val$)
                  
                Case "buffer_for_attribute_name":
                  new_ability\buffer_for_attribute_name$ = val$
                
                Case "buffer_animation":
                  new_ability\buffer_animation$ = val$
                  
                Case "hit_multiplier":
                  new_ability\hit_multiplier = Val(val$)
                  
                Case "hit_attribute":
                  new_ability\hit_attribute = Val(val$)
                  
                Case "hit_attribute_name":
                  new_ability\hit_attribute_name$ = val$
                
                Default:
                  error_message("load_abilities_db(): wrong attribute " + Chr(34) + XMLAttributeName(*node) + Chr(34) + " in ability tag in file " + Chr(34) + filename$ + Chr(34))
                  
              EndSelect
            Wend
          EndIf
          If id < 1
            error_message("load_abilities_db(): error in abilities file " + Chr(34) + filename$ + Chr(34) + ": unique ability id < 1")
          EndIf
          If id >= #MAX_NUMBER_OF_ABILITIES
            error_message("load_abilities_db(): error in abilities file " + Chr(34) + filename$ + Chr(34) + ": ability id > " + Str(#MAX_NUMBER_OF_ABILITIES-1))
          EndIf
          If ability_db(id)\name$ <> ""
            error_message("load_abilities_db(): ability id " + Str(id) + " not unique in abilities file " + Chr(34) + filename$ + Chr(34))
          EndIf
          With ability_db(id)
            \name$ = new_ability\name$
            \name_display$ = new_ability\name$
            \description$ = new_ability\description$
            \tile = new_ability\tile
            \color = new_ability\color
            \attribute_start_value = new_ability\attribute_start_value
            \depletable = new_ability\depletable
            \percentage = new_ability\percentage
            \main_screen = new_ability\main_screen
            \displayed_as_bonus = new_ability\displayed_as_bonus
            \randomizer_ability = new_ability\randomizer_ability
            \randomizer_ability_name$ = new_ability\randomizer_ability_name$
            \attribute = new_ability\attribute
            \xp = new_ability\xp
            \not_shown_if_zero = new_ability\not_shown_if_zero
            \minimum = new_ability\minimum
            \change_per_turn_chance = new_ability\change_per_turn_chance
            \change_per_turn = new_ability\change_per_turn
            \change_per_move = new_ability\change_per_move
            \turn_ends_if_lower = new_ability\turn_ends_if_lower
            \restore_at_end_of_turn = new_ability\restore_at_end_of_turn
            \game_ends = new_ability\game_ends
            \game_ends_val = new_ability\game_ends_val
            \game_ends_message$ = new_ability\game_ends_message$
            \critical_hit_melee = new_ability\critical_hit_melee
            \attack_melee = new_ability\attack_melee
            \defense_melee = new_ability\defense_melee
            \modify_with_each_kill = new_ability\modify_with_each_kill
            \damage_in_melee = new_ability\damage_in_melee
            \lightradius = new_ability\lightradius
            \modify_per_point_of_damage = new_ability\modify_per_point_of_damage
            \sneaking = new_ability\sneaking
            \backstab = new_ability\backstab
            \perception_tile_class$ = new_ability\perception_tile_class$
            \modify_attribute = new_ability\modify_attribute
            \modify_attribute_name$ = new_ability\modify_attribute_name$
            \modify_multiplier = new_ability\modify_multiplier
            \modify_divisor = new_ability\modify_divisor
            \modify_animation$ = new_ability\modify_animation$
            \modify_sound$ = new_ability\modify_sound$
            \armor = new_ability\armor
            \movement = new_ability\movement
            \buffer_for_attribute = new_ability\buffer_for_attribute
            \buffer_for_attribute_name$ = new_ability\buffer_for_attribute_name$
            \buffer_animation$ = new_ability\buffer_animation$
            \hit_multiplier = new_ability\hit_multiplier
            \hit_attribute = new_ability\hit_attribute
            \hit_attribute_name$ = new_ability\hit_attribute_name$
          EndWith
          *childnode = ChildXMLNode(*node)
          While *childnode <> 0
            Select GetXMLNodeName(*childnode)
              
              Case "attribute_bonus":
                If attribute_bonus_idx >= #MAX_NUMBER_OF_ATTRIBUTE_BONI
                  error_message("load_abilities_db(): too many attribute boni in attribute db file " + Chr(34) + filename$ + Chr(34))
                EndIf
                attribute_idx = 0
                bonus = 0
                displayed = 0
                name$ = ""
                If ExamineXMLAttributes(*childnode)
                  While NextXMLAttribute(*childnode)
                    val2$ = XMLAttributeValue(*childnode)
                    Select XMLAttributeName(*childnode)
                      
                      Case "attribute":
                        attribute_idx = Val(val2$)
                        If attribute_idx < 1 Or attribute_idx >= #MAX_NUMBER_OF_ABILITIES
                          error_message("load_abilities_db(): wrong attribute ID in attribute_bonus tag in file " + Chr(34) + filename$ + Chr(34))
                        EndIf
                        
                      Case "bonus":
                        bonus = Val(val2$)
                      
                      Case "displayed":
                        If val2$ = "yes"
                          displayed = 1
                        EndIf
                        
                      Case "name":
                        name$ = val2$
                        
                      Default:
                        error_message("load_abilities_db(): wrong attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in attribute_bonus tag in file " + Chr(34) + filename$ + Chr(34))
                        
                    EndSelect
                  Wend
                EndIf
                If attribute_idx > 0 Or name$ <> ""
                  ability_db(id)\attribute_bonus[attribute_bonus_idx]\attribute = attribute_idx
                  ability_db(id)\attribute_bonus[attribute_bonus_idx]\bonus = bonus
                  ability_db(id)\attribute_bonus[attribute_bonus_idx]\displayed = displayed
                  ability_db(id)\attribute_bonus[attribute_bonus_idx]\name$ = name$
                  attribute_bonus_idx = attribute_bonus_idx + 1
                EndIf
                
              Case "cap":
                If ability_cap_idx >= #MAX_NUMBER_OF_ABILITY_CAPS
                  error_message("load_abilities_db(): too many ability caps (>" + Str(#MAX_NUMBER_OF_ABILITY_CAPS) + ") for a single ability in file " + Chr(34) + filename$ + Chr(34))
                EndIf
                ability_idx = 0
                divisor = 1
                bonus = 0
                multiplier = 1
                name$ = ""
                If ExamineXMLAttributes(*childnode)
                  While NextXMLAttribute(*childnode)
                    val2$ = XMLAttributeValue(*childnode)
                    Select XMLAttributeName(*childnode)
                    
                      Case "ability":
                        ability_idx = Val(val2$)
                        If ability_idx < 1 Or ability_idx >= #MAX_NUMBER_OF_ABILITIES
                          error_message("load_abilities_db(): wrong ability ID " + Chr(34) + val2$ + Chr(34) + " in cap tag in file " + Chr(34) + filename$ + Chr(34))
                        EndIf
                        
                      Case "name":
                        name$ = val2$
                        
                      Case "bonus":
                        bonus = Val(val2$)
                        
                      Case "divisor":
                        divisor = Val(val2$)
                        
                      Case "multiplier":
                        multiplier = Val(val2$)
                        
                      Default:
                        error_message("load_abilities_db(): wrong attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in cap tag in file " + Chr(34) + filename$ + Chr(34))
             
                    EndSelect
                  Wend
                EndIf
                If ability_idx > 0 Or name$ <> ""
                  ability_db(id)\ability_cap[ability_cap_idx]\ability = ability_idx
                  ability_db(id)\ability_cap[ability_cap_idx]\name$ = name$
                  ability_db(id)\ability_cap[ability_cap_idx]\bonus = bonus
                  ability_db(id)\ability_cap[ability_cap_idx]\multiplier = multiplier
                  ability_db(id)\ability_cap[ability_cap_idx]\divisor = divisor
                  ability_cap_idx = ability_cap_idx + 1
                EndIf
                
              Case "requirement":
                If ability_req_idx >= #MAX_NUMBER_OF_ABILITY_CAPS
                  error_message("load_abilities_db(): too many ability caps (>" + Str(#MAX_NUMBER_OF_ABILITY_CAPS) + ") for a single ability in ability file " + Chr(34) + filename$ + Chr(34))
                EndIf
                attribute_idx = 0
                name$ = ""
                req_val = 0
                If ExamineXMLAttributes(*childnode)
                  While NextXMLAttribute(*childnode)
                    val2$ = XMLAttributeValue(*childnode)
                    Select XMLAttributeName(*childnode)
                    
                      Case "attribute":
                        attribute_idx = Val(val2$)
                        If attribute_idx < 1 Or attribute_idx >= #MAX_NUMBER_OF_ABILITIES
                          error_message("load_abilities_db(): wrong ability ID " + Chr(34) + val2$ + Chr(34) + " in requirement tag in file " + Chr(34) + filename$ + Chr(34))
                        EndIf
                        
                      Case "name":
                        name$ = val2$
                        
                      Case "value":
                        req_val = Val(val2$)
                        
                      Default:
                        error_message("load_abilities_db(): wrong attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in requirement tag in file " + Chr(34) + filename$ + Chr(34))
                         
                    EndSelect
                  Wend  
                EndIf
                If attribute_idx > 0 Or name$ <> ""
                  ability_db(id)\ability_requirement[ability_req_idx]\attribute = attribute_idx
                  ability_db(id)\ability_requirement[ability_req_idx]\name$ = name$
                  ability_db(id)\ability_requirement[ability_req_idx]\value = req_val
                  ability_req_idx = ability_req_idx + 1
                EndIf
                
              Case "display":
                With new_ability_display
                  \type = 0
                  \start_value = 0
                  \end_value = 0
                  \message$ = ""
                  \message2$ = ""
                  \color = $ffffff
                  \expanded_value_display = 0
                EndWith
                If ExamineXMLAttributes(*childnode)
                  While NextXMLAttribute(*childnode)
                    val2$ = XMLAttributeValue(*childnode)
                    Select XMLAttributeName(*childnode)
                    
                      Case "type":
                        Select val2$

                          Case "main screen status panel":
                            new_ability_display\type = 1                        
                          
                          Case "character info":
                            new_ability_display\type = 2
                            
                          Default:
                            error_message("load_abilities_db(): unknown display type " + Chr(34) + val2$ + Chr(34) + " in ability display tag in ability xml file " + Chr(34) + filename$ + Chr(34))
                            
                        EndSelect
                    
                      Case "start_value"
                        new_ability_display\start_value = Val(val2$)
                        
                      Case "end_value":
                        new_ability_display\end_value = Val(val2$)
                        
                      Case "message":
                        new_ability_display\message$ = val2$
                        
                      Case "message2":
                        new_ability_display\message2$ = val2$
                        
                      Case "color":
                        new_ability_display\color = Val(val2$)
                        
                      Case "language":
                        display_language$ = val2$
                        
                      Case "expanded_value_display":
                        If val2$ = "yes"
                          new_ability_display\expanded_value_display = 1
                        EndIf
                        
                      Default:
                        error_message("load_abilities_db(): unknown attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in ability display tag in abilities xml file " + Chr(34) + filename$ + Chr(34))
                        
                    EndSelect
                  Wend
                  If new_ability_display\message$ <> "" And display_language$ <> "" And display_language$ = preferences\language$
                    If display_idx >= #MAX_NUMBER_OF_ABILITY_DISPLAYS
                      error_message("load_abilities_db(): too many display entries (>" + Str(#MAX_NUMBER_OF_ABILITY_DISPLAYS) + ") for a single ability in ability file " + Chr(34) + filename$ + Chr(34))
                    EndIf
                    With ability_db(id)\display[display_idx]
                      \type = new_ability_display\type
                      \start_value = new_ability_display\start_value
                      \end_value = new_ability_display\end_value
                      \message$ = new_ability_display\message$
                      \message2$ = new_ability_display\message2$
                      \color = new_ability_display\color
                      \expanded_value_display = new_ability_display\expanded_value_display
                    EndWith
                    display_idx = display_idx + 1
                  EndIf
                EndIf
                
              Case "name":
                If ExamineXMLAttributes(*childnode)
                  While NextXMLAttribute(*childnode)
                    val2$ = XMLAttributeValue(*childnode)
                    Select XMLAttributeName(*childnode)
                    
                      Case "language":
                        If val2$ = preferences\language$
                          ability_db(id)\name_display$ = GetXMLNodeText(*childnode)
                        EndIf
                      
                      Default:
                        error_message("load_abilities_db(): unknown attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in name tag in ability xml file " + Chr(34) + filename$ + Chr(34))
                        
                    EndSelect
                  Wend
                EndIf
                
              Case "description":
                If ExamineXMLAttributes(*childnode)
                  While NextXMLAttribute(*childnode)
                    val2$ = XMLAttributeValue(*childnode)
                    Select XMLAttributeName(*childnode)
                    
                      Case "language":
                        If val2$ = preferences\language$
                          ability_db(id)\description$ = GetXMLNodeText(*childnode)
                        EndIf
                      
                      Default:
                        error_message("load_abilities_db(): unknown attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in description tag in ability xml file " + Chr(34) + filename$ + Chr(34))
                        
                    EndSelect
                  Wend
                EndIf
                
              Case "game_ends_message"
                If ExamineXMLAttributes(*childnode)
                  While NextXMLAttribute(*childnode)
                    val2$ = XMLAttributeValue(*childnode)
                    Select XMLAttributeName(*childnode)
                    
                      Case "language":
                        If val2$ = preferences\language$
                          ability_db(id)\game_ends_message$ = GetXMLNodeText(*childnode)
                        EndIf
                      
                      Default:
                        error_message("load_abilities_db(): unknown attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in game_ends_message tag in ability xml file " + Chr(34) + filename$ + Chr(34))
                        
                    EndSelect
                  Wend
                EndIf
                
              Case "adjustment":
                With new_adjustment
                  \attribute = 0
                  \attribute_name$ = ""
                  \value = 0
                  \percentage = 100
                  \percentage_attribute_multiplier = 0
                EndWith
                If ExamineXMLAttributes(*childnode)
                  While NextXMLAttribute(*childnode)
                    val2$ = XMLAttributeValue(*childnode)
                    Select XMLAttributeName(*childnode)
                    
                      Case "attribute":
                        new_adjustment\attribute = Val(val2$)
                        
                      Case "attribute_name":
                        new_adjustment\attribute_name$ = val2$
                        
                      Case "value":
                        new_adjustment\value = Val(val2$)
                        
                      Case "percentage":
                        new_adjustment\percentage = Val(val2$)
                        
                      Case "percentage_attribute_multiplier":
                        new_adjustment\percentage_attribute_multiplier = Val(val2$)
                      
                      Case "percentage_bonus":
                        new_adjustment\percentage_bonus = Val(val2$)
                      
                      Default:
                        error_message("load_abilities_db(): unknown attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in adjustment tag in ability xml file " + Chr(34) + filename$ + Chr(34))
                        
                    EndSelect
                  Wend
                  If adjustment_idx >= #MAX_NUMBER_OF_ABILITY_ADJUSTMENTS
                    error_message("load_abilities_db(): too many adjustments for one ability in ability xml file " + Chr(34) + filename$ + Chr(34))
                  EndIf
                  With ability_db(id)\adjustment[adjustment_idx]
                    \attribute = new_adjustment\attribute
                    \attribute_name$ = new_adjustment\attribute_name$
                    \value = new_adjustment\value
                    \percentage = new_adjustment\percentage
                    \percentage_attribute_multiplier = new_adjustment\percentage_attribute_multiplier
                    \percentage_bonus = new_adjustment\percentage_bonus
                  EndWith
                  adjustment_idx = adjustment_idx + 1
                EndIf

              Case "starting_equipment":
                starting_equipment_item_id = 0
                starting_equipment_item_name$ = ""
                starting_equipment_item_amount = 1
                If ExamineXMLAttributes(*childnode)
                  While NextXMLAttribute(*childnode)
                    val2$ = XMLAttributeValue(*childnode)
                    Select XMLAttributeName(*childnode)
                    
                      Case "item":
                        starting_equipment_item_id = Val(val2$)
                        
                      Case "item_name":
                        starting_equipment_item_name$ = val2$
                        
                      Case "amount":
                        starting_equipment_item_amount = Val(val2$)
                      
                      Default:
                        error_message("load_abilities_db(): unknown attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in starting_equipment tag in ability xml file " + Chr(34) + filename$ + Chr(34))
                        
                    EndSelect
                  Wend
                  If starting_equipment_idx >= #MAX_NUMBER_OF_ABILITY_STARTING_EQUIPMENT
                    error_message("load_abilities_db(): too many starting equipment for one ability (" + Chr(34) + ability_db(id)\name$ + Chr(34) + ") in ability xml file " + Chr(34) + filename$ + Chr(34)) 
                  EndIf
                  If starting_equipment_item_id > 0 Or starting_equipment_item_name$ <> ""
                    With ability_db(id)\starting_equipment[starting_equipment_idx]
                      \item = starting_equipment_item_id
                      \item_name$ = starting_equipment_item_name$
                      \amount = starting_equipment_item_amount
                    EndWith
                    starting_equipment_idx = starting_equipment_idx + 1
                  EndIf
                EndIf
              
              Default:
                error_message("load_abilities_db(): wrong tag " + Chr(34) + GetXMLNodeName(*childnode) + Chr(34) + " in file " + Chr(34) + filename$ + Chr(34))

            EndSelect
            *childnode = NextXMLNode(*childnode)
          Wend
          
        Default:
          error_message("load_abilities_db(): wrong tag " + Chr(34) + GetXMLNodeName(*node) + Chr(34) + " in file " + Chr(34) + filename$ + Chr(34))
          
      EndSelect
      *node = NextXMLNode(*node)
    Wend
  EndIf
  FreeXML(0)
  ;ability_db_resolve_names()
EndProcedure


; saves character data
Procedure save_character(*char.char_struct, filename$ = "savegame\character.xml")
  Protected i.w, *mainnode, *node
  If CreateXML(0) = 0
    error_message("save_character(): could not create xml structure in memory!")
  EndIf
  *mainnode = CreateXMLNode(RootXMLNode(0),"")
  SetXMLNodeName(*mainnode, "character")
  SetXMLAttribute(*mainnode, "Lost_Labyrinth_version", version_number$)
  SetXMLAttribute(*mainnode, "name", *char\name$)
  SetXMLAttribute(*mainnode, "xpos", Str(*char\xpos))
  SetXMLAttribute(*mainnode, "ypos", Str(*char\ypos))
  SetXMLAttribute(*mainnode, "facing", Str(*char\facing))
  SetXMLAttribute(*mainnode, "frame", Str(*char\frame))
  SetXMLAttribute(*mainnode, "map_filename", GetFilePart(*char\map_filename$))
  SetXMLAttribute(*mainnode, "inventory_cursor_x", Str(*char\inventory_cursor_x))
  SetXMLAttribute(*mainnode, "inventory_cursor_y", Str(*char\inventory_cursor_y))
  For i=1 To #MAX_NUMBER_OF_ABILITIES - 1
    If ability_db(i)\name$ <> ""
      *node = CreateXMLNode(*mainnode,"")
      SetXMLNodeName(*node, "ability")
      SetXMLAttribute(*node, "id", Str(i))
      If *char\ability[i]\ability_value <> 0
        SetXMLAttribute(*node, "ability_value", Str(*char\ability[i]\ability_value))
      EndIf
      If *char\ability[i]\attribute_max_value <> 0
        SetXMLAttribute(*node, "attribute_max_value", Str(*char\ability[i]\attribute_max_value))
      EndIf
      If *char\ability[i]\attribute_current_value <> 0
        SetXMLAttribute(*node, "attribute_current_value", Str(*char\ability[i]\attribute_current_value))
      EndIf
      If *char\ability[i]\power_adjustment <> 0
        SetXMLAttribute(*node, "power_adjustment", Str(*char\ability[i]\power_adjustment))
      EndIf
      If *char\ability[i]\adjustment_duration <> 0
        SetXMLAttribute(*node, "adjustment_duration", Str(*char\ability[i]\adjustment_duration))
      EndIf
      If *char\ability[i]\adjustment_name$ <> ""
        SetXMLAttribute(*node, "adjustment_name", *char\ability[i]\adjustment_name$)
      EndIf
      If *char\ability[i]\adjustment_power_id <> 0
        SetXMLAttribute(*node, "adjustment_power_id", Str(*char\ability[i]\adjustment_power_id))
      EndIf
      If *char\ability[i]\adjustment_item_id <> 0
        SetXMLAttribute(*node, "adjustment_item_id", Str(*char\ability[i]\adjustment_item_id))
      EndIf
      If *char\ability[i]\item_bonus <> 0
        SetXMLAttribute(*node, "item_bonus", Str(*char\ability[i]\item_bonus))
      EndIf
      If *char\ability[i]\activated = 1
        SetXMLAttribute(*node, "activated", "yes")
      EndIf
      If *char\ability[i]\adjustment_other <> 0
        SetXMLAttribute(*node, "adjustment_other", Str(*char\ability[i]\adjustment_other))
      EndIf
      If *char\ability[i]\adjustment_percentage <> 100
        SetXMLAttribute(*node, "adjustment_percentage", Str(*char\ability[i]\adjustment_percentage))
      EndIf
    EndIf
  Next
  For i=0 To #MAX_NUMBER_OF_POWERS - 1
    If *char\power[i]\cooldown > 0
      *node = CreateXMLNode(*mainnode,"")
      SetXMLNodeName(*node, "power")
      SetXMLAttribute(*node, "id", Str(i))
      SetXMLAttribute(*node, "cooldown", Str(*char\power[i]\cooldown))
    EndIf
  Next
  ForEach inventory()
    *node = CreateXMLNode(*mainnode,"")
    SetXMLNodeName(*node, "item")
    SetXMLAttribute(*node, "type", Str(inventory()\type))
    SetXMLAttribute(*node, "amount", Str(inventory()\amount))
    If item_db(inventory()\type)\fuel > 0
      SetXMLAttribute(*node, "fuel", Str(inventory()\fuel))
    EndIf
    If inventory()\equipped = 1
      SetXMLAttribute(*node, "equipped", "yes")
    EndIf
    If inventory()\selected = 1
      SetXMLAttribute(*node, "selected", "yes")
    EndIf
    If inventory()\magic_bonus > 0
      SetXMLAttribute(*node, "magic_bonus", Str(inventory()\magic_bonus))
    EndIf
  Next
  For i = 0 To #MAX_NUMBER_OF_ITEMS - 1
    If *char\item_identification[i]\identified = 1
      *node = CreateXMLNode(*mainnode,"")
      SetXMLNodeName(*node, "item_identification")
      SetXMLAttribute(*node, "id", Str(i))
      SetXMLAttribute(*node, "identified", "yes")
    EndIf
    If compare_string_lists(item_db(i)\class$, "potion") = 1
      *node = CreateXMLNode(*mainnode,"")
      SetXMLNodeName(*node, "item_tile")
      SetXMLAttribute(*node, "id", Str(i))
      SetXMLAttribute(*node, "tile", Str(item_db(i)\tile))
    EndIf
  Next
  If SaveXML(0, filename$) = 0
    error_message("save_character(): could not save character data to file " + Chr(34) + filename$ + Chr(34))
  EndIf  
  FreeXML(0)
EndProcedure


; load character data
Procedure load_character(*char.char_struct, filename$ = "savegame\character.xml")
  Protected val$, id.w, ability_value.w, attribute_max_value.w, attribute_current_value.w, cooldown.w
  Protected power_id.w, duration.w, power_adjustment.w, adjustment_duration.w, adjustment_name$
  Protected adjustment_power_id.w, item_type.w, item_amount.w, item_equipped.b, item_selected.b
  Protected item_bonus.w, item_fuel.w, item_magic_bonus.w, ability_activated.b
  Protected adjustment_other.w, adjustment_percentage.w, item_identification_identified.b
  Protected ability.ability_struct, *mainnode, *node, item_identification_id.w
  Protected item_tile_id.w, item_tile_tile.w
  init_character(*char)
  ClearList(inventory())
  If CreateXML(0) = 0
    error_message("load_character(): could not create xml structure in memory!")
  EndIf
  If LoadXML(0, filename$) = 0
    error_message("load_character(): could not open character xml file: " + Chr(34) + filename$ + Chr(34))
  EndIf
  If XMLStatus(0) <> 0
    error_message("load_character(): error in xml structure of character file " + Chr(34) + filename$ + Chr(34) + ": " + XMLError(0))
  EndIf
  *mainnode = MainXMLNode(0)
  If ExamineXMLAttributes(*mainnode)
    While NextXMLAttribute(*mainnode)
      val$ = XMLAttributeValue(*mainnode)
      Select XMLAttributeName(*mainnode)
      
        Case "Lost_Labyrinth_version":
      
        Case "name":
          *char\name$ = val$
          
        Case "xpos":
          If Val(val$) < 0 Or Val(val$) > #MAP_DIMENSION_X-1
            error_message("load_character(): wrong xpos attribute " + Chr(34) + val$ + Chr(34) + " in character file " + Chr(34) + filename$ + Chr(34))
          EndIf
          *char\xpos = Val(val$)
          
        Case "ypos":
          If Val(val$) < 0 Or Val(val$) > #MAP_DIMENSION_Y-1
            error_message("load_character(): wrong ypos attribute " + Chr(34) + val$ + Chr(34) + " in character file " + Chr(34) + filename$ + Chr(34))
          EndIf        
          *char\ypos = Val(val$)
          
        Case "facing":
          If Val(val$)<0 Or Val(val$) > 3
            error_message("load_character(): wrong facing attribute " + Chr(34) + val$ + Chr(34) + " in character file " + Chr(34) + filename$ + Chr(34))          
          EndIf
          *char\facing = Val(val$)
          
        Case "frame":
          If Val(val$) <> 0 And Val(val$) <> 1
            error_message("load_character(): wrong frame attribute " + Chr(34) + val$ + Chr(34) + " in character file " + Chr(34) + filename$ + Chr(34))  
          EndIf
          *char\frame = Val(val$)
          
        Case "map_filename":
          *char\map_filename$ = GetFilePart(val$)
          
        Case "inventory_cursor_x":
          *char\inventory_cursor_x = Val(val$)
          
        Case "inventory_cursor_y":
          *char\inventory_cursor_y = Val(val$)
          
        Default:
          error_message("load_character(): unknown attribute " + Chr(34) + XMLAttributeName(*mainnode) + Chr(34) + " in root node in file " + Chr(34) + filename$ + Chr(34))
      
      EndSelect
    Wend
  EndIf
  If *mainnode
    *node = ChildXMLNode(*mainnode)
    While *node <> 0
      
      Select GetXMLNodeName(*node)
      
        Case "ability":
          id = 0
          With ability
            \ability_value = 0
            \attribute_max_value = 0
            \attribute_current_value = 0
            \power_adjustment = 0
            \adjustment_duration = 0
            \adjustment_name$ = ""
            \adjustment_power_id = 0
            \adjustment_item_id = 0
            \item_bonus = 0
            \activated = 0
            \adjustment_other = 0
            \adjustment_percentage = 100
          EndWith
          If ExamineXMLAttributes(*node)
            While NextXMLAttribute(*node)
              val$ = XMLAttributeValue(*node)
              Select XMLAttributeName(*node)
              
                Case "id":
                  id = Val(val$)
                  If id < 1 Or id > #MAX_NUMBER_OF_ABILITIES-1
                    error_message("load_character(): wrong id attribute " + Chr(34) + val$ + Chr(34) + " in ability tag in file " + Chr(34) + filename$ + Chr(34))
                  EndIf
                  
                Case "ability_value":
                  ability\ability_value = Val(val$)
                  
                Case "attribute_max_value":
                  ability\attribute_max_value = Val(val$)
                  
                Case "attribute_current_value":
                  ability\attribute_current_value = Val(val$)
                  
                Case "power_adjustment":
                  ability\power_adjustment = Val(val$)
                  
                Case "adjustment_duration":
                  ability\adjustment_duration = Val(val$)
                  
                Case "adjustment_name":
                  ability\adjustment_name$ = val$
                  
                Case "adjustment_power_id":
                  ability\adjustment_power_id = Val(val$)
                  
                Case "adjustment_item_id":
                  ability\adjustment_item_id = Val(val$)
                  
                Case "item_bonus":
                  ability\item_bonus = Val(val$)
                  
                Case "activated":
                  If val$ = "yes"
                    ability\activated = 1
                  EndIf
                  
                Case "adjustment_other":
                  ability\adjustment_other = Val(val$)
                  
                Case "adjustment_percentage":
                  ability\adjustment_percentage = Val(val$)
                
                Default:
                  error_message("load_character(): unknown attribute " + Chr(34) + XMLAttributeName(*node) + Chr(34) + " in ability tag in file " + Chr(34) + filename$ + Chr(34))
                   
              EndSelect
            Wend
            If id > 0
              With *char\ability[id]
                \ability_value = ability\ability_value
                \attribute_max_value = ability\attribute_max_value
                \attribute_current_value = ability\attribute_current_value
                \power_adjustment = ability\power_adjustment
                \adjustment_duration = ability\adjustment_duration
                \adjustment_name$ = ability\adjustment_name$
                \adjustment_power_id = ability\adjustment_power_id
                \adjustment_item_id = ability\adjustment_item_id
                \item_bonus = ability\item_bonus
                \activated = ability\activated
                \adjustment_other = ability\adjustment_other
                \adjustment_percentage = ability\adjustment_percentage
              EndWith
            EndIf            
          EndIf
          
        Case "power":
          power_id = 0
          cooldown = 0
          If ExamineXMLAttributes(*node)
            While NextXMLAttribute(*node)
              val$ = XMLAttributeValue(*node)
              Select XMLAttributeName(*node)
                Case "id" : power_id = Val(val$)
                Case "cooldown" : cooldown = Val(val$)
                Case "duration" : duration = Val(val$)
                Default: error_message("load_character(): unknown attribute " + Chr(34) + XMLAttributeName(*node) + Chr(34) + " in power_cooldown tag in character xml file " + Chr(34) + filename$ + Chr(34))
              EndSelect
            Wend
            If power_id > 0
              *char\power[power_id]\cooldown = cooldown
            EndIf
          EndIf
          
        Case "item":
          item_type = 0
          item_amount = 0
          item_equipped = 0
          item_selected = 0
          item_fuel = 0
          item_magic_bonus = 0
          If ExamineXMLAttributes(*node)
            While NextXMLAttribute(*node)
              val$ = XMLAttributeValue(*node)
              Select XMLAttributeName(*node)
              
                Case "type":
                  item_type = Val(val$)
                
                Case "amount":
                  item_amount = Val(val$)
                
                Case "equipped":
                  If val$ = "yes"
                    item_equipped = 1
                  EndIf
                  
                Case "selected":
                  If val$ = "yes"
                    item_selected = 1
                  EndIf
                  
                Case "fuel":
                  item_fuel = Val(val$)
                  
                Case "magic_bonus":
                  item_magic_bonus = Val(val$)
                  
                Default:
                  error_message("load_character(): unknown attribute " + Chr(34) + XMLAttributeName(*node) + Chr(34) + " in item tag in character xml file " + Chr(34) + filename$ + Chr(34))
              
              EndSelect
            Wend
            If item_type > 0
              AddElement(inventory())
              With inventory()
                \type = item_type
                \amount = item_amount
                \equipped = item_equipped
                \selected = item_selected
                \fuel = item_fuel
                \magic_bonus = item_magic_bonus
              EndWith
            EndIf
          EndIf
          
        Case "item_identification":
          item_identification_id = 0
          item_identification_identified = 0
          If ExamineXMLAttributes(*node)
            While NextXMLAttribute(*node)
              val$ = XMLAttributeValue(*node)
              Select XMLAttributeName(*node)
                
                Case "id":
                  item_identification_id = Val(val$)
                  
                Case "identified":
                  If val$ = "yes"
                    item_identification_identified = 1
                  EndIf
                
                Default:
                  error_message("load_character(): unknown attribute " + Chr(34) + XMLAttributeName(*node) + Chr(34) + " in item identification tag in character xml file " + Chr(34) + filename$ + Chr(34))
                  
              EndSelect
            Wend
            If item_identification_id > 0 And item_identification_id < #MAX_NUMBER_OF_ITEMS
              *char\item_identification[item_identification_id]\identified = item_identification_identified
            EndIf
          EndIf

        Case "item_tile":
          item_tile_id = 0
          item_tile_tile = 0
          If ExamineXMLAttributes(*node)
            While NextXMLAttribute(*node)
              val$ = XMLAttributeValue(*node)
              Select XMLAttributeName(*node)
                
                Case "id":
                  item_tile_id = Val(val$)
                  
                Case "tile":
                  item_tile_tile = Val(val$)
                
                Default:
                  error_message("load_character(): unknown attribute " + Chr(34) + XMLAttributeName(*node) + Chr(34) + " in item tile tag in character xml file " + Chr(34) + filename$ + Chr(34))
                  
              EndSelect
            Wend
            If item_tile_id > 0 And item_tile_id < #MAX_NUMBER_OF_ITEMS
              item_db(item_tile_id)\tile = item_tile_tile
            EndIf
          EndIf
          
        Default:
          error_message("load_character(): unknown tag " + Chr(34) + GetXMLNodeName(*node) + Chr(34) + " in file " + Chr(34) + filename$ + Chr(34))
          
      EndSelect
      
      *node = NextXMLNode(*node)
    Wend
  EndIf 
  FreeXML(0)
EndProcedure


; returns cap for attribute
Procedure.w attribute_cap(id.w)
  Protected rc.w, i.w, cap.w, ability.w, multiplier.w, divisor.w, bonus.w
  If id < 1 Or id >= #MAX_NUMBER_OF_ABILITIES
    error_message("attribute_cap(): wrong id: " + Str(id))
  EndIf
  rc = -1
  For i=0 To #MAX_NUMBER_OF_ABILITY_CAPS-1
    ability = ability_db(id)\ability_cap[i]\ability
    divisor = ability_db(id)\ability_cap[i]\divisor
    multiplier = ability_db(id)\ability_cap[i]\multiplier
    bonus = ability_db(id)\ability_cap[i]\bonus
    If ability > 0
      cap = current_character\ability[ability]\attribute_max_value
      If multiplier > 1
        cap = current_character\ability[ability]\attribute_max_value * multiplier
      EndIf
      If divisor > 1
        cap = Int(current_character\ability[ability]\attribute_max_value / divisor)
      EndIf
      cap = cap + bonus
      If cap < rc Or rc = -1
        rc = cap
      EndIf
    EndIf
  Next
  ProcedureReturn rc
EndProcedure


; returns max value for attribute; includes cap
Procedure.w attribute_max_val(id.w, include_attribute_cap.b = 1, include_power_adjustment.b = 1, include_item_bonus_adjustment.b = 1)
  Protected rc.w, cap.w
  If id < 1 Or id > #MAX_NUMBER_OF_ABILITIES - 1
    error_message("attribute_max_val(): wrong id: " + Str(id))
  EndIf    
  rc = current_character\ability[id]\attribute_max_value
  If include_attribute_cap = 1
    cap = attribute_cap(id)
    If cap <> -1
      rc = min(rc, attribute_cap(id))
    EndIf
  EndIf
  If include_power_adjustment = 1
    rc = rc + current_character\ability[id]\power_adjustment
  EndIf
  If include_item_bonus_adjustment = 1
    rc = rc + current_character\ability[id]\item_bonus
  EndIf
  rc = rc + current_character\ability[id]\adjustment_other
  If current_character\ability[id]\adjustment_percentage <> 100
    rc = Int(rc * (current_character\ability[id]\adjustment_percentage / 100))
  EndIf  
  ProcedureReturn rc
EndProcedure


; returns current value for attribute; includes cap
Procedure.w attribute_current_val(id.w, include_attribute_cap.b = 1, include_power_adjustment.b = 1, include_item_bonus_adjustment.b = 1)
  Protected rc.w, cap.w, i.w
  If id < 1 Or id > #MAX_NUMBER_OF_ABILITIES - 1
    error_message("attribute_current_val(): wrong id: " + Str(id))
  EndIf
  rc = current_character\ability[id]\attribute_current_value
  If include_attribute_cap = 1 And ability_db(id)\change_per_move = 0 And ability_db(i)\movement = 0
    cap = attribute_cap(id)
    If cap <> -1
      rc = min(rc, attribute_cap(id))
    EndIf
  EndIf
  If include_power_adjustment = 1 And ability_db(id)\change_per_move = 0 And ability_db(i)\movement = 0
    rc = rc + current_character\ability[id]\power_adjustment
  EndIf
  If include_item_bonus_adjustment = 1 And ability_db(id)\change_per_move = 0 And ability_db(i)\movement = 0
    rc = rc + current_character\ability[id]\item_bonus
  EndIf
  If ability_db(id)\depletable = 0 And ability_db(id)\change_per_move = 0 And ability_db(i)\movement = 0
    rc = rc + current_character\ability[id]\adjustment_other
    If current_character\ability[id]\adjustment_percentage <> 100
      rc = Int((rc * current_character\ability[id]\adjustment_percentage) / 100)
    EndIf
  EndIf
  ProcedureReturn rc
EndProcedure


; returns expanded display for an ability
Procedure.s ability_expanded_value_display(id.w)
  Protected rc$ = "", i.w, val1.w, val2.w, attribute_current_val.w
  If id < 1 Or id > #MAX_NUMBER_OF_ABILITIES - 1
    error_message("ability_value_display(): wrong id: " + Str(id))
  EndIf
  attribute_current_val = attribute_current_val(id)
  If ability_db(id)\displayed_as_bonus
    If current_character\ability[id]\attribute_current_value < 0
      rc$ = "-"
    Else
      rc$ = "+"
    EndIf
  EndIf
  If ability_db(id)\randomizer_ability > 0
    val1 = attribute_current_val
    val2 = attribute_current_val(ability_db(id)\randomizer_ability)
    rc$ = rc$ + Str(val1) + " - " + Str(val1 + val2)
  Else
    rc$ = rc$ + Str(attribute_current_val(id))
    If ability_db(id)\depletable = 1
      rc$ = rc$ + " / " + Str(attribute_max_val(id))
    EndIf
  EndIf
  If ability_db(id)\percentage = 1
    rc$ = rc$ + "%"
  EndIf
  ProcedureReturn rc$
EndProcedure


; returns ability value for display
Procedure.s ability_value_display(id.w)
  Protected rc$ = "", i.w, val1.w, val2.w, attribute_current_val.w
  rc$ = ability_expanded_value_display(id)
  For i=0 To #MAX_NUMBER_OF_ABILITY_DISPLAYS - 1
    If ability_db(id)\display[i]\message$ <> ""
      If attribute_current_val >= ability_db(id)\display[i]\start_value And attribute_current_val <= ability_db(id)\display[i]\end_value
        rc$ = ReplaceString(ability_db(id)\display[i]\message$, "[value]", Str(attribute_current_val), #PB_String_NoCase)
      EndIf
    EndIf
  Next
  ProcedureReturn rc$
EndProcedure


; returns bonus text for ability
Procedure.s ability_bonus_text(id.w)
  Protected text$ = "", attribute.w, bonus.w, i.b, displayed.b
  For i=0 To #MAX_NUMBER_OF_ATTRIBUTE_BONI - 1
    attribute = ability_db(id)\attribute_bonus[i]\attribute
    bonus = ability_db(id)\attribute_bonus[i]\bonus
    displayed = ability_db(id)\attribute_bonus[i]\displayed
    If attribute > 0 And displayed = 1
      If text$ <> ""
        text$ = text$ + "; "
      EndIf
      text$ = text$ + ability_db(attribute)\name_display$ + "+" + Str(bonus)
      If ability_db(attribute)\percentage = 1
        text$ = text$ + "%"
      EndIf
    EndIf
  Next
  ProcedureReturn text$
EndProcedure


; returns 1 if ability + bonus is larger than cap, else 0
Procedure.b ability_capped(id.w, bonus.w=0)
  Protected rc.b = 0, cap.w
  If id < 1 Or id >= #MAX_NUMBER_OF_ABILITIES
    error_message("ability_capped(): wrong id: " + Str(id))
  EndIf
  cap = attribute_cap(id)
  If cap > -1
    If current_character\ability[id]\attribute_max_value + bonus >= cap
      rc = 1
    EndIf
  EndIf
  ProcedureReturn rc
EndProcedure


; returns 1 if ability is available to character, else 0
Procedure.b ability_available(id.w)
  Protected rc.b, i.w, attribute.w, req_val.w
  If id < 1 Or id >= #MAX_NUMBER_OF_ABILITIES
    error_message("ability_available(): wrong id: " + Str(id))
  EndIf  
  rc = 1
  For i=0 To #MAX_NUMBER_OF_ABILITY_REQUIREMENTS-1
    attribute = ability_db(id)\ability_requirement[i]\attribute
    req_val = ability_db(id)\ability_requirement[i]\value
    If attribute > 0
      If current_character\ability[attribute]\attribute_max_value < req_val
        rc = 0
      EndIf
    EndIf
  Next
  ProcedureReturn rc
EndProcedure


; character info screen
Procedure character_info_screen()
  Protected i.w = 1, j.w, x.b, y.b, row.b, column.b, text$, text2$, column_width.w=160, attribute_current_val.w
  Protected NewList tile_list.tile_list_struct(), display.b = 0
  draw_standard_frame(message_list$(#MESSAGE_CHARACTER_INFO), message_list$(#MESSAGE_PRESS_RETURN_TO_LEAVE)) 
  StartDrawing(ScreenOutput())
  row = 0
  column = 0
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
        DrawText(56 + column*column_width, 52 + row*32, text$, ability_db(i)\display[j]\color, 0)
        If ability_db(i)\display[j]\message2$ <> ""
          text$ = ReplaceString(ability_db(i)\display[j]\message2$, "[value]", Str(attribute_current_val))
          If ability_db(i)\display[j]\expanded_value_display = 1
            text$ = ReplaceString(ability_db(i)\display[j]\message2$, "[value]", ability_expanded_value_display(i))
          EndIf          
          DrawText(56 + column*column_width, 68 + row*32, text$, ability_db(i)\display[j]\color, 0)
        EndIf
        AddElement(tile_list())
        With tile_list()
          \x = 20 + (column * column_width)
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
  StopDrawing()
  ForEach tile_list()
    clip_ability_tile_sprite(tile_list()\tile)
    DisplaySprite(#SPRITE_ABILITIES, tile_list()\x, tile_list()\y)  
  Next
  ClearList(tile_list())  
EndProcedure


; returns number of entries in experience ability list
Procedure.w abilities_available_for_xp()
  Protected rc.w = 0, i.w = 0
  For i = 1 To #MAX_NUMBER_OF_ABILITIES - 1
    If ability_db(i)\name$ <> "" And ability_db(i)\xp = 1
      rc = rc + 1
    EndIf
  Next
  ProcedureReturn rc
EndProcedure


; "character gets experience" screen; returns ability ID of selected entry
Procedure.w experience_screen(selected_entry.w = 0, number_of_entries.w = 0, offset.w = 0, title$="You gain some experience!", selected_entry_color.l = $000050)
  Protected i.w = 0, j.w, k.w, row.b = 0, x.w, y.w, text$, column_width.w = 300, text_y.w
  Protected attribute.w, bonus.w, ability.w, multiplier.w, cap.w
  Protected rc.w = 0, displayed.b, req_val.w, bonus2.w, selected_ability_id.w
  Protected gain_power_tile_y.w = 0, frame.b = 0, divisor.w, bar_entry_height.f, bar_y.w
  Protected bar_height.w
  draw_standard_frame(title$)
  For i=3 To 28
    ClipSprite(#SPRITE_Frame, 0, frame * 16 + 16, 16, 16)
    DisplaySprite(#SPRITE_Frame, 320, i*16)
    frame = frame + 1
    If frame > 4
      frame = 0
    EndIf
  Next 
  If selected_entry - offset <= #EXPERIENCE_SCREEN_ABILITIES_ON_SCREEN
    StartDrawing(ScreenOutput())
    Box(20, #EXPERIENCE_SCREEN_ABILITIES_TOP_BORDER + (selected_entry-offset)*32, column_width-8, 32, selected_entry_color)
    StopDrawing()
  EndIf
  row = -offset
  For i=1 To #MAX_NUMBER_OF_ABILITIES - 1
    If ability_db(i)\name$ <> "" And ability_db(i)\xp = 1
      If row >= 0 And row <= #EXPERIENCE_SCREEN_ABILITIES_ON_SCREEN
        clip_ability_tile_sprite(ability_db(i)\tile)
        DisplayTransparentSprite(#SPRITE_ABILITIES, 20, #EXPERIENCE_SCREEN_ABILITIES_TOP_BORDER + row*32)
        If row = selected_entry - offset
          rc = i
          DisplaySprite(#SPRITE_ABILITIES, 338, 50)
        EndIf
      EndIf
      row = row + 1
    EndIf
  Next
  StartDrawing(ScreenOutput())
  row = -offset
  For i=1 To #MAX_NUMBER_OF_ABILITIES - 1
    If ability_db(i)\name$ <> "" And ability_db(i)\xp = 1
      If row >= 0 And row <= #EXPERIENCE_SCREEN_ABILITIES_ON_SCREEN
        text$ = ability_db(i)\name_display$
        If ability_available(i) = 0
          text$ = text$ + " (" + message_list$(#MESSAGE_NOT_AVAILABLE) + ")"
        Else
          If ability_capped(i) = 1
            text$ = text$ + " (" + message_list$(#MESSAGE_CAPPED) + ")"
          EndIf        
        EndIf
        text$ = shorten_text(text$, column_width-48)
        DrawingFont(FontID(#FONT_VERDANA_BOLD))
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawText(#EXPERIENCE_SCREEN_ABILITIES_LEFT_BORDER, #EXPERIENCE_SCREEN_ABILITIES_TOP_BORDER + row*32, text$, ability_db(i)\color, 0)
        If row = selected_entry - offset
          DrawText(372, 58, ability_db(i)\name_display$, ability_db(i)\color, 0)
        EndIf
        DrawingFont(FontID(#FONT_VERDANA))
        text$ = shorten_text(ability_bonus_text(i), column_width - 48)
        DrawText(#EXPERIENCE_SCREEN_ABILITIES_LEFT_BORDER, #EXPERIENCE_SCREEN_ABILITIES_TOP_BORDER + 16 + row*32, text$, ability_db(i)\color, 0)
        If row = selected_entry - offset
          text_y = 82
          bonus2 = 0
          selected_ability_id = i
          For j = 0 To #MAX_NUMBER_OF_ATTRIBUTE_BONI - 1
            attribute = ability_db(i)\attribute_bonus[j]\attribute
            bonus = ability_db(i)\attribute_bonus[j]\bonus
            If attribute = i
              bonus2 = bonus
            EndIf
            displayed = ability_db(i)\attribute_bonus[j]\displayed
            If attribute > 0 And displayed = 1
              text$ = ability_db(attribute)\name_display$ + "+" + Str(bonus)
              If ability_db(attribute)\percentage = 1
                text$ = text$ + "%"
              EndIf
              text$ = text$ + " (" + message_list$(#MESSAGE_CURRENT_VALUE) + ": " + Str(current_character\ability[attribute]\attribute_max_value) + ")"
              DrawText(340, text_y, shorten_text(text$, 300), ability_db(attribute)\color, 0)
              text_y = text_y + 16
            EndIf
          Next
          For j = 0 To #MAX_NUMBER_OF_ABILITY_CAPS - 1
            ability = ability_db(i)\ability_cap[j]\ability
            divisor = ability_db(i)\ability_cap[j]\divisor
            bonus = ability_db(i)\ability_cap[j]\bonus
            multiplier = ability_db(i)\ability_cap[j]\multiplier
            cap = 0
            If ability > 0
              text$ = ability_db(ability)\name_display$
              cap = current_character\ability[ability]\attribute_max_value
              If multiplier > 1
                text$ = text$ + " x " + Str(multiplier)
                cap = current_character\ability[ability]\attribute_max_value * multiplier
              Else 
                If divisor > 1
                  text$ = text$ + " / " + Str(divisor)
                  cap = Int(current_character\ability[ability]\attribute_max_value / divisor)
                EndIf
              EndIf
              If bonus > 0
                text$ = text$ + " + " + Str(bonus)
                cap = cap + bonus
              EndIf
              text$ = message_list$(#MESSAGE_CAPPED_AT) + " " + Str(cap) + " (" + text$ + ")"
              DrawText(340, text_y, shorten_text(text$, 300), ability_db(ability)\color, 0)
              text_y = text_y + 16
            EndIf
          Next
          For j = 0 To #MAX_NUMBER_OF_ABILITY_REQUIREMENTS - 1
            attribute = ability_db(i)\ability_requirement[j]\attribute
            req_val = ability_db(i)\ability_requirement[j]\value
            If attribute > 0
              text$ = message_list$(#MESSAGE_REQUIRED) + ": " + ability_db(attribute)\name_display$ + " " + Str(req_val) + "+"
              DrawText(340, text_y, shorten_text(text$, 300), ability_db(attribute)\color, 0)
              text_y = text_y + 16
            EndIf
          Next
          If ability_db(i)\description$ <> ""
            text_y = text_y + wrap_text(340, text_y, ability_db(i)\description$, 240, 12, $ffffff) * 12
            text_y = text_y + 16
          EndIf
          For j = 0 To #MAX_NUMBER_OF_POWERS - 1
            If power_available(j) = 0 And power_available(j, i, bonus2) = 1
              If gain_power_tile_y = 0
                gain_power_tile_y = text_y
              EndIf
              DrawText(378, text_y, message_list$(#MESSAGE_NEW_POWER) + ":", RGB(255, 100, 0), 0)
              text_y = text_y + 12
              DrawText(378, text_y, shorten_text(power_db(j)\name$, 300), $ffffff, 0)
              text_y = text_y + 26
            EndIf
          Next
        EndIf
      EndIf
      row = row + 1
    EndIf
  Next
  ; draw scrollbar
  If number_of_entries > #EXPERIENCE_SCREEN_ABILITIES_ON_SCREEN
    Box(300, #EXPERIENCE_SCREEN_ABILITIES_TOP_BORDER, 14, 384, RGB(125, 75, 0))
    Box(301, #EXPERIENCE_SCREEN_ABILITIES_TOP_BORDER + 1, 12, 382, 0)
    bar_entry_height = 384 / max(1, number_of_entries - 1)
    bar_y = Int(offset * bar_entry_height) + #EXPERIENCE_SCREEN_ABILITIES_TOP_BORDER + 2
    bar_height = Int(bar_entry_height * #EXPERIENCE_SCREEN_ABILITIES_ON_SCREEN) - 2
    Box(302, bar_y, 10, bar_height, RGB(255, 150, 0))
    LineXY(302, bar_y, 302, bar_y + bar_height - 2, RGB(255,200,125))
    LineXY(303, bar_y, 311, bar_y, RGB(255, 200, 125))
    LineXY(311, bar_y, 311, bar_y + bar_height - 2, RGB(125, 75, 0))
    LineXY(303, bar_y + bar_height - 1, 311, bar_y + bar_height - 1, RGB(125, 75, 0))
  EndIf
  StopDrawing()
  If gain_power_tile_y > 0
    For j = 0 To #MAX_NUMBER_OF_POWERS - 1
      If power_available(j) = 0 And power_available(j, selected_ability_id, bonus2) = 1
        clip_power_tile_sprite(power_db(j)\tile)
        DisplaySprite(#SPRITE_POWERS, 340, gain_power_tile_y)
        gain_power_tile_y = gain_power_tile_y + 38
      EndIf
    Next
  EndIf
  ProcedureReturn rc
EndProcedure


; character gets experience
Procedure experience(experience_points.w = 1, game_start.b = 0)
  Protected i.b = 0, finished.b = 0, update_screen.b = 0
  Protected selected_entry.w = 0, key_lock.b = 1, number_of_entries.w, esc.b = 0
  Protected selected_ability_id.w = 0, attribute.w, bonus.w, title$, remaining_xp.w
  Protected event_type.l = 0, mouse_x.w = 0, mouse_y.w = 0, main_window_event = 0
  Protected mouse_moved.b = 0, mouse_x_new.w = 0, mouse_y_new.w = 0, offset.w = 0
  Protected mouse_over_entry.b = 0, mouse_left_button.b = 0
  remaining_xp = experience_points
  
  ; clear keyboard
  Repeat
    ExamineKeyboard()
    If KeyboardPushed(#PB_Key_All) = 0
      key_lock = 0
    EndIf
  Until key_lock = 0
  
  While remaining_xp > 0 And esc = 0
    finished = 0
    i = 0
    update_screen = 0
    title$ = message_list$(#MESSAGE_YOU_GAIN_SOME_EXPERIENCE)
    If game_start = 1
      title$ = message_list$(#MESSAGE_CHOOSE_STARTING_ABILITIES)
    EndIf
    title$ = title$ + " (" + Str(remaining_xp) + ")"
    number_of_entries = abilities_available_for_xp()
    selected_ability_id = experience_screen(selected_entry, number_of_entries, offset, title$)
    FlipBuffers()
    While finished = 0 And esc = 0
  
      ; examine keyboard & mouse input; check for windows events
      ExamineKeyboard()
      mouse_left_button = 0
      If preferences\fullscreen = 0
        main_window_event = WindowEvent()
        event_type = EventType()
        If main_window_event = #PB_Event_CloseWindow
          program_ends = 1
          finished = 1
          esc = 1
        EndIf
        mouse_x_new = WindowMouseX(0)
        mouse_y_new = WindowMouseY(0)
        If main_window_event = #WM_LBUTTONDOWN Or main_window_event = #WM_LBUTTONDBLCLK
          mouse_left_button = 1
        EndIf
      Else
        ExamineMouse()
        mouse_x_new = MouseX()
        mouse_y_new = MouseY()
        If MouseButton(#PB_MouseButton_Left)
        EndIf
      EndIf
      mouse_moved = 0
      If mouse_x_new <> mouse_x Or mouse_y_new <> mouse_y
        mouse_moved = 1
      EndIf      
      mouse_x = mouse_x_new
      mouse_y = mouse_y_new      
    
      ; escape key: end program
      If KeyboardReleased(#PB_Key_Escape)
        finished = 1
        esc = 1
      EndIf
    
      ; key down: next entry
      If KeyboardPushed(#PB_Key_Down) And key_lock = 0 And selected_entry < number_of_entries - 1
        selected_entry = selected_entry + 1
        If selected_entry > #EXPERIENCE_SCREEN_ABILITIES_ON_SCREEN
          offset = selected_entry - #EXPERIENCE_SCREEN_ABILITIES_ON_SCREEN
        EndIf
        update_screen = 1
        key_lock = 1
      EndIf
    
      ; key up: previous entry
      If KeyboardPushed(#PB_Key_Up) And key_lock = 0 And selected_entry > 0
        selected_entry = selected_entry - 1
        If selected_entry < #EXPERIENCE_SCREEN_ABILITIES_ON_SCREEN
          offset = 0
        EndIf
        update_screen = 1
        key_lock = 1
      EndIf
      
      ; mousewheel down; increase offset
      If MouseWheel() < 0 And offset < number_of_entries - #EXPERIENCE_SCREEN_ABILITIES_ON_SCREEN - 1
        offset = offset + 1
        update_screen = 1
        key_lock = 1       
      EndIf
      
      ; mousewheel up: decrease offset
      If MouseWheel() > 0 And offset > 0
        offset = offset - 1
        update_screen = 1
        key_lock = 1      
      EndIf
      
      ; mousewheel (windowed screen mode)
      If main_window_event = #WM_MOUSEWHEEL
        If EventwParam() > 0
          mouse_moved = 1
          If offset > 0
            offset = offset - 1
            update_screen = 1
            key_lock = 1       
          EndIf
        Else
          If offset < number_of_entries - #EXPERIENCE_SCREEN_ABILITIES_ON_SCREEN - 1
            offset = offset + 1
            update_screen = 1
            key_lock = 1        
          EndIf
        EndIf
      EndIf
      
      ; mouse moved: change currently selected entry
      If mouse_moved = 1
        mouse_over_entry = 0
        If mouse_x >= #EXPERIENCE_SCREEN_ABILITIES_LEFT_BORDER And mouse_x <= 300 And mouse_y >= 50 And mouse_y <= 432
          selected_entry = Int((mouse_y - 50) / 32) + offset
          update_screen = 1
          key_lock = 1
          mouse_over_entry = 1
        EndIf
      EndIf      
      
      ; adjust selected_entry
      If selected_entry < offset
        selected_entry = offset
      EndIf
    
      ; return key: leave screen
      If (KeyboardPushed(#PB_Key_Return) And key_lock = 0) Or (mouse_left_button = 1 And mouse_over_entry = 1)
        If selected_ability_id > 0 And selected_ability_id < #MAX_NUMBER_OF_ABILITIES - 1
          If ability_available(selected_ability_id) = 1
            For i=0 To #MAX_NUMBER_OF_ATTRIBUTE_BONI - 1
              attribute = ability_db(selected_ability_id)\attribute_bonus[i]\attribute
              bonus = ability_db(selected_ability_id)\attribute_bonus[i]\bonus
              If attribute > 0
                current_character\ability[attribute]\attribute_max_value = current_character\ability[attribute]\attribute_max_value + bonus
                current_character\ability[attribute]\attribute_current_value = current_character\ability[attribute]\attribute_current_value + bonus
                current_character\ability[attribute]\ability_value = current_character\ability[attribute]\ability_value + 1
              EndIf
              experience_screen(selected_entry, number_of_entries, offset, title$, RGB(255,100,0))
              FlipBuffers()
            Next
            finished = 1          
          EndIf
        EndIf
        update_abilities_adjustment_other()
        key_lock = 1
        update_screen = 1
      EndIf
    
     ; keyboard released: remove key lock
      If KeyboardReleased(#PB_Key_All)
        key_lock = 0
      EndIf
    
      ; update screen
      If update_screen = 1 Or preferences\fullscreen = 1
        selected_ability_id = experience_screen(selected_entry, number_of_entries, offset, title$)
        If preferences\fullscreen = 1
          DisplayTransparentSprite(#SPRITE_MOUSEPOINTER, mouse_x, mouse_y)
        EndIf
        FlipBuffers()
        update_screen = 0
      EndIf
    
    Wend
  remaining_xp = remaining_xp - 1
  Wend
EndProcedure


; deletes all xml files in savegame directory
Procedure delete_savegame()
  If ExamineDirectory(0, "savegame\", "*.xml")
    While NextDirectoryEntry(0)
      If DirectoryEntryType(0) = #PB_DirectoryEntry_File
        DeleteFile("savegame\" + DirectoryEntryName(0))
      EndIf
    Wend
    FinishDirectory(0)
  EndIf
EndProcedure


; restores depleted attribute to max value; returns 1 if attribute was below max, else 0
Procedure.b restore_attribute(id.w)
  Protected rc.b = 0, attribute_current_val.w = 0, attribute_max_val.w = 0
  If id < 1 Or id >= #MAX_NUMBER_OF_ABILITIES
    error_message("restore_ability(): wrong id " + Chr(34) + Str(id) + Chr(34))
  EndIf
  attribute_current_val = attribute_current_val(id)
  attribute_max_val = attribute_max_val(id)
  If attribute_current_val < attribute_max_val
    current_character\ability[id]\attribute_current_value = attribute_max_val
    rc = 1
  EndIf
  update_abilities_adjustment_other()
  ProcedureReturn rc
EndProcedure


; reduces an ability / attribute
Procedure reduce_ability(id.w, value.w, negative_value_allowed.b = 0)
  If id < 1 Or id >= #MAX_NUMBER_OF_ABILITIES
    error_message("reduce_ability(): wrong id " + Chr(34) + Str(id) + Chr(34))
  EndIf
  current_character\ability[id]\attribute_current_value = current_character\ability[id]\attribute_current_value - value
  If ability_db(id)\minimum <> -1
    current_character\ability[id]\attribute_current_value = max(current_character\ability[id]\attribute_current_value, ability_db(id)\minimum)
  EndIf
  If negative_value_allowed = 0
    current_character\ability[id]\attribute_current_value = max(current_character\ability[id]\attribute_current_value, 0)
  EndIf
  update_abilities_adjustment_other()
EndProcedure


; increases a depleted attribute; returns amount by which attribute was increased
Procedure.w increase_attribute(id.w, value.w)
  Protected rc.w = 0
  If id < 1 Or id >= #MAX_NUMBER_OF_ABILITIES
    error_message("increase_attribute(): wrong id " + Chr(34) + Str(id) + Chr(34))
  EndIf
  rc = value
  If ability_db(id)\depletable = 1
    rc = min(current_character\ability[id]\attribute_max_value - current_character\ability[id]\attribute_current_value, value)
  EndIf
  current_character\ability[id]\attribute_current_value = current_character\ability[id]\attribute_current_value + rc
  update_abilities_adjustment_other()
  ProcedureReturn rc
EndProcedure


; modifies the current value of an attribute; returns the amount by which the attribute was modified
Procedure.w modify_attribute(attribute_id.w, value.w)
  Protected rc.w = 0
  rc = value
  If attribute_id < 1 Or attribute_id >= #MAX_NUMBER_OF_ABILITIES
    error_message("modify_attribute(): wrong attribute_id " + Chr(34) + Str(attribute_id) + Chr(34))
  EndIf
  If value > 0
    rc = increase_attribute(attribute_id, value)
  Else
    reduce_ability(attribute_id, Abs(value))
  EndIf
  update_abilities_adjustment_other()
  ProcedureReturn rc
EndProcedure


; modifies buffer for attribute; returns changed value for modification
Procedure.w modify_buffer_attribute(id.w, value.w) 
  Protected rc.w, i.w
  rc = value  
  For i = 1 To #MAX_NUMBER_OF_ABILITIES - 1
    If ability_db(i)\buffer_for_attribute = id And id > 0 And rc > 0
      rc = max(0, rc - modify_attribute(i, rc))
    EndIf
  Next
  ProcedureReturn rc
EndProcedure


; returns 1 if current character has died, else 0
Procedure character_died()
  Protected rc.b = 0, i.w = 0, attribute_current_val.w
  For i=1 To #MAX_NUMBER_OF_ABILITIES - 1
    If ability_db(i)\game_ends > 0
      attribute_current_val = attribute_current_val(i)
      If ability_db(i)\game_ends = 1 And attribute_current_val < ability_db(i)\game_ends_val
        rc = 1
      EndIf
      If ability_db(i)\game_ends = 2 And attribute_current_val > ability_db(i)\game_ends_val
        rc = 1
      EndIf
      If rc = 1
        If ability_db(i)\game_ends_message$ <> "" And current_character\game_end_message$ = ""
          current_character\game_end_message$ = ability_db(i)\game_ends_message$
        EndIf
      EndIf
    EndIf
  Next
  ProcedureReturn rc
EndProcedure


; returns random damage character causes in melee combat
Procedure.w random_damage_in_melee()
  Protected rc.w = 0, i.w = 0
  For i = 1 To #MAX_NUMBER_OF_ABILITIES - 1
    If ability_db(i)\damage_in_melee = 1
      rc = rc + attribute_current_val(i)
      If ability_db(i)\randomizer_ability > 0
        rc = rc + Random(attribute_current_val(ability_db(i)\randomizer_ability))
      EndIf
    EndIf
  Next
  ProcedureReturn rc
EndProcedure


; returns defense of character in melee combat
Procedure.w defense_in_melee()
  Protected rc.w = 0, i.w = 0
  For i = 1 To #MAX_NUMBER_OF_ABILITIES - 1
    If ability_db(i)\defense_melee = 1
      rc = rc + attribute_current_val(i)
    EndIf
  Next
  ProcedureReturn rc
EndProcedure


; damage buffer; returns adjusted damage value
Procedure.w character_damage_buffer(damage.w)
  Protected rc.w, i.w, j.w, reduced_by.w
  rc = Abs(damage)
  For i = 1 To #MAX_NUMBER_OF_ABILITIES - 1
    If ability_db(i)\modify_per_point_of_damage <> 0 And rc > 0
      For j = 1 To #MAX_NUMBER_OF_ABILITIES - 1
        If ability_db(j)\buffer_for_attribute = i And rc > 0
          If attribute_current_val(j) > 0
            play_sound("hit")
            animation(ability_db(j)\buffer_animation$, 6, 6,  rc)        
            rc = max(0, rc - Abs(modify_attribute(j, -rc)))
          EndIf
        EndIf
      Next
    EndIf
  Next
  ProcedureReturn rc
EndProcedure


; character takes damage
Procedure character_takes_damage(value.w, game_end_message$ = "")
  Protected i.w
  For i = 1 To #MAX_NUMBER_OF_ABILITIES - 1
    If ability_db(i)\modify_per_point_of_damage <> 0
      modify_attribute(i, value * ability_db(i)\modify_per_point_of_damage)
    EndIf
  Next
  If game_end_message$ <> ""
    If character_died() = 1
      current_character\game_end_message$ = game_end_message$
    EndIf
  EndIf
  update_abilities_adjustment_other()
EndProcedure


; returns chance for character to sneak successfully, or 0 if character is not sneaking
Procedure.w sneaking_val(only_when_activated.b = 0)
  Protected rc.b = 0, i.w = 0
  For i = 1 To #MAX_NUMBER_OF_ABILITIES - 1
    If ability_db(i)\sneaking = 1
      If only_when_activated = 0 Or current_character\ability[i]\activated = 1
        rc = rc + attribute_current_val(i)
      EndIf
    EndIf
  Next
  ProcedureReturn rc
EndProcedure


; returns bonus for backstabbing
Procedure.w backstabbing_val(only_when_activated.b = 0)
  Protected rc.w = 0, i.w = 0
  For i = 1 To #MAX_NUMBER_OF_ABILITIES - 1
    If ability_db(i)\backstab = 1
      If only_when_activated = 0 Or current_character\ability[i]\activated = 1
        rc = rc + attribute_current_val(i)
      EndIf
    EndIf
  Next  
  ProcedureReturn rc
EndProcedure


; returns perception value for current character
Procedure.w perception_val(tile_class$)
  Protected rc.w = 0, i.w = 0
  For i = 1 To #MAX_NUMBER_OF_ABILITIES - 1
    If ability_db(i)\perception_tile_class$ <> ""
      If compare_string_lists(ability_db(i)\perception_tile_class$, tile_class$) = 1 Or ability_db(i)\perception_tile_class$ = "all"
        rc = rc + attribute_current_val(i)
      EndIf
    EndIf
  Next
  ProcedureReturn rc
EndProcedure


; updates ability adjustment by other abilities
Procedure update_abilities_adjustment_other()
  Protected i.w = 0, j.w = 0, attribute.w = 0, attribute_current_val.w = 0, percentage_bonus.w = 0
  Protected percentage_attribute_multiplier.w = 0, percentage.w
  For i=1 To #MAX_NUMBER_OF_ABILITIES - 1
    current_character\ability[i]\adjustment_other = 0
    current_character\ability[i]\adjustment_percentage = 100
  Next
  For i=1 To #MAX_NUMBER_OF_ABILITIES - 1
    attribute_current_val = attribute_current_val(i)
    If attribute_current_val > 0
      For j=0 To #MAX_NUMBER_OF_ABILITY_ADJUSTMENTS - 1
        attribute = ability_db(i)\adjustment[j]\attribute
        percentage = ability_db(i)\adjustment[j]\percentage
        percentage_bonus = ability_db(i)\adjustment[j]\percentage_bonus
        percentage_attribute_multiplier = ability_db(i)\adjustment[j]\percentage_attribute_multiplier
        If attribute > 0
          If ability_db(i)\adjustment[j]\value <> 0
            current_character\ability[attribute]\adjustment_other = current_character\ability[attribute]\adjustment_other + ability_db(i)\adjustment[j]\value
          EndIf
          If percentage <> 100
            current_character\ability[attribute]\adjustment_percentage = Int((current_character\ability[attribute]\adjustment_percentage * percentage) / 100)
          ;Debug ability_db(attribute)\name$ + ":" + Str(current_character\ability[attribute]\adjustment_percentage) + "%"
          EndIf
          If ability_db(i)\adjustment[j]\percentage_attribute_multiplier > 0
            current_character\ability[attribute]\adjustment_percentage = Int((current_character\ability[attribute]\adjustment_percentage * ((percentage_attribute_multiplier * attribute_current_val) + percentage_bonus)) / 100)
          EndIf
        EndIf
      Next
    EndIf
  Next
EndProcedure


; returns number of movement points available
Procedure.w movement_left()
  Protected rc.w = 0, i.w
  For i = 1 To #MAX_NUMBER_OF_ABILITIES - 1
    If ability_db(i)\movement = 1
      rc = rc + attribute_current_val(i)
    EndIf
  Next
  ProcedureReturn rc
EndProcedure


; returns armor protection of character
Procedure.w armor_protection()
  Protected rc.w = 0, i.w
  For i = 1 To #MAX_NUMBER_OF_ABILITIES - 1
    If ability_db(i)\armor = 1
      rc = rc + attribute_current_val(i)
    EndIf
  Next
  ProcedureReturn rc
EndProcedure


; returns random armor protection for current character
Procedure.w random_armor_protection()
  Protected rc.w = 0
  rc = armor_protection()
  If rc > 0
    rc = Random(rc)
  EndIf
  ProcedureReturn rc
EndProcedure
; IDE Options = PureBasic 6.00 Beta 10 (Windows - x86)
; CursorPosition = 755
; FirstLine = 743
; Folding = ---------------------------------------------------
; EnableXP
; CompileSourceDirectory
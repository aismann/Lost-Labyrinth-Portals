; Lost Labyrinth VI: Portals
; items
; written in PureBasic 4.20 (http://www.purebasic.com)
; created:  14.11.2008 Frank Malota <malota@web.de>
; modified: 08.01.2009 Frank Malota <malota@web.de>
; modified: 13.02.2024 Peter Eismann

; declarations
Declare.w character_loses_items(amount_lost.w = 1, all.b = 0)
Declare.w random_item_type(rarity.l = 5, class$ = "", artefact.b = 0)
Declare.w magic_bonus()


; resets a single item
Procedure reset_item(*item.item_db_struct)
  Protected i.w
  With *item
    \name$ = ""
    \tile = 0
    \tile_equipped = -1
    \weight = 0
    \starting_equipment = 0
    \class$ = ""
    \class_name$ = ""
    \description$ = ""
    \can_be_equipped = 0
    \price = 0
    \fuel = 0
    \fuel_consumed_per_turn = 0
    \fuel_randomized = 0
    \use_name$ = ""
    \use_animation$ = ""
    \consumed_after_use = 0
    \turn_ends_after_use = 0
    \use_message$ = ""
    \fuel_consumed_per_use = 0
    \artefact = 0
    \equipment_limit = 0
    \identified = 1
    \identified_when_used = 0
    \power_id = 0
    \power_name$ = ""
  EndWith
  For i = 0 To #MAX_NUMBER_OF_ITEM_ABILITY_BONI - 1
    With *item\ability_bonus[i]
      \attribute = 0
      \attribute_name$ = ""
      \value = 0
      \magic_bonus_multiplier = 0
      \randomized = 0
      \randomized_bonus = 0
    EndWith
  Next
  For i = 0 To #MAX_NUMBER_OF_ITEM_UNEQUIP_CLASSES - 1
    *item\unequip_item_class$[i] = ""
  Next
EndProcedure


; resets item database
Procedure reset_item_db()
  Protected i.w, j.w
  For i=1 To #MAX_NUMBER_OF_ITEMS - 1
    With item_db(i)
      \name$ = ""
      \tile = 0
      \tile_equipped = -1
      \weight = 0
      \starting_equipment = 0
      \class$ = ""
      \class_name$ = ""
      \description$ = ""
      \can_be_equipped = 0
      \price = 0
      \fuel = 0
      \fuel_consumed_per_turn = 0
      \use_name$ = ""
      \use_animation$ = ""
      \consumed_after_use = 0
      \turn_ends_after_use = 0
      \use_message$ = ""
      \fuel_consumed_per_use = 0
      \artefact = 0
      \equipment_limit = 0
      \identified = 0
      \identified_when_used = 0
    EndWith
    For j=0 To #MAX_NUMBER_OF_ITEM_ABILITY_BONI - 1
      With item_db(i)\ability_bonus[j]
        \attribute = 0
        \attribute_name$ = ""
        \value = 0
        \magic_bonus_multiplier = 0
        \randomized = 0
        \randomized_bonus = 0
      EndWith
    Next
    For j=0 To #MAX_NUMBER_OF_ITEM_UNEQUIP_CLASSES - 1
      item_db(i)\unequip_item_class$[j] = ""
    Next
  Next
EndProcedure


; resolves ability names in power db
Procedure item_db_resolve_names()
  Protected i.w, j.w, k.w
  For i=1 To #MAX_NUMBER_OF_ITEMS - 1
    For j=0 To #MAX_NUMBER_OF_ITEM_ABILITY_BONI - 1
      If item_db(i)\ability_bonus[j]\attribute_name$ <> "" And item_db(i)\ability_bonus[j]\attribute = 0
        For k=1 To #MAX_NUMBER_OF_ABILITIES - 1
          If ability_db(k)\name$ = item_db(i)\ability_bonus[j]\attribute_name$
            item_db(i)\ability_bonus[j]\attribute = k
          EndIf
        Next
        If item_db(i)\ability_bonus[j]\attribute = 0
          error_message("item_db_resolve_names(): cannot find ability " + Chr(34) + item_db(i)\ability_bonus[j]\attribute_name$ + Chr(34))
        EndIf
      EndIf
    Next
    If item_db(i)\power_name$ <> "" And item_db(i)\power_id = 0
      For j = 1 To #MAX_NUMBER_OF_POWERS - 1
        If power_db(j)\name$ = item_db(i)\power_name$
          item_db(i)\power_id = j
        EndIf
      Next
      If item_db(i)\power_id = 0
        error_message("item_db_resolve_names(): cannot find power " + Chr(34) + item_db(i)\power_name$ + Chr(34))
      EndIf
    EndIf
  Next
EndProcedure


; scrambes the tiles assigned to items for one item class in the item database
Procedure scramble_item_db_tiles(class$)
  Protected i.w, NewList items.item_tile_list_struct(), tile1.w = 0, tile2.w, index.w = 0, r.w = -1, count.w = 0
  ClearList(items())
  For i = 0 To #MAX_NUMBER_OF_ITEMS - 1
    If item_db(i)\class$ = class$
      AddElement(items())
      With items()
        \item = i
        \tile = item_db(i)\tile
      EndWith
      count = count + 1
    EndIf
  Next
  If count > 1
    ResetList(items())
    While NextElement(items())
      index = ListIndex(items())
      tile1 = items()\tile
      r = index
      While r = index
        r = Random(count - 1)
      Wend
      SelectElement(items(), r)
      tile2 = items()\tile
      items()\tile = tile1
      SelectElement(items(), index)
      items()\tile = tile2
    Wend
    ForEach items()
      item_db(items()\item)\tile = items()\tile
    Next
  EndIf
  ClearList(items())
EndProcedure


; loads item database
Procedure load_item_db()
  Protected filename$= "data\items.xml"
  Protected val$, val2$, item_idx.w = 1, item_bonus_idx.w, attribute.w, attribute_name$
  Protected attribute_bonus_value.w = 0, starting_equipment.w, class$, can_be_equipped.b, item_id.w
  Protected description$, unequip_item_class$, unequip_class_idx.w = 0, price.w = 0, fuel.w = 0, use_message$
  Protected fuel_consumed_per_turn.b = 0, fuel_name$ = "", tile_equipped.w = 0, use_name$, consumed_after_use.b
  Protected turn_ends_after_use.b = 0, fuel_consumed_per_use.w = 0, artefact.b = 0
  Protected magic_bonus_multiplier.b = 0, equipment_limit.w = 0, randomized.b = 0, randomized_bonus.w = 0
  Protected identified.b = 0, identified_when_used.b = 0, language$ = "", type$ = "", duration.w = 0
  Protected use_animation$ = "", *mainnode, *node, *childnode
  Protected new_item.item_db_struct
  If CreateXML(0) = 0
    error_message("load_item_db(): could not create xml structure in memory!")
  EndIf
  If LoadXML(0, filename$) = 0
    error_message("load_item_db(): could not open item xml file: " + Chr(34) + filename$ + Chr(34))
  EndIf
  If XMLStatus(0) <> 0
    error_message("load_item_db(): error in xml structure of item file " + Chr(34) + filename$ + Chr(34) + ": " + XMLError(0))
  EndIf
  reset_item_db()
  *mainnode = MainXMLNode(0)
  If *mainnode
    *node = ChildXMLNode(*mainnode)
    While *node <> 0
      Select GetXMLNodeName(*node)
        
        Case "item":
          reset_item(@new_item)
          item_id = 0
;           name$ = ""
;           tile = 0
;           weight = 0
;           starting_equipment = 0
;           class$ = ""
;           description$ = ""
;           can_be_equipped = 0
;           price = 0
;           fuel = 0
;           fuel_consumed_per_turn = 0
;           fuel_name$ = ""
;           tile_equipped = -1
;           use_name$ = ""
;           consumed_after_use = 0
;           turn_ends_after_use = 0
;           use_message$ = ""
;           fuel_consumed_per_use = 0
;           artefact = 0
;           equipment_limit = 0
;           identified = 1
;           identified_when_used = 0
;           use_animation$ = ""
          If ExamineXMLAttributes(*node)
            While NextXMLAttribute(*node)
              val$ = XMLAttributeValue(*node)
              Select XMLAttributeName(*node)
              
                Case "id":
                  item_id = Val(val$)
                  If item_id < 1
                    error_message("load_item_db(): item ID too small or wring format (" + val$ + ") in item file " + Chr(34) + filename$ + Chr(34))
                  EndIf
                  If item_id >= #MAX_NUMBER_OF_ITEMS
                    error_message("load_item_db(): item ID too large (" + val$ + ") in item file " + Chr(34) + filename$ + Chr(34))
                  EndIf
                
                Case "name":
                  new_item\name$ = val$
                  
                Case "tile":
                  new_item\tile = Val(val$)
                  
                Case "tile_equipped":
                  new_item\tile_equipped = Val(val$)
                  
                Case "weight":
                  new_item\weight = Val(val$)
                  
                Case "starting_equipment":
                  new_item\starting_equipment = Val(val$)
                
                Case "class":
                  new_item\class$ = val$
                  
                Case "can_be_equipped":
                  If val$="yes"
                    new_item\can_be_equipped = 1
                  EndIf
                  
                Case "description":
                  new_item\description$ = val$
                  
                Case "price":
                  new_item\price = Val(val$)
                  
                Case "fuel":
                  new_item\fuel = Val(val$)
                  
                Case "fuel_consumed_per_turn":
                  new_item\fuel_consumed_per_turn = Val(val$)
                  
                Case "fuel_name":
                  new_item\fuel_name$ = val$
                  
                Case "fuel_randomized":
                  If val$ = "yes"
                    new_item\fuel_randomized = 1
                  EndIf
                  
                Case "use_name":
                  new_item\use_name$ = val$
                  
                Case "consumed_after_use":
                  If val$ = "yes"
                    new_item\consumed_after_use = 1
                  EndIf
                
                Case "turn_ends_after_use":
                  If val$ = "yes"
                    new_item\turn_ends_after_use = 1
                  EndIf
                  
                Case "use_message":
                  new_item\use_message$ = val$
                  
                Case "fuel_consumed_per_use":
                  new_item\fuel_consumed_per_use = Val(val$)
                  
                Case "artefact":
                  If val$ = "yes"
                    new_item\artefact = 1
                  EndIf
                  
                Case "equipment_limit":
                  new_item\equipment_limit = Val(val$)
                  
                Case "identified":
                  If val$ = "yes"
                    new_item\identified = 1
                  EndIf
                  If val$ = "no"
                    new_item\identified = 0
                  EndIf
                  
                Case "identified_when_used":
                  If val$ = "yes"
                    new_item\identified_when_used = 1
                  EndIf
                  
                Case "use_animation":
                  new_item\use_animation$ = val$
                  
                Case "power_id":
                  new_item\power_id = Val(val$)
                  
                Case "power_name":
                  new_item\power_name$ = val$
                  
                Default:
                  error_message("load_item_db(): unknown attribute " + Chr(34) + XMLAttributeName(*node) + Chr(34) + " in item tag in item xml file " + Chr(34) + filename$ + Chr(34))
                
              EndSelect
            Wend
            If item_id > 0
              If tile_equipped = -1
                tile_equipped = new_item\tile
              EndIf
              With item_db(item_id)
                \name$ = new_item\name$
                \tile = new_item\tile
                \weight = new_item\weight
                \starting_equipment = new_item\starting_equipment
                \class$ = new_item\class$
                \class_name$ = new_item\class$
                \description$ = new_item\description$
                \can_be_equipped = new_item\can_be_equipped
                \price = new_item\price
                \fuel = new_item\fuel
                \fuel_consumed_per_turn = new_item\fuel_consumed_per_turn
                \fuel_name$ = new_item\fuel_name$
                \fuel_randomized = new_item\fuel_randomized
                \tile_equipped = new_item\tile_equipped
                \use_name$ = new_item\use_name$
                \consumed_after_use = new_item\consumed_after_use
                \turn_ends_after_use = new_item\turn_ends_after_use
                \use_message$ = new_item\use_message$
                \fuel_consumed_per_use = new_item\fuel_consumed_per_use
                \artefact = new_item\artefact
                \equipment_limit = new_item\equipment_limit
                \identified = new_item\identified
                \identified_when_used = new_item\identified_when_used
                \use_animation$ = new_item\use_animation$
                \power_id = new_item\power_id
                \power_name$ = new_item\power_name$
              EndWith
              item_bonus_idx = 0
              unequip_class_idx = 0
              *childnode = ChildXMLNode(*node)
              While *childnode <> 0
                Select GetXMLNodeName(*childnode)
                
                  Case "ability_bonus":
                    attribute = 0
                    attribute_name$ = ""
                    attribute_bonus_value = 0
                    magic_bonus_multiplier = 0
                    randomized = 0
                    randomized_bonus = 0
                    duration  = 0
                    If ExamineXMLAttributes(*childnode)
                      While NextXMLAttribute(*childnode)
                        val2$ = XMLAttributeValue(*childnode)
                        Select XMLAttributeName(*childnode)
                        
                          Case "attribute":
                            attribute = Val(val2$)
                            
                          Case "attribute_name":
                            attribute_name$ = val2$
                          
                          Case "value":
                            attribute_bonus_value = Val(val2$)
                            
                          Case "magic_bonus_multiplier":
                            magic_bonus_multiplier = Val(val2$)
                            
                          Case "randomized":
                            If val2$ = "yes"
                              randomized = 1
                            EndIf
                            
                          Case "randomized_bonus":
                            randomized_bonus = Val(val2$)
                          
                          Case "duration":
                            duration = Val(val2$)
                        
                          Default:
                            error_message("load_item_db(): unknown attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in ability_bonus tag in item xml file " + Chr(34) + filename$ + Chr(34))
                        
                        EndSelect
                      Wend
                      If item_bonus_idx >= #MAX_NUMBER_OF_ITEM_ABILITY_BONI
                        error_message("load_item_db(): too much ability boni (>" + Str(#MAX_NUMBER_OF_ITEM_ABILITY_BONI) + ") in item xml file " + Chr(34) + filename$ + Chr(34))
                      EndIf
                      If attribute > 0 Or attribute_name$
                        With item_db(item_id)\ability_bonus[item_bonus_idx]
                          \attribute = attribute
                          \attribute_name$ = attribute_name$
                          \value = attribute_bonus_value
                          \magic_bonus_multiplier = magic_bonus_multiplier
                          \randomized = randomized
                          \randomized_bonus = randomized_bonus
                          \duration = duration
                        EndWith
                        item_bonus_idx = item_bonus_idx + 1
                      EndIf
                    EndIf
                    
                  Case "unequip":
                    unequip_item_class$ = ""
                    If ExamineXMLAttributes(*childnode)
                      While NextXMLAttribute(*childnode)
                        val2$ = XMLAttributeValue(*childnode)
                        Select XMLAttributeName(*childnode)
                        
                          Case "class":
                            unequip_item_class$ = val2$
                            
                          Default:
                            error_message("load_item_db(): unknown attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in unequip_class tag in item xml file " + Chr(34) + filename$ + Chr(34))
                            
                        EndSelect
                      Wend
                      If unequip_item_class$ <> ""
                        If unequip_class_idx >= #MAX_NUMBER_OF_ITEM_UNEQUIP_CLASSES
                          error_message("load_item_db(): too much unequip entries (>" + Str(#MAX_NUMBER_OF_ITEM_UNEQUIP_CLASSES) + ") for one item in item xml file " + Chr(34) + filename$ + Chr(34))
                        EndIf
                        item_db(item_id)\unequip_item_class$[unequip_class_idx] = unequip_item_class$
                        unequip_class_idx = unequip_class_idx + 1
                      EndIf
                    EndIf
                    
                  Case "name":
                    If ExamineXMLAttributes(*childnode)
                      While NextXMLAttribute(*childnode)
                        val2$ = XMLAttributeValue(*childnode)
                        Select XMLAttributeName(*childnode)
                          
                          Case "language":
                            If val2$ = preferences\language$
                              item_db(item_id)\name$ = GetXMLNodeText(*childnode)
                            EndIf
                            
                          Default:
                            error_message("load_item_db(): unknown attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in name tag in item xml file " + Chr(34) + filename$ + Chr(34))
                            
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
                              item_db(item_id)\description$ = GetXMLNodeText(*childnode)
                            EndIf
                            
                          Default:
                            error_message("load_item_db(): unknown attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in description tag in item xml file " + Chr(34) + filename$ + Chr(34))
                            
                        EndSelect
                      Wend
                    EndIf

                  Case "class_name":
                    If ExamineXMLAttributes(*childnode)
                      While NextXMLAttribute(*childnode)
                        val2$ = XMLAttributeValue(*childnode)
                        Select XMLAttributeName(*childnode)
                          
                          Case "language":
                            If val2$ = preferences\language$
                              item_db(item_id)\class_name$ = GetXMLNodeText(*childnode)
                            EndIf
                            
                          Default:
                            error_message("load_item_db(): unknown attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in class_name$ tag in item xml file " + Chr(34) + filename$ + Chr(34))
                            
                        EndSelect
                      Wend
                    EndIf

                  Case "fuel_name":
                    If ExamineXMLAttributes(*childnode)
                      While NextXMLAttribute(*childnode)
                        val2$ = XMLAttributeValue(*childnode)
                        Select XMLAttributeName(*childnode)
                          
                          Case "language":
                            If val2$ = preferences\language$
                              item_db(item_id)\fuel_name$ = GetXMLNodeText(*childnode)
                            EndIf
                            
                          Default:
                            error_message("load_item_db(): unknown attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in fuel_name tag in item xml file " + Chr(34) + filename$ + Chr(34))
                            
                        EndSelect
                      Wend
                    EndIf
                    
                  Case "message":
                    language$ = ""
                    type$ = ""
                    If ExamineXMLAttributes(*childnode)
                      While NextXMLAttribute(*childnode)
                        val2$ = XMLAttributeValue(*childnode)
                        Select XMLAttributeName(*childnode)
                          
                          Case "language":
                            language$ = val2$
                            If val2$ = preferences\language$
                              item_db(item_id)\fuel_name$ = GetXMLNodeText(*childnode)
                            EndIf
                          
                          Case "type":
                            type$ = val2$
                            
                          Default:
                            error_message("load_item_db(): unknown attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in message tag in item xml file " + Chr(34) + filename$ + Chr(34))
                            
                        EndSelect
                      Wend
                      If language$ = preferences\language$
                        Select type$
                        
                          Case "use":
                            item_db(item_id)\use_message$ = GetXMLNodeText(*childnode)
                          
                          Default:
                            error_message("load_item_db(): unknown type " + Chr(34) + type$ + Chr(34) + " in message tag in item xml file " + Chr(34) + filename$ + Chr(34))
                            
                        EndSelect
                      EndIf
                    EndIf                                    
                  
                  Default:
                    error_message("load_item_db(): unknown child tag " + Chr(34) + GetXMLNodeName(*childnode) + Chr(34) + " in item tag in item xml file " + Chr(34) + filename$ + Chr(34))
                    
                EndSelect
                *childnode = NextXMLNode(*childnode)
              Wend
            EndIf
          EndIf
          
        Default:
          error_message("load_item_db(): unknown tag " + Chr(34) + GetXMLNodeName(*node) + Chr(34) + " in item xml file " + Chr(34) + filename$ + Chr(34))
          
      EndSelect
      *node = NextXMLNode(*node)
    Wend
  EndIf
  FreeXML(0)
  scramble_item_db_tiles("Potion")
EndProcedure


; returns number of equipped items in one item class
Procedure.w number_of_equipped_items(class$)
  Protected rc.w = 0, *item_in_inventory.item_in_inventory_struct, item_type.w
  If ListSize(inventory()) > 0
    If ListIndex(inventory()) >= 0
      *item_in_inventory = @inventory()
    EndIf
    ForEach inventory()
      If inventory()\equipped = 1
        item_type = inventory()\type
        If item_db(item_type)\class$ = class$
          rc = rc + 1
        EndIf
      EndIf
    Next
  EndIf
  If *item_in_inventory
    ChangeCurrentElement(inventory(), *item_in_inventory)
  EndIf
  ProcedureReturn rc
EndProcedure


; unequip item class in inventory
Procedure unequip_item_class(item_type.w)
  Protected *last_inventory_element, i.w
  If ListIndex(inventory()) >= 0
    *last_inventory_element = @inventory()
  EndIf
  ForEach inventory()
    For i=0 To #MAX_NUMBER_OF_ITEM_UNEQUIP_CLASSES - 1
      If item_db(item_type)\unequip_item_class$[i] <> ""
        If item_db(item_type)\unequip_item_class$[i] = item_db(inventory()\type)\class$
          inventory()\equipped = 0
        EndIf
      EndIf
    Next
  Next
  If *last_inventory_element
    ChangeCurrentElement(inventory(), *last_inventory_element)
  EndIf
EndProcedure


; updates bonus from equipment for character
Procedure update_equipment_boni()
  Protected *last_inventory_element, i.w, attribute.w, bonus.w, magic_bonus_multiplier.w
  For i=0 To #MAX_NUMBER_OF_ABILITIES - 1
    current_character\ability[i]\item_bonus = 0
  Next
  If ListSize(inventory()) > 0
    If ListIndex(inventory()) >= 0
      *last_inventory_element = @inventory()
    EndIf
    ForEach inventory()
      If inventory()\equipped = 1
        For i=0 To #MAX_NUMBER_OF_ITEM_ABILITY_BONI-1
          attribute = item_db(inventory()\type)\ability_bonus[i]\attribute
          bonus = item_db(inventory()\type)\ability_bonus[i]\value
          magic_bonus_multiplier = item_db(inventory()\type)\ability_bonus[i]\magic_bonus_multiplier
          If magic_bonus_multiplier > 0
            bonus = bonus + (inventory()\magic_bonus * magic_bonus_multiplier)
          EndIf
          If attribute > 0
            current_character\ability[attribute]\item_bonus = current_character\ability[attribute]\item_bonus + bonus
          EndIf
        Next
      EndIf
    Next
    If *last_inventory_element
      ChangeCurrentElement(inventory(), *last_inventory_element)
    EndIf
  EndIf
EndProcedure


; inventory screen
Procedure inventory_screen(*cursor.cursor_struct, *item_menu.menu_struct, row_offset.w = 0, y_pixel_offset.b = 0)
  Protected frame.b = 1, attribute.w = 0, bonus.w = 0, item_type.w = 0, item_count.w = 0
  Protected i.b = 0, x.w, y.w, items_in_inventory.w = 0, row_size_in_pixel.w
  Protected tile.w, text$, total_number_of_rows_in_inventory.w, bar_height.w, bar_y.w
  items_in_inventory = ListSize(inventory())
  ClearScreen(0)
  draw_map_screen(@current_map)
  draw_character()
  ClipSprite(#SPRITE_Frame, 0, 6*16, 16, 16)
  DisplaySprite(#SPRITE_Frame, 0, 26*16)
  For i=1 To 39
    ClipSprite(#SPRITE_Frame, 0, 7*16 + (frame*16), 16, 16)
    DisplaySprite(#SPRITE_Frame, i*16, 26*16)
    frame = frame + 1
    If frame > 4
      frame = 0
    EndIf
  Next
  ClipSprite(#SPRITE_Frame, 0, 0, 16, 16)
  DisplaySprite(#SPRITE_Frame, 13*32, 0)
  frame = 1
  For i=1 To 25
    ClipSprite(#SPRITE_Frame, 0, frame*16 + 16, 16, 16)
    DisplaySprite(#SPRITE_Frame, 13*32, i*16)
    frame = frame + 1
    If frame > 4
      frame = 0
    EndIf
  Next
  ResetList(inventory())
  clip_fx_tile_sprite(#SPRITE_FX_GREY_BOX)
  ForEach inventory()
    inventory()\selected = 0
  Next
  x = 0
  y = 0
  item_count = 0
  ResetList(inventory())  
  While y < #INVENTORY_ROWS
    While NextElement(inventory()) And y < #INVENTORY_ROWS
      item_count = item_count + 1
      If item_count > row_offset * #INVENTORY_ROWS
        If inventory()\equipped = 1
          clip_item_tile_sprite(#TILE_ITEM_EQUIPPED)
          DisplaySprite(#SPRITE_ITEMS, 434 + x * 32, 32 + y * 32 + y_pixel_offset)         
        Else
          DisplaySprite(#SPRITE_FX, 434 + x * 32, 32 + y * 32 + y_pixel_offset)
        EndIf
        If inventory()\equipped = 1 And item_db(inventory()\type)\tile_equipped >= 0
          clip_item_tile_sprite(item_db(inventory()\type)\tile_equipped)
        Else
          clip_item_tile_sprite(item_db(inventory()\type)\tile)
        EndIf
        DisplayTransparentSprite(#SPRITE_ITEMS, 434 + x * 32, 32 + y * 32 + y_pixel_offset)        
        If *cursor\x = x And *cursor\y = y And y_pixel_offset = 0
          inventory()\selected = 1
          DisplaySprite(#SPRITE_ITEMS, 434, 240)
          ClipSprite(#SPRITE_CURSOR, *cursor\frame * 32, 0, 32, 32)
          DisplayTransparentSprite(#SPRITE_CURSOR, 434 + x * 32, 32 + y * 32)          
        EndIf
        x = x + 1
        If x > #INVENTORY_COLUMNS - 1
          x = 0
          y = y + 1
        EndIf        
      EndIf
    Wend
    If y < #INVENTORY_ROWS
      DisplaySprite(#SPRITE_FX, 434 + x * 32, 32 + y * 32 + y_pixel_offset)
    EndIf
    If *cursor\x = x And *cursor\y = y And y_pixel_offset = 0
      ClipSprite(#SPRITE_CURSOR, *cursor\frame * 32, 0, 32, 32)
      DisplayTransparentSprite(#SPRITE_CURSOR, 434 + x * 32, 32 + y * 32)
    EndIf
    x = x + 1
    If x > #INVENTORY_COLUMNS - 1
      x = 0
      y = y + 1
    EndIf
  Wend
  StartDrawing(ScreenOutput())
  If y_pixel_offset < 0
    Box(434, 0, #INVENTORY_COLUMNS * 32, 32, 0)
  EndIf
  If y_pixel_offset > 0
    Box(434, #INVENTORY_ROWS * 32 + 32, #INVENTORY_COLUMNS * 32, 32, 0)
  EndIf
  DrawingFont(#PB_Default)
  DrawText(416 + 16 + 2, 0, message_list$(#MESSAGE_INVENTORY) + " (" + Str(items_in_inventory) + " " + message_list$(#MESSAGE_ITEMS) + ")", $ffffff, 0)
  ResetList(inventory())  
  ForEach inventory()
    If inventory()\selected = 1
      item_type = inventory()\type
      y = 240
      text$ = item_db(item_type)\name$
      If item_db(item_type)\artefact = 1
        text$ = text$ + " + " + Str(inventory()\magic_bonus)
      EndIf

      If item_db(item_type)\identified = 0 And current_character\item_identification[item_type]\identified = 0
        text$ = message_list$(#MESSAGE_UNIDENTIFIED_ITEM)
      EndIf
      If wrap_text(468, y, text$, 640-468, 16, RGB(0, 255, 255)) < 2
        DrawText(468, y + 16, item_db(item_type)\class_name$, RGB(255,100,0), 0)
      EndIf
      y = y + 32
      DrawingFont(FontID(#FONT_VERDANA))
      If inventory()\amount > 1
        DrawText(434, y, message_list$(#MESSAGE_AMOUNT) + ": " + Str(inventory()\amount), RGB(255, 100, 0), 0)
        y = y + 16
      EndIf
      If item_db(item_type)\identified = 1 Or current_character\item_identification[item_type]\identified = 1
        For i = 0 To #MAX_NUMBER_OF_ITEM_ABILITY_BONI - 1
          attribute = item_db(item_type)\ability_bonus[i]\attribute
          bonus = item_db(item_type)\ability_bonus[i]\value
          If item_db(item_type)\artefact = 1
            bonus = bonus + (item_db(item_type)\ability_bonus[i]\magic_bonus_multiplier * inventory()\magic_bonus)
          EndIf
          If attribute > 0
            text$ = ability_db(attribute)\name_display$
            If bonus > 0
              text$ = text$ + " + "
            EndIf
            If item_db(item_type)\ability_bonus[i]\randomized = 1
              text$ = text$ + Str(item_db(item_type)\ability_bonus[i]\randomized_bonus) + " - " + Str(bonus + item_db(item_type)\ability_bonus[i]\randomized_bonus)
            Else          
              text$ = text$ + Str(bonus)
            EndIf
            If ability_db(attribute)\percentage = 1
              text$ = text$ + "%"
            EndIf
            DrawText(434, y, shorten_text(text$, 170), RGB(0, 255, 0), 0)
            y = y + 16
          EndIf       
        Next
        If item_db(item_type)\fuel > 0 And item_db(item_type)\fuel_name$ <> ""
          text$ = ReplaceString(item_db(item_type)\fuel_name$, "[fuel]", Str(inventory()\fuel))
          DrawText(434, y, shorten_text(text$, 170), RGB(255, 0, 255), 0)
          y = y + 16
        EndIf
        DrawText(434, y, shorten_text(message_list$(#MESSAGE_WEIGHT) + ": " + StrF(item_db(item_type)\weight / 10, 1) + " " + message_list$(#MESSAGE_POUND), 170), RGB(255,0,0), 0)
        y = y + 16
        DrawingFont(FontID(#FONT_SMALL))
        y = y + wrap_text(434, y, item_db(item_type)\description$, 640 - 434, 12, $ffffff)
      EndIf
    EndIf
  Next
  If items_in_inventory > 36
    Box(626, 32, 14, 192, $777777)
    Box(627, 33, 12, 190, 0)
    total_number_of_rows_in_inventory = (items_in_inventory + #INVENTORY_COLUMNS - 1) / #INVENTORY_COLUMNS
    row_size_in_pixel = (#INVENTORY_ROWS * 32) / total_number_of_rows_in_inventory
    bar_y = 34 + row_offset * row_size_in_pixel    
    bar_height = row_size_in_pixel * #INVENTORY_ROWS - 1
    Box(628, bar_y, 10, bar_height, $777777)
    LineXY(628, bar_y, 637, bar_y, $dddddd)
    LineXY(628, bar_y, 628, bar_y + bar_height, $dddddd)
    LineXY(637, bar_y + 1, 637, bar_y + bar_height, $222222)
    LineXY(629, bar_y + bar_height, 637, bar_y + bar_height, $222222)
  EndIf
  StopDrawing()  
  *item_menu\x = 434 + (*cursor\x) * 32 + 16
  *item_menu\y = 32 + (*cursor\y) * 32 + 16  
  display_menu(*item_menu)
EndProcedure


; opens inventory; returns 1 if current turn ends, else 0
Procedure open_inventory()
  Protected key_lock.b = 1, leave_inventory_screen.b = 0, main_window_event.l, esc.b
  Protected cursor.cursor_struct, item_menu.menu_struct, item_found.b, class$, item_type.w
  Protected attribute.w = 0, value.w = 0, turn_ends.b = 0, item_use$ = "", row_offset.w = 0, i.w = 0
  Protected item_can_be_equipped.b = 0, text$ = "", duration.w = 0, value_display.w = 0
  
  ; set cursor
  reset_cursor(cursor)
  cursor\x = current_character\inventory_cursor_x
  cursor\y = current_character\inventory_cursor_y
  
  ; set menu
  reset_menu(@item_menu)
  add_menu_entry(@item_menu, message_list$(#MESSAGE_DROP))
  add_menu_entry(@item_menu, message_list$(#MESSAGE_CANCEL))
  item_menu\font = #FONT_SMALL
  menu_auto_set(@item_menu, 1)
  item_menu\spacing = 0
  item_menu\padding = 0
  item_menu\menu_open = 0
  item_menu\entry_border = 0
  item_menu\border = 1
  
  ; release keyboard
  Repeat
    ExamineKeyboard()
    If KeyboardReleased(#PB_Key_All)
      key_lock = 0
    EndIf      
  Until key_lock = 0
  While leave_inventory_screen = 0
    ExamineKeyboard()
    
    ; check for windows events
    If preferences\fullscreen = 0
      main_window_event = WindowEvent()
      If main_window_event = #PB_Event_CloseWindow
        leave_inventory_screen = 1
        program_ends = 1
      EndIf
    EndIf
    
    ; ESC: leave inventory screen
    If KeyboardReleased(#PB_Key_Escape)
      leave_inventory_screen = 1
      esc = 1
    EndIf
    
    ; move cursor left
    If KeyboardPushed(#PB_Key_Left) And key_lock = 0 And cursor\x > 0 And item_menu\menu_open = 0
      cursor\x = cursor\x - 1
      key_lock = 1
    EndIf
    
    ; move cursor right
    If KeyboardPushed(#PB_Key_Right) And key_lock = 0 And cursor\x < #INVENTORY_COLUMNS - 1 And item_menu\menu_open = 0
      cursor\x = cursor\x + 1
      key_lock = 1
    EndIf
    
    ; move cursor up
    If KeyboardPushed(#PB_Key_Up) And key_lock = 0 And cursor\y > 0 And item_menu\menu_open = 0
      cursor\y = cursor\y - 1
      key_lock = 1
    EndIf
    
    ; move cursor up: scroll inventory up
    If KeyboardPushed(#PB_Key_Up) And key_lock = 0 And cursor\y = 0 And item_menu\menu_open = 0 And row_offset > 0
      For i= 2 To 30 Step 2
        inventory_screen(@cursor, @item_menu, row_offset, i)
        FlipBuffers()
      Next
      row_offset = row_offset - 1
      row_offset = row_offset - 1
      key_lock = 1
    EndIf    
    
    ; move cursor up: select previous item menu entry
    If KeyboardPushed(#PB_Key_Up) And key_lock = 0 And item_menu\menu_open = 1
      item_menu\selected_entry = item_menu\selected_entry - 1
      If item_menu\selected_entry < 0 
        item_menu\selected_entry = item_menu\number_of_entries - 1
      EndIf
      key_lock = 1
    EndIf    
    
    ; move cursor down
    If KeyboardPushed(#PB_Key_Down) And key_lock = 0 And cursor\y < #INVENTORY_ROWS - 1 And item_menu\menu_open = 0
      cursor\y = cursor\y + 1
      key_lock = 1
    EndIf
    
      ; move cursor down: scroll inventory
    If KeyboardPushed(#PB_Key_Down) And key_lock = 0 And cursor\y = #INVENTORY_ROWS - 1 And item_menu\menu_open = 0
      If row_offset < (ListSize(inventory()) - 31) / 6
        For i = 2 To 30 Step 2
          inventory_screen(@cursor, @item_menu, row_offset, -i)
          FlipBuffers()
        Next
        row_offset = row_offset + 1
        key_lock = 1
      EndIf
    EndIf  
    
    ; down: select next menu entry
    If KeyboardPushed(#PB_Key_Down) And key_lock = 0 And item_menu\menu_open = 1
      item_menu\selected_entry = item_menu\selected_entry + 1
      If item_menu\selected_entry >= item_menu\number_of_entries
        item_menu\selected_entry = 0
      EndIf
      key_lock = 1
    EndIf      
    
    ; Return: open item menu
    If KeyboardPushed(#PB_Key_Return) And item_menu\menu_open = 0 And key_lock = 0
      item_found = 0
      ForEach inventory()
        If inventory()\selected = 1
          item_type = inventory()\type
          menu_reset_entries(@item_menu)
          item_use$ = item_db(item_type)\use_name$
          If item_db(item_type)\fuel_consumed_per_use > 0 And inventory()\fuel < 1
            item_use$ = ""
          EndIf
          If item_use$ <> ""
            add_menu_entry(@item_menu, item_db(item_type)\use_name$)
          EndIf
          item_can_be_equipped = 0
          If item_db(item_type)\can_be_equipped = 1
            item_can_be_equipped = 1
          EndIf
          If item_db(item_type)\fuel > 0 And inventory()\fuel = 0
            item_can_be_equipped = 0
          EndIf
          If item_can_be_equipped = 1
            If inventory()\equipped = 1
              add_menu_entry(@item_menu, message_list$(#MESSAGE_ITEM_MENU_UNEQUIP))
            Else
              add_menu_entry(@item_menu, message_list$(#MESSAGE_ITEM_MENU_EQUIP))
            EndIf
          EndIf
          add_menu_entry(@item_menu, message_list$(#MESSAGE_DROP))
          If inventory()\amount > 1
            add_menu_entry(@item_menu, message_list$(#MESSAGE_ITEM_MENU_DROP_ALL))
          EndIf
          add_menu_entry(@item_menu, message_list$(#MESSAGE_CANCEL))
          menu_auto_set(@item_menu, 1)
          item_menu\menu_open = 1
          item_found = 1
        EndIf
      Next
      If item_found = 0
        leave_inventory_screen = 1
        cursor\x = 0
        cursor\y = 0
      EndIf
      key_lock = 1
    EndIf
    
    ; Return: select item menu entry
    If KeyboardPushed(#PB_Key_Return) And item_menu\menu_open = 1 And key_lock = 0
      ForEach inventory()
        If inventory()\selected = 1
          item_type = inventory()\type
        EndIf
      Next
      Select item_menu\menu_entry[item_menu\selected_entry]\name$
      
        Case message_list$(#MESSAGE_ITEM_MENU_EQUIP):
          item_can_be_equipped = 1
          If item_db(item_type)\equipment_limit > 0
            If number_of_equipped_items(item_db(item_type)\class$) >= item_db(item_type)\equipment_limit
              item_can_be_equipped = 0
              text$ = ReplaceString(message_list$(#MESSAGE_EQUIPMENT_LIMIT_REACHED), "[limit]", Str(item_db(item_type)\equipment_limit))
              text$ = ReplaceString(text$, "[item_class]", item_db(item_type)\class_name$)
              message(text$, "", $ffffff, item_db(item_type)\tile, 1)
            EndIf
          EndIf
          If item_can_be_equipped = 1
            ForEach inventory()
              If inventory()\selected = 1
                item_type = inventory()\type
              EndIf
            Next
            unequip_item_class(item_type)
            ForEach inventory()
              If inventory()\selected = 1
                inventory()\equipped = 1
              EndIf
            Next
            turn_ends = 1
          EndIf
          
        Case message_list$(#MESSAGE_ITEM_MENU_UNEQUIP):
          ForEach inventory()
            If inventory()\selected = 1
              inventory()\equipped = 0
            EndIf
          Next
      
        Case message_list$(#MESSAGE_DROP):
          ForEach inventory()
            If inventory()\selected = 1
              AddElement(item_on_map())
              With item_on_map()
                \xpos = current_character\xpos
                \ypos = current_character\ypos
                \type = inventory()\type
                \amount = 1
                \fuel = inventory()\fuel
                \magic_bonus = inventory()\magic_bonus
              EndWith
            EndIf
          Next
          character_loses_items(1, 0)
          
        Case message_list$(#MESSAGE_ITEM_MENU_DROP_ALL):
          ForEach inventory()
            If inventory()\selected = 1
              AddElement(item_on_map())
              With item_on_map()
                \xpos = current_character\xpos
                \ypos = current_character\ypos
                \type = inventory()\type
                \amount = inventory()\amount
                \fuel = inventory()\fuel
                \magic_bonus = inventory()\magic_bonus
              EndWith
            EndIf
          Next
          character_loses_items(0, 1)   
        
        Case item_db(item_type)\use_name$: ; use item
          If item_db(item_type)\use_message$ <> ""
            message(item_db(item_type)\use_message$, "", $ffffff, item_db(item_type)\tile, 1)
          EndIf
          value_display = 0
          For i=0 To #MAX_NUMBER_OF_ITEM_ABILITY_BONI - 1
            attribute = item_db(item_type)\ability_bonus[i]\attribute
            value = item_db(item_type)\ability_bonus[i]\value
            duration = item_db(item_type)\ability_bonus[i]\duration
            If attribute > 0 And value <> 0
              If duration = 0
                value_display = modify_attribute(attribute, value)
              Else
                current_character\ability[attribute]\power_adjustment = value
                current_character\ability[attribute]\adjustment_duration = duration
                current_character\ability[attribute]\adjustment_name$ = item_db(item_type)\name$
                current_character\ability[attribute]\adjustment_item_id = item_type
                current_character\ability[attribute]\adjustment_power_id = 0
              EndIf
            EndIf
          Next
          If item_db(item_type)\power_id > 0
            use_power_effect(item_db(item_type)\power_id)
          EndIf
          If item_db(item_type)\fuel_consumed_per_use
            inventory()\fuel = max(0, inventory()\fuel - item_db(item_type)\fuel_consumed_per_use)
          EndIf
          If item_db(item_type)\consumed_after_use = 1
            character_loses_items()
          EndIf
          If item_db(item_type)\turn_ends_after_use = 1
            turn_ends = 1
            leave_inventory_screen = 1
          EndIf
          If item_db(item_type)\identified_when_used = 1
            current_character\item_identification[item_type]\identified = 1
          EndIf
          animation(item_db(item_type)\use_animation$, 6, 6, value_display)
        
        Default:
          
      EndSelect
      key_lock = 1
      item_menu\selected_entry = 0
      item_menu\menu_open = 0      
    EndIf
    
    ; release key lock if no key is pressed
    If KeyboardReleased(#PB_Key_All)
      key_lock = 0
    EndIf        
    
    ; update screen
    blink_cursor(@cursor)
    inventory_screen(@cursor, @item_menu, row_offset)
    FlipBuffers()
  Wend
  current_character\inventory_cursor_x = cursor\x
  current_character\inventory_cursor_y = cursor\y
  update_equipment_boni()
  ProcedureReturn turn_ends
EndProcedure


;- character gets an item
Procedure character_gets_item(type.w, amount.w = 1, fuel.w = -1, magic_bonus.b = -1)
  Protected item_found.b = 0, new_item.item_in_inventory_struct
 Protected *last_item.item_in_inventory_struct
  If ListIndex(inventory()) >= 0
    *last_item = @inventory()
  EndIf
  
  If fuel = -1
    If item_db(type)\fuel_randomized = 1
      fuel = Random(max(1, item_db(type)\fuel) - 1) + 1
    Else
      fuel = item_db(type)\fuel
    EndIf
  EndIf
  If magic_bonus = -1
    If item_db(type)\artefact = 1
      magic_bonus = magic_bonus()
    Else
      magic_bonus = 0
    EndIf
  EndIf
  
  new_item\type = type
  new_item\amount = amount
  new_item\fuel = fuel
  new_item\magic_bonus = magic_bonus

  
  ; Is the same item on the inventory (only amount+1)?
  ResetList(inventory())
  While NextElement(inventory()) And item_found = 0
    If inventory()\type = new_item\type And inventory()\fuel = new_item\fuel And inventory()\magic_bonus = new_item\magic_bonus
      inventory()\amount = inventory()\amount + 1
      item_found = 1
    EndIf
  Wend
  If item_found = 0
    Protected *Element.item_in_inventory_struct = AddElement(inventory())
    If *Element <> 0  
      With *Element
        \type = new_item\type
        \amount = new_item\amount +1
        \equipped = 0
        \selected = 0
        \fuel = new_item\fuel
        \magic_bonus = new_item\magic_bonus
      EndWith
    Else
      error_message("No memory for inventory element")
    EndIf
  
  EndIf
  If *last_item
    ChangeCurrentElement(inventory(), *last_item)
  EndIf
EndProcedure


; character loses selected items from inventory; returns number of items lost
Procedure.w character_loses_items(amount_lost.w = 1, all.b = 0)
  Protected rc.w = 0, item_type.w, *last_item.item_in_inventory_struct
  If ListIndex(inventory()) >= 0
    *last_item = @inventory()
  EndIf  
  ForEach inventory()
    item_type = inventory()\type
    If inventory()\selected = 1
      If all = 1
        rc = rc + inventory()\amount
      Else
        rc = rc + min(amount_lost, inventory()\amount)
      EndIf
      inventory()\amount = inventory()\amount - amount_lost
      If inventory()\amount < 1 Or all = 1
        DeleteElement(inventory())
      EndIf
    EndIf
  Next
  If *last_item
    ChangeCurrentElement(inventory(), *last_item)
  EndIf  
  ProcedureReturn rc
EndProcedure


; character gets starting equipment
Procedure character_gets_starting_equipment()
  Protected i.w, j.w
  ClearList(inventory())
  For i = 1 To #MAX_NUMBER_OF_ITEMS - 1
    If item_db(i)\starting_equipment > 0
      character_gets_item(i, item_db(i)\starting_equipment)
    EndIf
  Next
  For i = 1 To #MAX_NUMBER_OF_ABILITIES - 1
    If current_character\ability[i]\ability_value > 0
      For j = 0 To #MAX_NUMBER_OF_ABILITY_STARTING_EQUIPMENT - 1
        If ability_db(i)\starting_equipment[j]\item > 0
          character_gets_item(ability_db(i)\starting_equipment[j]\item, ability_db(i)\starting_equipment[j]\amount)
        EndIf
      Next
    EndIf
  Next
EndProcedure


; pickup item screen
Procedure pickup_item_screen(*cursor.cursor_struct, xpos.w, ypos.w)
  Protected frame.b = 1, attribute.w = 0, bonus.w = 0, item_type.w = 0
  Protected i.b = 0, x.w, y.w, tile_type.w = 0, item_found.b = 0
  Protected tile.w, text$
  ClearScreen(0)
  draw_map_screen(@current_map)
  draw_character()
  ClipSprite(#SPRITE_Frame, 0, 6*16, 16, 16)
  DisplaySprite(#SPRITE_Frame, 0, 26*16)
  For i=1 To 39
    ClipSprite(#SPRITE_Frame, 0, 7*16 + (frame*16), 16, 16)
    DisplaySprite(#SPRITE_Frame, i*16, 26*16)
    frame = frame + 1
    If frame > 4
      frame = 0
    EndIf
  Next
  ClipSprite(#SPRITE_Frame, 0, 0, 16, 16)
  DisplaySprite(#SPRITE_Frame, 13*32, 0)
  frame = 1
  For i=1 To 25
    ClipSprite(#SPRITE_Frame, 0, frame*16 + 16, 16, 16)
    DisplaySprite(#SPRITE_Frame, 13*32, i*16)
    frame = frame + 1
    If frame > 4
      frame = 0
    EndIf
  Next
  StartDrawing(ScreenOutput())
  DrawingFont(#PB_Default)
  DrawText(416 + 16 + 2, 0, message_list$(#MESSAGE_PICKUP_ITEMS) + ":", $ffffff, 0)
  ForEach item_on_map()
    If item_on_map()\selected = 1
      item_type = item_on_map()\type
      y = 240
      text$ = item_db(item_type)\name$
      If item_db(item_type)\artefact = 1
        text$ = text$ + " + " + Str(item_on_map()\magic_bonus)
      EndIf
      If wrap_text(468, y, text$, 640-468, 16, RGB(0, 255, 255)) < 2
        DrawText(468, y + 16, item_db(item_type)\class$, RGB(255,100,0), 0)
      EndIf
      y = y + 32
      DrawingFont(FontID(#FONT_VERDANA))
      If item_on_map()\amount > 1
        DrawText(434, y, message_list$(#MESSAGE_AMOUNT) + ": " + Str(inventory()\amount), RGB(255, 100, 0), 0)
        y = y + 16
      EndIf      
      For i=0 To #MAX_NUMBER_OF_ITEM_ABILITY_BONI-1
        attribute = item_db(item_type)\ability_bonus[i]\attribute
        bonus = item_db(item_type)\ability_bonus[i]\value
        If item_db(item_type)\artefact = 1
          bonus = bonus + (item_db(item_type)\ability_bonus[i]\magic_bonus_multiplier * item_on_map()\magic_bonus)
        EndIf
        If attribute > 0
          text$ = ability_db(attribute)\name$
          If bonus > 0
            text$ = text$ + " + "
          EndIf
          text$ = text$ + Str(bonus)
          If ability_db(attribute)\percentage = 1
            text$ = text$ + "%"
          EndIf
          DrawText(434, y, shorten_text(text$, 170), RGB(0, 255, 0), 0)
          y = y + 16
        EndIf       
      Next
      If item_db(item_type)\fuel > 0 And item_db(item_type)\fuel_name$ <> ""
        text$ = ReplaceString(item_db(item_type)\fuel_name$, "[fuel]", Str(item_on_map()\fuel))
        DrawText(434, y, shorten_text(text$, 170), RGB(255, 0, 0), 0)
        y = y + 16
      EndIf             
      DrawText(434, y, shorten_text(message_list$(#MESSAGE_WEIGHT) + ": " + Str(item_db(item_type)\weight) + " " + message_list$(#MESSAGE_POUND), 170), RGB(255,0,0), 0)
      y = y + 16
      DrawingFont(FontID(#FONT_SMALL))      
      y = y + wrap_text(434, y, item_db(item_type)\description$, 170, 12, $ffffff)
    EndIf
  Next  
  StopDrawing()
  ForEach item_on_map()
    item_on_map()\selected = 0
  Next
  clip_power_tile_sprite(0)  
  ResetList(item_on_map())
  x = 0
  y = 0  
  While y < 6
    While NextElement(item_on_map()) And y < 6
      If item_on_map()\xpos = xpos And item_on_map()\ypos = ypos
        If item_on_map()\selected_for_pickup = 1
          clip_item_tile_sprite(#TILE_ITEM_EQUIPPED)
          DisplaySprite(#SPRITE_ITEMS, 434 + x * 32, 32 + y * 32)
          clip_item_tile_sprite(item_db(item_on_map()\type)\tile)
          DisplayTransparentSprite(#SPRITE_ITEMS, 434 + x * 32, 32 + y * 32)          
        Else
          clip_item_tile_sprite(item_db(item_on_map()\type)\tile)
          DisplaySprite(#SPRITE_ITEMS, 434 + x * 32, 32 + y * 32)
        EndIf
        If *cursor\x = x And *cursor\y = y
          item_on_map()\selected = 1
          DisplaySprite(#SPRITE_ITEMS, 434, 240)
          ClipSprite(#SPRITE_CURSOR, *cursor\frame * 32, 0, 32, 32)
          DisplayTransparentSprite(#SPRITE_CURSOR, 434 + x * 32, 32 + y * 32)
        EndIf
        x = x + 1
        If x > 5
          y = y + 1
          x = 0       
        EndIf
      EndIf
    Wend
    If y < 6
      DisplaySprite(#SPRITE_POWERS, 434 + x * 32, 32 + y * 32)
    EndIf
    If *cursor\x = x And *cursor\y = y
      ClipSprite(#SPRITE_CURSOR, *cursor\frame * 32, 0, 32, 32)
      DisplayTransparentSprite(#SPRITE_CURSOR, 434 + x * 32, 32 + y * 32)
    EndIf
    x = x + 1
    If x > 5
      y = y + 1
      x = 0
    EndIf
  Wend
EndProcedure


;- pickup multiple items; returns 1 if at least one item is picked up, else 0 
Procedure.b pickup_items(xpos.w, ypos.w)
  Protected rc.b = 0, number_of_items.w = 0, item_tile.w, tile_type.w
  Protected key_lock.b = 1, leave_pickup_screen.b = 0, main_window_event.l, esc.b
  Protected cursor.cursor_struct, item_found.b, class$, item_type.w
  Protected message_line1$ = "", message_line2$ = "", items_left.w = 0
  
  ;- check for items on map on position xpos / ypos
  ForEach item_on_map()
    item_on_map()\selected = 0
    item_on_map()\selected_for_pickup = 0
    If item_on_map()\xpos = xpos And item_on_map()\ypos = ypos
      number_of_items = number_of_items + 1
    EndIf
  Next
  If number_of_items = 0
    leave_pickup_screen = 1
    message(message_list$(#MESSAGE_NO_ITEMS_TO_PICKUP),"")
    play_sound("failure")
  EndIf
  
  ; set cursor
  reset_cursor(cursor)
  cursor\x = 0
  cursor\y = 0

  ; release keyboard
  Repeat
    ExamineKeyboard()
    If KeyboardReleased(#PB_Key_All)
      key_lock = 0
    EndIf      
  Until key_lock = 0
  While leave_pickup_screen = 0
  
    ExamineKeyboard()
    
    ;- check for windows events
    If preferences\fullscreen = 0
      main_window_event = WindowEvent()
      If main_window_event = #PB_Event_CloseWindow
        leave_pickup_screen = 1
        program_ends = 1
      EndIf
    EndIf
    
    ;- ESC: leave inventory screen
    If KeyboardReleased(#PB_Key_Escape)
      leave_pickup_screen = 1
      esc = 1
    EndIf
    
    ;- move cursor left
    If KeyboardPushed(#PB_Key_Left) And key_lock = 0 And cursor\x > 0
      cursor\x = cursor\x - 1
      key_lock = 1
    EndIf
    
    ;- move cursor right
    If KeyboardPushed(#PB_Key_Right) And key_lock = 0 And cursor\x < 5
      cursor\x = cursor\x + 1
      key_lock = 1
    EndIf
    
    ;- move cursor up
    If KeyboardPushed(#PB_Key_Up) And key_lock = 0 And cursor\y > 0
      cursor\y = cursor\y - 1
      key_lock = 1
    EndIf  
    
    ;- move cursor down
    If KeyboardPushed(#PB_Key_Down) And key_lock = 0 And cursor\y < 5
      cursor\y = cursor\y + 1
      key_lock = 1
    EndIf   
    
    ;- Space: select item for pickup
    If KeyboardPushed(#PB_Key_Space) And key_lock = 0 
      ForEach item_on_map()
        If item_on_map()\selected = 1
          If item_on_map()\selected_for_pickup = 1
            item_on_map()\selected_for_pickup = 0
          Else
            item_on_map()\selected_for_pickup = 1
          EndIf
        key_lock = 1
        EndIf
      Next
    EndIf
    
    ;- A: select all item for pickup
    If KeyboardPushed(#PB_Key_A) And key_lock = 0 
      ForEach item_on_map()
     ;   If item_on_map()\selected = 1
          If item_on_map()\selected_for_pickup = 1
            item_on_map()\selected_for_pickup = 0
          Else
            item_on_map()\selected_for_pickup = 1
          EndIf
        key_lock = 1
  ;      EndIf
      Next
    EndIf
    
    ;- Return: leave pickup screen
    If KeyboardPushed(#PB_Key_Return) And key_lock = 0
      leave_pickup_screen = 1
      key_lock = 1
    EndIf
    
    ; release key lock if no key is pressed
    If KeyboardReleased(#PB_Key_All)
      key_lock = 0
    EndIf        
    
    ; update screen
    blink_cursor(@cursor)
    pickup_item_screen(@cursor, xpos, ypos)
    FlipBuffers()
  Wend
  number_of_items = 0
  message_line1$ = ""
  message_line2$ = ""
  If esc = 0
    ForEach item_on_map()
      If item_on_map()\selected_for_pickup = 1
        number_of_items = number_of_items + 1
        item_tile = item_db(item_on_map()\type)\tile
        If message_line2$ <> ""
          message_line2$ = message_line2$ + ", "
        EndIf
        message_line2$ = message_line2$ + item_db(item_on_map()\type)\name$
        character_gets_item(item_on_map()\type, item_on_map()\amount, item_on_map()\fuel, item_on_map()\magic_bonus)
        DeleteElement(item_on_map())        
      EndIf
    Next
    If number_of_items > 0
      rc = 1
      If number_of_items = 1
        message_line1$ = message_list$(#MESSAGE_PICKUP_AN_ITEM) + ":"
      Else
        message_line1$ = message_list$(#MESSAGE_PICKUP_SOME_ITEMS) + ":"
      EndIf
      message(message_line1$, message_line2$, $ffffff, item_tile, 1)
    EndIf  
    update_equipment_boni()
    tile_type = read_map_tile_type(@current_map, xpos, ypos)
    If current_map\tileset\tile_type_db[tile_type]\container > 0
      items_left = 0
      ForEach item_on_map()
        If item_on_map()\xpos = xpos And item_on_map()\ypos = ypos
          items_left = items_left + 1
        EndIf
      Next
      If items_left = 0
        set_map_tile_type(@current_map, xpos, ypos, current_map\background_tile)
      EndIf
    EndIf
  EndIf
  ProcedureReturn rc
EndProcedure


; returns number of item types in item database
Procedure.w number_of_item_types()
  Protected rc.w, i.w
  For i=1 To #MAX_NUMBER_OF_ITEMS - 1
    If item_db(i)\name$ <> ""
      rc = rc + 1
    EndIf
  Next
  ProcedureReturn rc
EndProcedure


; returns random magic bonus for artefact
Procedure.w magic_bonus()
  Protected rc.w = 1
  While Random(1) = 0 And rc < 999
    rc = rc + 1
  Wend
  ProcedureReturn rc
EndProcedure


; returns a random item type
Procedure.w random_item_type(rarity.l = 5, class$ = "", artefact.b = 0)
  Protected NewList items.w(), i.w = 0, count.w = 0, r.w, rc.w = 0, stop_count.b = 0, add_item.b = 0
  Repeat
    ClearList(items())
    count = 0
    For i=1 To #MAX_NUMBER_OF_ITEMS - 1
      add_item = 0
      If item_db(i)\name$ <> "" And Random(rarity) > item_db(i)\price
        add_item = 1
        If class$ <> ""
          If item_db(i)\class$ <> class$
            add_item = 0
          EndIf
        EndIf
        If artefact = 1
          If item_db(i)\artefact = 0
            add_item = 0
          EndIf
        EndIf
      EndIf
      If add_item = 1
        AddElement(items())
        items() = i
        count = count + 1
      EndIf
    Next
  Until ListSize(items()) > 0 Or stop_count > 100
  If ListSize(items()) > 0
    r = Random(count - 1)
    i = 0
    ForEach items()
      If i = r
        rc = items()
      EndIf
      i = i + 1
    Next
  EndIf
  ClearList(items())
  ProcedureReturn rc
EndProcedure


; adds a random item to position x/y to the map
Procedure add_random_item(x.w, y.w, rarity.w = 5, class$ = "")
  Protected item_type.w = 0, i.w, count.w
  AddElement(item_on_map())
  item_type = random_item_type(rarity, class$)
  With item_on_map()
    \xpos = x
    \ypos = y
    \type = item_type
    \amount = 1
    \fuel = item_db(item_type)\fuel
    \magic_bonus = 0
  EndWith
  If item_db(item_type)\artefact = 1
    item_on_map()\magic_bonus = magic_bonus()
  EndIf
EndProcedure
; IDE Options = PureBasic 6.10 beta 6 (Windows - x64)
; CursorPosition = 1175
; FirstLine = 1133
; Folding = ----
; EnableXP
; CompileSourceDirectory
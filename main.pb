; Lost Labyrinth VI: Portals 0.3.0
; main file
; written in PureBasic 4.30 (http://www.purebasic.com)
; created:  08.10.2008 Frank Malota <malota@web.de>
; modified: 26.01.2009 Frank Malota <malota@web.de>
; total number of hours of programming: 128
; --------------------------------------------
; Switch to PureBasic 6.0 and Github
; modified: 202206 Peter Eismann
; total number of hours of programming: 10

; include files
EnableExplicit
XIncludeFile "constants.pb"
XIncludeFile "error_handling.pb"
XIncludeFile "misc.pb"
XIncludeFile "preferences.pb"
XIncludeFile "messages.pb"
XIncludeFile "map_handling.pb"
XIncludeFile "menu.pb"
XIncludeFile "graphics.pb"
XIncludeFile "character.pb"
XIncludeFile "monster.pb"
XIncludeFile "powers.pb"
XIncludeFile "items.pb"
XIncludeFile "sound.pb"


; set current directory to program file; uncomment before compiling final version
; SetCurrentDirectory(GetPathPart(ProgramFilename()))

;save_preferences(@preferences)

; initialize keyboard & mouse input
If InitKeyboard() = 0
  error_message("Can't open keyboard for input!")
EndIf
If InitMouse() = 0
  error_message("Can't open mouse for input!")
EndIf

; init graphics engine
UsePNGImageDecoder()
UseJPEGImageEncoder()
UseJPEGImageDecoder()
If InitSprite() = 0
  error_message("Can't open sprite environment!")
EndIf


; init sound
If InitSound() = 0
  isSoundSupported = #False
  error_message("Can't InitSound!")
EndIf
UseOGGSoundDecoder()
load_sound()


; define variables used in main loop
Define step_nr.w = 0
Define direction.b = 0
Define x.w = 0
Define y.w = 0
Global main_window_event.l = 0 ; id for event that occured in main window
Global update_screen.b = 1     ; flag; if set, update screen
Define character_moved.b = 0   ; flag: character has moved
Global game_paused.b = 0       ; flag: 1=game is paused
Define turn_ends.b = 0         ; flag; 1=current turn ends
Global goto_main_menu.b = 1    ; flag: 1=goto main screen
Global character_died.b = 0
Define save_game_at_exit.b = 1 ; flag: save game when exiting
Define key_lock.b = 0          ; flag: 1=keyboard locked
Define update_equipment_boni.b = 0 ; flag; if set, update boni provided by equipment
Define blocked_by_monster.b = 0    ; flag; 1=character is blocked by a monster
Define dx.b = 0                    ; xpos modification when moving character
Define dy.b = 0                    ; ypos modification when moving character
Define modify_value.w = 0          ; modifier for attributes
Define i.w = 0                     ; default counter


Procedure initAll()
  game_paused = 0
  program_ends = 0
  character_died = 0
  ; set preferences
  load_preferences(@preferences)
  ; load message list
  load_message_list()
  ; initialize misc dbs
  load_abilities_db()
  load_monster_db()
  load_power_db()
  load_item_db()
  ability_db_resolve_names()
  item_db_resolve_names()
  
EndProcedure


initAll()


If preferences\fullscreen = 0
  open_windowed_screen()
Else
  open_fullscreen()
EndIf


; load resources
load_sprites()


; load savegame or create new character
If FileSize("savegame\character.xml") > 0
  load_character(@current_character)
  load_map(@current_map, "savegame\" + GetFilePart(current_character\map_filename$))  
EndIf




; main loop
While program_ends = 0
  
  ; check for keyboard input
  ExamineKeyboard()
  
  character_moved = 0
  dx = 0
  dy = 0
  
  ; main menu
  If goto_main_menu = 1
    update_screen = 1
    goto_main_menu = 0
    game_paused = 0
    program_ends = 0
    character_died = 0
    Select main_menu()
        
      Case message_list$(#MESSAGE_MENU_SPLASH_NEW_GAME), message_list$(#MESSAGE_MENU_SPLASH_NEW_GAME_DEUTSCH), message_list$(#MESSAGE_MENU_SPLASH_NEW_GAME_ENGLISH):
        If program_ends = 0
          delete_savegame()
          init_character(@current_character)
          experience(3, 1)
          character_gets_starting_equipment()
          load_map(@current_map, "maps\" + GetFilePart(current_character\map_filename$))
          save_character(@current_character)
          save_map(@current_map, "savegame\" + GetFilePart(current_map\filename$))
        EndIf
        
      Case message_list$(#MESSAGE_MENU_SPLASH_CONTINUE_GAME): 
        If program_ends = 0
          load_character(@current_character)
          load_map(@current_map, "savegame\" + GetFilePart(current_character\map_filename$))
        EndIf
        
      Case message_list$(#MESSAGE_MENU_SPLASH_EXIT):
        program_ends = 1
        
    EndSelect
  EndIf
  
  ; check for windows events
  If preferences\fullscreen = 0
    main_window_event = WindowEvent()
    If main_window_event = #PB_Event_CloseWindow
      program_ends = 1
    EndIf
  EndIf
  
  ; escape key: goto main menu
  If KeyboardReleased(#PB_Key_Escape)
    ClearScreen(0)
    draw_map_screen(@current_map)
    draw_frame_main_screen() 
    draw_right_panel()
    draw_character()
    If preferences\fade_effect = 1
      DisplayTransparentSprite(#SPRITE_FADEOUT_TOTAL, 0, 0, 150)
    EndIf
    FlipBuffers()
    screenshot("savegame\screenshot.jpg")
    save_map(@current_map, "savegame\" + GetFilePart(current_map\filename$))
    save_character(@current_character)
    goto_main_menu = 1
    game_paused = 1
  EndIf
  
  ; ALT-X: end program without saving
  If KeyboardPushed(#PB_Key_LeftAlt) And KeyboardPushed(#PB_Key_X)
    program_ends = 1
  EndIf
  
  ; up: move character up
  If KeyboardPushed(key_binding(#ACTION_UP)\keycode) And game_paused = 0
    If movement_left() > 0
      dx = 0
      dy = -1
    EndIf
    current_character\facing = 0
    update_screen = 1
  EndIf
  
  ; down: move character down
  If KeyboardPushed(key_binding(#ACTION_DOWN)\keycode) And game_paused = 0
    If movement_left() > 0
      dx = 0
      dy = 1
    EndIf
    current_character\facing = 2
    update_screen = 1
  EndIf
  
  ; right: move character right
  If KeyboardPushed(key_binding(#ACTION_RIGHT)\keycode) And game_paused = 0
    If movement_left() > 0
      dx = 1
      dy = 0
    EndIf
    current_character\facing = 1
    update_screen = 1
  EndIf
  
  ; left: move character left
  If KeyboardPushed(key_binding(#ACTION_LEFT)\keycode) And game_paused = 0
    If movement_left() > 0
      dx = -1
      dy = 0
    EndIf
    current_character\facing = 3
    update_screen = 1
  EndIf   
  
  ; move character
  If (dx <> 0 Or dy <> 0) And game_paused = 0
    update_screen = 1
    blocked_by_monster = 0
    If current_character\xpos + dx >= 0 And current_character\xpos + dx < #MAP_DIMENSION_X - 1 And current_character\ypos + dy >= 0 And current_character\ypos + dy < #MAP_DIMENSION_Y - 1
      If field_contains_monster(current_character\xpos + dx, current_character\ypos + dy)
        blocked_by_monster = 1
        If sneaking_val(1) > 0 And backstabbing_val(1) = 0; character tries to sneak
          If Random(99) >= sneaking_val(1) Or monster_is_alerted(current_character\xpos + dx, current_character\ypos + dy)
            play_sound("oh_no")
            alert_monster(current_character\xpos + dx, current_character\ypos + dy)
            message(message_list$(#MESSAGE_MONSTER_NOTICES_YOU), "")
            turn_ends = 1
          Else
            blocked_by_monster = 0
            play_sound("evasion")
            message(message_list$(#MESSAGE_YOU_SNEAK_UNNOTICED_BY), "")
          EndIf
        Else
          character_attacks_monster(@current_map, current_character\xpos + dx, current_character\ypos + dy)
          turn_ends = 1
        EndIf
      EndIf
      If blocked_by_monster = 0
        trigger_map_event(@current_map, current_character\xpos + dx, current_character\ypos + dy)
        trigger_map_message(@current_map, current_character\xpos + dx, current_character\ypos + dy)
        If field_is_blocked(@current_map, current_character\xpos + dx, current_character\ypos + dy) = 0
          current_character_change_frame()
          If dx > 0 Or dy > 0
            current_character\xpos = current_character\xpos + dx
            current_character\ypos = current_character\ypos + dy
            For i=30 To 2 Step -#SETTING_MAP_SCREEN_SCROLLING_STEP
              draw_main_screen_complete(@current_map, dx * i, dy * i)
              current_character_change_frame()
            Next
          Else
            For i=2 To 30 Step #SETTING_MAP_SCREEN_SCROLLING_STEP
              draw_main_screen_complete(@current_map, Abs(dx) * i, Abs(dy) * i)
              current_character_change_frame()             
            Next
            current_character\xpos = current_character\xpos + dx
            current_character\ypos = current_character\ypos + dy            
          EndIf
          character_moved = 1
        EndIf
      EndIf
    EndIf
  EndIf
  
  ; ALT-Enter: toggle between windowed screen and fullscreen
  If KeyboardPushed(#PB_Key_LeftAlt) And KeyboardPushed(#PB_Key_Return)
    toggle_fullscreen(@current_map\tileset)
    update_screen = 1
  EndIf
  
  ; Character info
  If KeyboardPushed(#PB_Key_C) And game_paused = 0
    character_info_screen()
    FlipBuffers()
    game_paused = 1
  EndIf
  
  ; use power
  If KeyboardPushed(#PB_Key_U) And game_paused = 0 And key_lock = 0
    If use_power() = 1
      turn_ends = 1
    EndIf
    update_screen = 1
    key_lock = 1
  EndIf
  
  ; pickup items
  If KeyboardPushed(#PB_Key_P) And game_paused = 0 And key_lock = 0
    pickup_items(current_character\xpos, current_character\ypos)
    key_lock = 1
    update_screen = 1
  EndIf
  
  ; open inventory
  If KeyboardPushed(#PB_Key_I) And game_paused = 0 And key_lock = 0
    open_inventory()
    update_screen = 1
    key_lock = 1
  EndIf
  
  ; end turn
  If KeyboardPushed(#PB_Key_E) And game_paused = 0 And key_lock = 0
    turn_ends = 1
    update_screen = 1
    key_lock = 1
  EndIf 
  
  ; T-Key: trigger test
  If KeyboardPushed(#PB_Key_T) And key_lock = 0
    scramble_item_db_tiles("Potion")
  EndIf
  
  ; check for field effects after character has moved
  If character_moved = 1 And game_paused = 0
    If enter_field() = 1
      turn_ends = 1
    EndIf
    If detect_hidden_fields() = 1
      draw_main_screen_complete(@current_map, 0,0)
      Delay(1000)
    EndIf
    If field_is_open_portal(@current_map, current_character\xpos, current_character\ypos) = 1
      enter_portal()
      update_screen = 1
    Else
      If field_contains_dungeon_entrance(current_character\xpos, current_character\ypos)
        enter_dungeon()
        update_screen = 1
      EndIf
    EndIf
    For i = 1 To #MAX_NUMBER_OF_ABILITIES - 1
      If ability_db(i)\change_per_move <> 0
        modify_attribute(i, ability_db(i)\change_per_move)
      EndIf
      If turn_ends = 0 And ability_db(i)\turn_ends_if_lower > -32000
        If attribute_current_val(i) < ability_db(i)\turn_ends_if_lower
          turn_ends = 1
        EndIf
      EndIf
    Next
  EndIf
  
  ; remove game paused status
  If KeyboardPushed(#PB_Key_Return) And game_paused = 1
    game_paused = 0
    update_screen = 1
  EndIf
  
  ; release key lock if no key is pressed
  If KeyboardReleased(#PB_Key_All)
    key_lock = 0
  EndIf
  
  ; end of turn
  If turn_ends = 1
    ; adjust attributes at end of turn
    For i = 1 To #MAX_NUMBER_OF_ABILITIES - 1
      If ability_db(i)\modify_attribute > 0
        modify_value = attribute_current_val(i)
        If modify_value <> 0
          If ability_db(i)\modify_divisor > 1
            modify_value = (modify_value + ability_db(i)\modify_divisor - 1)/ ability_db(i)\modify_divisor
          EndIf
          If ability_db(i)\modify_multiplier <> 1
            modify_value = modify_value * ability_db(i)\modify_multiplier
          EndIf          
        EndIf
        If modify_value <> 0
          modify_attribute(ability_db(i)\modify_attribute, modify_value)
          If ability_db(i)\modify_sound$ <> ""
            play_sound(ability_db(i)\modify_sound$)
          EndIf
          If ability_db(i)\modify_animation$ <> ""
            animation(ability_db(i)\modify_animation$, 6, 6, Abs(modify_value))
          EndIf
        EndIf
      EndIf
      If ability_db(i)\change_per_turn <> 0
        If Random(99) < ability_db(i)\change_per_turn_chance
          modify_attribute(i, ability_db(i)\change_per_turn)
        EndIf
      EndIf
      If current_character\ability[i]\power_adjustment <> 0 Or current_character\ability[i]\adjustment_duration <> 0
        current_character\ability[i]\adjustment_duration = current_character\ability[i]\adjustment_duration - 1
        If current_character\ability[i]\adjustment_duration < 1
          current_character\ability[i]\power_adjustment = 0
          current_character\ability[i]\adjustment_duration = 0
          current_character\ability[i]\adjustment_name$ = ""
          current_character\ability[i]\adjustment_power_id = 0
        EndIf
      EndIf
    Next
    ; reduce cooldown for all powers
    For i = 1 To #MAX_NUMBER_OF_POWERS - 1
      If current_character\power[i]\cooldown > 0
        current_character\power[i]\cooldown = max(0, current_character\power[i]\cooldown - 1)
      EndIf
    Next
    move_all_monster()
    monster_attacks_character(current_character\xpos, current_character\ypos - 1)
    monster_attacks_character(current_character\xpos + 1, current_character\ypos)
    monster_attacks_character(current_character\xpos, current_character\ypos + 1)
    monster_attacks_character(current_character\xpos - 1, current_character\ypos)
    monster_turn_ends()
    spawn_random_monster(@current_map)    
    ; fuel of equipped items is reduced
    ForEach inventory()
      If inventory()\equipped = 1
        If item_db(inventory()\type)\fuel > 0
          inventory()\fuel = inventory()\fuel - item_db(inventory()\type)\fuel_consumed_per_turn
          If inventory()\fuel < 1
            inventory()\fuel = 0
            inventory()\equipped = 0
            update_equipment_boni = 1
          EndIf
        EndIf
      EndIf
    Next
    For i = 1 To #MAX_NUMBER_OF_ABILITIES - 1
      If ability_db(i)\restore_at_end_of_turn = 1
        restore_attribute(i)
      EndIf
    Next
    turn_ends = 0
    update_screen = 1
  EndIf
  
  ; character death
  If character_died() And program_ends = 0
    play_sound("deathcry")
    fade_map_screen_out(@current_map)    
    ClearScreen(0)
    draw_map_screen(@current_map)
    draw_frame_main_screen() 
    draw_right_panel()
    draw_character(0)
    If preferences\fade_effect = 1  
      DisplayTransparentSprite(#SPRITE_FADEOUT_TOTAL, 0, 0, 150)
    EndIf
    FlipBuffers()    
    screenshot("savegame\screenshot.jpg")
    delete_savegame()
    character_died = 1
    goto_main_menu = 1
    game_paused = 1
    update_screen = 0
  EndIf
  
  ; update boni provided by equipment
  If update_equipment_boni = 1
    update_equipment_boni()
    update_equipment_boni = 0
  EndIf
  
  ; update screen
  If update_screen = 1
    draw_main_screen_complete(@current_map, 0,0)
    update_screen = 0
  EndIf
  
Wend

; save current game
If FileSize("savegame\character.xml") > 0
  save_map(@current_map, "savegame\" + GetFilePart(current_map\filename$))
  save_character(@current_character)
EndIf

End
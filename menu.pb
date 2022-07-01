; Lost Labyrinth VI: Portals
; menu handling procedures
; written in PureBasic 4.20 (http://www.purebasic.com)
; created:  29.10.2008 Frank Malota <malota@web.de>
; modified: 21.12.2008 Frank Malota <malota@web.de>

; declarations
Declare toggle_fullscreen(*tileset.tileset_struct, load_tileset.b=1)
Declare delete_savegame()


; reset menu entries
Procedure menu_reset_entries(*menu.menu_struct)
  Protected i.w
  For i=0 To #MAX_NUMBER_OF_MENU_ENTRIES-1
    *menu\menu_entry[i]\name$ = ""
  Next
  *menu\number_of_entries = 0
EndProcedure


; reset menu
Procedure reset_menu(*menu.menu_struct)
  *menu\x = 0
  *menu\y = 0
  *menu\width = 0
  *menu\entry_height = 0
  *menu\padding = 2
  *menu\spacing = 4
  *menu\selected_entry = 0
  *menu\color = $ffffff
  *menu\use_mouse = 0
  *menu\mouse_over_entry = -1
  *menu\menu_open = 1
  *menu\border = 0
  *menu\entry_border = 1
  *menu\font = 0
  *menu\entry_highlight = 0
  *menu\entry_highlight_color1 = 0
  *menu\entry_highlight_color2 = 0
  menu_reset_entries(*menu.menu_struct)
EndProcedure


; sets menu parameter automatically
Procedure menu_auto_set(*menu.menu_struct, start_drawing.b = 0)
  Protected i.w
  If start_drawing = 1
    StartDrawing(ScreenOutput())
  EndIf
  If *menu\font > 0
    DrawingFont(FontID(*menu\font))
  EndIf
  *menu\number_of_entries = 0
  For i=0 To #MAX_NUMBER_OF_MENU_ENTRIES-1
    If TextWidth(*menu\menu_entry[i]\name$) + *menu\padding + *menu\padding > *menu\width
      *menu\width = TextWidth(*menu\menu_entry[i]\name$) + *menu\padding + *menu\padding 
    EndIf
    If TextHeight(*menu\menu_entry[i]\name$) + *menu\padding + *menu\padding > *menu\entry_height
      *menu\entry_height = TextHeight(*menu\menu_entry[i]\name$) + *menu\padding + *menu\padding
    EndIf
    If *menu\menu_entry[i]\name$ <> ""
      *menu\number_of_entries = *menu\number_of_entries + 1
    EndIf
  Next
  If start_drawing = 1
    StopDrawing()
  EndIf
EndProcedure



; adds new entry to menu; returns index of new entry
Procedure.w add_menu_entry(*menu.menu_struct, option$)
  Protected i.w = 0, rc.w = 0, stop.b = 0
  While i<#MAX_NUMBER_OF_MENU_ENTRIES And stop = 0
    If *menu\menu_entry[i]\name$ = ""
      *menu\menu_entry[i]\name$ = option$
      rc = i
      stop = 1
    EndIf
    i = i + 1
  Wend
  ProcedureReturn rc
EndProcedure


; displays menu
Procedure display_menu(*menu.menu_struct, start_drawing.b = 1)
  Protected x.w, y.w, i.w
  If *menu\menu_open = 1
    If start_drawing = 1
      StartDrawing(ScreenOutput())
    EndIf
    If *menu\font > 0
      DrawingFont(FontID(*menu\font))
    EndIf
    x = *menu\x
    y = *menu\y
    If *menu\width = 0
      menu_auto_set(*menu)
    EndIf
    *menu\mouse_over_entry = -1
    If *menu\border > 0 ; box around complete menu
      Box(x-1, y-1, *menu\width+3, (*menu\entry_height + *menu\padding + *menu\padding + *menu\spacing) * (*menu\number_of_entries)+3, *menu\color)
      Box(x, y, *menu\width, (*menu\entry_height + *menu\spacing) * (*menu\number_of_entries), 0)
    EndIf
    For i=0 To *menu\number_of_entries-1
      ; box around each entry
      If *menu\entry_border > 0 Or *menu\selected_entry = i
        Box(x, y, *menu\width, *menu\entry_height, *menu\color)
        If *menu\selected_entry = i And *menu\entry_highlight = 1
          LineXY(x, y, x + *menu\width, y, *menu\entry_highlight_color1)
          LineXY(x, y, x, y + *menu\entry_height, *menu\entry_highlight_color1)
          LineXY(x + *menu\width, y + 1, x + *menu\width, y + *menu\entry_height, *menu\entry_highlight_color2)
          LineXY(x + 1, y + *menu\entry_height, x + *menu\width, y + *menu\entry_height, *menu\entry_highlight_color2)
        EndIf
      EndIf
      If *menu\use_mouse = 1
        If *menu\mouse_x >= *menu\x And *menu\mouse_x <= *menu\x + *menu\width And *menu\mouse_y >= y And *menu\mouse_y <= y + *menu\entry_height And *menu\mouse_over_entry = -1
          *menu\selected_entry = i
          *menu\mouse_over_entry = i
        EndIf
      EndIf
      If *menu\selected_entry = i
        DrawText(x + *menu\padding + *menu\entry_border + *menu\border, y + *menu\padding + *menu\entry_border + *menu\border, *menu\menu_entry[i]\name$, 0, *menu\color)
      Else
        ; empty box inside of entries not selected
        Box(x + 1, y + 1, *menu\width - (*menu\entry_border * 2), *menu\entry_height - 2, 0)
        DrawText(x + *menu\padding + *menu\entry_border + *menu\border, y + *menu\padding + *menu\entry_border + *menu\border, *menu\menu_entry[i]\name$, *menu\color, 0)
      EndIf
      y = y + *menu\entry_height + *menu\spacing + *menu\padding
    Next
    If start_drawing = 1
      StopDrawing()
    EndIf
  EndIf
EndProcedure


; main menu; returns selected menu entry
Procedure.s main_menu()
  Protected update_screen.b = 0, leave_splashscreen.b = 0, option.b = 0, key_lock.b = 0
  Protected mouse_x.w, mouse_y.w, mouse_button.b, main_window_event.l, gadget.l
  Protected background.b = 0, spr.i, event_type.w
  reset_menu(@menu)
  If FileSize("savegame\character.xml") > 0
    add_menu_entry(@menu, message_list$(#MESSAGE_MENU_SPLASH_CONTINUE_GAME))
  EndIf
  add_menu_entry(@menu, message_list$(#MESSAGE_MENU_SPLASH_NEW_GAME))
  add_menu_entry(@menu, message_list$(#MESSAGE_MENU_SPLASH_EXIT))
  With menu
    \color = RGB(255, 100, 0)
    \padding = 6
    \x = 280
    \y = 250
    \use_mouse = 1
    \entry_highlight = 1
    \entry_highlight_color1 = RGB(255, 200, 125)
    \entry_highlight_color2 = RGB(125, 75, 0)
  EndWith
  ClearScreen(0)
  If FileSize("savegame\screenshot.jpg") > 0
    background = 1
    spr = LoadSprite(#PB_Any, "savegame\screenshot.jpg")
    DisplaySprite(spr, 0, 0)
  EndIf  
  DisplayTransparentSprite(#SPRITE_SPLASH, 320-SpriteWidth(#SPRITE_SPLASH)/2, 0)
  display_menu(@menu)
  FlipBuffers()  
  While leave_splashscreen = 0
    
    ExamineKeyboard()
    If preferences\fullscreen = 0
      main_window_event = WindowEvent()
      event_type = EventType()
      If main_window_event = #PB_Event_CloseWindow
        program_ends = 1
        leave_splashscreen = 1
      EndIf
      menu\mouse_x = WindowMouseX(0)
      menu\mouse_y = WindowMouseY(0)
      If main_window_event = #WM_LBUTTONDOWN And menu\mouse_over_entry > -1
        leave_splashscreen = 1
      EndIf
    Else
      ExamineMouse()
      menu\mouse_x = MouseX()
      menu\mouse_y = MouseY()
      If MouseButton(#PB_MouseButton_Left) And menu\mouse_over_entry > -1
        leave_splashscreen = 1
      EndIf
    EndIf
    
    ; toggle between fullscreen and windowed screen
    If KeyboardPushed(#PB_Key_LeftAlt) And KeyboardPushed(#PB_Key_Return) And key_lock = 0
      toggle_fullscreen(@current_map\tileset, 0)
      If FileSize("savegame\screenshot.jpg") > 0
        background = 1
        spr = LoadSprite(#PB_Any, "savegame\screenshot.jpg")
        DisplaySprite(spr, 0, 0)
      EndIf        
      update_screen = 1
      key_lock = 1
    EndIf
    
    ; ESC key: leave program
    If KeyboardReleased(#PB_Key_Escape)
      program_ends = 1
      leave_splashscreen = 1
    EndIf
    
    ; up: select previous menu entry
    If KeyboardPushed(#PB_Key_Up) And key_lock = 0
      menu\selected_entry = menu\selected_entry - 1
      If menu\selected_entry < 0 
        menu\selected_entry = menu\number_of_entries - 1
      EndIf
      update_screen = 1
      key_lock = 1
    EndIf
    
    ; down: select next menu entry
    If KeyboardPushed(#PB_Key_Down) And key_lock = 0
      menu\selected_entry = menu\selected_entry + 1
      If menu\selected_entry >= menu\number_of_entries
        menu\selected_entry = 0
      EndIf
      ;update_screen = 1
      key_lock = 1
    EndIf  
    
    ; RETURN: menu entry has been chosen
    If KeyboardPushed(#PB_Key_Return) And key_lock = 0
      leave_splashscreen = 1
    EndIf
    
    ; release key lock if no key is pressed
    If KeyboardReleased(#PB_Key_All)
      key_lock = 0
    EndIf
      
    ; draw screen
    ;If update_screen = 1
      ClearScreen(0)
      If background = 1
        DisplaySprite(spr, 0, 0)
      EndIf
      DisplayTransparentSprite(#SPRITE_SPLASH, 320-SpriteWidth(#SPRITE_SPLASH)/2, 0)
      display_menu(@menu)
      If preferences\fullscreen = 1
        DisplayTransparentSprite(#SPRITE_MOUSEPOINTER, menu\mouse_x, menu\mouse_y)
      EndIf
      If current_character\game_end_message$ <> ""
        StartDrawing(ScreenOutput())
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawText(320 - TextWidth(current_character\game_end_message$) / 2, 170, current_character\game_end_message$, RGB(255,0,0), 0)
        StopDrawing()
      EndIf
      FlipBuffers()
    ;EndIf
  
  Wend
  
  Select menu\menu_entry[menu\selected_entry]\name$
    
    Case message_list$(#MESSAGE_MENU_SPLASH_NEW_GAME):
      delete_savegame()
    
    Case message_list$(#MESSAGE_MENU_SPLASH_CONTINUE_GAME):
    
    Case message_list$(#MESSAGE_MENU_SPLASH_EXIT):
      program_ends = 1
    
    
  EndSelect
  If background = 1
    FreeSprite(spr)
  EndIf
  ProcedureReturn menu\menu_entry[menu\selected_entry]\name$
EndProcedure
; IDE Options = PureBasic 4.30 (Windows - x86)
; CursorPosition = 177
; FirstLine = 162
; Folding = --
; EnableXP
; CompileSourceDirectory
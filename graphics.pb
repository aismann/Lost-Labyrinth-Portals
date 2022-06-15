; Lost Labyrinth VI: Portals
; graphics procedures
; written in PureBasic 4.20 (http://www.purebasic.com)
; created:  08.10.2008 Frank Malota <malota@web.de>
; modified: 18.01.2009 Frank Malota <malota@web.de>


; declarations
Declare.w wrap_text(x.w, y.w, text$, width.w, height.w=16, color.l=$ffffff)
Declare.s ability_value_display(id.w)
Declare.s ability_expanded_value_display(id.w)


; returns movement of mouse wheel
Procedure.w MouseWheelDelta()
 Protected x.w
 x.w = ((EventwParam()>>16)&$FFFF) 
 ProcedureReturn -(x / 120) 
EndProcedure


; load all sprites into memory
Procedure load_sprites()
  Protected i.w
  If LoadSprite(#SPRITE_Characters, "graphics\characters.png") = 0
    error_message("load_sprites(): can't load character sprites!")
  EndIf
  If LoadSprite(#SPRITE_Frame, "graphics\frame.png") = 0
    error_message("load_sprites(): can't load frame sprites!")
  EndIf
  If LoadSprite(#SPRITE_ABILITIES, "graphics\abilities.png") = 0
    error_message("load_sprites(): can't load abilities sprites!")
  EndIf
  If LoadSprite(#SPRITE_SPLASH, "graphics\splash.png") = 0
    error_message("load_sprites(): can't load splash sprite!")
  EndIf
  If LoadSprite(#SPRITE_MONSTER, "graphics\monster.png") = 0
    error_message("load_sprites(): cannot load monster sprite!")
  EndIf
  If LoadSprite(#SPRITE_MOUSEPOINTER, "graphics\mousepointer.png") = 0
    error_message("load_sprites(): cannot load mouse pointer graphics!")
  EndIf
  If LoadSprite(#SPRITE_BLOOD, "graphics\blood.png") = 0
    error_message("load_sprites(): cannot load bloodspot image!")
  EndIf
  If LoadSprite(#SPRITE_POWERS, "graphics\powers.png") = 0
    error_message("load_sprites(): cannot load powers image!")
  EndIf
  If LoadSprite(#SPRITE_CURSOR, "graphics\cursor.png") = 0
    error_message("load_sprites(): cannot load cursor image!")
  EndIf
  If LoadSprite(#SPRITE_STARS, "graphics\starsprites.png") = 0
    error_message("load_sprites(): cannot star sprites!")
  EndIf
  If LoadSprite(#SPRITE_MISSILES, "graphics\missiles.png") = 0
    error_message("load_sprites(): cannot load missiles sprites!")
  EndIf
  For i=0 To 6
    If LoadSprite(#SPRITE_LIGHT1 + i, "graphics\light" + Str(i+1) + ".png") = 0
      error_message("load_sprites(): cannot load light radius sprite!")
    EndIf
  Next
  If LoadSprite(#SPRITE_ITEMS, "graphics\items.png") = 0
    error_message("load_sprites(): cannot load item sprites!")
  EndIf
  If LoadSprite(#SPRITE_FX, "graphics\fx.png") = 0
    error_message("load_sprites(): cannot load fx sprites!")
  EndIf
  ability_tiles_columns = Int(SpriteWidth(#SPRITE_ABILITIES) / 32)
  ability_tiles_rows = Int(SpriteHeight(#SPRITE_ABILITIES) / 32)
  monster_tiles_columns = Int(SpriteWidth(#SPRITE_MONSTER) / 32)
  monster_tiles_rows = Int(SpriteHeight(#SPRITE_MONSTER) / 32)
  power_tiles_columns = Int(SpriteWidth(#SPRITE_POWERS) / 32)
  power_tiles_rows = Int(SpriteHeight(#SPRITE_POWERS) / 32)
  missile_tiles_columns = Int(SpriteWidth(#SPRITE_MISSILES) / 32)
  missile_tiles_rows = Int(SpriteHeight(#SPRITE_MISSILES) / 32)
  item_tiles_columns = Int(SpriteWidth(#SPRITE_ITEMS) / 32)
  item_tiles_rows = Int(SpriteHeight(#SPRITE_ITEMS) / 32)
  fx_tiles_columns = Int(SpriteWidth(#SPRITE_FX) / 32)
  fx_tiles_rows = Int(SpriteHeight(#SPRITE_FX) / 32)
  CreateSprite(#SPRITE_FADEOUT, 416, 416)
  StartDrawing(SpriteOutput(#SPRITE_FADEOUT))
  Box(0, 0, 416, 416, RGB(1,1,1))
  StopDrawing()
  CreateSprite(#SPRITE_FADEOUT_TOTAL, 640, 480)
  StartDrawing(SpriteOutput(#SPRITE_FADEOUT_TOTAL))
  Box(0, 0, 640, 480, RGB(1,1,1))
  StopDrawing()
  LoadFont(#FONT_SMALL, "Arial", 8)
  LoadFont(#FONT_HARRINGTON, "Harrington", 12, #PB_Font_HighQuality)
  LoadFont(#FONT_ARIAL_NORMAL, "Arial", 10)
  LoadFont(#FONT_VERDANA, "Verdana", 10)
  LoadFont(#FONT_VERDANA_BOLD, "Verdana", 10, #PB_Font_Bold)
EndProcedure


; draws the frame for the main screen
Procedure draw_frame_main_screen()
  Protected frame.b = 1
  Protected i.b = 0
  ClipSprite(#SPRITE_Frame, 0, 6*16, 16, 16)
  DisplaySprite(#SPRITE_Frame, 0, 26*16)
  For i=1 To 39
    ClipSprite(#SPRITE_Frame, 0, 7*16 + (frame*16), 16, 16)
    DisplaySprite(#SPRITE_Frame, i*16, 26*16)
    If i > 25
      DisplaySprite(#SPRITE_Frame, i*16, 18)
      DisplaySprite(#SPRITE_Frame, i*16, 66)
    EndIf
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
EndProcedure


; clip tiles sprite to tile_type nr
Procedure clip_tile_sprite(*map.map_struct, tile_type.w)
  Protected x.w, y.w
  y = Int(tile_type / (*map\tileset\columns))
  x = tile_type - (y * (*map\tileset\columns))
  ClipSprite(*map\tileset\sprite, x*32, y*32, 32, 32)
EndProcedure


; clip ability tile sprite to tile type nr
Procedure clip_ability_tile_sprite(tile_type.w)
  Protected x.w, y.w
  y = Int(tile_type / ability_tiles_columns)
  x = tile_type - (y * ability_tiles_columns)
  ClipSprite(#SPRITE_ABILITIES, x*32, y*32, 32, 32)
EndProcedure


; clip power tile sprite to tile type nr
Procedure clip_power_tile_sprite(tile_type.w)
  Protected x.w, y.w
  y = Int(tile_type / power_tiles_columns)
  x = tile_type - (y * power_tiles_columns)
  ClipSprite(#SPRITE_POWERS, x*32, y*32, 32, 32)
EndProcedure


; clip item tile sprite to tile type nr
Procedure clip_item_tile_sprite(tile_type.w)
  Protected x.w, y.w
  y = Int(tile_type / item_tiles_columns)
  x = tile_type - (y * item_tiles_columns)
  ClipSprite(#SPRITE_ITEMS, x*32, y*32, 32, 32)
EndProcedure


; clip missile tile sprite to tile type nr
Procedure clip_missile_tile_sprite(tile_type.w)
  Protected x.w, y.w
  y = Int(tile_type / missile_tiles_columns)
  x = tile_type - (y * missile_tiles_columns)
  ClipSprite(#SPRITE_MISSILES, x*32, y*32, 32, 32)
EndProcedure


; clip monster tile sprite to tile type nr
Procedure clip_monster_tile_sprite(tile.w)
  Protected x.w, y.w
  y = Int(tile / monster_tiles_columns)
  x = tile - (y * monster_tiles_columns)
  ClipSprite(#SPRITE_MONSTER, x*32, y*32, 32, 32)
EndProcedure


Procedure clip_monster_sprite(monster_type.w)
  Protected x.w, y.w, tile.w
  tile = monster_type_db(monster_type)\tile
  y = Int(tile / monster_tiles_columns)
  x = tile - (y * monster_tiles_columns)
  ClipSprite(#SPRITE_MONSTER, x*32, y*32, 32, 32)
EndProcedure


; clip fx tile sprite to tile type nr
Procedure clip_fx_tile_sprite(tile_type.w)
  Protected x.w, y.w
  y = Int(tile_type / fx_tiles_columns)
  x = tile_type - (y * fx_tiles_columns)
  ClipSprite(#SPRITE_FX, x*32, y*32, 32, 32)
EndProcedure


; draws map part of screen
Procedure draw_map_screen(*map.map_struct, x_offset.b=0, y_offset.b=0, fade.w=0)
  Protected x.w, y.w, tile_type.w, display_message.b, lighting.b
  x = 0
  y = 0
  tile_type = 0
  If fade > 0
 ;   StartSpecialFX()
  EndIf
  For y = -1 To 12
    For x = -1 To 12
      tile_type = read_map_tile_type(*map, current_character\xpos - 6 + x, current_character\ypos - 6 + y)
      If read_map_hidden(*map, current_character\xpos - 6 + x, current_character\ypos - 6 + y) = 1
        tile_type = *map\background_tile
      EndIf
      If *map\tileset\tile_type_db[tile_type]\transparent = 1
        clip_tile_sprite(*map, current_map\background_tile)
        DisplaySprite(*map\tileset\sprite, x*32 + x_offset, y*32 + y_offset)
        clip_tile_sprite(*map, tile_type)
        DisplayTransparentSprite(*map\tileset\sprite, x*32 + x_offset, y*32 + y_offset)
        Else
        clip_tile_sprite(*map, tile_type)
        DisplaySprite(*map\tileset\sprite, x*32 + x_offset, y*32 + y_offset)
      EndIf
    Next
  Next
  ; display items
  ForEach item_on_map()
    If item_on_map()\xpos >= current_character\xpos-7 And item_on_map()\xpos <= current_character\xpos+6 And item_on_map()\ypos >= current_character\ypos-7 And item_on_map()\ypos <= current_character\ypos+6
      tile_type = read_map_tile_type(*map, item_on_map()\xpos, item_on_map()\ypos)
      If *map\tileset\tile_type_db[tile_type]\container = 0
        clip_item_tile_sprite(item_db(item_on_map()\type)\tile)
        DisplayTransparentSprite(#SPRITE_ITEMS, (item_on_map()\xpos - current_character\xpos + 6) * 32 + x_offset, (item_on_map()\ypos - current_character\ypos + 6) * 32 + y_offset)
      EndIf
    EndIf
  Next
  ; display monsters
  ForEach monster()
    If monster()\xpos >= current_character\xpos-7 And monster()\xpos <= current_character\xpos+6 And monster()\ypos >= current_character\ypos-7 And monster()\ypos <= current_character\ypos+6
      clip_monster_sprite(monster()\type)
      DisplayTransparentSprite(#SPRITE_MONSTER, (monster()\xpos - current_character\xpos + 6) * 32 + x_offset + monster()\x_offset, (monster()\ypos - current_character\ypos + 6) * 32 + y_offset + monster()\y_offset)
    EndIf
  Next
  lighting = current_light_radius()
  If lighting >= 0 And lighting < 7
    DisplayTransparentSprite(#SPRITE_LIGHT1 + lighting, 0, 0)
  EndIf
  If fade > 0
    If preferences\fade_effect = 1
      DisplayTransparentSprite(#SPRITE_FADEOUT, 0, 0, fade)
   ;;   StopSpecialFX()
    EndIf
  EndIf
  StartDrawing(ScreenOutput())
  Box(0, 416, 640, 3*16, RGB(0,0,0))
  Box(416, 0, 640-416, 480, RGB(0,0,0))
  ; display messages
  display_message = 0
  If message\display_for > ElapsedMilliseconds() - message\start_time
    x = 36
    If message\tile < 0
      x = 0
    EndIf
    If message\line1$ <> "" And message\line2$ <> ""
      DrawText(x, 440, message\line1$, message\color, RGB(0,0,0))
      DrawText(x, 456, message\line2$, message\color, RGB(0,0,0))
      display_message = 1
    EndIf
    If message\line1$ <> "" And message\line2$ = ""
      wrap_text(x, 440, message\line1$, 640 - x, 16, message\color)
      display_message = 1
    EndIf
    If message\line1$ = "" And message\line2$ <> ""
      DrawText(x, 448, message\line2$, message\color, RGB(0,0,0))
      display_message = 1
    EndIf
  EndIf
  StopDrawing()
  If display_message = 1
    If message\tile >= 0
      Select message\tile_type
      
        Case 0:
          clip_tile_sprite(*map, message\tile)
          DisplaySprite(*map\tileset\sprite, 0, 440)
          
        Case 1:
          clip_item_tile_sprite(message\tile)
          DisplaySprite(#SPRITE_ITEMS, 0, 440)
          
        Case 2:
          clip_power_tile_sprite(message\tile)
          DisplaySprite(#SPRITE_POWERS, 0, 440)
          
        Case 3:
          clip_monster_tile_sprite(message\tile)
          DisplaySprite(#SPRITE_MONSTER, 0, 440)
          
        Case 4:
          clip_ability_tile_sprite(message\tile)
          DisplaySprite(#SPRITE_ABILITIES, 0, 440)
          
      EndSelect
    EndIf
  EndIf
EndProcedure


; draw character in map screen
Procedure draw_character(y_offset.b = 0)
  If current_character\facing<0 Or current_character\facing>3
    error_message("draw_character: wrong facing: "+Str(current_character\facing))
  EndIf
  If current_character\frame<>0 And current_character\frame<>1
    error_message("draw_character: wrong frame: "+Str(current_character\frame))
  EndIf
  ClipSprite(#SPRITE_Characters, current_character\facing*64 + current_character\frame*32, 0, 32, 32)
  DisplayTransparentSprite(#SPRITE_Characters, 6*32, 6*32 + y_offset)
EndProcedure


; changes frame of current character sprite (for "walking" animation")
Procedure current_character_change_frame()
  current_character\frame = current_character\frame + 1
  If current_character\frame > 1
    current_character\frame = 0
  EndIf
EndProcedure


; draws right panel
Procedure draw_right_panel()
  Protected i.w, j.w, ok.b, x.b, y.w, text$, attribute_current_val.w = 0
  Protected NewList tile_list.tile_list_struct()
  Protected value$
  StartDrawing(ScreenOutput())
  DrawingFont(FontID(#FONT_VERDANA))
  DrawText(416 + 16 + 2, 0, program_title$, RGB(255, 100, 0), RGB(0, 0, 0))
  y = 86
  DrawingFont(#FONT_VERDANA)
  wrap_text(434, 34, "Location: " + current_map\name, 640 - 434, 16, $ffffff)
  DrawingFont(FontID(#FONT_SMALL))
  For i = 1 To #MAX_NUMBER_OF_ABILITIES - 1
    For j=0 To #MAX_NUMBER_OF_ABILITY_DISPLAYS - 1
      If ability_db(i)\display[j]\type = 1
        attribute_current_val = attribute_current_val(i)
        If (attribute_current_val >= ability_db(i)\display[j]\start_value And attribute_current_val <= ability_db(i)\display[j]\end_value) Or (ability_db(i)\display[j]\start_value = 0 And ability_db(i)\display[j]\end_value = 0)
          value$ = Str(attribute_current_val)
          If ability_db(i)\display[j]\expanded_value_display = 1
            value$ = ability_expanded_value_display(i)
          EndIf
          text$ = ReplaceString(ability_db(i)\display[j]\message$, "[value]", value$, #PB_String_NoCase)
          DrawText(468, y, text$, ability_db(i)\display[j]\color, 0)
          AddElement(tile_list())
          With tile_list()
            \x = 434
            \y = y
            \tile = ability_db(i)\tile
            \type = 1
          EndWith
          y = y + 12
          If ability_db(i)\display[j]\message2$ <> ""
            text$ = ReplaceString(ability_db(i)\display[j]\message2$, "[value]", value$, #PB_String_NoCase)
            DrawText(468, y, text$, ability_db(i)\display[j]\color, 0)
          EndIf
          y = y + 12 + 10
        EndIf
      EndIf
    Next
  Next
  For i=0 To #MAX_NUMBER_OF_ABILITIES - 1
    If current_character\ability[i]\adjustment_name$ <> ""
      AddElement(tile_list())
      tile_list()\x = 434
      tile_list()\y = y
      If current_character\ability[i]\adjustment_power_id > 0
        tile_list()\tile = power_db(current_character\ability[i]\adjustment_power_id)\tile
        tile_list()\type = 2
      EndIf
      If current_character\ability[i]\adjustment_item_id > 0
        tile_list()\tile = item_db(current_character\ability[i]\adjustment_item_id)\tile
        tile_list()\type = 3
      EndIf
      DrawText(434+34, y, current_character\ability[i]\adjustment_name$, $ffffff, 0)
      y = y + 12
      DrawText(434+34, y, message_list$(#MESSAGE_STRENGTH) + ": " + Str(current_character\ability[i]\power_adjustment) + " " + message_list$(#MESSAGE_DURATION) + ": " + Str(current_character\ability[i]\adjustment_duration), $ffffff,0)
      y = y + 22
    EndIf
    If current_character\ability[i]\activated = 1
      AddElement(tile_list())
      With tile_list()
        \x = 434
        \y = y
        \tile = ability_db(i)\tile
        \type = 1
      EndWith
      DrawText(434+34, y, ability_db(i)\name_display$, $ffffff, 0)
      y = y + 12
      DrawText(434+34, y, ability_expanded_value_display(i), $ffffff, 0)
      y = y + 22
    EndIf
  Next
  StopDrawing()
  ForEach tile_list()
    If tile_list()\type = 1
      clip_ability_tile_sprite(tile_list()\tile)
      DisplaySprite(#SPRITE_ABILITIES, tile_list()\x, tile_list()\y)
    EndIf
    If tile_list()\type = 2
      clip_power_tile_sprite(tile_list()\tile)
      DisplaySprite(#SPRITE_POWERS, tile_list()\x, tile_list()\y)
    EndIf 
    If tile_list()\type = 3
      clip_item_tile_sprite(tile_list()\tile)
      DisplaySprite(#SPRITE_ITEMS, tile_list()\x, tile_list()\y)
    EndIf   
  Next
  ClearList(tile_list())
EndProcedure


; draws complete main screen
Procedure draw_main_screen_complete(*map.map_struct, x_offset.b=0, y_offset.b=0, fade.w=0, char_y_offset.b=0)
  ClearScreen(0)
  draw_map_screen(*map, x_offset, y_offset, fade)
  draw_frame_main_screen() 
  draw_right_panel()
  draw_character(char_y_offset)
  FlipBuffers()
EndProcedure


; delete all loaded sprites from memory
Procedure free_all_sprites()
  FreeSprite(#SPRITE_Characters)
  FreeSprite(#SPRITE_Frame)
EndProcedure


; open game screen in window
Procedure open_windowed_screen()
  If OpenWindow(0, 0, 0, 640, 480, program_title$, #PB_Window_SystemMenu | #PB_Window_SizeGadget| #PB_Window_ScreenCentered | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget) = 0
    error_message("Can't open program window!")
  EndIf
  If OpenWindowedScreen(WindowID(0), 0, 0, 640, 480, 1, 0, 0) = 0
    error_message("Can't open windowed screen!") 
  EndIf    
EndProcedure


; open game in fullscreen modus
Procedure open_fullscreen()
  If OpenScreen(640, 480, 32, program_title$) = 0
    error_message("Can't open fullscreen!")
  EndIf
EndProcedure


; switch between windowed and fullscreen modus
Procedure toggle_fullscreen(*tileset.tileset_struct, load_tileset.b=1)
  If preferences\fullscreen = 0
    preferences\fullscreen = 1
    free_all_sprites()
    CloseScreen()
    CloseWindow(0)
    open_fullscreen()
    load_sprites()
    If load_tileset = 1
      load_tileset(*tileset)
    EndIf
    save_preferences(@preferences)
  Else
    preferences\fullscreen = 0
    free_all_sprites()
    CloseScreen()
    open_windowed_screen()
    load_sprites()
    If load_tileset = 1
      load_tileset(*tileset)
    EndIf
    save_preferences(@preferences)
  EndIf
EndProcedure


; displays text message
Procedure message(line1$, line2$, color.l=$ffffff, tile.w=-1, tile_type.b = 0, display_for.l=2000)
  message\color = color
  message\line1$ = line1$
  message\line2$ = line2$
  message\tile = tile
  message\tile_type = tile_type
  message\start_time = ElapsedMilliseconds()
  message\display_for = display_for
EndProcedure


; FX: fade map screen part out
Procedure fade_map_screen_out(*map.map_struct)
  Protected i.w
  For i=1 To 255 Step 5
    draw_main_screen_complete(*map, 0,0,i)
  Next
EndProcedure


; FX: fade map screen part in
Procedure fade_map_screen_in(*map.map_struct)
  Protected i.w
  For i=255 To 0 Step -5
    draw_main_screen_complete(*map, 0,0,i)
  Next
EndProcedure


; draws standard frame
Procedure draw_standard_frame(title$, subtitle$ = "")
  Protected frame.b = 1
  Protected i.b = 0
  ClearScreen(0)
  For i=0 To 29
    ClipSprite(#SPRITE_Frame, 0, frame*16 + 16, 16, 16)
    DisplaySprite(#SPRITE_Frame, 0, i*16)
    DisplaySprite(#SPRITE_Frame, 624, i*16)
    frame = frame + 1
    If frame > 4
      frame = 0
    EndIf
  Next
  For i=1 To 38
    ClipSprite(#SPRITE_Frame, 0, 7*16 + (frame*16), 16, 16)
    DisplaySprite(#SPRITE_Frame, i*16, 0)
    DisplaySprite(#SPRITE_Frame, i*16, 32)
    If subtitle$ <> ""
      DisplaySprite(#SPRITE_Frame, i*16, 432)
    EndIf
    DisplaySprite(#SPRITE_Frame, i*16, 464)
    frame = frame + 1
    If frame > 4
      frame = 0
    EndIf
    StartDrawing(ScreenOutput())
      DrawText(320-(TextWidth(title$)/2), 16, title$, RGB(255,255,255),0)
      If subtitle$ <> ""
        DrawText(320-(TextWidth(subtitle$)/2), 448, subtitle$, RGB(255,255,255), 0)
      EndIf
    StopDrawing()
  Next
EndProcedure


; shortens text to fit in box
Procedure.s shorten_text(text$, width.w, append$="...")
  If TextWidth(text$ + append$) > width
    While TextWidth(text$ + append$) > width
      text$ = Left(text$, Len(text$)-1)
    Wend
  text$ = text$ + append$
  EndIf
  ProcedureReturn text$
EndProcedure


; wraps text in box; returns number of lines displayed
Procedure.w wrap_text(x.w, y.w, text$, width.w, height.w=16, color.l=$ffffff)
  Protected rc.w = 0, rest$, pos.w, pos_old.w, line_y.w
  rest$ = text$
  line_y = y
  While TextWidth(rest$) > width
    pos = FindString(rest$, " ", 1)
    While pos > 0 And TextWidth(Mid(rest$, 1, pos)) < width
      pos_old = pos
      pos = FindString(rest$, " ", pos_old+1)
    Wend
    If pos = 0
      If pos_old = 0
        DrawText(x, line_y, rest$, color, 0)
      Else
        DrawText(x, line_y, Mid(rest$, 1, pos_old), color, 0)
        line_y = line_y + height
        rc = rc + 1
        DrawText(x, line_y, Mid(rest$, pos_old+1), color, 0)
      EndIf
      rest$ = ""
    Else
      If pos_old = 0
        DrawText(x, line_y, Mid(rest$, 1, pos), color, 0)
        rest$ = Mid(rest$, pos +1 )
      Else
        DrawText(x, line_y, Mid(rest$, 1, pos_old), color, 0)
        rest$ = Mid(rest$, pos_old + 1)
      EndIf
    EndIf
    line_y = line_y + height
    rc = rc + 1
  Wend
  If rest$ <> ""
    DrawText(x, line_y, rest$, color, 0)
    rc = rc + 1
  EndIf
  ProcedureReturn rc
EndProcedure


; creates a screenshot and saves it into a file
Procedure screenshot(filename$)
  If GrabSprite(#SPRITE_SCREENSHOT, 0, 0, 640, 480) = 0
    error_message("screenshot(): could not grab screenshot!")
  EndIf
  If SaveSprite(#SPRITE_SCREENSHOT, filename$, #PB_ImagePlugin_JPEG) = 0
    error_message("screenshot(): could not save screenshot to file " + Chr(34) + filename$ + Chr(34))
  EndIf
EndProcedure


; changes current cursor frame
Procedure blink_cursor(*cursor.cursor_struct)
  If *cursor\dir = 1
    *cursor\frame = *cursor\frame + 1
    If *cursor\frame > 3
      *cursor\dir = -1
    EndIf
  Else
    *cursor\frame = *cursor\frame - 1
    If *cursor\frame < 1
      *cursor\dir = 1
    EndIf
  EndIf
EndProcedure


; resets a cursor
Procedure reset_cursor(*cursor.cursor_struct)
  *cursor\x = 6
  *cursor\y = 6
  *cursor\frame = 0
  *cursor\dir = 1
  *cursor\esc = 0
EndProcedure


; displays cursor in main frame
Procedure cursor_select_field(*cursor.cursor_struct, range.b = 2)
  Protected x.w, y.w, leave_cursor_select_field.b = 0, key_lock.b = 1, main_window_event.l
  While leave_cursor_select_field = 0
  
    ; check for keyboard input
    ExamineKeyboard()  

    ; check for windows events
    If preferences\fullscreen = 0
      main_window_event = WindowEvent()
      If main_window_event = #PB_Event_CloseWindow
        program_ends = 1
        leave_cursor_select_field = 1
        *cursor\esc = 1
      EndIf
    EndIf
    
    ; move cursor up
    If KeyboardPushed(#PB_Key_Up) And key_lock = 0
      If (range > 1 And *cursor\y > 0) Or (range = 1 And *cursor\y > 5)
        *cursor\y = *cursor\y - 1
        key_lock = 1
      EndIf
    EndIf
    
    ; move cursor down
    If KeyboardPushed(#PB_Key_Down) And key_lock = 0
      If (range > 1 And *cursor\y < 12) Or (range = 1 And *cursor\y < 7)
        *cursor\y = *cursor\y + 1
        key_lock = 1
      EndIf
    EndIf
    
    ; move cursor left
    If KeyboardPushed(#PB_Key_Left) And key_lock = 0
      If (range > 1 And *cursor\x > 0) Or (range = 1 And *cursor\x > 5)
        *cursor\x = *cursor\x - 1
        key_lock = 1
      EndIf
    EndIf
    
    ; move cursor right
    If KeyboardPushed(#PB_Key_Right) And key_lock = 0
      If (range > 1 And *cursor\x < 12) Or (range = 1 And *cursor\x < 7)
        *cursor\x = *cursor\x + 1
        key_lock = 1
      EndIf
    EndIf
    
    ; Return: select field
    If KeyboardReleased(#PB_Key_Return) And key_lock = 0
      leave_cursor_select_field = 1
    EndIf
    
    ; Esc: cancel
    If KeyboardReleased(#PB_Key_Escape)
      leave_cursor_select_field = 1
      *cursor\esc = 1
    EndIf
    
    ; release key lock if no key is pressed
    If KeyboardReleased(#PB_Key_All)
      key_lock = 0
    EndIf       
    
    ; draw screen
    ClearScreen(0)
    draw_map_screen(@current_map)
    draw_frame_main_screen() 
    draw_right_panel()
    draw_character()
    ClipSprite(#SPRITE_CURSOR, *cursor\frame * 32, 0, 32, 32)
    DisplayTransparentSprite(#SPRITE_CURSOR, *cursor\x * 32, *cursor\y * 32)
    blink_cursor(*cursor)    
    FlipBuffers()    
    
  Wend
EndProcedure


; star sprites animation
Procedure star_sprite_animation(star_sprite.b = 0, x.b = 6, y.b = 6, number_of_stars.b = 7, mixed.b = 0, second_star_sprite.b = 0)
  Protected end_animation.b = 0, count.w = 0, i.w
  Protected NewList star_sprites.star_sprites_struct()
  For i=1 To number_of_stars
    AddElement(star_sprites())
    star_sprites()\x = x * 32 + Random(30)
    star_sprites()\y = y * 32 + Random(30)
    star_sprites()\frame = 0
    star_sprites()\delay = Random(9)
    star_sprites()\dir = 1
    star_sprites()\color = star_sprite
    If mixed = 1
      star_sprites()\color = Random(4)
    Else
      If second_star_sprite > 0
        If Random(1) = 0
          star_sprites()\color = second_star_sprite
        EndIf
      EndIf
    EndIf
  Next
  While end_animation = 0 And count < 50
    ClearScreen(0)
    draw_map_screen(@current_map)
    draw_frame_main_screen() 
    draw_right_panel()
    draw_character()
    ForEach star_sprites()
      If star_sprites()\delay > 0
        star_sprites()\delay = star_sprites()\delay - 1
      Else
        ClipSprite(#SPRITE_STARS, star_sprites()\frame * 9, star_sprites()\color * 9, 9, 9)
        DisplayTransparentSprite(#SPRITE_STARS, star_sprites()\x, star_sprites()\y)
        If star_sprites()\dir = 1
          star_sprites()\frame = star_sprites()\frame + 1
          If star_sprites()\frame > 3
            star_sprites()\frame = 4
            star_sprites()\dir = -1
          EndIf
        Else
          star_sprites()\frame = star_sprites()\frame - 1
          If star_sprites()\frame < 1
            star_sprites()\frame = 0
            star_sprites()\x = x * 32 + Random(30)
            star_sprites()\y = y * 32 + Random(30)
            star_sprites()\dir = 1
            If mixed = 1
              star_sprites()\color = Random(4)
            Else
              If second_star_sprite > 0
                If Random(1) = 0
                  star_sprites()\color = second_star_sprite
                EndIf
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    Next
    FlipBuffers()
    Delay(25)
    count = count + 1
  Wend
  ClearList(star_sprites())
EndProcedure


; creates an animation of a circle of stars dancing around
Procedure star_circle_animation(star_sprite.b = 0, x.b = 6, y.b = 6)
  Protected i.w = 0, a.w
  ClipSprite(#SPRITE_STARS, 4*9, star_sprite * 9, 9, 9)
  For i=0 To 200 Step 5
    ClearScreen(0)
    draw_map_screen(@current_map)
    draw_frame_main_screen() 
    draw_right_panel()
    draw_character()  
    For a= 0 To 360 Step 20
      DisplayTransparentSprite(#SPRITE_STARS, x*32+12+Sin(a+i)*20, y*32+12+Cos(a+i)*20)
    Next
    FlipBuffers()
    Delay(25)
  Next
EndProcedure


; missile animation
Procedure missile_animation(tile.w, source_x.b, source_y.b, destination_x.b, destination_y.b)
  Protected animation_ends.b = 0, step_x.b, step_y.b, x.w, y.w, count.w = 0, i.w
  x = source_x * 32
  y = source_y * 32
  step_x = destination_x - source_x
  step_y = destination_y - source_y
  count = 32
  If Abs(step_x) > Abs(step_y) And step_y <> 0
    count = Int(Abs(step_x) / Abs(step_y)) * 32
  EndIf
  If Abs(step_y) > Abs(step_x) And step_x <> 0
    count = Int(Abs(step_y) / Abs(step_x)) * 32
  EndIf  
  clip_missile_tile_sprite(tile)
  For i=0 To count
    ClearScreen(0)
    draw_map_screen(@current_map)
    draw_frame_main_screen() 
    draw_right_panel()
    draw_character()
    DisplayTransparentSprite(#SPRITE_MISSILES, x, y)
    FlipBuffers()
    x = x + step_x
    y = y + step_y
  Next
EndProcedure


; display fx tile animation
Procedure display_tile_animation(tile.w, type.b = 0, x.b = 6, y.b = 6, display_number.b = 0, number.w = 0)
  Protected text$
  Select type
  
    Case 1:
      clip_tile_sprite(@current_map, tile)
      DisplayTransparentSprite(current_map\tileset\sprite, x*32, y*32)
  
    Default:
      clip_fx_tile_sprite(tile)
      DisplayTransparentSprite(#SPRITE_FX, x*32, y*32)
      
  EndSelect
  If display_number = 1
    StartDrawing(ScreenOutput())
    DrawingFont(#PB_Default)
    text$ = Str(number)
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawText((x * 32) + 16 - TextWidth(text$)/2, (y * 32) + 16 - TextHeight(text$)/2, text$, $ffffff, 0)
    StopDrawing()
  EndIf
  FlipBuffers()
  Delay(250)
  draw_map_screen(@current_map)
  draw_frame_main_screen() 
  draw_right_panel()
  draw_character()
  FlipBuffers()
  Delay(250)    
EndProcedure


; display tile flood animation
Procedure display_tile_flood_animation(tile.w)
  Protected x.b = 0, y.b = 0
  draw_map_screen(@current_map)
  For x = 0 To 12
    For y = 0 To 12
      clip_fx_tile_sprite(tile)
      DisplayTransparentSprite(#SPRITE_FX, x * 32, y * 32)
    Next
  Next
  draw_frame_main_screen() 
  draw_right_panel()
  draw_character()
  FlipBuffers()
  Delay(500)
  draw_map_screen(@current_map)
  draw_frame_main_screen() 
  draw_right_panel()
  draw_character()
  FlipBuffers()    
EndProcedure


; displays animation
Procedure animation(name$, x.b = 6, y.b = 6, animation_parameter.w = 0)
  Select name$
  
    Case "": ; empty string = no animation
    
    Case "blue stars":
      star_sprite_animation(0, x, y, 25)
      
    Case "red stars":
      star_sprite_animation(1, x, y, 25)
      
    Case "purple stars":
      star_sprite_animation(2, x, y, 25)
      
    Case "green stars":
      star_sprite_animation(3, x, y, 25)
            
    Case "yellow stars":
      star_sprite_animation(4, x, y, 25)
      
    Case "aqua stars":
      star_sprite_animation(5, x, y, 25)
      
    Case "grey stars":
      star_sprite_animation(6, x, y, 25)
      
    Case "skull stars":
      star_sprite_animation(7, x, y, 25)
      
    Case "mixed stars":
      star_sprite_animation(0, x, y, 25, 1)
      
    Case "blue circle":
      star_circle_animation(0, x, y)
      
    Case "red circle":
      star_circle_animation(1, x, y)
      
    Case "purple circle":
      star_circle_animation(2, x, y)
      
    Case "green circle":
      star_circle_animation(3, x, y)
      
    Case "yellow circle":
      star_circle_animation(4, x, y)
      
    Case "aqua circle":
      star_circle_animation(5, x, y)
      
    Case "grey circle":
      star_circle_animation(6, x, y)
      
    Case "skull circle":
      star_circle_animation(7, x, y)
      
    Case "red fireball":
      missile_animation(#SPRITE_MISSILE_RED_BALL, 6, 6, x, y)
      
    Case "blue fireball":
      missile_animation(#SPRITE_MISSILE_BLUE_BALL, 6, 6, x, y)
      
    Case "green fireball":
      missile_animation(#SPRITE_MISSILE_GREEN_BALL, 6, 6, x, y)
      
    Case "purple fireball":
      missile_animation(#SPRITE_MISSILE_PURPLE_BALL, 6, 6, x, y)
      
    Case "lightning":
      missile_animation(#SPRITE_MISSILE_LIGHTNING, 6, 6, x, y)
      
    Case "blue lightning":
      missile_animation(#SPRITE_MISSILE_BLUE_LIGHTNING, 6, 6, x, y)
      
    Case "red cloud":
      display_tile_animation(#SPRITE_FX_CLOUD_RED, 0, x, y, 1, animation_parameter)
      
    Case "green cloud":
      display_tile_animation(#SPRITE_FX_CLOUD_GREEN, 0, x, y, 1, animation_parameter)
      
    Case "magic shield":
      display_tile_animation(#SPRITE_FX_MAGIC_SHIELD, 0, x, y, 1, animation_parameter)
      
    Case "battle rage":
      display_tile_animation(#SPRITE_FX_RAGE, 0, x, y, 1, animation_parameter)
      
    Case "fire flood":
      display_tile_flood_animation(#SPRITE_FX_FIRE)
      
    Case "wind flood":
      display_tile_flood_animation(#SPRITE_FX_WIND)
      
    Case "cross flood":
      display_tile_flood_animation(#SPRITE_FX_CROSS)
      
    Default:
      error_message("animation(): unknown animation: " + Chr(34) + name$ + Chr(34))
      
  EndSelect
EndProcedure
; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 249
; FirstLine = 245
; Folding = -------
; CompileSourceDirectory
; Lost Labyrinth VI: Portals
; map editor(standalone)
; written in PureBasic 4.20 (http://www.purebasic.com)
; created:  20.10.2008 Frank Malota <malota@web.de>
; modified: 29.12.2008 Frank Malota <malota@web.de>


; creates single tile images from tileset
Procedure create_images_from_tileset(*tileset.tileset_struct, offset.w)
  Protected x.w, y.w
  If *tileset\image_loaded = 0
    error_message("create_images_from_tileset: tileset image not loaded!")
  EndIf
  For y=0 To *tileset\rows-1
    For x=0 To *tileset\columns-1
      GrabImage(*tileset\image, offset+x+(y*10), x*32, y*32, 32, 32)
    Next
  Next
EndProcedure


Procedure create_images_from_monster(offset.w)
  Protected x.w, y.w, i.w=0
  LoadImage(#IMAGE_MONSTER, "graphics\monster.png")
  For y=0 To Int(ImageHeight(#IMAGE_MONSTER)/32)
    For x=0 To Int(ImageWidth(#IMAGE_MONSTER)/32)
      GrabImage(#IMAGE_MONSTER, offset+i, x*32, y*32, 32, 32)
      i = i + 1
    Next
  Next  
EndProcedure


Procedure create_images_from_items(offset.w)
  Protected x.w, y.w, i.w=0
  LoadImage(#IMAGE_ITEMS, "graphics\items.png")
  For y=0 To Int(ImageHeight(#IMAGE_ITEMS)/32)
    For x=0 To Int(ImageWidth(#IMAGE_ITEMS)/32)
      GrabImage(#IMAGE_ITEMS, offset+i, x*32, y*32, 32, 32)
      i = i + 1
    Next
  Next
EndProcedure


; draw scroll area
Procedure update_scrollarea()
  Protected x.w, y.w, tile.w=0, flags$
  StartDrawing(ImageOutput(#IMAGE_SCROLLAREA))
  For y=0 To #MAP_DIMENSION_X-1
    For x=0 To #MAP_DIMENSION_Y-1
      tile = read_map_tile_type(@current_map, x, y)
      If @current_map\tileset\tile_type_db[tile]\transparent = 1
        ;DrawImage(ImageID(100+current_map\default_tile), x*32, y*32)
        DrawImage(ImageID(100+tile), x*32, y*32)
      Else
        DrawImage(ImageID(100+tile), x*32, y*32)
      EndIf
      flags$ = ""
      If field_is_open_portal(@current_map, x, y)
        flags$ = flags$ + "P"
      EndIf
      If read_map_message_line1(@current_map, x, y)<>"" Or read_map_message_line2(@current_map, x, y)<>""
        flags$ = flags$ + "M"
      EndIf
      If read_map_event(@current_map, x, y) <> ""
        flags$ = flags$ + "E"
      EndIf
      If field_contains_transformation(x, y)
        flags$ = flags$ + "T"
      EndIf
      If flags$ <> ""
        DrawText(x*32, y*32, flags$, RGB(255,0,0), RGB(0,0,0))
      EndIf
      If GetGadgetState(#GADGET_OPTION_MODUS_SET_MONSTER) = 1 Or GetGadgetState(#GADGET_OPTION_MODUS_REMOVE_MONSTER) = 1
        If field_contains_monster(x, y)
          ForEach monster()
            If monster()\xpos = x And monster()\ypos = y
              DrawImage(ImageID(500+monster_type_db(monster()\type)\tile), x*32, y*32)
            EndIf
          Next
        EndIf
      EndIf
    Next
  Next
  StopDrawing()
EndProcedure


; open main window
Procedure open_main_window()
  If OpenWindow(#WINDOW_MAIN, 0, 0, 640, 480, main_window_title$ + " - <new map>", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_MinimizeGadget) = 0
    error_message("Could not open main window!")
  EndIf
  CreateMenu(#MENU_MAIN, WindowID(#WINDOW_MAIN))
  MenuTitle("File")
  MenuItem(#MENUITEM_NEW, "New" + Chr(9) + "Ctrl+N")
  AddKeyboardShortcut(#WINDOW_MAIN, #PB_Shortcut_Control | #PB_Shortcut_N, #MENUITEM_NEW)
  MenuItem(#MENUITEM_OPEN, "Open" + Chr(9) + "Ctrl+O")
  AddKeyboardShortcut(#WINDOW_MAIN, #PB_Shortcut_Control | #PB_Shortcut_O, #MENUITEM_OPEN)
  MenuItem(#MENUITEM_SAVE, "Save" + Chr(9) + "Ctrl+S")
  AddKeyboardShortcut(#WINDOW_MAIN, #PB_Shortcut_Control | #PB_Shortcut_S, #MENUITEM_SAVE)
  MenuItem(#MENUITEM_SAVE_AS, "Save as" + Chr(9) + "Ctrl+A")
  AddKeyboardShortcut(#WINDOW_MAIN, #PB_Shortcut_Control | #PB_Shortcut_A, #MENUITEM_SAVE_AS)
  MenuItem(#MENUITEM_QUIT, "Quit" + Chr(9) + "Ctrl+Q")
  AddKeyboardShortcut(#WINDOW_MAIN, #PB_Shortcut_Control | #PB_Shortcut_Q, #MENUITEM_QUIT)
  MenuTitle("Edit")
  MenuItem(#MENUITEM_FILL, "Fill map" + Chr(9) + "Ctrl+F")
  AddKeyboardShortcut(#WINDOW_MAIN, #PB_Shortcut_Control | #PB_Shortcut_F, #MENUITEM_FILL)
  MenuTitle("Extras")
  MenuItem(#MENUITEM_MONSTERDATA, "View monster data")
  MenuItem(#MENUITEM_ITEMDATA, "View item data")
  MenuItem(#MENUITEM_POWERDATA, "View powers data")
  MenuTitle("Help")
  MenuItem(#MENUITEM_ABOUT, "About")
  CreateToolBar(#WINDOW_MAIN, WindowID(0))
  ToolBarStandardButton(#MENUITEM_NEW, #PB_ToolBarIcon_New)
  ToolBarStandardButton(#MENUITEM_OPEN, #PB_ToolBarIcon_Open)
  ToolBarStandardButton(#MENUITEM_SAVE, #PB_ToolBarIcon_Save)
  ;CreateGadgetList(WindowID(#WINDOW_MAIN))
  OptionGadget(#GADGET_OPTION_MODUS_PAINT, 432, 32, 64, 16, "Paint")
  OptionGadget(#GADGET_OPTION_MODUS_EDIT, 496, 32, 64, 16, "Edit")
  OptionGadget(#GADGET_OPTION_MODUS_SET_MONSTER, 432, 180, 96, 16, "Place Monster")
  OptionGadget(#GADGET_OPTION_MODUS_REMOVE_MONSTER, 530, 180, 128, 16, "Remove Monster")
  OptionGadget(#GADGET_OPTION_MODUS_PLACE_ITEMS, 432, 240, 128, 16, "Place Items")
  SetGadgetState(#GADGET_OPTION_MODUS_PAINT, 1)
  ImageGadget(#GADGET_IMAGE_PLACE_MONSTER, 432, 200, 32, 32, ImageID(#IMAGE_EMPTY_TILE), #PB_Image_Border)
  TextGadget(#GADGET_TEXT_PAINT_TILE, 432, 52,  48, 16, "Paint")
  ImageGadget(#GADGET_PAINT_TILE1, 432, 68, 32, 32, ImageID(#IMAGE_EMPTY_TILE), #PB_Image_Border)
  TextGadget(#GADGET_TEXT_BACKGROUND_TILE, 494, 52, 32, 16, "Back")
  ImageGadget(#GAGDET_BACKGROUND_TILE, 494, 68, 32, 32, ImageID(#IMAGE_EMPTY_TILE), #PB_Image_Border)
  TextGadget(#GADGET_TEXT_OUTSIDE, 560, 52, 64, 16, "Outside")
  ImageGadget(#GADGET_IMAGE_TILE_OUTSIDE, 560, 68, 32, 32, ImageID(#IMAGE_EMPTY_TILE), #PB_Image_Border)
  TextGadget(#GADGET_TEXT_MAP_NAME, 432, 116, 64, 16, "Map name")
  StringGadget(#GADGET_STRING_MAP_NAME, 432, 132, 192, 20, "")
  TextGadget(#GADGET_TEXT_POSITION, 432, 164, 128, 16, "Position :")
  ScrollAreaGadget(#GADGET_SCROLLAREA, 0, 32, 416, 416, #MAP_DIMENSION_X*32, #MAP_DIMENSION_Y*32, 1)
  ImageGadget(#GADGET_SCROLLIMAGE, 0, 0, #MAP_DIMENSION_X*32, #MAP_DIMENSION_Y*32, ImageID(#IMAGE_SCROLLAREA))
EndProcedure



; loads preferences for map editor
Procedure load_map_editor_preferences()
  Protected val.s, x.b, y.b, portal_mapfile$, portal_x.b, portal_y.b
  If CreateXML(0) = 0
    error_message("load_map_editor_preferences: could not create xml structure in memory!")
  EndIf
  If LoadXML(0, map_editor_preferences_file$) = 0
    error_message("load_map_editor_preferences: could not open prefereces xml file: " + Chr(34) + map_editor_preferences_file$ + Chr(34))
  EndIf
  If XMLStatus(0) <> 0
    error_message("load_map_editor_preferences: error in xml structure of preferences file " + Chr(34) + map_editor_preferences_file$ + Chr(34) + ": " + XMLError(0))
  EndIf
  *mainnode = MainXMLNode(0)
  If *mainnode
    *node = ChildXMLNode(*mainnode)
    While *node <> 0
      Select GetXMLNodeName(*node)
      
        Case "last_map_file":
          map_filename$ = GetXMLNodeText(*node)
        
      EndSelect
      *node = NextXMLNode(*node)
    Wend
  EndIf
  FreeXML(0)
EndProcedure


; saves preferences for map editor
Procedure save_map_editor_preferences()
  If CreateXML(0) = 0
    error_message("save_map_editor_preferences: could not create xml structure in memory!")
  EndIf
  *mainnode = CreateXMLNode(RootXMLNode(0), "")
  SetXMLNodeName(*mainnode, "Lost_Labyrinth_Map_Editor_Preferences")
  *node = CreateXMLNode(*mainnode, "")
  SetXMLNodeName(*node, "last_map_file")
  SetXMLNodeText(*node, map_filename$)
  If SaveXML(0, map_editor_preferences_file$) = 0
    error_message("save_map_editor_preferences: Could not save preferences to file " + Chr(34) + map_editor_preferences_file$ + Chr(34))
  EndIf  
EndProcedure


Procedure update_listview_of_transformations()
  ;ClearGadgetItemList(#GADGET_LISTVIEW_FIELD_PARAMETER_TRANSFORMATIONS)
  ForEach map_transformation()
    If map_transformation()\x = field_x And map_transformation()\y = field_y
      AddGadgetItem(#GADGET_LISTVIEW_FIELD_PARAMETER_TRANSFORMATIONS, -1, map_transformation()\event$)
    EndIf
  Next
EndProcedure


Procedure open_window_select_paint_tile()
  If OpenWindow(#WINDOW_SELECT_PAINT_TILE, 0, 0, current_map\tileset\columns*32, current_map\tileset\rows*32, "Select new paint tile", #PB_Window_SystemMenu|#PB_Window_ScreenCentered, WindowID(#WINDOW_MAIN)) = 0
    error_message("Could not open paint tile selection window!")
  EndIf
  ;CreateGadgetList(WindowID(#WINDOW_SELECT_PAINT_TILE))
  ImageGadget(#GADGET_SELECT_TILE, 0, 0, current_map\tileset\columns*32, current_map\tileset\rows*32, ImageID(current_map\tileset\image))
  DisableWindow(#WINDOW_MAIN, 1)
EndProcedure


Procedure open_window_select_background_tile()
  If OpenWindow(#WINDOW_SELECT_BACKGROUND_TILE, 0, 0, current_map\tileset\columns*32, current_map\tileset\rows*32, "Select new background tile", #PB_Window_SystemMenu|#PB_Window_ScreenCentered, WindowID(#WINDOW_MAIN)) = 0
    error_message("Could not open background tile selection window!")
  EndIf
  ;CreateGadgetList(WindowID(#WINDOW_SELECT_BACKGROUND_TILE))
  ImageGadget(#GADGET_SELECT_BACKGROUND_TILE, 0, 0, current_map\tileset\columns*32, current_map\tileset\rows*32, ImageID(current_map\tileset\image))
  DisableWindow(#WINDOW_MAIN, 1)
EndProcedure


Procedure open_window_select_outside_tile()
  If OpenWindow(#WINDOW_SELECT_OUTSIDE_TILE, 0, 0, current_map\tileset\columns*32, current_map\tileset\rows*32, "Select new background tile", #PB_Window_SystemMenu|#PB_Window_ScreenCentered, WindowID(#WINDOW_MAIN)) = 0
    error_message("Could not open outside tile selection window!")
  EndIf
  ;CreateGadgetList(WindowID(#WINDOW_SELECT_OUTSIDE_TILE))
  ImageGadget(#GADGET_IMAGE_SELECT_TILE_OUTSIDE, 0, 0, current_map\tileset\columns*32, current_map\tileset\rows*32, ImageID(current_map\tileset\image))
  DisableWindow(#WINDOW_MAIN, 1)
EndProcedure


Procedure open_window_select_transformation_tile()
  If OpenWindow(#WINDOW_SELECT_TRANSFORMATION_TILE, 0, 0, current_map\tileset\columns*32, current_map\tileset\rows*32, "Select new transformation tile", #PB_Window_SystemMenu|#PB_Window_ScreenCentered) = 0
    error_message("Could not open transformation tile selection window!")
  EndIf
  ;CreateGadgetList(WindowID(#WINDOW_SELECT_TRANSFORMATION_TILE))
  ImageGadget(#GADGET_IMAGE_SELECT_TRANSFORMATION_TILE, 0, 0, current_map\tileset\columns*32, current_map\tileset\rows*32, ImageID(current_map\tileset\image))
  DisableWindow(#WINDOW_TRANSFORMATION, 1)
EndProcedure


Procedure open_window_select_message_tile()
  If OpenWindow(#WINDOW_SELECT_MESSAGE_TILE, 0, 0, current_map\tileset\columns*32, current_map\tileset\rows*32, "Select new transformation tile", #PB_Window_SystemMenu|#PB_Window_ScreenCentered) = 0
    error_message("Could not open message tile selection window!")
  EndIf
  ;CreateGadgetList(WindowID(#WINDOW_SELECT_MESSAGE_TILE))
  ImageGadget(#GADGET_IMAGE_SELECT_NEW_MESSAGE_TILE, 0, 0, current_map\tileset\columns*32, current_map\tileset\rows*32, ImageID(current_map\tileset\image))
  DisableWindow(#WINDOW_FIELD_PARAMETER, 1) 
EndProcedure


Procedure open_window_select_message_tile_add_transformation()
  If OpenWindow(#WINDOW_SELECT_MESSAGE_TILE, 0, 0, current_map\tileset\columns*32, current_map\tileset\rows*32, "Select new transformation tile", #PB_Window_SystemMenu|#PB_Window_ScreenCentered) = 0
    error_message("Could not open message tile selection window!")
  EndIf
  ;CreateGadgetList(WindowID(#WINDOW_SELECT_MESSAGE_TILE))
  ImageGadget(#GADGET_IMAGE_SELECT_NEW_MESSAGE_TILE_ADD_TRANSFORMATION, 0, 0, current_map\tileset\columns*32, current_map\tileset\rows*32, ImageID(current_map\tileset\image))
  DisableWindow(#WINDOW_TRANSFORMATION, 1) 
EndProcedure


Procedure open_window_select_message_tile_edit_transformation()
  If OpenWindow(#WINDOW_SELECT_MESSAGE_TILE, 0, 0, current_map\tileset\columns*32, current_map\tileset\rows*32, "Select new transformation tile", #PB_Window_SystemMenu|#PB_Window_ScreenCentered) = 0
    error_message("Could not open message tile selection window!")
  EndIf
  ;CreateGadgetList(WindowID(#WINDOW_SELECT_MESSAGE_TILE))
  ImageGadget(#GADGET_IMAGE_SELECT_NEW_MESSAGE_TILE_EDIT_TRANSFORMATION, 0, 0, current_map\tileset\columns*32, current_map\tileset\rows*32, ImageID(current_map\tileset\image))
  DisableWindow(#WINDOW_TRANSFORMATION, 1) 
EndProcedure


Procedure open_window_select_monster()
  If OpenWindow(#WINDOW_SELECT_MONSTER, 0, 0, ImageWidth(#IMAGE_MONSTER), ImageHeight(#IMAGE_MONSTER), "Select monster", #PB_Window_SystemMenu|#PB_Window_ScreenCentered) = 0
    error_message("Could not open window to select monster!")
  EndIf
  ;CreateGadgetList(WindowID(#WINDOW_SELECT_MONSTER))
  ImageGadget(#GADGET_IMAGE_SELECT_MONSTER, 0, 0, ImageWidth(#IMAGE_MONSTER), ImageHeight(#IMAGE_MONSTER), ImageID(#IMAGE_MONSTER))
  DisableWindow(#WINDOW_MAIN, 1)
EndProcedure


Procedure open_window_about()
  If OpenWindow(#WINDOW_ABOUT, 0, 0, 200, 200, "About", #PB_Window_ScreenCentered|#PB_Window_TitleBar) = 0
    error_message("open_window_about: could not open about window!")
  EndIf
  ;CreateGadgetList(WindowID(#WINDOW_ABOUT))
  TextGadget(#GADGET_TEXT_ABOUT_LINE1, 8, 8, 184, 16, "Lost Labyrinth VI: Portals", #PB_Text_Center)
  TextGadget(#GADGET_TEXT_ABOUT_LINE2, 8, 24, 184, 16, "Map Editor", #PB_Text_Center)
  TextGadget(#GADGET_TEXT_ABOUT_LINE3, 8, 40, 184, 16, "Version " + map_editor_version$, #PB_Text_Center)
  TextGadget(#GADGET_TEXT_ABOUT_LINE4, 8, 72, 184, 16, "(c) 2008 Frank Malota", #PB_Text_Center)
  TextGadget(#GADGET_TEXT_ABOUT_LINE5, 8, 88, 184, 16, "http://laby.toybox.de", #PB_Text_Center)
  ButtonGadget(#GADGET_BUTTON_ABOUT_OK, 8, 172, 184, 20, "OK")
EndProcedure


Procedure open_window_field_parameter()
  Protected field_tile_type.w, event$
  If IsWindow(#WINDOW_FIELD_PARAMETER)
    CloseWindow(#WINDOW_FIELD_PARAMETER)
  EndIf
  OpenWindow(#WINDOW_FIELD_PARAMETER, 0, 0, 416, 416, "Lost Labyrinth Map Editor - Field Parameter", #PB_Window_SystemMenu|#PB_Window_ScreenCentered, #WINDOW_MAIN)
  DisableWindow(#WINDOW_MAIN, 1)
  field_x = Int((WindowMouseX(#WINDOW_MAIN) - GadgetX(#GADGET_SCROLLAREA) - GadgetX(#GADGET_SCROLLIMAGE) + GetGadgetAttribute(#GADGET_SCROLLAREA,#PB_ScrollArea_X)) / 32)
  field_y = Int((WindowMouseY(#WINDOW_MAIN) - GadgetY(#GADGET_SCROLLAREA) - GadgetY(#GADGET_SCROLLIMAGE) + GetGadgetAttribute(#GADGET_SCROLLAREA,#PB_ScrollArea_Y)) / 32)
  field_tile_type = read_map_tile_type(@current_map, field_x, field_y)
  event$ = read_map_event(@current_map, field_x, field_y)
  message_tile = read_map_message_tile(@current_map, field_x, field_y)
  ;CreateGadgetList(WindowID(#WINDOW_FIELD_PARAMETER))
  TextGadget(#GADGET_TEXT_FIELD_PARAMETER_XY, 48, 8, 360, 16, "Field position: " + Str(field_x) + " / " + Str(field_y), 0)
  TextGadget(#GADGET_TEXT_FIELD_PARAMETER_TILE_TYPE, 48, 24, 360, 16, "Tile type: " + tile_type_db(field_tile_type)\name$)
  TextGadget(#GADGET_TEXT_FIELD_PARAMETER_PORTAL_MAP_FILENAME, 8, 72, 400, 16, "Portal to map (filename):")
  StringGadget(#GADGET_STRING_FIELD_PARAMETER_PORTAL_MAP_FILENAME, 8, 88, 300, 20, read_map_portal_mapfilename(@current_map, field_x, field_y))
  ButtonGadget(#GADGET_BUTTON_FIELD_PARAMETER_SELECT_PORTAL_MAP_FILENAME, 316, 88, 92, 20, "select map file")
  TextGadget(#GADGET_TEXT_FIELD_PARAMETER_PORTAL_X, 8, 120, 64, 20, "Target X")
  StringGadget(#GADGET_STRING_FIELD_PARAMETER_PORTAL_X, 54, 116, 24, 20, Str(read_map_portal_target_x(@current_map, field_x, field_y)), #PB_String_Numeric)
  TextGadget(#GADGET_TEXT_FIELD_PARAMETER_PORTAL_Y, 80, 120, 64, 16, "Target Y")
  StringGadget(#GADGET_STRING_FIELD_PARAMETER_PORTAL_Y, 128, 116, 24, 20, Str(read_map_portal_target_y(@current_map, field_x, field_y)), #PB_String_Numeric)
  ButtonGadget(#GADGET_BUTTON_FIELD_PARAMETER_SELECT_PORTAL_DESTINATION, 160, 116, 248, 20, "select destination on map")
  ButtonGadget(#GADGET_BUTTON_FIELD_PARAMETER_OK, 8, 376, 192, 32, "OK", #PB_Button_Default)
  ButtonGadget(#GADGET_BUTTON_FIELD_PARAMETER_CANCEL, 208, 376, 192, 32, "Cancel")
  TextGadget(#GADGET_TEXT_FIELD_PARAMETER_MESSAGE, 8, 144, 400, 16, "Text message displayed when entering/pushing:")
  StringGadget(#GADGET_STRING_FIELD_PARAMETER_MESSAGE_LINE1, 48, 160, 344, 20, read_map_message_line1(@current_map, field_x, field_y))
  StringGadget(#GADGET_STRING_FIELD_PARAMETER_MESSAGE_LINE2, 48, 184, 344, 20, read_map_message_line2(@current_map, field_x, field_y))
  ImageGadget(#GADGET_IMAGE_FIELD_PARAMETER_MESSAGE_TILE, 8, 160, 32, 32, ImageID(100+message_tile), #PB_Image_Border)
  TextGadget(#GADGET_TEXT_FIELD_PARAMETER_TRIGGER_EVENT, 8, 212, 400, 16, "Trigger event")
  StringGadget(#GADGET_STRING_FIELD_PARAMETER_TRIGGER_EVENT, 8, 228, 370, 20, event$)
  CheckBoxGadget(#GADGET_CHECKBOX_FIELD_PARAMETER_EVENT_XP, 380, 228, 36, 20, "XP")
  If read_map_event_xp(@current_map, field_x, field_y)
    SetGadgetState(#GADGET_CHECKBOX_FIELD_PARAMETER_EVENT_XP, 1)
  EndIf
  TextGadget(#GADGET_TEXT_FIELD_PARAMETER_TRANSFORMATIONS, 8, 256, 400, 16, "Transformations:")
  ListViewGadget(#GADGET_LISTVIEW_FIELD_PARAMETER_TRANSFORMATIONS, 8, 272, 400, 64)
  update_listview_of_transformations()
  ButtonGadget(#GADGET_BUTTON_FIELD_PARAMETER_ADD_TRANSFORMATION, 8, 344, 32, 20, "add")
  ButtonGadget(#GADGET_BUTTON_FIELD_PARAMETER_EDIT_TRANSFORMATION, 48, 344, 32, 20, "edit")
  ButtonGadget(#GADGET_BUTTON_FIELD_PARAMETER_DELETE_TRANSFORMATION, 88, 344, 32, 20, "delete")
  DisableGadget(#GADGET_BUTTON_FIELD_PARAMETER_EDIT_TRANSFORMATION, 1)
  DisableGadget(#GADGET_BUTTON_FIELD_PARAMETER_DELETE_TRANSFORMATION, 1)
  ImageGadget(#GADGET_IMAGE_FIELD_PARAMETER_TILE, 8, 8, 32, 32, ImageID(100+field_tile_type), #PB_Image_Border)
EndProcedure


Procedure open_window_add_transformation()
  Protected field_tile_type.w, event$
  If IsWindow(#WINDOW_TRANSFORMATION)
    CloseWindow(#WINDOW_TRANSFORMATION)
  EndIf
  OpenWindow(#WINDOW_TRANSFORMATION, 0, 0, 416, 416, "Lost Labyrinth Portals Map Editor - Add Transformation", #PB_Window_SystemMenu|#PB_Window_ScreenCentered, WindowID(#WINDOW_FIELD_PARAMETER))
  DisableWindow(#WINDOW_FIELD_PARAMETER, 1)
  transformation_tile = read_map_tile_type(@current_map, field_x, field_y)
  event$ = read_map_event(@current_map, field_x, field_y)
  message_tile = 0
  ;CreateGadgetList(WindowID(#WINDOW_TRANSFORMATION))
  ImageGadget(#GADGET_IMAGE_TRANSFORMATION_TILE, 8, 8, 32, 32, ImageID(100+transformation_tile), #PB_Image_Border)
  TextGadget(#GADGET_TEXT_TRANSFORMATION_XY, 48, 8, 360, 16, "Field position: " + Str(field_x) + " / " + Str(field_y), 0)
  TextGadget(#GADGET_TEXT_TRANSFORMATION_TILE_TYPE, 48, 24, 360, 16, "Tile type: " + tile_type_db(transformation_tile)\name$)
  TextGadget(#GADGET_TEXT_TRANSFORMATION_EVENT, 8, 72, 192, 16, "Transformation triggered by event:")
  ComboBoxGadget(#GADGET_COMBOBOX_TRANSFORMATION_EVENT, 200, 72, 192, 100)
  build_map_event_list(@current_map)
  ForEach map_event()
    AddGadgetItem(#GADGET_COMBOBOX_TRANSFORMATION_EVENT, -1, map_event()\name$)
  Next
  TextGadget(#GADGET_TEXT_TANSFORMATION_PORTAL_MAP_FILENAME, 8, 92, 400, 16, "Portal to map (filename):")
  StringGadget(#GADGET_STRING_TRANSFORMATION_PORTAL_MAP_FILENAME, 8, 108, 300, 20, "")
  ButtonGadget(#GADGET_BUTTON_TRANSFORMATION_SELECT_PORTAL_MAP_FILENAME, 316, 108, 92, 20, "select map file")
  TextGadget(#GADGET_TEXT_TRANSFORMATION_PORTAL_X, 8, 140, 64, 20, "Target X")
  StringGadget(#GADGET_STRING_TRANSFORMATION_PORTAL_X, 54, 136, 24, 20, "", #PB_String_Numeric)
  TextGadget(#GADGET_TEXT_TRANSFORMATION_PORTAL_Y, 80, 140, 64, 16, "Target Y")
  StringGadget(#GADGET_STRING_TRANSFORMATION_PORTAL_Y, 128, 136, 24, 20, "", #PB_String_Numeric)
  ButtonGadget(#GADGET_BUTTON_TRANSFORMATION_SELECT_PORTAL_DESTINATION, 160, 136, 248, 20, "select destination on map")
  ButtonGadget(#GADGET_BUTTON_TRANSFORMATION_OK, 8, 376, 192, 32, "OK")
  ButtonGadget(#GADGET_BUTTON_TRANSFORMATION_CANCEL, 208, 376, 192, 32, "Cancel")
  TextGadget(#GADGET_TEXT_TRANSFORMATION_MESSAGE, 8, 164, 400, 16, "Text message displayed when entering/pushing:")
  StringGadget(#GADGET_STRING_TRANSFORMATION_MESSAGE_LINE1, 48, 180, 344, 20, "")
  StringGadget(#GADGET_STRING_TRANSFORMATION_MESSAGE_LINE2, 48, 204, 344, 20, "")
  ImageGadget(#GADGET_IMAGE_ADD_TRANSFORMATION_MESSAGE_TILE, 8, 180, 32, 32, ImageID(100 + transformation_message_tile), #PB_Image_Border)
  TextGadget(#GADGET_TEXT_TRANSFORMATION_NEW_EVENT, 8, 224, 400, 16, "Event triggered:")
  StringGadget(#GADGET_STRING_TRANSFORMATION_NEW_EVENT, 8, 240, 400, 20, "")
EndProcedure


Procedure open_window_edit_transformation()
  Protected event$, new_event$, new_field_portal_mapfile$="", new_field_portal_x.b=0, new_field_portal_y.b=0
  Protected new_field_message_line1$="", new_field_message_line2$=""
  If IsWindow(#WINDOW_TRANSFORMATION)
    CloseWindow(#WINDOW_TRANSFORMATION)
  EndIf
  event$ = GetGadgetText(#GADGET_LISTVIEW_FIELD_PARAMETER_TRANSFORMATIONS)
  OpenWindow(#WINDOW_TRANSFORMATION, 0, 0, 416, 416, "Lost Labyrinth Portals Map Editor - Edit Transformation", #PB_Window_SystemMenu|#PB_Window_ScreenCentered, WindowID(#WINDOW_FIELD_PARAMETER))
  DisableWindow(#WINDOW_FIELD_PARAMETER, 1)
  ForEach map_transformation()
    If map_transformation()\event$ = event$ And map_transformation()\x = field_x And map_transformation()\y = field_y
      transformation_tile = map_transformation()\new_field\tile_type
      new_field_portal_mapfile$ = map_transformation()\new_field\portal_mapfile
      new_field_portal_x = map_transformation()\new_field\portal_x
      new_field_portal_y = map_transformation()\new_field\portal_y
      new_field_message_line1$ = map_transformation()\new_field\message_line1$
      new_field_message_line2$ = map_transformation()\new_field\message_line2$
      new_event$ = map_transformation()\new_field\event$
      transformation_message_tile = map_transformation()\new_field\message_tile
    EndIf
  Next
  ;CreateGadgetList(WindowID(#WINDOW_TRANSFORMATION))
  ImageGadget(#GADGET_IMAGE_TRANSFORMATION_TILE, 8, 8, 32, 32, ImageID(100+transformation_tile), #PB_Image_Border)
  TextGadget(#GADGET_TEXT_TRANSFORMATION_XY, 48, 8, 360, 16, "Field position: " + Str(field_x) + " / " + Str(field_y), 0)
  TextGadget(#GADGET_TEXT_TRANSFORMATION_TILE_TYPE, 48, 24, 360, 16, "Tile type: " + tile_type_db(transformation_tile)\name$)
  TextGadget(#GADGET_TEXT_TRANSFORMATION_EVENT, 8, 72, 192, 16, "Transformation triggered by event:")
  TextGadget(#GADGET_TEXT_TRANSFORMATION_EVENT2, 200, 72, 192, 16, event$, #PB_Text_Border)
  TextGadget(#GADGET_TEXT_TANSFORMATION_PORTAL_MAP_FILENAME, 8, 92, 400, 16, "Portal to map (filename):")
  StringGadget(#GADGET_STRING_TRANSFORMATION_PORTAL_MAP_FILENAME, 8, 108, 300, 20, new_field_portal_mapfile$)
  ButtonGadget(#GADGET_BUTTON_TRANSFORMATION_SELECT_PORTAL_MAP_FILENAME, 316, 108, 92, 20, "select map file")
  TextGadget(#GADGET_TEXT_TRANSFORMATION_PORTAL_X, 8, 140, 64, 20, "Target X")
  StringGadget(#GADGET_STRING_TRANSFORMATION_PORTAL_X, 54, 136, 24, 20, Str(new_field_portal_x), #PB_String_Numeric)
  TextGadget(#GADGET_TEXT_TRANSFORMATION_PORTAL_Y, 80, 140, 64, 16, "Target Y")
  StringGadget(#GADGET_STRING_TRANSFORMATION_PORTAL_Y, 128, 136, 24, 20, Str(new_field_portal_y), #PB_String_Numeric)
  ButtonGadget(#GADGET_BUTTON_TRANSFORMATION_SELECT_PORTAL_DESTINATION, 160, 136, 248, 20, "select destination on map")
  ButtonGadget(#GADGET_BUTTON_TRANSFORMATION_EDIT_OK, 8, 376, 184, 32, "OK")
  ButtonGadget(#GADGET_BUTTON_TRANSFORMATION_EDIT_CANCEL, 208, 376, 184, 32, "Cancel")
  TextGadget(#GADGET_TEXT_TRANSFORMATION_MESSAGE, 8, 164, 400, 16, "Text message displayed when entering/pushing:")
  ImageGadget(#GADGET_IMAGE_EDIT_TRANSFORMATION_MESSAGE_TILE, 8, 180, 32, 32, ImageID(100 + transformation_message_tile), #PB_Image_Border)
  StringGadget(#GADGET_STRING_TRANSFORMATION_MESSAGE_LINE1, 48, 180, 344, 20, new_field_message_line1$)
  StringGadget(#GADGET_STRING_TRANSFORMATION_MESSAGE_LINE2, 48, 204, 344, 20, new_field_message_line2$)
  TextGadget(#GADGET_TEXT_TRANSFORMATION_NEW_EVENT, 8, 224, 400, 16, "Event triggered:")
  StringGadget(#GADGET_STRING_TRANSFORMATION_NEW_EVENT, 8, 240, 400, 20, new_event$)  
EndProcedure


Procedure open_portal_destination_window()
  Protected open_map.b = 1, portal_mapfile$
  portal_mapfile$ = GetFilePart(GetGadgetText(#GADGET_STRING_FIELD_PARAMETER_PORTAL_MAP_FILENAME))
  If portal_mapfile$ = ""
    MessageRequester("Error", "No map file selected.")
    open_map = 0
  EndIf
  If open_map
    If FileSize("maps\" + portal_mapfile$) < 1
      MessageRequester("Error", "Cannot find map file: " + Chr(34) + portal_mapfile$ + Chr(34))
      open_map = 0
    EndIf
  EndIf
  load_map(@map_portal_destination, "maps\" + portal_mapfile$, 0)
  load_tile_type_definition(@map_portal_destination\tileset)
  load_tileset(@map_portal_destination\tileset, 0, 1)
  create_images_from_tileset(@map_portal_destination\tileset, 100 + #MAX_NUMBER_OF_TILE_TYPES)
  If open_map
    If OpenWindow(#WINDOW_PORTAL_MAP, 0, 0, 416, 432, "Select portal destination:", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
      StartDrawing(ImageOutput(#IMAGE_PORTAL_DESTINATION_SCROLLAREA))
      For y=0 To #MAP_DIMENSION_X-1
        For x=0 To #MAP_DIMENSION_Y-1
          tile = read_map_tile_type(@map_portal_destination, x, y)
          DrawImage(ImageID(100 + #MAX_NUMBER_OF_TILE_TYPES + tile), x*32, y*32)
        Next
      Next
      StopDrawing()    
      ;CreateGadgetList(WindowID(#WINDOW_PORTAL_MAP))
      ScrollAreaGadget(#GADGET_SCROLLAREA_PORTAL_MAP, 0, 0, 416, 416, #MAP_DIMENSION_X*32, #MAP_DIMENSION_Y*32, 1)
      ImageGadget(#GADGET_IMAGE_PORTAL_MAP, 0, 0, #MAP_DIMENSION_X*32, #MAP_DIMENSION_Y*32, ImageID(#IMAGE_PORTAL_DESTINATION_SCROLLAREA))
      DisableWindow(#WINDOW_FIELD_PARAMETER, 1)
    EndIf
  EndIf
EndProcedure


Procedure open_new_map_window()
  If IsWindow(#WINDOW_CREATE_NEW_MAP)
    CloseWindow(#WINDOW_CREATE_NEW_MAP)
  EndIf
  OpenWindow(#WINDOW_CREATE_NEW_MAP, 0, 0, 300, 200, "Create a new map", #PB_Window_ScreenCentered)
  DisableWindow(#WINDOW_MAIN, 1)
  ;CreateGadgetList(WindowID(#WINDOW_CREATE_NEW_MAP))
  TextGadget(#GADGET_TEXT_NEW_MAP_NAME, 8, 8, 284, 16, "Name of the new map:")
  StringGadget(#GADGET_STRING_NEW_MAP_NAME, 8, 24, 284, 20, "<new map>")
  TextGadget(#GADGET_TEXT_NEW_MAP_TILESET_DEFINITION, 8, 52, 284, 16, "Tileset definition xml file:")
  StringGadget(#GADGET_STRING_NEW_MAP_TILESET_DEFINITION, 8, 68, 200, 20, GetFilePart(current_map\tileset\definition_filename$))
  ButtonGadget(#GADGET_BUTTION_NEW_MAP_TILESET_DEFINITION, 216, 68, 76, 20, "select file")
  TextGadget(#GADGET_TEXT_NEW_MAP_TILESET_IMAGE, 8, 96, 284, 16, "Tileset image file:")
  StringGadget(#GADGET_STRING_NEW_MAP_TILESET_IMAGE, 8, 112, 200, 20, GetFilePart(current_map\tileset\image_filename$))
  ButtonGadget(#GADGET_BUTTON_NEW_MAP_TILESET_IMAGE, 216, 112, 76, 20, "select file")
  ButtonGadget(#GADGET_BUTTON_NEW_MAP_OK, 8, 172, 138, 20, "OK")
  ButtonGadget(#GADGET_BUTTON_NEW_MAP_CANCEL, 154, 172, 138, 20, "Cancel")
EndProcedure


Procedure save_field_parameter()
  Protected portal_mapfile$, portal_x.b, portal_y.b, event$, event_xp.b=0
  portal_mapfile$ = GetGadgetText(#GADGET_STRING_FIELD_PARAMETER_PORTAL_MAP_FILENAME)
  portal_x = Val(GetGadgetText(#GADGET_STRING_FIELD_PARAMETER_PORTAL_X))
  portal_y = Val(GetGadgetText(#GADGET_STRING_FIELD_PARAMETER_PORTAL_Y))
  event$ = GetGadgetText(#GADGET_STRING_FIELD_PARAMETER_TRIGGER_EVENT)
  set_map_portal(@current_map, field_x, field_y, portal_mapfile$, portal_x, portal_y)
  set_map_message(@current_map, field_x, field_y, GetGadgetText(#GADGET_STRING_FIELD_PARAMETER_MESSAGE_LINE1), GetGadgetText(#GADGET_STRING_FIELD_PARAMETER_MESSAGE_LINE2), message_tile)
  If GetGadgetState(#GADGET_CHECKBOX_FIELD_PARAMETER_EVENT_XP) = 1
    event_xp = 1
  EndIf
  set_map_event(@current_map, field_x, field_y, event$, event_xp)
  CloseWindow(#WINDOW_FIELD_PARAMETER)
  DisableWindow(#WINDOW_MAIN, 0)
  SetActiveWindow(#WINDOW_MAIN)
  update_scrollarea()
  SetGadgetState(#GADGET_SCROLLIMAGE,ImageID(#IMAGE_SCROLLAREA))
  map_changed = 1
EndProcedure


Procedure select_paint_tile()
  x = Int(WindowMouseX(#WINDOW_SELECT_PAINT_TILE) / 32)
  y = Int(WindowMouseY(#WINDOW_SELECT_PAINT_TILE) / 32)
  paint_tile = x + y * current_map\tileset\columns
  CloseWindow(#WINDOW_SELECT_PAINT_TILE)
  DisableWindow(#WINDOW_MAIN, 0)
  SetActiveWindow(#WINDOW_MAIN)    
  SetGadgetState(#GADGET_PAINT_TILE1,ImageID(100+paint_tile))
  If current_map\tileset\tile_type_db[paint_tile]\in_use = 0
    MessageRequester("Warning", "The selected tile could not be found in the tile type definition!")
  EndIf
EndProcedure


Procedure select_monster_in_mapeditor()
  Protected x.w, y.w, i.w, tile.w, type.w
  x = Int(WindowMouseX(#WINDOW_SELECT_MONSTER) / 32)
  y = Int(WindowMouseY(#WINDOW_SELECT_MONSTER) / 32)
  tile = x + y * Int(ImageWidth(#IMAGE_MONSTER) / 32)
  type = -1
  CloseWindow(#WINDOW_SELECT_MONSTER)
  DisableWindow(#WINDOW_MAIN, 0)
  SetActiveWindow(#WINDOW_MAIN)    
  For i=1 To #MAX_NUMBER_OF_MONSTER_TYPES-1
    If monster_type_db(i)\tile = tile And monster_type_db(i)\name$ <> ""
      type = i
    EndIf
  Next
  If type = -1
    MessageRequester("Warning", "The currently selected monster cannot be found in the monster database!")
  Else
    place_monster_tile = tile
    place_monster_type = type
    ;Debug tile
    ;Debug type
    SetGadgetState(#GADGET_IMAGE_PLACE_MONSTER, ImageID(500 + place_monster_tile))
  EndIf
EndProcedure


Procedure select_background_tile()
  Protected x.w, y.w
  x = Int(WindowMouseX(#WINDOW_SELECT_BACKGROUND_TILE) / 32)
  y = Int(WindowMouseY(#WINDOW_SELECT_BACKGROUND_TILE) / 32)
  background_tile = x + y * current_map\tileset\columns
  CloseWindow(#WINDOW_SELECT_BACKGROUND_TILE)
  DisableWindow(#WINDOW_MAIN, 0)
  SetActiveWindow(#WINDOW_MAIN)    
  SetGadgetState(#GAGDET_BACKGROUND_TILE,ImageID(100 + background_tile))
  If current_map\tileset\tile_type_db[background_tile]\in_use = 0
    MessageRequester("Warning", "The selected tile could not be found in the tile type definition!")
  EndIf
  current_map\background_tile = background_tile
  map_changed = 1
EndProcedure


Procedure select_outside_tile()
  x = Int(WindowMouseX(#WINDOW_SELECT_OUTSIDE_TILE) / 32)
  y = Int(WindowMouseY(#WINDOW_SELECT_OUTSIDE_TILE) / 32)
  outside_tile = x + y * current_map\tileset\columns
  CloseWindow(#WINDOW_SELECT_OUTSIDE_TILE)
  DisableWindow(#WINDOW_MAIN, 0)
  SetActiveWindow(#WINDOW_MAIN)    
  SetGadgetState(#GADGET_IMAGE_TILE_OUTSIDE,ImageID(100 + outside_tile))
  If current_map\tileset\tile_type_db[outside_tile]\in_use = 0
    MessageRequester("Warning", "The selected tile could not be found in the tile type definition!")
  EndIf
  current_map\tile_outside_map = outside_tile
  map_changed = 1
EndProcedure


Procedure select_transformation_tile()
  x = Int(WindowMouseX(#WINDOW_SELECT_TRANSFORMATION_TILE) / 32)
  y = Int(WindowMouseY(#WINDOW_SELECT_TRANSFORMATION_TILE) / 32)
  transformation_tile = x + y * current_map\tileset\columns
  CloseWindow(#WINDOW_SELECT_TRANSFORMATION_TILE)
  DisableWindow(#WINDOW_TRANSFORMATION, 0)
  SetActiveWindow(#WINDOW_TRANSFORMATION)    
  SetGadgetState(#GADGET_IMAGE_TRANSFORMATION_TILE,ImageID(100 + transformation_tile))
  If current_map\tileset\tile_type_db[transformation_tile]\in_use = 0
    MessageRequester("Warning", "The selected tile could not be found in the tile type definition!")
  EndIf
EndProcedure


Procedure select_message_tile()
  x = Int(WindowMouseX(#WINDOW_SELECT_MESSAGE_TILE) / 32)
  y = Int(WindowMouseY(#WINDOW_SELECT_MESSAGE_TILE) / 32)
  message_tile = x + y * current_map\tileset\columns
  CloseWindow(#WINDOW_SELECT_MESSAGE_TILE)
  DisableWindow(#WINDOW_FIELD_PARAMETER, 0)
  SetActiveWindow(#WINDOW_FIELD_PARAMETER)    
  SetGadgetState(#GADGET_IMAGE_FIELD_PARAMETER_MESSAGE_TILE,ImageID(100 + message_tile))
  If current_map\tileset\tile_type_db[message_tile]\in_use = 0
    MessageRequester("Warning", "The selected tile could not be found in the tile type definition!")
  EndIf 
  map_changed = 1 
EndProcedure


Procedure select_message_tile_add_transformation()
  x = Int(WindowMouseX(#WINDOW_SELECT_MESSAGE_TILE) / 32)
  y = Int(WindowMouseY(#WINDOW_SELECT_MESSAGE_TILE) / 32)
  transformation_message_tile = x + y * current_map\tileset\columns
  CloseWindow(#WINDOW_SELECT_MESSAGE_TILE)
  DisableWindow(#WINDOW_TRANSFORMATION, 0)
  SetActiveWindow(#WINDOW_TRANSFORMATION)    
  SetGadgetState(#GADGET_IMAGE_ADD_TRANSFORMATION_MESSAGE_TILE,ImageID(100 + transformation_message_tile))
  If current_map\tileset\tile_type_db[message_tile]\in_use = 0
    MessageRequester("Warning", "The selected tile could not be found in the tile type definition!")
  EndIf 
  map_changed = 1 
EndProcedure


Procedure select_message_tile_edit_transformation()
  x = Int(WindowMouseX(#WINDOW_SELECT_MESSAGE_TILE) / 32)
  y = Int(WindowMouseY(#WINDOW_SELECT_MESSAGE_TILE) / 32)
  transformation_message_tile = x + y * current_map\tileset\columns
  CloseWindow(#WINDOW_SELECT_MESSAGE_TILE)
  DisableWindow(#WINDOW_TRANSFORMATION, 0)
  SetActiveWindow(#WINDOW_TRANSFORMATION)    
  SetGadgetState(#GADGET_IMAGE_EDIT_TRANSFORMATION_MESSAGE_TILE,ImageID(100 + transformation_message_tile))
  If current_map\tileset\tile_type_db[message_tile]\in_use = 0
    MessageRequester("Warning", "The selected tile could not be found in the tile type definition!")
  EndIf 
  map_changed = 1 
EndProcedure


Procedure select_portal_destination()
  Protected x.w, y.w
  x = Int((WindowMouseX(#WINDOW_PORTAL_MAP) - GadgetX(#GADGET_SCROLLAREA_PORTAL_MAP) - GadgetX(#GADGET_IMAGE_PORTAL_MAP) + GetGadgetAttribute(#GADGET_SCROLLAREA_PORTAL_MAP,#PB_ScrollArea_X)) / 32)
  y = Int((WindowMouseY(#WINDOW_PORTAL_MAP) - GadgetY(#GADGET_SCROLLAREA_PORTAL_MAP) - GadgetY(#GADGET_IMAGE_PORTAL_MAP) + GetGadgetAttribute(#GADGET_SCROLLAREA_PORTAL_MAP,#PB_ScrollArea_Y)) / 32)
  CloseWindow(#WINDOW_PORTAL_MAP)
  DisableWindow(#WINDOW_FIELD_PARAMETER, 0)
  SetActiveWindow(#WINDOW_FIELD_PARAMETER)
  SetGadgetText(#GADGET_STRING_FIELD_PARAMETER_PORTAL_X, Str(x))
  SetGadgetText(#GADGET_STRING_FIELD_PARAMETER_PORTAL_Y, Str(y))  
EndProcedure


Procedure open_map_in_mapeditor()
  Protected open_map.b = 1, new_filename$
  If map_changed = 1
    Select MessageRequester("Lost Labyrinth Portals Map Editor", "Do you want to save your map?", #PB_MessageRequester_YesNoCancel)
      Case #PB_MessageRequester_Yes:
        If map_filename$ = ""
          map_filename$ = SaveFileRequester("Choose map xml file to open", "map.xml", "XML File (*.xml)|*.xml|all files (*.*)|*.*", 0)
        EndIf
        If map_filename$ <> ""
          save_map(@current_map, map_filename$)
          SetWindowTitle(#WINDOW_MAIN, main_window_title$ + " - " + GetFilePart(map_filename$))
        EndIf
      Case #PB_MessageRequester_Cancel:
        open_map = 0
    EndSelect
  EndIf
  If open_map = 1
    new_filename$ = OpenFileRequester("Choose map xml file to open", "maps\" + GetFilePart(map_filename$), "XML File (*.xml)|*.xml|all files (*.*)|*.*", 0)
    If new_filename$ <> ""
      load_map(@current_map, new_filename$, 0)
      load_tile_type_definition(@current_map\tileset)
      load_tileset(@current_map\tileset, 0, 1)
      create_images_from_tileset(@current_map\tileset, 100)
      map_filename$ = new_filename$
      update_scrollarea()
      SetGadgetState(#GADGET_SCROLLIMAGE,ImageID(#IMAGE_SCROLLAREA))
      SetWindowTitle(#WINDOW_MAIN, main_window_title$ + " - " + GetFilePart(map_filename$))
      SetGadgetText(#GADGET_STRING_MAP_NAME, current_map\name)
      background_tile = current_map\background_tile
      SetGadgetState(#GAGDET_BACKGROUND_TILE,ImageID(100 + background_tile))
      outside_tile = current_map\tile_outside_map
      SetGadgetState(#GADGET_IMAGE_TILE_OUTSIDE,ImageID(100 + outside_tile))
      map_changed = 0
    EndIf
  EndIf
EndProcedure


; paint with tile; returns 1 if successful, else 0
Procedure.b paint_with_tile(tile.w)
  Protected rc.b = 0
  x = Int((WindowMouseX(#WINDOW_MAIN) - GadgetX(#GADGET_SCROLLAREA) - GadgetX(#GADGET_SCROLLIMAGE) + GetGadgetAttribute(#GADGET_SCROLLAREA,#PB_ScrollArea_X)) / 32)
  y = Int((WindowMouseY(#WINDOW_MAIN) - GadgetY(#GADGET_SCROLLAREA) - GadgetY(#GADGET_SCROLLIMAGE) + GetGadgetAttribute(#GADGET_SCROLLAREA,#PB_ScrollArea_Y)) / 32)      
  set_map_tile_type(@current_map, x, y, tile)
  update_scrollarea()
  SetGadgetState(#GADGET_SCROLLIMAGE,ImageID(#IMAGE_SCROLLAREA))
  map_changed = 1 
  ProcedureReturn rc
EndProcedure


Procedure.b place_monster_in_mapeditor()
  Protected rc.b = 0, x.w, y.w, new_monster.monster_struct
  x = Int((WindowMouseX(#WINDOW_MAIN) - GadgetX(#GADGET_SCROLLAREA) - GadgetX(#GADGET_SCROLLIMAGE) + GetGadgetAttribute(#GADGET_SCROLLAREA,#PB_ScrollArea_X)) / 32)
  y = Int((WindowMouseY(#WINDOW_MAIN) - GadgetY(#GADGET_SCROLLAREA) - GadgetY(#GADGET_SCROLLIMAGE) + GetGadgetAttribute(#GADGET_SCROLLAREA,#PB_ScrollArea_Y)) / 32)
  If field_contains_monster(x, y) = 0 And monster_type_db(place_monster_type)\name$ <> ""
    new_monster\type = place_monster_type
    new_monster\xpos = x
    new_monster\ypos = y
    new_monster\hitpoints = monster_type_db(place_monster_type)\hitpoints
    new_monster\alerted = 0
    new_monster\y_offset = 0
    rc = add_monster(@current_map, @new_monster)
    If rc = 1
      map_changed = 1
    EndIf  
  EndIf
  If rc = 1
    update_scrollarea()
    SetGadgetState(#GADGET_SCROLLIMAGE,ImageID(#IMAGE_SCROLLAREA))
  EndIf
  ProcedureReturn rc
EndProcedure


Procedure.b remove_monster_in_mapeditor()
  Protected rc.b = 0, x.w, y.w, *monster = 0
  x = Int((WindowMouseX(#WINDOW_MAIN) - GadgetX(#GADGET_SCROLLAREA) - GadgetX(#GADGET_SCROLLIMAGE) + GetGadgetAttribute(#GADGET_SCROLLAREA,#PB_ScrollArea_X)) / 32)
  y = Int((WindowMouseY(#WINDOW_MAIN) - GadgetY(#GADGET_SCROLLAREA) - GadgetY(#GADGET_SCROLLIMAGE) + GetGadgetAttribute(#GADGET_SCROLLAREA,#PB_ScrollArea_Y)) / 32)
  If field_contains_monster(x, y) = 1
    ForEach monster()
      If monster()\xpos = x And monster()\ypos = y
        *monster = @monster()
      EndIf
    Next
    If *monster > 0
      ChangeCurrentElement(monster(), *monster)
      DeleteElement(monster())
      rc = 1
    EndIf
  EndIf
  If rc = 1
    update_scrollarea()
    SetGadgetState(#GADGET_SCROLLIMAGE,ImageID(#IMAGE_SCROLLAREA))
  EndIf
  ProcedureReturn rc
EndProcedure


Procedure create_new_map_in_mapeditor()
  Protected ok.b = 1, new_map_name$
  If map_changed = 1
    Select MessageRequester("Lost Labyrinth Portals Map Editor", "Do you want to save your map?", #PB_MessageRequester_YesNoCancel)
      Case #PB_MessageRequester_Yes:
        If map_filename$ = ""
          map_filename$ = SaveFileRequester("Choose map xml file to open", "map.xml", "XML File (*.xml)|*.xml|all files (*.*)|*.*", 0)
        EndIf
        If map_filename$ <> ""
          save_map(@current_map, map_filename$)
          SetWindowTitle(#WINDOW_MAIN, main_window_title$ + " - " + GetFilePart(map_filename$))
        EndIf
      Case #PB_MessageRequester_Cancel:
        ok = 0
    EndSelect
  EndIf
  new_map_name$ = GetGadgetText(#GADGET_STRING_NEW_MAP_NAME)
  new_map_tileset_definition$ = GetGadgetText(#GADGET_STRING_NEW_MAP_TILESET_DEFINITION)
  new_map_tileset_image$ = GetGadgetText(#GADGET_STRING_NEW_MAP_TILESET_IMAGE)
  If ok = 1 And new_map_tileset_definition$ = ""
    MessageRequester("Error", "Please select a tileset definition xml file!")
    ok = 0
  EndIf
  If ok = 1 And new_map_tileset_image$ = ""
    MessageRequester("Error", "Please select a tileset image file!")
    ok = 0
  EndIf
  If ok = 1
    If FileSize("tilesets\" + new_map_tileset_definition$) < 1
      MessageRequester("Error", "Could not find tileset definition file " + Chr(34) + "tilesets\" + new_map_tileset_definition$ + Chr(34) + "!")
      ok = 0
    EndIf
  EndIf
  If ok = 1
    If FileSize("tilesets\" + new_map_tileset_image$) < 1
      MessageRequester("Error", "Could not find tileset image file " + Chr(34) + "tilesets\" + new_map_tileset_image$ + Chr(34) + "!")
      ok = 0
    EndIf
  EndIf    
  If ok = 1
    map_filename$ = ""
    CloseWindow(#WINDOW_CREATE_NEW_MAP)
    DisableWindow(#WINDOW_MAIN, 0)
    SetActiveWindow(#WINDOW_MAIN)
    reset_map(@current_map)
    current_map\name = new_map_name$
    current_map\tileset\definition_filename$ = new_map_tileset_definition$
    current_map\tileset\image_filename$ = new_map_tileset_image$
    load_tile_type_definition(@current_map\tileset)
    load_tileset(@current_map\tileset, 0, 1)
    create_images_from_tileset(@current_map\tileset, 100)
    fill_map(@current_map, background_tile)
    update_scrollarea()
    SetGadgetState(#GADGET_SCROLLIMAGE,ImageID(#IMAGE_SCROLLAREA))
    SetGadgetState(#GADGET_PAINT_TILE1,ImageID(100+paint_tile))
    SetGadgetState(#GAGDET_BACKGROUND_TILE,ImageID(100 + background_tile))
    SetGadgetState(#GADGET_IMAGE_TILE_OUTSIDE,ImageID(100 + outside_tile))
    SetGadgetText(#GADGET_STRING_MAP_NAME, current_map\name)
    map_changed = 1
  EndIf
EndProcedure


Procedure.b add_transformation_from_editor()
  Protected event$, portal_mapfile$, portal_x.b, portal_y.b, message_line1$, message_line2$
  Protected rc.b = 0, new_event$ = ""
  Protected transformation.map_transformation_struct
  event$ = GetGadgetText(#GADGET_COMBOBOX_TRANSFORMATION_EVENT)
  If Trim(event$) <> ""
    transformation\x = field_x
    transformation\y = field_y
    transformation\event$ = event$
    transformation\triggered = 0
    transformation\new_field\portal_mapfile = GetGadgetText(#GADGET_STRING_TRANSFORMATION_PORTAL_MAP_FILENAME)
    transformation\new_field\portal_x = Val(GetGadgetText(#GADGET_STRING_TRANSFORMATION_PORTAL_X))
    transformation\new_field\portal_y = Val(GetGadgetText(#GADGET_STRING_TRANSFORMATION_PORTAL_Y))
    transformation\new_field\message_line1$ = GetGadgetText(#GADGET_STRING_TRANSFORMATION_MESSAGE_LINE1)
    transformation\new_field\message_line2$ = GetGadgetText(#GADGET_STRING_TRANSFORMATION_MESSAGE_LINE2)
    transformation\new_field\message_tile = transformation_message_tile
    transformation\new_field\event$ = GetGadgetText(#GADGET_STRING_TRANSFORMATION_NEW_EVENT)
    add_map_transformation(@transformation)
    map_changed = 1
    rc = 1
  EndIf
  CloseWindow(#WINDOW_TRANSFORMATION)
  DisableWindow(#WINDOW_FIELD_PARAMETER, 0)
  SetActiveWindow(#WINDOW_FIELD_PARAMETER)
  update_listview_of_transformations()  
  ProcedureReturn rc
EndProcedure


Procedure edit_transformation_from_editor()
  Protected event$
  event$ = GetGadgetText(#GADGET_TEXT_TRANSFORMATION_EVENT2)
  ForEach map_transformation()
    If map_transformation()\event$ = event$ And map_transformation()\x = field_x And map_transformation()\y = field_y
      map_transformation()\new_field\tile_type = transformation_tile
      map_transformation()\new_field\portal_mapfile = GetGadgetText(#GADGET_STRING_TRANSFORMATION_PORTAL_MAP_FILENAME)
      map_transformation()\new_field\portal_x = Val(GetGadgetText(#GADGET_STRING_TRANSFORMATION_PORTAL_X))
      map_transformation()\new_field\portal_y = Val(GetGadgetText(#GADGET_STRING_TRANSFORMATION_PORTAL_Y))
      map_transformation()\new_field\message_line1$ = GetGadgetText(#GADGET_STRING_TRANSFORMATION_MESSAGE_LINE1)
      map_transformation()\new_field\message_line2$ = GetGadgetText(#GADGET_STRING_TRANSFORMATION_MESSAGE_LINE2)
      map_transformation()\new_field\message_tile = transformation_message_tile
      map_transformation()\new_field\event$ = GetGadgetText(#GADGET_STRING_TRANSFORMATION_NEW_EVENT)
    EndIf
  Next
  CloseWindow(#WINDOW_TRANSFORMATION)
  DisableWindow(#WINDOW_FIELD_PARAMETER, 0)
  SetActiveWindow(#WINDOW_FIELD_PARAMETER)
  update_listview_of_transformations()
EndProcedure


Procedure editor_view_monster_data()
  Protected i.w, j.w, k.w, text$, text2$, filename$="monsterdata.html"
  If CreateFile(0, filename$)
    WriteStringN(0, "<!DOCTYPE HTML PUBLIC " + Chr(34) + "-//W3C//DTD HTML 4.0 Transitional//EN" + Chr(34) + ">")
    WriteStringN(0, "<HTML>")
    WriteStringN(0, "<HEAD>")
    WriteStringN(0, "<TITLE> Lost Labyrinth: Portals </TITLE>")
    WriteStringN(0, "</HEAD>")
    WriteStringN(0, "<BODY>")
    WriteStringN(0, "<h1>Lost Labyrinth: Portals " + version_number$ + "</h1>")
    WriteStringN(0, "<h2>Monster Data</h2>")
    WriteStringN(0, "<TABLE CELLSPACING=" + Chr(34) + "0" + Chr(34) + " CELLPADDING=" + Chr(34) + "2" + Chr(34) + " BORDER=" + Chr(34) + "1" + Chr(34) + ">")
    text$ = "<TR VALIGN=" + Chr(34) + "bottom" + Chr(34) + ">"
    text$ = text$ + "<TH>Level</TH>"
    text$ = text$ + "<TH>Monster</TH>"
    text$ = text$ + "<TH>Classes</TH>"    
    text$ = text$ + "<TH>Attack</TH>"
    text$ = text$ + "<TH>Defense</TH>"
    text$ = text$ + "<TH>Hitpoints</TH>"
    text$ = text$ + "<TH>Armor</TH>"
    text$ = text$ + "<TH>Strength</TH>"
    text$ = text$ + "<TH>Speed</TH>"
    text$ = text$ + "<TH>Special</TH>"
    text$ = text$ + "</TR>"
    WriteStringN(0, text$)
    For i = 1 To 255
      For j = 1 To #MAX_NUMBER_OF_MONSTER_TYPES - 1
        If monster_type_db(j)\level = i
          text$ = "<TR>"
          text$ = text$ + "<TD>" + Str(i) + "</TD>"
          text$ = text$ + "<TD>" + monster_type_db(j)\name$ + "</TD>"
          text$ = text$ + "<TD>" + ReplaceString(monster_type_db(j)\class$, "|", ", ") + "</TD>"
          text$ = text$ + "<TD ALIGN=" + Chr(34) + "center" + Chr(34) + ">" + Str(monster_type_db(j)\attack) + "</TD>"
          text$ = text$ + "<TD ALIGN=" + Chr(34) + "center" + Chr(34) + ">" + Str(monster_type_db(j)\defense) + "</TD>"
          text$ = text$ + "<TD ALIGN=" + Chr(34) + "center" + Chr(34) + ">" + Str(monster_type_db(j)\hitpoints) + "</TD>"
          text$ = text$ + "<TD ALIGN=" + Chr(34) + "center" + Chr(34) + ">" + Str(monster_type_db(j)\armor) + "</TD>"
          text$ = text$ + "<TD ALIGN=" + Chr(34) + "center" + Chr(34) + ">" + Str(monster_type_db(j)\strength) + "</TD>"
          text$ = text$ + "<TD ALIGN=" + Chr(34) + "center" + Chr(34) + ">" + Str(monster_type_db(j)\speed) + "</TD>"
          text$ = text$ + "<TD>"
          text2$ = ""
          If monster_type_db(j)\flying = 1
            text2$ = text2$ + "Flyer"
          EndIf
          If monster_type_db(j)\regeneration > 0
            If text2$ <> ""
              text2$ = text2$ + "<BR>"
            EndIf
            text2$ = text2$ + "regenerates up to " + Str(monster_type_db(j)\regeneration) + " hitpoints per turn"            
          EndIf
          If monster_type_db(j)\resistance_class$ <> ""
            If text2$ <> ""
              text2$ = text2$ + "<BR>"
            EndIf
            text2$ = text2$ + "resistant vs " + ReplaceString(monster_type_db(j)\resistance_class$, "|", ", ")
          EndIf
          If monster_type_db(j)\immune_class$ <> ""
            If text2$ <> ""
              text2$ = text2$ + "<BR>"
            EndIf
            text2$ = text2$ + "immune vs " + ReplaceString(monster_type_db(j)\immune_class$, "|", ", ")
          EndIf
          If monster_type_db(j)\vulnerable_class$ <> ""
            If text2$ <> ""
              text2$ = text2$ + "<BR>"
            EndIf
            text2$ = text2$ + "vulnerable vs " + ReplaceString(monster_type_db(j)\vulnerable_class$, "|", ", ")
          EndIf
          For k = 0 To #MAX_NUMBER_OF_MONSTER_AFFLICTIONS - 1
            If monster_type_db(j)\affliction[k]\attribute > 0
              If text2$ <> ""
                text2$ = text2$ + "<BR>"
              EndIf
              text2$ = text2$ + "inflicts "
              If monster_type_db(j)\affliction[k]\randomized = 1
                text2$ = text2$ + "1 - "
              EndIf
              text2$ = text2$ + Str(monster_type_db(j)\affliction[k]\value) + " points of "
              text2$ = text2$ + ability_db(monster_type_db(j)\affliction[k]\attribute)\name$
              text2$ = text2$ + " at " + Str(monster_type_db(j)\affliction[k]\chance) + "%"
              text2$ = text2$ + " with a successful attack"
            EndIf
          Next
          If text2$ = ""
            text2$ = "&nbsp;"
          EndIf
          text$ = text$ + text2$ + "</TD></TR>"
          WriteStringN(0, text$)
        EndIf
      Next
    Next
    WriteStringN(0, "</TABLE>")
    WriteStringN(0, "</BODY>")
    WriteStringN(0, "</HTML>")
    CloseFile(0)
    RunProgram(filename$)
  EndIf
EndProcedure


Procedure editor_view_item_data()
  Protected i.w, j.w, k.w, text$, text2$, filename$="itemdata.html"
  If CreateFile(0, filename$)
    WriteStringN(0, "<!DOCTYPE HTML PUBLIC " + Chr(34) + "-//W3C//DTD HTML 4.0 Transitional//EN" + Chr(34) + ">")
    WriteStringN(0, "<HTML>")
    WriteStringN(0, "<HEAD>")
    WriteStringN(0, "<TITLE> Lost Labyrinth: Portals </TITLE>")
    WriteStringN(0, "</HEAD>")
    WriteStringN(0, "<BODY>")
    WriteStringN(0, "<h1>Lost Labyrinth: Portals " + version_number$ + "</h1>")
    WriteStringN(0, "<h2>Item Data</h2>")
    WriteStringN(0, "<TABLE CELLSPACING=" + Chr(34) + "0" + Chr(34) + " CELLPADDING=" + Chr(34) + "2" + Chr(34) + " BORDER=" + Chr(34) + "1" + Chr(34) + ">")
    text$ = "<TR VALIGN=" + Chr(34) + "bottom" + Chr(34) + ">"
    text$ = text$ + "<TH>Item</TH>"
    text$ = text$ + "<TH>Class</TH>"    
    text$ = text$ + "<TH>Weight</TH>"    
    text$ = text$ + "<TH>Price</TH>"
    text$ = text$ + "<TH>Special</TH>"
    text$ = text$ + "</TR>"
    WriteStringN(0, text$)
    For i = 1 To 255
      If item_db(i)\name$ <> ""
        text$ = "<TR>"
        text$ = text$ + "<TD>" + item_db(i)\name$ + "</TD>"
        text$ = text$ + "<TD>" + ReplaceString(item_db(i)\class$, "|", ", ") + "</TD>"
        text$ = text$ + "<TD ALIGN=" + Chr(34) + "center" + Chr(34) + ">" + StrF(item_db(i)\weight / 10, 1) + " lb</TD>"
        text$ = text$ + "<TD ALIGN=" + Chr(34) + "center" + Chr(34) + ">" + Str(item_db(i)\price) + "</TD>"
        text$ = text$ + "</TR>"
        WriteStringN(0, text$)
      EndIf
    Next
    WriteStringN(0, "</TABLE>")
    WriteStringN(0, "</BODY>")
    WriteStringN(0, "</HTML>")
    CloseFile(0)
    RunProgram(filename$)
  EndIf
EndProcedure


Procedure editor_view_powers_data()
  Protected i.w, j.w, k.w, text$, text2$, filename$="itemdata.html", effect_strength.w
  If CreateFile(0, filename$)
    WriteStringN(0, "<!DOCTYPE HTML PUBLIC " + Chr(34) + "-//W3C//DTD HTML 4.0 Transitional//EN" + Chr(34) + ">")
    WriteStringN(0, "<HTML>")
    WriteStringN(0, "<HEAD>")
    WriteStringN(0, "<TITLE> Lost Labyrinth: Portals </TITLE>")
    WriteStringN(0, "</HEAD>")
    WriteStringN(0, "<BODY>")
    WriteStringN(0, "<h1>Lost Labyrinth: Portals " + version_number$ + "</h1>")
    WriteStringN(0, "<h2>Powers Data</h2>")
    WriteStringN(0, "<TABLE CELLSPACING=" + Chr(34) + "0" + Chr(34) + " CELLPADDING=" + Chr(34) + "2" + Chr(34) + " BORDER=" + Chr(34) + "1" + Chr(34) + ">")
    text$ = "<TR VALIGN=" + Chr(34) + "bottom" + Chr(34) + ">"
    text$ = text$ + "<TH>Power</TH>"
    text$ = text$ + "<TH>Class</TH>"    
    text$ = text$ + "<TH>Effect</TH>"
    text$ = text$ + "<TH>Strength</TH>"
    text$ = text$ + "<TH>Description</TH>"
    text$ = text$ + "</TR>"
    WriteStringN(0, text$)
    For i = 1 To #MAX_NUMBER_OF_POWERS - 1
      If power_db(i)\name$ <> ""
        text$ = "<TR>"
        text$ = text$ + "<TD>" + power_db(i)\name$ + "</TD>"
        text$ = text$ + "<TD>" + ReplaceString(power_db(i)\class$, "|", ", ") + "</TD>"
        text$ = text$ + "<TD ALIGN=" + Chr(34) + "center" + Chr(34) + ">" + power_db(i)\effect_name$ + "</TD>"
        text$ = text$ + "<TD ALIGN=" + Chr(34) + "center" + Chr(34) + ">"
        effect_strength = power_db(i)\effect_strength
        text$ = text$ + Str(effect_strength)
        text$ = text$ + "</TD>"
        text$ = text$ + "<TD>" + power_db(i)\description$ + "</TD>"
        text$ = text$ + "</TR>"
        WriteStringN(0, text$)
      EndIf
    Next
    WriteStringN(0, "</TABLE>")
    WriteStringN(0, "</BODY>")
    WriteStringN(0, "</HTML>")
    CloseFile(0)
    RunProgram(filename$)
  EndIf
EndProcedure
; IDE Options = PureBasic 4.30 (Windows - x86)
; CursorPosition = 534
; FirstLine = 503
; Folding = --------
; CompileSourceDirectory
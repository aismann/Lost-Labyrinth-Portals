; Lost Labyrinth VI: Portals
; map editor(standalone)
; written in PureBasic 4.20 (http://www.purebasic.com)
; created:  15.10.2008 Frank Malota <malota@web.de>
; modified: 07.01.2009 Frank Malota <malota@web.de>


;- windows constants
Enumeration
  #WINDOW_MAIN
  #WINDOW_SELECT_PAINT_TILE
  #WINDOW_SELECT_BACKGROUND_TILE
  #WINDOW_SELECT_OUTSIDE_TILE
  #WINDOW_FIELD_PARAMETER
  #WINDOW_PORTAL_MAP
  #WINDOW_CREATE_NEW_MAP
  #WINDOW_ABOUT
  #WINDOW_TRANSFORMATION
  #WINDOW_SELECT_TRANSFORMATION_TILE
  #WINDOW_SELECT_MESSAGE_TILE
  #WINDOW_SELECT_MONSTER
EndEnumeration


;- images constants
Enumeration
  #IMAGE_SCROLLAREA
  #IMAGE_PORTAL_DESTINATION_SCROLLAREA
  #IMAGE_EMPTY_TILE
  #IMAGE_MONSTER
  #IMAGE_ITEMS
EndEnumeration


;- gadget enumeration
Enumeration
  #GADGET_SCROLLAREA
  #GADGET_SCROLLIMAGE
  #GADGET_PAINT_TILE1
  #GADGET_SELECT_TILE
  #GADGET_SELECT_BACKGROUND_TILE
  #GAGDET_BACKGROUND_TILE
  #GADGET_TEXT_PAINT_TILE
  #GADGET_TEXT_BACKGROUND_TILE
  #GADGET_TEXT_MAP_NAME
  #GADGET_STRING_MAP_NAME
  #GADGET_TEXT_FIELD_PARAMETER_XY
  #GADGET_TEXT_FIELD_PARAMETER_TILE_TYPE
  #GADGET_IMAGE_FIELD_PARAMETER_TILE
  #GADGET_TEXT_FIELD_PARAMETER_PORTAL_MAP_FILENAME
  #GADGET_STRING_FIELD_PARAMETER_PORTAL_MAP_FILENAME
  #GADGET_BUTTON_FIELD_PARAMETER_SELECT_PORTAL_MAP_FILENAME
  #GADGET_BUTTON_FIELD_PARAMETER_SELECT_PORTAL_DESTINATION
  #GADGET_TEXT_FIELD_PARAMETER_PORTAL_X
  #GADGET_TEXT_FIELD_PARAMETER_PORTAL_Y
  #GADGET_STRING_FIELD_PARAMETER_PORTAL_X
  #GADGET_STRING_FIELD_PARAMETER_PORTAL_Y
  #GADGET_TEXT_FIELD_PARAMETER_TRIGGER_EVENT
  #GADGET_STRING_FIELD_PARAMETER_TRIGGER_EVENT
  #GADGET_TEXT_FIELD_PARAMETER_TRANSFORMATIONS
  #GADGET_LISTVIEW_FIELD_PARAMETER_TRANSFORMATIONS
  #GADGET_BUTTON_FIELD_PARAMETER_ADD_TRANSFORMATION
  #GADGET_BUTTON_FIELD_PARAMETER_EDIT_TRANSFORMATION
  #GADGET_BUTTON_FIELD_PARAMETER_DELETE_TRANSFORMATION
  #GADGET_BUTTON_FIELD_PARAMETER_OK
  #GADGET_BUTTON_FIELD_PARAMETER_CANCEL
  #GADGET_TEXT_POSITION
  #GADGET_IMAGE_TILE_OUTSIDE
  #GADGET_TEXT_OUTSIDE
  #GADGET_IMAGE_SELECT_TILE_OUTSIDE
  #GADGET_TEXT_FIELD_PARAMETER_MESSAGE
  #GADGET_STRING_FIELD_PARAMETER_MESSAGE_LINE1
  #GADGET_STRING_FIELD_PARAMETER_MESSAGE_LINE2
  #GADGET_IMAGE_FIELD_PARAMETER_MESSAGE_TILE
  #GADGET_OPTION_MODUS_PAINT
  #GADGET_OPTION_MODUS_EDIT
  #GADGET_OPTION_MODUS_SET_MONSTER
  #GADGET_OPTION_MODUS_REMOVE_MONSTER
  #GADGET_TEXT_PLACE_REMOVE_MONSTER
  #GADGET_IMAGE_PLACE_MONSTER
  #GADGET_SCROLLAREA_PORTAL_MAP
  #GADGET_IMAGE_PORTAL_MAP
  #GADGET_BUTTON_NEW_MAP_OK
  #GADGET_BUTTON_NEW_MAP_CANCEL
  #GADGET_STRING_NEW_MAP_NAME
  #GADGET_TEXT_NEW_MAP_NAME
  #GADGET_TEXT_NEW_MAP_TILESET_DEFINITION
  #GADGET_STRING_NEW_MAP_TILESET_DEFINITION
  #GADGET_BUTTION_NEW_MAP_TILESET_DEFINITION
  #GADGET_TEXT_NEW_MAP_TILESET_IMAGE
  #GADGET_STRING_NEW_MAP_TILESET_IMAGE
  #GADGET_BUTTON_NEW_MAP_TILESET_IMAGE
  #GADGET_TEXT_ABOUT_LINE1
  #GADGET_TEXT_ABOUT_LINE2
  #GADGET_TEXT_ABOUT_LINE3
  #GADGET_TEXT_ABOUT_LINE4
  #GADGET_TEXT_ABOUT_LINE5
  #GADGET_BUTTON_ABOUT_OK
  #GADGET_IMAGE_TRANSFORMATION_TILE
  #GADGET_TEXT_TRANSFORMATION_EVENT
  #GADGET_COMBOBOX_TRANSFORMATION_EVENT
  #GADGET_TEXT_TRANSFORMATION_XY
  #GADGET_TEXT_TRANSFORMATION_TILE_TYPE
  #GADGET_TEXT_TANSFORMATION_PORTAL_MAP_FILENAME
  #GADGET_BUTTON_TRANSFORMATION_SELECT_PORTAL_MAP_FILENAME
  #GADGET_STRING_TRANSFORMATION_PORTAL_MAP_FILENAME
  #GADGET_TEXT_TRANSFORMATION_PORTAL_X
  #GADGET_STRING_TRANSFORMATION_PORTAL_X
  #GADGET_TEXT_TRANSFORMATION_PORTAL_Y
  #GADGET_STRING_TRANSFORMATION_PORTAL_Y
  #GADGET_BUTTON_TRANSFORMATION_SELECT_PORTAL_DESTINATION
  #GADGET_BUTTON_TRANSFORMATION_OK
  #GADGET_BUTTON_TRANSFORMATION_CANCEL
  #GADGET_TEXT_TRANSFORMATION_MESSAGE
  #GADGET_STRING_TRANSFORMATION_MESSAGE_LINE1
  #GADGET_STRING_TRANSFORMATION_MESSAGE_LINE2
  #GADGET_IMAGE_ADD_TRANSFORMATION_MESSAGE_TILE
  #GADGET_IMAGE_EDIT_TRANSFORMATION_MESSAGE_TILE
  #GADGET_IMAGE_SELECT_TRANSFORMATION_TILE
  #GADGET_BUTTON_TRANSFORMATION_EDIT_OK
  #GADGET_BUTTON_TRANSFORMATION_EDIT_CANCEL
  #GADGET_TEXT_TRANSFORMATION_EVENT2
  #GADGET_TEXT_TRANSFORMATION_NEW_EVENT
  #GADGET_STRING_TRANSFORMATION_NEW_EVENT
  #GADGET_IMAGE_SELECT_NEW_MESSAGE_TILE
  #GADGET_IMAGE_SELECT_NEW_MESSAGE_TILE_ADD_TRANSFORMATION
  #GADGET_IMAGE_SELECT_NEW_MESSAGE_TILE_EDIT_TRANSFORMATION
  #GADGET_IMAGE_SELECT_MONSTER
  #GADGET_CHECKBOX_FIELD_PARAMETER_EVENT_XP
  #GADGET_OPTION_MODUS_PLACE_ITEMS
EndEnumeration


; menu enumeration
Enumeration
  #MENU_MAIN
EndEnumeration


; menuitem enumeration
Enumeration
  #MENUITEM_NEW
  #MENUITEM_OPEN
  #MENUITEM_SAVE
  #MENUITEM_SAVE_AS
  #MENUITEM_QUIT
  #MENUITEM_FILL
  #MENUITEM_MONSTERDATA
  #MENUITEM_ITEMDATA
  #MENUITEM_POWERDATA
  #MENUITEM_ABOUT
EndEnumeration



; include external files
XIncludeFile "constants.pb"
XIncludeFile "error_handling.pb"
XIncludeFile "misc.pb"
XIncludeFile "preferences.pb"
XIncludeFile "map_handling.pb"
XIncludeFile "menu.pb"
XIncludeFile "graphics.pb"
XIncludeFile "character.pb"
XIncludeFile "monster.pb"
XIncludeFile "powers.pb"
XIncludeFile "items.pb"
XIncludeFile "sound.pb"
;- debug fuction
XIncludeFile "debug.pb"



;- globals
Global map_editor_version$ = "0.001a"
Global map_editor_preferences_file$ = "config\map_editor_preferences.xml" ; preferences xml file
Global paint_tile.w = 1                                                   ; tile ID of tile currently used for painting
Global background_tile.w = 4                                              ; tile ID of tile currently used for background
Global outside_tile.w = 0                                                 ; tile ID of tile currently displayed outside the map boundaryl
Global map_filename$ = ""                                                 ; filename of map file currently used
Global map_changed.b                                                      ; flag: 1=recent changes to map have not been saved
Global main_window_title$ = "Lost Labyrinth Portals Map Editor"           ; main window title
Global continue_painting.b                                                ; mouse held down, continue to paint; 1=left mouse button, 2=right mouse button
Global field_x.w, field_y.w                                               ; x/y map coordinates for field parameter
Global mouse_map_x.w, mouse_map_y.w                                       ; x/y map coordinates for mouse pointer
Global field_tile_type.w                                                  ; tile type of field currently edited
Global map_portal_destination.map_struct                                  ; map used to display portal destination
Global select_paint_tile_window_pos_x.w = -1                              ; x position of window to select paint tile
Global select_paint_tile_window_pos_y.w = -1                              ; y position of window to select paint tile
Global new_map_tileset_definition$ = "standard_tileset.xml"               ; filename of tileset definition file for new map
Global new_map_tileset_image$ = "standard_tileset.png"                    ; filename of tileset image file for new map
Global brush_rows.b                                                       ; number of rows in paint brush
Global brush_columns.b                                                    ; number of columns in paint brush
Global transformation_tile.w                                              ; tile ID of new field after transformation
Global message_tile.w=0                                                   ; tile ID of image displayed with message displayed when entering field
Global transformation_message_tile.w = 0                                  ; tile ID of image displayed with message in transformation
Global place_monster_tile.w                                               ; tile of currently selected monster
Global place_monster_type.w                                               ; type of currently selected monster

XIncludeFile "map_editor_procedures.pb"

; init graphics engine
UsePNGImageDecoder()
If InitSprite() = 0
  error_message("Can't open sprite enviroment!")
EndIf
If CreateImage(#IMAGE_EMPTY_TILE, 32, 32) = 0
  error_message("Cannot create empty tile image!")
EndIf
If CreateImage(#IMAGE_SCROLLAREA, #MAP_DIMENSION_X*32, #MAP_DIMENSION_Y*32) = 0
  error_message("Cannot create scrollarea image!")
EndIf
If CreateImage(#IMAGE_PORTAL_DESTINATION_SCROLLAREA, #MAP_DIMENSION_X*32, #MAP_DIMENSION_Y*32) = 0
  error_message("Cannot create portal destination scrollarea!")
EndIf


; initialize misc dbs
reset_preferences(@preferences)
load_abilities_db()
load_monster_db()
load_power_db()
load_item_db()
ability_db_resolve_names()
item_db_resolve_names()


open_main_window()
place_monster_type = 1
place_monster_tile = monster_type_db(1)\tile


; load preferences & map
If FileSize(map_editor_preferences_file$) > 0
  load_map_editor_preferences()
EndIf
If map_filename$ <> ""
  load_map(@current_map, "maps\" + GetFilePart(map_filename$), 0)
  background_tile = current_map\background_tile
  outside_tile = current_map\tile_outside_map
Else
  load_map(@current_map, "maps\map_start.xml", 0)
  map_filename$ = "map_start.xml"
EndIf
load_tile_type_definition(@current_map\tileset)
load_tileset(@current_map\tileset, 0, 1)
create_images_from_tileset(@current_map\tileset, 100)
create_images_from_monster(500)
SetGadgetText(#GADGET_STRING_MAP_NAME, current_map\name)
SetWindowTitle(#WINDOW_MAIN, main_window_title$ + " - " + GetFilePart(map_filename$))


; update gadgets
update_scrollarea()
SetGadgetState(#GADGET_SCROLLIMAGE, ImageID(#IMAGE_SCROLLAREA))
SetGadgetState(#GADGET_PAINT_TILE1,ImageID(100+paint_tile))
SetGadgetState(#GAGDET_BACKGROUND_TILE,ImageID(100 + background_tile))
SetGadgetState(#GADGET_IMAGE_TILE_OUTSIDE,ImageID(100 + outside_tile))


; main loop
end_loop.b = 0
continue_painting.b = 0
lock_painting.b = 0
Repeat
  event = WindowEvent()
  eventtype = EventType()
  window = EventWindow()
  gadget = EventGadget()
  menu_g = EventMenu()
  
  ; main window: quit
  If (event = #PB_Event_CloseWindow And window = #WINDOW_MAIN) Or (event = #PB_Event_Menu And menu_g = #MENUITEM_QUIT)
    If map_changed = 1
      Select MessageRequester("Lost Labyrinth Portals Map Editor", "Do you want to save the changes to your map?", #PB_MessageRequester_YesNoCancel)
        Case #PB_MessageRequester_Yes:
          If map_filename$ = ""
            map_filename$ = SaveFileRequester("Choose map xml file to open", "map.xml", "XML File (*.xml)|*.xml|all files (*.*)|*.*", 0)
          EndIf
          If map_filename$ <> ""
            save_map(@current_map, map_filename$)
            SetWindowTitle(#WINDOW_MAIN, main_window_title$ + " - " + GetFilePart(map_filename$))
            map_changed = 0
            end_loop = 1
          EndIf
        Case #PB_MessageRequester_No:
          end_loop = 1
      EndSelect
    Else
      end_loop = 1
    EndIf
  EndIf
  
  ; main window: edit field parameter window
  If event = #PB_Event_Gadget And gadget = #GADGET_SCROLLIMAGE And GetGadgetState(#GADGET_OPTION_MODUS_EDIT) = 1
    open_window_field_parameter()
  EndIf
  
  ; field parameter window: select file for portal mapfile
  If event = #PB_Event_Gadget And gadget = #GADGET_BUTTON_FIELD_PARAMETER_SELECT_PORTAL_MAP_FILENAME
    portal_mapfile$ = OpenFileRequester("Select map file for portal", GetGadgetText(#GADGET_STRING_FIELD_PARAMETER_PORTAL_MAP_FILENAME), "XML File (*.xml)|*.xml|all files (*.*)|*.*", 0)
    SetGadgetText(#GADGET_STRING_FIELD_PARAMETER_PORTAL_MAP_FILENAME, GetFilePart(portal_mapfile$))
  EndIf
  
  ; field parameter window: open map to select portal destination
  If event = #PB_Event_Gadget And gadget = #GADGET_BUTTON_FIELD_PARAMETER_SELECT_PORTAL_DESTINATION
    open_portal_destination_window()
  EndIf
  
  ; field parameter window: save field parameter
  If event = #PB_Event_Gadget And gadget = #GADGET_BUTTON_FIELD_PARAMETER_OK
    save_field_parameter()
  EndIf
  
  ; select paint tile window: close
  If event = #PB_Event_CloseWindow And window = #WINDOW_SELECT_PAINT_TILE
    CloseWindow(#WINDOW_SELECT_PAINT_TILE)
    DisableWindow(#WINDOW_MAIN, 0)
    SetActiveWindow(#WINDOW_MAIN)    
  EndIf
  
  ; select background tile window: close
  If event = #PB_Event_CloseWindow And window = #WINDOW_SELECT_BACKGROUND_TILE
    CloseWindow(#WINDOW_SELECT_BACKGROUND_TILE)
    DisableWindow(#WINDOW_MAIN, 0)
    SetActiveWindow(#WINDOW_MAIN)    
  EndIf
  
  ; select outside tile window: close
  If event = #PB_Event_CloseWindow And window = #WINDOW_SELECT_OUTSIDE_TILE
    CloseWindow(#WINDOW_SELECT_OUTSIDE_TILE)
    DisableWindow(#WINDOW_MAIN, 0)
    SetActiveWindow(#WINDOW_MAIN)    
  EndIf
  
  ; field parameter window: close
  If event = #PB_Event_CloseWindow And window = #WINDOW_FIELD_PARAMETER
    CloseWindow(#WINDOW_FIELD_PARAMETER)
    DisableWindow(#WINDOW_MAIN, 0)
    SetActiveWindow(#WINDOW_MAIN)
  EndIf
  
  ; select monster window: close
  If event = #PB_Event_CloseWindow And window = #WINDOW_SELECT_MONSTER
    CloseWindow(#WINDOW_SELECT_MONSTER)
    DisableWindow(#WINDOW_MAIN, 0)
    SetActiveWindow(#WINDOW_MAIN)
  EndIf  
  
  ; field parameter window: cancel button
  If event = #PB_Event_Gadget And gadget = #GADGET_BUTTON_FIELD_PARAMETER_CANCEL
    CloseWindow(#WINDOW_FIELD_PARAMETER)
    DisableWindow(#WINDOW_MAIN, 0)
    SetActiveWindow(#WINDOW_MAIN)  
  EndIf
  
  ; select portal target window: close
  If event = #PB_Event_CloseWindow And window = #WINDOW_PORTAL_MAP
    CloseWindow(#WINDOW_PORTAL_MAP)
    DisableWindow(#WINDOW_FIELD_PARAMETER, 0)
    SetActiveWindow(#WINDOW_FIELD_PARAMETER)
  EndIf
  
  ; main window: paint with paint tile (left mouse button)
  If GetGadgetState(#GADGET_OPTION_MODUS_PAINT) = 1
    If (event = #PB_Event_Gadget And gadget = #GADGET_SCROLLIMAGE And eventtype = #PB_EventType_LeftClick) Or continue_painting=1
      paint_with_tile(paint_tile)
      continue_painting = 1
    EndIf
  EndIf
  
  ; main window: paint with background tile (right mouse button)
  If GetGadgetState(#GADGET_OPTION_MODUS_PAINT) = 1
    If event = #PB_Event_Gadget And gadget = #GADGET_SCROLLIMAGE And eventtype = #PB_EventType_RightClick 
      paint_with_tile(background_tile)
    EndIf
  EndIf
  
  ; main window: place new monster
  If GetGadgetState(#GADGET_OPTION_MODUS_SET_MONSTER) = 1
    If event = #PB_Event_Gadget And gadget = #GADGET_SCROLLIMAGE And eventtype = #PB_EventType_LeftClick
      place_monster_in_mapeditor()
    EndIf
  EndIf
  
  ; main window: remove monster
  If GetGadgetState(#GADGET_OPTION_MODUS_REMOVE_MONSTER) = 1
    If event = #PB_Event_Gadget And gadget = #GADGET_SCROLLIMAGE And eventtype = #PB_EventType_LeftClick
      remove_monster_in_mapeditor()
    EndIf    
  EndIf
  
  ; main window: open window to select new paint tile 
  If event = #PB_Event_Gadget And gadget = #GADGET_PAINT_TILE1
    open_window_select_paint_tile()
  EndIf
  
  ; main window: open window to select new background tile
  If event = #PB_Event_Gadget And gadget = #GAGDET_BACKGROUND_TILE
    open_window_select_background_tile()
  EndIf
  
  ; main window: open window to select new outside tile
  If event = #PB_Event_Gadget And gadget = #GADGET_IMAGE_TILE_OUTSIDE
    open_window_select_outside_tile()
  EndIf
  
  ; transformation window: open window to select transformation tile
  If event = #PB_Event_Gadget And gadget = #GADGET_IMAGE_TRANSFORMATION_TILE
    open_window_select_transformation_tile()
  EndIf
  
  ; add transformation window: open window to select new message tile
  If event = #PB_Event_Gadget And gadget = #GADGET_IMAGE_ADD_TRANSFORMATION_MESSAGE_TILE
    open_window_select_message_tile_add_transformation()
  EndIf
  
  ; edit transformation window: open window to select new message tile
  If event = #PB_Event_Gadget And gadget = #GADGET_IMAGE_EDIT_TRANSFORMATION_MESSAGE_TILE
    open_window_select_message_tile_edit_transformation()
  EndIf
  
  ; select paint tile window: select new paint tile
  If event = #PB_Event_Gadget And gadget = #GADGET_SELECT_TILE
    select_paint_tile()
  EndIf
  
  ; select background tile window: select new background tile
  If event = #PB_Event_Gadget And gadget = #GADGET_SELECT_BACKGROUND_TILE
    select_background_tile()
  EndIf
  
  ; select outside tile window: select new outside tile
  If event = #PB_Event_Gadget And gadget = #GADGET_IMAGE_SELECT_TILE_OUTSIDE
    select_outside_tile()
  EndIf
  
  ; select transformation tile window: select new transformation tile
  If event = #PB_Event_Gadget And gadget = #GADGET_IMAGE_SELECT_TRANSFORMATION_TILE
    select_transformation_tile()
  EndIf
  
  ; select message tile window: select new message tile
  If event = #PB_Event_Gadget And gadget = #GADGET_IMAGE_SELECT_NEW_MESSAGE_TILE
    select_message_tile()
  EndIf
  
  ; select message tile for new transformation window: select new message tile
  If event = #PB_Event_Gadget And gadget = #GADGET_IMAGE_SELECT_NEW_MESSAGE_TILE_ADD_TRANSFORMATION
    select_message_tile_add_transformation()
  EndIf
  
  ; select message tile for edit transformation window: select new message tile
  If event = #PB_Event_Gadget And gadget = #GADGET_IMAGE_SELECT_NEW_MESSAGE_TILE_EDIT_TRANSFORMATION
    select_message_tile_edit_transformation()
  EndIf
  
  ; select monster window: select monster
  If event = #PB_Event_Gadget And gadget = #GADGET_IMAGE_SELECT_MONSTER
    select_monster_in_mapeditor()
  EndIf
  
  ; select monster
  If event = #PB_Event_Gadget And gadget = #GADGET_IMAGE_PLACE_MONSTER
    open_window_select_monster()
  EndIf
  
  ; field parameter window: open window to select new message tile image
  If event = #PB_Event_Gadget And gadget = #GADGET_IMAGE_FIELD_PARAMETER_MESSAGE_TILE
    open_window_select_message_tile()
  EndIf
  
  ; select portal destination window: select portal destination
  If event = #PB_Event_Gadget And gadget = #GADGET_IMAGE_PORTAL_MAP And eventtype = #PB_EventType_LeftClick
    select_portal_destination()
  EndIf
  
  ; new map window: ok button
  If event = #PB_Event_Gadget And gadget = #GADGET_BUTTON_NEW_MAP_OK
    create_new_map_in_mapeditor()
  EndIf
  
  ; new map window: cancel button
  If event = #PB_Event_Gadget And gadget = #GADGET_BUTTON_NEW_MAP_CANCEL
    CloseWindow(#WINDOW_CREATE_NEW_MAP)
    DisableWindow(#WINDOW_MAIN, 0)
    SetActiveWindow(#WINDOW_MAIN)  
  EndIf
  
  ; new map window: select tileset definition file button
  If event = #PB_Event_Gadget And gadget = #GADGET_BUTTION_NEW_MAP_TILESET_DEFINITION
    new_map_tileset_definition$ = OpenFileRequester("Select tileset definition xml file", "tilesets\tiles_standard.xml", "XML Files (*.xml)|*.xml|all files (*.*)|*.*", 0)
    SetGadgetText(#GADGET_STRING_NEW_MAP_TILESET_DEFINITION, GetFilePart(new_map_tileset_definition$))
  EndIf
  
  ; new map window: select tileset image file button
  If event = #PB_Event_Gadget And gadget = #GADGET_BUTTON_NEW_MAP_TILESET_IMAGE
    new_map_tileset_image$ = OpenFileRequester("Select tileset image file", "tilesets\tiles_standard.png", "PNG images (*.png)|*.png|all files (*.*)|*.*", 0)
    SetGadgetText(#GADGET_STRING_NEW_MAP_TILESET_IMAGE, GetFilePart(new_map_tileset_image$))
  EndIf
  
  ; main window menu: load map
  If event = #PB_Event_Menu And menu_g = #MENUITEM_OPEN
    open_map_in_mapeditor()
  EndIf
  
  ; main window menu: save map
  If event = #PB_Event_Menu And menu_g = #MENUITEM_SAVE
    If map_filename$ = ""
      map_filename$ = SaveFileRequester("Choose map xml file to open", "map.xml", "XML File (*.xml)|*.xml|all files (*.*)|*.*", 0)
    EndIf
    If map_filename$ <> ""
      save_map(@current_map, map_filename$)
      MessageRequester("Lost Labyrinth Portals Map Editor", "Your map has been saved.")
      SetWindowTitle(#WINDOW_MAIN, main_window_title$ + " - " + GetFilePart(map_filename$))
      map_changed = 0
    EndIf
  EndIf
  
  ; main window menu: save map as
  If event = #PB_Event_Menu And menu_g = #MENUITEM_SAVE_AS
    new_map_filename$ = SaveFileRequester("Save map as", "map.xml", "XML File (*.xml)|*.xml|all files (*.*)|*.*", 0)
    If new_map_filename$ <> ""
      map_filename$ = new_map_filename$
      save_map(@current_map, map_filename$)
      MessageRequester("Lost Labyrinth Portals Map Editor", "Your map has been saved.")
      SetWindowTitle(#WINDOW_MAIN, main_window_title$ + " - " + GetFilePart(map_filename$))
      map_changed = 0
    EndIf
  EndIf
  
  ; main window menu: create new map
  If event = #PB_Event_Menu And menu_g = #MENUITEM_NEW
    open_new_map_window()
  EndIf
  
  ; main window menu: about
  If event = #PB_Event_Menu And menu_g = #MENUITEM_ABOUT
    open_window_about()
  EndIf
  
  ; main window menu: fill
  If event = #PB_Event_Menu And menu_g = #MENUITEM_FILL
    If MessageRequester("Lost Labyrinth Portals Map Editor", "Do you really want to fill the complete map with the paint tile?", #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
      fill_map(@current_map, paint_tile)
      update_scrollarea()
      SetGadgetState(#GADGET_SCROLLIMAGE, ImageID(#IMAGE_SCROLLAREA))
      map_changed = 1
    EndIf
  EndIf
  
  ; main window: view monster data
  If event = #PB_Event_Menu And menu_g = #MENUITEM_MONSTERDATA
    editor_view_monster_data()
  EndIf
  
  ; main window: view item data
  If event = #PB_Event_Menu And menu_g = #MENUITEM_ITEMDATA
    editor_view_item_data()
  EndIf
  
  ; main window: view powers data
  If event = #PB_Event_Menu And menu_g = #MENUITEM_POWERDATA
    editor_view_powers_data()
  EndIf  
  
  ; about window: ok button
  If event = #PB_Event_Gadget And gadget = #GADGET_BUTTON_ABOUT_OK
    CloseWindow(#WINDOW_ABOUT)
  EndIf
  
  ; release mouse button
  If event = #WM_LBUTTONUP 
    continue_painting = 0
  EndIf
  
  ; main window: map name has been changed
  If event = #PB_Event_Gadget And gadget = #GADGET_STRING_MAP_NAME And eventtype = #PB_EventType_Change
    current_map\name = GetGadgetText(#GADGET_STRING_MAP_NAME)
    map_changed = 1
  EndIf
  
  ; field parameter window: add transformation
  If event = #PB_Event_Gadget And gadget = #GADGET_BUTTON_FIELD_PARAMETER_ADD_TRANSFORMATION
    open_window_add_transformation()
  EndIf
  
  ; transformation window: ok button
  If event = #PB_Event_Gadget And gadget = #GADGET_BUTTON_TRANSFORMATION_OK
    add_transformation_from_editor()
  EndIf
  
  ; add transformation window: close window
  If event = #PB_Event_CloseWindow And window = #WINDOW_TRANSFORMATION
    CloseWindow(#WINDOW_TRANSFORMATION)
    DisableWindow(#WINDOW_FIELD_PARAMETER, 0)
    SetActiveWindow(#WINDOW_FIELD_PARAMETER)
  EndIf
  
  ; add transformation window: cancel button
  If event = #PB_Event_Gadget And gadget = #GADGET_BUTTON_TRANSFORMATION_CANCEL
    CloseWindow(#WINDOW_TRANSFORMATION)
    DisableWindow(#WINDOW_FIELD_PARAMETER, 0)
    SetActiveWindow(#WINDOW_FIELD_PARAMETER)  
  EndIf
  
  ; edit transformation window: ok button
  If event = #PB_Event_Gadget And gadget = #GADGET_BUTTON_TRANSFORMATION_EDIT_OK
    edit_transformation_from_editor()
  EndIf
  
  ; edit transformation window: cancel button
  If event = #PB_Event_Gadget And gadget = #GADGET_BUTTON_TRANSFORMATION_EDIT_CANCEL
    CloseWindow(#WINDOW_TRANSFORMATION)
    DisableWindow(#WINDOW_FIELD_PARAMETER, 0)
    SetActiveWindow(#WINDOW_FIELD_PARAMETER)
  EndIf
  
  ; field parameter window: select transformation
  If event = #PB_Event_Gadget And gadget = #GADGET_LISTVIEW_FIELD_PARAMETER_TRANSFORMATIONS
    DisableGadget(#GADGET_BUTTON_FIELD_PARAMETER_EDIT_TRANSFORMATION, 0)
    DisableGadget(#GADGET_BUTTON_FIELD_PARAMETER_DELETE_TRANSFORMATION, 0)    
  EndIf
  
  ; field parameter window: edit transformation
  If event = #PB_Event_Gadget And gadget = #GADGET_BUTTON_FIELD_PARAMETER_EDIT_TRANSFORMATION
    open_window_edit_transformation()
  EndIf
  
  
  ; field parameter window: delete transformation
  If event = #PB_Event_Gadget And gadget = #GADGET_BUTTON_FIELD_PARAMETER_DELETE_TRANSFORMATION
    If MessageRequester("Lost Labyrinth Portals Map Editor", "Do you really want to delete this transformation?", #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
      ForEach map_transformation()
        If map_transformation()\x = field_x And map_transformation()\y = field_y And map_transformation()\event$ = GetGadgetText(#GADGET_LISTVIEW_FIELD_PARAMETER_TRANSFORMATIONS)
          DeleteElement(map_transformation())
        EndIf
      Next
      update_listview_of_transformations()
    EndIf
  EndIf
  
  ; main window: change paint modus
  If event = #PB_Event_Gadget And gadget = #GADGET_OPTION_MODUS_SET_MONSTER
    update_scrollarea()
    SetGadgetState(#GADGET_SCROLLIMAGE, ImageID(#IMAGE_SCROLLAREA))
  EndIf
  If event = #PB_Event_Gadget And gadget = #GADGET_OPTION_MODUS_REMOVE_MONSTER
    update_scrollarea()
    SetGadgetState(#GADGET_SCROLLIMAGE, ImageID(#IMAGE_SCROLLAREA))
  EndIf  
  If event = #PB_Event_Gadget And gadget = #GADGET_OPTION_MODUS_PAINT
    update_scrollarea()
    SetGadgetState(#GADGET_SCROLLIMAGE, ImageID(#IMAGE_SCROLLAREA))
  EndIf
  If event = #PB_Event_Gadget And gadget = #GADGET_OPTION_MODUS_EDIT
    update_scrollarea()
    SetGadgetState(#GADGET_SCROLLIMAGE, ImageID(#IMAGE_SCROLLAREA))
  EndIf
  
  ; main window: show coordinates of mouse pointer
  x = WindowMouseX(#WINDOW_MAIN) - GadgetX(#GADGET_SCROLLAREA) - GadgetX(#GADGET_SCROLLIMAGE)
  y = WindowMouseY(#WINDOW_MAIN) - GadgetY(#GADGET_SCROLLAREA) - GadgetY(#GADGET_SCROLLIMAGE)
  If x>=0 And x<416 And y>=0 And y<=416
    x = Int((WindowMouseX(#WINDOW_MAIN) - GadgetX(#GADGET_SCROLLAREA) - GadgetX(#GADGET_SCROLLIMAGE) + GetGadgetAttribute(#GADGET_SCROLLAREA,#PB_ScrollArea_X)) / 32)
    y = Int((WindowMouseY(#WINDOW_MAIN) - GadgetY(#GADGET_SCROLLAREA) - GadgetY(#GADGET_SCROLLIMAGE) + GetGadgetAttribute(#GADGET_SCROLLAREA,#PB_ScrollArea_Y)) / 32)
    If mouse_map_x <> x Or mouse_map_y <> y
      mouse_map_x = x
      mouse_map_y = y
      SetGadgetText(#GADGET_TEXT_POSITION, "Position: " + Str(x) + " / " + Str(y))
    EndIf
  EndIf
  
Until end_loop = 1
save_map_editor_preferences()
; IDE Options = PureBasic 6.10 LTS beta 9 (Windows - x64)
; CursorPosition = 170
; FirstLine = 153
; Executable = map_editor.exe
; CompileSourceDirectory
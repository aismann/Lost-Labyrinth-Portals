; Lost Labyrinth VI: Portals
; handling of preferences
; written in PureBasic 4.20 (http://www.purebasic.com)
; created:  12.10.2008 Frank Malota <malota@web.de>
; modified: 07.01.2009 Frank Malota <malota@web.de>



; resets key bindings to default
Procedure reset_key_bindings()
  key_binding(#ACTION_TEST)\name$ = "test"
  key_binding(#ACTION_TEST)\keycode = #PB_Key_T
  key_binding(#ACTION_ESCAPE)\name$ = "escape"
  key_binding(#ACTION_ESCAPE)\keycode = #PB_Key_Escape
  key_binding(#ACTION_UP)\name$ = "move up"
  key_binding(#ACTION_UP)\keycode = #PB_Key_Up
  key_binding(#ACTION_DOWN)\name$ = "move down"
  key_binding(#ACTION_DOWN)\keycode = #PB_Key_Down
  key_binding(#ACTION_LEFT)\name$ = "move left"
  key_binding(#ACTION_LEFT)\keycode = #PB_Key_Left
  key_binding(#ACTION_RIGHT)\name$ = "move right"
  key_binding(#ACTION_RIGHT)\keycode = #PB_Key_Right   
EndProcedure



; resets preferences to default values
Procedure reset_preferences(*preferences.preferences_struct)
  With *preferences
    \fullscreen = 0
    \message_delay = 0
    \DDD_effects = 0
    \fade_effect = 1
    \language$ = "English"
  EndWith
EndProcedure


; loads preferences xml file into preferences
Procedure load_preferences(*preferences.preferences_struct, filename$="config\preferences.xml")
  Protected val$, text$, action.w, keycode.l, *mainnode
  reset_preferences(*preferences)
  reset_key_bindings()
  If CreateXML(0) = 0
    error_message("load_preferences(): could not create xml structure in memory!")
  EndIf
  If LoadXML(0, filename$) = 0
    error_message("load_preferences(): could not open preferences xml file: " + Chr(34) + filename$ + Chr(34))
  EndIf
  If XMLStatus(0) <> 0
    error_message("load_preferences(): error in xml structure of map file: " + XMLError(0))
  EndIf
  *mainnode = MainXMLNode(0)
  If *mainnode
    If ExamineXMLAttributes(*mainnode)
      While NextXMLAttribute(*mainnode)
        val$ = XMLAttributeValue(*mainnode)
        Select XMLAttributeName(*mainnode)
        
          Case "Lost_Labyrinth_version":
          
          Case "fullscreen":
            If val$ = "yes"
              *preferences\fullscreen = 1
            EndIf
            
          Case "message_delay":
            *preferences\message_delay = Val(val$)
            
          Case "DDD_effects":
            If val$ = "yes"
              *preferences\DDD_effects = 1
            EndIf
            
          Case "fade_effect":
            If val$ = "yes"
              *preferences\fade_effect = 1
            EndIf
            
            
          Case "language":
            *preferences\language$ = val$
            
          Default:
            error_message("load_preferences(): unknown attribute " + Chr(34) + XMLAttributeName(*mainnode) + Chr(34) + " in preferences xml file " + Chr(34) + filename$ + Chr(34))
            
        EndSelect
      Wend
    EndIf
  EndIf
  FreeXML(0)
EndProcedure


; save preferences into xml file
Procedure save_preferences(*preferences.preferences_struct, filename$="config\preferences.xml")
  Protected *root_node
  If CreateXML(0) = 0
    error_message("load_preferences: could not create xml structure in memory!")
  EndIf
  *root_node = CreateXMLNode(RootXMLNode(0),"")
  SetXMLNodeName(*root_node, "Lost_Labyrinth_Preferences")
  SetXMLAttribute(*root_node, "Lost_Labyrinth_version", version_number$)
  If *preferences\fullscreen = 1
    SetXMLAttribute(*root_node, "fullscreen", "yes")
  Else
    SetXMLAttribute(*root_node, "fullscreen", "no")
  EndIf
  SetXMLAttribute(*root_node, "message_delay", Str(*preferences\message_delay))
  If *preferences\DDD_effects = 1
    SetXMLAttribute(*root_node, "DDD_effects", "yes")
  Else
    SetXMLAttribute(*root_node, "DDD_effects", "no")
  EndIf
  If *preferences\fade_effect = 1
    SetXMLAttribute(*root_node, "fade_effect", "yes")
  Else
    SetXMLAttribute(*root_node, "fade_effect", "no")
  EndIf
  SetXMLAttribute(*root_node, "language", *preferences\language$)
  If SaveXML(0, filename$) = 0
    error_message("save_preferences: could not save data into preferences xml file: " + Chr(34) + filename$ + Chr(34))
  EndIf
  FreeXML(0)
EndProcedure


; loads key bindings
Procedure load_key_bindings()
  Protected filename$ = "config\keys.xml", text$, val$, *mainnode, *node
  If CreateXML(0) = 0
    error_message("load_key_bindings(): could not create xml structure in memory!")
  EndIf
  If FileSize("config\keys.xml") < 1
    error_message("load_key_bindings(): could not find key definition xml file " + Chr(34) + filename$ + Chr(34))
  EndIf
  If LoadXML(0, filename$) = 0
    error_message("load_key_bindings(): could not open key definition xml file " + Chr(34) + filename$ +Chr(34))
  EndIf
  If XMLStatus(0) <> 0
    error_message("load_key_bindings(): error in xml structure of key definition xml file " + Chr(34) + filename$ + Chr(34) + ": " + XMLError(0))  
  EndIf
  *mainnode = MainXMLNode(0)
  If *mainnode
    *node = ChildXMLNode(*mainnode)
    While *node <> 0
      text$ = GetXMLNodeText(*node)
      Select GetXMLNodeName(*node)
      
        Case "move_up":
          
      EndSelect
    Wend  
  EndIf  
  FreeXML(0)
EndProcedure
; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 100
; FirstLine = 96
; Folding = -
; EnableXP
; CompileSourceDirectory
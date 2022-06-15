; Lost Labyrinth VI: Portals
; miscellaneous procedures
; written in PureBasic 4.20 (http://www.purebasic.com)
; created:  12.12.2008 Frank Malota <malota@web.de>
; modified: 21.12.2008 Frank Malota <malota@web.de>


; returns smaller value
Procedure.l min(val1.l, val2.l)
  Protected rc.w
  rc = val1
  If val2 < val1
    rc = val2
  EndIf
  ProcedureReturn rc
EndProcedure


; returns greater value
Procedure.l max(val1.l, val2.l)
  Protected rc.w
  rc = val1
  If val2 > val1
    rc = val2
  EndIf
  ProcedureReturn rc
EndProcedure


; compares two string lists and returns 1 if they contain at least one match
Procedure.b compare_string_lists(string1$, string2$, separator$ = "|")
  Protected rc.b = 0, pos.w = 0, part$, rest$
  Protected NewList list1$()
  Protected NewList list2$()
  rest$ = string1$
  pos = FindString(rest$, separator$, 1)
  While pos > 0
    AddElement(list1$())
    list1$() = Left(rest$, pos - 1)
    rest$ = Mid(rest$, pos + 1)
    pos = FindString(rest$, separator$, 1)
  Wend
  If rest$ <> ""
    AddElement(list1$())
    list1$() = rest$
  EndIf
  rest$ = string2$
  pos = FindString(rest$, separator$, 1)
  While pos > 0
    AddElement(list2$())
    list2$() = Left(rest$, pos - 1)
    rest$ = Mid(rest$, pos + 1)
    pos = FindString(rest$, separator$, 1)
  Wend
  If rest$ <> ""
    AddElement(list2$())
    list2$() = rest$
  EndIf  
  ResetList(list1$())
  While NextElement(list1$()) And rc = 0
    ResetList(list2$())
    While NextElement(list2$()) And rc = 0
      If LCase(list1$()) = LCase(list2$())
        rc = 1
      EndIf
    Wend
  Wend
  ProcedureReturn rc
EndProcedure


; adds a string to a string list if it is not already included; returns new string list
Procedure.s add_string_list(string_list$, new_string$, separator$ = "|")
  If compare_string_lists(string_list$, new_string$, separator$) = 0
    If string_list$ <> ""
      string_list$ = string_list$ + separator$
    EndIf
    string_list$ = string_list$ + new_string$
  EndIf
  ProcedureReturn string_list$
EndProcedure
; IDE Options = PureBasic 4.20 (Windows - x86)
; CursorPosition = 62
; FirstLine = 39
; Folding = -
; EnableXP
; CompileSourceDirectory
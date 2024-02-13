; Lost Labyrinth VI: Portals
; error handling
; written in PureBasic 4.20 (http://www.purebasic.com)
; created:  08.10.2008 Frank Malota <malota@web.de>
; modified: 17.10.2008 Frank Malota <malota@web.de>


; include constants & variables
XIncludeFile "constants.pb"


Procedure error_message(msg$ = "Undefined error!")
  MessageRequester("Error", msg$, #PB_MessageRequester_Ok | #PB_MessageRequester_Error)
  End
EndProcedure

Procedure info_message(msg$ = "Info...")
  MessageRequester("Info", msg$, #PB_MessageRequester_Ok | #PB_MessageRequester_Info)
EndProcedure
; IDE Options = PureBasic 6.10 beta 6 (Windows - x64)
; CursorPosition = 16
; Folding = -
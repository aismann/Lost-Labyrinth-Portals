; Lost Labyrinth VI: Portals
; error handling
; written in PureBasic 4.20 (http://www.purebasic.com)
; created:  08.10.2008 Frank Malota <malota@web.de>
; modified: 17.10.2008 Frank Malota <malota@web.de>


; include constants & variables
XIncludeFile "constants.pb"


Procedure error_message(msg$ = "Undefined error!")
  MessageRequester("Error", msg$, 0)
  End
EndProcedure
; IDE Options = PureBasic 4.20 (Windows - x86)
; CursorPosition = 4
; Folding = -
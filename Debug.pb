;-
Procedure draw_debug_infos_4_Developers() 
  ;- 
  If LabyDebugFlag = 0: ProcedureReturn: EndIf
  
  StartDrawing(ScreenOutput())
  DrawText(16 + 2, 16, "PlayerPos (" + Str(current_character\xpos) + ", " + Str(current_character\ypos) + ")", RGB(255, 100, 0), RGB(0, 0, 0))
  StopDrawing()
EndProcedure
; IDE Options = PureBasic 6.10 LTS beta 9 (Windows - x64)
; CursorPosition = 6
; Folding = -
; EnableXP
; DPIAware
; Lost Labyrinth VI: Portals
; resource packer
; written in PureBasic 4.20 (http://www.purebasic.com)
; created:  08.10.2008 Frank Malota <malota@web.de>
; modified: 08.10.2008 Frank Malota <malota@web.de>


; define variables & constants
pak_filename$ = "resources.pak"

; open pack file for writing
If CreatePack("resources.pak") = 0
  MessageRequester("Error", "Can't open PAK file " + pak_filename$, 0)
  End
EndIf


; add files to pack
AddPackFile("resources\tiles.png", 9)
AddPackFile("resources\chara4.png", 9)
AddPackFile("resources\rahmen.png", 9)


; close pack file
ClosePack()
; IDE Options = PureBasic 4.20 (Windows - x86)
; EnableXP
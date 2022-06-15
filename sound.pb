; Lost Labyrinth VI: Portals
; sound procedures
; written in PureBasic 4.20 (http://www.purebasic.com)
; created:  30.10.2008 Frank Malota <malota@web.de>
; modified: 31.10.2008 Frank Malota <malota@web.de>


XIncludeFile "constants.pb"


; load all OGG sounds in "sound" directory
Procedure load_sound()
  Protected i.w
  i = 1
  If ExamineDirectory(0, "sound\", "*.ogg")
    While NextDirectoryEntry(0)
      If DirectoryEntryType(0) = #PB_DirectoryEntry_File And i < #MAX_NUMBER_OF_SOUNDS
        sound(i)\sound = LoadSound(#PB_Any, "sound\" + DirectoryEntryName(0))
        SoundVolume(sound(i)\sound, 50)
        sound(i)\filename$ = RemoveString(GetFilePart(DirectoryEntryName(0)), ".ogg", #PB_String_NoCase)
        i = i + 1
      EndIf
    Wend
    FinishDirectory(0)
  EndIf
EndProcedure



; plays sound
Procedure play_sound(sound_filename$)
  Protected i.w
  
  If isSoundSupported = #False; InitSound was failed?
    ProcedureReturn  
  EndIf
  For i=1 To #MAX_NUMBER_OF_SOUNDS-1
    If sound(i)\filename$ = sound_filename$ And sound_filename$ <> ""
      PlaySound(sound(i)\sound)
    EndIf
  Next
EndProcedure
; IDE Options = PureBasic 6.00 Beta 10 (Windows - x86)
; CursorPosition = 33
; Folding = --
; EnableXP
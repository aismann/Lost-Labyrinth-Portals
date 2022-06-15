; Lost Labyrinth VI: Portals
; messages
; written in PureBasic 4.20 (http://www.purebasic.com)
; created:  28.11.2008 Frank Malota <malota@web.de>
; modified: 21.12.2008 Frank Malota <malota@web.de>



; resets message list
Procedure reset_message_list()
  Protected i.w = 0
  For i=1 To #MAX_NUMBER_OF_MESSAGES - 1
    message_list$(i) = "??? missing message ID " + Str(i) + " ???"
  Next
EndProcedure


; load message list
Procedure load_message_list(filename$="data\messages.xml")
  Protected val$, text$, id.w = 0, language$, *mainnode, *node, *childnode, val2$
  reset_message_list()
  If CreateXML(0) = 0
    error_message("load_message_list(): could not create xml structure in memory!")
  EndIf
  If LoadXML(0, filename$) = 0
    error_message("load_message_list(): could not open message xml file: " + Chr(34) + filename$ + Chr(34))
  EndIf
  If XMLStatus(0) <> 0
    error_message("load_message_list(): error in xml structure of message file: " + XMLError(0))
  EndIf
  *mainnode = MainXMLNode(0)
  If *mainnode
    If ExamineXMLAttributes(*mainnode)
      While NextXMLAttribute(*mainnode)
        val$ = XMLAttributeValue(*mainnode)
        Select XMLAttributeName(*mainnode)
        
          Case "Lost_Labyrinth_version":
            
          Default:
            error_message("load_message_list(): unknown attribute " + Chr(34) + XMLAttributeName(*mainnode) + Chr(34) + " in messages xml file " + Chr(34) + filename$ + Chr(34))
            
        EndSelect
      Wend
    EndIf
    *node = ChildXMLNode(*mainnode)
    While *node <> 0
      Select GetXMLNodeName(*node)
      
        Case "message":
          id = 0
          If ExamineXMLAttributes(*node)
            While NextXMLAttribute(*node)
              val$ = XMLAttributeValue(*node)
              Select XMLAttributeName(*node)
                  
                Case "id":
                  id = Val(val$)
                  
                Default:
                  error_message("load_message_list(): unknown attribute " + Chr(34) + XMLAttributeName(*node) + Chr(34) + " in message tag in messages xml file " + Chr(34) + filename$ + Chr(34))

              EndSelect
            Wend
            If id < 1 Or id > #MAX_NUMBER_OF_MESSAGES - 1
              error_message("load_message_list(): wrong id " + Chr(34) + Str(id) + Chr(34) + " in message tag in messages xml file " + Chr(34) + filename$ + Chr(34))
            EndIf
            *childnode =ChildXMLNode(*node)
            While *childnode <> 0
              Select GetXMLNodeName(*childnode)
              
                Case "text":
                  If ExamineXMLAttributes(*childnode)
                    While NextXMLAttribute(*childnode)
                      val2$ = XMLAttributeValue(*childnode)
                      Select XMLAttributeName(*childnode)
                      
                        Case "language":
                          If val2$ = preferences\language$
                            message_list$(id) = GetXMLNodeText(*childnode)
                          EndIf
                        
                        Default:
                          error_message("load_message_list(): unknown attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in text tag in messages xml file " + Chr(34) + filename$ + Chr(34))
                      
                      EndSelect
                    Wend
                  EndIf           
                  
                Default:
                  error_message("load_message_list(): unknown tag " + Chr(34) + GetXMLNodeName(*childnode) + Chr(34) + " in messages xml file " + Chr(34) + filename$ + Chr(34))
                  
              EndSelect
              *childnode = NextXMLNode(*childnode)
            Wend
          EndIf
        
        Default:
          error_message("load_message_list(): unknown tag " + Chr(34) + GetXMLNodeName(*node) + Chr(34) + " in messages xml file " + Chr(34) + filename$ + Chr(34))
          
      EndSelect
      *node = NextXMLNode(*node)
    Wend
  EndIf
  FreeXML(0)
EndProcedure
; IDE Options = PureBasic 4.20 (Windows - x86)
; CursorPosition = 19
; FirstLine = 3
; Folding = -
; EnableXP
; CompileSourceDirectory
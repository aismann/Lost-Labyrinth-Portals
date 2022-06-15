; Lost Labyrinth VI: Portals
; powers
; written in PureBasic 4.20 (http://www.purebasic.com)
; created:  10.11.2008 Frank Malota <malota@web.de>
; modified: 08.01.2009 Frank Malota <malota@web.de>


; resets a power
Procedure reset_power(*power.power_db_struct)
  Protected i.w = 0
  With *power
    \name$ = ""
    \description$ = ""
    \tile = 0
    \effect = 0
    \effect_name$ = ""
    \effect_strength = 0
    \strength_bonus_attribute = 0
    \strength_bonus_attribute_name$ = ""
    \strength_multiplier = 1
    \strength_randomized = 0
    \randomized_strength_bonus = 0
    \randomized_strength_bonus_attribute = 0
    \randomized_strength_bonus_attribute_name$ = ""
    \randomized_strength_multiplier = 1
    \randomized_strength_divisor = 1
    \animation$ = ""
    \end_turn = 0
    \sound$ = ""
    \failure_sound$ = ""
    \wrong_use_sound$ = ""
    \success_attribute = 0
    \success_attribute_name$ = ""
    \success_bonus = 0
    \success_attribute_multiplier = 1
    \success_attribute_divisor = 1
    \success_message$ = ""
    \failure_message$ = ""
    \wrong_use_message$ = ""
    \already_used_message$ = ""
    \cost = 0
    \cost_attribute = 0
    \cost_attribute_name$ = ""
    \class$ = ""
    \range = 0
    \modify_attribute = 0
    \modify_attribute_name$ = ""
    \activates_ability_id = 0
    \activates_ability_name$ = ""
    \deplete_attribute_id = 0
    \deplete_attribute_name$ = ""
    \cooldown = 0
    \monster_effect$ = ""
    \field_effect$ = ""
    \affects_only_monster_class$ = ""  
  EndWith
  For i=0 To #MAX_NUMBER_OF_POWER_REQUIREMENTS - 1
    With *power\power_requirement[i]
      \attribute = 0
      \attribute_name$ = ""
      \value = 0
    EndWith
  Next  
EndProcedure


; resets power db
Procedure reset_power_db()
  Protected i.w, j.w
  For i=0 To #MAX_NUMBER_OF_POWERS - 1
    reset_power(@power_db(i))
  Next
EndProcedure


; resolves names in power db
Procedure powers_db_resolve_names()
  Protected i.w, j.w, k.w
  For i=0 To #MAX_NUMBER_OF_POWERS-1
    If power_db(i)\strength_bonus_attribute_name$ <> "" And power_db(i)\strength_bonus_attribute = 0
      For j=0 To #MAX_NUMBER_OF_ABILITIES-1
        If ability_db(j)\name$ = power_db(i)\strength_bonus_attribute_name$
          power_db(i)\strength_bonus_attribute = j
        EndIf
      Next
      If power_db(i)\strength_bonus_attribute = 0
        error_message("powers_db_resolve_names(): cannot find ability " + Chr(34) + power_db(i)\strength_bonus_attribute_name$ + Chr(34))
      EndIf
    EndIf
    If power_db(i)\success_attribute_name$ <> "" And power_db(i)\success_attribute = 0
      For j=0 To #MAX_NUMBER_OF_ABILITIES-1
        If ability_db(j)\name$ = power_db(i)\success_attribute_name$
          power_db(i)\success_attribute = j
        EndIf
      Next
      If power_db(i)\success_attribute = 0
        error_message("powers_db_resolve_names(): cannot find ability " + Chr(34) + power_db(i)\success_attribute_name$ + Chr(34))
      EndIf
    EndIf
    If power_db(i)\cost_attribute_name$ <> "" And power_db(i)\cost_attribute = 0
      For j=0 To #MAX_NUMBER_OF_ABILITIES-1
        If ability_db(j)\name$ = power_db(i)\cost_attribute_name$
          power_db(i)\cost_attribute = j
        EndIf
      Next
      If power_db(i)\cost_attribute = 0
        error_message("powers_db_resolve_names(): cannot find ability " + Chr(34) + power_db(i)\cost_attribute_name$ + Chr(34))
      EndIf
    EndIf
    If power_db(i)\modify_attribute_name$ <> "" And power_db(i)\modify_attribute = 0
      For j=0 To #MAX_NUMBER_OF_ABILITIES-1
        If ability_db(j)\name$ = power_db(i)\modify_attribute_name$
          power_db(i)\modify_attribute = j
        EndIf
      Next
      If power_db(i)\modify_attribute = 0
        error_message("powers_db_resolve_names(): cannot find ability " + Chr(34) + power_db(i)\modify_attribute_name$ + Chr(34))
      EndIf
    EndIf
    If power_db(i)\adjust_attribute_name$ <> "" And power_db(i)\adjust_attribute = 0
      For j=0 To #MAX_NUMBER_OF_ABILITIES-1
        If ability_db(j)\name$ = power_db(i)\adjust_attribute_name$
          power_db(i)\adjust_attribute = j
        EndIf
      Next
      If power_db(i)\adjust_attribute = 0
        error_message("powers_db_resolve_names(): cannot find ability " + Chr(34) + power_db(i)\adjust_attribute_name$ + Chr(34))
      EndIf
    EndIf
    If power_db(i)\duration_bonus_attribute_name$ <> "" And power_db(i)\duration_bonus_attribute = 0
      For j=0 To #MAX_NUMBER_OF_ABILITIES - 1
        If ability_db(j)\name$ = power_db(i)\duration_bonus_attribute_name$
          power_db(i)\duration_bonus_attribute = j
        EndIf
      Next
      If power_db(i)\duration_bonus_attribute = 0
        error_message("powers_db_resolve_names(): cannot find ability " + Chr(34) + power_db(i)\duration_bonus_attribute_name$ + Chr(34))
      EndIf
    EndIf
    If power_db(i)\activates_ability_name$ <> "" And power_db(i)\activates_ability_id = 0
      For j=0 To #MAX_NUMBER_OF_ABILITIES - 1
        If ability_db(j)\name$ = power_db(i)\activates_ability_name$
          power_db(i)\activates_ability_id = j
        EndIf
      Next
      If power_db(i)\activates_ability_id = 0
        error_message("powers_db_resolve_names(): cannot find ability " + Chr(34) + power_db(i)\activates_ability_name$ + Chr(34))
      EndIf
    EndIf
    If power_db(i)\deplete_attribute_name$ <> "" And power_db(i)\deplete_attribute_id = 0
      For j=0 To #MAX_NUMBER_OF_ABILITIES - 1
        If ability_db(j)\name$ = power_db(i)\deplete_attribute_name$
          power_db(i)\deplete_attribute_id = j
        EndIf
      Next
      If power_db(i)\deplete_attribute_id = 0
        error_message("powers_db_resolve_names(): cannot find ability " + Chr(34) + power_db(i)\deplete_attribute_name$ + Chr(34))
      EndIf
    EndIf
    For j=0 To #MAX_NUMBER_OF_POWER_REQUIREMENTS-1
      If power_db(i)\power_requirement[j]\attribute_name$ <> "" And power_db(i)\power_requirement[j]\attribute = 0
        For k=0 To #MAX_NUMBER_OF_ABILITIES-1
          If ability_db(k)\name$ = power_db(i)\power_requirement[j]\attribute_name$
            power_db(i)\power_requirement[j]\attribute = k
          EndIf
        Next
        If power_db(i)\power_requirement[j]\attribute = 0
          error_message("powers_db_resolve_names(): cannot find ability " + Chr(34) + power_db(i)\power_requirement[j]\attribute_name$ + Chr(34))
        EndIf
      EndIf
    Next
  Next
EndProcedure


; loads power definition from XML file into db structure
Procedure load_power_db()
  Protected filename$ ="data\powers.xml"
  Protected val$, name$, effect.w, effect_strength.w, strength_bonus_attribute.w
  Protected strength_bonus_attribute_name$, animation$, end_turn.b, power_idx.w = 1
  Protected effect_name$, tile.w, sound$, description$, success_attribute.w
  Protected success_attribute_name$, success_bonus.w, success_attribute_multiplier.b
  Protected success_attribute_divisor.b, cost.w, cost_attribute.w, cost_attribute_name$
  Protected strength_multiplier.b, strength_divisor.b, failure_message$, class$
  Protected success_message$, val2$, req_idx.w, req_attribute.w, req_attribute_name$
  Protected req_value.w, wrong_use_message$, failure_sound$, wrong_use_sound$, range.b
  Protected modify_attribute.w, modify_attribute_name$, strength_randomized.b
  Protected adjust_attribute.w, adjust_attribute_name$, duration.w, duration_bonus_attribute.w
  Protected duration_bonus_attribute_name$, duration_multiplier.w, duration_divisor.w
  Protected activates_ability_id.w, activates_ability_name$, deplete_attribute_id.w, deplete_attribute_name$
  Protected power_id.w, cooldown.w = 0, monster_effect$, randomized_strength_bonus.w = 0
  Protected affects_only_monster_class$, *mainnode, *node, *childnode
  Protected new_power.power_db_struct, message_language$, message_type$
  If CreateXML(0) = 0
    error_message("load_power_db(): could not create xml structure in memory!")
  EndIf
  If LoadXML(0, filename$) = 0
    error_message("load_power_db(): could not open power xml file: " + Chr(34) + filename$ + Chr(34))
  EndIf
  If XMLStatus(0) <> 0
    error_message("load_power_db(): error in xml structure of powers file " + Chr(34) + filename$ + Chr(34) + ": " + XMLError(0))
  EndIf
  reset_power_db()
  *mainnode = MainXMLNode(0)
  If *mainnode
    *node = ChildXMLNode(*mainnode)
    While *node <> 0
      Select GetXMLNodeName(*node)
      
        Case "power":
          reset_power(@new_power)
          power_id = 0
          If ExamineXMLAttributes(*node)
            While NextXMLAttribute(*node)
              val$ = XMLAttributeValue(*node)
              Select XMLAttributeName(*node)
              
                Case "id":
                  power_id = Val(val$)
                  If power_id < 1 Or power_id >= #MAX_NUMBER_OF_POWERS
                    error_message("load_power_db(): wrong ID attribute " + Chr(34) + val$ + Chr(34) + " in powers xml file " + Chr(34) + filename$ + Chr(34))
                  EndIf

                Case "name":
                  new_power\name$ = val$
                  
                Case "description":
                  new_power\description$ = val$
                  
                Case "tile":
                  new_power\tile = Val(val$)
                  
                Case "effect":
                  new_power\effect = Val(val$)
                  
                Case "effect_name":
                  new_power\effect_name$ = val$
                  
                Case "effect_strength":
                  new_power\effect_strength = Val(val$)
                  
                Case "strength_bonus_attribute":
                  new_power\strength_bonus_attribute = Val(val$)
                  
                Case "strength_bonus_attribute_name":
                  new_power\strength_bonus_attribute_name$ = val$
                  
                Case "strength_multiplier":
                  new_power\strength_multiplier = Val(val$)
                  
                Case "strength_divisor":
                  new_power\strength_divisor = Val(val$)
                  
                Case "strength_randomized":
                  If val$ = "yes"
                    new_power\strength_randomized = 1
                  EndIf
                  
                Case "randomized_strength_bonus":
                  new_power\randomized_strength_bonus = Val(val$)
                  
                Case "randomized_strength_bonus_attribute":
                  new_power\randomized_strength_bonus_attribute = Val(val$)
                  
                Case "randomized_strength_bonus_attribute_name":
                  new_power\randomized_strength_bonus_attribute_name$ = val$
                  
                Case "randomized_strength_multiplier":
                  new_power\randomized_strength_multiplier = Val(val$)
                  
                Case "randomized_strength_divisor":
                  new_power\randomized_strength_divisor = Val(val$)
                  
                Case "animation":
                  new_power\animation$ = val$
                  
                Case "end_turn":
                  If val$ = "yes"
                    new_power\end_turn = 1
                  EndIf
                
                Case "sound":
                  new_power\sound$ = val$
                  
                Case "failure_sound":
                  new_power\failure_sound$ = val$
                
                Case "wrong_use_sound":
                  new_power\wrong_use_sound$ = val$
                  
                Case "success_attribute":
                  new_power\success_attribute = Val(val$)
                  
                Case "success_attribute_name":
                  new_power\success_attribute_name$ = val$
                
                Case "success_bonus":
                  new_power\success_bonus = Val(val$)
                  
                Case "success_attribute_multiplier":
                  new_power\success_attribute_multiplier = Val(val$)
                  
                Case "success_attribute_divisor":
                  new_power\success_attribute_divisor = Val(val$)
                  
                Case "success_message":
                  new_power\success_message$ = val$
                  
                Case "failure_message":
                  new_power\failure_message$ = val$
                  
                Case "wrong_use_message":
                  new_power\wrong_use_message$ = val$
                  
                Case "already_used_message":
                  new_power\already_used_message$ = val$
                  
                Case "cost":
                  new_power\cost = Val(val$)
                  
                Case "cost_attribute":
                  new_power\cost_attribute = Val(val$)
                
                Case "cost_attribute_name":
                  new_power\cost_attribute_name$ = val$
                  
                Case "class":
                  new_power\class$ = val$
                  
                Case "range":
                  new_power\range = Val(val$)
                  
                Case "modify_attribute":
                  new_power\modify_attribute = Val(val$)
                  
                Case "modify_attribute_name":
                  new_power\modify_attribute_name$ = val$
                  
                Case "adjust_attribute":
                  new_power\adjust_attribute = Val(val$)
                  
                Case "adjust_attribute_name":
                  new_power\adjust_attribute_name$ = val$
                  
                Case "duration":
                  new_power\duration = Val(val$)
                  
                Case "duration_bonus_attribute":
                  new_power\duration_bonus_attribute = Val(val$)
                  
                Case "duration_bonus_attribute_name":
                  new_power\duration_bonus_attribute_name$ = val$
                  
                Case "duration_multiplier":
                  new_power\duration_multiplier = Val(val$)
                  
                Case "duration_divisor":
                  new_power\duration_divisor = Val(val$)
                  
                Case "activates_ability_id":
                  new_power\activates_ability_id = Val(val$)
                  
                Case "activates_ability_name":
                  new_power\activates_ability_name$ = val$
                  
                Case "deplete_attribute_id":
                  new_power\deplete_attribute_id = Val(val$)
                  
                Case "deplete_attribute_name":
                  new_power\deplete_attribute_name$ = val$
                  
                Case "cooldown":
                  new_power\cooldown = Val(val$)
                  
                Case "monster_effect":
                  new_power\monster_effect$ = val$
                  
                Case "affects_only_monster_class":
                  new_power\affects_only_monster_class$ = val$
                  
                Case "field_effect":
                  new_power\field_effect$ = val$
                  
                Default:
                  error_message("load_power_db(): unknown attribute " + Chr(34) + XMLAttributeName(*node) + Chr(34) + " in power tag in power xml file " + Chr(34) + filename$ + Chr(34))
              
              EndSelect
            Wend
            If power_id > 0
              With power_db(power_id)
                \name$ = new_power\name$
                \description$ = new_power\description$
                \tile = new_power\tile
                \effect_name$ = new_power\effect_name$
                \effect = new_power\effect
                \effect_strength = new_power\effect_strength
                \strength_bonus_attribute = new_power\strength_bonus_attribute
                \strength_bonus_attribute_name$ = new_power\strength_bonus_attribute_name$
                \strength_multiplier = new_power\strength_multiplier
                \strength_divisor = new_power\strength_divisor
                \strength_randomized = new_power\strength_randomized
                \randomized_strength_bonus = new_power\randomized_strength_bonus
                \randomized_strength_bonus_attribute = new_power\randomized_strength_bonus_attribute
                \randomized_strength_bonus_attribute_name$ = new_power\randomized_strength_bonus_attribute_name$
                \randomized_strength_multiplier = new_power\randomized_strength_multiplier
                \randomized_strength_divisor = new_power\randomized_strength_divisor
                \animation$ = new_power\animation$
                \end_turn = new_power\end_turn
                \sound$ = new_power\sound$
                \failure_sound$ = new_power\failure_sound$
                \wrong_use_sound$ = new_power\wrong_use_sound$
                \success_attribute = new_power\success_attribute
                \success_attribute_name$ = new_power\success_attribute_name$
                \success_bonus = new_power\success_bonus
                \success_attribute_multiplier = new_power\success_attribute_multiplier
                \success_attribute_divisor = new_power\success_attribute_divisor
                \success_message$ = new_power\success_message$
                \failure_message$ = new_power\failure_message$
                \wrong_use_message$ = new_power\wrong_use_message$
                \already_used_message$ = new_power\already_used_message$
                \cost = new_power\cost
                \cost_attribute = new_power\cost_attribute
                \cost_attribute_name$ = new_power\cost_attribute_name$
                \class$ = new_power\class$
                \range = new_power\range
                \modify_attribute = new_power\modify_attribute
                \modify_attribute_name$ = new_power\modify_attribute_name$
                \adjust_attribute = new_power\adjust_attribute
                \adjust_attribute_name$ = new_power\adjust_attribute_name$
                \duration = new_power\duration
                \duration_bonus_attribute = new_power\duration_bonus_attribute
                \duration_bonus_attribute_name$ = new_power\duration_bonus_attribute_name$
                \duration_multiplier = new_power\duration_multiplier
                \duration_divisor = new_power\duration_divisor
                \activates_ability_id = new_power\activates_ability_id
                \activates_ability_name$ = new_power\activates_ability_name$
                \deplete_attribute_id = new_power\deplete_attribute_id
                \deplete_attribute_name$ = new_power\deplete_attribute_name$
                \cooldown = new_power\cooldown
                \monster_effect$ = new_power\monster_effect$
                \affects_only_monster_class$ = new_power\affects_only_monster_class$
                \field_effect$ = new_power\field_effect$
              EndWith
              req_idx = 0
              
              *childnode = ChildXMLNode(*node)
              While *childnode <> 0
                Select GetXMLNodeName(*childnode)
                  
                  Case "requirement":
                    If req_idx >= #MAX_NUMBER_OF_POWER_REQUIREMENTS
                      error_message("load_power_db(): too much requirements for one power in powers xml file " + Chr(34) + filename$ + Chr(34))
                    EndIf
                    req_attribute = 0
                    req_attribute_name$ = ""
                    req_value = 0
                    If ExamineXMLAttributes(*childnode)
                      While NextXMLAttribute(*childnode)
                        val2$ = XMLAttributeValue(*childnode)
                        Select XMLAttributeName(*childnode)
                        
                          Case "attribute":
                            req_attribute = Val(val2$)
                            
                          Case "attribute_name":
                            req_attribute_name$ = val2$
                            
                          Case "value":
                            req_value = Val(val2$)
                            
                          Default:
                            error_message("load_power_db(): wrong attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in requirement tag in powers xml file " + Chr(34) + filename$ + Chr(34))
                            
                        EndSelect
                      Wend
                    EndIf
                    If req_attribute > 0 Or req_attribute_name$ <> ""
                      power_db(power_id)\power_requirement[req_idx]\attribute = req_attribute
                      power_db(power_id)\power_requirement[req_idx]\attribute_name$ = req_attribute_name$
                      power_db(power_id)\power_requirement[req_idx]\value = req_value
                      req_idx = req_idx + 1
                    EndIf
                    
                  Case "name":
                    If ExamineXMLAttributes(*childnode)
                      While NextXMLAttribute(*childnode)
                        val2$ = XMLAttributeValue(*childnode)
                        Select XMLAttributeName(*childnode)
                          
                          Case "language":
                            If val2$ = preferences\language$
                              power_db(power_id)\name$ = GetXMLNodeText(*childnode)
                            EndIf
                            
                          Default:
                            error_message("load_power_db(): unknown attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in name tag in power xml file " + Chr(34) + filename$ + Chr(34))
                        
                        EndSelect
                      Wend
                    EndIf
                    
                  Case "description":
                    If ExamineXMLAttributes(*childnode)
                      While NextXMLAttribute(*childnode)
                        val2$ = XMLAttributeValue(*childnode)
                        Select XMLAttributeName(*childnode)
                          
                          Case "language":
                            If val2$ = preferences\language$
                              power_db(power_id)\description$ = GetXMLNodeText(*childnode)
                            EndIf
                            
                          Default:
                            error_message("load_power_db(): unknown attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in description tag in power xml file " + Chr(34) + filename$ + Chr(34))
                        
                        EndSelect
                      Wend
                    EndIf
                    
                  Case "message":
                    message_language$ = ""
                    message_type$ = ""
                    If ExamineXMLAttributes(*childnode)
                      While NextXMLAttribute(*childnode)
                        val2$ = XMLAttributeValue(*childnode)
                        Select XMLAttributeName(*childnode)
                          
                          Case "language":
                            message_language$ = val2$
                            
                          Case "type":
                            message_type$ = val2$
                            
                          Default:
                            error_message("load_power_db(): unknown attribute " + Chr(34) + XMLAttributeName(*childnode) + Chr(34) + " in message tag in power xml file " + Chr(34) + filename$ + Chr(34))
                        
                        EndSelect
                      Wend
                      If message_language$ = preferences\language$
                        Select message_type$
                          
                          Case "success":
                            power_db(power_id)\success_message$ = GetXMLNodeText(*childnode)
                            
                          Case "failure":
                            power_db(power_id)\failure_message$ = GetXMLNodeText(*childnode)
                            
                          Case "wrong use":
                            power_db(power_id)\wrong_use_message$ = GetXMLNodeText(*childnode)
                          
                          Case "already used":
                            power_db(power_id)\already_used_message$ = GetXMLNodeText(*childnode)
                            
                          Default:
                            error_message("load_power_db(): unknown message type " + Chr(34) + message_type$ + Chr(34) + " in powers xml file " + Chr(34) + filename$ + Chr(34))
                            
                        EndSelect
                      EndIf
                    EndIf
                                                                              
                  Default:
                    error_message("load_power_db(): unknown tag " + Chr(34) + GetXMLNodeName(*childnode) + Chr(34) + " in powers xml file " + Chr(34) + filename$ + Chr(34))
                
                EndSelect
                *childnode = NextXMLNode(*childnode)
              Wend
            EndIf
          EndIf          
        
        Default:
          error_message("load_power_db(): unknown tag " + Chr(34) + GetXMLNodeName(*node) + Chr(34) + " in power xml file " + Chr(34) + filename$ + Chr(34))
          
      EndSelect
      *node = NextXMLNode(*node)
    Wend
  EndIf
  FreeXML(0)
  powers_db_resolve_names()
EndProcedure


; returns power effect strength for current character
Procedure.w power_strength(power_id.w)
  Protected rc.w = 0, attribute.w, bonus.w
  If power_id < 1 Or power_id >= #MAX_NUMBER_OF_POWERS
    error_message("power_strength(): wrong power id: " + Str(power_id))
  EndIf
  rc = power_db(power_id)\effect_strength
  attribute = power_db(power_id)\strength_bonus_attribute
  If attribute > 0 And attribute < #MAX_NUMBER_OF_ABILITIES
    bonus = attribute_current_val(attribute)
    If power_db(power_id)\strength_multiplier <> 1
      bonus = bonus * power_db(power_id)\strength_multiplier
    EndIf
    If power_db(power_id)\strength_divisor > 1
      bonus = Int(bonus / power_db(power_id)\strength_divisor)
    EndIf
    rc = rc + bonus
  EndIf
  ProcedureReturn rc
EndProcedure


; returns randomized part of power effect strength for current character
Procedure.w power_strength_random_part(power_id.w)
  Protected rc.w = 0, attribute.w, bonus.w
  If power_id < 1 Or power_id >= #MAX_NUMBER_OF_POWERS
    error_message("power_strength_random_part(): wrong power id: " + Str(power_id))
  EndIf
  If power_db(power_id)\strength_randomized = 1
    rc = power_db(power_id)\randomized_strength_bonus
    attribute = power_db(power_id)\randomized_strength_bonus_attribute
    If attribute > 0 And attribute < #MAX_NUMBER_OF_ABILITIES
      bonus = attribute_current_val(attribute)
      If power_db(power_id)\randomized_strength_multiplier <> 1
        bonus = bonus * power_db(power_id)\randomized_strength_multiplier
      EndIf
      If power_db(power_id)\randomized_strength_divisor > 1
        bonus = Int(bonus / power_db(power_id)\randomized_strength_divisor)
      EndIf
      rc = rc + bonus
    EndIf
  EndIf
  ProcedureReturn rc
EndProcedure


; returns randomized power effect strength for current character
Procedure.w power_strength_randomized(power_id.w)
  Protected rc.w = 0
  rc = power_strength_random_part(power_id)
  If rc > 0
    rc = Random(rc)
  EndIf
  rc = rc + power_strength(power_id)
  ;Debug Str(power_strength(power_id)) + " - " + Str(power_strength(power_id) + power_strength_random_part(power_id))
  ProcedureReturn rc
EndProcedure


; sets cooldown for power
Procedure power_cooldown(power_id.w)
  If power_db(power_id)\cooldown > 0
    current_character\power[power_id]\cooldown = power_db(power_id)\cooldown
  EndIf
EndProcedure


; plays sound effect for succcesful power usage; returns 1 if sound was found, else 0
Procedure.b power_success_sound(power_id.w)
  Protected rc.b = 0
  If power_db(power_id)\sound$ <> ""
    play_sound(power_db(power_id)\sound$)
    rc = 1
  EndIf
  ProcedureReturn rc
EndProcedure


; plays sound effect for unsuccessful power usage; returns 1 if sound was found, else 0
Procedure.b power_failure_sound(power_id.w)
  Protected rc.b = 0
  If power_db(power_id)\failure_sound$ <> ""
    play_sound(power_db(power_id)\failure_sound$)
    rc = 1
  EndIf
  ProcedureReturn rc
EndProcedure


; plays sound effect if power was used wrongly; returns 1 if sound was found, else 0
Procedure.b power_wrong_usage_sound(power_id)
  Protected rc.b = 0
  If power_db(power_id)\wrong_use_sound$ <> ""
    play_sound(power_db(power_id)\wrong_use_sound$)
    rc = 1
  EndIf
  ProcedureReturn rc
EndProcedure


; displays message if power was used successfully; returns 1 if message was found, else 0
Procedure.b power_success_message(power_id)
  Protected rc.b = 0, message$
  If power_db(power_id)\success_message$ <> ""
    message$ = ReplaceString(power_db(power_id)\success_message$, "[power_strength]", Str(power_strength(power_id)), #PB_String_NoCase)
    message(message$, "", $ffffff, power_db(power_id)\tile, 2)
    rc = 1
  EndIf
  ProcedureReturn rc
EndProcedure


; displays message if power was used unsuccessfully; returns 1 if message was found, else 0
Procedure.b power_failure_message(power_id)
  Protected rc.b = 0
  If power_db(power_id)\failure_message$ <> ""
    message(power_db(power_id)\failure_message$, "", $ffffff, power_db(power_id)\tile, 2)
    rc = 1
  EndIf  
  ProcedureReturn rc
EndProcedure


; displays message if power was already used; returns 1 if message was found, else 0
Procedure.b power_already_used_message(power_id)
  Protected rc.b = 0
  If power_db(power_id)\already_used_message$ <> ""
    message(power_db(power_id)\already_used_message$, "", $ffffff, power_db(power_id)\tile, 2)
    rc = 1
  EndIf  
  ProcedureReturn rc
EndProcedure


; displays message if power was used wrongly; returns 1 if message was found, else 0
Procedure.b power_wrong_usage_message(power_id)
  Protected rc.b
  If power_db(power_id)\wrong_use_message$ <> ""
    message(power_db(power_id)\wrong_use_message$, "", $ffffff, power_db(power_id)\tile, 2)
    rc = 1
  EndIf
  ProcedureReturn rc
EndProcedure


; returns 1 if power is available to character, else 0
Procedure.b power_available(power_id.w, gain_attribute.w = 0, gain_bonus.w = 0)
  Protected rc.b = 1, i.w = 0, attribute.w = 0, value.w = 0, current_attribute_value.w = 0
  If power_db(power_id)\name$ = ""
    rc = 0
  EndIf
  If rc = 1
    For i=0 To #MAX_NUMBER_OF_POWER_REQUIREMENTS-1
      attribute = power_db(power_id)\power_requirement[i]\attribute
      value = power_db(power_id)\power_requirement[i]\value
      If attribute > 0
        current_attribute_value = attribute_current_val(attribute, 1, 0, 0)
        If attribute = gain_attribute
          current_attribute_value = current_attribute_value + gain_bonus
        EndIf
        If current_attribute_value < value
          rc = 0
        EndIf
      EndIf
    Next
  EndIf
  ProcedureReturn rc 
EndProcedure


; returns success chance for power for current character
Procedure power_success_chance(power_id.w)
  Protected rc.w = 100, attribute.w
  If power_id < 1 Or power_id >= #MAX_NUMBER_OF_POWERS
    error_message("power_success_chance(): wrong power id: " + Str(power_id))
  EndIf
  attribute = power_db(power_id)\success_attribute
  If attribute > 0 And attribute < #MAX_NUMBER_OF_ABILITIES
    rc = attribute_current_val(attribute)
    If power_db(power_id)\success_attribute_multiplier > 1
      rc = rc * power_db(power_id)\success_attribute_multiplier
    EndIf
    If power_db(power_id)\success_attribute_divisor > 1
      rc = Int(rc / power_db(power_id)\success_attribute_divisor)
    EndIf
    rc = rc + power_db(power_id)\success_bonus
  EndIf
  ProcedureReturn rc
EndProcedure


; attack via power
Procedure power_attack(power_id.w)
  Protected cursor.cursor_struct, attack.b = 0, *attacked_monster, damage.w, x1.w, y1.w
  Protected success_chance.w, x.w, y.w, i.w, monster_type.w, text$
  reset_cursor(@cursor)
  cursor_select_field(@cursor)
  If cursor\esc <> 1
    ForEach monster()
      If monster()\xpos = current_character\xpos - 6 + cursor\x And monster()\ypos = current_character\ypos - 6 + cursor\y
        attack = 1
        *attacked_monster = @monster()
      EndIf
    Next
  EndIf
  If attack = 1
    animation(power_db(power_id)\animation$, cursor\x, cursor\y)
    success_chance = power_success_chance(power_id)
    If Random(99) >= success_chance
      attack = 0
      power_failure_sound(power_id)
      power_failure_message(power_id)   
    EndIf
  EndIf
  If attack = 1
    ChangeCurrentElement(monster(), *attacked_monster)
    x = monster()\xpos
    y = monster()\ypos
    monster_type = monster()\type
    damage = power_strength_randomized(power_id)
    damage = monster_adjust_damage(monster_type, damage, power_db(power_id)\class$, power_db(power_id)\affects_only_monster_class$)
    power_success_message(power_id)
    play_sound("hit")
    ClearScreen(0)
    draw_map_screen(@current_map)
    draw_frame_main_screen() 
    draw_right_panel()
    draw_character()
    x1 = cursor\x * 32
    y1 = cursor\y * 32
    DisplayTransparentSprite(#SPRITE_BLOOD, x1, y1)
    StartDrawing(ScreenOutput())
    DrawingFont(#PB_Default)
    text$ = Str(damage)
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawText(x1 + 16 - TextWidth(text$)/2, y1 + 16 - TextHeight(text$)/2, text$, $ffffff, 0)
    StopDrawing()
    ChangeCurrentElement(monster(), *attacked_monster)    
    monster()\hitpoints = monster()\hitpoints - damage
    kill_monster()
    FlipBuffers()
    Delay(250)
    ClearScreen(0)
    draw_map_screen(@current_map)
    draw_frame_main_screen() 
    draw_right_panel()
    draw_character()
    FlipBuffers()
    Delay(250)       
  EndIf
EndProcedure


; area attack via power
Procedure power_area_attack(power_id)
  Protected *current_monster, monster_type.w, damage.w
  animation(power_db(power_id)\animation$)
  ResetList(monster())
  While NextElement(monster())
    *current_monster = @monster()
    monster_type = monster()\type
    If monster()\xpos >= current_character\xpos - 6 And monster()\xpos <= current_character\xpos + 6 And monster()\ypos >= current_character\ypos - 6 And monster()\ypos <= current_character\ypos + 6
      damage = power_strength_randomized(power_id)
      damage = monster_adjust_damage(monster_type, damage, power_db(power_id)\class$, power_db(power_id)\affects_only_monster_class$) 
      ChangeCurrentElement(monster(), *current_monster)
      play_sound("hit")
      animation("red cloud", monster()\xpos + 6 - current_character\xpos, monster()\ypos + 6 - current_character\ypos, damage)
      ChangeCurrentElement(monster(), *current_monster)
      monster()\hitpoints = monster()\hitpoints - damage
    EndIf
  Wend
  kill_monster()
EndProcedure


; creates an effect with duration
Procedure power_duration_effect(power_id.w)
  Protected adjustment.w, duration.w = 0, duration_bonus.w = 0, attribute.w
  If power_db(power_id)\adjust_attribute > 0
    If Random(99) >= power_success_chance(power_id)
      power_failure_sound(power_id)
      power_failure_message(power_id)
    Else
      attribute = power_db(power_id)\adjust_attribute
      adjustment = power_strength(power_id)
      duration = power_db(power_id)\duration
      If power_db(power_id)\duration_bonus_attribute > 0
        duration_bonus = attribute_current_val(power_db(power_id)\duration_bonus_attribute)
      EndIf
      If power_db(power_id)\duration_multiplier > 1
        duration_bonus = duration_bonus * power_db(power_id)\duration_multiplier
      EndIf
      If power_db(power_id)\duration_divisor > 1
        duration_bonus = Int(duration_bonus / power_db(power_id)\duration_divisor)
      EndIf
      current_character\ability[attribute]\power_adjustment = adjustment
      current_character\ability[attribute]\adjustment_duration = duration + duration_bonus
      current_character\ability[attribute]\adjustment_name$ = power_db(power_id)\name$
      current_character\ability[attribute]\adjustment_power_id = power_id
      current_character\ability[attribute]\adjustment_item_id = 0
      animation(power_db(power_id)\animation$)
      power_success_sound(power_id)
      power_success_message(power_id)
      power_cooldown(power_id)
    EndIf
  EndIf
EndProcedure


; modifies an attribute value; returns amount by which attribute was increased/decreased
Procedure.w power_modify_attribute(power_id.w, secondary_effect.b = 0)
  Protected rc.w = 0
  If power_db(power_id)\modify_attribute > 0
    If secondary_effect = 0
      animation(power_db(power_id)\animation$)
      power_success_sound(power_id)
      power_success_message(power_id)
    EndIf
    rc = modify_attribute(power_db(power_id)\modify_attribute, power_strength(power_id))
    If rc <> 0 And secondary_effect = 0
      power_cooldown(power_id)
    EndIf
  EndIf
  ProcedureReturn rc
EndProcedure


; uses/transforms a field via power; returns 1 if power was used successfully, else 0
Procedure.b power_use_field(power_id.w, transformation.b = 0)
  Protected cursor.cursor_struct, tile_type.w, x.w, y.w, class$, transforms_into.w, rc.b = 0
  Protected success_chance.w
  reset_cursor(@cursor)
  cursor_select_field(@cursor, power_db(power_id)\range)
  x = current_character\xpos - 6 + cursor\x
  y = current_character\ypos - 6 + cursor\y
  tile_type = read_map_tile_type(@current_map, x, y)
  class$ = current_map\tileset\tile_type_db[tile_type]\class$
  transforms_into = current_map\tileset\tile_type_db[tile_type]\transforms_into
  success_chance = power_success_chance(power_id)
  rc = 1
  If compare_string_lists(power_db(power_id)\class$, class$) = 0
    power_wrong_usage_sound(power_id)
    power_wrong_usage_message(power_id)
    rc = 0  
  EndIf
  If rc = 1
    If read_map_if_power_used(@current_map, x, y, power_db(power_id)\field_effect$) = 1
      power_wrong_usage_sound(power_id)
      power_already_used_message(power_id)
      rc = 0
    EndIf
  EndIf
  If rc = 1
    animation(power_db(power_id)\animation$, cursor\x, cursor\y)
    If Random(99) >= success_chance
      power_failure_sound(power_id)
      power_failure_message(power_id)
      add_map_power_used(@current_map, x, y, power_db(power_id)\field_effect$)
      rc = 0   
    EndIf
  EndIf
  If rc = 1
    If transformation = 1
      set_map_tile_type(current_map, x, y, transforms_into)
    EndIf
    power_success_sound(power_id)
    power_success_message(power_id)
    power_modify_attribute(power_id, 1)
    power_cooldown(power_id)
    add_map_power_used(@current_map, x, y, power_db(power_id)\field_effect$)
  EndIf
  ProcedureReturn rc
EndProcedure


; activates / deactivates an ability
Procedure power_activate_ability(power_id.w)
  Protected ability_id.w = 0
  If power_db(power_id)\activates_ability_id > 0
    ability_id = power_db(power_id)\activates_ability_id
    If current_character\ability[ability_id]\activated = 1
      current_character\ability[ability_id]\activated = 0
    Else
      current_character\ability[ability_id]\activated = 1
    EndIf
    power_cooldown(power_id)
  EndIf
EndProcedure


; depletes an attribute via power
Procedure power_deplete_attribute(power_id.w)
  Protected attribute_id.w = 0
  attribute_id = power_db(power_id)\deplete_attribute_id
  If attribute_id > 0
    animation(power_db(power_id)\animation$)
    power_success_sound(power_id)
    power_success_message(power_id)     
    update_abilities_adjustment_other()
    current_character\ability[attribute_id]\attribute_current_value = 0
  EndIf
EndProcedure


; applies an effect to a monster via power; returns 1 if successfull, else 0
Procedure power_apply_effect_to_monster(power_id.w)
  Protected rc.b = 0, cursor.cursor_struct, *attacked_monster
  reset_cursor(@cursor)
  cursor_select_field(@cursor)
  If cursor\esc <> 1
    ForEach monster()
      If monster()\xpos = current_character\xpos - 6 + cursor\x And monster()\ypos = current_character\ypos - 6 + cursor\y
        rc = 1
        *attacked_monster = @monster()
      EndIf
    Next
  EndIf
  If rc = 1
    ChangeCurrentElement(monster(), *attacked_monster)
    If compare_string_lists(monster()\effect$, power_db(power_id)\monster_effect$) = 1
      animation(power_db(power_id)\animation$, cursor\x, cursor\y)
      play_sound("failure")
      message(message_list$(#MESSAGE_MONSTER_ALREADY_AFFECTED_BY_POWER), "", $ffffff, power_db(power_id)\tile, 2)
      rc = 0
    EndIf
  EndIf
  If rc = 1
    If compare_string_lists(monster_type_db(monster()\type)\immune_class$, power_db(power_id)\class$) = 1
      animation(power_db(power_id)\animation$, cursor\x, cursor\y)
      play_sound("failure")
      message(message_list$(#MESSAGE_MONSTER_IS_IMMUNE_VS_POWER), "", $ffffff, power_db(power_id)\tile, 2)
      rc = 0
    EndIf
  EndIf
  If rc = 1
    If compare_string_lists(monster_type_db(monster()\type)\resistance_class$, power_db(power_id)\class$) = 1
      If Random(3) > 0
        animation(power_db(power_id)\animation$, cursor\x, cursor\y)
        play_sound("failure")
        message(message_list$(#MESSAGE_MONSTER_HAS_RESISTED), "", $ffffff, power_db(power_id)\tile, 2)
        rc = 0
      EndIf
    EndIf
  EndIf  
  If rc = 1
    If power_db(power_id)\monster_effect$ = "sleep"
      monster()\alerted = 0
    Else
      If monster()\effect$ <> ""
        monster()\effect$ = monster()\effect$ + "|"
      EndIf
      monster()\effect$ = monster()\effect$ + power_db(power_id)\monster_effect$      
      monster()\alerted = 1
    EndIf
  EndIf  
  If rc = 1
    animation(power_db(power_id)\animation$, cursor\x, cursor\y)
    power_success_sound(power_id)
    power_success_message(power_id)     
    update_abilities_adjustment_other()
  EndIf
  ProcedureReturn rc
EndProcedure


; uses a power effect
Procedure use_power_effect(power_id.w)
  Select power_db(power_id)\effect_name$
      
    Case "attack":
      power_attack(power_id)
      
    Case "area attack":
      power_area_attack(power_id)
        
    Case "duration":
      power_duration_effect(power_id)
      
    Case "transform field":
      power_use_field(power_id, 1)
        
    Case "use field":
      power_use_field(power_id, 0)
        
    Case "activate ability":
      power_activate_ability(power_id)
        
    Case "deplete attribute":
      power_deplete_attribute(power_id)
        
    Case "modify attribute":
      power_modify_attribute(power_id)
        
    Case "apply effect to monster":
      power_apply_effect_to_monster(power_id)
        
    Default:
      error_message("use_power_effect(): cannot find power effect " + Chr(34) + power_db(power_id)\effect_name$ + Chr(34))
      
  EndSelect
EndProcedure


; character uses a power screen
Procedure use_power_screen(*power_selection.power_selection_struct)
  Protected frame.b = 1, tiles_x.w, tiles_y.w
  Protected i.b = 0, x.w, y.w, power_idx.w, tile_x.w, tile_y.w, power_found.b
  Protected tile.w, text$
  ClearScreen(0)
  draw_map_screen(@current_map)
  draw_character()
  ClipSprite(#SPRITE_Frame, 0, 6*16, 16, 16)
  DisplaySprite(#SPRITE_Frame, 0, 26*16)
  For i=1 To 39
    ClipSprite(#SPRITE_Frame, 0, 7*16 + (frame*16), 16, 16)
    DisplaySprite(#SPRITE_Frame, i*16, 26*16)
    frame = frame + 1
    If frame > 4
      frame = 0
    EndIf
  Next
  ClipSprite(#SPRITE_Frame, 0, 0, 16, 16)
  DisplaySprite(#SPRITE_Frame, 13*32, 0)
  frame = 1
  For i=1 To 25
    ClipSprite(#SPRITE_Frame, 0, frame*16 + 16, 16, 16)
    DisplaySprite(#SPRITE_Frame, 13*32, i*16)
    frame = frame + 1
    If frame > 4
      frame = 0
    EndIf
  Next
  StartDrawing(ScreenOutput())
  DrawingFont(FontID(#FONT_VERDANA_BOLD))
  DrawText(416 + 16 + 2, 0, message_list$(#MESSAGE_USE_A_POWER) + ":", $ffffff, 0)
  DrawingFont(FontID(#FONT_VERDANA))
  If *power_selection\selected_power_id > 0
    DrawText(434, 240, power_db(*power_selection\selected_power_id)\name$, RGB(0,255,255),0)
    y = 256
    ;DrawingFont(FontID(#FONT_SMALL))
    ;y = 256 + wrap_text(434, 256, power_db(*power_selection\selected_power_id)\description$, 180, 12) * 12
    If power_db(*power_selection\selected_power_id)\success_attribute > 0
      text$ = message_list$(#MESSAGE_SUCCESS_CHANCE) + ": " + Str(power_success_chance(*power_selection\selected_power_id)) + "%"
      DrawText(434, y, text$, RGB(255, 100, 0), 0)
      y = y + 16
    EndIf
    If power_db(*power_selection\selected_power_id)\cost > 0
      text$ = message_list$(#MESSAGE_COST) + ": " + Str(power_db(*power_selection\selected_power_id)\cost) + " " + power_db(*power_selection\selected_power_id)\cost_attribute_name$
      DrawText(434, y, text$, RGB(255,100,0), 0)
      y = y + 16
    EndIf
    text$ = message_list$(#MESSAGE_RANGE) + ": "
    Select power_db(*power_selection\selected_power_id)\range
      Case 0: text$ = text$ + " " + message_list$(#MESSAGE_RANGE_SELF)
      Case 1: text$ = text$ + " " + message_list$(#MESSAGE_RANGE_TOUCH)
      Default: text$ = text$ + " " + message_list$(#MESSAGE_RANGE_SIGHT)
    EndSelect
    DrawText(434, y, text$, RGB(255, 100, 0), 0)
    y = y + 16
    If current_character\power[*power_selection\selected_power_id]\cooldown > 0
      text$ = ReplaceString(message_list$(#MESSAGE_COOLDOWN), "[cooldown]", Str(current_character\power[*power_selection\selected_power_id]\cooldown))
      DrawText(434, y, text$, RGB(255, 100, 0), 0)
      y = y + 16
    EndIf
    DrawingFont(FontID(#FONT_SMALL))
    y = y + wrap_text(434, y, power_db(*power_selection\selected_power_id)\description$, 640 - 434, 12) * 12    
  EndIf
  StopDrawing()
  power_idx = 1
  *power_selection\selected_power_id = 0
  For y=0 To 5
    For x=0 To 5
      tiles_x = 0
      tiles_y = 0
      power_found = 0
      While power_found = 0 And power_idx < #MAX_NUMBER_OF_POWERS-1
        If power_available(power_idx)
          tile.w = power_db(power_idx)\tile
          tiles_y = Int(tile / power_tiles_columns)
          tiles_x = tile - (tiles_y * power_tiles_columns)
          power_found = 1
          If *power_selection\cursor\x = x And *power_selection\cursor\y = y
            *power_selection\selected_power_id = power_idx
          EndIf
        EndIf
        power_idx = power_idx + 1
      Wend
      ClipSprite(#SPRITE_POWERS, tiles_x*32, tiles_y*32, 32, 32)
      DisplaySprite(#SPRITE_POWERS, 434 + x * 32, 32 + y * 32)
      If *power_selection\cursor\x = x And *power_selection\cursor\y = y
        ClipSprite(#SPRITE_CURSOR, *power_selection\cursor\frame * 32, 0, 32, 32)
        DisplayTransparentSprite(#SPRITE_CURSOR, 434 + x * 32, 32 + y * 32)
      EndIf
    Next
  Next
EndProcedure


; character uses a power; returns 1 if current turn ends, else 0
Procedure.b use_power()
  Protected leave_power_screen.b = 0, main_window_event.l, rc.b = 0
  Protected selected_power.w = 0, key_lock.b = 0, esc.b = 0, text$, text2$
  Protected power_selection.power_selection_struct, power_id, cost.w, success_chance.w
  Protected success.b, cost_attribute.w
  power_selection\selected_power = 0
  power_selection\selected_power_id = 0
  reset_cursor(@power_selection\cursor)
  power_selection\cursor\x = 0
  power_selection\cursor\y = 0
  key_lock = 1
  Repeat
    ExamineKeyboard()
    If KeyboardReleased(#PB_Key_All)
      key_lock = 0
    EndIf      
  Until key_lock = 0
  While leave_power_screen = 0
    
    ExamineKeyboard()
    
    ; check for windows events
    If preferences\fullscreen = 0
      main_window_event = WindowEvent()
      If main_window_event = #PB_Event_CloseWindow
        leave_power_screen = 1
        program_ends = 1
      EndIf
    EndIf
    
    ; ESC: leave power screen
    If KeyboardReleased(#PB_Key_Escape)
      leave_power_screen = 1
      esc = 1
    EndIf
    
    ; move cursor left
    If KeyboardPushed(#PB_Key_Left) And key_lock = 0 And power_selection\cursor\x > 0
      power_selection\cursor\x = power_selection\cursor\x - 1
      key_lock = 1
    EndIf
    
    ; move cursor right
    If KeyboardPushed(#PB_Key_Right) And key_lock = 0 And power_selection\cursor\x < 5
      power_selection\cursor\x = power_selection\cursor\x + 1
      key_lock = 1
    EndIf
    
    ; move cursor up
    If KeyboardPushed(#PB_Key_Up) And key_lock = 0 And power_selection\cursor\y > 0
      power_selection\cursor\y = power_selection\cursor\y - 1
      key_lock = 1
    EndIf
    
    ; move cursor down
    If KeyboardPushed(#PB_Key_Down) And key_lock = 0 And power_selection\cursor\y < 5
      power_selection\cursor\y = power_selection\cursor\y + 1
      key_lock = 1
    EndIf
    
    ; Return: select power
    If KeyboardReleased(#PB_Key_Return)
      leave_power_screen = 1
    EndIf
    
    ; release key lock if no key is pressed
    If KeyboardReleased(#PB_Key_All)
      key_lock = 0
    EndIf    
    
    ; update screen
    blink_cursor(@power_selection\cursor)
    use_power_screen(@power_selection)
    FlipBuffers()
    
  Wend
  
  ; pay power cost
  power_id = power_selection\selected_power_id
  cost = power_db(power_id)\cost
  cost_attribute = power_db(power_id)\cost_attribute
  If esc <> 1 And program_ends <> 1 And power_id > 0
    If power_db(power_id)\cost > 0
      If attribute_current_val(cost_attribute) < cost
        play_sound("failure")
        text$ = ReplaceString(message_list$(#MESSAGE_INSUFFICIENT_POWER_RESOURCE), "[attribute_name]", ability_db(cost_attribute)\name_display$)
        message(text$, message_list$(#MESSAGE_INSUFFICIENT_POWER_RESOURCE2), $ffffff, power_db(power_id)\tile, 2)
        esc = 1
      Else
         reduce_ability(cost_attribute, cost, 0)
      EndIf
    EndIf
  EndIf
  If esc <> 1 And program_ends <> 1 And power_id > 0
    If power_db(power_id)\cooldown > 0 And current_character\power[power_id]\cooldown > 0
      play_sound("failure")
      text$ = ReplaceString(message_list$(#MESSAGE_COOLDOWN_TOO_HIGH), "[cooldown]", Str(current_character\power[power_id]\cooldown))
      message(text$, "", $ffffff, power_db(power_id)\tile, 2)
      esc = 1
    EndIf
  EndIf
  
  ; select effect
  If esc <> 1 And program_ends <> 1 And power_id > 0
    use_power_effect(power_id)
    If power_db(power_id)\end_turn = 1
      rc = 1
    EndIf
  EndIf
  
  ProcedureReturn rc
EndProcedure
; IDE Options = PureBasic 4.30 (Windows - x86)
; CursorPosition = 1047
; FirstLine = 1027
; Folding = -----
; EnableXP
; CompileSourceDirectory
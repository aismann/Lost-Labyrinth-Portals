; Lost Labyrinth VI: Portals
; constants, global variables & structures declarations
; written in PureBasic 4.20 (http://www.purebasic.com)
; created:  08.10.2008 Frank Malota <malota@web.de>
; modified: 19.02.2009 Frank Malota <malota@web.de>
; modified: 13.02.2024 Peter Eismann

;- sprite constants
Enumeration
  #SPRITE_Characters
  #SPRITE_Frame
  #SPRITE_FADEOUT
  #SPRITE_FADEOUT_TOTAL
  #SPRITE_ABILITIES
  #SPRITE_SPLASH
  #SPRITE_MONSTER
  #SPRITE_MOUSEPOINTER
  #SPRITE_BLOOD
  #SPRITE_SCREENSHOT
  #SPRITE_POWERS
  #SPRITE_CURSOR
  #SPRITE_STARS
  #SPRITE_MISSILES
  #SPRITE_LIGHT1
  #SPRITE_LIGHT2
  #SPRITE_LIGHT3
  #SPRITE_LIGHT4
  #SPRITE_LIGHT5
  #SPRITE_LIGHT6
  #SPRITE_LIGHT7
  #SPRITE_ITEMS
  #SPRITE_FX
EndEnumeration

#SPRITE_FX_GREY_BOX = 0
#SPRITE_FX_CLOUD_RED = 1
#SPRITE_FX_CLOUD_GREEN = 2
#SPRITE_FX_CLOUD_BLUE = 3
#SPRITE_FX_BLOOD_SKULL = 4
#SPRITE_FX_MAGIC_SHIELD = 5
#SPRITE_FX_RAGE = 6
#SPRITE_FX_FIRE = 7
#SPRITE_FX_WIND = 8
#SPRITE_FX_CROSS = 9

#SPRITE_MISSILE_RED_BALL = 0
#SPRITE_MISSILE_BLUE_BALL = 1
#SPRITE_MISSILE_GREEN_BALL = 2
#SPRITE_MISSILE_PURPLE_BALL = 3
#SPRITE_MISSILE_LIGHTNING = 4
#SPRITE_MISSILE_BLUE_LIGHTNING = 5


;- screen borders
#EXPERIENCE_SCREEN_ABILITIES_LEFT_BORDER = 56
#EXPERIENCE_SCREEN_ABILITIES_TOP_BORDER = 52
#EXPERIENCE_SCREEN_ABILITIES_ON_SCREEN = 11


;- action constants
Enumeration
  #ACTION_TEST
  #ACTION_EXIT
  #ACTION_ESCAPE
  #ACTION_UP
  #ACTION_DOWN
  #ACTION_LEFT
  #ACTION_RIGHT
  #ACTION_RETURN
  #ACTION_END_TURN
  #MAX_NUMBER_OF_ACTIONS
EndEnumeration


;- power constants
#MAX_NUMBER_OF_POWERS = 255
#MAX_NUMBER_OF_POWER_REQUIREMENTS = 3


;- key bindings structure
Structure key_binding_struct
  name$ ; name of action
  keycode.l ; code of key
EndStructure


;- sound constants
#MAX_NUMBER_OF_SOUNDS = 30


;- font IDs
Enumeration
  #FONT_STANDARD
  #FONT_SMALL
  #FONT_HARRINGTON
  #FONT_ARIAL_NORMAL
  #FONT_VERDANA
  #FONT_VERDANA_BOLD
EndEnumeration


;- map constants
#MAP_DIMENSION_X = 50
#MAP_DIMENSION_Y = 50
#MAX_NUMBER_OF_TILE_TYPES = 500
#MAX_NUMBER_OF_ATTRIBUTES_MODIFIED_BY_TILE = 3


;- character constants
#MAX_NUMBER_OF_ABILITIES = 255
#MAX_NUMBER_OF_ATTRIBUTE_BONI = 10
#MAX_NUMBER_OF_ABILITY_CAPS = 3
#MAX_NUMBER_OF_ABILITY_REQUIREMENTS = 3
#MAX_NUMBER_OF_ABILITY_DISPLAYS = 5
#MAX_NUMBER_OF_ABILITY_ADJUSTMENTS = 5
#MAX_NUMBER_OF_ABILITY_STARTING_EQUIPMENT = 3


;- message IDs
#MESSAGE_NULL = 0
#MESSAGE_CHARACTER_INFO = 1
#MESSAGE_PRESS_RETURN_TO_LEAVE = 2
#MESSAGE_NOT_AVAILABLE = 3
#MESSAGE_CAPPED = 4
#MESSAGE_CURRENT_VALUE = 5
#MESSAGE_CAPPED_AT = 6
#MESSAGE_REQUIRED = 7
#MESSAGE_NEW_POWER = 8
#MESSAGE_YOU_GAIN_SOME_EXPERIENCE = 9
#MESSAGE_CHOOSE_STARTING_ABILITIES = 10
#MESSAGE_STRENGTH = 11
#MESSAGE_DURATION = 12
#MESSAGE_INVENTORY = 13
#MESSAGE_ITEMS = 14
#MESSAGE_AMOUNT = 15
#MESSAGE_WEIGHT = 16
#MESSAGE_POUND = 17
#MESSAGE_DROP = 18
#MESSAGE_CANCEL = 19
#MESSAGE_EQUIPMENT_LIMIT_REACHED = 20
#MESSAGE_PICKUP_ITEMS = 21
#MESSAGE_NO_ITEMS_TO_PICKUP = 22
#MESSAGE_PICKUP_AN_ITEM = 23
#MESSAGE_PICKUP_SOME_ITEMS = 24
#MESSAGE_LEVEL = 25
#MESSAGE_AN_ITEM_LIES_ON_THE_GROUND = 26
#MESSAGE_SOME_ITEMS_LIE_ON_THE_GROUND = 27
#MESSAGE_ENTER_DUNGEON = 28
#MESSAGE_MENU_SPLASH_NEW_GAME = 29
#MESSAGE_MENU_SPLASH_CONTINUE_GAME = 30
#MESSAGE_MENU_SPLASH_EXIT = 31
#MESSAGE_ITEM_MENU_UNEQUIP = 32
#MESSAGE_ITEM_MENU_EQUIP = 33
#MESSAGE_ITEM_MENU_DROP_ALL = 34
#MESSAGE_USE_A_POWER = 35
#MESSAGE_SUCCESS_CHANCE = 36
#MESSAGE_COST = 37
#MESSAGE_RANGE = 38
#MESSAGE_RANGE_SELF = 39
#MESSAGE_RANGE_TOUCH = 40
#MESSAGE_RANGE_SIGHT = 41
#MESSAGE_MONSTER_NOTICES_YOU = 42
#MESSAGE_YOU_SNEAK_UNNOTICED_BY = 43
#MESSAGE_YOU_WERE_KILLED_BY = 44
#MESSAGE_SUCCESSFUL_BACKSTAB = 45
#MESSAGE_INSUFFICIENT_POWER_RESOURCE = 46
#MESSAGE_INSUFFICIENT_POWER_RESOURCE2 = 47
#MESSAGE_COOLDOWN_TOO_HIGH = 48
#MESSAGE_COOLDOWN = 49
#MESSAGE_MONSTER_REGENERATES = 50
#MESSAGE_MONSTER_IS_IMMUNE_VS_POWER = 51
#MESSAGE_MONSTER_ALREADY_AFFECTED_BY_POWER = 52
#MESSAGE_MONSTER_HAS_RESISTED = 53
#MESSAGE_UNIDENTIFIED_ITEM = 54
#MAX_NUMBER_OF_MESSAGES = 55

;- menu constants
#MAX_NUMBER_OF_MENU_ENTRIES = 30


;- setting constants
#SETTING_MAP_SCREEN_SCROLLING_STEP = 2


;- monster constants
#MAX_NUMBER_OF_MONSTER_TYPES = 300
#MAX_NUMBER_OF_MONSTER_AFFLICTIONS = 5


;- key binding constants
Enumeration
  #KEY_UP
  #KEY_DOWN
  #KEY_LEFT
  #KEY_RIGHT
  #KEY_RETURN
EndEnumeration


;- item constants
#MAX_NUMBER_OF_ITEMS = 255
#MAX_NUMBER_OF_ITEM_ABILITY_BONI = 5
#TILE_ITEM_EQUIPPED = 47
#MAX_NUMBER_OF_ITEM_UNEQUIP_CLASSES = 5
#INVENTORY_ROWS = 6
#INVENTORY_COLUMNS = 6


;- splash screen menu entries
#MENU_SPLASH_NEW_GAME = "New Game"
#MENU_SPLASH_CONTINUE_GAME = "Continue Game"
#MENU_SPLASH_EXIT = "Exit"


;- item menu entries
#ITEM_MENU_USE = "Use"
#ITEM_MENU_DROP = "Drop"
#ITEM_MENU_DROP_ALL = "Drop all"
#ITEM_MENU_CANCEL = "Cancel"
#ITEM_MENU_EQUIP = "Equip"
#ITEM_MENU_UNEQUIP = "Unequip"


;- standard tile types (used in dungeons)
#TILE_STANDARD_GOLD = 9
#TILE_STANDARD_SANCTUM = 140
#TILE_STANDARD_NEXUS = 141


;- modify attribute by tile structure
; update; reset_tile_type_db(), load_tile_type_definition()
Structure modify_attribute_by_tile_struct
  attribute.w ; id of ability that is changed when character enters field
  attribute_name$ ; name of ability that is changed when character enters field
  amount.w ; amount of increase
  amount_randomized.b ; flag: 1=amount is randomized (default: 0)
  amount_reduced_by_ability.w ; ID of ability that reduces amount (default: 0)
  amount_reduced_by_ability_name$ ; name of ability that reduces amount (default: 0)
  replenish.b ; flag: 1=restore depleted attribute to max value (default: 0)
  trigger_hidden.b ; flag; 1=attribute modification are triggered even when tile is still hidden (e.g. traps) (default: 0)
  turn_ends.b ; flag; 1=current turn ends if modification is triggered (default: 0)
EndStructure


;- tile type database structure
; update; reset_tile_type_db(), load_tile_type_definition()
Structure tile_type_db_struct
  in_use.b ; flag: 0=tile type not in use, 1=tile type in use (default: 1)
  name$ ; name of tile type
  solid.b ; flag; 0=non-solid (can be passed through), 1=solid (blocks movement) (default: 0)
  blocks_flight.b ; flag; 1=tile blocks flying creatures (default: 0)
  transparent.b ; 0=non-transparent, 1=transparent (display background tile underneath)
  message$ ; message that gets displayed when character enters tile
  remove_after_entering.b ; flag; 1=tile is replaced by default tile after character enters
  sound$ ; name of sound played when entering field
  class$ ; name of class tile belongs to
  transforms_into.w ; ID of new tile this tile can be transformed into (default: 0)
  container.b ; number of items created when tile is transformed; items on this tile are not shown (default: 0)
  hidden.b ; flag; 1=tile is displayed as background until detected (default: 0)
  detection_message$ ; message displayed when hidden tile is detected
  detection_sound$ ; sound played when hidden tile is detected
  animation_enter$ ; animation displayed when entering
  modify_attribute.modify_attribute_by_tile_struct[#MAX_NUMBER_OF_ATTRIBUTES_MODIFIED_BY_TILE] ; modify attributes when entering tile
EndStructure


;- tileset structure
Structure tileset_struct
  name$ ; name of tileset
  image_filename$ ; filename of tileset
  image.i ; pointer to tileset image
  image_loaded.b ; flag: 1=tileset image already loaded
  sprite.i ; pointer to tileset sprite
  sprite_loaded.b ; flag: 1=tileset sprite already loaded
  rows.w ; number of tile rows in tileset
  columns.w ; number of tile columns in tileset
  definition_filename$ ; filename of tile type definition xml file
  tile_type_db.tile_type_db_struct[#MAX_NUMBER_OF_TILE_TYPES] ; tile type definition for this map
EndStructure


;- map event structure
Structure map_event_struct
  name$ ; name of event
  xp.b ; character gains experience when event is triggered
  triggered.b ; flag: 1=event has been triggered
EndStructure


;- preferences structure
; update: reset_preferences(), load_preferences(), save_preferences()
Structure preferences_struct
  fullscreen.b ; 0=windowed, 1=fullscreen
  message_delay.l ; number of milliseconds to display messages
  DDD_effects.b ; 0=3D effects disabled, 1=3D effects enabled
  fade_effect.b ; 0=no fade effect; 1=fade with TranslucentSprite; 2=fade with 3D effects
  inventory_smooth_scrolling.b ; 0=no smooth scrolling, 1=smooth scrolling
  language$ ; current language
EndStructure


;- ability attribute bonus structure
Structure attribute_bonus_struct
  attribute.w ; ID of attribute
  name$ ; name of attribute (optional)
  bonus.w ; bonus value
  displayed.b ; flag: 1=bonus is displayed in experience screen (default: 0)
EndStructure


;- ability caps structure
Structure ability_cap_struct
  ability.w ; ID of ability
  name$ ; name of attribute (optional)
  bonus.w ; bonus for ability cap (default: 0)
  multiplier.w ; multiplier for ability to determine cap (default: 1)
  divisor.w ; divisor for ability to determine cap (default: 1)
EndStructure


;- ability requiremenents structure
Structure ability_requirement_struct
  attribute.w ; ID of attribute
  name$ ; name of attribute (optional)
  value.w ; mininum attribute value
EndStructure


;- ability display structure
; update: reset_ability(), load_abilites_db()
Structure ability_display_struct
  type.b ; display type; 0:not used; 1=main screen status panel; 2=character info screen (default: 0)
  start_value.w ; attribute start value for ability display entry
  end_value.w ; attribute end value for ability display entry
  message$ ; text for display / status message
  message2$ ; second text line for display / status message
  color.l ; color for display / status message (default: $ffffff)
  expanded_value_display.b ; flag; 1=attribute is displayed in expanded/formatted view (default: 0)
EndStructure


;- ability attribute adjustments (adjusts other attributes if attribute > 0)
; update: reset_ability(), load_abilities_db(), ability_db_resolve_names()
Structure ability_attribute_adjustment_struct
  attribute.w ; ID of attribute adjusted
  attribute_name$ ; name of attribute adjusted
  value.w ; absolute value of adjustment (default: 0)
  percentage.w ; percentage value of adjustment (default: 100)
  percentage_attribute_multiplier.b ; this attribute is used to determine percentage for adjustment (default: 0)
  percentage_bonus.w ; bonus added to determine percentage based on attribute (default: 0)
EndStructure


;- additional starting equipment due to chosen abilities
; update: reset_ability(), load_abilites_db(), character_gets_starting_equipment(), ability_db_resolve_names()
Structure ability_starting_equipment_struct
  item.w ; ID of item
  item_name$ ; name of the item (for reference by name)
  amount.w ; amount of item (default: 1)
EndStructure


;- abilities database structure
; update: reset_ability(), load_abilities_db(), ability_db_resolve_names()
Structure ability_db_struct
  name$ ; name of ability
  name_display$ ; name of ability used for display (translations)
  description$ ; short description of ability
  tile.w ; tile ID of ability image
  color.l ; RGB color code of ability (default: $ffffff = white)
  attribute.b ; flag; 1=ability is also an attribute (default: 0)
  depletable.b ; flag: 1=attribute depletable (default: 0)
  percentage.b ; flag: 1=attribute displayed as percentage (default: 0)
  displayed_as_bonus.b ; flag: 1=attribute is displayed as bonus (default: 0)
  randomizer_ability.w ; ID of ability used as randomizer bonus value (default: 0)
  randomizer_ability_name$ ; name of ability used as randomizer bonus value
  main_screen.b ; flag: 1=attribute is displayed on main screen (default: 0)
  attribute_start_value.w ; start value of ability at character creation (default: 0)
  xp.b ; flag: 1=ability can be increased by experience (default: 0)
  game_ends.b ; 1=game ends if attribute is lower, 2=higher than value (default: 0)
  game_ends_val.w ; value for attribute to reach for the game to end
  game_ends_message$ ; message displayed if game ends due to this attribute
  not_shown_if_zero.b ; flag: 1=attribute is not displayed in info screen if value=zero (default: 0)
  minimum.w ; minimum value; if set to -1, there is no minimum (default: -1)
  change_per_turn_chance.b ; percentage of chance that attribute changes at the end of each turn (default: 0)
  change_per_turn.w ; amount of which attribute changes at the end of each turn (default: 0)
  change_per_move.w ; amount of which attribute changes at every move (default: 0)
  turn_ends_if_lower.w ; if attribute is lower than this value => current turn ends (default: -32000)
  restore_at_end_of_turn.b ; flag; 1=attribute is restored at the end of a turn (default: 0)
  attack_melee.b ; flag; 1=attribute is used for melee attacks (default: 0)
  critical_hit_melee.b ; flag; 1=attribute causes critical hits in melee combat (default: 0)
  defense_melee.b ; flag; 1=attribute provides defense in melee combat (default: 0)
  damage_in_melee.b ; flag; 1=attribute provides damage in melee combat (default: 0)
  modify_with_each_kill.w ; attribute is modified by this value each time the characters kills a monster (default: 0)
  lightradius.b ; flag; 1=attribute increases light radius (default: 0)
  modify_per_point_of_damage.b ; value this attribute is modified per each point of damage the character takes (default: 0)
  hit_multiplier.w ; value by wich this attribute gets modified with each successful hit in melee combat (default: 0)
  hit_attribute.w ; ID of attribute used as multiplier to determine the amount this attribute gets modified with each successful melee combat hit
  hit_attribute_name$ ; name of attribute used as multiplier to determine the amount this attribute gets modified with each successful melee combat hit
  sneaking.b ; flag; 1=attribute is used for sneaking (default: 0)
  backstab.b ; flag; 1=attribbute is used for backstabbing (default: 0)
  perception_tile_class$ ; name of hidden tile class attribute is used to detect; "all" is used for all tileset classes
  modify_attribute.w ; ID of attribute modified by this ability every turn
  modify_attribute_name$ ; name of attribute modified by this ability every turn
  modify_multiplier.w ; multiplier applied to this attribute before modified is determined
  modify_divisor.w ; divisor applied to this attribute before modifier is determined
  modify_animation$ ; animation displayed when attribute gets modified
  modify_sound$ ; sound played when attribute gets modified
  armor.b ; flag; 1=attribute provides armor protection (default: 0)
  movement.b ; flag; 1=attribute is used for movement (default: 0)
  buffer_for_attribute.w ; ID of attribute this attribute is used as buffer for (default: 0)
  buffer_for_attribute_name$ ; name of attribute this attribute is used as buffer for
  buffer_animation$ ; name of animation displayed when buffer gets activated (default: "")
  attribute_bonus.attribute_bonus_struct[#MAX_NUMBER_OF_ATTRIBUTE_BONI] ; attribute boni
  ability_cap.ability_cap_struct[#MAX_NUMBER_OF_ABILITY_CAPS] ; ability caps
  ability_requirement.ability_requirement_struct[#MAX_NUMBER_OF_ABILITY_REQUIREMENTS] ; ability requirements
  display.ability_display_struct[#MAX_NUMBER_OF_ABILITY_DISPLAYS] ; ability displays
  adjustment.ability_attribute_adjustment_struct[#MAX_NUMBER_OF_ABILITY_ADJUSTMENTS] ; attribute adjustments
  starting_equipment.ability_starting_equipment_struct[#MAX_NUMBER_OF_ABILITY_STARTING_EQUIPMENT] ; additional starting equipment due to abilities
EndStructure


;- abilities structure
; update: init_character(), load_character(), save_character()
Structure ability_struct
  ability_value.w ; value of ability
  attribute_max_value.w ; max value of attribute
  attribute_current_value.w ; current value of ability
  power_adjustment.w ; adjustment of attribute due to a power
  adjustment_duration.w ; duration of adjustment in turns
  adjustment_name$ ; name of adjustment effect
  adjustment_power_id.w ; ID of power that triggered adjustment
  adjustment_item_id.w ; ID of item that triggered adjustment
  item_bonus.w ; attribute bonus from items
  activated.b ; flag; 1=ability is activated (applies only to some abilites like sneaking; default: 0)
  adjustment_other.w ; adjustment from other abilities (default: 0)
  adjustment_percentage.w ; adjustment in percentage from other abilities (default: 100)
EndStructure


;- map field structure
; update: reset_map(), load_map(), save_map()
Structure mapfield_struct
  tile_type.w ; ID of tile image
  portal_mapfile.s ; filename of map portal leads to
  portal_x.b ; target x of portal
  portal_y.b ; target y of portal
  message_line1$ ; message displayed when entering/pushing field; first line
  message_line2$ ; message displayed when entering/pushing field; second line
  message_tile.w ; ID of tile image displayed with message
  event$ ; name of map event triggered by this field
  event_xp.b ; flag: 1=event causes character to gain experience (default:0)
  power_used$ ; string list of powers already used on this field (default: "")
  hidden.b ; flag; 1=field is displayed as background tile (default: 0)
  visited.b ; flag; 1=character has been adjacent to this field (default: 0)
EndStructure


;- map structure
Structure map_struct
  name.s ; name of map
  filename$ ; filename of map
  tileset.tileset_struct ; tileset used in map
  mapfield.mapfield_struct[#MAP_DIMENSION_X*#MAP_DIMENSION_Y] ; map tiles
  tile_outside_map.w ; ID of tile used to display outside of map dimensions
  default_tile.w ; ID of tile used as default map tile
  background_tile.w ; ID of tile image used as background for transparent tiles
  spawn_monster_level.w ; level of monsters spawn on map (0=no new monsters are spawn)
  spawn_monster_chance.w ; percentage of chance that a random new monster is spawn each turn
  visited.b ; flag: 1=character has already visited map (default: 0)
  lighting.b ; default lighting of map (from 0=no light to 8=full light; default: 0)
EndStructure


;- map transformation structure
Structure map_transformation_struct
  event$ ; name of event that triggers this transformation
  x.b ; x position of transformation field
  y.b ; y position of transformation field
  new_field.mapfield_struct ; new field transformation field transforms to
  triggered.b ; flag; 1=transformation has already been triggered
EndStructure


;- message structure
Structure message_struct
  color.l ; RGB color in which to display message
  line1$ ; first line of text
  line2$ ; second line of text
  tile.w ; tile image for message
  tile_type.b ; tile type (0=map tileset, 1=item tileset, 2=power tileset, 3=monster tileset, 4=abilities tileset)
  start_time.l ; start of timer for message (in milliseconds)
  display_for.l ; number of milliseconds to display message
EndStructure


;- menu entry structure
Structure menu_entry_struct
  name$ ; name of entry
EndStructure


;- menu structure
Structure menu_struct
  x.w ; x position of menu on screen
  y.w ; y position of menu on screen
  width.w ; menu width in pixel
  entry_height.w ; height of a single menu entry in pixel
  padding.w ; padding of menu entry text
  spacing.w ; spacing between menu entries
  selected_entry.b ; currently selected menu entry
  number_of_entries.w ; number of entries in menu
  color.l ; color of menu
  use_mouse.b ; flag: 1=entries can be selected via mouse
  mouse_x.w ; x pos of mouse pointer
  mouse_y.w ; y pos of mouse pointer
  mouse_over_entry.w ; index of menu entry mouse pointer is hovering over
  menu_entry.menu_entry_struct[#MAX_NUMBER_OF_MENU_ENTRIES]
  menu_open.b ; flag: 0=menu is not displayed, 1=menu is displayed (default: 1)
  border.b ; pixel width of border for menu
  entry_border.b ; pixel width of border for menu entries
  font.w ; font used for menu; 0=system font (default: 0)
  entry_highlight.b ; flag; 1=highlight selected entry
  entry_highlight_color1.l ; first color for highlight
  entry_highlight_color2.l ; second color for highlight
EndStructure


;- monster afflictions
; update; reset_monster_type()
Structure  monster_affliction_struct
  class$ ; class of affliction
  chance.b ; success chance for monster to provide affliction to character
  attribute.w ; ID of attribute that gets modified
  attribute_name$ ; name of attribute that gets modified
  value.w ; value of modification
  randomized.b ; flag: 1=value gets randomized (default: 0)
  animation$ ; animation displayed when character gets affliction
  sound$ ; sound played when character gets affliction
  message$ ; message displayed when character gets affliction
EndStructure


;- monster type db structure
; update: reset_monster_db(), load_monster_db()
Structure monster_type_db_struct
  name$ ; name of monster
  class$ ; class of monster
  tile.w ; tile number of monster image
  attack.w ; attack value of monster (in percent)
  defense.w ; defense value of monster (in percent)
  strength.w ; strength value of monster => determines damage in combat
  hitpoints.w ; number of hitpoints of monster
  armor.w ; armor of monster => reduces damage the monster takes
  level.w ; level of monster
  speed.b ; number of tiles monster moves each round if alerted (default: 0)
  flying.b ; flag; 1=monster is flying and ignores obstacles when moving (default: 0)
  regeneration.b ; number of hitpoints monster regenerates per turn
  resistance_class$ ; string list of classes the monster is resistant to (half damage)
  immune_class$ ; string list of classes the monster is immune to
  vulnerable_class$ ; string list of classes the monster is vulnerable to (double damage)
  affliction.monster_affliction_struct[#MAX_NUMBER_OF_MONSTER_AFFLICTIONS] ; afflictions
EndStructure


;- monster structure
; update: add_monster(), place_random_monster(), spawn_random_monster(), load_map(), save_map()
Structure monster_struct
  type.w ; type of monster => monster type db
  xpos.w ; x position in current map
  ypos.w ; y position in current map
  hitpoints.w ; current hitpoints of monster
  alerted.b ; flag: 1=monster is alerted, sneaking no longer possible (default: 0)
  x_offset.b ; x offset in pixel for display (used for movement)
  y_offset.b ; y offset in pixel for display (used for movement & attack)
  selected.b ; flag; 1=monster selected for special effects
  effect$ ; string list of effects that are applied to monster (default: "")
EndStructure


;- sound structure
Structure sound_struct
  filename$ ; filename of sound file
  sound.i ; pointer to sound effect
EndStructure


;- cursor structure
Structure cursor_struct
  x.w ; x position of cursor
  y.w ; y position of cursor
  frame.b ; current blink frame of cursor
  dir.b ; blink direction of cursor
  esc.b ; flag: 1=escape has been pressed, no selection has been made (default: 0)
EndStructure


;- power requirement structure
Structure power_requirement_struct
  attribute.w ; ID of attribute for requirement
  attribute_name$ ; name of attribute for requirement
  value.w ; mininum value of attribute
EndStructure


;- power db structure
; update: reset_power(), load_power_db(), powers_db_resolve_names()
Structure power_db_struct
  name$ ; name of power
  description$ ; description of the power
  tile.w ; ID of image tile used for power
  effect.w ; ID of power effect
  effect_name$ ; name of power effect
  effect_strength.w ; strength of effect (default: 0)
  strength_bonus_attribute.w ; ID of attribute that provides bonus to effect strength (default: 0)
  strength_bonus_attribute_name$ ; name of attribute that provides bonus to effect strength (default: "")
  strength_multiplier.w ; multiplier applied to attribute to determine effect strength (default: 1)
  strength_divisor.w ; divisor applied to attribute to determine effect strength (default: 1)
  strength_randomized.b ; flag: 1=strength amount provided by attribute is randomized (default: 0)
  randomized_strength_bonus.w ; random part of effect strength (default: 0)
  randomized_strength_bonus_attribute.w ; ID of attribute that provides randomized bonus to effect strength (default: 0)
  randomized_strength_bonus_attribute_name$ ; name of attribute that provides randomized bonus to effect strength (default: "")
  randomized_strength_multiplier.w ; multiplier applied to attribute to determine randomized effect strength (default: 1)
  randomized_strength_divisor.w ; divisor applied to attribute to determine randomized effect strength (default: 1)
  success_attribute.w ; ID of attribute that provides success chance of power
  success_attribute_name$ ; name of attribute that provides success chance of power
  success_attribute_multiplier.b ; multiplier applied to attribute to determine power success chance
  success_attribute_divisor.b ; divisor applied to attribute to determine power sucess chance
  success_bonus.w ; bonus to power success chance
  success_message$ ; message displayed if power is used successfully
  failure_message$ ; message displayed if power is used unsuccessfully
  wrong_use_message$ ; message displayed if power is used wrong
  already_used_message$ ; message displayed if power has already been used
  animation$ ; name of animation for power
  end_turn.b ; flag: 1=use of power ends turn (default: 0)
  sound$ ; name of sound file played when power is successfully used
  failure_sound$ ; name of sound file played when power is used unsuccessfully
  wrong_use_sound$ ; name of sound file played when power is used wrongly
  cost.w ; attibute depletion cost to use power
  cost_attribute.w ; ID of attibute to deplete
  cost_attribute_name$ ; name of attribute to deplete
  class$ ; name of power class
  range.b ; range of power (0=self, 1=touch/1 field, 2=sight)
  modify_attribute.w ; ID of attribute to increase with power use
  modify_attribute_name$ ; name of  attribute to increase with power use
  adjust_attribute.w ; ID of attribute to adjust with power
  adjust_attribute_name$ ; name of attribute to adjust with power
  duration.w ; duration of adjustment in turns
  duration_bonus_attribute.w ; ID of attribute that provides bonus to duration
  duration_bonus_attribute_name$ ; name of attribute that provides bonus to duration
  duration_multiplier.w ; multiplier applied to attribute to determine duration
  duration_divisor.w ; divisor applied to attribute to determine duration
  activates_ability_id.w ; ID of ability that is activated with this power (default: 0)
  activates_ability_name$ ; name of ability that is activated with this power
  deplete_attribute_id.w ; ID of attribute that gets depleted with this power
  deplete_attribute_name$ ; name of attribute that gets depleted with this power
  cooldown.w ; number of turns to pass until power can be used again (default: 0)
  affects_only_monster_class$ ; string list of monster classes that are affected exclusively by this power (default: "")
  monster_effect$ ; name of effect that is applied to a monster by this power
  field_effect$ ; name of effect that is applied to a field by this power
  power_requirement.power_requirement_struct[#MAX_NUMBER_OF_POWER_REQUIREMENTS]
EndStructure


;- character power structure
; update: init_character(), save_character(), load_character()
Structure char_power_struct
  cooldown.w ; cooldown of power in turns
EndStructure


;- power selection structure
Structure power_selection_struct
  selected_power.w ; currently selected power
  selected_power_id.w ; ID of currently selected power
  cursor.cursor_struct ; cursor for power selection
EndStructure


;- star sprite structure
Structure star_sprites_struct
  x.w ; x position on screen (in pixel)
  y.w ; y position on screen (in pixel)
  frame.b ; current frame of star sprite
  dir.b ; direction of frame animation
  color.b ; color of sprite
  delay.b ; delay of appearance
EndStructure


;- item bonus structure
; used in: reset_item_db(), load_item_db()
Structure item_bonus_struct
  attribute.w ; ID of attribute the item gies a bonus to
  attribute_name$ ; name of attribute the item gives a bonus to
  value.w ; bonus value
  magic_bonus_multiplier.b ; multiplier for magic bonus if item is an artifact (default: 0)
  randomized.b ; flag; 1=bonus is randomized (default: 0)
  randomized_bonus.w ; bonus added to randomized value (default: 0)
  duration.w ; duration in turns (default: 0 => bonus is unlimited)
EndStructure


;- item database structure
; used in: reset_item_db(), load_item_db()
Structure item_db_struct
  name$ ; name of item
  tile.w ; tile ID of item
  tile_equipped.w ; tile ID of item when equipped (default: => tile)
  weight.w ; weight of item in ounces
  starting_equipment.w ; character gets this amount of items at the start of the game (default: 0)
  class$ ;  item class
  class_name$ ; item class used for display (translated)
  description$ ; item description
  can_be_equipped.b ; flag: 1=item can be equipped (default: 0)
  price.w ; price of item in gold
  fuel.w ; fuel capacity (when completely filled)
  fuel_consumed_per_turn.b ; number of fuel units consumed per turn when item is equipped
  fuel_consumed_per_use.w ; number of fuel units consumed with each use of item (default: 0)
  fuel_randomized.b ; flag; 1=amount of fuel is randomized upon item creation (default: 0)
  fuel_name$ ; name of fuel item description
  use_name$ ; name of "Use item" action
  use_animation$ ; animation displayed when item is used (default: "")
  consumed_after_use.b ; flag; if set, item is removed after being used (default: 0)
  turn_ends_after_use.b ; flag; if set, the current turn ends after the item was used (default: 0)
  use_message$ ; message displayed after item is used
  artefact.b ; flag; 1=item is a magic artefact (default: 0)
  equipment_limit.w ; max. number of items of this class that can be equipped at the same time (default: 0 = no limit)
  identified.b ; flag; 1=item type is identified (default: 0)
  identified_when_used.b ; flag; 1=item type gets identified when used (default: 0)
  power_id.w ; ID of power triggered when item is used (default: 0 => no power)
  power_name$ ; name of power triggered when item is used (default: "" => no power)
  ability_bonus.item_bonus_struct[#MAX_NUMBER_OF_ITEM_ABILITY_BONI] ; ability boni from items
  unequip_item_class$[#MAX_NUMBER_OF_ITEM_UNEQUIP_CLASSES] ; name of classes unequipped when item is equipped
EndStructure


;- item in inventory structure
; update: open_inventory(), pickup_items(), add_random_item(), load_character(), save_character()
Structure item_in_inventory_struct
  type.w ; type of item
  amount.w ; amount of item (default: 1)
  fuel.w ; fuel units left (default: 0)
  equipped.b ; flag; 1=item is equipped by character (default: 0)
  selected.b ; flag: 1=item is currently selected in inventory (default: 0)
  magic_bonus.w ; magic bonus of item (only artefacts; default: 0)
EndStructure


;- item tile list structure (used for scrambling item tiles)
; update: scrambe_item_db_tiles()
Structure item_tile_list_struct
  item.w ; ID of item
  tile.w ; ID of tile
EndStructure


;- item on map structure
; update: open_inventory(), pickup_items(), add_random_item()
Structure item_on_map_struct
  xpos.w ; x position on map
  ypos.w ; y position on map
  type.w ; type of item
  amount.w ; amount of items (default: 1)
  fuel.w ; fuel units left (default: 0)
  selected.b ; flag: item selected in pickup items screen (default: 0)
  selected_for_pickup.b ; flag: item selected for pickup in pickup items screen (default: 0)
  magic_bonus.w ; magic bonus of item (only artefacts; default: 0)
EndStructure


;- item identification structure
; update: init_character(), load_character(), save_character()
Structure item_identification_struct
  identified.b ; flag; 1=item type identified (default: 0)
EndStructure


;- character structure
Structure char_struct
  name$ ; name of character
  xpos.b ; x position in current map
  ypos.b ; y position in current map
  facing.b ; facing of character sprite (0=up, 1=right, 2=down, 3=left)
  frame.b ; current frame of character sprite (0 or 1)
  map_filename$ ; filename of map the character is currently on
  inventory_cursor_x.b ; x position of cursor in inventory
  inventory_cursor_y.b ; y position of cursor in inventory
  ability.ability_struct[#MAX_NUMBER_OF_ABILITIES] ; abilites of character
  power.char_power_struct[#MAX_NUMBER_OF_POWERS] ; character powers
  item_identification.item_identification_struct[#MAX_NUMBER_OF_ITEMS] ; item identification
  game_end_message$ ; message displayed when game ends
EndStructure


;- dungeon tunnel structure
Structure dungeon_tunnel_struct
  start_xpos.w ; x position for start of tunnel
  start_ypos.w ; y position for start of tunnel
  end_xpos.w ; x position for end of tunnel
  end_ypos.w ; y position for end of tunnel
  length.w ; length of tunnel in number of tiles
  minimum_length.w ; minimum length for tunnel
  first_tunnel.b ; flag; 1=first dungeon tunnel, not connected to others (default: 0) 
EndStructure


;- dungeon structure
; used in procedures: enter_dungeon, load_map, save_map, create_dungeon_level
Structure dungeon_struct
  xpos.w ; x position of dungeon on map
  ypos.w ; y position of dungeon on map
  name$ ; name of dungeon
  map_filename$ ; filename use for dungeon map files
  number_of_levels.w ; number of levels in dungeon
  dimension_x.b ; x dimension used for dungeon maps
  dimension_y.b ; y dimension used for dungeon maps
  entrance_to_level.w ; next level
  difficulty_level.w ; difficulty of dungeon (default: 0)
  lighting.b ; lighting level (default: 0)
  default_tile.w ; default tile used for maps (usually a wall)
  background_tile.w ; background tile used for maps (usually a floor)
  tile_outside_map.w ; tile displayed outside of map (usually a wall)
  main_treasure.w ; item ID of main treasure found at the bottom of the dungeon (default: 0 => random treasure)
  bottom_portal$ ; name of map the portal at the bottom of the dungeon leads to (default: "" => no portal)
  bottom_portal_target_x.w ; x position for portal target
  bottom_portal_target_y.w ; y position for portal target
  bottom_portal_tile.w ; tile used for portal at the bottom of the dungeon
  traps_per_level.w ; number of traps placed per level
EndStructure


; tile list structure
Structure tile_list_struct
  x.w ; x position of tile on screen
  y.w ; y position of tile on screen
  tile.w ; tile nr
  type.b ; type of tile; 0=tileset, 1=ability, 2=power, 3=monster
EndStructure


; coordinates structure
Structure coordinates_struct
  x.w ; x position
  y.w ; y position
EndStructure


;- global variables 
Global version_number$="0.3.1"
Global program_title$ = "Lost Labyrinth: Portals " + version_number$
Global resources_pak_file$ = "resources.pak" ; name of the pack file that countains all resources (images & sounds)
Global current_character.char_struct ; data for current character
Global current_map.map_struct ; data for current map
Global preferences.preferences_struct ; current preferences
Global Dim tile_type_db.tile_type_db_struct(#MAX_NUMBER_OF_TILE_TYPES) ; tile type definition database
Global message.message_struct ; message 
Global map_filename$ = "" ; name of current map file
Global tileset.tileset_struct ; currently used tileset
Global NewList map_event.map_event_struct() ; linked list of all map events for current map
Global NewList map_transformation.map_transformation_struct() ; linked list of all map transformations for current map
Global Dim ability_db.ability_db_struct(#MAX_NUMBER_OF_ABILITIES) ; abilities db
Global program_ends.b = 0 ; flag: 1=program ends immediately (default: 0)
Global menu.menu_struct ; menu
Global Dim monster_type_db.monster_type_db_struct(#MAX_NUMBER_OF_MONSTER_TYPES) ; monster type db
Global NewList monster.monster_struct() ; linked list of monsters
Global monster_tiles_rows.w, monster_tiles_columns.w ; rows & columns in monster tile image
Global Dim sound.sound_struct(#MAX_NUMBER_OF_SOUNDS) ; list of all sounds
Global Dim key_binding.key_binding_struct(#MAX_NUMBER_OF_ACTIONS) ; key bindings
Global Dim power_db.power_db_struct(#MAX_NUMBER_OF_POWERS) ; power database
Global cursor_frame.b ; current cursor frame
Global cursor_frame_dir.b ; blink direction of cursor
Global ability_tiles_rows.b, ability_tiles_columns.b ; rows & colums in ability tile image
Global power_tiles_rows.b, power_tiles_columns.b ; rows & colums in power tile image
Global missile_tiles_rows.b, missile_tiles_columns.b ; rows & columns in missile tiles image
Global item_tiles_rows.b, item_tiles_columns.b ; rows & columns in item tiles image
Global fx_tiles_rows.b, fx_tiles_columns.b ; rows & columns in fx tiles image
Global NewList inventory.item_in_inventory_struct() ; character inventory
Global Dim item_db.item_db_struct(#MAX_NUMBER_OF_ITEMS) ; item database
Global NewList item_on_map.item_on_map_struct() ; items on current map
Global NewList dungeon_on_map.dungeon_struct() ; dungeons on current map
Global Dim message_list$(#MAX_NUMBER_OF_MESSAGES); list of messages (for foreign languages)
Global isSoundSupported.b = #True                ; InitSound() works/fails

Global startLastPoint = true ; false = delete saved game

; IDE Options = PureBasic 6.10 beta 6 (Windows - x64)
; CursorPosition = 5
; EnableXP
; DPIAware
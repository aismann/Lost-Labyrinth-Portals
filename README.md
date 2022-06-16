[![Version](https://img.shields.io/badge/3.0.alpha1-brightgreen.svg)](https://github.com/aismann/Lost-Labyrinth-Portals/pulls)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-blue.svg)](https://github.com/aismann/Lost-Labyrinth-Portals/pulls)

[![Windows 32bit Build Status](https://img.shields.io/badge/Windows32-passed-green.svg)](https://github.com/aismann/Lost-Labyrinth-Portals/pulls)
[![Windows 64bit Build Status](https://img.shields.io/badge/Windows64-passed-green.svg)](https://github.com/aismann/Lost-Labyrinth-Portals/pulls)
[![Linux Build Status](https://img.shields.io/badge/Linux-untested-orange.svg)](https://github.com/aismann/Lost-Labyrinth-Portals/pulls)
[![macOS Build Status](https://img.shields.io/badge/macOS-untested-orange.svg)](https://github.com/aismann/Lost-Labyrinth-Portals/pulls)
[![Android Build Status](https://img.shields.io/badge/Android-unsupported-red.svg)](https://github.com/aismann/Lost-Labyrinth-Portals/pulls)
[![iPhone Build Status](https://img.shields.io/badge/iPhone-unsupported-red.svg)](https://github.com/aismann/Lost-Labyrinth-Portals/pulls)

# Lost-Labyrinth-Portals 3.0 (PureBasic 6.00)
'Lost Labyrinth Portals' is a coffee-break roguelike game written in Purebasic.

### Game mechanics
The game can be controlled with keyboard. The focus is not on defeating monsters, but on reaching new levels. 
At the beginning of the game, the character's abilities can be freely chosen, so there are no fixed character classes. 
Each character has its own tactics. Unlike other Nethack successors, a game in Lost Labyrinth lasts relatively short, and the fun lies in trying out different combinations of abilities, not in leading a character to the end of the game.

### Keys
- UP/DOWN/LEFT/RIGHT: Player & Menue management
- LEFT-ALT-ENTER: toggle between windowed screen and fullscreen
- C: Character info
- U: Use power
- P: Pickup items
- I: open Inventory
- E: End turn
- T: Trigger test
- RETURN: Remove game paused status
- F1: Mouse and keyboard released

Game features: 
* Nice graphics; smooth scrolling 
* randomly generated dungeons 
* a large skill tree (including spells and special powers) 
* character gains experience by reaching new dungeon levels, not by killing monsters 
* all game data (maps, character abilities, powers, spells, monsters, items) is stored in external XML files and can be modified without changing the code 
* graphical map editor for easy creation of user-made maps; individual tilesets possible for each map 
* available in several languages (currently: English and German); language can be changed in mid-game; new languages can be added by expanding the XML files 
* new skills, powers and spells can be unlocked by reaching milestones (not yet implemented) 
* online highscore list (not yet implemented)

The game is currently in an Alpha stage. 
The game will be available for Windows, Linux and Mac OS.


### History:
'Lost Labyrinth Portals' 3.0
- Adapt 2.0 to PureBasic 6.0

'Lost Labyrinth Portals' 2.0 
- Written by Frank.Malota (PureBasic 4.30) : https://www.findbestopensource.com/product/lost-labyrinth-portals

### Lost Labyrinth
* Lost Labyrinth written by Frank Dobele (PureBasic): http://www.lostlabyrinth.com 
* Lost Labyrinth written by Frank.Malota(Blitz Basic): http://laby.toybox.de  (link no longer works)

### Lost Labyrinth DX 
- Lost Labyrinth DX created by Johan Jansen (C++/SDL2): https://www.labydx.com/

### 'Lost Labyrinth' past history (short):
The game was first programmed in 1991 on the Atari ST with STOS BASIC by Frank Malota. At that time the graphics had a size of 16×16 dots and 16 colors. Scrolling was still blockwise at that time. A version in C++ followed, but it was never really playable. 

Later the whole game was rewritten from scratch with Blitz Basic. This version already had clean pixel-by-pixel scrolling, and the graphics were 32×32 pixels with 256 colors.

The PureBasic version was written by Frank Dobele mainly to make the game run on Linux. It now also runs cleanly under Windows and has surpassed the original in most respects.

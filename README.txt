================================================================================
  DETROIT: BECOME HUMAN  -  VR MOD
================================================================================

  Play Detroit: Become Human on a VR headset with 6DOF head tracking.
  Cutscenes play on a large flat screen, and the game's flat interface is
  fitted into the part of the view the lenses actually show.


WORK IN PROGRESS - NOT FINISHED
-------------------------------
  This is an unfinished, work-in-progress VR mod. It is not a polished
  release. It is shared so people can play with it and help improve it.


WHAT YOU NEED
-------------
  * Detroit: Become Human on PC (Steam, Vulkan) - your own copy of the game.
  * A VR headset with SteamVR. Tested on PSVR2 at 90 Hz. The mod uses OpenXR
    and finds SteamVR's loader by itself, so there is nothing else to install.
  * Optional: the ViGEmBus driver, only for PlayStation button prompts and
    DualShock motion/touchpad. Everything else works fine without it.


HOW TO INSTALL
--------------
  1. Find your Detroit game folder - the one that contains
     DetroitBecomeHuman.exe.
     In Steam: right-click the game > Manage > Browse local files.

  2. Copy this whole DETROIT_VR_MOD folder INTO that game folder, so you end
     up with:
         ...\Detroit Become Human\DETROIT_VR_MOD\

  3. Start SteamVR, put the headset on, and check that it is tracking.

  4. Open the DETROIT_VR_MOD folder and run:
         Play Detroit in VR.cmd

  5. Press a key when it asks. The game starts in your headset.

  A "Detroit VR" shortcut is placed on your desktop, so next time you can just
  use that.

  Nothing in the game is replaced or patched. The mod starts the game and
  injects itself. The only file it edits is GraphicOptions.JSON, to raise the
  frame rate cap, and your original is backed up first.

  FIRST LAUNCH IS SLOW. Detroit builds its shader cache the first time it
  runs, which can take many minutes, and levels may stutter for a while
  afterwards. This happens once.

  NEVER RUN DETROIT BEFORE? Then the frame cap cannot be set yet. Play once,
  quit the game, and it is applied as you exit - active from the next launch.


CONTROLS
--------
  F6                     recenter your view (the game window must be focused)
  both sticks pressed    open the VR settings panel inside the headset

  Play with a gamepad, keyboard, or the VR controllers.

  Settings live in  profiles\vr_panel_settings.txt , each with a comment
  explaining it. The panel saves its own changes immediately; edits you make
  by hand apply the next time the game starts.


UNINSTALL
---------
  Run  Uninstall VR mod.cmd

  It restores your original GraphicOptions.JSON, removes the desktop shortcut
  and deletes this folder. Your saves are never touched.


IF SOMETHING GOES WRONG
-----------------------
  There is no log by default. To capture one, create an empty file named
      profiles\debug_log.flag
  and play again; detroit_vr_debug.log then appears next to this file. Delete
  the flag afterwards - the log grows large.

  If the game crashes, an anonymous report is written to
  crash_reports\crash_<date>.txt (PC, headset and GPU details, no personal
  data). Send that along with a description of what happened.


LICENSE
-------
  MIT - see the LICENSE file.

  Fork it, fix it, build your own version and publish it; the only condition
  is that the copyright notice stays with it. Improvements are very welcome.

  The licence covers this mod's own code only. It grants no rights to
  Detroit: Become Human or anything else Quantic Dream or Sony owns, and the
  mod ships no game files.

================================================================================

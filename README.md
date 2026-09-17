# Detroit: Become Human — VR Mod

Play **Detroit: Become Human** on a VR headset with 6DOF head tracking.
Cutscenes play on a large flat screen, and the game's flat interface is fitted
into the part of the view the lenses actually show.

> ### ⚠️ Work in progress — not finished
> This is an unfinished, work-in-progress VR mod. It is not a polished release.
> It is shared so people can play with it and help improve it.

---

## Supported game versions

Every release below is recognised by name, and the mod uses addresses recorded
for that exact build:

| Release | Store | Build | Recognised as |
|---|---|---|---|
| Detroit: Become Human | Steam | v09.10.2023 | `retail Steam, v09.10.2023` |
| Detroit: Become Human Demo | Steam | 2021-10-25 | `Steam demo, 2021-10-25` |
| Detroit: Become Human | Epic Games | v09.10.2023 | `Epic, v09.10.2023` |
| Detroit: Become Human Demo | Epic Games | 2021-10-25 | `Epic demo, 2021-10-25` |

The four are genuinely different files, not one build behind four storefronts.
The mod identifies yours by its SHA-256 and says which it found in the log.

**Another build, or an updated one?** It still works. The addresses are also
recorded as byte signatures, and anything unrecognised is found by searching
for those instead — you will see `UNVERIFIED build` in the log and a count of
how many addresses moved. Nothing is patched unless it was found unambiguously.

---

## What you need

- **Detroit: Become Human on PC** — your own copy, from either store above.
- **A VR headset with SteamVR.** Tested on PSVR2 at 90 Hz. The mod uses OpenXR
  and finds SteamVR's loader by itself, so there is nothing else to install.
- *Optional:* the **ViGEmBus** driver, only for PlayStation button prompts and
  DualShock motion/touchpad. Everything else works fine without it.

---

## Install

**1. Find your game folder** — the one containing `DetroitBecomeHuman.exe`.
In Steam: right-click the game → *Manage* → *Browse local files*.

**2. Copy this whole `DETROIT_VR_MOD` folder into it**, so you end up with:

```
...\Detroit Become Human\DETROIT_VR_MOD\
```

**3. Set these in-game video settings** before you start:

| Setting | Value |
|---|---|
| VSync | **Off** |
| Bloom | **Off** |
| Motion Blur | **Off** |
| Depth of Field | **Low** |
| Screen Space Reflections | **Off** |
| Ambient Occlusion | **Off** |
| Display Mode | **Windowed** |

> **Do not change Resolution Scale.** Changing it can break the game.

**4. Start SteamVR**, put the headset on, and check that it is tracking.

**5. Run `Play Detroit in VR.cmd`** from inside the `DETROIT_VR_MOD` folder.

**6. Press a key when it asks.** The game starts in your headset.

---

## ⚠️ Check your video settings again after the first VR run

**This is the single most common reason the mod "stops working".**

Detroit rewrites its own configuration on exit, and a VR session can leave some
of those settings changed behind your back. Check the table in step 3 again:

- **after your first ever launch in VR**, and
- **every time you change the rendering method** (mono ↔ stereo) in the VR panel.

**Display Mode** and **VSync** are the two that matter most. Exclusive
fullscreen fights the VR compositor for the display: the symptom is a session
that runs perfectly on menus and flat cutscenes, then collapses to a few frames
per second the moment real 3D gameplay starts. Windowed fixes it.

If performance falls off a cliff and nothing else changed, check these first.

---

## What the mod touches

Nothing in the game is replaced or patched. The mod starts the game and injects
itself. It writes two files:

- **`GraphicOptions.JSON`** — to raise the frame rate cap. Your original is
  backed up first and restored by the uninstaller.
- **`steam_appid.txt`** *(Steam copies only, and only if there is not one
  already)*. Launched outside Steam the game does not know which app it is: the
  full game answers by asking Steam to start itself a **second** time, in a
  process the mod is not in — so the game runs flat and nothing looks wrong —
  and the demo refuses outright with *"Steam must be running to play this
  game"*. The id is read from Steam's own records for your install, and the
  uninstaller removes the file again. **Epic copies need none of this** and are
  left alone.

### First launch is slow

Detroit builds its shader cache the first time it runs, which can take many
minutes, and levels may stutter for a while afterwards. In stereo it is slower
still, because every pipeline is compiled twice — once per eye layout. This
happens once; the results are cached and the second visit to an area is smooth.

### Never run Detroit before?

Then the frame cap cannot be set yet. Play once, quit the game, and it is
applied as you exit — active from the next launch.

---

## Controls

| Input | Does |
|---|---|
| `F6` | Recenter your view *(the game window must be focused)* |
| Both sticks pressed | Open the VR settings panel inside the headset |

Play with a gamepad, keyboard, or the VR controllers.

Settings live in `profiles\vr_panel_settings.txt`, each with a comment
explaining it. The panel saves its own changes immediately; edits you make by
hand apply the next time the game starts.

---

## Uninstall

Run **`Uninstall VR mod.cmd`**.

It restores your original `GraphicOptions.JSON`, removes the `steam_appid.txt`
the launcher wrote (never one that was already there), removes any "Detroit VR"
desktop shortcut left by an older version of the mod, and deletes this folder.
**Your saves are never touched.**

---

## If something goes wrong

There is no log by default. To capture one, create an empty file named:

```
profiles\debug_log.flag
```

and play again — `detroit_vr_debug.log` then appears next to this file. Delete
the flag afterwards, as the log grows large.

If the game crashes, an anonymous report is written to
`crash_reports\crash_<date>.txt` (PC, headset and GPU details, no personal
data). Send that along with a description of what happened.

---

## License

**MIT** — see the [LICENSE](LICENSE) file.

Fork it, fix it, build your own version and publish it; the only condition is
that the copyright notice stays with it. Improvements are very welcome.

The licence covers this mod's own code only. It grants no rights to
*Detroit: Become Human* or anything else Quantic Dream or Sony owns, and the
mod ships no game files.

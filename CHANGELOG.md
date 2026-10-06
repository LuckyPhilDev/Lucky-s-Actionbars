## [Unreleased]

### Added
- **Import from Dominos, EllesmereUI or Bartender4** Switch over in one click. Your bars land where they were, at the same size and shape, with the same numbers, spells and keybinds, and the same Ctrl, Alt, Shift and form paging, in a new Edit Mode layout of their own. You're offered it the first time Lucky's Actionbars loads next to one of them, or press Import under Bars in `/luckybars`. Afterwards it can turn the other addon off and reload for you, and once you've seen your new bars you can keep them or revert everything to how it was.

## [0.3.2] - 2026-10-05

### Fixed
- Fixed an error with the settings panel.
- **Paging menus** No longer try to build themselves at login before a bar is selected.

### Improved
- **Shared skyriding bar** The layout is applied once after login and after a spec or talent change, instead of every time your spells update, so it no longer waits for combat to end when nothing needs changing.

## [0.3.1] - 2026-10-04

### Fixed
- **Shared skyriding bar** Swapping two skyriding abilities now saves both of them. Before, the one you clicked back into the empty slot was dropped from the shared layout and moved back at your next login.

### Improved
- **Out-of-range icons** The red tint is softer, matching the out-of-mana tint, so the icon stays readable while you're out of range.

## [0.3.0] - 2026-10-04

### Added
- **WoW Forever support** Lucky's Actionbars now loads in WoW Forever as well as Retail.
- **Shared skyriding bar** Surge Forward, Skyward Ascent and the other skyriding abilities sit in the same slots on every character's skyriding bar. Set them up on one character and turn on Share Skyriding Bar layout there, then rearrange them on any character and the rest follow at their next login. Anything else on that bar stays per character. Leave one character out with Include this character. Both settings are under Bars in `/luckybars`.

## [0.2.0] - 2026-10-04

### Added
- **Keybinds for Action Bars 9 to 12** Bind their buttons in Quick Keybind mode, the same way as the stock bars.
- **More Edit Mode settings for Action Bars 9 to 12** Orientation, Bar Visible and Always Show Buttons work just like they do on the stock bars. Bars with more than one row now stack upwards, as the stock bars do.
- **Rows Grow** A new Edit Mode setting on horizontal action bars, including Action Bars 1 to 8, picks whether extra rows stack upwards or downwards, so your first button can sit top left.
- **Hidden until hovered for the Menu and Bags bars** Select the Micro Menu or Bags bar in Edit Mode to fade it out until you point at it.
- **Backpack only** A new Edit Mode setting on the Bags bar hides the other bag slots and the arrow that shows them, leaving just the backpack.
- **Hidden menu buttons** Pick any Micro Menu buttons to remove in its Edit Mode settings. The rest close up to fill the gap.
- **Masque support for Action Bars 9 to 12** With Masque installed, each extra bar has its own group under Lucky's Actionbars, so you can skin them like any other bar.

### Improved
- **Show/Hide Action Bars** A button in every action bar's Edit Mode settings opens a list beside the dialog, where you turn Action Bars 2 to 12 on and off.
- **Paging panel** Paging moved out of the bar's Edit Mode settings into its own panel beside the dialog, opened with the Paging button. It follows you from bar to bar, and only one of it and Show/Hide Action Bars is open at a time.
- **Form paging** Druids can page Action Bars 2 to 8 in Cat, Bear or Moonkin Form, and rogues while stealthed, from the Paging panel, just as Action Bar 1 already swaps.
- **More paging options** Ctrl+Shift, Ctrl+Alt, Alt+Shift and friendly target paging are now off by default to keep the Paging panel simple. Turn on More paging options under Bars in `/luckybars` to use them.
- **Minimap button** Left-click opens Edit Mode and right-click opens settings.
- **Tidier Bars settings** Paging comes first, then Hidden until hovered, and Action Bars 2 to 12 are picked from a single Shown bars list instead of a row each.
- **Lucky's Actionbars icon in Edit Mode** Settings and buttons this addon adds to Edit Mode carry its icon, so you can tell them apart from Blizzard's.

## [0.1] - 2026-10-03

### Added
- **Hold to page** Select any of Action Bars 1 to 8 in Edit Mode and pick a page for Ctrl, Alt, Shift, Ctrl+Shift, Ctrl+Alt, Alt+Shift or a friendly target. The bar swaps while the key is held, and its keys press the paged buttons.
- **Action Bars 9 to 12** Four extra bars showing the spare form pages, which you move in Edit Mode like the stock bars. Show or hide them from any action bar's settings in Edit Mode. A bar whose page your class's forms already use, like a druid's Cat Form page, is left out and says why in `/luckybars`.
- **Snapping for Action Bars 9 to 12** Dropping one of them in Edit Mode lines it up with nearby bars and screen edges, following Edit Mode's Snap setting.
- **Out-of-range icons** Action buttons on every bar turn red while your target is out of range, not just their keybind text. Turn it off under Buttons in `/luckybars`.
- **Hide button text** Remove keybind text or macro names from every action button, under Buttons in `/luckybars`.
- **Button tooltips** Choose whether action button tooltips show always, only out of combat, only while holding a modifier, or never, under Buttons in `/luckybars`.
- **Hidden until hovered** Any of Action Bars 1 to 12 can fade out until you point at it or drag a spell, set per bar in its Edit Mode settings. Set how quickly they appear and hide under Bars in `/luckybars`.
- **Layout for Action Bars 9 to 12** Selecting one in Edit Mode gives you # of Rows, # of Icons, Icon Size and Icon Padding, saved per layout like the stock bars.
- **Bars settings** Show or hide Action Bars 2 to 12 from one place in `/luckybars`, kept in sync with the stock Action Bars options.
- **Minimap button** Click it to open `/luckybars`. Drag it to move it around the minimap.

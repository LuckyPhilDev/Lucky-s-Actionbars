## [Unreleased]

### Added
- **Keybinds for Action Bars 9 to 12** Bind their buttons in Quick Keybind mode, the same way as the stock bars.
- **More Edit Mode settings for Action Bars 9 to 12** Orientation, Bar Visible and Always Show Buttons work just like they do on the stock bars. Bars with more than one row now stack upwards, as the stock bars do.
- **Rows Grow** A new Edit Mode setting on horizontal action bars, including Action Bars 1 to 8, picks whether extra rows stack upwards or downwards, so your first button can sit top left.

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

# Lucky's Actionbars

Keep Blizzard's action bars and make them do more. Lucky's Actionbars builds on the stock bars instead of replacing them, so your layout, keybinds, Edit Mode and other addons keep working as they always have.

Supports Retail and WoW Forever.

## Why Lucky's Actionbars

- **No bar replacement**: the bars you see are Blizzard's own. Nothing to rebuild and no new look to get used to.
- **Set up in Edit Mode**: every per-bar option sits in the stock Edit Mode dialog, beside Blizzard's own settings. There is no separate config window to learn.
- **Works in combat**: everything runs through the game's secure systems, so nothing stops working when you pull.
- **Stays out of the way**: vehicles, override bars, possession and pet battles are never touched.

## Features

### Tidier bars

- **Out-of-range icons**: the whole icon turns red while your target is out of range, on every action bar.
- **Hide button text**: remove keybind text or macro names from every action button.
- **Button tooltips**: show action button tooltips always, out of combat only, with a modifier held, or never.
- **Hidden until hovered**: any action bar, the Micro Menu or the Bags bar can fade out until you point at it, set per bar in its Edit Mode settings. Its keybinds keep working, and how quickly it appears and hides is set under Bars in `/luckybars`.
- **Tidier menu and bags**: remove any Micro Menu buttons you never click, and shrink the Bags bar down to just the backpack, from their Edit Mode settings.
- **Show and hide bars directly from Edit Mode**: turn Action Bars 2 to 12 on and off from any action bar's Edit Mode settings. Bars 2 to 8 stay in sync with the stock Action Bars options.

### Shared skyriding bar

Surge Forward, Skyward Ascent and the other skyriding abilities sit in the same slots on every character's skyriding bar. Set them up once, rearrange them on any character, and the rest follow at their next login. Anything else on that bar stays per character, and you can leave a character out. Turn it on under Bars in `/luckybars`.

### Action Bars 9 to 12

Four extra bars that show pages 7 to 10, built from the stock buttons, so they look and behave like the rest of your bars.

- Move them in Edit Mode, where they snap to nearby bars, with a separate position, size, padding and row count for each layout.
- Bind their buttons in Quick Keybind mode like any stock bar.
- Skin them with Masque, each bar in its own group.
- Bars on a page your class's forms already use, such as a druid's Cat Form page, are not offered.

### Hold to page

Turn one bar into several. Hold a modifier and a bar swaps to another page, then swaps back when you let go.

- **Any of Action Bars 1 to 8**: select a bar in Edit Mode and open its Paging panel to pick a page for Ctrl, Alt, Shift, Ctrl+Shift, Ctrl+Alt, Alt+Shift or a friendly target. Releasing the key returns the bar to its own page, including stance, form and stealth pages on Action Bar 1.
- **Any spare page**: page a bar to Action Bar 1's second page, to the contents of another bar, or to a form page your class does not use.
- **Keybinds follow the page**: while a modifier is held, a paged bar's keys press its paged buttons. Any modifier key you have already bound to something else is left alone.
- **Form paging**: druids can page Action Bars 2 to 8 in Cat, Bear or Moonkin Form, and rogues while stealthed.

### Import from Dominos, EllesmereUI or Bartender4

Switch over in one click. Your bars land where they were, at the same size and shape, with the same spells, keybinds and Ctrl, Alt, Shift and form paging, in a new Edit Mode layout of their own.

- You're offered it the first time Lucky's Actionbars loads next to one of them, or press **Import** under Bars in `/luckybars`.
- Afterwards it can turn the other addon off and reload for you.
- Keep your new bars, or revert everything to how it was. **Revert import** under Bars in `/luckybars` undoes it any time later.

## Installation

Install `Luckys_Actionbars` in the `Interface/AddOns` folder for your game:

- **Retail**: `World of Warcraft/_retail_/Interface/AddOns`
- **WoW Forever**: `World of Warcraft/_classic_beta_/Interface/AddOns` during the beta

Lucky's Utils is bundled.

## Usage

1. Open Edit Mode, select an action bar and open **Paging** to pick a page for each modifier. Ctrl pages Action Bar 1 to its second page by default.
2. Hold the modifier and drag spells onto that bar to fill its page.
3. Hold the modifier and press that bar's keys to cast from it.

## Slash Commands

| Command | Action |
|---|---|
| `/luckybars` | Opens the settings |
| `/luckybars revert` | Reverts an import from another action bar addon |

## Settings

Paging is set per bar in Edit Mode. In `/luckybars`, under **Bars**, choose which of Action Bars 2 to 12 are shown, and turn on **More paging options** for Ctrl+Shift, Ctrl+Alt, Alt+Shift and friendly target paging. Shift-1 to Shift-6 switch action bar pages by default, so unbind them in Key Bindings if you page with Shift.

## Author

Lucky Phil

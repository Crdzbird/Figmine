# figmine example

A small app themed entirely from design tokens. Everything in `lib/theme/tokens`
is generated, the files directly in `lib/theme` are scaffolded once and yours to
edit, and `lib/app` shows the result.

## Where the tokens come from

`design-tokens.json` is the kind of file the figmine exporter plugin writes
from a Figma file. It holds:

- Primitives: color ramps, a font family and a base size.
- Semantic: light and dark colors that alias the primitives.
- Spacing: page margin, gutter and section gap in Mobile, Tablet and Desktop
  modes.
- Effects: a card shadow and a brand gradient.
- Text styles: a display, headline, title, body and label scale.

`figmine.yaml` reads that file through `tokens.files`, so no Figma token or
network access is needed:

```bash
dart run figmine generate --offline
```

The run reports `Heavy Figma reads: 0 sent`. File metadata comes from
`figmine.lock.json` and the icons from `assets/figmine/icons`.

## What the app shows

- Colors: the generated scheme roles and every color token with its mode.
- Components: filled, outlined and text buttons, a disabled button, an input,
  chips, a checkbox, a radio, a switch, a dialog, a bottom sheet, a snack
  bar, a tooltip, a navigation bar and a floating action button, styled by
  `AppComponentThemes`.
- Effects: the gradient and shadow tokens and the type scale.

Page padding and gaps come from `context.appSpacing`, which picks the Spacing
mode for the window width: Mobile below 600, Tablet below 840, Desktop from there.
The icon in the app bar toggles light and dark mode.

## Use your own design

Point `figma.file_key` at your file, remove `tokens.files` and run
`dart run figmine generate` with `FIGMA_TOKEN` set, or export your own
`design-tokens.json` with the plugin and keep the offline setup.

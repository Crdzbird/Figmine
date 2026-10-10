# Changelog

## 0.1.0 (unreleased)

- CLI: `init`, `generate`, `check`, `scaffold`, `doctor`, `webhook`,
  `comment`, `exporter`, `relay` and `preview`.
- Tokens from Figma Variables, color and text styles, library and team
  styles, or design token JSON files such as the figmine exporter output.
- One generated library per collection with typed constants, aliases as
  references, Figma descriptions and catalogues of `FigmineTokenEntry`.
- `AppColorScheme` ThemeExtension with every Material role, extra roles,
  seed derived roles and hand set overrides.
- Inference from designed screens: color roles, typography, spacing and
  radius scales, component dimensions, and roles mapped onto variables
  through screen bindings.
- Role scales such as `tertiary/10` to `tertiary/100` set the role color
  from the step the screens use most, and derived container, fixed and
  dark roles move onto the nearest step of their scale.
- Neutral, success, warning and info scales: surfaces and outlines snap
  to the neutral scale with one step per tone, feedback roles take the
  most used step that reads as text, and feedback containers come from
  their scale.
- Single color overrides get a dark value at the tone of the dark role.
- Component metrics come from the most used component of each kind in
  its resting state, preferring names that state the kind and mobile
  variants, skipping parts such as list items and labels, and measuring
  the painted body, such as the field box of an input.
- Inference keeps secondary and tertiary out of feedback hues and pale
  tints.
- Figma API budget: heavy reads (file and nodes) are cached on disk per
  file version, screens load in batches of 50 that split when Figma cannot
  render them, each sync reports its heavy reads, and long rate limits
  fail at once with the seat type, the wait and the alternatives.
- Monochrome brands: primary comes from the default button even when it is
  gray, gray seeds derive with the monochrome scheme, surfaces are the
  lightest major background, pale tints never count as neutral, and
  accents seen on a single screen are ignored.
- Auto mode infers colors whenever the defined colors give no primary.
- Text roles prefer plain styles over italic, link and code variants, skip
  private styles, and accept larger size gaps for styles named after the
  role.
- Variables with named modes: the configured light and dark modes become
  `Light` and `Dark` in class names, whatever Figma calls them.
- Feedback roles, error included, prefer semantic tokens over primitives,
  match aliases such as `danger`, `positive` or `red` as whole words,
  need a hue that fits the role, and get containers from hue scales.
- Tokens named for another use, such as text bound as a fill, never fill
  a background role, and foregrounds that do not read on their background
  are replaced by readable ones.
- Component states: hovered, pressed, focused, disabled, error and
  selected colors of buttons, text fields and chips are read from the
  variants in the screens and in component sets. They become fields of the
  color scheme that reference the bound tokens, keep their relation to the
  resting color in dark mode, follow the hovered variant when pressed or
  focused are missing, and fall back to Material state layers.
  Outlined buttons, recognized as labelled buttons with a border apart
  from a light or no fill, get fill, label and border per state, with
  transparent Material state layers by default. `AppComponentThemes`
  builds filled button, outlined button, text field and chip themes from
  them, the scaffold uses it, and `figmine scaffold --force` updates
  existing projects. The preview shows disabled, focused, error and
  selected states.
- `figmine adopt` finds hard coded colors, spacings and radii in app code,
  offline from the lock file. It reads how each value is used, such as a
  color inside `TextStyle` or padding inside `EdgeInsets`, to pick the
  token meant for that use and the theme aware scheme role, reports colors
  no token has, replaces unambiguous values with `--apply` (with the
  import, sorted, and formatted), and fails CI with `--set-exit-if-found`.
  `--since <ref>` limits it to lines a branch adds, it writes GitHub
  annotations in Actions, and `--report` appends a Markdown section.
  `figmine init` adds a `figmine adopt` pull request check that fails only
  on new hard coded values and needs no Figma token, and the sync pull
  request lists hard coded values that match the new tokens.
- `figmine score` grades the generated theme, or with `--inferred` what
  the cached screens alone give, against a YAML reference of colors per
  mode, component dimensions and text roles, offline. Colors compare by
  CAM16 distance as match, close or off, numbers within a tolerance and
  text by family and size. It prints section scores and every miss,
  writes a Markdown scorecard with `--report`, and fails CI below
  `--min`.
- Text roles count identical styles once, under the shortest name.
  Inferred typography leaves monospace families out, and inferred dark
  modes keep the hue of secondary, tertiary, error and feedback colors at
  the Material dark tone instead of copying light values.
- Collections with modes beyond light and dark, such as breakpoints or
  brands, get a `...Modes` class with a constant per mode, `all` and
  `byMode`. Breakpoint modes map onto Material window size classes, app
  modes first, with `of(width)` and a BuildContext getter.
- Shadows from effect styles become `List<BoxShadow>` and gradient fills
  become `LinearGradient`, `RadialGradient` or `SweepGradient` constants,
  in an `effects` folder. The exporter plugin writes them as DTCG
  `shadow` and `gradient` tokens.
- `figmine generate --offline` regenerates from the lock file and the
  cache, without a token or the network. The cache keeps every read of a
  file version except its metadata and images, and the lock file records
  the file name.
- Checkbox, radio, switch, tab and text button states, with generated
  themes, scaffold files and preview examples. Checked values such as
  `Value Type=Checked` count as selected, indeterminate ones are skipped,
  and the glyph inside a control is read as its mark.
- Within each text role kind, larger roles get larger styles.
- Display and headline styles come from screens alone: large text on a
  few layers counts even when rare, sizes may sit further apart at the
  top of the scale, and styles that differ only in line height count as
  one.
- `components` in `figmine.yaml` pins component metrics, such as
  `inputHeight: 40`, over the inferred values.
- When colors are inferred and no screen is dark, `generate` and
  `doctor` point to the exporter plugin, which reads dark mode values
  that screens cannot give.
- Modes classes are enhanced enums, and generated shadows and gradients
  leave default arguments out and use named alignments, so generated code
  passes very_good_analysis without ignores.
- The example app is generated offline from an exporter JSON file and
  shows the scheme, every component theme, shadows, gradients, the type
  scale and spacing that follows the window size.
- The exporter plugin sends `design-tokens.json` to GitHub: it commits the
  file on top of the base branch to `figmine/tokens`, skips exports with no
  token changes, and keeps its settings on the designer's computer. The
  `figmine tokens` workflow that `init` writes generates the theme on that
  branch, offline when no Figma token is set, and opens or updates the
  pull request. Offline syncs of exported files need no lock file.
- Floating action buttons, navigation bars, bottom sheets, dialogs, snack
  bars and toasts, and tooltips get colors, corner radii and sizes from
  the screens, generated themes, scaffold files and a preview example.
  The translucent fill around a dialog or sheet counts as its scrim, so
  the panel inside is measured. Run `figmine scaffold --force` to wire
  them into an existing theme.
- Components whose own name states the kind, such as a `Tooltip` set, are
  preferred over layers that only carry the name, such as an icon called
  tooltip.
- Text, icon and outline colors of a component keep reading on its fill in
  dark mode: a value that would disappear moves to a readable tone of its
  own hue.
- The contrast audit skips pairs where both colors are Material defaults,
  such as the navigation bar of a design without one.
- `figmine scaffold` formats the files it writes.
- Boolean variables become `bool` constants, durations `Duration`,
  `cubic-bezier()` strings `Curve` and font weights `FontWeight`, from
  Figma names such as `motion/duration/short` and `font/weight/bold`, the
  `FONT_WEIGHT` scope, or the DTCG `boolean`, `duration`, `cubicBezier`
  and `fontWeight` types. Tokens linked by aliases change type together,
  and motion tokens get a `motion` folder. Numbers named for font weights
  that were `double` before are now `FontWeight`.
- `generate` and the pull request report list font families the text
  styles use that `pubspec.yaml` does not bundle under `flutter.fonts`,
  since Flutter would show the platform font instead. Roboto and SF Pro
  count as bundled.
- CI renders the example theme in light and dark mode and uploads the
  images, and `tool/corpus.dart` scores local design files against their
  references and fails when inference regresses below the committed
  baseline. CI scores the Simple Design System and Material 3 Design Kit corpora,
  published as `corpus-v1` release assets.
- `figmine generate --watch` regenerates offline whenever the token files
  or `figmine.yaml` change, so a new export from the plugin reaches the
  running app with a hot reload. A file read halfway through a save is
  logged and skipped.
- `FigmineGallery` shows every token of the generated `appTokenCatalog`
  with a preview of its value. It needs only the widgets layer, so it
  works as a debug page or a Widgetbook use case.
- `figmine init` in a terminal asks for the file and the settings. With
  `FIGMA_TOKEN` set it checks, with light reads only, whether the file's
  variables are readable and how many styles it publishes, and suggests
  the exporter plugin when variables are out of reach.
- The workflows `figmine init` writes use `actions/checkout@v7`.
- Offline syncs skip screen inference when no screens were cached for the
  version, instead of failing, and modes classes of plain values no
  longer import Flutter.
- Component metrics prefer the component named just for its kind, such as
  `Button` over `Split button`, and the size variant the screens use most
  instead of always `medium`, since design systems such as Material 3
  Expressive make a smaller size the default. Side sheets no longer count
  as bottom sheets, and `type=modal` no longer makes a component a dialog.
- When tokens come from exported files, the file's styles are not read
  from Figma, saving heavy API reads.
- `figmine score --inferred` grades the color scheme `generate` would
  build from the screens alone, derived roles such as containers
  included, instead of only the roles inference names itself.
- Colors drawn on a dark panel inside a light screen, such as the action
  of a snack bar or a dark mode example on a documentation page, count as
  inverse colors, not light mode ones. Pale secondary and tertiary
  candidates, below 3:1 against the surface, need three screens, so dark
  mode swatches no longer become light accents and the roles are derived
  from primary instead.
- `onSurface` is the readable text color with the most contrast among
  those used at least half as much as the top one, so captions on
  documentation pages no longer pass for body text; secondary text may be
  the slightly tinted gray Material uses. When the most used stroke is a
  divider below 2:1, the stroke of resting text fields sets `outline`.
- SVG icon export with the `FigmineIcon` widget.
- Domain and Figma folder layouts for generated code, with stale files
  removed on sync.
- Safe updates: renamed tokens are rewritten in the project's code and
  removed tokens still in use stay as deprecated constants.
- WCAG AA contrast audit of the color scheme in every report, with a
  suggested fix for each failing pair: the design's own token closest to
  the failing color that passes in every failing mode, preferring tokens
  named for the same use and not for a state, or the same hue at a passing
  tone when no token does. The report adds a ready to paste
  `color_scheme` snippet for `figmine.yaml`, and `generate` logs each
  finding with its fix.
- `figmine preview` renders light and dark images of the theme, added as a
  Before and After table to the pull request.
- Lock file, Markdown change report with Figma version history, and a
  GitHub workflow that opens a pull request and links it in Figma.

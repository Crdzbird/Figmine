# figmine

[![figmine][ci_badge]][ci_link]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

Turn a Figma design into Flutter theme code, and keep it in sync with a pull
request every time the design changes.

figmine reads Figma Variables, styles, an exported token file or the designed
screens themselves. It writes typed Dart constants, a full Material
`ColorScheme`, a `TextTheme`, component themes with their hover, pressed,
disabled and selected states, shadows, gradients, responsive spacing and SVG
icons. Then it checks the result for contrast, finds hard coded values in your
app and replaces them with tokens.

```dart
FilledButton(
  style: FilledButton.styleFrom(backgroundColor: context.appColorScheme.success),
  onPressed: save,
  child: Text('Save', style: AppTypography.labelLarge),
)

Padding(padding: EdgeInsets.all(context.appSpacing.pageMargin), child: page)
```

## Quick start

```bash
flutter pub add figmine
dart run figmine init --file https://www.figma.com/design/<key>/My-App
export FIGMA_TOKEN=<personal access token with file_content:read>
dart run figmine doctor
dart run figmine generate
```

`init` writes `figmine.yaml`, the GitHub workflows and the theme layer in
`lib/theme`. `doctor` tells you which Figma scopes your token has and where
tokens will come from. `generate` writes the code and the lock file.

Then use the theme:

```dart
import 'package:my_app/theme/theme.dart';

MaterialApp(
  theme: const AppTheme().themeData,
  darkTheme: const AppTheme(brightness: Brightness.dark).themeData,
  home: const HomePage(),
);
```

## Where tokens come from

figmine works with whatever your Figma plan and file give it. With
`tokens.source: auto` it picks the best source available.

| Source | Needs | Gives |
| --- | --- | --- |
| Figma Variables | Enterprise plan, `file_variables:read` | Every collection and mode |
| Exporter plugin | Any plan, Figma desktop | Variables, text styles, shadows and gradients as a JSON file |
| Styles | Any plan, `file_content:read` | Color, text, effect and gradient styles, also from libraries |
| Screens | Any plan, `file_content:read` | Colors, type, spacing, radii and component metrics inferred from the designs |

Screen inference fills the gaps: a file with only a few styles still gets a
complete color scheme, type scale and component metrics. It reads which
colors fill buttons, surfaces and text, how components look in each state,
and what spacing and radii repeat.

### The exporter plugin

When your token cannot read Variables, export them from inside Figma:

```bash
dart run figmine exporter
```

In Figma desktop choose Plugins, Development, Import plugin from manifest,
and pick `figma_exporter/manifest.json`. Run it in the design file. It can:

- Download `design-tokens.json` for you to commit, or
- Send it to GitHub. Enter the repository, base branch, file path and a
  fine grained token with Contents read and write on that repository. The
  plugin pushes the file to the `figmine/tokens` branch, and the
  `figmine tokens` workflow written by `init` generates the theme and opens
  the pull request. Designers ship token changes without a developer and
  without any Figma API calls.

Point figmine at the file:

```yaml
tokens:
  files: [design-tokens.json]
```

`dart run figmine generate --offline` then works with no Figma token at all.

## Commands

| Command | What it does |
| --- | --- |
| `init` | Writes `figmine.yaml`, the workflows and the theme layer. |
| `doctor` | Checks the token's scopes and explains how tokens will be read. |
| `generate` | Reads Figma and writes the code, the lock file and a change report. `--offline` uses the lock file and cache only. |
| `scaffold` | Writes the theme class and component themes once. `--force` updates them to the current templates. |
| `adopt` | Finds hard coded colors, spacings and radii that match tokens. `--apply` replaces them, `--since <ref>` checks only new lines. |
| `score` | Grades the theme against reference values, for tuning and CI. |
| `check` | Tells whether Figma has a newer version than the lock file. |
| `preview` | Renders light and dark images of the theme for pull requests. |
| `exporter` | Writes the Figma plugin. |
| `webhook`, `relay` | Registers a Figma webhook and writes a Cloudflare Worker that turns it into a GitHub dispatch, for syncs within seconds. |
| `comment` | Links the pull request in a Figma comment. |

## What gets generated

`lib/theme/tokens` is rewritten on every sync. Never edit it by hand.

- One library per collection with typed constants, aliases kept as
  references, and Figma descriptions as doc comments.
- `AppColorScheme`, a `ThemeExtension` with every Material role, extra roles
  such as `success` and `warning`, and component state colors. Read it with
  `context.appColorScheme`. Roles Figma does not define are derived, and dark
  values are derived when the design has only light ones.
- `AppTypography` with a `TextTheme`.
- `AppComponentThemes` for filled, outlined and text buttons, inputs, chips,
  checkboxes, radios, switches, tabs, floating action buttons, navigation
  bars, bottom sheets, dialogs, snack bars and tooltips, with every state
  the design shows.
- `AppComponents` with measured heights, radii and paddings.
- Shadows as `List<BoxShadow>` and gradients as `Gradient` constants.
- A `Modes` enum for collections with modes beyond light and dark. For
  breakpoints, `context.appSpacing` picks the mode for the window width.
- SVG icons with the `FigmineIcon` widget.
- `FigmineTokenEntry` catalogues of every token, for galleries and tests.

`lib/theme` is written once and is yours: tune the component themes there.

## Keeping the app in sync

`init` adds three GitHub workflows:

- `figmine sync` runs every hour, on demand or on a Figma webhook. It opens a
  pull request with the code, a change report with Figma version history,
  before and after images, and a contrast audit.
- `figmine tokens` runs when the plugin sends tokens.
- `figmine adopt` fails a pull request that adds hard coded design values.
  It needs no Figma token.

Add `FIGMA_TOKEN` as a repository secret and allow GitHub Actions to create
pull requests in the repository settings.

Renamed tokens are rewritten in your code, and removed tokens that are still
used stay as deprecated constants until you move off them.

## Configuration

`figmine.yaml`, with the defaults `init` writes:

```yaml
figma:
  file_key: AbC123
  token_env: FIGMA_TOKEN

tokens:
  source: auto            # auto, variables, styles or file
  files: []               # design token JSON files or folders
  collections: {}         # collection name: class name segment
  strip_prefix: ""
  light_mode: light
  dark_mode: dark

color_scheme:
  roles: {}               # primary: brand/blue/600
  extra: {}               # success: feedback/green
  overrides: {}           # error: "#B3261E" or {light: .., dark: ..}

typography:
  enabled: true
  roles: {}               # bodyLarge: Body/Regular

inference:
  mode: auto              # auto, always or off
  pages: []
  node_ids: []

library:
  file_keys: []           # design system files whose styles are used

icons:
  node_ids: []            # frames or pages holding icon components
  name_prefix: ""
  output: assets/figmine/icons

output:
  directory: lib/theme/tokens
  theme_directory: lib/theme
  class_prefix: App
  layout: domain          # domain or figma

components: {}            # pin measured metrics, such as inputHeight: 48

lock_file: figmine.lock.json
```

Unknown keys stop the sync with an error, naming the section a misplaced
key belongs to.

## Accessibility

Every sync checks each text and outline color against its background in
light and dark mode. Pairs below WCAG AA get a suggested fix: the closest
token of your own design that passes, or the same hue at a passing tone, with
a `color_scheme` snippet ready to paste.

## Figma API budget

Figma limits API reads, tightly on some seats. figmine caches every read per
file version under `.figmine/cache`, reads screens in small batches, reports
how many heavy reads each sync used, and stops early with an explanation when
the limit would make it wait. `generate --offline` and the exporter plugin use
no reads at all.

## Example

[`example/`](example) is an app generated offline from an exported token
file. It shows the color scheme, every component theme, shadows, gradients,
the type scale and responsive spacing.

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[ci_badge]: https://github.com/Crdzbird/Figmine/actions/workflows/figmine.yaml/badge.svg
[ci_link]: https://github.com/Crdzbird/Figmine/actions/workflows/figmine.yaml

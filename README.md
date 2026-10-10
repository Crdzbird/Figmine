# figmine

[![figmine][ci_badge]][ci_link]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

Turn a Figma design into Flutter theme code: tokens, a full ColorScheme,
typography, component themes with their states, shadows, gradients,
responsive spacing and icons. figmine opens a pull request whenever the
design changes.

| Path | Contents |
| --- | --- |
| [`figmine/`](figmine) | The package: the `dart run figmine` CLI, the Figma exporter plugin and the `FigmineIcon` widget. |
| [`figmine/example/`](figmine/example) | An app themed with generated code. |

See the [package README](figmine/README.md) for setup and configuration.

## Development

```bash
cd figmine
flutter pub get
flutter analyze
flutter test
```

The plugin and relay tests run with Node.js when it is installed.

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[ci_badge]: https://github.com/Crdzbird/Figmine/actions/workflows/figmine.yaml/badge.svg
[ci_link]: https://github.com/Crdzbird/Figmine/actions/workflows/figmine.yaml

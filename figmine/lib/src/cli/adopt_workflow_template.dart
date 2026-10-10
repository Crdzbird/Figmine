/// The GitHub Actions check written by `figmine init` that keeps new code
/// on the design tokens.
abstract final class AdoptWorkflowTemplate {
  /// Workflow that flags hard coded design values a pull request adds. It
  /// reads only the lock file and the generated code, so it needs no Figma
  /// token, and existing values never fail it.
  static const String contents = r'''
name: figmine adopt

on:
  pull_request:
    paths:
      - "lib/**"

permissions:
  contents: read

jobs:
  adopt:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - run: flutter pub get

      - name: Find new hard coded values
        run: >-
          dart run figmine adopt
          --since "origin/${{ github.base_ref }}"
          --set-exit-if-found
''';
}

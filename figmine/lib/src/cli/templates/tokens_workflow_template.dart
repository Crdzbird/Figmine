/// The GitHub Actions workflow written by `figmine init` for tokens the
/// exporter plugin sends.
abstract final class TokensWorkflowTemplate {
  /// Workflow that runs when the plugin pushes `design-tokens.json` to the
  /// `figmine/tokens` branch: it generates the theme on that branch, offline
  /// when no Figma token is set, and opens or updates the pull request.
  static const String contents = r'''
name: figmine tokens

on:
  push:
    branches: [figmine/tokens]

permissions:
  contents: write
  pull-requests: write

concurrency:
  group: figmine-tokens
  cancel-in-progress: true

jobs:
  generate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - run: flutter pub get

      - name: Generate the theme from the exported tokens
        run: |
          report="$RUNNER_TEMP/figmine-report.md"
          touch "$report"
          if [ -n "$FIGMA_TOKEN" ]; then
            dart run figmine generate --force --report "$report"
          else
            dart run figmine generate --offline --report "$report"
          fi
        env:
          FIGMA_TOKEN: ${{ secrets.FIGMA_TOKEN }}

      - name: Find hard coded values
        continue-on-error: true
        run: dart run figmine adopt --report "$RUNNER_TEMP/figmine-report.md"

      - name: Commit the generated code
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "41898283+github-actions[bot]@users.noreply.github.com"
          git add -A
          if ! git diff --cached --quiet; then
            git commit -m "chore(design): generate the theme from exported tokens"
            git push
          fi

      - name: Open or update the pull request
        env:
          GH_TOKEN: ${{ github.token }}
        run: |
          report="$RUNNER_TEMP/figmine-report.md"
          open=$(gh pr list --head figmine/tokens --state open --json number --jq '.[0].number')
          if [ -n "$open" ]; then
            gh pr edit "$open" --body-file "$report"
          else
            gh pr create --head figmine/tokens \
              --title "chore(design): sync tokens from Figma" \
              --body-file "$report"
          fi
''';
}

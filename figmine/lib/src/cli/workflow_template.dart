/// The GitHub Actions workflow written by `figmine init`.
abstract final class WorkflowTemplate {
  /// Workflow that opens a pull request when Figma tokens change.
  static const String contents = r'''
name: figmine sync

on:
  schedule:
    - cron: "0 * * * *"
  workflow_dispatch:
  repository_dispatch:
    types: [figma-file-update]

permissions:
  contents: write
  pull-requests: write

concurrency:
  group: figmine-sync
  cancel-in-progress: false

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - run: flutter pub get

      - name: Preview before
        continue-on-error: true
        run: dart run figmine preview --output .figmine/preview/before

      - name: Sync tokens from Figma
        id: figmine
        run: dart run figmine generate --report "$RUNNER_TEMP/figmine-report.md"
        env:
          FIGMA_TOKEN: ${{ secrets.FIGMA_TOKEN }}

      - name: Preview after
        if: steps.figmine.outputs.changed == 'true'
        continue-on-error: true
        run: >-
          dart run figmine preview --output .figmine/preview/after
          --compare .figmine/preview/before
          --report "$RUNNER_TEMP/figmine-report.md"

      - name: Find hard coded values
        if: steps.figmine.outputs.changed == 'true'
        continue-on-error: true
        run: dart run figmine adopt --report "$RUNNER_TEMP/figmine-report.md"

      - name: Open pull request
        id: pr
        if: steps.figmine.outputs.changed == 'true'
        uses: peter-evans/create-pull-request@v7
        with:
          branch: figmine/sync
          delete-branch: true
          commit-message: "chore(design): sync tokens from Figma"
          title: "chore(design): sync tokens from Figma"
          body-path: ${{ runner.temp }}/figmine-report.md

      - name: Link the pull request in Figma
        if: steps.pr.outputs.pull-request-operation == 'created'
        continue-on-error: true
        run: dart run figmine comment --pr-url "${{ steps.pr.outputs.pull-request-url }}"
        env:
          FIGMA_TOKEN: ${{ secrets.FIGMA_TOKEN }}
''';
}

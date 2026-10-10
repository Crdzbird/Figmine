/// Asks questions on a terminal, with a default for an empty answer.
final class InitPrompt {
  /// Creates a prompt that reads lines with [read] and writes with [write].
  const factory({
    required String? Function() read,
    required void Function(String text) write,
  }) = InitPrompt._;

  const new _({required this.read, required this.write});

  /// Reads one line, or null at the end of input.
  final String? Function() read;

  /// Writes text without a line break.
  final void Function(String text) write;

  /// The answer to [question], or [fallback] when it is empty.
  String text(String question, String fallback) {
    final hint = fallback.isEmpty ? '' : ' [$fallback]';
    write('$question$hint: ');
    final answer = read()?.trim() ?? '';
    return answer.isEmpty ? fallback : answer;
  }

  /// A yes or no answer to [question], [fallback] when empty.
  bool yes(String question, {required bool fallback}) {
    final answer = text(question, fallback ? 'Y/n' : 'y/N').toLowerCase();
    if (answer.startsWith('y')) return true;
    if (answer.startsWith('n')) return false;
    return fallback;
  }

  /// The index of the option picked from [options], the first by default.
  int choice(String question, List<String> options) {
    write('$question\n');
    for (var i = 0; i < options.length; i++) {
      write('  ${i + 1}) ${options[i]}\n');
    }
    final picked = int.tryParse(text('Choice', '1')) ?? 1;
    return (picked - 1).clamp(0, options.length - 1);
  }
}

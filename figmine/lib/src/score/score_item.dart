/// How close a value came to its reference.
enum Grade {
  /// The same, or indistinguishable.
  match(1),

  /// Near, such as a slightly different shade.
  close(0.5),

  /// Different.
  off(0),

  /// Not produced at all.
  missing(0);

  new(this.points);

  /// Points out of one.
  final double points;
}

/// One graded value of a scorecard.
typedef ScoreItem = ({
  String section,
  String name,
  String expected,
  String actual,
  Grade grade,
});

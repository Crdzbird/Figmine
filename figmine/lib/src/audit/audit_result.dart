import 'package:figmine/src/audit/contrast_finding.dart';
import 'package:figmine/src/audit/contrast_fix.dart';

/// The contrast audit of a scheme: the failing pairs, how many pairs were
/// checked, a suggested fix for each failing pair, and the `figmine.yaml`
/// settings that apply them.
typedef AuditResult = ({
  List<ContrastFinding> findings,
  int checked,
  List<ContrastFix?> fixes,
  String snippet,
});

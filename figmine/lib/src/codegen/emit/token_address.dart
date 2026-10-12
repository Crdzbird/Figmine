import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';

/// Where a generated constant lives.
typedef TokenAddress = ({String className, String member, String file});

/// A token in one mode with its generated address.
typedef IndexEntry = ({
  TokenCollection collection,
  DesignToken token,
  String mode,
  TokenAddress address,
});

/// One token of a design token file, in one mode, before aliases resolve.
typedef DtcgEntry = ({
  String collection,
  String mode,
  List<String> path,
  String type,
  Object? value,
  String description,
  String? aliasCollection,
  Object? fallback,
  String? variableId,
});

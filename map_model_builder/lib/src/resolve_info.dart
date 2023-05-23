import 'package:analyzer/dart/element/type.dart';

/// PropertyInfo
class PropertyInfo {
  String propertyName;
  DartType propertyType;

  PropertyInfo({
    required this.propertyName,
    required this.propertyType,
  });
}

/// ConvertInfo
class ConvertInfo {
  DartType type;
  String convert;

  ConvertInfo({
    required this.type,
    required this.convert,
  });
}

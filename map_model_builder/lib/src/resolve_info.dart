import 'package:analyzer/dart/element/type.dart';

class PropertyInfo {
  String propertyName;
  DartType propertyType;
  String propertyTypeName;

  PropertyInfo(
      {required this.propertyName,
      required this.propertyType,
      required this.propertyTypeName});
}

class ConvertInfo {
  DartType type;
  String typeName;
  String convert;

  ConvertInfo(
      {required this.type, required this.convert, required this.typeName});
}

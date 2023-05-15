import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

abstract class BaseGenerator<T> extends GeneratorForAnnotation<T> {
  String get mapClass;
  String get customCode => '';
  String get superClass => '';

  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation,
      BuildStep buildStep) {
    if (element is ClassElement) {
      var className = element.name;

      /// property list
      String propertyString = '';
      String initString = '';
      var properties = annotation.read('properties');
      if (!properties.isNull) {
        for (var item in properties.listValue) {
          /// property type
          late DartType propertyTypeObject;
          late String propertyType;
          var itemType = item.type;
          if (itemType is ParameterizedType) {
            if (itemType.typeArguments.isNotEmpty) {
              propertyTypeObject = itemType.typeArguments.first;
              propertyType = propertyTypeObject.toString();
            }
          }

          /// property name
          var propertyName = item.getField('name')!.toStringValue();
          var propertyValue = "_data['$propertyName']";
          var setValue = propertyValue;

          /// property default
          var defaultValue = item.getField('value');//?.variable?.displayName;
          if (defaultValue != null && !defaultValue.isNull) {
            initString += '''
  if ($propertyValue == null) {
    $propertyValue = ${defaultValue.toStringValue()};
  }
''';
          }

          if (propertyTypeObject.isDartCoreList) {
            /// castList
            propertyTypeObject as ParameterizedType;
            var listEleType = propertyTypeObject.typeArguments.first;
            if (listEleType is! DynamicType) {
              setValue = '$setValue?.cast<$listEleType>()';
            }
          } else
          if (propertyTypeObject.isDartCoreMap) {
            /// castMap
            propertyTypeObject as ParameterizedType;
            var keyType = propertyTypeObject.typeArguments.first;
            var valueType = propertyTypeObject.typeArguments.last;
            if (keyType is! DynamicType || valueType is! DynamicType) {
              setValue = '$setValue?.cast<$keyType, $valueType>()';
            }
          }

          /// convert
          var convert = item.getField('convert')?.toStringValue();
          if (convert != null) {
            setValue = '$convert($setValue)';
          }

          propertyString += '''
  $propertyType get $propertyName => $setValue;

  set $propertyName($propertyType $propertyName) => $propertyValue = $propertyName;

''';
        }

        if (initString.isNotEmpty) {
          initString = ''' {
$initString
}
''';
        }
      }

      var setData = 'data ?? {}';
      if (mapClass != 'Map<String, dynamic>' &&
          mapClass != 'Map<dynamic, dynamic>' && mapClass != 'Map') {
        setData = '$mapClass($setData)';
      }

      return '''

class _${className}Impl $superClass {
  final $mapClass _data;

${propertyString}
$customCode

  _${className}Impl([Map<String, dynamic>? data]) : _data = $setData ${initString.isNotEmpty? initString: ';'}
}
''';
    }
  }
}

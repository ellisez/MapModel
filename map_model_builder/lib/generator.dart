import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:map_model/annotation.dart';
import 'package:source_gen/source_gen.dart';

class MapModelGenerator extends GeneratorForAnnotation<Model> {

  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation,
      BuildStep buildStep) {
    if (element is ClassElement) {
      var className = element.name;
      var partOf = buildStep.inputId.pathSegments.last;

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

      return '''part of '$partOf';

class _${className}Impl {
  final Map<String, dynamic> _data;

${propertyString}

  _${className}Impl([Map<String, dynamic>? data]) : _data = data ?? {} ${initString.isNotEmpty? initString: ';'}
}
''';
    }
  }
}

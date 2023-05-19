import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

abstract class BaseGenerator<T> extends GeneratorForAnnotation<T> {
  String get mapClass => 'Map<String, dynamic>';

  String get customCode => '';

  String get superClass => 'MapModel';

  String get initCode => '';

  String get modelRef => '\$data';

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is ClassElement) {
      var className = element.name;
      var genMixin = '_${className}Mixin';

      String genClass = '';
      var superType = element.supertype;
      if (superType == null || superType.element.name == 'Object') {
        genClass = '_${className}Impl';
      }

      ///
      var converts = annotation.read('converts').mapValue.map((key, value) {
        return MapEntry<String, String>(
            key!.toTypeValue().toString(), value!.toStringValue()!);
      });

      /// property list
      String propertyString = '';
      String initString = '';
      String exportString = '';
      String validateString = '';
      String typesString = '';
      var properties = annotation.peek('properties');
      if (properties != null) {
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
          var propertyValue = "$modelRef['$propertyName']";

          /// property default
          var defaultValue = item.getField('value');
          if (defaultValue != null && !defaultValue.isNull) {
            initString += '''
  if ($propertyValue == null) {
    $propertyValue = ${defaultValue.toStringValue()};
  }
''';
          }

          var setValue = propertyValue;
          if (propertyTypeObject.isDartCoreList) {
            /// castList
            propertyTypeObject as ParameterizedType;
            var listEleType = propertyTypeObject.typeArguments.first;
            if (listEleType is! DynamicType) {
              setValue = '$setValue?.cast<$listEleType>()';
            }
          } else if (propertyTypeObject.isDartCoreMap) {
            /// castMap
            propertyTypeObject as ParameterizedType;
            var keyType = propertyTypeObject.typeArguments.first;
            var valueType = propertyTypeObject.typeArguments.last;
            if (keyType is! DynamicType || valueType is! DynamicType) {
              setValue = '$setValue?.cast<$keyType, $valueType>()';
            }
          }

          var typeElement = propertyType;
          if (propertyTypeObject.nullabilitySuffix != NullabilitySuffix.none) {
            typeElement = typeElement.substring(0, typeElement.length - 1);
          }

          /// types
          typesString += '''
          map['$propertyName'] = $typeElement;
          ''';

          /// validate
          if (propertyTypeObject is! DynamicType) {
            var convert = converts[typeElement] ?? defaultConvert[typeElement];
            if (convert != null) {
              validateString += '''
              var $propertyName = $propertyValue;
              if ($propertyName != null) {
                $propertyValue = $convert('$propertyName', $propertyName);
              }
              ''';
            } else {
              validateString += '''
              var $propertyName = $propertyValue;
              if ($propertyName != null) {
                assert($propertyName is $propertyType, '$propertyName is not $propertyType');
              }
              ''';
            }
          }

          propertyString += '''
  $propertyType get $propertyName => $setValue;

  set $propertyName($propertyType $propertyName) => $propertyValue = $propertyName;

''';
          exportString += "map['$propertyName'] = $propertyValue;";
        }
      }

      if (genClass.isNotEmpty) {
        genClass = '''
class $genClass extends $superClass with $genMixin {
  $genClass([super.data]);
}
''';
      }
      return '''
$genClass
mixin $genMixin on $superClass {

${propertyString}
$customCode


  @override
  void \$default() {
    $initCode
    $initString
  }
  
  @override
  void \$validate() {
    $validateString
  }
  
  @override
  Map<String, Type> \$types() {
    var map = super.\$types();
    $typesString
    return map;
  }

  @override
  Map<String, dynamic> \$export() {
    var map = super.\$export();
    $exportString
    return map;
  }
}

    ''';
    }
  }
}

Map<String, String> defaultConvert = {
  'int': 'defaultIntConvert',
  'double': 'defaultDoubleConvert',
  'String': 'defaultStringConvert',
  'List<String>': 'stringListConvertBuilder()',
  'DateTime': 'dateTimeConvertBuilder()',
};

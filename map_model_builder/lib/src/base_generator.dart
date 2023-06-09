import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

import 'resolve_info.dart';

/// BaseGenerator
abstract class BaseGenerator<T> extends GeneratorForAnnotation<T> {
  /// mapClass
  String get mapClass => 'Map<String, dynamic>';

  /// customCode
  String get customCode => '';

  /// superClass
  String get superClass => 'MapModel';

  /// initCode
  String get initCode => '';

  /// modelRef
  String get modelRef => '\$data';

  String? customConvert(PropertyInfo propertyInfo) => null;

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is ClassElement) {
      Set<PropertyInfo> propertySet = {};
      Set<ConvertInfo> convertSet = {};

      var className = element.name;
      var genMixin = '_${className}Mixin';

      String genClass = '';
      var superType = element.supertype;
      if (superType == null || superType.element.name == 'Object') {
        genClass = '_${className}Impl';
      }

      ///
      var annConverts = annotation.peek('converts');
      var converts = <String, String>{};
      if (annConverts != null) {
        var mapValues = annConverts.mapValue;
        for (var entry in mapValues.entries) {
          var key = entry.key;
          var value = entry.value;

          var propertyTypeObject = key!.toTypeValue()!;
          var typeElement =
              propertyTypeObject.getDisplayString(withNullability: false);
          var convertName = value!.toStringValue()!;
          converts[typeElement] = convertName;

          convertSet.add(ConvertInfo(
            type: propertyTypeObject,
            convert: convertName,
          ));
        }
      }

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
              propertyType =
                  propertyTypeObject.getDisplayString(withNullability: true);
            }
          }

          /// property name
          var propertyName = item.getField('name')!.toStringValue()!;
          var propertyValue = "$modelRef['$propertyName']";

          var propertyInfo = PropertyInfo(
            propertyName: propertyName,
            propertyType: propertyTypeObject,
          );
          propertySet.add(propertyInfo);

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
              setValue = '''
              $setValue?.runtimeType.toString() == 'CastList<dynamic, $listEleType>'? $setValue: $setValue?.cast<$listEleType>()
              ''';
            }
          } else if (propertyTypeObject.isDartCoreMap) {
            /// castMap
            propertyTypeObject as ParameterizedType;
            var keyType = propertyTypeObject.typeArguments.first;
            var valueType = propertyTypeObject.typeArguments.last;
            if (keyType is! DynamicType || valueType is! DynamicType) {
              setValue = '''
              $setValue?.runtimeType.toString() == 'CastMap<dynamic, dynamic, $keyType, $valueType>'? $setValue: $setValue?.cast<$keyType, $valueType>()
              ''';
            }
          }

          var typeElement =
              propertyTypeObject.getDisplayString(withNullability: false);

          /// types
          typesString += '''
          map['$propertyName'] = $typeElement;
          ''';

          /// validate
          if (propertyTypeObject is! DynamicType) {
            var convertCode = "assert($propertyName is $propertyType, '$propertyName is not $propertyType');";

            var convert = converts[typeElement] ??
                defaultConvert(typeElement, propertyInfo);
            if (convert != null) {
              convertCode = "$propertyValue = $convert('$propertyName', $propertyName);";
            } else {
              var str = customConvert(propertyInfo);
              if (str != null) convertCode = '$propertyValue = $str;';
            }

            validateString += '''
              var $propertyName = $propertyValue;
              if ($propertyName != null) {
                $convertCode
              }
              ''';
          }

          propertyString += '''
            $propertyType get $propertyName => $setValue;
          
            set $propertyName($propertyType $propertyName) => $propertyValue = $propertyName;
          
          ''';
          exportString += "map['$propertyName'] = $propertyValue;";
        }
      }

      return '''
${genSupperClass(genClass, genMixin, propertySet, convertSet)}
mixin $genMixin on $superClass {

${propertyString}
$customCode


  ${genDefault(initCode, initString, propertySet, convertSet)}
  
  ${genValidate(validateString, propertySet, convertSet)}
  
  ${genTypes(typesString, propertySet, convertSet)}

  ${genExport(exportString, propertySet, convertSet)}
}

    ''';
    }
  }

  /// genSupperClass
  String genSupperClass(String genClass, String genMixin,
      Set<PropertyInfo> propertySet, Set<ConvertInfo> convertSet) {
    if (genClass.isNotEmpty) {
      return '''
      class $genClass extends $superClass with $genMixin {
        $genClass([super.data]);
      }
      ''';
    }
    return '';
  }

  /// genExport
  String genExport(String exportString, Set<PropertyInfo> propertySet,
      Set<ConvertInfo> convertSet) {
    if (exportString.isNotEmpty) {
      return '''
      @override
      Map<String, dynamic> \$export() {
        var map = super.\$export();
        $exportString
        return map;
      }
      ''';
    }
    return '';
  }

  /// genTypes
  String genTypes(String typesString, Set<PropertyInfo> propertySet,
      Set<ConvertInfo> convertSet) {
    if (typesString.isNotEmpty) {
      return '''
      @override
      Map<String, Type> \$types() {
        var map = super.\$types();
        $typesString
        return map;
      }
      ''';
    }
    return '';
  }

  /// genValidate
  String genValidate(String validateString, Set<PropertyInfo> propertySet,
      Set<ConvertInfo> convertSet) {
    if (validateString.isNotEmpty) {
      return '''
      @override
      void \$validate() {
        super.\$validate();
        $validateString
      }
      ''';
    }
    return '';
  }

  /// genDefault
  String genDefault(String initCode, String initString,
      Set<PropertyInfo> propertySet, Set<ConvertInfo> convertSet) {
    if (initCode.isNotEmpty || initString.isNotEmpty) {
      return '''
      @override
      void \$default() {
        super.\$default();
        $initString $initCode
      }
      ''';
    }
    return '';
  }

  /// defaultConvert
  String? defaultConvert(String typeElement, PropertyInfo propertyInfo) {
    switch (typeElement) {
      case 'int':
        return 'defaultIntConvert';
      case 'double':
        return 'defaultDoubleConvert';
      case 'String':
        return 'defaultStringConvert';
      case 'List<String>':
        return 'stringListConvertBuilder()';
      case 'DateTime':
        return 'dateTimeConvertBuilder()';
    }
    return null;
  }
}

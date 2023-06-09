# MapModel

`Dart` `flutter` [Pub Package](https://pub.dev/packages/map_model)

Language: [en](README.md) [cn](README-ZH_CN.md)

MapModel as its name suggests. Implement various Model objects using Map, such as Entity, VO, and DTO.

Its core idea is to use Map as storage and getter/setter as facade to control visibility.
In order to reduce the cost of object conversion, and even share the same instance, only with different visibility.
This is like using different types of pointers to interpret the same memory space, rather than maintaining data synchronization across multiple memory blocks.

## Setup

```yaml
dependencies:
  map_model: any

dev_dependencies:
  build_runner: any
  map_model_builder: any
```

## Example

```dart
import 'package:map_model/map_model.dart';

part 'your_model.g.dart';

@Model([
  Property<String?>('nullableString', value: '"123"'),
  Property<int>('fixInt'),
  Property('notType', value: '12'),
  Property<List<String>?>('listWithType'),
  Property<List?>('listNoType'),
  Property<Map<String?, dynamic>?>('mapWithType'),
  Property<Map?>('mapNoType'),
  Property<DateTime?>('dateTime'),
], converts: {
  List<String?>: 'toStringList',
})
class SuperModel extends _SuperModelImpl {
  /// use extends
  SuperModel([super.data]);
}

@Model([
  Property<String?>('subProperty', value: '"value form sub default"'),
])
class SubModel extends SuperModel with _SubModelMixin {
  /// use mixin
  SubModel([super.data]);
}

List<String> toStringList(String property, dynamic value) {
  return value.split(' ');
}


```

- `@Model.converts` define the convert of Type, see Default Support Type: List<String>, int, double, DateTime
- use extends superClass: _${yourClass}Impl
- use mixin: _${yourClass}Mixin

## Generate

```shell
flutter pub run build_runner build
```
or

```shell
dart run build_runner build
```

## Use MapModel

```dart
/// simple case
var customModel = SuperModel();
print(customModel.nullableString);

/// console see '123'

/// init data
Map<String, dynamic> data = {
  'nullableString': 'notDefaultValue',
  'unknownProperty': 'do not export',
  'listWithType': 'a b c', // auto convert, List<String> default sep is ' '
  'dateTime': '2023-05-19' // auto convert, DateTime accept String & int
};
var customModelWithInit = SuperModel(data);
print(customModelWithInit.nullableString);

/// console see 'notDefaultValue'

var subModel = SubModel(data);
print(subModel.$export());

/// do not export 'unknownProperty'
/// console see {nullableString: notDefaultValue, fixInt: null, notType: 12, listWithType: [a, b, c], listNoType: null, mapWithType: null, mapNoType: null, dateTime: 2023-05-19 00:00:00.000, subProperty: value form sub default}
var other = SuperModel();
subModel.$bindTo(other);

/// Different types have obtained the ability to synchronize data
/// change one of binds, other also changed
subModel.nullableString = 'from bind changed';

print(other.nullableString);

/// console see 'from bind changed'

```

- `$types` Show all field Types.
- `$export()` Only defined fields can be obtained.
- `$bindTo()` Used for conversion between models, sharing a single piece of data.
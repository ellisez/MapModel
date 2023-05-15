# MapModel

`Dart` `flutter` [Pub Package](https://pub.dev/packages/map_model)

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
import 'package:map_model/annotation.dart';

part 'your_model.g.dart';

@Model([
  Property<String?>('nullableString', value: '"123"'),
  Property<int>('fixInt'),
  Property('withValueConvert', value: '12', convert: 'convert'),
  Property<List<String?>?>('listWithType'),
  Property<List?>('listNoType'),
  Property<Map<String?, dynamic>?>('mapWithType'),
  Property<Map?>('mapNoType'),
])
class YourModel extends _YourModelImpl {
  YourModel([super.data]);
}

/// custom convert
convert(data) => data.toString();

```

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
import 'your_model.dart';

main() {
  /// simple case
  var customModel = YourModel();
  print(customModel.nullableString);
  /// console see 123

  /// init data
  var customModelWithInit = YourModel({'nullableString': 'notDefaultValue'});
  print(customModelWithInit.nullableString);
  /// console see notDefaultValue
}

```
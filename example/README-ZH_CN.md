# MapModel

`Dart` `flutter` [Pub Package](https://pub.dev/packages/map_model)

Language: [en](README.md) [cn](README-ZH_CN.md)

MapModel顾名思义就是，使用Map实现各种Model对象，如Entity、VO和DTO。

它的核心思想是使用Map作为存储，使用getter/setter作为门面来控制可见性。
为了降低对象转换的成本，甚至可以使用共享同一实例，只需要控制字段可见性即可。

这就像使用不同类型的指针来解释相同的内存空间，而不是在多个内存块之间保持数据同步，既开辟了大量内存空间，又浪费算力重复拷贝数据。
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
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
import 'package:map_model/map_model.dart';
part 'your_model.g.dart';

@Model([
  Property<String?>('nullableString', value: '"123"'),
  Property<int>('fixInt'),
  Property('notType', value: '12'),
  Property<List<String?>?>('listWithType'),
  Property<List?>('listNoType'),
  Property<Map<String?, dynamic>?>('mapWithType'),
  Property<Map?>('mapNoType'),
])
class SuperModel extends _SuperModelImpl {/// use extends
  SuperModel([super.data]);
}

@Model([
  Property<String?>('subProperty', value: '"value form sub default"'),
])
class SubModel extends SuperModel with _SubModelMixin {/// use mixin
  SubModel([super.data]);
}

```

- 使用类继承方式: _${yourClass}Impl
- 使用mixin混入: _${yourClass}Mixin

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
  var customModel = SuperModel();
  print(customModel.nullableString);
  /// console see 123

  /// init data
  Map<String, dynamic> data = {'nullableString': 'notDefaultValue', 'unknownProperty': 'do not export'};
  var customModelWithInit = SuperModel(data);
  print(customModelWithInit.nullableString);
  /// console see notDefaultValue

  var subModel = SubModel(data);
  print(subModel.export());
  /// do not export 'unknownProperty'
  /// console see {nullableString: notDefaultValue, fixInt: null, withValueConvert: 12, listWithType: null, listNoType: null, mapWithType: null, mapNoType: null, subProperty: value form sub default}

  var other = SuperModel();
  subModel.bindTo(other);/// Different types have obtained the ability to synchronize data
  /// change one of binds, other also changed
  subModel.nullableString = 'from bind changed';

  print(other.nullableString);
  /// console see 'from bind changed'
}

```

- `export()` 只会输出定义过的字段，不会输出其他model独有的字段.
- `bindTo()` 用于不同model间的转换，使之共享一个Map实例.
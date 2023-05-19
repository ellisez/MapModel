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

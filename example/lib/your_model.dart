import 'package:map_model/map_model.dart';
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
class SuperModel extends _SuperModelImpl {/// use extends
  SuperModel([super.data]);
}

convert(data) => data.toString();

@Model([
  Property<String?>('subProperty', value: '"value form sub default"'),
])
class SubModel extends SuperModel with _SubModelMixin {/// use mixin
  SubModel([super.data]);
}

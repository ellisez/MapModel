import 'package:map_model/annotation.dart';
import 'package:map_model_builder/generator/base.dart';

class MapModelGenerator extends BaseGenerator<Model> {

  @override
  String get mapClass => 'Map<String, dynamic>';
}

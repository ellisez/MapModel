library map_model_builder;

import 'package:build/build.dart';
import 'package:map_model_builder/src/map_model.dart';
import 'package:source_gen/source_gen.dart';

Builder mapModelBuilder(BuilderOptions options) =>
    SharedPartBuilder([MapModelGenerator()], 'map_model');

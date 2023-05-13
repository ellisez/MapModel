library map_model_build;

import 'package:build/build.dart';
import 'package:map_model_builder/generator.dart';
import 'package:source_gen/source_gen.dart';

Builder mapModelBuilder(BuilderOptions options) {
  return LibraryBuilder(MapModelGenerator());
}

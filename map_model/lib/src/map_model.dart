import 'package:meta/meta.dart';

abstract class MapModel {
  @protected
  // ignore: non_constant_identifier_names
  late Map<String, dynamic> $data;

  Map<String, Type> $types() => {};

  void $default() {}

  void $validate() {}

  Map<String, dynamic> $export() => {};

  void $bindTo(MapModel other) {
    other.$data = $data;
    $validate();
  }

  MapModel([Map<String, dynamic>? data]) : $data = data ?? {} {
    $default();
    $validate();
  }
}

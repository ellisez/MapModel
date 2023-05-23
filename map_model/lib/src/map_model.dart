import 'package:meta/meta.dart';

abstract class MapModel {
  /// do not use it out of subclass
  @protected
  // ignore: non_constant_identifier_names
  late Map<String, dynamic> $data;

  /// field types
  Map<String, Type> $types() => {};

  /// set default value
  void $default() {}

  /// validate field value
  void $validate() {}

  /// export data
  Map<String, dynamic> $export() => {};

  /// bind to another model
  void $bindTo(MapModel other) {
    other.$data = $data;
    $validate();
  }

  /// base MapModel class
  MapModel([Map<String, dynamic>? data]) : $data = data ?? {} {
    $default();
    $validate();
  }
}

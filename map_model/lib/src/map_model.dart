import 'package:meta/meta.dart';

abstract class MapModel {
  @protected
  // ignore: non_constant_identifier_names
  late Map<String, dynamic> $_data;

  void useDefault() {}

  void validate() {}

  Map<String, dynamic> export() => {};

  void bindTo(MapModel other) {
    other.$_data = $_data;
    validate();
  }

  MapModel([Map<String, dynamic>? data]): $_data = data ?? {} {
    useDefault();
    validate();
  }
}
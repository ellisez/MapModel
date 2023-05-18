import 'package:meta/meta.dart';

abstract class MapModel {
  @protected
  late Map<String, dynamic> $_data;

  void useDefault() {}

  Map<String, dynamic> export() => {};

  void bindTo(MapModel other) {
    other.$_data = $_data;
  }

  MapModel([Map<String, dynamic>? data]): $_data = data ?? {} {
    useDefault();
  }
}
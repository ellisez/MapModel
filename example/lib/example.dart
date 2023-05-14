import 'package:example/your_model.dart';

main() {
  /// simple case
  var customModel = YourModel();
  print(customModel.nullableString);
  /// console see 123

  /// init data
  var customModelWithInit = YourModel({'nullableString': 'notDefaultValue'});
  print(customModelWithInit.nullableString);
  /// console see notDefaultValue
}
import 'package:example/your_model.dart';

main() {
  /// simple case
  var customModel = SuperModel();
  print(customModel.nullableString);
  /// console see 123

  /// init data
  Map<String, dynamic> data = {'nullableString': 'notDefaultValue', 'unknownProperty': 'do not export'};
  var customModelWithInit = SuperModel(data);
  print(customModelWithInit.nullableString);
  /// console see notDefaultValue

  var subModel = SubModel(data);
  print(subModel.export());
  /// do not export 'unknownProperty'
  /// console see {nullableString: notDefaultValue, fixInt: null, withValueConvert: 12, listWithType: null, listNoType: null, mapWithType: null, mapNoType: null, subProperty: value form sub default}

  var other = SuperModel();
  subModel.bindTo(other);/// Different types have obtained the ability to synchronize data
  /// change one of binds, other also changed
  subModel.nullableString = 'from bind changed';

  print(other.nullableString);
  /// console see 'from bind changed'
}
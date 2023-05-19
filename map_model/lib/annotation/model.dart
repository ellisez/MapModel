/// Model annotation
class Model {
  /// type converts
  final Map<Type, String> converts;
  /// field settings
  final List<Property> properties;

  /// Model annotation
  const Model(this.properties, {this.converts  = const {}});
}

/// field setting
class Property<T> {
  /// field name
  final String name;
  /// field default value
  final String? value;

  /// field setting
  const Property(this.name, {this.value});

}

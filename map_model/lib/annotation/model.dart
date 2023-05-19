class Model {
  final Map<Type, String> converts;
  final List<Property> properties;

  const Model(this.properties, {this.converts  = const {}});
}

class Property<T> {
  final String name;
  final String? value;

  const Property(this.name, {this.value});

}

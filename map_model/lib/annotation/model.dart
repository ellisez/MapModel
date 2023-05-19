class Model {
  final List<Property> properties;

  const Model([this.properties = const []]);
}

class Property<T> {
  final String name;
  final String? value;

  const Property(this.name, {this.value});

}

class Model {
  final List<Property> properties;

  const Model([this.properties = const []]);
}

class Property<T> {
  final String name;
  final String? value;
  final String? convert;

  const Property(this.name, {this.value, this.convert});

}

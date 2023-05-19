/// defaultIntConvert
int defaultIntConvert(String _, dynamic value) {
  if (value is int) {
  } else if (value is String) {
    return int.parse(value);
  }
  return value;
}

/// defaultDoubleConvert
double defaultDoubleConvert(String _, dynamic value) {
  if (value is double) {
  } else if (value is String) {
    return double.parse(value);
  }
  return value;
}

/// defaultStringConvert
String defaultStringConvert(String _, dynamic value) {
  if (value is String) {
  } else {
    return value.toString();
  }
  return value;
}

/// dateTimeConvertBuilder
DateTime Function(String, dynamic) dateTimeConvertBuilder() {
  return (String property, dynamic value) {
    if (value is String) {
      return DateTime.parse(value);
    } else if (value is int) {
      return DateTime.fromMicrosecondsSinceEpoch(value);
    }
    throw AssertionError('$property <${value.runtimeType}> can not convert DateTime');
  };
}

/// stringListConvertBuilder
List<String> Function(String, dynamic) stringListConvertBuilder(
        [String sep = ' ']) =>
    (_, dynamic value) => value.split(sep);

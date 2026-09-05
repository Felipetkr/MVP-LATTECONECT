import 'dart:async';

final Map<String, String> _storage = <String, String>{};
final StreamController<void> _popStateController =
    StreamController<void>.broadcast();
String _location = '/';
String _title = 'LatteConect | Banco de leite digital';

String currentLocation() => _location;

Stream<void> get onPopState => _popStateController.stream;

void pushUrl(String url) {
  _location = url;
}

void replaceUrl(String url) {
  _location = url;
}

String? readLocalStorage(String key) => _storage[key];

void writeLocalStorage(String key, String value) {
  _storage[key] = value;
}

void setDocumentTitle(String title) {
  _title = title;
}

String documentTitleForTests() => _title;

void setLocationForTests(String url) {
  _location = url;
  _popStateController.add(null);
}

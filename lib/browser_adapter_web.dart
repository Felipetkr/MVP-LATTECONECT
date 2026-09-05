// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

String currentLocation() {
  final path = html.window.location.pathname?.isEmpty ?? true
      ? '/'
      : html.window.location.pathname!;
  final search = html.window.location.search ?? '';
  return '$path$search';
}

Stream<void> get onPopState => html.window.onPopState.map((_) {});

void pushUrl(String url) {
  html.window.history.pushState(null, '', url);
}

void replaceUrl(String url) {
  html.window.history.replaceState(null, '', url);
}

String? readLocalStorage(String key) => html.window.localStorage[key];

void writeLocalStorage(String key, String value) {
  html.window.localStorage[key] = value;
}

void setDocumentTitle(String title) {
  html.document.title = title;
}

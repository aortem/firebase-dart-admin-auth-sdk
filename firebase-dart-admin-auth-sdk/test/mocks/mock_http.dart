import 'dart:convert';
import 'dart:typed_data';
import 'package:ds_standard_features/ds_standard_features.dart' as http;

class MockResponse extends http.Response {
  MockResponse(int statusCode, String body, {Map<String, String>? headers})
    : super(body, statusCode, headers: headers ?? {});
}

class MockHttpClient implements http.Client {
  static final Map<String, MockResponse> _responses = {};

  @override
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final response = _responses[url.toString()];
    if (response != null) {
      return http.Response(
        response.body,
        response.statusCode,
        headers: {'content-type': 'application/json'},
      );
    }
    throw Exception('Unexpected POST $url with body=$body');
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final response = _responses[url.toString()];
    if (response != null) {
      return http.Response(
        response.body,
        response.statusCode,
        headers: {'content-type': 'application/json'},
      );
    }
    throw Exception('Unexpected GET $url');
  }

  // 👇 Stub unused methods (not needed for your tests)
  @override
  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => Future.error(UnimplementedError());

  @override
  Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => Future.error(UnimplementedError());

  @override
  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => Future.error(UnimplementedError());

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) =>
      Future.error(UnimplementedError());

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) =>
      Future.error(UnimplementedError());

  @override
  void close() {
    // no-op
  }

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) {
    throw UnimplementedError();
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw UnimplementedError();
  }
}

void overrideResponses(Map<String, MockResponse> responses) {
  MockHttpClient._responses.clear();
  MockHttpClient._responses.addAll(responses);
}

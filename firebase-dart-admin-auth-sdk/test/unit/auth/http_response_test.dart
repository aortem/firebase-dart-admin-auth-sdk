import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'package:firebase_dart_admin_auth_sdk/src/http_response.dart';

void main() {
  group('HttpResponse', () {
    test('constructor initializes values', () {
      final response = HttpResponse(
        statusCode: 200,
        body: {'message': 'Success'},
      );

      expect(response.statusCode, 200);
      expect(response.body, containsPair('message', 'Success'));
      expect(response.headers, isEmpty);
    });

    test('toMap converts the response to a map', () {
      final response = HttpResponse(
        statusCode: 200,
        body: {'message': 'Success'},
      );

      expect(response.toMap(), {
        'statusCode': 200,
        'body': {'message': 'Success'},
      });
    });

    test('toJson converts the response to JSON', () {
      final response = HttpResponse(
        statusCode: 200,
        body: {'message': 'Success'},
      );

      expect(
        response.toJson(),
        '{"statusCode":200,"body":{"message":"Success"}}',
      );
    });

    test('fromMap creates an instance from a map', () {
      final response = HttpResponse.fromMap({
        'statusCode': 200,
        'body': {'message': 'Success'},
      });

      expect(response.statusCode, 200);
      expect(response.body, containsPair('message', 'Success'));
    });

    test('fromJson creates an instance from JSON', () {
      final response = HttpResponse.fromJson(
        '{"statusCode":200,"body":{"message":"Success"}}',
      );

      expect(response.statusCode, 200);
      expect(response.body, containsPair('message', 'Success'));
    });

    test('fromMap rejects missing body', () {
      expect(
        () => HttpResponse.fromMap({'statusCode': 200}),
        throwsA(isA<TypeError>()),
      );
    });
  });
}

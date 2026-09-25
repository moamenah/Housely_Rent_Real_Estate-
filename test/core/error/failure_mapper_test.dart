import 'package:flutter_test/flutter_test.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/error/failure.dart';
import 'package:housely/core/error/failure_mapper.dart';

void main() {
  group('FailureMapper', () {
    test('maps NetworkException to NetworkFailure', () {
      final failure = FailureMapper.map(const NetworkException());
      expect(failure, isA<NetworkFailure>());
      expect(failure.message, contains('internet'));
    });

    test('maps ServerException to ServerFailure keeping its message', () {
      final failure = FailureMapper.map(const ServerException('Boom'));
      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'Boom');
    });

    test('maps NotFoundException to NotFoundFailure', () {
      expect(FailureMapper.map(const NotFoundException()), isA<NotFoundFailure>());
    });

    test('maps ParsingException to ParsingFailure', () {
      expect(FailureMapper.map(const ParsingException()), isA<ParsingFailure>());
    });

    test('falls back to UnknownFailure for unexpected errors', () {
      final failure = FailureMapper.map(StateError('unexpected'));
      expect(failure, isA<UnknownFailure>());
      expect(failure.message, contains('unexpected'));
    });
  });
}

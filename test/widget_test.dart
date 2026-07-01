import 'package:flutter_test/flutter_test.dart';
import 'package:alu_intern/core/utils/validators.dart';

void main() {
  group('student email validation', () {
    test('accepts an ALU student email regardless of case', () {
      expect(Validators.aluStudentEmail('Student@ALUSTUDENT.COM'), isNull);
    });

    test('rejects non-ALU and lookalike domains', () {
      expect(Validators.aluStudentEmail('student@gmail.com'), isNotNull);
      expect(
        Validators.aluStudentEmail('student@alustudent.com.fake'),
        isNotNull,
      );
    });
  });

  group('startup verification input validation', () {
    test('requires a complete http or https website URL', () {
      expect(Validators.website('https://startup.example'), isNull);
      expect(Validators.website('startup.example'), isNotNull);
      expect(Validators.website('ftp://startup.example'), isNotNull);
      expect(Validators.website(''), isNotNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/features/auth/domain/validators.dart';

void main() {
  group('phone validator', () {
    test('removes one leading zero, spaces and dashes', () {
      expect(normalizePhone('0 925-413-5592'), '9254135592');
      expect(validatePhone('0 925-413-5592'), isNull);
      expect(validatePhone('00925135592'), AuthValidationError.invalidPhone);
    });
    test('accepts 9 then seven to nine digits only', () {
      expect(validatePhone('91234567'), isNull);
      expect(validatePhone('9123456789'), isNull);
      expect(validatePhone('812345678'), isNotNull);
      expect(validatePhone('9123456'), isNotNull);
      expect(validatePhone('91234567890'), isNotNull);
    });
  });
  group('OTP validator', () {
    test('requires six digits', () {
      expect(validateOtp('123456'), isNull);
      expect(validateOtp('12345'), isNotNull);
      expect(validateOtp('12345a'), isNotNull);
    });
  });
  group('name validators', () {
    test('requires first name and allows spaces and Myanmar letters', () {
      expect(validateFirstName('  Hania  '), isNull);
      expect(validateFirstName('မေသက်'), isNull);
      expect(validateFirstName(''), isNotNull);
      expect(validateFirstName('May3'), isNotNull);
      expect(validateFirstName('a' * 51), isNotNull);
    });
    test('last name is optional but otherwise follows same rule', () {
      expect(validateLastName('  '), isNull);
      expect(validateLastName('Aung'), isNull);
      expect(validateLastName('Aung2'), isNotNull);
    });
  });
  group('birth date validator', () {
    final today = DateTime(2026, 11, 10);
    test(
      'accepts exact thirteenth birthday',
      () => expect(
        validateBirthDate(DateTime(2013, 11, 10), today: today),
        isNull,
      ),
    );
    test(
      'rejects one day short of thirteen',
      () => expect(
        validateBirthDate(DateTime(2013, 11, 11), today: today),
        isNotNull,
      ),
    );
    test(
      'rejects future date',
      () => expect(
        validateBirthDate(DateTime(2026, 11, 11), today: today),
        isNotNull,
      ),
    );
    test('accepts leap day only on a valid leap year', () {
      expect(validateBirthDate(DateTime(2000, 2, 29), today: today), isNull);
      expect(validateBirthParts(2001, 2, 29, today: today), isNotNull);
    });
    test('parses the three design fields and validates their boundaries', () {
      expect(parseBirthDate('May', '1', '1980'), DateTime(1980, 5, 1));
      expect(parseBirthDate('5', '1', '1980'), DateTime(1980, 5, 1));
      expect(parseBirthDate('Feb', '29', '2000'), DateTime(2000, 2, 29));
      expect(parseBirthDate('Feb', '29', '2001'), isNull);
      expect(
        validateBirthInputs('', '', '', today: today),
        AuthValidationError.birthDateRequired,
      );
      expect(
        validateBirthInputs('May', '32', '1980', today: today),
        AuthValidationError.invalidBirthDate,
      );
      expect(validateBirthInputs('May', '1', '2013', today: today), isNull);
      expect(
        validateBirthInputs('Nov', '11', '2026', today: today),
        AuthValidationError.futureBirthDate,
      );
      expect(validateBirthInputs('Nov', '10', '2013', today: today), isNull);
    });
    test(
      'rejects impossible calendar date',
      () => expect(
        validateBirthParts(2020, 4, 31, today: today),
        AuthValidationError.invalidBirthDate,
      ),
    );
    test('rejects years outside the supported calendar range', () {
      expect(
        validateBirthParts(0, 1, 1, today: today),
        AuthValidationError.invalidBirthDate,
      );
      expect(
        validateBirthParts(10000, 1, 1, today: today),
        AuthValidationError.invalidBirthDate,
      );
    });
    test(
      'rejects missing date',
      () => expect(validateBirthDate(null, today: today), isNotNull),
    );
  });
}

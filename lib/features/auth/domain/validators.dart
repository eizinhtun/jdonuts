import 'package:characters/characters.dart';

const minimumAge = 13;
final RegExp _personName = RegExp(r"^[\p{L}\p{M} ]+$", unicode: true);

enum AuthValidationError {
  invalidPhone,
  invalidOtp,
  firstNameRequired,
  invalidName,
  birthDateRequired,
  invalidBirthDate,
  futureBirthDate,
  underage,
}

String normalizePhone(String input) {
  var value = input.replaceAll(RegExp(r'[\s-]'), '');
  if (value.startsWith('0')) value = value.substring(1);
  return value;
}

AuthValidationError? validatePhone(String input) {
  final value = normalizePhone(input);
  if (!RegExp(r'^9\d{7,9}$').hasMatch(value)) {
    return AuthValidationError.invalidPhone;
  }
  return null;
}

AuthValidationError? validateOtp(String input) =>
    RegExp(r'^\d{6}$').hasMatch(input) ? null : AuthValidationError.invalidOtp;

AuthValidationError? validateFirstName(String input) {
  final value = input.trim();
  if (value.isEmpty) return AuthValidationError.firstNameRequired;
  if (value.characters.length > 50 || !_personName.hasMatch(value)) {
    return AuthValidationError.invalidName;
  }
  return null;
}

AuthValidationError? validateLastName(String input) {
  final value = input.trim();
  if (value.isEmpty) return null;
  if (value.characters.length > 50 || !_personName.hasMatch(value)) {
    return AuthValidationError.invalidName;
  }
  return null;
}

AuthValidationError? validateBirthDate(DateTime? date, {DateTime? today}) =>
    date == null
    ? AuthValidationError.birthDateRequired
    : validateBirthParts(date.year, date.month, date.day, today: today);

AuthValidationError? validateBirthParts(
  int year,
  int month,
  int day, {
  DateTime? today,
}) {
  if (month < 1 || month > 12 || day < 1) {
    return AuthValidationError.invalidBirthDate;
  }
  final daysInMonth = DateTime(year, month + 1, 0).day;
  if (day > daysInMonth) return AuthValidationError.invalidBirthDate;
  final date = DateTime(year, month, day);
  final now = today ?? DateTime.now();
  if (date.isAfter(DateTime(now.year, now.month, now.day))) {
    return AuthValidationError.futureBirthDate;
  }
  var age = now.year - year;
  if (now.month < month || (now.month == month && now.day < day)) age--;
  if (age < minimumAge) return AuthValidationError.underage;
  return null;
}

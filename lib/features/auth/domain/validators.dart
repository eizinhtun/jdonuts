const minimumAge = 13;
final RegExp _personName = RegExp(r"^[\p{L}\p{M} ]{1,50}$", unicode: true);

String normalizePhone(String input) {
  var value = input.replaceAll(RegExp(r'[\s-]'), '');
  if (value.startsWith('0')) value = value.substring(1);
  return value;
}

String? validatePhone(String input) {
  final value = normalizePhone(input);
  if (!RegExp(r'^9\d{7,9}$').hasMatch(value))
    return 'Enter a valid Myanmar mobile number.';
  return null;
}

String? validateOtp(String input) =>
    RegExp(r'^\d{6}$').hasMatch(input) ? null : 'Enter all 6 digits.';

String? validateFirstName(String input) {
  final value = input.trim();
  if (value.isEmpty) return 'First name is required.';
  if (value.length > 50 || !_personName.hasMatch(value))
    return 'Use up to 50 letters and spaces.';
  return null;
}

String? validateLastName(String input) {
  final value = input.trim();
  if (value.isEmpty) return null;
  if (value.length > 50 || !_personName.hasMatch(value))
    return 'Use up to 50 letters and spaces.';
  return null;
}

String? validateBirthDate(DateTime? date, {DateTime? today}) => date == null
    ? 'Choose your date of birth.'
    : validateBirthParts(date.year, date.month, date.day, today: today);

String? validateBirthParts(int year, int month, int day, {DateTime? today}) {
  if (month < 1 || month > 12 || day < 1) return 'Choose a real calendar date.';
  final daysInMonth = DateTime(year, month + 1, 0).day;
  if (day > daysInMonth) return 'Choose a real calendar date.';
  final date = DateTime(year, month, day);
  final now = today ?? DateTime.now();
  if (date.isAfter(DateTime(now.year, now.month, now.day)))
    return 'Date cannot be in the future.';
  var age = now.year - year;
  if (now.month < month || (now.month == month && now.day < day)) age--;
  if (age < minimumAge) return 'You must be at least $minimumAge years old.';
  return null;
}

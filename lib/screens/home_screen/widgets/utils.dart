

String extractNameFromEmail(String email) {
  final nameInQuotesRegExp = RegExp(r'"([^"]*)');
  final nameMatch = nameInQuotesRegExp.firstMatch(email);
  if (nameMatch != null && nameMatch.groupCount >= 1) {
    return nameMatch.group(1) ?? 'No name';
  } else {
    final nameRegExp = RegExp(r'^(.*?)<');
    final match = nameRegExp.firstMatch(email);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)?.trim() ?? 'No name';
    } else if (email.contains("@")) {
      return email.split("@")[0];
    }
  }
  return 'No name';
}

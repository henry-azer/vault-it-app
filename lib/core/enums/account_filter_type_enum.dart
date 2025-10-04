enum AccountFilterType {
  all('all'),
  weak('weak'),
  stale('stale'),
  favorites('favorites');

  final String value;
  const AccountFilterType(this.value);

  static AccountFilterType fromString(String value) {
    return AccountFilterType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => AccountFilterType.all,
    );
  }
}

enum AccountSortType {
  dateAdded('date'),
  name('name'),
  lastModified('modified');

  final String value;
  const AccountSortType(this.value);

  static AccountSortType fromString(String value) {
    return AccountSortType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => AccountSortType.dateAdded,
    );
  }
}

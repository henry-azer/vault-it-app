enum PasswordStrength {
  veryWeak(0.0, 0.2),
  weak(0.2, 0.4),
  fair(0.4, 0.6),
  good(0.6, 0.8),
  strong(0.8, 1.0);

  final double min;
  final double max;
  const PasswordStrength(this.min, this.max);

  static PasswordStrength fromValue(double value) {
    if (value <= 0.2) return PasswordStrength.veryWeak;
    if (value <= 0.4) return PasswordStrength.weak;
    if (value <= 0.6) return PasswordStrength.fair;
    if (value <= 0.8) return PasswordStrength.good;
    return PasswordStrength.strong;
  }
}

/// Exact arithmetic for locally entered decimal values and derived ratios.
class Decimal implements Comparable<Decimal> {
  Decimal._(BigInt numerator, BigInt denominator)
    : assert(denominator > BigInt.zero),
      numerator = numerator ~/ numerator.gcd(denominator),
      denominator = denominator ~/ numerator.gcd(denominator);

  factory Decimal.integer(int value) =>
      Decimal._(BigInt.from(value), BigInt.one);

  final BigInt numerator;
  final BigInt denominator;

  static final zero = Decimal.integer(0);
  static final one = Decimal.integer(1);

  static Decimal? parse(String source) {
    final value = source.trim().replaceAll('٫', '.').replaceAllMapped(
      RegExp('[٠-٩۰-۹]'),
      (match) {
        final code = match[0]!.codeUnitAt(0);
        return (code - (code >= 0x06f0 ? 0x06f0 : 0x0660)).toString();
      },
    );
    if (!RegExp(r'^\d{1,12}(?:\.\d{1,6})?$').hasMatch(value)) return null;
    final parts = value.split('.');
    final digits = parts.length == 1 ? 0 : parts.last.length;
    return Decimal._(BigInt.parse(parts.join()), BigInt.from(10).pow(digits));
  }

  Decimal operator +(Decimal other) => Decimal._(
    numerator * other.denominator + other.numerator * denominator,
    denominator * other.denominator,
  );
  Decimal operator -(Decimal other) =>
      this + Decimal._(-other.numerator, other.denominator);
  Decimal operator *(Decimal other) =>
      Decimal._(numerator * other.numerator, denominator * other.denominator);
  Decimal operator /(Decimal other) => Decimal._(
    numerator * other.denominator * BigInt.from(other.numerator.sign),
    denominator * other.numerator.abs(),
  );
  @override
  int compareTo(Decimal other) =>
      (numerator * other.denominator).compareTo(other.numerator * denominator);
  bool get positive => numerator > BigInt.zero;
  bool get whole => denominator == BigInt.one;

  Decimal atLeast(Decimal other) => compareTo(other) >= 0 ? this : other;

  Decimal rounded([int places = 2]) {
    final scale = BigInt.from(10).pow(places);
    final scaled = numerator.abs() * scale;
    final extra = (scaled % denominator) * BigInt.two >= denominator
        ? BigInt.one
        : BigInt.zero;
    return Decimal._(
      (scaled ~/ denominator + extra) * BigInt.from(numerator.sign),
      scale,
    );
  }

  Decimal ceiling([int places = 0]) {
    final scale = BigInt.from(10).pow(places);
    final scaled = numerator * scale;
    final extra =
        scaled > BigInt.zero && scaled.remainder(denominator) != BigInt.zero
        ? BigInt.one
        : BigInt.zero;
    return Decimal._(scaled ~/ denominator + extra, scale);
  }

  String format([int places = 2]) {
    final value = rounded(places);
    final scale = BigInt.from(10).pow(places);
    final digits = (value.numerator.abs() * scale ~/ value.denominator)
        .toString()
        .padLeft(places + 1, '0');
    final sign = value.numerator.isNegative ? '-' : '';
    if (places == 0) return '$sign$digits';
    final split = digits.length - places;
    return '$sign${digits.substring(0, split)}.${digits.substring(split)}';
  }
}

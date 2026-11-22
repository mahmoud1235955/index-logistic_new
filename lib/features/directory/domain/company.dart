class Company {
  const Company({required this.name, required this.category, required this.location, required this.initials, required this.accent, this.verified = true});
  final String name;
  final String category;
  final String location;
  final String initials;
  final int accent;
  final bool verified;
}

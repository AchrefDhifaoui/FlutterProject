class CustomUser {
  final String id;
  final String fullName;
  final String email;
  final double latitude;
  final double longitude;
  final List<String> games;

  CustomUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.latitude,
    required this.longitude,
    required this.games,
  });
}

class User {
  final int id;
  final String name;
  final String email;
  final String city;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.city,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>;
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      city: address['city'],
    );
  }
}

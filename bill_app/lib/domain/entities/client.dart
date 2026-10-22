import 'dart:convert';

class Client {
  String id;
  String name;
  String nit;
  String email;

  Client({
    required this.id,
    required this.name,
    required this.nit,
    required this.email,
  });

  factory Client.fromJson(String json) => Client.fromMap(jsonDecode(json));

  String toJson() => jsonEncode(toMap());

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      nit: map['nit'],
      email: map['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nit': nit,
      'email': email,
    };
  }
}

class Investisseur {
  final int? id; // Champ id
  String email;
  String nom;
  String prenom;
  String address;
  String tel;
  String password;

  Investisseur({
    this.id,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.address,
    required this.tel,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'address': address,
      'tel': tel,
      'password': password,
    };
  }

  static Investisseur fromJson(Map<String, dynamic> json) {
    return Investisseur(
      id: json['id'],
      email: json['email'],
      nom: json['nom'],
      prenom: json['prenom'],
      address: json['address'],
      tel: json['tel'],
      password: json['password'],
    );
  }
}

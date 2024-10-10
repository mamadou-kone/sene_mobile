class Agriculteur {
  final String id; // Champ id
  String email;
  String nom;
  String prenom;
  String address;
  String tel;
  String password;

  Agriculteur({
    required this.id, // id requis dans le constructeur
    required this.email,
    required this.nom,
    required this.prenom,
    required this.address,
    required this.tel,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Inclure l'id dans la conversion JSON
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'address': address,
      'tel': tel,
      'password': password,
    };
  }

  static Agriculteur fromJson(Map<String, dynamic> json) {
    return Agriculteur(
      id: json['id'], // Assurez-vous que 'id' est présent dans le JSON
      email: json['email'],
      nom: json['nom'],
      prenom: json['prenom'],
      address: json['address'],
      tel: json['tel'],
      password: json['password'],
    );
  }

  // Méthode pour créer un objet Agriculteur avec uniquement l'ID
  static Map<String, dynamic> toIdJson(String id) {
    return {
      'id': id,
    };
  }
}

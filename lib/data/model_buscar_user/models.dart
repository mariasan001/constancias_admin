class Role {
  final int id;
  final String description;

  Role({required this.id, required this.description});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
    };
  }
}

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String? workUnit;
  final String? rfc;
  final String? curp;
  final String? bank;
  final String? jobPlaza;
  final String? jobCode;
  final String? occupationDate;
  final String? idSS;
  final String? phone;
  final String? address;
  final List<Role> roles;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    this.workUnit,
    this.rfc,
    this.curp,
    this.bank,
    this.jobPlaza,
    this.jobCode,
    this.occupationDate,
    this.idSS,
    this.phone,
    this.address,
    required this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      workUnit: json['workUnit'],
      rfc: json['rfc'],
      curp: json['curp'],
      bank: json['bank'],
      jobPlaza: json['jobPlaza'],
      jobCode: json['jobCode'],
      occupationDate: json['occupationDate'],
      idSS: json['idSS'],
      phone: json['phone'],
      address: json['address'],
      roles: (json['roles'] as List<dynamic>)
          .map((role) => Role.fromJson(role))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'workUnit': workUnit,
      'rfc': rfc,
      'curp': curp,
      'bank': bank,
      'jobPlaza': jobPlaza,
      'jobCode': jobCode,
      'occupationDate': occupationDate,
      'idSS': idSS,
      'phone': phone,
      'address': address,
      'roles': roles.map((r) => r.toJson()).toList(),
    };
  }
}

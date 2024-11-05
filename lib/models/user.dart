import 'package:hive/hive.dart';

part 'user.g.dart';  // This file will be generated automatically

@HiveType(typeId: 0)  // Each model requires a unique typeId
class User {
  @HiveField(0)
  final String email;

  @HiveField(1)
  final String password;

  @HiveField(2)
  final String role;

  var key;

  User({
    required this.email,
    required this.password,
    required this.role, required String name,
  });

  get name => null;

  

 
}

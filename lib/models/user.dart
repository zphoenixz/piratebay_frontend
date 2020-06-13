import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
    User({
        this.userId,
        this.username,
        this.email,
        this.phoneNumber,
        this.catUserStatus,
    });

    int userId;
    String username;
    String email;
    String phoneNumber;
    String catUserStatus;

    factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json["userId"],
        username: json["username"],
        email: json["email"],
        phoneNumber: json["phoneNumber"],
        catUserStatus: json["catUserStatus"],
    );

    Map<String, dynamic> toJson() => {
        "userId": userId,
        "username": username,
        "email": email,
        "phoneNumber": phoneNumber,
        "catUserStatus": catUserStatus,
    };
}

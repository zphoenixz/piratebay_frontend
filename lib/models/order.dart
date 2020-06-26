// To parse this JSON data, do
//
//     final order = orderFromJson(jsonString);

import 'dart:convert';

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());

class Order {
    Order({
        this.orderId,
        this.address,
        this.providerOrder,
        this.warehouseId,
        this.userOrder,
        this.orderDate,
    });

    int orderId;
    String address;
    ProviderOrder providerOrder;
    int warehouseId;
    UserOrder userOrder;
    String orderDate;

    factory Order.fromJson(Map<String, dynamic> json) => Order(
        orderId: json["orderId"],
        address: json["address"],
        providerOrder: ProviderOrder.fromJson(json["providerOrder"]),
        warehouseId: json["warehouseId"],
        userOrder: UserOrder.fromJson(json["userOrder"]),
        orderDate: json["orderDate"],
    );

    Map<String, dynamic> toJson() => {
        "orderId": orderId,
        "address": address,
        "providerOrder": providerOrder.toJson(),
        "warehouseId": warehouseId,
        "userOrder": userOrder.toJson(),
        "orderDate": orderDate,
    };
}

class ProviderOrder {
    ProviderOrder({
        this.providerId,
        this.providerName,
        this.catCountry,
    });

    int providerId;
    int providerName;
    String catCountry;

    factory ProviderOrder.fromJson(Map<String, dynamic> json) => ProviderOrder(
        providerId: json["providerId"],
        providerName: json["providerName"],
        catCountry: json["catCountry"],
    );

    Map<String, dynamic> toJson() => {
        "providerId": providerId,
        "providerName": providerName,
        "catCountry": catCountry,
    };
}

class UserOrder {
    UserOrder({
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

    factory UserOrder.fromJson(Map<String, dynamic> json) => UserOrder(
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
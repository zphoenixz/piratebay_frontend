import 'dart:convert';

ProductOrder productOrderFromJson(String str) => ProductOrder.fromJson(json.decode(str));

String productOrderToJson(ProductOrder data) => json.encode(data.toJson());

class ProductOrder {
    ProductOrder({
        this.productOrderId,
        this.orderId,
        this.product,
        this.productId,
        this.unitPrice,
        this.qttyRequested,
        this.qttyCommit,
        this.qttyReceived,
    });

    int productOrderId;
    int orderId;
    Product product;
    dynamic productId;
    double unitPrice;
    int qttyRequested;
    int qttyCommit;
    int qttyReceived;

    factory ProductOrder.fromJson(Map<String, dynamic> json) => ProductOrder(
        productOrderId: json["productOrderId"],
        orderId: json["orderId"],
        product: Product.fromJson(json["product"]),
        productId: json["productId"],
        unitPrice: json["unitPrice"],
        qttyRequested: json["qttyRequested"],
        qttyCommit: json["qttyCommit"],
        qttyReceived: json["qttyReceived"],
    );

    Map<String, dynamic> toJson() => {
        "productOrderId": productOrderId,
        "orderId": orderId,
        "product": product.toJson(),
        "productId": productId,
        "unitPrice": unitPrice,
        "qttyRequested": qttyRequested,
        "qttyCommit": qttyCommit,
        "qttyReceived": qttyReceived,
    };
}

class Product {
    Product({
        this.productId,
        this.productCode,
        this.catProductType,
        this.productName,
        this.productDescription,
        this.productAttributes,
    });

    int productId;
    String productCode;
    String catProductType;
    String productName;
    dynamic productDescription;
    String productAttributes;

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        productId: json["productId"],
        productCode: json["productCode"],
        catProductType: json["catProductType"],
        productName: json["productName"],
        productDescription: json["productDescription"],
        productAttributes: json["productAttributes"],
    );

    Map<String, dynamic> toJson() => {
        "productId": productId,
        "productCode": productCode,
        "catProductType": catProductType,
        "productName": productName,
        "productDescription": productDescription,
        "productAttributes": productAttributes,
    };
}
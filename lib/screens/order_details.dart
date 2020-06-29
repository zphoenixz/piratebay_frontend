import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:piratebay/models/order.dart';
import 'package:piratebay/models/productOrder.dart';
import 'package:piratebay/providers/orders.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class OrderDetailsScreen extends StatefulWidget {
  @override
  _OrderDetailsScreenState createState() => new _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Order _order;
  Orders _ordersProvider;
  bool isLoading = false;
  String _nextOrderStatus;

  List<ProductOrder> _productOrder = [];

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final ValueChanged _onChanged = (val) => print(val);

  final GlobalKey<RefreshIndicatorState> refreshKey =
      new GlobalKey<RefreshIndicatorState>();
  // Orders _orders;

  @override
  void initState() {
    super.initState();
    _ordersProvider = Provider.of<Orders>(context, listen: false);
    _order = _ordersProvider.chosenOrder;

    print('ordered at ${_order.orderDate}');
    print('prepared at ${_order.preparedDate}');
    print('shipped at ${_order.shippedDate}');
    print('delivered at ${_order.deliveredDate}');
    if (_order.preparedDate == null) {
      _nextOrderStatus = "prepared";
    } else if (_order.shippedDate == null) {
      _nextOrderStatus = "shipped";
    } else if (_order.deliveredDate == null) {
      _nextOrderStatus = "delivered";
    }

    refreshList();
  }

  Future<void> refreshList() async {
    List<ProductOrder> listAux =
        await _ordersProvider.getOrderProducts(_order.orderId);
    // print(listAux);
    // print(listAux[0]);
    // print(listAux[0].productOrderId);
    // print(listAux.length);
    if (listAux != null) {
      setState(() {
        _productOrder = listAux;
      });
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Widget buildSectionTitle(
      BuildContext context, String text, int align, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, left: 10),
      child: Align(
        alignment: align == 0 ? Alignment.center : Alignment.centerLeft,
        child: Container(
          child: Text(
            text,
            style: TextStyle(
                fontSize: fontSize,
                fontWeight: align == 0 ? FontWeight.normal : FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget buildOrderFields(BuildContext context, String text, double fontSize,
      bool disabled, String initialValue, String attribute, int max) {
    return Container(
      width: 200,
      child: FormBuilderTextField(
        attribute: attribute,
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: text,
          fillColor: Colors.blueAccent,
        ),
        onChanged: _onChanged,
        valueTransformer: (text) {
          return text == null ? null : num.tryParse(text);
        },
        readOnly: disabled,
        validators: [
          FormBuilderValidators.required(errorText: 'This field reqired'),
          FormBuilderValidators.numeric(errorText: 'Only numbers'),
          FormBuilderValidators.min(0, errorText: 'Less than 0'),
          FormBuilderValidators.max(max, errorText: 'Greater than max.'),
        ],
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget buildContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(5),
      height: _nextOrderStatus != null ? 390 : 420,
      // width: 300,
      child: child,
    );
  }

  _onAlertButtonsPressed(
    context,
  ) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Update",
      desc: "Are you sure to update this order?",
      buttons: [
        DialogButton(
          child: Text(
            "No",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.red[300],
        ),
        DialogButton(
          child: Text(
            "Yes",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
            updateOrder();
            Navigator.of(context).pop();
          },
          color: Colors.green[300],
        )
      ],
    ).show();
  }

  Future<void> updateOrder() async {
    setState(() {
      isLoading = true;
    });
    _productOrder.forEach((productOrder) async {
      final qttyCommit = _fbKey
          .currentState.value["${productOrder.product.productName}_prepared"];
      final qttyReceived = _fbKey
          .currentState.value["${productOrder.product.productName}_received"];
      print('qttyCommit: $qttyCommit');
      print('qttyCommit: $qttyReceived');
      final response = await _ordersProvider.updateOrderProductQty(
          _order.orderId,
          productOrder.productOrderId,
          qttyCommit,
          qttyReceived);
      if (response == null) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      // await Future.delayed(Duration(seconds: 1));
    });

    final response = await _ordersProvider.updateOrderStatus(
        _order.orderId, _nextOrderStatus);
    if (response == null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${_order.orderId}'),
      ),
      body: _productOrder.length != 0
          ? LoadingOverlay(
              isLoading: isLoading,
              opacity: 0.5,
              child: SingleChildScrollView(
                // key: refreshKey,
                child: Column(
                  children: <Widget>[
                    buildSectionTitle(context, 'Details', 1, 20),
                    buildSectionTitle(
                        context, 'Status: ${_order.orderStatus}', 0, 15),
                    buildSectionTitle(
                        context,
                        'Ordered at: ${DateFormat.yMEd().add_jms().format(DateTime.parse(_order.orderDate))}',
                        0,
                        15),
                    _order.preparedDate != null
                        ? buildSectionTitle(
                            context,
                            'Prepared at: ${DateFormat.yMEd().add_jms().format(DateTime.parse(_order.preparedDate))}',
                            0,
                            15)
                        : Container(),
                    _order.shippedDate != null
                        ? buildSectionTitle(
                            context,
                            'Shipped at: ${DateFormat.yMEd().add_jms().format(DateTime.parse(_order.shippedDate))}',
                            0,
                            15)
                        : Container(),
                    _order.deliveredDate != null
                        ? buildSectionTitle(
                            context,
                            'Delivered at: ${DateFormat.yMEd().add_jms().format(DateTime.parse(_order.deliveredDate))}',
                            0,
                            15)
                        : Container(),
                    buildSectionTitle(context, 'Items', 1, 20),
                    buildContainer(
                      FormBuilder(
                        key: _fbKey,
                        child: ListView.builder(
                          itemBuilder: (ctx, index) => Card(
                            color: Colors.lightBlue[50],
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 10,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child:
                                        Image.asset('assets/icons/movie.png'),
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Text(
                                        _productOrder[index]
                                            .product
                                            .productName,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      buildOrderFields(
                                          context,
                                          "Qty. requested: ",
                                          15,
                                          true,
                                          _productOrder[index]
                                              .qttyRequested
                                              .toString(),
                                          "${_productOrder[index].product.productName}_requested", //_order.preparedDate != null ?
                                          _productOrder[index].qttyRequested),
                                      _order.preparedDate != null
                                          ? buildOrderFields(
                                              context,
                                              "Qty. prepared: ",
                                              15,
                                              true,
                                              _productOrder[index]
                                                  .qttyCommit
                                                  .toString(),
                                              "${_productOrder[index].product.productName}_prepared",
                                              _productOrder[index]
                                                  .qttyRequested)
                                          : buildOrderFields(
                                              context,
                                              "Qty. prepared: ",
                                              15,
                                              false,
                                              _productOrder[index]
                                                  .qttyRequested
                                                  .toString(),
                                              "${_productOrder[index].product.productName}_prepared",
                                              _productOrder[index]
                                                  .qttyRequested),
                                      _order.shippedDate == null
                                          ? Container()
                                          : _order.deliveredDate != null
                                              ? buildOrderFields(
                                                  context,
                                                  "Qty. delivered: ",
                                                  15,
                                                  true,
                                                  _productOrder[index]
                                                      .qttyReceived
                                                      .toString(),
                                                  "${_productOrder[index].product.productName}_delivered",
                                                  _productOrder[index]
                                                      .qttyCommit)
                                              : buildOrderFields(
                                                  context,
                                                  "Qty. delivered: ",
                                                  15,
                                                  false,
                                                  _productOrder[index]
                                                      .qttyCommit
                                                      .toString(),
                                                  "${_productOrder[index].product.productName}_delivered",
                                                  _productOrder[index]
                                                      .qttyCommit),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          itemCount: _productOrder.length,
                        ),
                      ),
                    ),
                    _nextOrderStatus != null
                        ? ButtonTheme(
                            minWidth: 400,
                            height: 45,
                            child: FlatButton(
                              onPressed: () {
                                if (_fbKey.currentState.saveAndValidate()) {
                                  print(_fbKey.currentState.value);
                                  _onAlertButtonsPressed(
                                    context,
                                  );
                                } else {
                                  print(_fbKey.currentState.value);
                                  print('validation failed');
                                }
                              },
                              color: Colors.blueAccent,
                              child: Text(
                                'Set as $_nextOrderStatus',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}

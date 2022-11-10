class InAppPurchaseItem {
  final String id;
  final String price;
  final String title;
  final int priceMicros;

  const InAppPurchaseItem(this.id, this.price, this.title, this.priceMicros);

  factory InAppPurchaseItem.fromMap(final Map<dynamic, dynamic> value) {
    final id = value["id"] as String;
    final price = value["price"] as String;
    final title = value["title"] as String;
    final priceMicros = value["priceMicros"] as int;
    return InAppPurchaseItem(id, price, title, priceMicros);
  }
}

class InAppPurchaseItem {
  final String id;
  final String price;
  final String title;
  final String originalPrice;

  InAppPurchaseItem(this.id, this.price, this.title, this.originalPrice);

  factory InAppPurchaseItem.fromMap(Map<dynamic, dynamic> value) {
    final id = value["id"] as String;
    final price = value["price"] as String;
    final title = value["title"] as String;
    final originalPrice = value["originalPrice"] as String;
    return InAppPurchaseItem(id, price, title, originalPrice);
  }
}

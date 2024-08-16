class Items {
  int? id;
  final String name;
  final double price;
  int? stock;
  String? description;
  String? imagePath;
  String? category;
  int? barCode;

  Items({
    this.id,
    required this.name,
    required this.price,
    this.barCode,
    this.stock,
    this.description,
    this.imagePath,
    this.category,
  });

  //! convert client into a Map
  Map<String, dynamic> toMap(){
    return{
      'name': name,
      'price': price,
      'stock': stock,
      'barcode': barCode,
      'description': description,
      'imagePath': imagePath,
      'category' : category,
    };
  }
}
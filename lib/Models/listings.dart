class Listings {
  int? id;
  final String name;
  final double price;
  final int quantity;
  String? comment;

  Listings({
    this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.comment,
  });

  //! convert client into a Map
  Map<String, dynamic> toMap(){
    return{
      'name': name,
      'price': price,
      'quantity': quantity,
      'comment': comment,
    };
  }
}
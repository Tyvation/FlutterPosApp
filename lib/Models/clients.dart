class Clients{
  final String contactName;
  final String clientName;
  final double phoneNumber;
  final String email;
  final String address;

  Clients({
    required this.clientName,
    required this.contactName,
    required this.phoneNumber,
    required this.email,
    required this.address,
  });

  //! convert client into a Map
  Map<String, dynamic> toMap(){
    return{
      'contactName': contactName,
      'clientName': clientName,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
    };
  }
}
class AccelerationData{
  final int id;
  final double accelerationValue; // acceleration value in double

  const AccelerationData({required this.accelerationValue, required this.id});

  factory AccelerationData.fromJson(Map<String, dynamic> json) => AccelerationData(
    accelerationValue: json['accelerationValue'], 
    id: json['id']);

  Map<String, dynamic> toJson() => {
    'id' : id,
    'accelerationValue' : accelerationValue
  };

}
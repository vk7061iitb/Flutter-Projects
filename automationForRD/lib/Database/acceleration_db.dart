class AccelerationData{
  final int id;
  final String accelerationValueType; // Raw OR Smoothed Data
  final double accelerationValue; // acceleration value in double

  const AccelerationData({required this.accelerationValue, required this.accelerationValueType, required this.id});

  factory AccelerationData.fromJson(Map<String, dynamic> json) => AccelerationData(
    accelerationValue: json['accelerationValue'], 
    accelerationValueType: json['accelerationValueType'],
    id: json['id']);

  Map<String, dynamic> toJson() => {
    'id' : id,
    'accelerationValueType' : accelerationValueType,
    'accelerationValue' : accelerationValue
  };

}
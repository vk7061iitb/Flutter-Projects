class AccelerationData{
  final int id;
  final String accelerationValueType; // Raw OR Smoothed
  final int accelerationValue;

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
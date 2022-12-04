class Device {
  String deviceId;
  String owner;
  String pet;
  String mapIconUrl;

  Device(
      {required this.deviceId,
      this.owner = "",
      this.pet = "",
      this.mapIconUrl = ""});

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
        deviceId: json['device_id'],
        owner: json['owner'],
        pet: json['pet'],
        mapIconUrl: json['map_icon_url']);
  }

  Map<String, dynamic> toJson() => {
        "device_id": deviceId,
        "owner": owner,
        "pet": pet,
        "map_icon_url": mapIconUrl
      };
}

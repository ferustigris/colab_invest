class DeviceRegistrationException implements Exception {
  final String message;
  DeviceRegistrationException(this.message);

  @override
  String toString() {
    return message;
  }
}

class DeviceUrlException implements Exception {
  final String message;
  DeviceUrlException(this.message);

  @override
  String toString() {
    return message;
  }
}
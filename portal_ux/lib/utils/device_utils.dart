import 'package:http/http.dart' as http;
import 'package:portal_ux/data/state_notifiers.dart';
import 'package:portal_ux/data/app_constants.dart';
import 'package:portal_ux/utils/exceptions/device_exceptions.dart';

Future<void> registerDevice() async {
  if (StateNotifiers.userDeviceTokenData.value.token !=
      AppConstants.emptyTokenValue) {
    final idToken = await StateNotifiers.user.value!.getIdToken();
    final response = await http.post(
      Uri.parse(AppConstants.cloudUrlDeviceRegistration),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body:
          '{"${AppConstants.userDeviceTokenName}":"${StateNotifiers.userDeviceTokenData.value.token}"}',
    );

    if (response.statusCode != 200) {
      throw DeviceRegistrationException(
        "Device activation fail: ${response.body} \n Please try again later",
      );
    } else {
      StateNotifiers.userDeviceTokenData.value = UserDeviceTokenData();
      StateNotifiers.userDeviceTokenData.value.isRegAckPending = true;
    }
  }
}

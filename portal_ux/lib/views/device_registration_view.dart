import 'package:flutter/material.dart';
import 'package:portal_ux/widgets/auth_gate.dart';
import 'package:portal_ux/utils/is_mobile_view_port.dart';
import 'package:portal_ux/data/app_styles.dart';
import 'package:portal_ux/data/state_notifiers.dart';
import 'package:portal_ux/utils/device_utils.dart';
import 'package:portal_ux/widgets/common_error_widget.dart';
import 'package:portal_ux/widgets/common_acknowledge_widget.dart';
import 'package:portal_ux/widgets/common_app_bar.dart';
import 'package:portal_ux/widgets/common_navigation_bar.dart';
import 'package:portal_ux/widgets/ai_popup_chat.dart';
import 'package:portal_ux/l10n/app_localizations.dart';
import 'package:portal_ux/utils/navigation_utils.dart';


class DeviceRegistrationView extends StatelessWidget {
  const DeviceRegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGate(
      page: isMobileViewPort(context) ? 
      DeviceRegistrationScreen() : 
      Stack(children: [DeviceRegistrationScreen(), AIPopUpChat()])
    );
  }
}

class DeviceRegistrationScreen extends StatefulWidget {
  const DeviceRegistrationScreen({super.key});

  @override
  State<DeviceRegistrationScreen> createState() => _DeviceRegistrationScreenState();

}

class _DeviceRegistrationScreenState extends State<DeviceRegistrationScreen> {

  final TextEditingController deviceIdInputController = TextEditingController();

  @override
  void dispose() {
    deviceIdInputController.dispose();
    super.dispose();
  } 

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: CommonAppBar(
        title: "Device Registration"
      ),
      body: Center(
        child: ValueListenableBuilder(
          valueListenable: StateNotifiers.userDeviceTokenData,
          builder: (context, tokenData, child) {
            return (tokenData.isRegistrationPending || tokenData.isRegAckPending)
            ? registrationActionBuilder(context)
            : registrationInputBuilder();
          }
        )
      ),
      bottomNavigationBar: isMobileViewPort(context) ? CommonNavigationBar() : null
    );
  }

  void submitDeviceId() {
    StateNotifiers.userDeviceTokenData.value.token = deviceIdInputController.text;
    StateNotifiers.userDeviceTokenData.value.isRegistrationPending = true;
  }

  Widget registrationInputBuilder() {
    double widthCoeff = isMobileViewPort(context) ? 0.8 : 0.5;
    return Container(
      width: MediaQuery.of(context).size.width * widthCoeff,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.deviceRegistrationInputCTA,
              hintStyle: TextStyle(
                color: Theme.of(context).hintColor
              )
            ),
            controller: deviceIdInputController,
            onSubmitted: (value) {
              setState(() => submitDeviceId());
            }, 
          ),
          SizedBox(
            height: AppStyles.verticalSeparatorHeight
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => submitDeviceId());
            },
            child: Text(AppLocalizations.of(context)!.registrationButtonLabel)
          )
        ]
      ),
    );
  }

  Widget registrationActionBuilder(BuildContext context) {
    String message = AppLocalizations.of(context)!.registerDeviceSuccessMessage;

    return FutureBuilder(
          future: registerDevice(),
          builder: (context, asyncSnapshot) {
            return Center(
              child: (asyncSnapshot.connectionState == ConnectionState.waiting)
              ? CircularProgressIndicator()
              : asyncSnapshot.hasError 
                ? CommonErrorWidget(message: asyncSnapshot.error.toString())
                : CommonAcknowledgeWidget(
                    message: message,
                    ackButtonLabel: AppLocalizations.of(context)!.goToHomePageAckButtonLabel,
                    ackCallback: acknowledgeCallback
                  )
            );
          }
    );
  }


  void acknowledgeCallback() {
    StateNotifiers.userDeviceTokenData.value.isRegAckPending = false;
    redirectToMainPage(context);
  }

}
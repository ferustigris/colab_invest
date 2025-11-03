// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get ticketsNav => 'Tickets';

  @override
  String get ticketsPageTitle => 'Tickets de Soporte';

  @override
  String get aiAssistantNav => 'Asistente IA';

  @override
  String get aiAssistantPageTitle => 'Pregúntame';

  @override
  String get userSettingsPageTitle => 'Configuración del Usuario';

  @override
  String get userMenuItemSettings => 'Ajustes';

  @override
  String get userMenuItemLogOut => 'Cerrar sesión';

  @override
  String get userSettingsLanguageLabel => 'Selecciona el idioma';

  @override
  String get aiAssistantChatUserMarker => 'Tú';

  @override
  String get aiAssistantChatInputPlaceholder =>
      'Escribe aquí, pulsa `Enter` para enviar.';

  @override
  String get errorNoDataFound => 'No se encontraron datos';

  @override
  String get aiLanguagePrompt => 'Contéstame en Español';

  @override
  String get gremlinMessage => '¡Algo salió mal, no fue mi culpa!';

  @override
  String get registerDeviceCTA => 'Registre su DVR dispositivo';

  @override
  String get registerDeviceSuccessMessage =>
      'Su dispositivo fue registrado exitosamente';

  @override
  String get registerDeviceAlertTitle => 'Registro de dispositivo';

  @override
  String get defaultActionSuccessAckMessage => '¡Éxito!';

  @override
  String get defaultActionSuccessAckButtonLabel => 'Entendido';

  @override
  String get deviceRegistrationInputCTA => 'Introduce el ID de tu dispositivo';

  @override
  String get registrationButtonLabel => 'Registrar';

  @override
  String get deviceRegistrationPageNavigationLabel =>
      'Vincular un dispositivo a mi cuenta';

  @override
  String get goToHomePageAckButtonLabel =>
      'Entendido. Ir a la Página de Inicio';

  @override
  String get generalWelcomeTitle => '¡Bienvenido a Solvía Tech Vigilance!';

  @override
  String get passwordInputPlaceholder => 'Contraseña';

  @override
  String get passwordResetMailSentMessage =>
      'Correo de restablecimiento de contraseña enviado. Revisa tu correo y sigue las instrucciones';

  @override
  String get resetPasswordButtonLabel => 'Restablecer contraseña';

  @override
  String get googleSignInButtonLabel => 'Iniciar sesión con Google';

  @override
  String get emailSignInOptionEmailCTALabel => 'o con tu Email';

  @override
  String get resetPasswordPageTitle =>
      'Ingresa tu correo electrónico para restablecer la contraseña';

  @override
  String get userRegistrationPageTitle =>
      'Ingresa tu correo electrónico y establece la contraseña';

  @override
  String get emailVerificationCTA =>
      'Por favor, verifica tu correo electrónico';

  @override
  String get verificationEmailSendButtonLabel =>
      'Enviar el correo de verificación';

  @override
  String get cancelButtonLabel => 'Cancelar';

  @override
  String get signInButtonLabel => 'Iniciar sesión';

  @override
  String get userManualLabel => 'Manual de Usuario';

  @override
  String get dismissLabel => 'Descartar';

  @override
  String get dontShowAgainLabel => 'No mostrar de nuevo';

  @override
  String get haCredentialsNotificationLabel =>
      'Credenciales de Home Assistant\n\nUsuario: demo\nContraseña: demo';

  @override
  String get verificationEmailSentMessage =>
      'El correo de verificación ha sido enviado, por favor revisa las instrucciones en tu buzón. \nSi no encuentras el correo en la bandeja de entrada, revisa la carpeta de spam.';
}

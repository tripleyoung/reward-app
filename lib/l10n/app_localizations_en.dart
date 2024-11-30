import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Reward App';

  @override
  String get loginTitle => 'Login';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signUpButton => 'Sign up';

  @override
  String get signUpTitle => 'Sign Up';

  @override
  String get nameLabel => 'Name';

  @override
  String get nicknameLabel => 'Nickname';

  @override
  String get verifyEmailButton => 'Verify Email';

  @override
  String get verificationCodeLabel => 'Verification Code';

  @override
  String get verifyCodeButton => 'Verify Code';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get nicknameRequired => 'Nickname is required';

  @override
  String get emailVerificationRequired => 'Email verification is required';

  @override
  String get emailSendSuccess => 'Verification code has been sent';

  @override
  String get emailSendFail => 'Failed to send verification code';

  @override
  String get emailVerifySuccess => 'Email verification completed';

  @override
  String get emailVerifyFail => 'Email verification failed';

  @override
  String get signupSuccess => 'Sign up completed successfully';

  @override
  String get signupFail => 'Sign up failed';

  @override
  String get loginFail => 'Login failed';

  @override
  String get loginSuccess => 'Login successful';
}

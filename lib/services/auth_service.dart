class AuthService {
  static String? _registeredEmail;
  static String? _registeredPassword;

  static bool register(String email, String password) {
    _registeredEmail = email;
    _registeredPassword = password;
    return true;
  }

  static bool login(String email, String password) {
    return email == _registeredEmail && password == _registeredPassword;
  }

  static bool verifyOtp(String otp) {
    return otp == "123456"; // static OTP
  }

  static bool resetPassword(String email, String newPassword) {
    if (email == _registeredEmail) {
      _registeredPassword = newPassword;
      return true;
    }
    return false;
  }
}

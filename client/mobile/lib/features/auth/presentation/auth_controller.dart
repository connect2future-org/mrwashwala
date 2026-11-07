import 'package:flutter/foundation.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/repositories/auth_repository.dart';

enum AuthStatus {
  uninitialized,
  unauthenticated,
  sendingOtp,
  otpSent,
  verifyingOtp,
  authenticated,
  error,
}

class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;
  final SecureStorageService _storageService;

  AuthStatus _status = AuthStatus.uninitialized;
  CustomerModel? _currentCustomer;
  String? _token;
  String? _activePhone;
  String? _devNote;
  String? _errorMessage;

  AuthStatus get status => _status;
  CustomerModel? get currentCustomer => _currentCustomer;
  String? get token => _token;
  String? get activePhone => _activePhone;
  String? get devNote => _devNote;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _token != null;
  bool get isLoading => _status == AuthStatus.sendingOtp || _status == AuthStatus.verifyingOtp;

  AuthController({
    AuthRepository? authRepository,
    SecureStorageService? storageService,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _storageService = storageService ?? SecureStorageService();

  /// Validates existing session on app startup.
  Future<void> checkAuthStatus() async {
    _status = AuthStatus.uninitialized;
    _errorMessage = null;
    notifyListeners();

    try {
      final savedToken = await _storageService.getToken();
      final savedCustomerData = await _storageService.getCustomer();

      if (savedToken != null && savedToken.isNotEmpty) {
        _token = savedToken;

        if (savedCustomerData != null) {
          _currentCustomer = CustomerModel.fromJson(savedCustomerData);
        }

        try {
          // Verify token against live backend profile API
          final liveProfile = await _authRepository.fetchProfile(savedToken);
          _currentCustomer = liveProfile;
          await _storageService.saveCustomer(liveProfile.toJson());
          _status = AuthStatus.authenticated;
        } catch (_) {
          // Fallback to cached profile if offline, or clear if unauthorized
          if (_currentCustomer != null) {
            _status = AuthStatus.authenticated;
          } else {
            await logout();
            return;
          }
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  /// Sends 6-digit OTP to customer phone number.
  Future<bool> sendOtp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length != 10) {
      _errorMessage = 'Please enter a valid 10-digit mobile number';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    _status = AuthStatus.sendingOtp;
    _errorMessage = null;
    _devNote = null;
    notifyListeners();

    try {
      final res = await _authRepository.sendOtp(cleanPhone);
      _activePhone = cleanPhone;
      _devNote = res.devNote;
      _status = AuthStatus.otpSent;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Verifies 6-digit OTP and completes customer authentication.
  Future<bool> verifyOtp(String otp, {String? name}) async {
    final cleanOtp = otp.trim();
    if (cleanOtp.length != 6) {
      _errorMessage = 'Please enter a valid 6-digit OTP';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    if (_activePhone == null || _activePhone!.isEmpty) {
      _errorMessage = 'Phone number missing. Please request a new OTP.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }

    _status = AuthStatus.verifyingOtp;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _authRepository.verifyOtp(_activePhone!, cleanOtp, name: name);
      _token = res.token;
      _currentCustomer = res.customer;

      await _storageService.saveToken(res.token);
      await _storageService.saveCustomer(res.customer.toJson());

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Clears customer session and resets to unauthenticated state.
  Future<void> logout() async {
    await _storageService.clearAll();
    _token = null;
    _currentCustomer = null;
    _activePhone = null;
    _devNote = null;
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Clears error message.
  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _activePhone != null ? AuthStatus.otpSent : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

    /// Updates profile (name, email) for the logged in customer.
  Future<bool> updateProfile({String? name, String? email}) async {
    if (_token == null || _token!.isEmpty) {
      _errorMessage = "Authentication token missing. Please sign in again.";
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    notifyListeners();

    try {
      final updatedCustomer = await _authRepository.updateProfile(
        _token!,
        name: name,
        email: email,
      );
      _currentCustomer = updatedCustomer;
      await _storageService.saveCustomer(updatedCustomer.toJson());
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      notifyListeners();
      return false;
    }
  }

String _cleanErrorMessage(String rawMessage) {
    return rawMessage.replaceAll('ApiException: ', '').replaceAll('Exception: ', '').trim();
  }
}

import 'dart:developer' as developer;

/// A utility class for providing the salesperson ID throughout the app
/// This is a temporary solution until we implement global state management
class SalespersonServiceProvider {
  // Singleton instance
  static SalespersonServiceProvider? _instance;

  // The authenticated salesperson ID
  String? _salespersonId;

  // Private constructor
  SalespersonServiceProvider._();

  // Factory constructor to return the singleton instance
  factory SalespersonServiceProvider() {
    _instance ??= SalespersonServiceProvider._();
    return _instance!;
  }

  // Getter for the salesperson ID
  String? get salespersonId => _salespersonId;

  // Setter for the salesperson ID
  set salespersonId(String? id) {
    _salespersonId = id;
    developer.log('[SalespersonServiceProvider] Salesperson ID set to: $_salespersonId');
  }

  // Check if ID is available
  bool get hasId => _salespersonId != null && _salespersonId!.isNotEmpty;
}

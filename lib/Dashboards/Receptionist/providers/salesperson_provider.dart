import 'package:flutter/foundation.dart';
import '../models/salesperson.dart';
import '../services/receptionist_service.dart';

class SalespersonProvider with ChangeNotifier {
  final ReceptionistService _receptionistService;

  SalespersonProvider(this._receptionistService) {
    fetchSalespersons();
  }

  List<Salesperson> _salespersons = [];
  List<Salesperson> get salespersons => _salespersons;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSalespersons() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final salespersons = await _receptionistService.fetchSalespersonsFromSupabase();
      if (salespersons.isEmpty) {
        _errorMessage = 'No salespersons found in Supabase.';
        debugPrint('DEBUG: No salespersons found in Supabase.');
        _salespersons = [];
      } else {
        debugPrint('DEBUG: Fetched \\${salespersons.length} salespersons from Supabase.');
        _salespersons = salespersons;
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('DEBUG: Error fetching salespersons: \\${e.toString()}');
      _salespersons = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSalespersonStatus(String salespersonId, SalespersonStatus status) async {
    _isLoading = true;
    _errorMessage = null;
    // No need to notifyListeners() here as the UI might not need to show loading for this specific action immediately,
    // or it can be handled by a local loading state in the widget triggering it.
    // However, if a global loading state for this action is desired, uncomment the next line.
    // notifyListeners(); 
    try {
      final updatedSalesperson = await _receptionistService.updateSalespersonStatus(salespersonId, status);
      if (updatedSalesperson != null) {
        // Update the local list
        int index = _salespersons.indexWhere((sp) => sp.id == salespersonId);
        if (index != -1) {
          _salespersons[index] = updatedSalesperson;
        }
      } else {
        _errorMessage = 'Failed to update salesperson status or salesperson not found.';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false; // Assuming we want to turn off global loading if it was on
      notifyListeners(); // Notify listeners about the change in data or error state
    }
  }
}

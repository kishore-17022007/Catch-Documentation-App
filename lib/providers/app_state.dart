import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/state_models.dart';
import '../services/firestore_service.dart';

class AppState extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  SharedPreferences? _prefs;
  StreamSubscription<User?>? _authSubscription;

  String _currentLanguage = 'English';
  String _fisherId = '';
  FisherProfile _profile = FisherProfile();
  List<Vessel> _vessels = [];
  List<CrewMember> _crew = [];
  List<TripRecord> _trips = [];
  List<SalesRecord> _sales = [];
  List<CatchItem> _catches = [];
  bool _isLoggedIn = false;
  bool _isLoading = false;

  String get currentLanguage => _currentLanguage;
  String get fisherId => _fisherId;
  FisherProfile get profile => _profile;
  List<Vessel> get vessels => _vessels;
  List<CrewMember> get crew => _crew;
  List<TripRecord> get trips => _trips;
  List<SalesRecord> get sales => _sales;
  List<CatchItem> get catches => _catches;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  AppState() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _currentLanguage = _prefs?.getString('currentLanguage') ?? 'English';
    _isLoggedIn = _prefs?.getBool('isLoggedIn') ?? false;
    _fisherId = _prefs?.getString('fisherId') ?? '';

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _isLoggedIn = true;
      _fisherId = currentUser.phoneNumber ?? _fisherId;
      await _prefs?.setBool('isLoggedIn', true);
      await _prefs?.setString('fisherId', _fisherId);
    }

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _isLoggedIn = false;
        _fisherId = '';
        notifyListeners();
      }
    });

    // If signed in or previously logged in, reload data from Firestore.
    if (_isLoggedIn && _fisherId.isNotEmpty) {
      await _loadFromFirestore();
    }
    notifyListeners();
  }

  Future<void> _loadFromFirestore() async {
    _isLoading = true;
    notifyListeners();
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Not authenticated');
      }

      final data = await _firestore.loadAll(_fisherId);
      if (data['profile'] != null) _profile = data['profile'] as FisherProfile;
      _vessels = data['vessels'] as List<Vessel>;
      _crew = data['crew'] as List<CrewMember>;
      _trips = data['trips'] as List<TripRecord>;
      _sales = data['sales'] as List<SalesRecord>;
      _catches = data['catches'] as List<CatchItem>;
    } catch (e) {
      debugPrint('Firestore load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Language ─────────────────────────────────────────────────────────────────
  void setLanguage(String lang) {
    _currentLanguage = lang;
    _prefs?.setString('currentLanguage', lang);
    notifyListeners();
  }

  // ── Auth ─────────────────────────────────────────────────────────────────────
  Future<void> login({String phoneNumber = ''}) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('Firebase Auth user is not signed in.');
    }

    _isLoggedIn = true;
    _fisherId = phoneNumber.isNotEmpty
        ? phoneNumber
        : (currentUser.phoneNumber ?? currentUser.uid);
    await _prefs?.setBool('isLoggedIn', true);
    await _prefs?.setString('fisherId', _fisherId);

    try {
      await _firestore.saveProfile(
        _fisherId,
        FisherProfile(
          fisherId: _fisherId,
          fullName: currentUser.phoneNumber != null ? 'New Fisher' : 'Anonymous Fisher',
          phoneNumber: currentUser.phoneNumber ?? '',
          uid: currentUser.uid,
        ),
      );
    } catch (e) {
      debugPrint('Initial Firestore profile write failed: $e');
    }

    await _loadFromFirestore();
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _fisherId = '';
    _profile = FisherProfile();
    _vessels = [];
    _crew = [];
    _trips = [];
    _sales = [];
    _catches = [];
    await FirebaseAuth.instance.signOut();
    await _prefs?.setBool('isLoggedIn', false);
    await _prefs?.remove('fisherId');
    notifyListeners();
  }

  // ── Profile ──────────────────────────────────────────────────────────────────
  Future<void> updateProfile(FisherProfile updated) async {
    _profile = updated;
    notifyListeners();
    try {
      await _firestore.saveProfile(_fisherId, updated);
    } catch (e) {
      debugPrint('Profile save error: $e');
    }
  }

  // ── Vessels ──────────────────────────────────────────────────────────────────
  Future<void> addVessel(Vessel vessel) async {
    _vessels.add(vessel);
    notifyListeners();
    try {
      await _firestore.saveVessel(_fisherId, vessel);
    } catch (e) {
      debugPrint('Vessel save error: $e');
    }
  }

  Future<void> removeVessel(String vesselId) async {
    _vessels.removeWhere((v) => v.id == vesselId);
    notifyListeners();
    await _firestore.deleteVessel(_fisherId, vesselId);
  }

  // ── Crew ─────────────────────────────────────────────────────────────────────
  Future<void> addCrewMember(CrewMember member) async {
    _crew.add(member);
    notifyListeners();
    try {
      await _firestore.saveCrewMember(_fisherId, member);
    } catch (e) {
      debugPrint('Crew save error: $e');
    }
  }

  Future<void> removeCrewMember(String memberId) async {
    _crew.removeWhere((m) => m.id == memberId);
    notifyListeners();
    await _firestore.deleteCrewMember(_fisherId, memberId);
  }

  // ── Trips ─────────────────────────────────────────────────────────────────────
  Future<void> addTrip(TripRecord trip) async {
    _trips.insert(0, trip);
    notifyListeners();
    try {
      await _firestore.saveTrip(_fisherId, trip);
    } catch (e) {
      debugPrint('Trip save error: $e');
    }
  }

  Future<void> removeTrip(String tripId) async {
    _trips.removeWhere((t) => t.id == tripId);
    notifyListeners();
    await _firestore.deleteTrip(_fisherId, tripId);
  }

  // ── Sales ─────────────────────────────────────────────────────────────────────
  Future<void> addSales(SalesRecord sale) async {
    _sales.insert(0, sale);
    notifyListeners();
    try {
      await _firestore.saveSale(_fisherId, sale);
    } catch (e) {
      debugPrint('Sales save error: $e');
    }
  }

  Future<void> removeSale(String saleId) async {
    _sales.removeWhere((s) => s.id == saleId);
    notifyListeners();
    await _firestore.deleteSale(_fisherId, saleId);
  }

  Future<void> addCatch(CatchItem catchItem) async {
    _catches.insert(0, catchItem);
    notifyListeners();
    try {
      await _firestore.saveCatch(_fisherId, catchItem);
    } catch (e) {
      debugPrint('Catch save error: $e');
    }
  }

  Future<void> removeCatch(String catchId) async {
    _catches.removeWhere((c) => c.id == catchId);
    notifyListeners();
    await _firestore.deleteCatch(_fisherId, catchId);
  }
}

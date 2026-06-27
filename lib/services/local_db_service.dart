import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/state_models.dart';

class LocalDbService {
  // Helper to generate unique keys per fisher and collection
  String _key(String fisherId, String collection) => '${fisherId}_$collection';

  Future<SharedPreferences> _getPrefs() async => await SharedPreferences.getInstance();

  // ── Profile ─────────────────────────────────────────────────────────────────
  Future<void> saveProfile(String fisherId, FisherProfile profile) async {
    final prefs = await _getPrefs();
    await prefs.setString(_key(fisherId, 'profile'), jsonEncode(profile.toMap()));
  }

  Future<FisherProfile?> loadProfile(String fisherId) async {
    final prefs = await _getPrefs();
    final jsonStr = prefs.getString(_key(fisherId, 'profile'));
    if (jsonStr == null) return null;
    return FisherProfile.fromMap(jsonDecode(jsonStr));
  }

  // ── Vessels ─────────────────────────────────────────────────────────────────
  Future<void> saveVessel(String fisherId, Vessel vessel) async {
    final vessels = await loadVessels(fisherId);
    final index = vessels.indexWhere((v) => v.id == vessel.id);
    if (index >= 0) {
      vessels[index] = vessel;
    } else {
      vessels.add(vessel);
    }
    final prefs = await _getPrefs();
    await prefs.setString(_key(fisherId, 'vessels'), jsonEncode(vessels.map((v) => v.toMap()).toList()));
  }

  Future<List<Vessel>> loadVessels(String fisherId) async {
    final prefs = await _getPrefs();
    final jsonStr = prefs.getString(_key(fisherId, 'vessels'));
    if (jsonStr == null) return [];
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((v) => Vessel.fromMap(v)).toList();
  }

  Future<void> deleteVessel(String fisherId, String vesselId) async {
    final vessels = await loadVessels(fisherId);
    vessels.removeWhere((v) => v.id == vesselId);
    final prefs = await _getPrefs();
    await prefs.setString(_key(fisherId, 'vessels'), jsonEncode(vessels.map((v) => v.toMap()).toList()));
  }

  // ── Crew ────────────────────────────────────────────────────────────────────
  Future<void> saveCrewMember(String fisherId, CrewMember member) async {
    final crew = await loadCrew(fisherId);
    final index = crew.indexWhere((m) => m.id == member.id);
    if (index >= 0) {
      crew[index] = member;
    } else {
      crew.add(member);
    }
    final prefs = await _getPrefs();
    await prefs.setString(_key(fisherId, 'crew'), jsonEncode(crew.map((m) => m.toMap()).toList()));
  }

  Future<List<CrewMember>> loadCrew(String fisherId) async {
    final prefs = await _getPrefs();
    final jsonStr = prefs.getString(_key(fisherId, 'crew'));
    if (jsonStr == null) return [];
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((m) => CrewMember.fromMap(m)).toList();
  }

  Future<void> deleteCrewMember(String fisherId, String memberId) async {
    final crew = await loadCrew(fisherId);
    crew.removeWhere((m) => m.id == memberId);
    final prefs = await _getPrefs();
    await prefs.setString(_key(fisherId, 'crew'), jsonEncode(crew.map((m) => m.toMap()).toList()));
  }

  // ── Trips ───────────────────────────────────────────────────────────────────
  Future<void> saveTrip(String fisherId, TripRecord trip) async {
    final trips = await loadTrips(fisherId);
    final index = trips.indexWhere((t) => t.id == trip.id);
    if (index >= 0) {
      trips[index] = trip;
    } else {
      trips.add(trip);
    }
    final prefs = await _getPrefs();
    await prefs.setString(_key(fisherId, 'trips'), jsonEncode(trips.map((t) => t.toMap()).toList()));
  }

  Future<List<TripRecord>> loadTrips(String fisherId) async {
    final prefs = await _getPrefs();
    final jsonStr = prefs.getString(_key(fisherId, 'trips'));
    if (jsonStr == null) return [];
    final List<dynamic> list = jsonDecode(jsonStr);
    final trips = list.map((t) => TripRecord.fromMap(t)).toList();
    // Sort descending by departureTime (simulating Firestore orderBy)
    trips.sort((a, b) => b.departureTime.compareTo(a.departureTime));
    return trips;
  }

  Future<void> deleteTrip(String fisherId, String tripId) async {
    final trips = await loadTrips(fisherId);
    trips.removeWhere((t) => t.id == tripId);
    final prefs = await _getPrefs();
    await prefs.setString(_key(fisherId, 'trips'), jsonEncode(trips.map((t) => t.toMap()).toList()));
  }

  // ── Sales ────────────────────────────────────────────────────────────────────
  Future<void> saveSale(String fisherId, SalesRecord sale) async {
    final sales = await loadSales(fisherId);
    final index = sales.indexWhere((s) => s.id == sale.id);
    if (index >= 0) {
      sales[index] = sale;
    } else {
      sales.add(sale);
    }
    final prefs = await _getPrefs();
    await prefs.setString(_key(fisherId, 'sales'), jsonEncode(sales.map((s) => s.toMap()).toList()));
  }

  Future<List<SalesRecord>> loadSales(String fisherId) async {
    final prefs = await _getPrefs();
    final jsonStr = prefs.getString(_key(fisherId, 'sales'));
    if (jsonStr == null) return [];
    final List<dynamic> list = jsonDecode(jsonStr);
    final sales = list.map((s) => SalesRecord.fromMap(s)).toList();
    sales.sort((a, b) => b.date.compareTo(a.date));
    return sales;
  }

  Future<void> deleteSale(String fisherId, String saleId) async {
    final sales = await loadSales(fisherId);
    sales.removeWhere((s) => s.id == saleId);
    final prefs = await _getPrefs();
    await prefs.setString(_key(fisherId, 'sales'), jsonEncode(sales.map((s) => s.toMap()).toList()));
  }

  // ── Load all data for a fisher at once ──────────────────────────────────────
  Future<Map<String, dynamic>> loadAll(String fisherId) async {
    final results = await Future.wait([
      loadProfile(fisherId),
      loadVessels(fisherId),
      loadCrew(fisherId),
      loadTrips(fisherId),
      loadSales(fisherId),
    ]);
    return {
      'profile': results[0],
      'vessels': results[1],
      'crew': results[2],
      'trips': results[3],
      'sales': results[4],
    };
  }
}

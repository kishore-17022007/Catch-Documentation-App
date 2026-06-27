import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/state_models.dart';

class MongoDbService {
  static const String dataApiUrl = 'http://localhost:3000';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  Future<Map<String, dynamic>> _post(String action, Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse('$dataApiUrl/action/$action'),
        headers: _headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        debugPrint('MongoDB Error: ${response.statusCode} - ${response.body}');
        return {};
      }
    } catch (e) {
      debugPrint('MongoDB Network Error: $e');
      return {};
    }
  }

  // ── Profile ─────────────────────────────────────────────────────────────────
  Future<void> saveProfile(String fisherId, FisherProfile profile) async {
    final doc = profile.toMap();
    doc['fisherId'] = fisherId; 
    
    // Upsert equivalent
    await _post('updateOne', {
      'collection': 'profiles',
      'filter': {'fisherId': fisherId},
      'update': {'\$set': doc},
      'upsert': true,
    });
  }

  Future<FisherProfile?> loadProfile(String fisherId) async {
    final res = await _post('findOne', {
      'collection': 'profiles',
      'filter': {'fisherId': fisherId},
    });
    if (res['document'] == null) return null;
    return FisherProfile.fromMap(res['document']);
  }

  // ── Vessels ─────────────────────────────────────────────────────────────────
  Future<void> saveVessel(String fisherId, Vessel vessel) async {
    final doc = vessel.toMap();
    doc['fisherId'] = fisherId;
    
    await _post('updateOne', {
      'collection': 'vessels',
      'filter': {'fisherId': fisherId, 'id': vessel.id},
      'update': {'\$set': doc},
      'upsert': true,
    });
  }

  Future<List<Vessel>> loadVessels(String fisherId) async {
    final res = await _post('find', {
      'collection': 'vessels',
      'filter': {'fisherId': fisherId},
    });
    final docs = res['documents'] as List<dynamic>? ?? [];
    return docs.map((v) => Vessel.fromMap(v)).toList();
  }

  Future<void> deleteVessel(String fisherId, String vesselId) async {
    await _post('deleteOne', {
      'collection': 'vessels',
      'filter': {'fisherId': fisherId, 'id': vesselId},
    });
  }

  // ── Crew ────────────────────────────────────────────────────────────────────
  Future<void> saveCrewMember(String fisherId, CrewMember member) async {
    final doc = member.toMap();
    doc['fisherId'] = fisherId;

    await _post('updateOne', {
      'collection': 'crew',
      'filter': {'fisherId': fisherId, 'id': member.id},
      'update': {'\$set': doc},
      'upsert': true,
    });
  }

  Future<List<CrewMember>> loadCrew(String fisherId) async {
    final res = await _post('find', {
      'collection': 'crew',
      'filter': {'fisherId': fisherId},
    });
    final docs = res['documents'] as List<dynamic>? ?? [];
    return docs.map((m) => CrewMember.fromMap(m)).toList();
  }

  Future<void> deleteCrewMember(String fisherId, String memberId) async {
    await _post('deleteOne', {
      'collection': 'crew',
      'filter': {'fisherId': fisherId, 'id': memberId},
    });
  }

  // ── Trips ───────────────────────────────────────────────────────────────────
  Future<void> saveTrip(String fisherId, TripRecord trip) async {
    final doc = trip.toMap();
    doc['fisherId'] = fisherId;

    await _post('updateOne', {
      'collection': 'trips',
      'filter': {'fisherId': fisherId, 'id': trip.id},
      'update': {'\$set': doc},
      'upsert': true,
    });
  }

  Future<List<TripRecord>> loadTrips(String fisherId) async {
    final res = await _post('find', {
      'collection': 'trips',
      'filter': {'fisherId': fisherId},
      'sort': {'departureTime': -1},
    });
    final docs = res['documents'] as List<dynamic>? ?? [];
    return docs.map((t) => TripRecord.fromMap(t)).toList();
  }

  Future<void> deleteTrip(String fisherId, String tripId) async {
    await _post('deleteOne', {
      'collection': 'trips',
      'filter': {'fisherId': fisherId, 'id': tripId},
    });
  }

  // ── Sales ────────────────────────────────────────────────────────────────────
  Future<void> saveSale(String fisherId, SalesRecord sale) async {
    final doc = sale.toMap();
    doc['fisherId'] = fisherId;

    await _post('updateOne', {
      'collection': 'sales',
      'filter': {'fisherId': fisherId, 'id': sale.id},
      'update': {'\$set': doc},
      'upsert': true,
    });
  }

  Future<List<SalesRecord>> loadSales(String fisherId) async {
    final res = await _post('find', {
      'collection': 'sales',
      'filter': {'fisherId': fisherId},
      'sort': {'date': -1},
    });
    final docs = res['documents'] as List<dynamic>? ?? [];
    return docs.map((s) => SalesRecord.fromMap(s)).toList();
  }

  Future<void> deleteSale(String fisherId, String saleId) async {
    await _post('deleteOne', {
      'collection': 'sales',
      'filter': {'fisherId': fisherId, 'id': saleId},
    });
  }

  // ── Load all data for a fisher at once ──────────────────────────────────────
  Future<Map<String, dynamic>> loadAll(String fisherId) async {
    try {
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
    } catch (e) {
      debugPrint('Error loading all data from Local Backend: $e');
      rethrow;
    }
  }
}

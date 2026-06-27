import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/state_models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Root reference ──────────────────────────────────────────────────────────
  DocumentReference _fisherDoc(String fisherId) =>
      _db.collection('fishers').doc(fisherId);

  CollectionReference _sub(String fisherId, String col) =>
      _fisherDoc(fisherId).collection(col);

  // ── Profile ─────────────────────────────────────────────────────────────────
  Future<void> saveProfile(String fisherId, FisherProfile profile) async {
    await _fisherDoc(fisherId).set(
      {'profile': profile.toMap(), 'fisherId': fisherId},
      SetOptions(merge: true),
    );
  }

  Future<FisherProfile?> loadProfile(String fisherId) async {
    final doc = await _fisherDoc(fisherId).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>?;
    final profileMap = data?['profile'] as Map<String, dynamic>?;
    if (profileMap == null) return null;
    return FisherProfile.fromMap(profileMap);
  }

  // ── Vessels ─────────────────────────────────────────────────────────────────
  Future<void> saveVessel(String fisherId, Vessel vessel) async {
    await _sub(fisherId, 'vessels').doc(vessel.id).set(vessel.toMap());
  }

  Future<List<Vessel>> loadVessels(String fisherId) async {
    final snap = await _sub(fisherId, 'vessels').get();
    return snap.docs
        .map((d) => Vessel.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteVessel(String fisherId, String vesselId) async {
    await _sub(fisherId, 'vessels').doc(vesselId).delete();
  }

  // ── Crew ────────────────────────────────────────────────────────────────────
  Future<void> saveCrewMember(String fisherId, CrewMember member) async {
    await _sub(fisherId, 'crew').doc(member.id).set(member.toMap());
  }

  Future<List<CrewMember>> loadCrew(String fisherId) async {
    final snap = await _sub(fisherId, 'crew').get();
    return snap.docs
        .map((d) => CrewMember.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteCrewMember(String fisherId, String memberId) async {
    await _sub(fisherId, 'crew').doc(memberId).delete();
  }

  // ── Trips ───────────────────────────────────────────────────────────────────
  Future<void> saveTrip(String fisherId, TripRecord trip) async {
    // Store catches inside the trip document (not as sub-collection)
    // so a single read fetches the full trip with catches.
    await _sub(fisherId, 'trips').doc(trip.id).set(trip.toMap());
  }

  Future<List<TripRecord>> loadTrips(String fisherId) async {
    final snap = await _sub(fisherId, 'trips')
        .orderBy('departureTime', descending: true)
        .get();
    return snap.docs
        .map((d) => TripRecord.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteTrip(String fisherId, String tripId) async {
    await _sub(fisherId, 'trips').doc(tripId).delete();
  }

  // ── Sales ────────────────────────────────────────────────────────────────────
  Future<void> saveSale(String fisherId, SalesRecord sale) async {
    await _sub(fisherId, 'sales').doc(sale.id).set(sale.toMap());
  }

  Future<List<SalesRecord>> loadSales(String fisherId) async {
    final snap = await _sub(fisherId, 'sales')
        .orderBy('date', descending: true)
        .get();
    return snap.docs
        .map((d) => SalesRecord.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteSale(String fisherId, String saleId) async {
    await _sub(fisherId, 'sales').doc(saleId).delete();
  }

  // ── Catches ─────────────────────────────────────────────────────────────
  Future<void> saveCatch(String fisherId, CatchItem catchItem) async {
    await _sub(fisherId, 'catches').doc(catchItem.id).set(catchItem.toMap());
  }

  Future<List<CatchItem>> loadCatches(String fisherId) async {
    final snap = await _sub(fisherId, 'catches').get();
    return snap.docs
        .map((d) => CatchItem.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteCatch(String fisherId, String catchId) async {
    await _sub(fisherId, 'catches').doc(catchId).delete();
  }

  // ── Load all data for a fisher at once ──────────────────────────────────────
  Future<Map<String, dynamic>> loadAll(String fisherId) async {
    final results = await Future.wait([
      loadProfile(fisherId),
      loadVessels(fisherId),
      loadCrew(fisherId),
      loadTrips(fisherId),
      loadSales(fisherId),
      loadCatches(fisherId),
    ]);
    return {
      'profile': results[0],
      'vessels': results[1],
      'crew': results[2],
      'trips': results[3],
      'sales': results[4],
      'catches': results[5],
    };
  }
}

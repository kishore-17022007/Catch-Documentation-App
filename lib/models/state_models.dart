
class FisherProfile {
  String fisherId;
  String fullName;
  String gender;
  String age;
  String dob;
  String mobileNumber;
  String phoneNumber;
  String uid;
  String aadhaarNumber;
  String address;
  String societyName;
  String membershipNumber;
  String gaisPolicyNumber;
  String dateOfEnrolment;
  String policyValidity;
  bool personalInsurance;
  String landingCentre;

  FisherProfile({
    this.fisherId = '',
    this.fullName = '',
    this.gender = 'Male',
    this.age = '',
    this.dob = '',
    this.mobileNumber = '',
    this.phoneNumber = '',
    this.uid = '',
    this.aadhaarNumber = '',
    this.address = '',
    this.societyName = '',
    this.membershipNumber = '',
    this.gaisPolicyNumber = '',
    this.dateOfEnrolment = '',
    this.policyValidity = '',
    this.personalInsurance = false,
    this.landingCentre = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'fisherId': fisherId,
      'fullName': fullName,
      'gender': gender,
      'age': age,
      'dob': dob,
      'mobileNumber': mobileNumber,
      'phoneNumber': phoneNumber,
      'uid': uid,
      'aadhaarNumber': aadhaarNumber,
      'address': address,
      'societyName': societyName,
      'membershipNumber': membershipNumber,
      'gaisPolicyNumber': gaisPolicyNumber,
      'dateOfEnrolment': dateOfEnrolment,
      'policyValidity': policyValidity,
      'personalInsurance': personalInsurance,
      'landingCentre': landingCentre,
    };
  }

  factory FisherProfile.fromMap(Map<String, dynamic> map) {
    return FisherProfile(
      fisherId: map['fisherId'] ?? '',
      fullName: map['fullName'] ?? '',
      gender: map['gender'] ?? 'Male',
      age: map['age'] ?? '',
      dob: map['dob'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      phoneNumber: map['phoneNumber'] ?? map['mobileNumber'] ?? '',
      uid: map['uid'] ?? '',
      aadhaarNumber: map['aadhaarNumber'] ?? '',
      address: map['address'] ?? '',
      societyName: map['societyName'] ?? '',
      membershipNumber: map['membershipNumber'] ?? '',
      gaisPolicyNumber: map['gaisPolicyNumber'] ?? '',
      dateOfEnrolment: map['dateOfEnrolment'] ?? '',
      policyValidity: map['policyValidity'] ?? '',
      personalInsurance: map['personalInsurance'] ?? false,
      landingCentre: map['landingCentre'] ?? '',
    );
  }
}

class Vessel {
  String id;
  String name;
  String type;
  String length;
  String hp;
  String yearOfReg;
  String gearUsed;

  Vessel({
    required this.id,
    required this.name,
    this.type = 'Motorized',
    this.length = '',
    this.hp = '',
    this.yearOfReg = '',
    this.gearUsed = 'Net',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'length': length,
        'hp': hp,
        'yearOfReg': yearOfReg,
        'gearUsed': gearUsed,
      };

  factory Vessel.fromMap(Map<String, dynamic> map) => Vessel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        type: map['type'] ?? 'Motorized',
        length: map['length'] ?? '',
        hp: map['hp'] ?? '',
        yearOfReg: map['yearOfReg'] ?? '',
        gearUsed: map['gearUsed'] ?? 'Net',
      );
}

class CrewMember {
  String id;
  String fullName;
  String gender;
  String age;
  String aadhaarNumber;

  CrewMember({
    required this.id,
    required this.fullName,
    this.gender = 'Male',
    this.age = '',
    this.aadhaarNumber = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'fullName': fullName,
        'gender': gender,
        'age': age,
        'aadhaarNumber': aadhaarNumber,
      };

  factory CrewMember.fromMap(Map<String, dynamic> map) => CrewMember(
        id: map['id'] ?? '',
        fullName: map['fullName'] ?? '',
        gender: map['gender'] ?? 'Male',
        age: map['age'] ?? '',
        aadhaarNumber: map['aadhaarNumber'] ?? '',
      );
}

class TripRecord {
  String id;
  String vesselId;
  String gearUsed;
  List<String> crewIds;
  String startGps;
  String endGps;
  String fuelConsumed;
  String departureTime;
  String arrivalTime;
  List<CatchItem> catches;

  TripRecord({
    required this.id,
    required this.vesselId,
    this.gearUsed = '',
    this.crewIds = const [],
    this.startGps = '',
    this.endGps = '',
    this.fuelConsumed = '',
    this.departureTime = '',
    this.arrivalTime = '',
    this.catches = const [],
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'vesselId': vesselId,
        'gearUsed': gearUsed,
        'crewIds': crewIds,
        'startGps': startGps,
        'endGps': endGps,
        'fuelConsumed': fuelConsumed,
        'departureTime': departureTime,
        'arrivalTime': arrivalTime,
        'catches': catches.map((x) => x.toMap()).toList(),
      };

  factory TripRecord.fromMap(Map<String, dynamic> map) => TripRecord(
        id: map['id'] ?? '',
        vesselId: map['vesselId'] ?? '',
        gearUsed: map['gearUsed'] ?? '',
        crewIds: List<String>.from(map['crewIds'] ?? []),
        startGps: map['startGps'] ?? '',
        endGps: map['endGps'] ?? '',
        fuelConsumed: map['fuelConsumed'] ?? '',
        departureTime: map['departureTime'] ?? '',
        arrivalTime: map['arrivalTime'] ?? '',
        catches: List<CatchItem>.from(
            (map['catches'] ?? []).map((x) => CatchItem.fromMap(x))),
      );
}

class CatchItem {
  String id;
  String species;
  String weightKg;
  bool isDiscard;

  CatchItem({
    required this.id,
    required this.species,
    required this.weightKg,
    this.isDiscard = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'species': species,
        'weightKg': weightKg,
        'isDiscard': isDiscard,
      };

  factory CatchItem.fromMap(Map<String, dynamic> map) => CatchItem(
        id: map['id'] ?? '',
        species: map['species'] ?? '',
        weightKg: map['weightKg'] ?? '0',
        isDiscard: map['isDiscard'] ?? false,
      );
}

class SalesRecord {
  String id;
  String species;
  String quantity;
  String pricePerKg;
  String buyerDetails;
  String date;

  SalesRecord({
    required this.id,
    required this.species,
    required this.quantity,
    required this.pricePerKg,
    required this.buyerDetails,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'species': species,
        'quantity': quantity,
        'pricePerKg': pricePerKg,
        'buyerDetails': buyerDetails,
        'date': date,
      };

  factory SalesRecord.fromMap(Map<String, dynamic> map) => SalesRecord(
        id: map['id'] ?? '',
        species: map['species'] ?? '',
        quantity: map['quantity'] ?? '0',
        pricePerKg: map['pricePerKg'] ?? '0',
        buyerDetails: map['buyerDetails'] ?? '',
        date: map['date'] ?? '',
      );
}

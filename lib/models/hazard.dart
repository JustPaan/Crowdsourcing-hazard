import 'package:cloud_firestore/cloud_firestore.dart';

class Hazard {
  final String id;
  final String type;
  final String description; // ✅ Add this field
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String reportedBy;

  Hazard({
    required this.id,
    required this.type,
    required this.description, // ✅ Add this field
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.reportedBy,
  });

  factory Hazard.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Hazard(
      id: doc.id,
      type: data['type'] ?? '',
      description: data['description'] ?? '', // ✅ Fetch description from Firestore
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      reportedBy: data['reportedBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'description': description, // ✅ Save description to Firestore
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': Timestamp.fromDate(timestamp),
      'reportedBy': reportedBy,
    };
  }
}

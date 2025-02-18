import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hazard.dart';

class MapScreen extends StatefulWidget {
  final bool refresh;
  final double? latitude; // New parameter for latitude
  final double? longitude; // New parameter for longitude
  final String? description; // New parameter for hazard description

  const MapScreen({Key? key, this.refresh = false, this.latitude, this.longitude, this.description}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Hazard> _hazards = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _newReportsCount = 0;
  Timestamp? _lastSeenTimestamp;

  @override
  void initState() {
    super.initState();
    _loadHazards();
    _getLastSeenTimestamp();
  }

  Future<void> _loadHazards() async {
    final QuerySnapshot snapshot = await _firestore.collection('hazards').get();
    setState(() {
      _hazards = snapshot.docs.map((doc) => Hazard.fromFirestore(doc)).toList();
    });
  }

  Future<void> _getLastSeenTimestamp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? lastSeenMillis = prefs.getInt('last_seen_report');
    
    setState(() {
      _lastSeenTimestamp = lastSeenMillis != null
          ? Timestamp.fromMillisecondsSinceEpoch(lastSeenMillis)
          : Timestamp.fromMillisecondsSinceEpoch(0);
    });

    _countNewReports();
  }

  Future<void> _countNewReports() async {
    QuerySnapshot snapshot = await _firestore
        .collection('hazards')
        .where('timestamp', isGreaterThan: _lastSeenTimestamp)
        .get();

    setState(() {
      _newReportsCount = snapshot.docs.length;
    });
  }

  Future<void> _markReportsAsSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('last_seen_report', Timestamp.now().millisecondsSinceEpoch);

    setState(() {
      _newReportsCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.refresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadHazards();
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hazard Map'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.article),
                tooltip: 'Latest News',
                onPressed: () {
                  _markReportsAsSeen();
                  Navigator.pushNamed(context, '/news');
                },
              ),
              if (_newReportsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_newReportsCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About',
            onPressed: () => Navigator.pushNamed(context, '/about'),
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(3.1390, 101.6869), // KL coordinates
          zoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: _hazards.map((hazard) => Marker(
              point: LatLng(hazard.latitude, hazard.longitude),
              width: 80,
              height: 80,
              builder: (context) => GestureDetector(
                onTap: () => _showHazardDetails(hazard),
                child: const Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 30,
                ),
              ),
            )).toList() +
            // Add a marker for the newly reported hazard if coordinates are provided
            (widget.latitude != null && widget.longitude != null
                ? [
                    Marker(
                      point: LatLng(widget.latitude!, widget.longitude!),
                      width: 80,
                      height: 80,
                      builder: (context) => GestureDetector(
                        onTap: () => _showNewHazardDetails(widget.description),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 30,
                        ),
                      ),
                    ),
                  ]
                : []),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'report',
            onPressed: () => Navigator.pushNamed(context, '/report'),
            child: const Icon(Icons.add),
            tooltip: 'Report Hazard',
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'admin',
            onPressed: () => Navigator.pushNamed(context, '/admin'),
            child: const Icon(Icons.admin_panel_settings),
            tooltip: 'Admin Panel',
          ),
        ],
      ),
    );
  }

  void _showHazardDetails(Hazard hazard) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(hazard.type),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${hazard.description}'),
            Text('Reported by: ${hazard.reportedBy}'),
            Text('Date: ${hazard.timestamp.toString()}'),
            Text('Location: ${hazard.latitude}, ${hazard.longitude}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showNewHazardDetails(String? description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Hazard Reported'),
        content: Text(description ?? 'No description provided.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
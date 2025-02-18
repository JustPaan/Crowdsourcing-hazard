import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'map_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _hazardDescriptionController = TextEditingController();
  final TextEditingController _reportedByController = TextEditingController();
  final TextEditingController _customHazardController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  String? _selectedHazardType;
  Position? _currentPosition;
  bool _isLoading = false;

  final List<String> _predefinedHazards = ['Flood', 'Fire', 'Landslide', 'Accident'];
  List<String> _hazardTypes = ['Others'];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchHazardTypes();
  }

  Future<void> _fetchHazardTypes() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('hazards').get();
      List<String> uniqueTypes = snapshot.docs
          .map((doc) => doc['type'].toString())
          .toSet()
          .toList();

      setState(() {
        _hazardTypes = [..._predefinedHazards, 'Others'];
      });
    } catch (e) {
      print("❌ Error fetching hazard types: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied. Please enable them from settings.')),
      );
      return;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _latitudeController.text = position.latitude.toString();
      _longitudeController.text = position.longitude.toString();
    });
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String hazardType = _selectedHazardType == "Others"
          ? _customHazardController.text.trim()
          : _selectedHazardType!;

      if (hazardType.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid hazard type')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      double? latitude = double.tryParse(_latitudeController.text.trim());
      double? longitude = double.tryParse(_longitudeController.text.trim());

      if (latitude == null || longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid latitude and longitude')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        DocumentReference docRef = await FirebaseFirestore.instance.collection('hazards').add({
          'type': hazardType,
          'description': _hazardDescriptionController.text.trim(),
          'latitude': latitude,
          'longitude': longitude,
          'timestamp': Timestamp.now(),
          'reportedBy': _reportedByController.text.isNotEmpty
              ? _reportedByController.text.trim()
              : 'Anonymous',
        });

        print("✅ Hazard report submitted: ${docRef.id}");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MapScreen(refresh: true),
          ),
        );
      } catch (e) {
        print("Firebase Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting report: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Hazard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedHazardType,
                decoration: const InputDecoration(labelText: 'Hazard Type', border: OutlineInputBorder()),
                items: _hazardTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedHazardType = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select a hazard type' : null,
              ),
              const SizedBox(height: 10),
              if (_selectedHazardType == "Others")
                TextFormField(
                  controller: _customHazardController,
                  decoration: const InputDecoration(labelText: 'Specify Other Hazard', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'Enter a hazard type' : null,
                ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _hazardDescriptionController,
                decoration: const InputDecoration(labelText: 'Hazard Description', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Please enter hazard description' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _reportedByController,
                decoration: const InputDecoration(labelText: 'Reported By (Optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _latitudeController,
                decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Please enter latitude' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _longitudeController,
                decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Please enter longitude' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitReport,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hazardDescriptionController.dispose();
    _reportedByController.dispose();
    _customHazardController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }
}

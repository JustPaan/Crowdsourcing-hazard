import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _reportedByController = TextEditingController();
  final TextEditingController _customHazardController = TextEditingController();
  String? _selectedHazardType;
  bool _isLoading = false;

  final List<String> _predefinedHazards = ['Flood', 'Fire', 'Landslide', 'Accident']; // ✅ Predefined hazard types
  List<String> _hazardTypes = ['Others']; // ✅ Default: Only "Others" initially

  @override
  void initState() {
    super.initState();
    _checkUserAuth();
    _fetchHazardTypes();
  }

  void _checkUserAuth() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _fetchHazardTypes() async {
    try {
      setState(() {
        _hazardTypes = [..._predefinedHazards, 'Others']; // ✅ Only predefined + "Others"
      });
    } catch (e) {
      print("❌ Error fetching hazard types: $e");
    }
  }

  Future<void> _deleteHazard(String hazardId) async {
    bool confirmDelete = await _showConfirmationDialog("Are you sure you want to delete this hazard?");
    if (confirmDelete) {
      await FirebaseFirestore.instance.collection('hazards').doc(hazardId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hazard deleted successfully!')),
      );
    }
  }

  Future<void> _addHazard() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      double? lat = double.tryParse(_latitudeController.text.trim());
      double? lon = double.tryParse(_longitudeController.text.trim());
      if (lat == null || lon == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid latitude or longitude')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

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

      try {
        await FirebaseFirestore.instance.collection('hazards').add({
          'type': hazardType,
          'description': _descriptionController.text.trim(),
          'latitude': lat,
          'longitude': lon,
          'timestamp': Timestamp.now(),
          'reportedBy': _reportedByController.text.isNotEmpty ? _reportedByController.text.trim() : 'Admin',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hazard added successfully!')),
        );

        _clearForm();
      } catch (e) {
        print("❌ Error adding hazard: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding hazard: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _customHazardController.clear();
    _descriptionController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
    _reportedByController.clear();
  }

  Future<bool> _showConfirmationDialog(String message) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirm"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Confirm"),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ Hazard Entry Form
            Form(
              key: _formKey,
              child: Column(
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
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                    maxLines: 2,
                    validator: (value) => value == null || value.isEmpty ? 'Enter description' : null,
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _latitudeController,
                    decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Enter latitude' : null,
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _longitudeController,
                    decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Enter longitude' : null,
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _addHazard,
                    child: _isLoading ? const CircularProgressIndicator() : const Text('Add Hazard'),
                  ),
                ],
              ),
            ),

            const Divider(),

            // ✅ List of reported hazards
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('hazards').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading hazards'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hazards reported yet.'));
                }

                final hazards = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: hazards.length,
                  itemBuilder: (context, index) {
                    final hazard = hazards[index];
                    return ListTile(
                      title: Text(hazard['type']),
                      subtitle: Text(hazard['description']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteHazard(hazard.id),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

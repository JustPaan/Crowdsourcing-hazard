import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String? selectedType;
  List<String> _hazardTypes = ['All', 'Others']; // ✅ Only predefined hazards + "Others"
  final List<String> _predefinedHazards = ['Flood', 'Fire', 'Landslide', 'Accident']; // ✅ Predefined types

  @override
  void initState() {
    super.initState();
    _fetchHazardTypes();
  }

  Future<void> _fetchHazardTypes() async {
    try {
      setState(() {
        _hazardTypes = ['All', ..._predefinedHazards, 'Others']; // ✅ No custom hazards in dropdown
      });
    } catch (e) {
      print("❌ Error fetching hazard types: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latest News'),
        actions: [
          DropdownButton<String>(
            value: selectedType,
            hint: const Text("Filter by type"),
            onChanged: (String? newValue) {
              setState(() {
                selectedType = newValue;
              });
            },
            items: _hazardTypes.map<DropdownMenuItem<String>>((String type) {
              return DropdownMenuItem<String>(
                value: type == 'All' ? null : type,
                child: Text(type),
              );
            }).toList(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('hazards').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading news'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No recent hazard reports.'));
          }

          final hazardsList = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .where((hazard) =>
                  selectedType == null ||
                  (selectedType == 'Others' && !_predefinedHazards.contains(hazard['type'])) || 
                  (selectedType != 'Others' && hazard['type'] == selectedType))
              .toList();

          return ListView.builder(
            itemCount: hazardsList.length,
            itemBuilder: (context, index) {
              var hazard = hazardsList[index];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text("New Hazard: ${hazard['type']}"),
                  subtitle: Text(
                    "Details: ${hazard['description']}\n"
                    "Reported by: ${hazard['reportedBy']}",
                  ),
                  trailing: Text(
                      hazard['timestamp'].toDate().toLocal().toString()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<dynamic> facilities = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadFacilities();
  }

  Future<void> loadFacilities() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final res = await http.get(Uri.parse('${auth.baseUrl}/api/facilities/'),
        headers: {'Authorization': 'Bearer ${auth.token}'});
    if (res.statusCode == 200) {
      setState(() {
        facilities = jsonDecode(res.body);
        _loading = false;
      });
    } else {
      setState(() {
        facilities = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (facilities.isEmpty) return const Center(child: Text('No facilities found'));

    return FlutterMap(
      options: MapOptions(
        center: LatLng(-13.9626, 33.7741), // Malawi approx center
        zoom: 7,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.datapp',
        ),
        MarkerLayer(  
          markers: facilities.map((f) {
            final lat = f['latitude'] ?? -13.9626;
            final lon = f['longitude'] ?? 33.7741;
            final name = f['name'] ?? 'Unknown';

            return Marker(
              point: LatLng(lat, lon),
              width: 40,
              height: 40,
              builder: (context) => Tooltip(
                message: name,
                child: const Icon(Icons.location_on, color: Colors.red, size: 30),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
   
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../constants.dart';

class Pharmacy {
  final String id;
  final String name;
  final String address;
  final LatLng position;

  Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    required this.position,
  });
}

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  late GoogleMapController mapController;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  bool _loading = true;
  String _errorMessage = '';
  List<Pharmacy> _pharmacies = [];
  Pharmacy? _selectedPharmacy;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check and request location permissions
      final status = await Permission.location.request();
      if (!status.isGranted) {
        setState(() {
          _loading = false;
          _errorMessage = 'Location permission denied';
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      // Fetch nearby pharmacies
      await _fetchNearbyPharmacies(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = 'Error getting location: $e';
      });
    }
  }

  Future<void> _fetchNearbyPharmacies(double lat, double lng) async {
    const apiKey =
        'AIzaSyAyC1piShMBPtC00vXGPBI6E-jq-SpN2fQ'; // Replace with your API key
    final radius = 5000; // 5km radius
    final type = 'pharmacy';

    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=$radius&type=$type&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _processPharmacyData(data['results']);
      } else {
        setState(() {
          _errorMessage = 'Failed to load pharmacies';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching pharmacies: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _processPharmacyData(List<dynamic> pharmacies) {
    _pharmacies =
        pharmacies.map((pharmacy) {
          final lat = pharmacy['geometry']['location']['lat'];
          final lng = pharmacy['geometry']['location']['lng'];
          final name = pharmacy['name'];
          final address = pharmacy['vicinity'] ?? 'No address provided';

          return Pharmacy(
            id: pharmacy['place_id'],
            name: name,
            address: address,
            position: LatLng(lat, lng),
          );
        }).toList();

    _addMarkers();
  }

  void _addMarkers() {
    _markers.clear();

    // Add current location marker if available
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentPosition!,
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // Add pharmacy markers
    for (var pharmacy in _pharmacies) {
      final marker = Marker(
        markerId: MarkerId(pharmacy.id),
        position: pharmacy.position,
        infoWindow: InfoWindow(title: pharmacy.name, snippet: pharmacy.address),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );

      _markers.add(marker);
    }
  }

  void _onPharmacySelected(Pharmacy? pharmacy) {
    setState(() {
      _selectedPharmacy = pharmacy;
    });

    if (pharmacy != null && mapController != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(pharmacy.position, 16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Pharmacies"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loading = true;
                _markers.clear();
                _pharmacies.clear();
                _selectedPharmacy = null;
              });
              _getCurrentLocation();
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_currentPosition != null) {
                mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(_currentPosition!, 15),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildMap(),
          if (_pharmacies.isNotEmpty && !_loading)
            Positioned(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              child: _buildPharmacyDropdown(),
            ),
        ],
      ),
    );
  }

  Widget _buildPharmacyDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          24.0,
        ), // More rounded corners like Google Maps
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12.0, // Softer shadow
            spreadRadius: 0.5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Pharmacy>(
            value: _selectedPharmacy,
            isExpanded: true,
            hint: const Text(
              'Select Pharmacy',
              style: TextStyle(color: Colors.grey),
            ),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            items:
                _pharmacies.map((Pharmacy pharmacy) {
                  return DropdownMenuItem<Pharmacy>(
                    value: pharmacy,
                    child: Text(
                      pharmacy.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16.0, // Slightly larger text
                      ),
                    ),
                  );
                }).toList(),
            onChanged: _onPharmacySelected,
            style: const TextStyle(
              color: Colors.black, // Text color when selected
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMap() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    if (_currentPosition == null) {
      return const Center(child: Text('Unable to determine location'));
    }

    return GoogleMap(
      onMapCreated: (controller) {
        setState(() {
          mapController = controller;
        });
      },
      initialCameraPosition: CameraPosition(
        target: _currentPosition!,
        zoom: 15,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      compassEnabled: true,
    );
  }
}

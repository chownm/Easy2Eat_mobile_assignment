import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/core/routing/RiderRouting.dart';
import 'package:easy2eat/services/maps/map_api_service.dart';

class GeoapifyMapWidget extends StatefulWidget {
  final String deliveryNumber;
  final String name;

  GeoapifyMapWidget({
    super.key,
    this.deliveryNumber = "Delivery Number 1234",
    this.name = "Chow Booh Hwa",
  });

  @override
  State<GeoapifyMapWidget> createState() => _GeoapifyMapWidgetState();
}

class _GeoapifyMapWidgetState extends State<GeoapifyMapWidget> {
  final MapController _mapController = MapController();

  static const LatLng _customerLocation = LatLng(
    3.1500,
    101.7000,
  ); // Customer location

  String _destinationAddress = "Fetching delivery address...";
  String _routeInfo = "Tap locate button to calculate route";

  LatLng? _currentPosition; // Null initially
  List<LatLng> _routePoints = [];

  bool _showDeliveryCard = true;

  @override
  void initState() {
    super.initState();
    _loadDestinationAddress();
  }

  Future<void> _loadDestinationAddress() async {
    final address = await MapApiService.getAddressFromCoordinates(
      _customerLocation.latitude,
      _customerLocation.longitude,
    );
    if (mounted) {
      setState(() {
        _destinationAddress = address ?? "Fetching...";
      });
    }
  }

  Future<void> _locateRiderGPS() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable GPS Location Services.')),
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        final newPos = LatLng(position.latitude, position.longitude);
        setState(() {
          _currentPosition = newPos;
        });
        _mapController.move(newPos, 15.0);
        await _loadRouteInfo(newPos);
      }
    } catch (_) {}

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (mounted) {
        final newPos = LatLng(position.latitude, position.longitude);
        setState(() {
          _currentPosition = newPos;
        });
        _loadRouteInfo(newPos);
      }
    });
  }

  Future<void> _loadRouteInfo(LatLng startPos) async {
    final route = await MapApiService.getDeliveryRoute(
      startLat: startPos.latitude,
      startLng: startPos.longitude,
      endLat: _customerLocation.latitude,
      endLng: _customerLocation.longitude,
    );

    if (mounted) {
      setState(() {
        if (route != null && route.routePoints.isNotEmpty) {
          _routeInfo =
              "${route.distanceKm.toStringAsFixed(1)} km • ${route.durationMinutes.toStringAsFixed(0)} mins away";
          _routePoints = route.routePoints;
        } else {
          _routeInfo = "3.2 km • 12 mins away";
          _routePoints = [startPos, _customerLocation];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String apiKey = MapApiService.geoapifyApiKey;

    return Stack(
      children: [
        // Geoapify Map Tiles via FlutterMap
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: _customerLocation,
            initialZoom: 14.0,
          ),
          children: [
            // Tile Layer
            TileLayer(
              urlTemplate:
                  'https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=$apiKey',
              userAgentPackageName: 'com.easy2eat.app',
            ),

            // Polyline Layer for Road Route
            if (_routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 5.0,
                    color: ThemesColors.brandOrange,
                  ),
                ],
              ),

            // Markers Layer for Customer and Live Rider
            MarkerLayer(
              markers: [
                const Marker(
                  point: _customerLocation,
                  width: 50,
                  height: 50,
                  child: Icon(Icons.location_on, color: Colors.red, size: 38),
                ),
                if (_currentPosition != null)
                  Marker(
                    point: _currentPosition!,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.navigation,
                      color: ThemesColors.brandOrange,
                      size: 36,
                    ),
                  ),
              ],
            ),
          ],
        ),

        // Floating Action Button to Locate Rider GPS Position
        Positioned(
          right: 16,
          top: 16,
          child: FloatingActionButton.small(
            heroTag: "locateRiderGps",
            backgroundColor: Colors.white,
            onPressed: _locateRiderGPS,
            child: const Icon(
              Icons.my_location,
              color: ThemesColors.darkCharcoal,
            ),
          ),
        ),

        // Floating Action Button to Re-open Card when Closed
        if (!_showDeliveryCard)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: "reopenCard",
              backgroundColor: ThemesColors.brandOrange,
              onPressed: () {
                setState(() {
                  _showDeliveryCard = true;
                });
              },
              child: const Icon(
                Icons.local_shipping_outlined,
                color: Colors.white,
              ),
            ),
          ),

        // Bottom Delivery Destination Overlay Card
        if (_showDeliveryCard)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Delivery Number & Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.deliveryNumber,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: ThemesColors.darkCharcoal,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          setState(() {
                            _showDeliveryCard = false;
                          });
                        },
                      ),
                    ],
                  ),

                  // Route Info: Distance & Duration
                  Row(
                    children: [
                      const Icon(
                        Icons.navigation_outlined,
                        color: ThemesColors.brandOrange,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _routeInfo,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ThemesColors.brandOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Destination Address
                  Text(
                    _destinationAddress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 14),

                  // Action Button: Chat With Customer
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemesColors.darkCharcoal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.chatWindow,
                          arguments: widget.name,
                        );
                      },
                      icon: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: Colors.white,
                      ),
                      label: Text(
                        "Chat With ${widget.name}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

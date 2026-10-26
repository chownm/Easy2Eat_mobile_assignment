import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/core/routing/RiderRouting.dart';
import 'package:easy2eat/core/constants/active_delivery.dart';
import 'package:easy2eat/services/maps/map_api_service.dart';

class GeoapifyMapWidget extends StatefulWidget {
  final String deliveryNumber;
  final String name;

  GeoapifyMapWidget({
    super.key,
    this.deliveryNumber = "Delivery #1234",
    this.name = "Chow Booh Hwa",
  });

  @override
  State<GeoapifyMapWidget> createState() => _GeoapifyMapWidgetState();
}

class _GeoapifyMapWidgetState extends State<GeoapifyMapWidget> {
  final MapController _mapController = MapController();

  static const LatLng _vendorLocation = LatLng(3.1400, 101.6900); // Vendor Store
  static const LatLng _customerLocation = LatLng(3.1500, 101.7000); // Customer Drop Off

  String _destinationAddress = "Fetching delivery address...";
  String _routeInfo = "Tap locate button to calculate route";

  LatLng? _currentPosition;
  List<LatLng> _routePoints = [];

  bool _showDeliveryCard = true;

  @override
  void initState() {
    super.initState();
    _loadDestinationAddress();
  }

  LatLng get _activeDestination => ActiveDeliveryState.isVendorQrScanned
      ? _customerLocation
      : _vendorLocation;

  Future<void> _loadDestinationAddress() async {
    final target = _activeDestination;
    final address = await MapApiService.getAddressFromCoordinates(
      target.latitude,
      target.longitude,
    );
    if (mounted) {
      setState(() {
        _destinationAddress = address ??
            (ActiveDeliveryState.isVendorQrScanned
                ? "Drop Off: Jalan Tun"
                : "Pickup: Kuala Lumpur Store");
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
    final target = _activeDestination;
    final route = await MapApiService.getDeliveryRoute(
      startLat: startPos.latitude,
      startLng: startPos.longitude,
      endLat: target.latitude,
      endLng: target.longitude,
    );

    if (mounted) {
      setState(() {
        if (route != null && route.routePoints.isNotEmpty) {
          _routeInfo =
              "${route.distanceKm.toStringAsFixed(1)} km • ${route.durationMinutes.toStringAsFixed(0)} mins away";
          _routePoints = route.routePoints;
        } else {
          _routeInfo = "3.2 km • 12 mins away";
          _routePoints = [startPos, target];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String apiKey = MapApiService.geoapifyApiKey;
    final bool isHeadingToCustomer = ActiveDeliveryState.isVendorQrScanned;
    final LatLng destinationPoint = _activeDestination;

    return Stack(
      children: [
        // Geoapify Map Tiles via FlutterMap
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: destinationPoint,
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

            // Markers Layer: Turns from Vendor Store icon to Customer Location Pin!
            MarkerLayer(
              markers: [
                Marker(
                  point: destinationPoint,
                  width: 50,
                  height: 50,
                  child: isHeadingToCustomer
                      ? const Icon(Icons.location_on, color: Colors.red, size: 38)
                      : Container(
                          decoration: const BoxDecoration(
                            color: ThemesColors.brandOrange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.storefront_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
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
                  // Top Row: Delivery Number & Phase Badge & Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.deliveryNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ThemesColors.darkCharcoal,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Dynamic Status Badge: Changes character from Vendor to Customer!
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isHeadingToCustomer
                                  ? ThemesColors.success.withValues(alpha: 0.15)
                                  : ThemesColors.brandOrange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isHeadingToCustomer
                                      ? Icons.person_pin_circle
                                      : Icons.storefront,
                                  size: 14,
                                  color: isHeadingToCustomer
                                      ? ThemesColors.success
                                      : ThemesColors.brandOrange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isHeadingToCustomer
                                      ? "GOING TO CUSTOMER"
                                      : "GOING TO VENDOR",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isHeadingToCustomer
                                        ? ThemesColors.success
                                        : ThemesColors.brandOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

                  // Action Buttons: Chat With Vendor & Chat With Customer
                  Row(
                    children: [
                      // Chat With Vendor Button
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: ThemesColors.darkCharcoal,
                            side: const BorderSide(
                              color: ThemesColors.darkCharcoal,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            final chatTitle = "Vendor ${widget.deliveryNumber}";
                            ChatListState.startOrOpenChat(chatTitle, context);
                            Navigator.pushNamed(
                              context,
                              AppRoutes.chatWindow,
                              arguments: chatTitle,
                            );
                          },
                          icon: const Icon(
                            Icons.storefront_outlined,
                            color: ThemesColors.darkCharcoal,
                            size: 18,
                          ),
                          label: const Text(
                            "Chat Vendor",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Chat With Customer Button
                      Expanded(
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
                            final chatTitle = "Customer ${widget.deliveryNumber}";
                            ChatListState.startOrOpenChat(chatTitle, context);
                            Navigator.pushNamed(
                              context,
                              AppRoutes.chatWindow,
                              arguments: chatTitle,
                            );
                          },
                          icon: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text(
                            "Chat Customer",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

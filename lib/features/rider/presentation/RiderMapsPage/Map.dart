import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/core/routing/RiderRouting.dart';
import 'package:easy2eat/core/constants/active_delivery.dart';
import 'package:easy2eat/services/maps/map_api_service.dart';

class GeoapifyMapWidget extends StatefulWidget {
  final String? deliveryNumber;
  final String name;

  const GeoapifyMapWidget({
    super.key,
    this.deliveryNumber,
    this.name = "Chow Booh Hwa",
  });

  @override
  State<GeoapifyMapWidget> createState() => _GeoapifyMapWidgetState();
}

class _GeoapifyMapWidgetState extends State<GeoapifyMapWidget> {
  final MapController _mapController = MapController();

  static const LatLng _defaultCenter = LatLng(3.1400, 101.6900); // KL Center
  
  // Dynamic locations fetched from active order in Firestore
  LatLng _vendorLocation = const LatLng(3.1400, 101.6900); // Vendor Store
  LatLng _customerLocation = const LatLng(3.1500, 101.7000); // Customer Drop Off

  String _destinationAddress = "No result";
  String _routeInfo = "No result";

  LatLng? _currentPosition;
  List<LatLng> _routePoints = [];

  bool _showDeliveryCard = true;
  bool _isHeadingToCustomer = false; // Toggle between Vendor & Customer

  @override
  void initState() {
    super.initState();
    _isHeadingToCustomer = ActiveDeliveryState.isVendorQrScanned;
    _loadOrderFromFirestore();
  }

  String get _activeDeliveryNum {
    final num = widget.deliveryNumber ?? ActiveDeliveryState.currentDeliveryNumber;
    if (num.isEmpty || num == 'Unknown Delivery') {
      return "";
    }
    return num;
  }

  LatLng get _activeDestination =>
      _isHeadingToCustomer ? _customerLocation : _vendorLocation;

  Future<void> _loadOrderFromFirestore() async {
    if (_activeDeliveryNum.isEmpty) {
      if (mounted) {
        setState(() {
          _destinationAddress = "No result";
          _routeInfo = "No result";
        });
      }
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(_activeDeliveryNum)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        
        final double pLat = (data['pickupLat'] as num?)?.toDouble() ?? 3.1400;
        final double pLng = (data['pickupLng'] as num?)?.toDouble() ?? 101.6900;
        final double dLat = (data['dropoffLat'] as num?)?.toDouble() ?? 3.1500;
        final double dLng = (data['dropoffLng'] as num?)?.toDouble() ?? 101.7000;

        if (mounted) {
          setState(() {
            _vendorLocation = LatLng(pLat, pLng);
            _customerLocation = LatLng(dLat, dLng);
          });
        }
      }
    } catch (_) {}

    await _loadDestinationAddress();
    if (_currentPosition != null) {
      await _loadRouteInfo(_currentPosition!);
    }
  }

  Future<void> _loadDestinationAddress() async {
    if (_activeDeliveryNum.isEmpty) return;

    final target = _activeDestination;
    final address = await MapApiService.getAddressFromCoordinates(
      target.latitude,
      target.longitude,
    );
    if (mounted) {
      setState(() {
        _destinationAddress = address ?? "No result";
      });
    }
  }

  Future<void> _locateRiderGPS() async {
    if (_activeDeliveryNum.isEmpty) return;

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
    if (_activeDeliveryNum.isEmpty) return;

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
          _routeInfo = "No result";
          _routePoints = [startPos, target];
        }
      });
    }
  }

  void _toggleDestinationPhase() {
    if (_activeDeliveryNum.isEmpty) return;

    setState(() {
      _isHeadingToCustomer = !_isHeadingToCustomer;
    });
    _loadDestinationAddress();
    if (_currentPosition != null) {
      _loadRouteInfo(_currentPosition!);
    } else {
      _mapController.move(_activeDestination, 14.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String apiKey = MapApiService.geoapifyApiKey;
    final String deliveryId = _activeDeliveryNum;
    final bool hasActiveDelivery = deliveryId.isNotEmpty;
    final LatLng destinationPoint = hasActiveDelivery ? _activeDestination : _defaultCenter;

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

            // Polyline Layer for Road Route (Only if active delivery exists)
            if (hasActiveDelivery && _routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 5.0,
                    color: ThemesColors.brandOrange,
                  ),
                ],
              ),

            // Markers Layer (Only if active delivery exists)
            if (hasActiveDelivery)
              MarkerLayer(
                markers: [
                  Marker(
                    point: destinationPoint,
                    width: 50,
                    height: 50,
                    child: _isHeadingToCustomer
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
        if (hasActiveDelivery)
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
        if (!_showDeliveryCard && hasActiveDelivery)
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

        // Bottom Delivery Destination Overlay Card or No Active Delivery State
        if (_showDeliveryCard)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: hasActiveDelivery
                ? Container(
                    padding: const EdgeInsets.all(14),
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
                        // Top Row: Delivery Number & Compact Phase Switch Badge & Close Icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    deliveryId,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: ThemesColors.darkCharcoal,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Compact Switch Badge with Arrow Icon
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: _toggleDestinationPhase,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _isHeadingToCustomer
                                              ? ThemesColors.success.withValues(alpha: 0.15)
                                              : ThemesColors.brandOrange.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: _isHeadingToCustomer
                                                ? ThemesColors.success
                                                : ThemesColors.brandOrange,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _isHeadingToCustomer
                                                  ? Icons.person_pin_circle
                                                  : Icons.storefront,
                                              size: 13,
                                              color: _isHeadingToCustomer
                                                  ? ThemesColors.success
                                                  : ThemesColors.brandOrange,
                                            ),
                                            const SizedBox(width: 3),
                                            Flexible(
                                              child: Text(
                                                _isHeadingToCustomer
                                                    ? "GOING TO CUSTOMER"
                                                    : "GOING TO VENDOR",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: _isHeadingToCustomer
                                                      ? ThemesColors.success
                                                      : ThemesColors.brandOrange,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 3),
                                            Icon(
                                              Icons.swap_horiz_rounded,
                                              size: 14,
                                              color: _isHeadingToCustomer
                                                  ? ThemesColors.success
                                                  : ThemesColors.brandOrange,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Compact Close Button
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showDeliveryCard = false;
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  color: ThemesColors.darkCharcoal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

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
                                  final chatTitle = "Vendor $deliveryId";
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
                                  final chatTitle = "Customer $deliveryId";
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
                  )
                : Container(
                    padding: const EdgeInsets.all(20),
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
                      children: [
                        const Icon(
                          Icons.map_outlined,
                          size: 48,
                          color: ThemesColors.brandOrange,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "No Active Delivery Selected",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ThemesColors.darkCharcoal,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Please go to the Delivery Page and tap 'View Route' on an accepted order to view the route.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemesColors.darkCharcoal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.riderHome,
                              );
                            },
                            child: const Text(
                              "Go to Delivery Page",
                              style: TextStyle(
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

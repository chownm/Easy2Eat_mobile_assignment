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

  const GeoapifyMapWidget({
    super.key,
    this.deliveryNumber,
  });

  @override
  State<GeoapifyMapWidget> createState() => _GeoapifyMapWidgetState();
}

class _GeoapifyMapWidgetState extends State<GeoapifyMapWidget> {
  final MapController _mapController = MapController();

  // Dynamic locations fetched from active order in Firestore
  LatLng _vendorLocation = const LatLng(3.0519, 101.6923); // Vendor Store
  LatLng _customerLocation = const LatLng(3.0562, 101.6881); // Customer Drop Off

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

  void _toggleDestination() {
    setState(() {
      _isHeadingToCustomer = !_isHeadingToCustomer;
    });
    _loadDestinationAddress();
    _mapController.move(_activeDestination, 15.0);
    if (_currentPosition != null) {
      _loadRouteInfo(_currentPosition!);
    }
  }

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

        // 1. Read vendor location and customer deliveryAddress string directly from Firestore
        final String vendorAddressStr = data['location'] as String? ??
            data['pickupLocation'] as String? ?? '';

        final String customerAddressStr = data['deliveryAddress'] as String? ??
            data['dropOffLocation'] as String? ?? '';

        // 2. Geocode vendor address string to LatLng
        final LatLng? vendorLatLng =
            await MapApiService.getCoordinatesFromAddress(vendorAddressStr);

        // 3. Geocode customer address string to LatLng
        final LatLng? customerLatLng =
            await MapApiService.getCoordinatesFromAddress(customerAddressStr);

        if (mounted) {
          setState(() {
            _vendorLocation = vendorLatLng ?? const LatLng(3.0519, 101.6923);
            _customerLocation = customerLatLng ?? const LatLng(3.0562, 101.6881);
            _destinationAddress =
                _isHeadingToCustomer ? customerAddressStr : vendorAddressStr;
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
        if (address != null && address.isNotEmpty) {
          _destinationAddress = address;
        }
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

    Position pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    final riderLatLng = LatLng(pos.latitude, pos.longitude);

    if (mounted) {
      setState(() {
        _currentPosition = riderLatLng;
      });

      _mapController.move(riderLatLng, 15.0);
      await _loadRouteInfo(riderLatLng);
    }
  }

  Future<void> _loadRouteInfo(LatLng startPos) async {
    final target = _activeDestination;

    final routeInfo = await MapApiService.getDeliveryRoute(
      startLat: startPos.latitude,
      startLng: startPos.longitude,
      endLat: target.latitude,
      endLng: target.longitude,
    );

    if (routeInfo != null && mounted) {
      setState(() {
        _routeInfo =
            "${routeInfo.distanceKm.toStringAsFixed(1)} km • ${routeInfo.durationMinutes.ceil()} mins away";
        _routePoints = routeInfo.routePoints;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliveryId = _activeDeliveryNum;
    final hasActiveDelivery = deliveryId.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // FlutterMap Tile Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _activeDestination,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://maps.geoapify.com/v1/tile/osm-carto/{z}/{x}/{y}.png?apiKey=${MapApiService.geoapifyApiKey}',
                userAgentPackageName: 'com.example.easy2eat',
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: ThemesColors.brandOrange,
                      strokeWidth: 5.0,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (_currentPosition != null)
                    Marker(
                      point: _currentPosition!,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.navigation_rounded,
                          color: Colors.blue,
                          size: 32,
                        ),
                      ),
                    ),
                  Marker(
                    point: _activeDestination,
                    width: 50,
                    height: 50,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: ThemesColors.brandOrange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 6)
                        ],
                      ),
                      child: Icon(
                        _isHeadingToCustomer
                            ? Icons.person_pin_circle
                            : Icons.storefront_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Floating GPS Recenter Button
          Positioned(
            top: 40,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'recenter_map',
              backgroundColor: Colors.white,
              onPressed: _locateRiderGPS,
              child: const Icon(Icons.my_location, color: ThemesColors.darkCharcoal),
            ),
          ),

          // Floating Toggle Card Visibility
          if (hasActiveDelivery)
            Positioned(
              top: 40,
              left: 16,
              child: FloatingActionButton.small(
                heroTag: 'toggle_card',
                backgroundColor: ThemesColors.darkCharcoal,
                onPressed: () {
                  setState(() {
                    _showDeliveryCard = !_showDeliveryCard;
                  });
                },
                child: Icon(
                  _showDeliveryCard ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white,
                ),
              ),
            ),

          // Bottom Active Delivery Overlay Card
          if (hasActiveDelivery && _showDeliveryCard)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Interactive Header Status Badge (Tap to Toggle Destination)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: _toggleDestination,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: ThemesColors.brandOrange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: ThemesColors.brandOrange.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _isHeadingToCustomer
                                      ? "GOING TO CUSTOMER 🔄"
                                      : "GOING TO VENDOR 🔄",
                                  style: const TextStyle(
                                    color: ThemesColors.brandOrange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          deliveryId,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: ThemesColors.darkCharcoal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Destination Address
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: ThemesColors.brandOrange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _destinationAddress,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: ThemesColors.darkCharcoal,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // ETA & Distance Info
                    Row(
                      children: [
                        const Icon(
                          Icons.two_wheeler_rounded,
                          color: Colors.grey,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _routeInfo,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Chat Action Buttons (Vendor vs Customer)
                    Row(
                      children: [
                        // Chat With Vendor Button
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              foregroundColor: ThemesColors.darkCharcoal,
                              elevation: 0,
                              side: const BorderSide(color: Color(0xFFEEEEEE)),
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
              ),
            )
          else if (!hasActiveDelivery)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
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
                    const SizedBox(height: 4),
                    Text(
                      "Accept an order on the Delivery Page to view route directions.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

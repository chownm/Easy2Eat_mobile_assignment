import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/features/customer/models/order_tracking_model.dart';
import 'package:easy2eat/services/maps/map_api_service.dart';

class CustomerLiveTrackingMapView extends StatefulWidget {
  final CorridorRouteModel corridor;
  final String deliveryAddress;
  final OrderTrackingStage stage;
  final int etaMinutesRemaining;
  final ValueChanged<RouteInfo>? onRouteLoaded;

  const CustomerLiveTrackingMapView({
    super.key,
    required this.corridor,
    required this.deliveryAddress,
    required this.stage,
    this.etaMinutesRemaining = 4, // Default fallback
    this.onRouteLoaded,
  });

  @override
  State<CustomerLiveTrackingMapView> createState() =>
      _CustomerLiveTrackingMapViewState();
}

class _CustomerLiveTrackingMapViewState
    extends State<CustomerLiveTrackingMapView> {
  final MapController _mapController = MapController();

  // Coordinates: Geocoded from realtime fields (Fallback to defaults if offline)
  LatLng _merchantCoords = const LatLng(3.0398, 101.7635);
  LatLng _customerCoords = const LatLng(3.0365, 101.7665);
  LatLng _riderCoords = const LatLng(3.0398, 101.7635); // Starts at merchants

  List<LatLng> _routePoints = <LatLng>[];
  bool _isLoadingRoute = true;
  int _initialTransitMinutes = 4;

  @override
  void initState() {
    super.initState();
    _fetchGeoapifyDeliveryRoute();
  }

  @override
  void didUpdateWidget(covariant CustomerLiveTrackingMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recalculate rider marker position whenever the minute counter changes or stage updates
    if (oldWidget.etaMinutesRemaining != widget.etaMinutesRemaining ||
        oldWidget.stage != widget.stage) {
      _updateRiderPosition();
    }
  }

  /// Calculates the exact LatLng on the road polyline based on remaining transit time
  void _updateRiderPosition() {
    if (_routePoints.isEmpty) return;

    // 1. If still preparing or awaiting pickup, rider stays at Restaurant (Point A)
    if (widget.stage == OrderTrackingStage.confirmed ||
        widget.stage == OrderTrackingStage.preparing) {
      setState(() {
        _riderCoords = _merchantCoords;
      });
      return;
    }

    // 2. If delivered, rider is at Customer Gate (Point B)
    if (widget.stage == OrderTrackingStage.delivered || widget.etaMinutesRemaining <= 0) {
      setState(() {
        _riderCoords = _customerCoords;
      });
      return;
    }

    // 3. During Transit (Almost Done): Compute progress ratio along the polyline (0.0 to 1.0)
    final double remaining = widget.etaMinutesRemaining.toDouble();
    final double total = _initialTransitMinutes.toDouble().clamp(1.0, 30.0);

    // Progress goes from 0.0 (just picked up) to 1.0 (reached destination)
    final double progress = (1.0 - (remaining / total)).clamp(0.0, 1.0);

    // Map progress ratio to the corresponding index in the road polyline points list
    final int targetIndex = ((_routePoints.length - 1) * progress).round();

    setState(() {
      _riderCoords = _routePoints[targetIndex];
    });
  }

  /// Calls MapApiService.getDeliveryRoute using Retrofit + Dio
  Future<void> _fetchGeoapifyDeliveryRoute() async {
    setState(() => _isLoadingRoute = true);

    try {
      // 1. Geocode dynamic locations using full context for better accuracy
      final vendorLatLng = await MapApiService.getCoordinatesFromAddress(widget.corridor.merchantHub);
      final customerLatLng = await MapApiService.getCoordinatesFromAddress(widget.deliveryAddress);
      
      if (vendorLatLng != null) _merchantCoords = vendorLatLng;
      if (customerLatLng != null) _customerCoords = customerLatLng;

      // 2. Fetch Routing Polylines
      final RouteInfo? routeInfo = await MapApiService.getDeliveryRoute(
        startLat: _merchantCoords.latitude,
        startLng: _merchantCoords.longitude,
        endLat: _customerCoords.latitude,
        endLng: _customerCoords.longitude,
        mode: 'drive',
      );

      if (routeInfo != null && routeInfo.routePoints.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _routePoints = routeInfo.routePoints;
          _initialTransitMinutes = routeInfo.durationMinutes.round().clamp(2, 20);
          _isLoadingRoute = false;
        });

        _updateRiderPosition();
        _recenterMap();
        // Notify parent to sync actual distance and ETA
        widget.onRouteLoaded?.call(routeInfo);
      } else {
        _setFallbackCorridorRoute();
      }
    } catch (_) {
      _setFallbackCorridorRoute();
    }
  }

  /// Fallback waypoints along Cheras C180 corridor in case of no internet or rate limit
  void _setFallbackCorridorRoute() {
    if (!mounted) return;
    setState(() {
      _routePoints = <LatLng>[
        _merchantCoords,
        const LatLng(3.0392, 101.7640),
        const LatLng(3.0385, 101.7648),
        const LatLng(3.0375, 101.7658),
        _customerCoords,
      ];
      _initialTransitMinutes = 4;
      _isLoadingRoute = false;
    });
    _updateRiderPosition();
    _recenterMap();
  }

  /// Re-centers the map view over the route corridor
  void _recenterMap() {
    if (_routePoints.isNotEmpty) {
      final int midIndex = _routePoints.length ~/ 2;
      _mapController.move(_routePoints[midIndex], 15.0);
    } else {
      final double lat = (_merchantCoords.latitude + _customerCoords.latitude) / 2;
      final double lng = (_merchantCoords.longitude + _customerCoords.longitude) / 2;
      _mapController.move(LatLng(lat, lng), 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Geoapify tile URL with OpenStreetMap fallback if API key is not configured
    final String apiKey = MapApiService.geoapifyApiKey;
    final String tileUrl = apiKey.isNotEmpty
        ? 'https://maps.geoapify.com/v1/tile/osm-carto/{z}/{x}/{y}.png?apiKey=$apiKey'
        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    return Stack(
      children: <Widget>[
        // ====================================================================
        // 1. REAL FLUTTER_MAP LAYER (Geoapify Tiles + Road Polylines)
        // ====================================================================
        Positioned.fill(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(3.0378, 101.7650),
              initialZoom: 15.0,
              minZoom: 13.0,
              maxZoom: 18.5,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom |
                InteractiveFlag.drag |
                InteractiveFlag.doubleTapZoom,
              ),
            ),
            children: <Widget>[
              // Geoapify Tile Layer
              TileLayer(
                urlTemplate: tileUrl,
                userAgentPackageName: 'com.easy2eat.app',
              ),

              // Turn-by-Turn Road Polylines from Geoapify Routing API
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: <Polyline>[
                    Polyline(
                      points: _routePoints,
                      color: ThemesColors.brandOrange,
                      strokeWidth: 5.0,
                      strokeCap: StrokeCap.round,
                      strokeJoin: StrokeJoin.round,
                    ),
                  ],
                ),

              // Location Markers (Point A, Point B, Rider)
              MarkerLayer(
                markers: <Marker>[
                  // Point A: Merchant Pin
                  Marker(
                    point: _merchantCoords,
                    width: 100,
                    height: 60,
                    alignment: Alignment.topCenter,
                    child: _buildLocationPin(
                      label: 'A',
                      color: ThemesColors.darkCharcoal,
                      title: widget.corridor.merchantName,
                    ),
                  ),

                  // Point B: Customer Sub-Pin
                  Marker(
                    point: _customerCoords,
                    width: 110,
                    height: 60,
                    alignment: Alignment.topCenter,
                    child: _buildLocationPin(
                      label: 'B',
                      color: ThemesColors.freshGreen,
                      title: widget.corridor.dropOffLandmark,
                    ),
                  ),

                  // Rider In-Transit Pin
                  Marker(
                    point: _riderCoords,
                    width: 36,
                    height: 36,
                    child: Container(
                      decoration: BoxDecoration(
                        color: ThemesColors.brandOrange,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ThemesColors.appSurface,
                          width: 2.2,
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: ThemesColors.brandOrange.withValues(
                              alpha: 0.4,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.two_wheeler_rounded,
                        color: ThemesColors.appSurface,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ====================================================================
        // 2. TOP FLOATING BADGES (<1km Corridor & Unstacked Priority)
        // ====================================================================
        Positioned(
          top: 104,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Left Badge: <1km Direct Corridor Active
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: ThemesColors.appSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ThemesColors.darkCharcoal.withValues(alpha: 0.12),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: ThemesColors.freshGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isLoadingRoute
                          ? 'Fetching Route...'
                          : '<1km Direct Corridor\nActive',
                      style: const TextStyle(
                        color: ThemesColors.darkCharcoal,
                        fontSize: 9.5,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // Right Badge: UNSTACKED ROUTE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: ThemesColors.darkCharcoal,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'UNSTACKED\nROUTE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ThemesColors.appSurface,
                    fontSize: 9,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ====================================================================
        // 3. FLOATING RE-CENTER BUTTON
        // ====================================================================
        Positioned(
          right: 16,
          top: 160,
          child: InkWell(
            onTap: _recenterMap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: ThemesColors.appSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ThemesColors.darkCharcoal.withValues(alpha: 0.15),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.my_location_rounded,
                size: 20,
                color: ThemesColors.darkCharcoal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationPin({
    required String label,
    required Color color,
    required String title,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: ThemesColors.appSurface, width: 2),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: ThemesColors.appSurface,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: ThemesColors.appSurface,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: ThemesColors.darkCharcoal.withValues(alpha: 0.15),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 3,
              ),
            ],
          ),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color == ThemesColors.freshGreen
                  ? ThemesColors.freshGreen
                  : ThemesColors.darkCharcoal,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
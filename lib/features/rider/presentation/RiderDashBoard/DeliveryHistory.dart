import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/user_session.dart';
import '../../../../core/theme/theme.dart';

class DeliveryHistory extends StatelessWidget {
  final String orderCode;
  final String time;
  final String storeName;
  final String dropoffLocation;
  final String earning;
  final VoidCallback? onTap;

  const DeliveryHistory({
    super.key,
    required this.orderCode,
    required this.time,
    required this.storeName,
    required this.dropoffLocation,
    required this.earning,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            color: ThemesColors.darkCharcoal,
            size: 20,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Line 1: Order Code & Time (Wrapped in Expanded/Flexible to prevent 56px overflow)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    orderCode,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ThemesColors.darkCharcoal,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Line 2: Store Name -> Dropoff & Earning Amount
            Row(
              children: [
                Expanded(
                  child: Text(
                    "$storeName → $dropoffLocation",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  earning,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ThemesColors.darkCharcoal,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
      ),
    );
  }
}

/// Dynamic List Builder for Delivery History fetched via FutureBuilder (triggered by RefreshButton)
class DeliveryHistoryList extends StatefulWidget {
  const DeliveryHistoryList({super.key});

  @override
  State<DeliveryHistoryList> createState() => DeliveryHistoryListState();
}

class DeliveryHistoryListState extends State<DeliveryHistoryList> {
  late Future<List<Map<String, dynamic>>> _tripsFuture;

  @override
  void initState() {
    super.initState();
    _tripsFuture = _fetchTrips();
  }

  void refreshTrips() {
    setState(() {
      _tripsFuture = _fetchTrips();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchTrips() async {
    final uid = UserSession.currentUid ?? 'guest_rider';
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('recent_trips')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (_) {
      return [];
    }
  }

  void _showTripDetailsModal(BuildContext context, Map<String, dynamic> tripData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      tripData['deliveryId'] ?? 'Delivery #0001',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ThemesColors.darkCharcoal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.storefront, size: 18, color: ThemesColors.darkCharcoal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Pickup: Kuala Lumpur",
                      style: TextStyle(color: Colors.grey[700]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 18, color: ThemesColors.darkCharcoal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Drop Off: ${tripData['destination'] ?? 'Jalan Tun'}",
                      style: TextStyle(color: Colors.grey[700]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Earning:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(
                    tripData['earning']?.toString().startsWith('RM') == true
                        ? tripData['earning']
                        : "RM ${tripData['earning'] ?? '100.00'}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ThemesColors.success),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _tripsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: ThemesColors.brandOrange));
        }

        final trips = snapshot.data ?? [];

        if (trips.isEmpty) {
          return Center(
            child: Text(
              "No recent trip records yet.",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          );
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: trips.length,
          itemBuilder: (context, index) {
            final data = trips[index];

            final deliveryId = data['deliveryId'] ?? "#E2E-${8842 - index}";
            final destination = data['destination'] ?? "Subang Jaya";
            final earningRaw = data['earning']?.toString() ?? "10.00";
            final earning = earningRaw.startsWith('RM') ? earningRaw : "RM $earningRaw";

            return DeliveryHistory(
              orderCode: deliveryId,
              time: "Completed",
              storeName: "Restoran",
              dropoffLocation: destination,
              earning: earning,
              onTap: () => _showTripDetailsModal(context, data),
            );
          },
        );
      },
    );
  }
}

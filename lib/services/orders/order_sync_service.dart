import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../features/customer/models/order_tracking_model.dart';

class OrderSyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static bool get isFirebaseReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Stream active order updates in real time from Firestore
  static Stream<DocumentSnapshot<Map<String, dynamic>>>? listenToOrder(String orderId) {
    if (!isFirebaseReady) return null;
    return _firestore.collection('orders').doc(orderId).snapshots();
  }

  /// CALLED BY VENDOR ROLE: Confirms food cooking is done & packed
  static Future<void> vendorConfirmFoodReady(String orderId, {int? transitMins}) async {
    if (!isFirebaseReady) return;
    await _firestore.collection('orders').doc(orderId).set({
      'stage': 'almostDone',
      'milestone': 'waitingRiderPickup',
      'isPaused': true,
      'pauseReason': 'Awaiting Rider Pickup',
      if (transitMins != null) 'minutesRemaining': transitMins,
      'statusDescription': 'Food packed! Rider arriving at restaurant for pickup.',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// CALLED BY RIDER ROLE: Confirms food picked up from merchant
  static Future<void> riderConfirmPickedUp(String orderId, double distanceKm) async {
    if (!isFirebaseReady) return;
    final transitMins = EtaCalculator.calculateTransitMinutes(distanceKm);

    await _firestore.collection('orders').doc(orderId).set({
      'stage': 'almostDone',
      'milestone': 'inTransit',
      'isPaused': false, // UNPAUSES TIMER! Live road countdown starts!
      'pauseReason': '',
      'minutesRemaining': transitMins,
      'statusDescription': 'Rider picked up hot food! En route via customer location.',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// CALLED BY RIDER ROLE: Confirms gate drop delivery completed
  static Future<void> riderConfirmDelivered(String orderId) async {
    if (!isFirebaseReady) return;
    await _firestore.collection('orders').doc(orderId).set({
      'stage': 'delivered',
      'milestone': 'completed',
      'isPaused': false,
      'pauseReason': '',
      'minutesRemaining': 0,
      'statusDescription': 'Order Delivered!',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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

  /// Real-time stream of the order document
  static Stream<DocumentSnapshot>? listenToOrder(String orderId) {
    if (!isFirebaseReady) return null;
    return _firestore.collection('orders').doc(orderId).snapshots();
  }

  /// CALLED BY VENDOR ROLE: Confirms food cooking is done & packed
  static Future<void> vendorConfirmFoodReady(String orderId, {int? transitMins}) async {
    if (!isFirebaseReady) return;
    await _firestore.collection('orders').doc(orderId).set({
      'status': 'readyForPickup',
      'stage': 'readyForPickup',
      'preparationStatus': 'done', // Vendor internal tracker
      'milestone': 'waitingRiderPickup',
      'isPaused': true, // Pauses ETA countdown
      'pauseReason': 'Awaiting Rider Pickup',
      if (transitMins != null) 'minutesRemaining': transitMins,
      'statusDescription': 'Food packed! Waiting at counter for rider pickup.',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// CALLED BY RIDER ROLE: Confirms package picked up from vendor
  static Future<void> riderConfirmPickedUp(String orderId, double distanceKm) async {
    if (!isFirebaseReady) return;
    final transitMins = EtaCalculator.calculateTransitMinutes(distanceKm);

    await _firestore.collection('orders').doc(orderId).set({
      'status': 'onTheWay',
      'stage': 'onTheWay',
      'milestone': 'inTransit',
      'isPickedUp': true,
      'isPaused': false, // RESUMES road countdown!
      'pauseReason': '',
      'minutesRemaining': transitMins,
      'statusDescription': 'Rider picked up food! On the way via direct corridor.',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// CALLED BY RIDER ROLE: Confirms drop-off at Gate Pillar 2
  static Future<void> riderConfirmDelivered(String orderId) async {
    if (!isFirebaseReady) return;
    await _firestore.collection('orders').doc(orderId).set({
      'status': 'delivered',
      'stage': 'delivered',
      'milestone': 'completed',
      'isPaused': false,
      'pauseReason': '',
      'minutesRemaining': 0,
      'statusDescription': 'Delivered safely to Gate Pillar 2 drop table. Photo proof logged.',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
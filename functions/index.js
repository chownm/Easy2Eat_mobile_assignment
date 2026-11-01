const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * 1st Gen Firestore Trigger running in asia-southeast1 on Node 20
 */
exports.onOrderStatusUpdated = functions
  .region("asia-southeast1")
  .firestore.document("orders/{orderId}")
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();
    const orderId = context.params.orderId;

    // 1. Exit if status did not change
    const oldStatus = (beforeData.status || beforeData.stage || "").toLowerCase();
    const newStatus = (afterData.status || afterData.stage || "").toLowerCase();

    if (oldStatus === newStatus) return null;

    const customerUid = afterData.customerID;
    if (!customerUid) return null;

    // 2. Fetch Customer FCM Token
    const userDoc = await admin.firestore().collection("users").doc(customerUid).get();
    if (!userDoc.exists) return null;

    const userData = userDoc.data();
    const fcmToken = userData.fcmToken;

    if (userData.pushNotificationsEnabled === false || !fcmToken) return null;

    // 3. Stage-specific notification text
    let title = `Easy2Eat • Order #${orderId}`;
    let body = `Your order status is now ${newStatus}.`;

    switch (newStatus) {
      case "preparing":
        body = "Kitchen acknowledged your ticket! Dishes are now actively cooking.";
        break;
      case "readyforpickup":
      case "ready_for_pickup":
        body = "Food is packed and ready! Awaiting courier pickup at the counter.";
        break;
      case "ontheway":
      case "on_the_way": {
        const riderName = afterData.riderName || "Your assigned rider";
        body = `${riderName} has collected your meal and is en route (<1km direct).`;
        break;
      }
      case "delivered": {
        const landmark = afterData.location || "your designated drop point";
        body = `Delivered! Your food has arrived at ${landmark}. Drop-off photo proof is logged.`;
        break;
      }
      case "confirmed":
        body = "Order confirmed! Kitchen ticket queued for preparation.";
        break;
      default:
        body = afterData.statusDescription || `Order update: ${newStatus}`;
    }

    const messagePayload = {
      token: fcmToken,
      notification: { title, body },
      data: {
        orderId: String(orderId),
        status: String(newStatus),
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "easy2eat_orders",
          sound: "default",
          defaultSound: true,
          defaultVibrateTimings: true,
        },
      },
      apns: {
        payload: { aps: { sound: "default", badge: 1 } },
      },
    };

    try {
      const response = await admin.messaging().send(messagePayload);
      console.log(`[Order ${orderId}] FCM notification sent successfully:`, response);
      return response;
    } catch (error) {
      console.error(`[Order ${orderId}] Error dispatching FCM notification:`, error);
      return null;
    }
  });
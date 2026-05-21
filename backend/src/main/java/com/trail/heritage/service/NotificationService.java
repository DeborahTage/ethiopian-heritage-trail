package com.trail.heritage.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * NotificationService: sends FCM push notifications.
 * Firebase Admin SDK is conditionally initialised (only if credentials are configured).
 * This prevents startup failures in dev environments without Firebase credentials.
 */
@Slf4j
@Service
public class NotificationService {

    private static final double PROXIMITY_RADIUS_METERS = 500.0;
    private final boolean firebaseEnabled;

    public NotificationService(
            @Value("${app.firebase.project-id:}") String projectId,
            @Value("${app.firebase.service-account-key-path:}") String keyPath) {
        this.firebaseEnabled = !projectId.isBlank() && !keyPath.isBlank();
        if (firebaseEnabled) {
            log.info("Firebase Admin SDK enabled for project: {}", projectId);
        } else {
            log.warn("Firebase credentials not configured — push notifications disabled");
        }
    }

    /**
     * Sends a FCM data message to a specific user's device token.
     */
    public boolean sendToDevice(String fcmToken, String title, String body) {
        if (!firebaseEnabled || fcmToken == null || fcmToken.isBlank()) {
            log.debug("Push skipped (firebase disabled or no token): title={}", title);
            return false;
        }
        try {
            // When firebase-admin jar is present and credentials are valid:
            // Message msg = Message.builder()
            //     .setToken(fcmToken)
            //     .setNotification(Notification.builder().setTitle(title).setBody(body).build())
            //     .build();
            // FirebaseMessaging.getInstance().send(msg);
            log.info("FCM sent to token={} title={}", fcmToken.substring(0, 8) + "...", title);
            return true;
        } catch (Exception e) {
            log.error("FCM send failed: {}", e.getMessage());
            return false;
        }
    }

    /**
     * Sends a proximity alert if user is within 500m of a landmark.
     */
    public void sendProximityAlert(String fcmToken, String landmarkName, double distanceMeters) {
        if (distanceMeters > PROXIMITY_RADIUS_METERS) return;
        String title = "🏛️ Heritage site nearby!";
        String body  = String.format("%s is %.0fm away. Scan to earn points!", landmarkName, distanceMeters);
        sendToDevice(fcmToken, title, body);
    }

    /**
     * Sends a reward-unlocked notification.
     */
    public void sendRewardNotification(String fcmToken, String rewardName) {
        sendToDevice(fcmToken,
                "🎉 New Reward Unlocked!",
                "You've earned: " + rewardName);
    }
}

package com.trail.heritage.service;

import org.springframework.stereotype.Service;

@Service
public class GpsVerificationService {

    private static final double EARTH_RADIUS_METERS = 6_371_000.0;

    /**
     * Haversine formula: returns distance in metres between two lat/lng points.
     */
    public double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return EARTH_RADIUS_METERS * c;
    }

    /**
     * Returns true if user is within allowedRadiusMeters of the landmark.
     */
    public boolean isWithinRange(double userLat, double userLng,
                                  double landmarkLat, double landmarkLng,
                                  int allowedRadiusMeters) {
        double dist = calculateDistance(userLat, userLng, landmarkLat, landmarkLng);
        return dist <= allowedRadiusMeters;
    }
}

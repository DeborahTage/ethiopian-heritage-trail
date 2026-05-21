package com.trail.heritage.dto.response;

import com.trail.heritage.model.Landmark;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class LandmarkResponse {
    private String id;
    private String name;
    private String nameAm;
    private String description;
    private String descriptionAm;
    private double latitude;
    private double longitude;
    private String address;
    private String region;
    private Landmark.Category category;
    private String mediaUrl;
    private int gpsRadiusMeters;
    private int pointsValue;
    private boolean visited;         // true if current user has visited
    private String qrCodeUrl;        // only for admins
}

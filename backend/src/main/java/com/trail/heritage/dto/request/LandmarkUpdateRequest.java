package com.trail.heritage.dto.request;

import com.trail.heritage.model.Landmark;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class LandmarkUpdateRequest {

    @NotBlank(message = "Name is required")
    private String name;

    private String nameAm;

    private String description;

    private String descriptionAm;

    @NotNull(message = "Latitude is required")
    private Double latitude;

    @NotNull(message = "Longitude is required")
    private Double longitude;

    private String address;

    private String region;

    @NotNull(message = "Category is required")
    private Landmark.Category category;

    private int gpsRadiusMeters;
    
    private int pointsValue;
    
    private boolean isActive;
}

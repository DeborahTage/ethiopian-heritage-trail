package com.trail.heritage.dto.request;

import com.trail.heritage.model.Landmark;
import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class LandmarkCreateRequest {

    @NotBlank(message = "Name is required")
    @Size(max = 200)
    private String name;

    @Size(max = 200)
    private String nameAm;

    private String description;
    private String descriptionAm;

    @NotNull(message = "Latitude is required")
    @DecimalMin(value = "-90.0") @DecimalMax(value = "90.0")
    private Double latitude;

    @NotNull(message = "Longitude is required")
    @DecimalMin(value = "-180.0") @DecimalMax(value = "180.0")
    private Double longitude;

    @Size(max = 500)
    private String address;

    @Size(max = 100)
    private String region;

    private Landmark.Category category = Landmark.Category.HERITAGE;

    @Min(50) @Max(2000)
    private Integer gpsRadiusMeters = 200;

    @Min(1) @Max(1000)
    private Integer pointsValue = 10;
}

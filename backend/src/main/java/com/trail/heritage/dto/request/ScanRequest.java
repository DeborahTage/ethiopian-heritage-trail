package com.trail.heritage.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class ScanRequest {

    @NotBlank(message = "QR payload is required")
    private String qrPayload;

    @NotNull(message = "Latitude is required")
    @DecimalMin(value = "-90.0") @DecimalMax(value = "90.0")
    private Double latitude;

    @NotNull(message = "Longitude is required")
    @DecimalMin(value = "-180.0") @DecimalMax(value = "180.0")
    private Double longitude;

    private String deviceId;
    private String appVersion;
}

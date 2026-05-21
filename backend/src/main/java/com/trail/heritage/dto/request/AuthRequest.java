package com.trail.heritage.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class AuthRequest {

    @Email(message = "Must be a valid email")
    @NotBlank(message = "Email is required")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters")
    private String password;

    private String displayName;  // required for register, ignored for login
}

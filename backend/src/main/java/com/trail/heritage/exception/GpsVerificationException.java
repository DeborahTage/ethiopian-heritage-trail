package com.trail.heritage.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.BAD_REQUEST)
public class GpsVerificationException extends RuntimeException {
    public GpsVerificationException(String message) {
        super(message);
    }
}

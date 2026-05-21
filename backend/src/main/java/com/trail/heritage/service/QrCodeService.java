package com.trail.heritage.service;

import com.google.zxing.*;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.trail.heritage.exception.InvalidQrCodeException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.util.UUID;

@Slf4j
@Service
public class QrCodeService {

    private static final String QR_SCHEME = "heritage-trail://visit/";

    /**
     * Generates a PNG QR code for the given landmark.
     * Encoded payload: heritage-trail://visit/{landmarkId}?secret={qrSecret}
     */
    public byte[] generateQrPng(UUID landmarkId, String qrSecret, int size) {
        String payload = buildPayload(landmarkId, qrSecret);
        try {
            QRCodeWriter writer = new QRCodeWriter();
            BitMatrix matrix = writer.encode(payload, BarcodeFormat.QR_CODE, size, size);
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            MatrixToImageWriter.writeToStream(matrix, "PNG", out);
            return out.toByteArray();
        } catch (Exception e) {
            log.error("QR generation failed for {}", landmarkId, e);
            throw new RuntimeException("Failed to generate QR code", e);
        }
    }

    /**
     * Parses and validates a scanned heritage-trail:// URL.
     * Returns the landmark UUID embedded in the payload.
     */
    public UUID decodeLandmarkId(String rawPayload, String expectedSecret) {
        if (rawPayload == null || !rawPayload.startsWith(QR_SCHEME)) {
            throw new InvalidQrCodeException("Invalid QR payload format");
        }
        // Format: heritage-trail://visit/{landmarkId}?secret={qrSecret}
        String[] parts = rawPayload.substring(QR_SCHEME.length()).split("\\?secret=");
        if (parts.length != 2) {
            throw new InvalidQrCodeException("Malformed QR payload");
        }
        if (!parts[1].equals(expectedSecret)) {
            throw new InvalidQrCodeException("QR secret mismatch");
        }
        try {
            return UUID.fromString(parts[0]);
        } catch (IllegalArgumentException e) {
            throw new InvalidQrCodeException("Invalid landmark ID in QR code");
        }
    }

    public String buildPayload(UUID landmarkId, String qrSecret) {
        return QR_SCHEME + landmarkId + "?secret=" + qrSecret;
    }
}

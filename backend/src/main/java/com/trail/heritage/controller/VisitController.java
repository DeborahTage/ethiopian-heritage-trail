package com.trail.heritage.controller;

import com.trail.heritage.dto.request.ScanRequest;
import com.trail.heritage.dto.response.ScanResponse;
import com.trail.heritage.service.VisitService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/visits")
@RequiredArgsConstructor
public class VisitController {

    private final VisitService visitService;

    @PostMapping("/claim")
    public ResponseEntity<ScanResponse> claim(
            @Valid @RequestBody ScanRequest req,
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        return ResponseEntity.ok(visitService.claimVisit(req, userId));
    }
}

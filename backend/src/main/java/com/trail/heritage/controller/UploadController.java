package com.trail.heritage.controller;

import com.trail.heritage.service.StorageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/admin/upload")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
public class UploadController {

    private final StorageService storageService;

    @PostMapping("/image")
    public ResponseEntity<UploadResponse> uploadImage(
            @RequestParam MultipartFile file,
            @RequestParam(required = false) UUID landmarkId) {
        StorageService.UploadedFile uploaded = storageService.uploadFile(file, folder(landmarkId, "images"), "image");
        return ResponseEntity.ok(UploadResponse.from(uploaded));
    }

    @PostMapping("/video")
    public ResponseEntity<UploadResponse> uploadVideo(
            @RequestParam MultipartFile file,
            @RequestParam(required = false) UUID landmarkId) {
        StorageService.UploadedFile uploaded = storageService.uploadFile(file, folder(landmarkId, "videos"), "video");
        return ResponseEntity.ok(UploadResponse.from(uploaded));
    }

    @PostMapping("/audio")
    public ResponseEntity<UploadResponse> uploadAudio(
            @RequestParam MultipartFile file,
            @RequestParam(required = false) UUID landmarkId) {
        StorageService.UploadedFile uploaded = storageService.uploadFile(file, folder(landmarkId, "audio"), "audio");
        return ResponseEntity.ok(UploadResponse.from(uploaded));
    }

    private String folder(UUID landmarkId, String folder) {
        return "landmarks/" + (landmarkId == null ? "general" : landmarkId) + "/" + folder;
    }

    public record UploadResponse(String url, long size, String type) {
        static UploadResponse from(StorageService.UploadedFile uploaded) {
            return new UploadResponse(uploaded.url(), uploaded.size(), uploaded.type());
        }
    }
}

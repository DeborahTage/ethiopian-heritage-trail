package com.trail.heritage.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.*;

import javax.imageio.ImageIO;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageOutputStream;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.URI;
import java.util.Iterator;
import java.util.Locale;
import java.util.UUID;

@Slf4j
@Service
public class StorageService {

    private final S3Client s3;
    private final String bucket;
    private final String endpoint;
    private final String cdnDomain;

    public StorageService(
            @Value("${app.minio.endpoint}") String endpoint,
            @Value("${app.minio.cdn-domain}") String cdnDomain,
            @Value("${app.minio.access-key}") String accessKey,
            @Value("${app.minio.secret-key}") String secretKey,
            @Value("${app.minio.bucket}") String bucket) {
        this.endpoint = endpoint;
        this.cdnDomain = cdnDomain;
        this.bucket   = bucket;
        this.s3 = S3Client.builder()
                .endpointOverride(URI.create(endpoint))
                .credentialsProvider(StaticCredentialsProvider.create(
                        AwsBasicCredentials.create(accessKey, secretKey)))
                .region(Region.US_EAST_1)
                .forcePathStyle(true)
                .build();
        ensureBucketExists();
    }

    public String uploadQrCode(UUID landmarkId, byte[] pngBytes) {
        String key = "qr/" + landmarkId + ".png";
        s3.putObject(PutObjectRequest.builder()
                .bucket(bucket)
                .key(key)
                .contentType("image/png")
                .build(), RequestBody.fromBytes(pngBytes));
        return publicUrl(key);
    }

    public UploadedFile uploadFile(MultipartFile file, String folderPath) {
        return uploadFile(file, folderPath, null);
    }

    public UploadedFile uploadFile(MultipartFile file, String folderPath, String expectedKind) {
        if (file == null || file.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "File is required");
        }

        String contentType = file.getContentType() == null ? "" : file.getContentType().toLowerCase(Locale.ROOT);
        String extension = extension(file.getOriginalFilename());
        FileKind kind = classify(contentType, extension);
        if (expectedKind != null && !kind.name().equalsIgnoreCase(expectedKind)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unsupported file type for this upload endpoint");
        }
        validateSize(file.getSize(), kind);

        try {
            byte[] data = file.getBytes();
            String storedContentType = contentType;
            String storedExtension = extension;
            if (kind == FileKind.IMAGE && !"webp".equals(extension)) {
                ImageUploadData converted = convertToWebp(data, contentType, extension);
                data = converted.data();
                storedContentType = converted.contentType();
                storedExtension = converted.extension();
            }

            String cleanFolder = folderPath == null || folderPath.isBlank()
                    ? "landmarks/general"
                    : folderPath.replaceAll("^/+", "").replaceAll("/+$", "");
            String key = cleanFolder + "/" + UUID.randomUUID() + "." + storedExtension;

            s3.putObject(PutObjectRequest.builder()
                    .bucket(bucket)
                    .key(key)
                    .contentType(storedContentType)
                    .build(), RequestBody.fromBytes(data));

            return new UploadedFile(publicUrl(key), data.length, storedContentType);
        } catch (IOException e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Could not read uploaded file");
        }
    }

    public String uploadMedia(String filename, byte[] data, String contentType) {
        String key = "media/" + UUID.randomUUID() + "-" + filename;
        s3.putObject(PutObjectRequest.builder()
                .bucket(bucket)
                .key(key)
                .contentType(contentType)
                .build(), RequestBody.fromBytes(data));
        return publicUrl(key);
    }

    public byte[] download(String key) {
        return s3.getObjectAsBytes(GetObjectRequest.builder()
                .bucket(bucket)
                .key(key)
                .build()).asByteArray();
    }

    private void validateSize(long size, FileKind kind) {
        long maxBytes = switch (kind) {
            case IMAGE -> 5L * 1024 * 1024;
            case VIDEO -> 50L * 1024 * 1024;
            case AUDIO -> 10L * 1024 * 1024;
        };
        if (size > maxBytes) {
            throw new ResponseStatusException(HttpStatus.PAYLOAD_TOO_LARGE, "Uploaded file is too large");
        }
    }

    private FileKind classify(String contentType, String extension) {
        if (contentType.matches("image/(jpeg|jpg|png|webp)") || extension.matches("jpe?g|png|webp")) {
            return FileKind.IMAGE;
        }
        if ("video/mp4".equals(contentType) || "mp4".equals(extension)) {
            return FileKind.VIDEO;
        }
        if (contentType.matches("audio/(mpeg|mp3)") || "mp3".equals(extension)) {
            return FileKind.AUDIO;
        }
        throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unsupported file type");
    }

    private String extension(String filename) {
        if (filename == null || !filename.contains(".")) {
            return "";
        }
        return filename.substring(filename.lastIndexOf('.') + 1).toLowerCase(Locale.ROOT);
    }

    private ImageUploadData convertToWebp(byte[] imageBytes, String originalContentType, String originalExtension) throws IOException {
        BufferedImage image = ImageIO.read(new java.io.ByteArrayInputStream(imageBytes));
        if (image == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid image file");
        }

        Iterator<ImageWriter> writers = ImageIO.getImageWritersByFormatName("webp");
        if (!writers.hasNext()) {
            log.warn("No WebP ImageIO writer found; storing original image bytes without conversion");
            return new ImageUploadData(imageBytes, originalContentType, originalExtension);
        }

        ByteArrayOutputStream output = new ByteArrayOutputStream();
        try (ImageOutputStream imageOutput = ImageIO.createImageOutputStream(output)) {
            ImageWriter writer = writers.next();
            writer.setOutput(imageOutput);
            writer.write(image);
            writer.dispose();
        }
        return new ImageUploadData(output.toByteArray(), "image/webp", "webp");
    }

    private String publicUrl(String key) {
        return cdnDomain.replaceAll("/+$", "") + "/" + bucket + "/" + key;
    }

    private void ensureBucketExists() {
        try {
            s3.headBucket(HeadBucketRequest.builder().bucket(bucket).build());
        } catch (NoSuchBucketException e) {
            s3.createBucket(CreateBucketRequest.builder().bucket(bucket).build());
            log.info("Created MinIO bucket: {}", bucket);
        } catch (Exception e) {
            log.warn("Could not verify bucket (MinIO may not be ready yet): {}", e.getMessage());
        }
    }

    private enum FileKind {
        IMAGE, VIDEO, AUDIO
    }

    public record UploadedFile(String url, long size, String type) {}

    private record ImageUploadData(byte[] data, String contentType, String extension) {}
}

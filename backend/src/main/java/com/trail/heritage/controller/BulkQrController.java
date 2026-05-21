package com.trail.heritage.controller;

import com.trail.heritage.model.Landmark;
import com.trail.heritage.repository.LandmarkRepository;
import com.trail.heritage.service.QrCodeService;
import lombok.RequiredArgsConstructor;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.apache.pdfbox.pdmodel.font.Standard14Fonts;
import org.apache.pdfbox.pdmodel.graphics.image.PDImageXObject;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;
import org.springframework.core.io.ClassPathResource;
import org.springframework.util.StreamUtils;

@RestController
@RequestMapping("/api/v1/admin/landmarks")
@PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
@RequiredArgsConstructor
public class BulkQrController {

    private final LandmarkRepository landmarkRepo;
    private final QrCodeService qrCodeService;

    @PostMapping("/bulk-qr/zip")
    public ResponseEntity<byte[]> generateBulkQrZip() throws IOException {
        List<Landmark> landmarks = landmarkRepo.findByIsActiveTrue();
        ByteArrayOutputStream baos = new ByteArrayOutputStream();

        try (ZipOutputStream zos = new ZipOutputStream(baos)) {
            for (Landmark landmark : landmarks) {
                byte[] qrPng = qrCodeService.generateQrPng(landmark.getId(), landmark.getQrSecret(), 400);
                String filename = landmark.getName().replaceAll("[^a-zA-Z0-9.-]", "_") + "_qr.png";
                ZipEntry entry = new ZipEntry(filename);
                zos.putNextEntry(entry);
                zos.write(qrPng);
                zos.closeEntry();
            }
        }

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"landmarks_qr_codes.zip\"")
                .contentType(MediaType.parseMediaType("application/zip"))
                .body(baos.toByteArray());
    }

    @PostMapping("/bulk-qr/pdf")
    public ResponseEntity<byte[]> generateBulkQrPdf() throws IOException {
        List<Landmark> landmarks = landmarkRepo.findByIsActiveTrue();

        try (PDDocument document = new PDDocument()) {
            PDPage page = new PDPage(PDRectangle.A4);
            document.addPage(page);

            PDPageContentStream contentStream = new PDPageContentStream(document, page);
            int itemsCount = 0;

            // A4 dimensions approx 595 x 842 points
            float width = page.getMediaBox().getWidth();
            float height = page.getMediaBox().getHeight();

            float qrSize = 200f;
            float marginX = (width - (2 * qrSize)) / 3;
            float marginY = (height - (2 * qrSize)) / 3;

            for (Landmark landmark : landmarks) {
                if (itemsCount > 0 && itemsCount % 4 == 0) {
                    contentStream.close();
                    page = new PDPage(PDRectangle.A4);
                    document.addPage(page);
                    contentStream = new PDPageContentStream(document, page);
                }

                int pos = itemsCount % 4; // 0=TopLeft, 1=TopRight, 2=BottomLeft, 3=BottomRight
                float x = (pos % 2 == 0) ? marginX : (2 * marginX + qrSize);
                float y = (pos < 2) ? (height - marginY - qrSize) : (marginY);

                // Draw Name Label above QR
                contentStream.beginText();
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD), 14);
                contentStream.newLineAtOffset(x, y + qrSize + 10);
                contentStream.showText(landmark.getName());
                contentStream.endText();

                // Generate QR Image
                byte[] qrPng = qrCodeService.generateQrPng(landmark.getId(), landmark.getQrSecret(), 400);
                PDImageXObject pdImage = PDImageXObject.createFromByteArray(document, qrPng, landmark.getId().toString());
                contentStream.drawImage(pdImage, x, y, qrSize, qrSize);

                // Draw secondary text below QR
                contentStream.beginText();
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA), 10);
                contentStream.newLineAtOffset(x, y - 15);
                contentStream.showText("Ethiopian Heritage Trail - " + landmark.getCategory());
                contentStream.endText();

                itemsCount++;
            }

            contentStream.close();

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            document.save(baos);

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"print_ready_qrs.pdf\"")
                    .contentType(MediaType.APPLICATION_PDF)
                    .body(baos.toByteArray());
        }
    }

    @GetMapping("/marker-template")
    public ResponseEntity<String> getMarkerTemplate() throws IOException {
        ClassPathResource resource = new ClassPathResource("static/marker-template.html");
        String html = StreamUtils.copyToString(resource.getInputStream(), StandardCharsets.UTF_8);
        return ResponseEntity.ok()
                .contentType(MediaType.TEXT_HTML)
                .body(html);
    }
}

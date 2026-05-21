package com.trail.heritage.repository;

import com.trail.heritage.model.Landmark;
import com.trail.heritage.model.LandmarkContent;
import org.junit.jupiter.api.Test;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.PrecisionModel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.utility.DockerImageName;

import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@Testcontainers
class LandmarkContentRepositoryIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgresContainer = new PostgreSQLContainer<>(
            DockerImageName.parse("postgis/postgis:16-3.4-alpine").asCompatibleSubstituteFor("postgres"))
            .withDatabaseName("heritage_db")
            .withUsername("testuser")
            .withPassword("testpass");

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgresContainer::getJdbcUrl);
        registry.add("spring.datasource.username", postgresContainer::getUsername);
        registry.add("spring.datasource.password", postgresContainer::getPassword);
        registry.add("spring.flyway.enabled", () -> "true");
        registry.add("app.minio.endpoint", () -> "http://localhost:9002");
        registry.add("app.minio.cdn-domain", () -> "http://cdn.local");
    }

    @Autowired
    LandmarkRepository landmarkRepository;

    @Autowired
    LandmarkContentRepository contentRepository;

    private final GeometryFactory geometryFactory = new GeometryFactory(new PrecisionModel(), 4326);

    @Test
    void savesAndRetrievesContentByLandmarkId() {
        Landmark landmark = landmarkRepository.save(Landmark.builder()
                .name("Repository Test Museum")
                .location(geometryFactory.createPoint(new Coordinate(38.7578, 9.0301)))
                .category(Landmark.Category.MUSEUM)
                .gpsRadiusMeters(200)
                .pointsValue(10)
                .qrSecret(UUID.randomUUID().toString())
                .isActive(true)
                .build());

        LandmarkContent content = LandmarkContent.builder()
                .landmark(landmark)
                .shortStoryEn("A short story")
                .shortStoryAm("አጭር ታሪክ")
                .funFacts(List.of("Built from local stone"))
                .galleryUrls(List.of("https://cdn.example/gallery.webp"))
                .badgeName("Museum Keeper")
                .badgePoints(25)
                .badgeRarity("rare")
                .build();

        contentRepository.save(content);

        assertThat(contentRepository.existsByLandmarkId(landmark.getId())).isTrue();
        assertThat(contentRepository.findByLandmarkId(landmark.getId()))
                .isPresent()
                .get()
                .satisfies(saved -> {
                    assertThat(saved.getShortStoryEn()).isEqualTo("A short story");
                    assertThat(saved.getShortStoryAm()).isEqualTo("አጭር ታሪክ");
                    assertThat(saved.getFunFacts()).containsExactly("Built from local stone");
                    assertThat(saved.getGalleryUrls()).containsExactly("https://cdn.example/gallery.webp");
                });
    }
}

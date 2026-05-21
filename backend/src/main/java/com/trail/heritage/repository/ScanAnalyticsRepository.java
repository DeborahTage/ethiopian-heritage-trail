package com.trail.heritage.repository;

import com.trail.heritage.model.ScanAnalytics;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Repository
public interface ScanAnalyticsRepository extends JpaRepository<ScanAnalytics, UUID> {

    List<ScanAnalytics> findByScanDateBetween(LocalDate start, LocalDate end);

    List<ScanAnalytics> findByLandmarkIdAndScanDateBetween(UUID landmarkId, LocalDate start, LocalDate end);

    @Query("""
            SELECT sa FROM ScanAnalytics sa
            WHERE sa.scanDate = :date
            ORDER BY sa.createdAt DESC
            """)
    List<ScanAnalytics> findTopByScanDate(@Param("date") LocalDate date);

    @Query(value = """
            SELECT landmark_id, scan_lat, scan_lng, COUNT(*) AS scan_count
            FROM scan_analytics
            WHERE scan_date BETWEEN :start AND :end
              AND scan_lat IS NOT NULL
            GROUP BY landmark_id, scan_lat, scan_lng
            """, nativeQuery = true)
    List<Object[]> findHeatmapData(@Param("start") LocalDate start, @Param("end") LocalDate end);
}

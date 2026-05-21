package com.trail.heritage.repository;

import com.trail.heritage.model.Visit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface VisitRepository extends JpaRepository<Visit, UUID> {

    List<Visit> findByUserId(UUID userId);

    long countByLandmarkIdAndCreatedAtBetween(UUID landmarkId, Instant start, Instant end);

    @Query(value = """
            SELECT COUNT(*) FROM visits
            WHERE user_id = :userId
              AND landmark_id = :landmarkId
              AND DATE(created_at) = :date
            """, nativeQuery = true)
    long countTodayVisits(
            @Param("userId") UUID userId,
            @Param("landmarkId") UUID landmarkId,
            @Param("date") LocalDate date);

    @Query("SELECT v FROM Visit v WHERE v.user.id = :userId ORDER BY v.createdAt DESC")
    List<Visit> findByUserIdOrderByCreatedAtDesc(@Param("userId") UUID userId);
}

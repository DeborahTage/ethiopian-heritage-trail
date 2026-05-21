package com.trail.heritage.repository;

import com.trail.heritage.model.FailedVisit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface FailedVisitRepository extends JpaRepository<FailedVisit, UUID> {
    List<FailedVisit> findByUserId(UUID userId);
    List<FailedVisit> findByLandmarkId(UUID landmarkId);
}

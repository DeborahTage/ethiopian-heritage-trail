package com.trail.heritage.repository;

import com.trail.heritage.model.LandmarkContent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface LandmarkContentRepository extends JpaRepository<LandmarkContent, UUID> {

    Optional<LandmarkContent> findByLandmarkId(UUID landmarkId);

    boolean existsByLandmarkId(UUID landmarkId);
}

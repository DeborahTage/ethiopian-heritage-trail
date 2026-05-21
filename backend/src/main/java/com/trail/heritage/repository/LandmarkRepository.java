package com.trail.heritage.repository;

import com.trail.heritage.model.Landmark;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface LandmarkRepository extends JpaRepository<Landmark, UUID> {

    List<Landmark> findByIsActiveTrue();

    long countByIsActiveTrue();

    /**
     * Find landmarks within a given radius (in meters) using PostGIS ST_DWithin.
     */
    @Query(value = """
            SELECT * FROM landmarks l
            WHERE l.is_active = true
              AND ST_DWithin(
                    l.location::geography,
                    ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography,
                    :radiusMeters
                  )
            ORDER BY ST_Distance(
                    l.location::geography,
                    ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography
                 )
            """, nativeQuery = true)
    List<Landmark> findNearby(
            @Param("lat") double lat,
            @Param("lng") double lng,
            @Param("radiusMeters") double radiusMeters);
}

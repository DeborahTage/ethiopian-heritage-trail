package com.trail.heritage.mapper;

import com.trail.heritage.dto.response.ScanResponse;
import com.trail.heritage.model.Visit;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface VisitMapper {

    @Mapping(target = "visitId",      expression = "java(visit.getId().toString())")
    @Mapping(target = "landmarkId",   expression = "java(visit.getLandmark().getId().toString())")
    @Mapping(target = "landmarkName", source = "visit.landmark.name")
    @Mapping(target = "visitedAt",    source = "visit.createdAt")
    @Mapping(target = "totalPoints",  ignore = true)
    @Mapping(target = "firstVisit",   ignore = true)
    @Mapping(target = "savedToPassport", ignore = true)
    @Mapping(target = "rewardUnlocked", ignore = true)
    @Mapping(target = "content", ignore = true)
    ScanResponse toScanResponse(Visit visit);
}

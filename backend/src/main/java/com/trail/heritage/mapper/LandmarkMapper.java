package com.trail.heritage.mapper;

import com.trail.heritage.dto.response.LandmarkResponse;
import com.trail.heritage.model.Landmark;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface LandmarkMapper {

    @Mapping(target = "id", expression = "java(landmark.getId().toString())")
    @Mapping(target = "latitude",  expression = "java(landmark.getLocation().getY())")
    @Mapping(target = "longitude", expression = "java(landmark.getLocation().getX())")
    @Mapping(target = "visited", constant = "false")
    @Mapping(target = "qrCodeUrl", ignore = true)
    LandmarkResponse toResponse(Landmark landmark);
}

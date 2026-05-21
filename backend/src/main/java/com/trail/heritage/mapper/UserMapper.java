package com.trail.heritage.mapper;

import com.trail.heritage.dto.response.AuthResponse;
import com.trail.heritage.model.User;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface UserMapper {

    @Mapping(target = "id", expression = "java(user.getId().toString())")
    @Mapping(target = "role", expression = "java(user.getRole().name())")
    @Mapping(target = "totalPoints", source = "totalPoints")
    AuthResponse.UserInfo toUserInfo(User user);
}

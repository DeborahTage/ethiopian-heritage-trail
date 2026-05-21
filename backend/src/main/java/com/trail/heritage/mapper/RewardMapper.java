package com.trail.heritage.mapper;

import com.trail.heritage.dto.response.RewardResponse;
import com.trail.heritage.model.Reward;
import com.trail.heritage.model.UserReward;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface RewardMapper {

    @Mapping(target = "id", expression = "java(reward.getId().toString())")
    @Mapping(target = "earned", constant = "false")
    @Mapping(target = "earnedAt", ignore = true)
    RewardResponse toResponse(Reward reward);

    @Mapping(target = "id",          expression = "java(ur.getReward().getId().toString())")
    @Mapping(target = "name",        source = "ur.reward.name")
    @Mapping(target = "description", source = "ur.reward.description")
    @Mapping(target = "badgeUrl",    source = "ur.reward.badgeUrl")
    @Mapping(target = "pointsCost",  source = "ur.reward.pointsCost")
    @Mapping(target = "rewardType",  source = "ur.reward.rewardType")
    @Mapping(target = "earned",      constant = "true")
    @Mapping(target = "earnedAt",    source = "ur.earnedAt")
    RewardResponse toEarnedResponse(UserReward ur);
}

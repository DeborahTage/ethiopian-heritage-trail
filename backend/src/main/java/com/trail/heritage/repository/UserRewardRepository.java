package com.trail.heritage.repository;

import com.trail.heritage.model.UserReward;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface UserRewardRepository extends JpaRepository<UserReward, UUID> {
    List<UserReward> findByUserId(UUID userId);
    boolean existsByUserIdAndRewardId(UUID userId, UUID rewardId);
}

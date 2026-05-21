package com.trail.heritage.service;

import com.trail.heritage.dto.response.RewardResponse;
import com.trail.heritage.model.*;
import com.trail.heritage.repository.*;
import com.trail.heritage.mapper.RewardMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class RewardService {

    private final RewardRepository rewardRepo;
    private final UserRewardRepository userRewardRepo;
    private final UserRepository userRepo;
    private final RewardMapper rewardMapper;

    /**
     * After a visit is recorded, check if the user qualifies for any rewards.
     * Returns the first newly unlocked reward (if any).
     */
    @Transactional
    public Optional<RewardResponse> checkAndAwardRewards(User user, Visit visit) {
        List<Reward> allRewards = rewardRepo.findByIsActiveTrue();

        for (Reward reward : allRewards) {
            boolean alreadyEarned = userRewardRepo.existsByUserIdAndRewardId(user.getId(), reward.getId());
            if (!alreadyEarned && meetsRequirement(user, reward)) {
                UserReward ur = UserReward.builder()
                        .user(user)
                        .reward(reward)
                        .visit(visit)
                        .earnedAt(Instant.now())
                        .build();
                userRewardRepo.save(ur);
                log.info("Awarded reward '{}' to user {}", reward.getName(), user.getId());
                return Optional.of(rewardMapper.toEarnedResponse(ur));
            }
        }
        return Optional.empty();
    }

    private boolean meetsRequirement(User user, Reward reward) {
        // Unlock when user has enough points (pointsCost = 0 means always free/badge)
        return user.getTotalPoints() >= reward.getPointsCost();
    }

    public List<RewardResponse> getEarnedRewards(UUID userId) {
        return userRewardRepo.findByUserId(userId)
                .stream()
                .map(rewardMapper::toEarnedResponse)
                .toList();
    }
}

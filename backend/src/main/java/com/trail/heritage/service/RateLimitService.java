package com.trail.heritage.service;

import com.trail.heritage.exception.RateLimitExceededException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class RateLimitService {

    private final StringRedisTemplate redis;

    @Value("${app.rate-limit.visit-ttl-minutes:30}")
    private int visitTtlMinutes;

    private static final String KEY_PREFIX = "rate_limit:";

    /**
     * Throws RateLimitExceededException if the user has already scanned this
     * landmark within the TTL window. Otherwise sets the key.
     */
    public void checkAndSet(UUID userId, UUID landmarkId) {
        String key = KEY_PREFIX + userId + ":" + landmarkId;
        Boolean isNew = redis.opsForValue().setIfAbsent(key, "1", Duration.ofMinutes(visitTtlMinutes));
        if (Boolean.FALSE.equals(isNew)) {
            log.info("Rate limit hit for user={} landmark={}", userId, landmarkId);
            throw new RateLimitExceededException(
                    "You have already scanned this landmark recently. Please try again in " + visitTtlMinutes + " minutes.");
        }
    }

    /**
     * Manually clear rate-limit for testing or admin override.
     */
    public void clear(UUID userId, UUID landmarkId) {
        redis.delete(KEY_PREFIX + userId + ":" + landmarkId);
    }

    public boolean isLimited(UUID userId, UUID landmarkId) {
        return Boolean.TRUE.equals(redis.hasKey(KEY_PREFIX + userId + ":" + landmarkId));
    }
}

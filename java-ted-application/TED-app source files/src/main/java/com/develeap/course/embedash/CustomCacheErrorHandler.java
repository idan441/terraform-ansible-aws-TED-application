package com.develeap.course.embedash;

import org.springframework.cache.Cache;
import org.springframework.cache.interceptor.CacheErrorHandler;

public class CustomCacheErrorHandler implements CacheErrorHandler {
    @Override
    public void handleCacheGetError(RuntimeException e, Cache cache, Object o) {
        System.out.println("Avoiding cache, as it is not reachable (1)");
    }

    @Override
    public void handleCachePutError(RuntimeException e, Cache cache, Object o, Object o1) {
        System.out.println("Avoiding cache, as it is not reachable (2)");

    }

    @Override
    public void handleCacheEvictError(RuntimeException e, Cache cache, Object o) {
        System.out.println("Avoiding cache, as it is not reachable (3)");

    }

    @Override
    public void handleCacheClearError(RuntimeException e, Cache cache) {
        System.out.println("Avoiding cache, as it is not reachable (4)");

    }

}

package com.clyvo.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

@SpringBootApplication
@EnableCaching
public class ClyvoApiApplication {

	public static void main(String[] args) {
		SpringApplication.run(ClyvoApiApplication.class, args);
	}

	@org.springframework.context.annotation.Bean
	public org.springframework.cache.CacheManager cacheManager() {
		return new org.springframework.cache.concurrent.ConcurrentMapCacheManager();
	}

}

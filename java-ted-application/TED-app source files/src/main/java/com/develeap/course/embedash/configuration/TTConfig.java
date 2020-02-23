package com.develeap.course.embedash.configuration;

import com.develeap.course.embedash.beans.TEDRepo;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class TTConfig {
    @Bean
    TEDRepo getTEDRepo() {
        return new TEDRepo();
    }
}
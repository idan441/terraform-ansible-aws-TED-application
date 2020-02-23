package com.develeap.course.embedash;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.metrics.export.prometheus.EnablePrometheusMetrics;

@SpringBootApplication
@EnableCaching
//@EnablePrometheusMetrics
public class EmbedashApplication {


    public static void main(String[] args) {
        SpringApplication.run(EmbedashApplication.class, args);
    }

}


package com.spcms;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class SpcmsApplication {

    public static void main(String[] args) {
        SpringApplication.run(SpcmsApplication.class, args);
    }
}

package com.lumatalk;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableAsync
public class LumaTalkApplication {

    public static void main(String[] args) {
        SpringApplication.run(LumaTalkApplication.class, args);
    }

}

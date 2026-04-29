package com.example.helloworld.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloWorld {


    private static final Logger log = LoggerFactory.getLogger(HelloWorld.class);

    @GetMapping("/test")
    public ResponseEntity<String> test()
    {
        log.info("Received request for /test endpoint");
        log.info("ThreadName {}" , Thread.currentThread().getName());
        return ResponseEntity.ok("Hello World 1");
    }
}

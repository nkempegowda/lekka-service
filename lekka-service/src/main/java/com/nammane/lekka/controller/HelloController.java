package com.nammane.lekka.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("hello")
public class HelloController {

    @GetMapping
    public String seyHello(){
        return "hello";
    }

    @GetMapping("/{user}")
    public String seyHelloUser(@PathVariable("user")String user){
        return "hello "+user;
    }
}

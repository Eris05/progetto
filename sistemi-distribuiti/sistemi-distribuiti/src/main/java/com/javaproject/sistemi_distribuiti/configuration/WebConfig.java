package com.javaproject.sistemi_distribuiti.configuration;


import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer{

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        // Permetti richieste da tutti i domini per /questions
        registry.addMapping("/**")
                .allowedOrigins("http://localhost:63569")  // L'indirizzo del tuo frontend Flutter
                .allowedMethods("GET", "POST", "PUT", "DELETE")  // Le richieste HTTP che sono permesse
                .allowedHeaders("*")  // Consenti tutti gli header
                .allowCredentials(true);  // Se il frontend invia credenziali (cookie, headers personalizzati)
    }
}

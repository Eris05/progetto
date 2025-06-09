# Usa l'immagine di OpenJDK 17
FROM openjdk:17-jdk-slim

# Imposta la working directory
WORKDIR /app

# Copia il file JAR dell'app Spring Boot
COPY target/sistemi-distribuiti-0.0.1-SNAPSHOT.jar app.jar

# Esponi la porta su cui gira Spring Boot
EXPOSE 8080

# Comando per eseguire il backend
CMD ["java", "-jar", "app.jar"]

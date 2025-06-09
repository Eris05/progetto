# --------------------------
# FASE 1: Build con Maven
# --------------------------
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /build
COPY . .

RUN mvn clean package -DskipTests

# --------------------------
# FASE 2: Runtime con JDK
# --------------------------
FROM openjdk:17-jdk-slim

WORKDIR /app

#  Copia il file JAR dalla fase 'builder'
COPY --from=builder /build/target/sistemi-distribuiti-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]

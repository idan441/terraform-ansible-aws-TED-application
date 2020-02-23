FROM maven:3-alpine as builder
WORKDIR /app
COPY . . 
ENTRYPOINT ["mvn", "verify"]

FROM openjdk
COPY --from=builder /app /app
ENTRYPOINT ["java", "-jar", "/app/target/embedash-1.1-SNAPSHOT.jar","--spring.config.location=/app/application.properties"]
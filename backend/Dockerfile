FROM openjdk:17-jdk-slim

VOLUME /tmp

# Copy the jar file
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar

# Expose port
EXPOSE 8080

# Environment variables
ENV SPRING_PROFILES_ACTIVE=prod

# Run the application
ENTRYPOINT ["java","-jar","/app.jar"]
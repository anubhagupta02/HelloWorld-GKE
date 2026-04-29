# Use the official Eclipse Temurin 21 image as the base image
FROM eclipse-temurin:21-jdk-jammy

# Set the working directory inside the container
WORKDIR /app

# Copy the built JAR file from the host to the container
COPY build/libs/HelloWorld-0.0.1-SNAPSHOT.jar app.jar

# Expose the port that the application will run on
EXPOSE 8080

# Command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]

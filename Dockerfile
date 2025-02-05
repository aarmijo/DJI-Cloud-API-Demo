# Build stage using the official Maven image with OpenJDK 11
FROM maven:3.8-openjdk-11 AS build
# Define a build argument with a default version. This will override the revision property in your pom.xml.
ARG APP_VERSION=1.10.0
WORKDIR /app

# Copy only the necessary files and folders.
COPY pom.xml LICENSE /app/
COPY cloud-sdk /app/cloud-sdk/
COPY sample /app/sample/
COPY sql /app/sql/

# Build the multi-module project and repackage the Spring Boot jar.
RUN mvn clean package -Drevision=${APP_VERSION} -Dmaven.test.skip=true -Dspring-boot.repackage.version=2.7.12 && \
    mv sample/target/sample-${APP_VERSION}.jar sample/target/sample.jar

# Runtime stage: use a slim OpenJDK image
FROM openjdk:11-jre-slim
WORKDIR /app
# Copy only the renamed jar from the sample module's target directory in the build stage.
COPY --from=build /app/sample/target/sample.jar .

ENTRYPOINT ["java", "-jar", "sample.jar"]

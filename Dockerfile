FROM gradle:8.12.0-jdk17@sha256:2d7b30486264fab79e2fd1ccbb0a9cbdfa79ac2009263cac7802f4b1ed8f52f3 AS cache
WORKDIR /app
ENV GRADLE_USER_HOME /app/gradle
COPY *.gradle.kts gradle.properties /app/
RUN gradle shadowJar --parallel --console=verbose

FROM gradle:8.12.0-jdk17@sha256:2d7b30486264fab79e2fd1ccbb0a9cbdfa79ac2009263cac7802f4b1ed8f52f3 AS build
WORKDIR /app
COPY --from=cache /app/gradle /home/gradle/.gradle
COPY *.gradle.kts gradle.properties /app/
COPY src/main/ /app/src/main/
RUN gradle shadowJar --parallel --console=verbose

FROM amazoncorretto:21.0.6@sha256:c85c7135dc4129c10319b6aacb01e1f896ae0e3fccaa3823daae74643cac6126 as runtime
WORKDIR /app

COPY --from=build /app/build/libs/rtxalert-all.jar /app/rtxalert.jar

ENTRYPOINT ["java", "-jar", "/app/rtxalert.jar"]

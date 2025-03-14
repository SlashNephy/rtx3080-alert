FROM gradle:8.13.0-jdk17@sha256:d7ceb3073cb5a062df210269cff5be93b7667cb321b19a69f6a7ecb56a26afde AS cache
WORKDIR /app
ENV GRADLE_USER_HOME /app/gradle
COPY *.gradle.kts gradle.properties /app/
RUN gradle shadowJar --parallel --console=verbose

FROM gradle:8.13.0-jdk17@sha256:d7ceb3073cb5a062df210269cff5be93b7667cb321b19a69f6a7ecb56a26afde AS build
WORKDIR /app
COPY --from=cache /app/gradle /home/gradle/.gradle
COPY *.gradle.kts gradle.properties /app/
COPY src/main/ /app/src/main/
RUN gradle shadowJar --parallel --console=verbose

FROM amazoncorretto:21.0.6@sha256:c0643148d077b3917bf6c085aaa1ac35ff1f202344ab8691cc0f5953f9b97f8e as runtime
WORKDIR /app

COPY --from=build /app/build/libs/rtxalert-all.jar /app/rtxalert.jar

ENTRYPOINT ["java", "-jar", "/app/rtxalert.jar"]

FROM gradle:8.12.1-jdk17@sha256:deb3ed64f189e9b326e4147de66335286eea9f8b6677e53514af62370cbf7a4a AS cache
WORKDIR /app
ENV GRADLE_USER_HOME /app/gradle
COPY *.gradle.kts gradle.properties /app/
RUN gradle shadowJar --parallel --console=verbose

FROM gradle:8.12.1-jdk17@sha256:deb3ed64f189e9b326e4147de66335286eea9f8b6677e53514af62370cbf7a4a AS build
WORKDIR /app
COPY --from=cache /app/gradle /home/gradle/.gradle
COPY *.gradle.kts gradle.properties /app/
COPY src/main/ /app/src/main/
RUN gradle shadowJar --parallel --console=verbose

FROM amazoncorretto:21.0.6@sha256:aa94fda5e3ea59687d0a68e1c491687cb9d7365245d077684f848b2a53f1430d as runtime
WORKDIR /app

COPY --from=build /app/build/libs/rtxalert-all.jar /app/rtxalert.jar

ENTRYPOINT ["java", "-jar", "/app/rtxalert.jar"]

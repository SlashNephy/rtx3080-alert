FROM gradle:8.9.0-jdk17@sha256:682c0245826af1e6f5f7b95306cc7039d3d8d8e8de06b1a330e6f9015ee757a0 AS cache
WORKDIR /app
ENV GRADLE_USER_HOME /app/gradle
COPY *.gradle.kts gradle.properties /app/
RUN gradle shadowJar --parallel --console=verbose

FROM gradle:8.9.0-jdk17@sha256:682c0245826af1e6f5f7b95306cc7039d3d8d8e8de06b1a330e6f9015ee757a0 AS build
WORKDIR /app
COPY --from=cache /app/gradle /home/gradle/.gradle
COPY *.gradle.kts gradle.properties /app/
COPY src/main/ /app/src/main/
RUN gradle shadowJar --parallel --console=verbose

FROM amazoncorretto:21.0.4@sha256:f6267db88bddd9a7ae29e59d5b3b51eb4b16167b179d57b27e74a9834e2be29d as runtime
WORKDIR /app

COPY --from=build /app/build/libs/rtxalert-all.jar /app/rtxalert.jar

ENTRYPOINT ["java", "-jar", "/app/rtxalert.jar"]

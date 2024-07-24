FROM gradle:8.9.0-jdk17@sha256:59974b9d706ee92d74f0d3dc96951702dadc07d39c5c1e20a11455df0c195a9f AS cache
WORKDIR /app
ENV GRADLE_USER_HOME /app/gradle
COPY *.gradle.kts gradle.properties /app/
RUN gradle shadowJar --parallel --console=verbose

FROM gradle:8.9.0-jdk17@sha256:59974b9d706ee92d74f0d3dc96951702dadc07d39c5c1e20a11455df0c195a9f AS build
WORKDIR /app
COPY --from=cache /app/gradle /home/gradle/.gradle
COPY *.gradle.kts gradle.properties /app/
COPY src/main/ /app/src/main/
RUN gradle shadowJar --parallel --console=verbose

FROM amazoncorretto:18.0.1@sha256:50da77dcfd039a3af6864d322ae3f11d25492fc91dbc575009a1073ed7319a47 as runtime
WORKDIR /app

COPY --from=build /app/build/libs/rtxalert-all.jar /app/rtxalert.jar

ENTRYPOINT ["java", "-jar", "/app/rtxalert.jar"]

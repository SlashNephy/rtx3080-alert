FROM gradle:8.14.3-jdk17@sha256:c6f78d7020d3c92a45bba201879c178a3bcef4af8e109e3daa70b5f0ab02c65e AS cache
WORKDIR /app
ENV GRADLE_USER_HOME /app/gradle
COPY *.gradle.kts gradle.properties /app/
RUN gradle shadowJar --parallel --console=verbose

FROM gradle:8.14.3-jdk17@sha256:c6f78d7020d3c92a45bba201879c178a3bcef4af8e109e3daa70b5f0ab02c65e AS build
WORKDIR /app
COPY --from=cache /app/gradle /home/gradle/.gradle
COPY *.gradle.kts gradle.properties /app/
COPY src/main/ /app/src/main/
RUN gradle shadowJar --parallel --console=verbose

FROM amazoncorretto:18.0.1@sha256:50da77dcfd039a3af6864d322ae3f11d25492fc91dbc575009a1073ed7319a47 as runtime
WORKDIR /app

COPY --from=build /app/build/libs/rtxalert-all.jar /app/rtxalert.jar

ENTRYPOINT ["java", "-jar", "/app/rtxalert.jar"]

FROM gradle:8.14.0-jdk17@sha256:e92df1d16c3552a4a5127a5e43294ee255183131c682063408ddf920cfc993d3 AS cache
WORKDIR /app
ENV GRADLE_USER_HOME /app/gradle
COPY *.gradle.kts gradle.properties /app/
RUN gradle shadowJar --parallel --console=verbose

FROM gradle:8.14.0-jdk17@sha256:e92df1d16c3552a4a5127a5e43294ee255183131c682063408ddf920cfc993d3 AS build
WORKDIR /app
COPY --from=cache /app/gradle /home/gradle/.gradle
COPY *.gradle.kts gradle.properties /app/
COPY src/main/ /app/src/main/
RUN gradle shadowJar --parallel --console=verbose

FROM amazoncorretto:21.0.7@sha256:d51610ff3c790833e308318d25424361a69680a4b7968329b73012ad502ab936 as runtime
WORKDIR /app

COPY --from=build /app/build/libs/rtxalert-all.jar /app/rtxalert.jar

ENTRYPOINT ["java", "-jar", "/app/rtxalert.jar"]

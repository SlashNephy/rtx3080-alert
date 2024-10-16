FROM gradle:8.10.2-jdk17@sha256:33477ba5b65634f1aca6e236bff56c9fd3ff9515baa12773a08ca2f5ccd6805e AS cache
WORKDIR /app
ENV GRADLE_USER_HOME /app/gradle
COPY *.gradle.kts gradle.properties /app/
RUN gradle shadowJar --parallel --console=verbose

FROM gradle:8.10.2-jdk17@sha256:33477ba5b65634f1aca6e236bff56c9fd3ff9515baa12773a08ca2f5ccd6805e AS build
WORKDIR /app
COPY --from=cache /app/gradle /home/gradle/.gradle
COPY *.gradle.kts gradle.properties /app/
COPY src/main/ /app/src/main/
RUN gradle shadowJar --parallel --console=verbose

FROM amazoncorretto:21.0.5@sha256:1ecf7a5a18a91c49286b494ef35813349655fb821743f067e0b36c4d94d18371 as runtime
WORKDIR /app

COPY --from=build /app/build/libs/rtxalert-all.jar /app/rtxalert.jar

ENTRYPOINT ["java", "-jar", "/app/rtxalert.jar"]

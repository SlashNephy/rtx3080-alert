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

FROM amazoncorretto:21.0.4@sha256:9cfe41a64a5484b38d847e3a833e19b80448020b2fcabf13aa5908b432d99c29 as runtime
WORKDIR /app

COPY --from=build /app/build/libs/rtxalert-all.jar /app/rtxalert.jar

ENTRYPOINT ["java", "-jar", "/app/rtxalert.jar"]

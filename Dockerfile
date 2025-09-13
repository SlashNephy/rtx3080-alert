FROM gradle:8.14.3-jdk17@sha256:2c584c55bfac5d7b156a14edfdca3e6a7ba27c4c104a3c0bb74163e60013f84f AS cache
WORKDIR /app
ENV GRADLE_USER_HOME /app/gradle
COPY *.gradle.kts gradle.properties /app/
RUN gradle shadowJar --parallel --console=verbose

FROM gradle:8.14.3-jdk17@sha256:2c584c55bfac5d7b156a14edfdca3e6a7ba27c4c104a3c0bb74163e60013f84f AS build
WORKDIR /app
COPY --from=cache /app/gradle /home/gradle/.gradle
COPY *.gradle.kts gradle.properties /app/
COPY src/main/ /app/src/main/
RUN gradle shadowJar --parallel --console=verbose

FROM amazoncorretto:21.0.8@sha256:6f7e12166b3297823f56b9ea9adcae75b701a4f0585f093c10989fcd22c8ee9f as runtime
WORKDIR /app

COPY --from=build /app/build/libs/rtxalert-all.jar /app/rtxalert.jar

ENTRYPOINT ["java", "-jar", "/app/rtxalert.jar"]

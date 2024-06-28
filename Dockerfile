FROM gradle:8.8.0-jdk17@sha256:cb3b50c6d5298026e5962880469079d62389f33744af3bba90bf21175052aa91 AS cache
WORKDIR /app
ENV GRADLE_USER_HOME /app/gradle
COPY *.gradle.kts gradle.properties /app/
RUN gradle shadowJar --parallel --console=verbose

FROM gradle:8.8.0-jdk17@sha256:cb3b50c6d5298026e5962880469079d62389f33744af3bba90bf21175052aa91 AS build
WORKDIR /app
COPY --from=cache /app/gradle /home/gradle/.gradle
COPY *.gradle.kts gradle.properties /app/
COPY src/main/ /app/src/main/
RUN gradle shadowJar --parallel --console=verbose

FROM amazoncorretto:21.0.3@sha256:3de4ac51208f1b809f37d3babe434d6ac9bb74b273ebe4deda22be77baaaef8e as runtime
WORKDIR /app

COPY --from=build /app/build/libs/rtxalert-all.jar /app/rtxalert.jar

ENTRYPOINT ["java", "-jar", "/app/rtxalert.jar"]

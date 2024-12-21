FROM gradle:8.11.1-jdk17@sha256:91d559b8d55f522de5bc6882f73bcedc4e2cc7b0a58e839a9fa0ed95811a988d AS cache
WORKDIR /app
ENV GRADLE_USER_HOME /app/gradle
COPY *.gradle.kts gradle.properties /app/
RUN gradle shadowJar --parallel --console=verbose

FROM gradle:8.11.1-jdk17@sha256:91d559b8d55f522de5bc6882f73bcedc4e2cc7b0a58e839a9fa0ed95811a988d AS build
WORKDIR /app
COPY --from=cache /app/gradle /home/gradle/.gradle
COPY *.gradle.kts gradle.properties /app/
COPY src/main/ /app/src/main/
RUN gradle shadowJar --parallel --console=verbose

FROM amazoncorretto:21.0.5@sha256:ea5768203e58ec38c4352a28b135c8190468e15746ee5bec6e4294dd24adf8d6 as runtime
WORKDIR /app

COPY --from=build /app/build/libs/rtxalert-all.jar /app/rtxalert.jar

ENTRYPOINT ["java", "-jar", "/app/rtxalert.jar"]

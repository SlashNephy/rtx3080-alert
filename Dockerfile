FROM gradle:8.10.2-jdk17@sha256:134597a255301e63cda7b0554347275741b0240b3afc645175164550a1afff90 AS cache
WORKDIR /app
ENV GRADLE_USER_HOME /app/gradle
COPY *.gradle.kts gradle.properties /app/
RUN gradle shadowJar --parallel --console=verbose

FROM gradle:8.10.2-jdk17@sha256:134597a255301e63cda7b0554347275741b0240b3afc645175164550a1afff90 AS build
WORKDIR /app
COPY --from=cache /app/gradle /home/gradle/.gradle
COPY *.gradle.kts gradle.properties /app/
COPY src/main/ /app/src/main/
RUN gradle shadowJar --parallel --console=verbose

FROM amazoncorretto:21.0.5@sha256:a442b4beb07a8f4b20f66263bf620187d2e48a6ec882ce4d6a1ed63135c281d7 as runtime
WORKDIR /app

COPY --from=build /app/build/libs/rtxalert-all.jar /app/rtxalert.jar

ENTRYPOINT ["java", "-jar", "/app/rtxalert.jar"]

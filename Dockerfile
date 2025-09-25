FROM gradle:8.14.3-jdk17@sha256:628a4f22c98cd20fdc72ad16498abb5f576824f7bdab1417dfcaf1e5def7e9c2 AS cache
WORKDIR /app
ENV GRADLE_USER_HOME /app/gradle
COPY *.gradle.kts gradle.properties /app/
RUN gradle shadowJar --parallel --console=verbose

FROM gradle:8.14.3-jdk17@sha256:628a4f22c98cd20fdc72ad16498abb5f576824f7bdab1417dfcaf1e5def7e9c2 AS build
WORKDIR /app
COPY --from=cache /app/gradle /home/gradle/.gradle
COPY *.gradle.kts gradle.properties /app/
COPY src/main/ /app/src/main/
RUN gradle shadowJar --parallel --console=verbose

FROM amazoncorretto:25@sha256:9fcfe855a80c72f08ad8eb56a8090605d75584fd0f357246b6de6c0fc2cda92c as runtime
WORKDIR /app

COPY --from=build /app/build/libs/rtxalert-all.jar /app/rtxalert.jar

ENTRYPOINT ["java", "-jar", "/app/rtxalert.jar"]

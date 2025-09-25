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

FROM amazoncorretto:21.0.8@sha256:759f912b96b3aab92dd071cdc9582fe71e527016020716f98ddd2dfd6d42b4fe as runtime
WORKDIR /app

COPY --from=build /app/build/libs/rtxalert-all.jar /app/rtxalert.jar

ENTRYPOINT ["java", "-jar", "/app/rtxalert.jar"]

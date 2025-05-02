FROM gradle:8.14.0-jdk17@sha256:292f8efec195c0d7c0e543d5b06600c0a0501a860d6895bad902b36c6cd6c9ac AS cache
WORKDIR /app
ENV GRADLE_USER_HOME /app/gradle
COPY *.gradle.kts gradle.properties /app/
RUN gradle shadowJar --parallel --console=verbose

FROM gradle:8.14.0-jdk17@sha256:292f8efec195c0d7c0e543d5b06600c0a0501a860d6895bad902b36c6cd6c9ac AS build
WORKDIR /app
COPY --from=cache /app/gradle /home/gradle/.gradle
COPY *.gradle.kts gradle.properties /app/
COPY src/main/ /app/src/main/
RUN gradle shadowJar --parallel --console=verbose

FROM amazoncorretto:21.0.7@sha256:a05ae4abdf820458420bd59ab06ca1c8031baf88cddae07718c1227e4cf9a0b5 as runtime
WORKDIR /app

COPY --from=build /app/build/libs/rtxalert-all.jar /app/rtxalert.jar

ENTRYPOINT ["java", "-jar", "/app/rtxalert.jar"]

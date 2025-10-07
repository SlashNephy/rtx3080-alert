FROM gradle:8.14.3-jdk17@sha256:f487e80f0fb7345029c74153fa81066b4e8d5dbf6a0899e975df32fa4754c117 AS cache
WORKDIR /app
ENV GRADLE_USER_HOME /app/gradle
COPY *.gradle.kts gradle.properties /app/
RUN gradle shadowJar --parallel --console=verbose

FROM gradle:8.14.3-jdk17@sha256:f487e80f0fb7345029c74153fa81066b4e8d5dbf6a0899e975df32fa4754c117 AS build
WORKDIR /app
COPY --from=cache /app/gradle /home/gradle/.gradle
COPY *.gradle.kts gradle.properties /app/
COPY src/main/ /app/src/main/
RUN gradle shadowJar --parallel --console=verbose

FROM amazoncorretto:25@sha256:3648876d41a6b36f13a7679745f7dca8dd4ce1fe467e1d1949462455cc2bcc72 as runtime
WORKDIR /app

COPY --from=build /app/build/libs/rtxalert-all.jar /app/rtxalert.jar

ENTRYPOINT ["java", "-jar", "/app/rtxalert.jar"]

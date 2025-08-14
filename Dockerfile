FROM gradle:8.14.3-jdk17@sha256:fdb8cfa611ab5667b84c450a4d35e142090417d48bb6eae308ec3f45bcc7493b AS cache
WORKDIR /app
ENV GRADLE_USER_HOME /app/gradle
COPY *.gradle.kts gradle.properties /app/
RUN gradle shadowJar --parallel --console=verbose

FROM gradle:8.14.3-jdk17@sha256:fdb8cfa611ab5667b84c450a4d35e142090417d48bb6eae308ec3f45bcc7493b AS build
WORKDIR /app
COPY --from=cache /app/gradle /home/gradle/.gradle
COPY *.gradle.kts gradle.properties /app/
COPY src/main/ /app/src/main/
RUN gradle shadowJar --parallel --console=verbose

FROM amazoncorretto:21.0.8@sha256:b3569027d44397d1410603091bba256b1dbc6054ce9ac245b16d0c64e2f462d4 as runtime
WORKDIR /app

COPY --from=build /app/build/libs/rtxalert-all.jar /app/rtxalert.jar

ENTRYPOINT ["java", "-jar", "/app/rtxalert.jar"]

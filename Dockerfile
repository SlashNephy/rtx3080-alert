FROM gradle:8.14.3-jdk17@sha256:c0020bb573878e9e3f6271fe6d32529c38f383f063de6f8e72f6d30138956227 AS cache
WORKDIR /app
ENV GRADLE_USER_HOME /app/gradle
COPY *.gradle.kts gradle.properties /app/
RUN gradle shadowJar --parallel --console=verbose

FROM gradle:8.14.3-jdk17@sha256:c0020bb573878e9e3f6271fe6d32529c38f383f063de6f8e72f6d30138956227 AS build
WORKDIR /app
COPY --from=cache /app/gradle /home/gradle/.gradle
COPY *.gradle.kts gradle.properties /app/
COPY src/main/ /app/src/main/
RUN gradle shadowJar --parallel --console=verbose

FROM amazoncorretto:21.0.8@sha256:dc9e136c19854698f3dc848705cc43ad7cebaf168513126d7a87c1ea6107bb27 as runtime
WORKDIR /app

COPY --from=build /app/build/libs/rtxalert-all.jar /app/rtxalert.jar

ENTRYPOINT ["java", "-jar", "/app/rtxalert.jar"]

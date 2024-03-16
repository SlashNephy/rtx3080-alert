FROM gradle:8.6.0-jdk17@sha256:27ed98487dd9c155d555955084dfd33f32d9f7ac5a90a79b1323ab002a1a8b6e AS cache
WORKDIR /app
ENV GRADLE_USER_HOME /app/gradle
COPY *.gradle.kts gradle.properties /app/
RUN gradle shadowJar --parallel --console=verbose

FROM gradle:8.6.0-jdk17@sha256:27ed98487dd9c155d555955084dfd33f32d9f7ac5a90a79b1323ab002a1a8b6e AS build
WORKDIR /app
COPY --from=cache /app/gradle /home/gradle/.gradle
COPY *.gradle.kts gradle.properties /app/
COPY src/main/ /app/src/main/
RUN gradle shadowJar --parallel --console=verbose

FROM amazoncorretto:21.0.2@sha256:3a2ed04334a85a6b790b557c27c67bcf50c8a6e5407ea795592ed31c519840e5 as runtime
WORKDIR /app

COPY --from=build /app/build/libs/rtxalert-all.jar /app/rtxalert.jar

ENTRYPOINT ["java", "-jar", "/app/rtxalert.jar"]

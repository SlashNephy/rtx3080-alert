FROM gradle:8.14.3-jdk17@sha256:809c5f212631307505cafb8200a2dc6d42d3833fac11866eb947376fd2ec1fe8 AS cache
WORKDIR /app
ENV GRADLE_USER_HOME /app/gradle
COPY *.gradle.kts gradle.properties /app/
RUN gradle shadowJar --parallel --console=verbose

FROM gradle:8.14.3-jdk17@sha256:809c5f212631307505cafb8200a2dc6d42d3833fac11866eb947376fd2ec1fe8 AS build
WORKDIR /app
COPY --from=cache /app/gradle /home/gradle/.gradle
COPY *.gradle.kts gradle.properties /app/
COPY src/main/ /app/src/main/
RUN gradle shadowJar --parallel --console=verbose

FROM amazoncorretto:25@sha256:325a68614d796fed7c0bdbf2dfc28528ad0116b15af3aad3eaf2d7d846c735c0 as runtime
WORKDIR /app

COPY --from=build /app/build/libs/rtxalert-all.jar /app/rtxalert.jar

ENTRYPOINT ["java", "-jar", "/app/rtxalert.jar"]

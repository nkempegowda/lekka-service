FROM eclipse-temurin
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} application.jar
ENTRYPOINT ["java", "-Xmx2048M", "-jar", "/application.jar"]
# docker build -t spring-boot-app .
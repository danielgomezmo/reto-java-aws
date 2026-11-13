
# ETAPA 1: COMPILAR CON MAVEN
FROM maven:3.10.0-eclipse-temurin-21 AS compilacion

WORKDIR /app

COPY pom.xml .

COPY src ./src

RUN mvn -B clean package


# ETAPA 2: EJECUTAR LA APLICACION
FROM eclipse-temurin:21-jre

WORKDIR /app

COPY --from=compilacion /app/target/hola-mundo-1.0.0.jar app.jar

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]



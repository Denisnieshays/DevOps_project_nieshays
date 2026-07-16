FROM maven:3.8.6-openjdk-11 AS builder
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

FROM amazoncorretto:11
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
COPY wait-for-it.sh .
RUN chmod +x wait-for-it.sh
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
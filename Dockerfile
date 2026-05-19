# Estágio de Build (Compilação)
FROM maven:3.9-eclipse-temurin-21-alpine AS builder
WORKDIR /app
# Copia o pom.xml e faz o download das dependências (cache)
COPY pom.xml .
RUN mvn dependency:go-offline -B
# Copia o código fonte e gera o artefato .jar
COPY src ./src
RUN mvn clean package -DskipTests

# Estágio de Execução (Run)
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Criar grupo e usuário sem privilégios (Exigência DevOps 2.2)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copiar o jar gerado do estágio de build
COPY --from=builder /app/target/*.jar app.jar

# Mudar para o usuário não-root
USER appuser

# Expor a porta 8080
EXPOSE 8080

# Comando para rodar a aplicação
ENTRYPOINT ["java", "-jar", "app.jar"]

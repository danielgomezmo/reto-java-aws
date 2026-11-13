
# Reto Tecnico DevOps - Java

## Descripcion

Aplicacion sencilla Hola Mundo desarrollada
con Java 21.

Utiliza Maven para compilar el codigo
y Docker para empaquetar y ejecutar la aplicacion.

## Tecnologias

- Java 21
- Maven
- Docker
- Git y GitHub

## Construir imagen Docker

docker build -t reto-hola-mundo:1.0 .

## Ejecutar aplicacion

docker run --rm -p 127.0.0.1:8080:8080 reto-hola-mundo:1.0

## Probar aplicacion

Abrir en el navegador:

http://localhost:8080

## Estado del reto tecnico

- [x] Aplicacion Hola Mundo en Java
- [x] Compilacion con Maven y Docker
- [ ] Publicacion en AWS ECR
- [ ] Infraestructura con Terraform
- [ ] Despliegue en AWS ECS
- [ ] Automatizacion con GitHub Actions

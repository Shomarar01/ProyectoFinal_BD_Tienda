# Proyecto Final: Base de datos para tienda online

Este repositorio contiene el desarrollo del proyecto final para la materia de Bases de Datos, el sistema gestiona las operaciones de una tienda de productos electrónicos, incluyendo el manejo de clientes, productos, categorías, pedidos y reseñas.

## Fases del Proyecto

El proyecto está dividido en 5 entregables principales:

- [x] **Fase 1: Análisis y Diseño** (Diagrama ER, normalización 3NF, identificación de claves).
- [x] **Fase 2: Implementación** (Scripts DDL y DML en MySQL con restricciones y optimización con índices).
- [x] **Fase 3: Consultas y Procedimientos** (Implementación de lógica de negocio mediante procedimientos almacenados).
- [ ] **Fase 4: Validación y Optimización** (Pruebas de integridad).
- [ ] **Fase 5: Documentación** (Reporte formal estructurado en LaTeX).

## Tecnologías usadas

* **Base de Datos:** MySQL / MariaDB (Archivos `.sql`).
* **Lenguaje de Programación:** Java (Uso de JDBC para la conexión).
* **Documentación:** LaTeX (Compilado mediante VS Code y pdflatex).
* **Modelado:** MySQL Model para diagrama Entidad-Relación.

## Estructura del Repositorio
* `/docs`: Contiene los archivos fuente en LaTeX y los diagramas exportados.
* `/sql`: Contiene los scripts numerados por fases (`f1_...` , `f2_...`, `f3_...`, `f4_...`) listos para ser ejecutados en MySQL Workbench.

## 🚀 Guía de Ejecución

Para probar el proyecto localmente, abre MySQL Workbench y ejecuta los scripts ubicados en la carpeta `/sql` en el siguiente orden :
1. Ejecutar `f2_implementacion_tablas.sql` para crear la base de datos y sus restricciones.
2. Ejecutar `f2_implementacion_datos.sql` para insertar los datos de prueba.
3. Ejecutar `f3_consultas.sql` y `f3_storeProcedures` para almacenar la lógica del negocio en el servidor.

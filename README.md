# sistema_acviis
## Estructura de Carpetas del Proyecto

A continuación, se describe brevemente la función de cada carpeta del sistema:


### 🧩 Descripción de carpetas asociadas al backend

| Carpeta / Archivo     | Descripción |
|-----------------------|-------------|
| `index.js`            | Archivo principal que inicializa el servidor y configura middlewares. |
| `routes/`             | Define los endpoints de la API para cada entidad (modularizado). [usuarios.js, contratos.js, etc.]|
| `controllers/`        | Contiene funciones que controlan la lógica de cada ruta. [getUsuarios.dart, crearUsuario.dart, etc]|
| `services/`           | Contiene la lógica de negocio que interactúa con la base de datos. [Donde se utilizara Prisma y Mongoose para conectar con Supabase y MongoDB ]|
| `middlewares/`        | Middleware reutilizable para autenticación, validación, logging, etc. |
| `prisma/`             | Configuración de Prisma ORM, esquema de base de datos y migraciones. |
| `.env`                | Archivo para variables de entorno (no debe subirse al repositorio). |

---


- **`constants/`**: Define constantes globales utilizadas a lo largo del proyecto, como rutas, textos, colores o configuraciones fijas.

- **`models/`**: Contiene las clases que representan los modelos de datos del sistema (por ejemplo, Trabajador, Contrato, Obra, etc.).

- **`providers/`**: Incluye los proveedores de estado o servicios que gestionan la comunicación entre el modelo y la interfaz de usuario.

- **`test/`**: Almacena pruebas automatizadas del sistema, tanto de componentes individuales como de integración.

- **`ui/`**: Contiene toda la interfaz gráfica del sistema.
  - **`assets/`**: Recursos estáticos como imágenes, íconos o archivos de estilo.
  - **`views/`**: Vistas principales del sistema divididas por módulos funcionales.
    - **`contratos/`**, **`finanzas/`**, **`logistica/`**, **`obras/`**, **`trabajadores/`**: Cada carpeta representa un módulo funcional con sus respectivas pantallas y componentes.
  - **`widgets/`**: Componentes reutilizables de la interfaz, como botones, formularios, encabezados, etc.

- **`utils/`**: Funciones auxiliares o clases de utilidad utilizadas en diversas partes del sistema.

- **`.gitkeep`**: Archivos temporales (borrar una vez se agregue algo a su respectiva carpeta.) 


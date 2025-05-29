# sistema_acviis
## Estructura de Carpetas del Proyecto

A continuación, se describe brevemente la función de cada carpeta del sistema:

- **`backend/`**: Contiene la lógica del lado del servidor.
  - **`controllers/`**: Controladores encargados de manejar las peticiones y coordinar la lógica del negocio.
  - **`database/`**: Configuración de la base de datos, migraciones y datos de ejemplo (seeders).

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


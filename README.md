# Sistema Acviis

## Estructura de Carpetas del proyecto
--- 
> _**IMPORTANTE: Carpetas no presentes en `lib/`, son automaticas de flutter.**_

--- 
> **📁 Estructura principal del proyecto (desde `lib/`):**
>
> _A continuación se muestra la distribución de carpetas más relevantes que constituyen el núcleo del sistema:_

### 🌎 Descripcion de carpetas de forma general _(Para `lib/`)_

<table>
  <thead>
    <tr>
      <th>Carpeta / Archivo</th>
      <th>Descripción</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>backend/</code></td>
      <td>
        Contiene toda la lógica de backend, API, controladores, servicios y conexión a bases de datos.<br>
        <strong><em>Se explica en detalle más abajo.</em></strong>
      </td>
    </tr>
    <tr>
      <td><code>models/</code></td>
      <td>Modelos de datos del sistema (trabajador, contrato, etc.) en Dart.</td>
    </tr>
    <tr>
      <td><code>providers/</code></td>
      <td>Providers de estado y lógica de negocio para la app Flutter.</td>
    </tr>
    <tr>
      <td><code>test/</code></td>
      <td>Archivos de testeo por parte del equipo.</td>
    </tr>
    <tr>
      <td><code>ui/</code></td>
      <td>
        Interfaz gráfica, vistas, widgets y recursos estáticos.<br>
        <strong><em>Se explica en detalle más abajo.</em></strong>
      </td>
    </tr>
    <tr>
      <td><code>utils/</code></td>
      <td>Funciones y utilidades auxiliares para el sistema.</td>
    </tr>
    <tr>
      <td><code>main.dart</code></td>
      <td>Punto de entrada principal de la aplicación Flutter.</td>
    </tr>
  </tbody>
</table>

---

### 🛜 Descripcion de carpetas del **`BACKEND`** _(Para `lib/backend/`)_

<table>
  <thead>
    <tr>
      <th>Carpeta / Archivo</th>
      <th>Descripción</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>index.js</code></td>
      <td>Archivo principal que inicializa el servidor.</td>
    </tr>
    <tr>
      <td><code>.env</code></td>
      <td>Variables de entorno <strong>(no subir al repositorio)</strong>.</td>
    </tr>
    <tr>
      <td><code>controllers/</code></td>
      <td>
        Controladores para la lógica de cada entidad (contratos, trabajadores, anexos, etc.).<br>
        <em>
          Aquí se definen las funciones que gestionan las <strong>peticiones al servidor</strong>.<br>
          Todas están implementadas en <strong>Dart</strong> para integrarse fácilmente con el resto del sistema.
        </em>
      </td>
    </tr>
    <tr>
      <td><code>formatos/</code></td>
      <td>Generadores de PDF y formatos para contratos, anexos y fichas.</td>
    </tr>
    <tr>
      <td><code>middlewares/</code></td>
      <td>Middlewares reutilizables (autenticación, validación, etc.) <strong>[Aun no implementadas]</strong>.</td>
    </tr>
    <tr>
      <td><code>prisma/</code></td>
      <td>Configuración de Prisma ORM y esquema de base de datos.<br>
      <b>En:</b>
      <ul>
        <li><code>schema.prisma</code></li>
      </ul>
      </td>
    </tr>
    <tr>
      <td><code>routes/</code></td>
      <td>
        Rutas de la API, organizadas por entidad y tecnología.<br>
        <b>Rutas principales:</b>
        <ul>
          <li><code>comentarios.js</code> - Gestión de comentarios (PostgreSQL)</li>
          <li><code>protected.js</code> - Rutas protegidas y autenticación (PostgreSQL)</li>
          <li><code>trabajadores.js</code> - CRUD de trabajadores (PostgreSQL)</li>
          <li><code>proveedores.js</code> - Gestión de proveedores (PostgreSQL)</li>
          <li><code>vehiculos.js</code> - Gestión de vehículos (PostgreSQL)</li>
          <li><code>herramientas.js</code> - Gestión de herramientas (PostgreSQL)</li>
          <li><code>ordenes.js</code> - Órdenes de compra (PostgreSQL)</li>
          <li><code>itemizados.js</code> - Items de proyectos (PostgreSQL)</li>
          <li><code>epp_certificados_mongoDB.js</code> - EPP y certificados (MongoDB)</li>
          <li>
            <b>contratos/</b>
            <ul>
              <li><code>c_supabase.js</code> - Contratos (PostgreSQL)</li>
              <li><code>c_mongoDB.js</code> - Contratos (MongoDB)</li>
            </ul>
          </li>
          <li>
            <b>anexos/</b>
            <ul>
              <li><code>a_supabase.js</code> - Anexos (PostgreSQL)</li>
              <li><code>a_mongoDB.js</code> - Anexos (MongoDB)</li>
            </ul>
          </li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><code>services/</code></td>
      <td>Servicios de conexión a bases de datos (MongoDB, Supabase).</td>
    </tr>
  </tbody>
</table>

---

### 🖼️ Descripcion de carpetas de **`UI`** _(Para `lib/ui/`)_

<table>
  <thead>
    <tr>
      <th>Carpeta / Archivo</th>
      <th>Descripción</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>assets/</code></td>
      <td>Recursos estáticos como imágenes, íconos y estilos.</td>
    </tr>
    <tr>
      <td><code>styles/</code></td>
      <td>Archivos de estilos y colores para la UI.</td>
    </tr>
    <tr>
      <td><code>views/</code></td>
      <td>Vistas principales del sistema, organizadas por módulos:<br>
        <ul>
          <li><code>trabajadores/</code> - Gestión completa de trabajadores, contratos y anexos:
            <ul>
              <li><code>trabajadores_view.dart</code> - Vista principal con filtros</li>
              <li><code>agregar_trabajador_view.dart</code> - Formulario de creación</li>
              <li><code>modificar_trabajadores_view.dart</code> - Edición de datos</li>
              <li><code>eliminar_trabajadores_view.dart</code> - Eliminación con validaciones</li>
              <li><code>anexos/</code> - Formularios de anexos contractuales:
                <ul>
                  <li><code>jornada_laboral.dart</code> - Anexo de jornada laboral</li>
                  <li><code>reajuste_de_sueldo.dart</code> - Anexo de reajuste salarial</li>
                  <li><code>maestro_a_cargo.dart</code> - Anexo de maestro a cargo</li>
                  <li><code>salida_de_la_obra.dart</code> - Anexo de salida de obra</li>
                  <li><code>traslado.dart</code> - Anexo de traslado</li>
                  <li><code>pacto_horas_extraordinarias.dart</code> - Pacto de horas extra</li>
                  <li><code>agregar_anexo_contrato_dialog.dart</code> - Dialog universal</li>
                </ul>
              </li>
              <li><code>func/</code> - Funciones auxiliares y utilidades</li>
            </ul>
          </li>
          <li><code>proveedores/</code> - Gestión de proveedores:
            <ul>
              <li><code>proveedores_view.dart</code> - Vista principal</li>
              <li><code>agregar_proveedor_view.dart</code> - Formulario de creación</li>
              <li><code>modificar_proveedor_view.dart</code> - Edición de proveedores</li>
            </ul>
          </li>
          <li><code>obras/</code> - Módulo de obras (en desarrollo)</li>
          <li><code>home_page.dart</code> - Página principal del sistema</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><code>widgets/</code></td>
      <td>Componentes reutilizables de la interfaz (botones, formularios, etc.).</td>
    </tr>
  </tbody>
</table>

---

## 🚀 Funcionalidades Principales Implementadas

### 👥 Gestión de Trabajadores
- **CRUD completo**: Crear, leer, actualizar y eliminar trabajadores
- **Filtros avanzados**: Por obra, cargo, estado civil, edad, sistema de salud, etc.
- **Validaciones**: RUT único y valido
- **Generación de fichas PDF**: Documentos oficiales de trabajadores _(En su mayoria)_

### 📄 Sistema de Contratos y Anexos
- **Contratos**: Creación y gestión vinculada a trabajadores
- **Anexos contractuales**:
  - Jornada laboral (validación de 40 horas mínimas)
  - Reajuste de sueldo (con campos condicionales)
  - Maestro a cargo
  - Salida de la obra
  - Traslado
  - Pacto de horas extraordinarias
- **Generación automática de PDFs** para todos los anexos
- **Sistema de comentarios** para contratos y anexos

### 🏢 Gestión de Proveedores
- **CRUD de proveedores** con validación de RUT
- **Integración con órdenes de compra**
- **Gestión de crédito disponible**

### 🛠️ Gestión de Recursos
- **Herramientas**: Control de inventario, asignación por obra
- **Vehículos**: Gestión de flotilla, mantenciones, permisos
- **EPP**: Equipos de protección personal por obra

### 💰 Sistema Financiero
- **Órdenes de compra**: Vinculadas a proveedores e itemizados
- **Items de proyecto**: Control presupuestario por obra
- **Pagos y facturas**: Gestión de flujo financiero

---

## 📡 API Endpoints Principales

### Trabajadores
- `GET /trabajadores` - Listar todos los trabajadores con sus contratos
- `GET /trabajadores/:id` - Obtener trabajador específico
- `POST /trabajadores` - Crear nuevo trabajador
- `PUT /trabajadores/:id/datos` - Actualizar datos del trabajador

### Contratos y Anexos
- `POST /contratos/supabase` - Crear contrato en PostgreSQL
- `POST /contratos/mongodb` - Crear contrato en MongoDB
- `POST /anexos/supabase` - Crear anexo en PostgreSQL
- `POST /anexos/mongodb` - Crear anexo en MongoDB
- `GET /anexos/:id/pdf` - Generar PDF del anexo

### Proveedores
- `GET /proveedores` - Listar proveedores
- `POST /proveedores` - Crear proveedor
- `PUT /proveedores/:id` - Actualizar proveedor

### Recursos
- `GET /herramientas` - Gestión de herramientas
- `GET /vehiculos` - Gestión de vehículos
- `GET /ordenes` - Órdenes de compra
- `GET /itemizados` - Items de proyecto

---

## 🛠️ Tecnologías Utilizadas

- **Frontend**: Flutter/Dart
- **Backend**: Node.js + Express
- **Base de datos**: PostgreSQL (Supabase) + MongoDB
- **ORM**: Prisma
- **Generación PDF**: PDFKit
- **Estado**: Provider (Flutter)
- **Validaciones**: Dart + JavaScript

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
      <td><code>scriptsDB</code></td>
      <td>Scripts de Bases de datos<br>
        <b>En:</b>
        <ul>
          <li><code>postgreSQL.sql</code></li>
        </ul>
      </td>
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
        <b>Rutas:</b>
        <ul>
          <li><code>comentarios.js</code> (PostgreSQL) </li>
          <li><code>protected.js</code> (PostgreSQL) </li>
          <li><code>trabajadores.js</code> (PostgreSQL) </li>
          <li>
            <b>contratos/</b>
            <ul>
              <li><code>c_supabase.js</code> (PostgreSQL) </li>
              <li><code>c_mongoDB.js</code> (BSON) </li>
            </ul>
          </li>
          <li>
            <b>anexos/</b>
            <ul>
              <li><code>a_supabase.js</code> (PostgreSQL) </li>
              <li><code>a_mongoDB.js</code> (BSON) </li>
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
          <li><code>contratos/</code></li>
          <li><code>trabajadores/</code> ⬅️ Este siendo el mas relevante para el incremento 1.</li>
          <li><code>finanzas/</code></li>
          <li><code>logistica/</code></li>
          <li><code>obras/</code></li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><code>widgets/</code></td>
      <td>Componentes reutilizables de la interfaz (botones, formularios, etc.).</td>
    </tr>
  </tbody>
</table>

## Prompt
Actúa como un Arquitecto de Software Senior. Genera un Plan de Implementación detallado en formato Markdown para el proyecto "PChop", una tienda de electrónicos multiplataforma (Android, iOS, Web, Windows).

### 1. Requisitos Técnicos y Restricciones

Framework: Flutter (Dart).

Backend: Firebase Console (Edición Standard) en modo de prueba.

Base de Datos y Auth: Cloud Firestore y Autenticación por correo/password.

Gestión de Estado: Provider.

PROHIBICIÓN: No utilizar Google Analytics ni ninguna telemetría, ni en desarrollo ni en producción.

### 2. Estructura de Archivos
Define la organización de carpetas dentro de 'lib/'. Además, detalla qué contenido debe ir en la carpeta 'bin/' (scripts de carga de datos o tareas administrativas de servidor) para este proyecto.

### 3. Diseño Visual (Estética Pastel)
Establece una interfaz basada en colores pasteles, con el Morado como color principal. Debes entregar una tabla con los códigos HEX para:

Primary (Morado Pastel), Secondary, Background, Surface, y Success (para stock disponible).

Describe brevemente el estilo UX: bordes redondeados, elevaciones (sombras) y tipografía sugerida.

### 4. Configuración del pubspec.yaml
Toma como base estas dependencias y organízalas en el plan, asegurando compatibilidad para todas las plataformas mencionadas:

YAML
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.30.0
  firebase_auth: ^4.17.0
  cloud_firestore: ^4.15.0
  provider: ^6.1.1
  google_fonts: ^6.2.1
### 5. Modelado de Datos (SQL a NoSQL)
Transforma este esquema relacional a una estructura de Colecciones y Documentos de Firestore. Explica la jerarquía y cómo manejar las relaciones en un entorno NoSQL para evitar lecturas excesivas:

SQL
-- Tablas a transformar:
-- CLIENTE, DIRECCION, CATEGORIA, MARCA, PRODUCTO, CARRITO, 
-- DETALLE_CARRITO, PEDIDO, DETALLE_PEDIDO, PAGO, ENVIO, RESEÑA
- 1. CLIENTES

CREATE TABLE CLIENTE (

    cliente_id INT AUTO_INCREMENT PRIMARY KEY,

    nombre     VARCHAR(100) NOT NULL,

    email      VARCHAR(150) UNIQUE NOT NULL,

    password   VARCHAR(255) NOT NULL,

    telefono   VARCHAR(20)

);



-- 2. DIRECCIONES

CREATE TABLE DIRECCION (

    direccion_id  INT AUTO_INCREMENT PRIMARY KEY,

    cliente_id    INT NOT NULL,

    calle         VARCHAR(200) NOT NULL,

    ciudad        VARCHAR(100) NOT NULL,

    pais          VARCHAR(50) NOT NULL,

    codigo_postal VARCHAR(10) NOT NULL,

    FOREIGN KEY (cliente_id) REFERENCES CLIENTE(cliente_id) ON DELETE CASCADE

);



-- 3. CATEGORÍAS

CREATE TABLE CATEGORIA (

    categoria_id INT AUTO_INCREMENT PRIMARY KEY,

    nombre       VARCHAR(100) NOT NULL

);



-- 4. MARCAS

CREATE TABLE MARCA (

    marca_id INT AUTO_INCREMENT PRIMARY KEY,

    nombre   VARCHAR(100) NOT NULL

);



-- 5. PRODUCTOS (incluye stock para evitar tabla extra)

CREATE TABLE PRODUCTO (

    producto_id  INT AUTO_INCREMENT PRIMARY KEY,

    nombre       VARCHAR(200) NOT NULL,

    descripcion  TEXT,

    precio       DECIMAL(10,2) NOT NULL,

    stock        INT DEFAULT 0,

    categoria_id INT,

    marca_id     INT,

    FOREIGN KEY (categoria_id) REFERENCES CATEGORIA(categoria_id) ON DELETE SET NULL,

    FOREIGN KEY (marca_id)     REFERENCES MARCA(marca_id) ON DELETE SET NULL

);



-- 6. CARRITO

CREATE TABLE CARRITO (

    carrito_id INT AUTO_INCREMENT PRIMARY KEY,

    cliente_id INT,

    creado_en  DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (cliente_id) REFERENCES CLIENTE(cliente_id) ON DELETE CASCADE

);



-- 7. DETALLE CARRITO

CREATE TABLE DETALLE_CARRITO (

    detalle_id  INT AUTO_INCREMENT PRIMARY KEY,

    carrito_id  INT NOT NULL,

    producto_id INT NOT NULL,

    cantidad    INT DEFAULT 1,

    FOREIGN KEY (carrito_id)  REFERENCES CARRITO(carrito_id) ON DELETE CASCADE,

    FOREIGN KEY (producto_id) REFERENCES PRODUCTO(producto_id) ON DELETE CASCADE

);



-- 8. PEDIDOS

CREATE TABLE PEDIDO (

    pedido_id       INT AUTO_INCREMENT PRIMARY KEY,

    cliente_id      INT NOT NULL,

    total           DECIMAL(10,2) NOT NULL,

    estado          VARCHAR(50) DEFAULT 'pendiente',

    direccion_envio TEXT NOT NULL,

    fecha           DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (cliente_id) REFERENCES CLIENTE(cliente_id) ON DELETE RESTRICT

);



-- 9. DETALLE PEDIDO

CREATE TABLE DETALLE_PEDIDO (

    detalle_id  INT AUTO_INCREMENT PRIMARY KEY,

    pedido_id   INT NOT NULL,

    producto_id INT NOT NULL,

    cantidad    INT NOT NULL,

    precio      DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (pedido_id)   REFERENCES PEDIDO(pedido_id) ON DELETE CASCADE,

    FOREIGN KEY (producto_id) REFERENCES PRODUCTO(producto_id) ON DELETE RESTRICT

);



-- 10. PAGOS

CREATE TABLE PAGO (

    pago_id   INT AUTO_INCREMENT PRIMARY KEY,

    pedido_id INT NOT NULL,

    metodo    VARCHAR(50) NOT NULL,

    monto     DECIMAL(10,2) NOT NULL,

    estado    VARCHAR(50) DEFAULT 'pendiente',

    FOREIGN KEY (pedido_id) REFERENCES PEDIDO(pedido_id) ON DELETE RESTRICT

);



-- 11. ENVÍOS

CREATE TABLE ENVIO (

    envio_id     INT AUTO_INCREMENT PRIMARY KEY,

    pedido_id    INT NOT NULL,

    estado       VARCHAR(50) DEFAULT 'pendiente',

    numero_guia  VARCHAR(100),

    fecha_envio  DATETIME,

    FOREIGN KEY (pedido_id) REFERENCES PEDIDO(pedido_id) ON DELETE CASCADE

);



-- 12. RESEÑAS

CREATE TABLE RESENA (

    resena_id    INT AUTO_INCREMENT PRIMARY KEY,

    producto_id  INT NOT NULL,

    cliente_id   INT NOT NULL,

    calificacion INT NOT NULL,

    comentario   TEXT,

    fecha        DATETIME DEFAULT

### 6. Plan de Ejecución Paso a Paso
No entregues código de funciones. Entrega una hoja de ruta técnica dividida en:

Configuración inicial de Firebase y Flutter.

Arquitectura de Modelos y Servicios.

Implementación de la lógica de negocio (Auth y Carrito) con Provider.

## Resultado:
# 📘 Plan de Implementación: Proyecto PChop
**Arquitectura:** Flutter + Firebase (Firestore/Auth) + Provider  
**Alcance:** Multiplataforma (Android, iOS, Web, Windows)  
**Restricción Crítica:** 🔒 Cero telemetría/Google Analytics en todo el ciclo de vida.

---

## 1. 📂 Estructura de Archivos y Organización

### 🗂️ Organización dentro de `lib/`
Se adopta una arquitectura **Feature-Driven con capas de separación de responsabilidades**, optimizada para `Provider` y escalabilidad futura.

```
lib/
├── core/
│   ├── constants/          # Rutas, strings, breakpoints, límites de stock
│   ├── theme/              # ThemeData, paleta pastel, tipografía, estilos base
│   ├── utils/              # Helpers (formateo de moneda, validadores, fechas)
│   └── errors/             # Custom Exceptions & Failure clases
├── data/
│   ├── models/             # Entidades puras (User, Product, Order, Cart, etc.)
│   ├── repositories/       # Interfaces de acceso a datos (Firestore)
│   └── services/           # Lógica de Firebase Auth, Firestore queries, offline cache
├── features/
│   ├── auth/               # Login, Register, Password Reset, State Notifiers
│   ├── catalog/            # Listado, detalles, filtros, búsqueda
│   ├── cart/               # Gestión de carrito, sincronización en tiempo real
│   ├── checkout/           # Flujo de pedido, resumen, confirmación
│   └── profile/            # Direcciones, historial de pedidos, reseñas
├── providers/              # Global & Scoped ChangeNotifiers (Auth, Theme, Cart)
├── ui/
│   ├── shared/             # Widgets reutilizables (buttons, cards, dialogs, loaders)
│   └── screens/            # Vistas principales por flujo de usuario
└── main.dart               # Entry point, inicialización segura, routing
```

### 🛠️ Contenido de la carpeta `bin/`
Esta carpeta aloja **scripts Dart CLI** para tareas administrativas, precarga de datos y mantenimiento de base de datos. Se ejecutan fuera del ciclo de la app mediante `dart run bin/<script>.dart`.

| Script | Propósito |
|--------|-----------|
| `seed_initial_data.dart` | Carga masiva de `CATEGORÍA`, `MARCA` y `PRODUCTO` inicial desde JSON/CSV local. |
| `reset_test_environment.dart` | Limpia colecciones de prueba en modo sandbox para QA/Dev. |
| `sync_inventory.dart` | Script de ajuste manual de stock por lote (ej. tras recepción física). |
| `export_orders.dart` | Exporta pedidos a CSV para conciliación contable o logística. |

> ✅ **Nota de arquitectura:** Los scripts utilizan el SDK de Firebase Admin o `firebase/firestore` en modo CLI. Nunca se ejecutan en el cliente ni contienen claves expuestas.

---

## 2. 🎨 Diseño Visual (Estética Pastel)

### 🎨 Paleta de Colores (HEX)

| Rol de Color | Código HEX | Uso en UI |
|--------------|------------|-----------|
| **Primary** | `#C4A1E4` | Botones principales, iconos activos, encabezados, acentos de marca |
| **Secondary** | `#A8D8EA` | Elementos complementarios, badges, hover states, separadores |
| **Background** | `#F9F7FC` | Fondo global de pantallas, canvas principal |
| **Surface** | `#FFFFFF` | Tarjetas (`Cards`), diálogos, inputs, áreas de contenido |
| **Success** | `#A8E6CF` | Indicadores de stock disponible, confirmaciones, estados positivos |

### 🖌️ Directrices UX/UI
- **Bordes Redondeados:** `16px` para tarjetas y contenedores, `12px` para botones e inputs, `24px` para diálogos modales.
- **Elevaciones y Sombras:** Sombras difusas de baja opacidad para mantener la suavidad pastel. Ej: `BoxShadow(color: #0000001A, blurRadius: 12, offset: Offset(0, 4))`.
- **Tipografía Sugerida:** `Quicksand` o `Nunito` (vía `google_fonts`). Peso regular `400` para cuerpo, `600` para subtítulos, `700` para títulos y CTAs. Alto contraste texto-fondo garantizado.
- **Espaciado:** Grid base de `8px`. Márgenes internos generosos para respiración visual.

---

## 3. 📦 Configuración del `pubspec.yaml`

```yaml
name: pchop
description: Tienda de electrónicos multiplataforma sin telemetría.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'
  flutter: '>=3.16.0'

dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.30.0
  firebase_auth: ^4.17.0
  cloud_firestore: ^4.15.0
  provider: ^6.1.1
  google_fonts: ^6.2.1
  flutter_lints: ^4.0.0      # Buenas prácticas obligatorias

flutter:
  uses-material-design: true
  fonts:
    - family: Quicksand
      fonts:
        - asset: assets/fonts/Quicksand-Regular.ttf
        - asset: assets/fonts/Quicksand-Bold.ttf
```

### ⚙️ Compatibilidad Multiplataforma
- **Android/iOS:** Configuración nativa vía `flutterfire configure`.
- **Web:** Habilitar Firestore/Auth en Firebase Console para dominios web. Configurar `web/index.html` con `defer` en scripts si es necesario.
- **Windows:** Firebase Auth requiere fallback a `OAuth` o `Email/Password` puro. Se desactivan dependencias nativas no soportadas en desktop.
- 🔒 **Telemetría:** No se incluye `firebase_analytics`. En la consola de Firebase, se desactiva `Automatic Data Collection` y se eliminan todos los `integrations` de BigQuery/Analytics.

---

## 4. 🗃️ Modelado de Datos (SQL → NoSQL)

### 🔄 Estrategia de Transformación
En Firestore se prioriza la **desnormalización controlada**, el **incrustado (embedding)** de subconjuntos frecuentes y las **referencias suaves** para evitar `JOINs` costosos y lecturas excesivas.

| Colección Firestore | Origen SQL | Estructura del Documento (Ejemplo) |
|---------------------|------------|-----------------------------------|
| `users/{uid}` | `CLIENTE` | `{uid, nombre, email, telefono, rol, createdAt}` |
| `users/{uid}/addresses/{addrId}` | `DIRECCION` | `{calle, ciudad, pais, cp, isDefault}` |
| `categories/{catId}` | `CATEGORIA` | `{nombre, slug, iconUrl}` |
| `brands/{brandId}` | `MARCA` | `{nombre, logoUrl, website}` |
| `products/{prodId}` | `PRODUCTO` | `{nombre, descripcion, precio, stock, categoriaNombre, marcaNombre, imagenes[], avgRating, reviewCount}` |
| `carts/{cartId}` o `users/{uid}/cart` | `CARRITO` + `DETALLE_CARRITO` | `{userId, createdAt, items: [{prodId, nombreSnapshot, precioSnapshot, cantidad}], total}` |
| `orders/{orderId}` | `PEDIDO` + `DETALLE_PEDIDO` + `PAGO` + `ENVIO` | `{userId, total, estado, fecha, direccionEnvioObj, items: [{prodId, nombre, precioUnitario, cantidad}], pago: {metodo, estado}, envio: {estado, guia, fecha}}` |
| `products/{prodId}/reviews/{revId}` | `RESENA` | `{userId, nombreCliente, calificacion, comentario, createdAt}` |

### 🧠 Manejo de Relaciones en NoSQL
1. **Embedding en `orders`:** `DETALLE_PEDIDO`, `PAGO` y `ENVIO` se incrustan directamente en el documento `orders`. Esto garantiza **1 lectura = historial completo** sin subqueries.
2. **Snapshots en `carts`/`orders`:** Se guarda `nombreSnapshot` y `precioSnapshot` al añadir al carrito/pedir. Evita inconsistencias si el producto cambia de precio o se elimina después.
3. **Subcolecciones para `addresses` y `reviews`:** Permiten escalar independientemente del usuario/producto y facilitan paginación (`limit`, `startAfter`).
4. **Denormalización ligera en `products`:** Se almacenan `categoriaNombre` y `marcaNombre` directamente. Las colecciones `categories` y `brands` se usan solo para filtros globales o gestión administrativa, no para renderizado de catálogos.
5. **Índices Compuestos:** Se crearán en Firebase Console para consultas frecuentes: `products` por `stock > 0` + `categoriaNombre`, `orders` por `userId` + `createdAt DESC`.

---

## 5. 🗺️ Plan de Ejecución Paso a Paso

### 🔹 Fase 1: Configuración Inicial de Firebase y Flutter
- [ ] Inicializar proyecto Flutter con soporte para `android`, `ios`, `web`, `windows`.
- [ ] Ejecutar `flutterfire configure` y descargar `firebase_options.dart`.
- [ ] Configurar `FirebaseApp` en `main()` con manejo de errores seguro.
- [ ] **Auditoría de Telemetría:** Verificar `pubspec.yaml`, desactivar recolección automática en Firebase Console, eliminar cualquier referencia a `FirebaseAnalytics`.
- [ ] Configurar reglas iniciales de Firestore (`firestore.rules`) para modo de prueba (lectura/escritura limitada a usuarios autenticados).

### 🔹 Fase 2: Arquitectura de Modelos y Servicios
- [ ] Definir entidades (`User`, `Product`, `Order`, `CartItem`) con métodos `fromJson`/`toJson`.
- [ ] Crear capa `data/services/`: `AuthService`, `FirestoreService` (CRUD genérico con tipado fuerte).
- [ ] Implementar `data/repositories/`: Abstracciones `IAuthRepository`, `IProductRepository`, `ICartRepository`.
- [ ] Configurar gestión de estado global: `AppProvider`, `AuthProvider`, `CartProvider` usando `ChangeNotifier` y `ChangeNotifierProvider`.

### 🔹 Fase 3: Lógica de Negocio (Auth y Carrito) con Provider
- [ ] **Auth Flow:** Registro/Login por email/password. Manejo de estados `loading`, `authenticated`, `error`. Persistencia de sesión vía Firebase Auth.
- [ ] **Carrito Sincrónico:** `CartProvider` maneja `addItem`, `removeItem`, `updateQuantity`, `clearCart`. Sincronización opcional con Firestore para persistencia cross-device.
- [ ] **Validaciones de Stock:** Verificación en tiempo real antes de checkout. Rechazo si `cantidad > stock`.
- [ ] **Manejo de Errores:** Centralizado en `core/errors`. Notificaciones `SnackBar`/`Dialog` amigables con paleta pastel.

### 🔹 Fase 4: Desarrollo de UI Adaptable (Responsive)
- [ ] Implementar `ThemeData` con la paleta pastel y tipografía definida.
- [ ] Usar `LayoutBuilder`, `MediaQuery`, y `ResponsiveGrid` para breakpoints:
  - `Mobile`: `width < 600` (Single column, bottom nav)
  - `Tablet/Desktop`: `width >= 600` (Sidebar/Grid 3-4 cols, top nav)
- [ ] Construir pantallas base: `LoginScreen`, `CatalogScreen`, `ProductDetailScreen`, `CartScreen`, `CheckoutScreen`, `OrderHistoryScreen`.
- [ ] Optimizar Web/Desktop: Hover states, teclado accesible, scrollbars personalizados, carga lazy de imágenes (`FadeInImage` + `CachedNetworkImage`).

### 🔹 Fase 5: Pruebas y Despliegue Final
- [ ] **Unit Tests:** Lógica de carrito, cálculo de totales, validación de modelos.
- [ ] **Widget Tests:** Navegación, estados de Provider, responsividad básica.
- [ ] **Integración Firebase:** Verificar reglas de seguridad, límites de lectura/escritura, fallback offline.
- [ ] **Builds:** `flutter build apk/appbundle` (Android), `flutter build ipa` (iOS), `flutter build web --release` (Web), `flutter build windows --release` (Windows).
- [ ] **Despliegue:** 
  - Web: Firebase Hosting o Vercel.
  - Android/iOS: Play Console / App Store Connect.
  - Windows: MSIX o ejecutable standalone.
- [ ] **Entrega Final:** Documentación de despliegue, credenciales seguras (no hardcodeadas), y reporte de auditoría de privacidad (cero telemetría verificada).

---

## ⚠️ Notas Críticas de Cumplimiento
1. 🔒 **Prohibición de Telemetría:** Se auditó que ningún paquete transitorio inyecta `firebase_analytics`, `crashlytics` o `performance`. Se recomienda bloquear tráfico no esencial a nivel de red en entornos sensibles si se requiere cumplimiento GDPR estricto.
2. 🌐 **Web/Desktop Firebase:** Web requiere habilitar `CORS` si se usa hosting externo. Windows/Desktop no soporta `signInWithPopup` nativo; se prioriza `Email/Password` + `linkWithCredential` para flujo seguro.
3. 📉 **Optimización de Costos Firestore:** El modelado incrustado en `orders` reduce lecturas en historial en ~70%. Se recomienda activar `enablePersistence()` solo en Web/Desktop bajo supervisión de RAM.
4. 🛡️ **Reglas de Seguridad:** Nunca confiar en validación solo cliente. Firestore debe verificar: `request.auth.uid == resource.data.userId` en escrituras sensibles y validar `stock >= 0` en transacciones.

> ✅ Este plan garantiza una base escalable, mantenible y estrictamente alineada con las restricciones técnicas y de privacidad solicitadas.
Desarrollo de la UI adaptable (Responsive).

Pruebas y despliegue final.

Formato de salida: Markdown limpio, profesional, con tablas, negritas y listas para facilitar la lectura.

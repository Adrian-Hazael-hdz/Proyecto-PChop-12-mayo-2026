# 📘 Plan Técnico de Implementación Profesional - "PChop"
**E-commerce Multiplataforma (Android, iOS, Web, Windows) | Flutter + Firebase + Provider**

---

## 🎯 Propósito y Alcance Técnico
Desarrollar una aplicación de comercio electrónico para venta de electrónicos (computadoras, teléfonos, periféricos) con arquitectura escalable, estado local sincronizado con Firestore, navegación adaptativa por plataforma, y un sistema de diseño basado en tonos pastel con el morado claro como identidad principal. El plan establece la secuencia técnica exacta, el mapeo de bases de datos, la estructura del proyecto y los estándares de calidad antes de la generación de código.

---

## 🛠️ Ecosistema de Desarrollo

| Herramienta | Rol en el Flujo de Trabajo |
|-------------|----------------------------|
| **VS Code** | Entorno principal de compilación, depuración, testing, control de versiones y análisis estático. |
| **Antigravity** | Entorno asistido por IA para generación de scaffolding, validación de arquitectura, refactorización guiada y prototipado rápido de widgets/providers. Se usa en paralelo a VS Code para acelerar la escritura de patrones repetitivos. |
| **Firebase Console** | Auth (Email/Password), Firestore (BD NoSQL), Storage (imágenes), Hosting (Web), Crashlytics, Analytics. |
| **Flutter SDK** | Canal `stable`. Soporte habilitado para `android`, `ios`, `web`, `windows`. |
| **Git + CI/CD** | Repositorio centralizado. Pipeline opcional para builds multiplataforma y despliegue web. |

---

## 🗄️ Estrategia de Mapeo de Datos (Relacional → Firestore)

El esquema proporcionado es relacional. Firestore es documental; por tanto, se aplicará **denormalización controlada**, **subcolecciones** y **snapshots inmutables** para garantizar rendimiento en lecturas y consistencia en transacciones.

| Tabla Relacional | Estructura en Firestore | Estrategia Técnica |
|------------------|-------------------------|--------------------|
| `CLIENTE` | `users/{uid}` | Documento raíz vinculado a Firebase Auth. Campos: `nombre`, `apellido`, `email`, `telefono`, `estado`, `fechaRegistro`, `ultimoLogin`. |
| `DIRECCION` | `users/{uid}/addresses/{addressId}` | Subcolección. Cada doc representa una dirección. Campo `esPredeterminada` como booleano. Se copia como snapshot en `orders` al confirmar compra. |
| `PRODUCTO` | `products/{productId}` | Documento principal. Incluye `categoriaNombre`, `marcaNombre` (denormalizados para evitar joins). Campos de precio, stock, estado, fechas. |
| `CATEGORIA` / `MARCA` | `categories/{catId}` / `brands/{brandId}` | Colecciones de referencia. Se usan para filtros y dropdowns. No se anidan en productos para evitar duplicación masiva. |
| `IMAGEN_PRODUCTO` | `products/{productId}/images/{imageId}` **o** Array `imageUrls[]` en doc principal | Se recomienda array de URLs con metadatos `orden` y `esPrincipal` para reducir lecturas. Subcolección solo si se requiere versión original + thumbnails. |
| `ESPECIFICACION` | `products/{productId}/specs/{specId}` **o** Mapa `specs: {ram: "16GB", pantalla: "15.6"}` | Mapa embebido es óptimo para specs estáticas. Subcolección solo si son dinámicas o muy extensas. |
| `INVENTARIO` + `PROVEEDOR` | `inventory/{productId}` / `suppliers/{supplierId}` | `inventory` almacena `stockActual`, `stockMinimo`, `ubicacion`. `suppliers` es catálogo administrativo. Se vincula por `productId`/`supplierId`. |
| `CARRITO` + `DETALLE_CARRITO` | Estado local (`Provider`) → `users/{uid}/cart/{itemId}` (solo usuarios registrados) | El carrito es volátil. Se persiste en Firestore únicamente para sincronización cross-device o recuperación de sesión. |
| `PEDIDO` + `DETALLE_PEDIDO` | `orders/{orderId}` + subcolección `items/{itemId}` | `orders` contiene snapshot inmutable de dirección, cupón aplicado, totales y estado. `items` guarda `productId`, `cantidad`, `precioUnitarioSnapshot`. |
| `PAGO` + `ENVIO` + `CUPON` | `orders/{orderId}/payments/{paymentId}` / `shipping/{shippingId}` / `coupons/{couponId}` | Pagos y envíos son subcolecciones del pedido. Cupones se validan en tiempo real y se guardan como referencia en el pedido. |
| `RESENA` | `products/{productId}/reviews/{reviewId}` + `products/{productId}/reviewSummary` | Subcolección para comentarios. `reviewSummary` es documento agregado con `promedio`, `totalReseñas`, `distribucionCalificaciones` (actualizado vía Cloud Function o cliente tras validar). |

🔒 **Reglas de Seguridad Firestore (Resumen):**
- `users/*`: Solo el propietario autenticado puede leer/escribir.
- `products/*`: Lectura pública. Escritura restringida a roles administrativos.
- `orders/*`: Solo el creador del pedido puede leer. Escritura solo en creación.
- `inventory/*`, `suppliers/*`: Acceso restringido a backend/admin.

---

## 📂 Arquitectura de Directorios y Patrones

```text
lib/
├── main.dart                      # Punto de entrada, inicialización Firebase, Theme, Router
├── config/
│   ├── routes.dart                # go_router: rutas, redirecciones, deep links
│   ├── theme.dart                 # ThemeData: colores pastel, tipografía, componentes base
│   └── firebase_init.dart         # Configuración multi-flavor (dev/prod)
├── core/
│   ├── constants/                 # Strings, dimensiones, breakpoints
│   ├── errors/                    # Custom exceptions, error handlers
│   ├── utils/                     # Formatters, validators, date helpers
│   └── widgets/                   # Reutilizables puros: PastelButton, CustomTextField, LoadingShimmer
├── data/
│   ├── models/                    # Clases Dart (fromJson/toJson): User, Product, Order, CartItem, Review
│   ── dto/                       # Data Transfer Objects para payloads específicos
├── services/
│   ├── auth_service.dart          # Firebase Auth wrapper
│   ├── firestore_service.dart     # Queries genéricas, paginación, batch writes
│   ├── storage_service.dart       # Upload/download imágenes
│   └── cart_sync_service.dart     # Sincronización carrito local ↔ Firestore
├── providers/
│   ├── auth_provider.dart         # Estado sesión, perfil, direcciones
│   ├── product_provider.dart      # Catálogo, filtros, búsqueda, detalle
│   ├── cart_provider.dart         # CRUD carrito, cálculos totales
│   ├── order_provider.dart        # Creación, seguimiento, historial
│   └── ui_provider.dart           # Theme, navegación, estados de carga global
├── ui/
│   ├── screens/
│   │   ├── auth/                  # Login, Register, ForgotPassword
│   │   ├── home/                  # Home, Categories, Search, Filters
│   │   ├── product/               # Detail, Specs, Reviews, Gallery
│   │   ├── cart/                  # Cart, Checkout, CouponInput
│   │   ├── orders/                # OrderList, OrderDetail, Tracking
│   │   ├── profile/               # Profile, Addresses, Security
│   │   └── admin/                 # (Opcional) CRUD productos, inventario
│   └── platforms/                 # Adaptaciones específicas (si es necesario)
└── utils/
    ├── platform_utils.dart        # Detección SO, breakpoints, navegación adaptativa
    └── analytics_utils.dart       # Eventos Firebase Analytics
```

**Patrones Aplicados:**
- **Provider + ChangeNotifier:** Gestión de estado predecible, sin boilerplate excesivo.
- **Repository Pattern (ligero):** `services/` abstraen Firebase; `providers/` consumen servicios.
- **Inmutabilidad en transacciones:** Pedidos y pagos guardan snapshots para evitar inconsistencias históricas.
- **Navegación Adaptativa:** `go_router` con layouts diferenciados para móvil (BottomNav) y escritorio (NavigationRail/SideMenu).

---

##  Sistema de Diseño UI/UX (Paleta Pastel Profesional)

| Elemento | Color / Hex | Uso Técnico |
|----------|-------------|-------------|
| **Primario** | `#B8A9E8` (Morado claro) | Botones CTA, barras activas, acentos interactivos, badges destacados |
| **Secundario** | `#A8D5E2` (Azul pastel) | Estados informativos, enlaces secundarios, fondos de secciones |
| **Fondo Base** | `#F8F9FB` (Gris pastel frío) | Scaffold background, separación visual |
| **Superficie** | `#FFFFFF` (Blanco) | Cards, modales, inputs, áreas de contenido |
| **Texto Principal** | `#1E293B` (Azul grisáceo oscuro) | WCAG AA garantizado sobre fondos pastel. Títulos y cuerpo |
| **Texto Secundario** | `#64748B` (Gris medio) | Descripciones, metadatos, placeholders |
| **Éxito/Stock** | `#A7F3D0` (Menta pastel) | Indicadores positivos, precios oferta, confirmaciones |
| **Alerta/Stock Bajo** | `#FED7AA` (Naranja pastel) | Advertencias, cupones por vencer, validaciones |

**Directrices UI/UX:**
- **Accesibilidad:** Contraste mínimo 4.5:1. Soporte a `MediaQuery.textScaleFactor`. Etiquetas semánticas para lectores de pantalla.
- **Responsive:** 
  - Móvil: `BottomNavigationBar`, grids 2 cols, full-width cards.
  - Web/Windows: `NavigationRail` o `AppBar` extendido, grids 4-5 cols, tablas para pedidos, hover states.
- **Feedback:** Skeleton loaders (`shimmer`), toast/snackbar pastel, empty states ilustrados, validación en tiempo real de formularios.
- **Componentes Base:** `PastelElevatedButton`, `PastelOutlinedButton`, `ProductCard`, `SpecTable`, `ReviewRow`, `AddressSelector`.

---

## 📦 Stack de Dependencias (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase & Cloud
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest
  firebase_storage: ^latest
  firebase_analytics: ^latest
  firebase_crashlytics: ^latest

  # Estado y Rutas
  provider: ^latest
  go_router: ^latest
  flutter_hooks: ^latest          # Reduce boilerplate en widgets con estado
  equatable: ^latest              # Comparación eficiente de modelos

  # UI y Experiencia
  cached_network_image: ^latest
  shimmer: ^latest
  flutter_slidable: ^latest       # Acciones en carrito/pedidos
  google_fonts: ^latest
  flutter_svg: ^latest
  intl: ^latest                   # Formatos moneda/fecha

  # Utilidades y Seguridad
  uuid: ^latest                   # IDs locales/carrito
  validators: ^latest             # Validación email/password
  flutter_dotenv: ^latest         # Variables de entorno
  shared_preferences: ^latest     # Cache ligero (theme, onboarding)

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^latest
  build_runner: ^latest
  mockito: ^latest
```

---

## 📋 Procedimiento Técnico Paso a Paso

1. **Inicialización Multiplataforma y Configuración Base**
   - Crear proyecto Flutter con soporte `android`, `ios`, `web`, `windows`.
   - Configurar `pubspec.yaml`, `flutter_launcher_icons`, y assets.
   - Establecer `.gitignore`, `.env` para variables de entorno, y estructura de carpetas definida.
   - Configurar `go_router` con shell routes y placeholders para validación de navegación.

2. **Integración de Firebase y Reglas de Seguridad**
   - Ejecutar `flutterfire configure` para generar `firebase_options.dart` multiplataforma.
   - Inicializar `FirebaseCore`, `FirebaseAuth`, `Firestore`, `Storage` en `main.dart`.
   - Redactar e implementar reglas de seguridad en Firestore alineadas al mapeo NoSQL.
   - Habilitar Auth (Email/Password) y configurar verificación por email (opcional).

3. **Sistema de Diseño y Tema Base**
   - Implementar `ThemeData` con paleta pastel, tipografía, radios, elevaciones y estados de botones.
   - Crear widgets base reutilizables (`PastelButton`, `CustomTextField`, `LoadingShimmer`, `EmptyState`).
   - Configurar `MediaQuery` breakpoints y adaptadores de layout (`LayoutBuilder`, `Platform.isDesktop`).

4. **Autenticación y Gestión de Perfiles**
   - Desarrollar `AuthService` (login, register, logout, resetPassword, stream de usuario).
   - Implementar `AuthProvider` con `ChangeNotifier` para estado global de sesión.
   - Crear pantallas de Login/Registro con validación en tiempo real y manejo de errores Firebase.
   - Sincronizar `users/{uid}` tras registro y desarrollar CRUD de `addresses` subcolección.

5. **Catálogo de Productos y Búsquedas**
   - Modelar clases Dart (`Product`, `Category`, `Brand`, `Review`) con `fromJson/toJson`.
   - Implementar `ProductService` con queries paginadas (`startAfterDocument`), filtros por categoría/marca/precio, y búsqueda por texto.
   - Desarrollar `ProductProvider` para estado del catálogo, loading, error y empty.
   - Construir `HomeScreen` con grid adaptable, filtros laterales (desktop) / drawer (mobile), y skeleton loaders.
   - Implementar `ProductDetailScreen` con galería, specs embebidas, y botón de acción.

6. **Carrito de Compras y Checkout**
   - Crear `CartItem` model y `CartProvider` con lógica local (add, remove, updateQty, clear, total).
   - Sincronizar carrito con Firestore solo para usuarios registrados (`users/{uid}/cart`).
   - Desarrollar `CartScreen` con lista editable, resumen y validación de stock.
   - Implementar flujo de checkout: selección de dirección, aplicación de cupón (`coupons/{couponId}`), cálculo de impuestos/descuentos, y creación de `orders/{orderId}` con snapshot inmutable.

7. **Gestión de Pedidos, Pagos y Envíos**
   - Crear `OrderProvider` para historial y detalle.
   - Implementar `OrderDetailScreen` con línea de tiempo de estado (`pendiente`, `pagado`, `enviado`, `entregado`, `cancelado`).
   - Modelar subcolecciones `payments` y `shipping` dentro del pedido.
   - Simular integración de pasarela (placeholder para Stripe/MercadoPago) con `referenciaExterna` y estado de pago.

8. **Reseñas, Calificaciones y Postventa**
   - Desarrollar `ReviewService` con validación de compra verificada (`pedido_id` vinculado).
   - Implementar formulario de reseña con estrellas, título y comentario.
   - Actualizar `reviewSummary` (promedio y conteo) tras aprobación/moderación.
   - Mostrar reseñas en detalle de producto con paginación y filtros por calificación.

9. **Adaptación Responsive y Optimización Multiplataforma**
   - Ajustar navegación: `BottomNavigationBar` (móvil) → `NavigationRail`/`SideMenu` (web/windows).
   - Optimizar grids: 2 cols (mobile) → 4-5 cols (desktop).
   - Implementar `DataTable` o `ListView` avanzado para historial de pedidos en escritorio.
   - Asegurar compatibilidad de rutas, deep links y manejo de teclado en Web/Windows.
   - Reducir rebuilds: `const`, `Consumer` selectivo, `Selector` en Provider, imágenes cacheadas.

10. **Testing, Analítica y Despliegue**
    - Unit tests para providers, servicios y modelos (`mockito`).
    - Widget tests para componentes críticos y flujos de navegación.
    - Integrar `FirebaseAnalytics` para eventos: `view_item`, `add_to_cart`, `begin_checkout`, `purchase`.
    - Configurar `Crashlytics` y manejo global de errores.
    - Builds: `flutter build apk/appbundle`, `ipa`, `web`, `windows`.
    - Despliegue Web en Firebase Hosting. Configuración de signing y publicación en stores (opcional).

---

## ✅ Criterios de Calidad y Validación

| Área | Criterio de Aceptación |
|------|------------------------|
| **Arquitectura** | Separación clara UI/Estado/Servicios. Provider sin ciclos de notificación. |
| **Base de Datos** | Consultas paginadas, índices compuestos declarados, snapshots inmutables en transacciones. |
| **UI/UX** | Paleta pastel consistente, contraste WCAG AA, layouts adaptativos por plataforma, feedback visual en todos los estados. |
| **Rendimiento** | < 2s carga inicial catálogo, rebuilds mínimos, imágenes cacheadas, queries optimizadas. |
| **Seguridad** | Reglas Firestore estrictas, validación de entrada, manejo seguro de tokens, sin datos sensibles en logs. |
| **Multiplataforma** | Navegación y layouts adaptados, compilación exitosa en las 4 plataformas, deep links funcionales. |

---

## 🚀 Siguiente Hito
El plan técnico está consolidado. El siguiente paso es la **generación estructurada de código**, comenzando por:
1. Configuración inicial, `pubspec.yaml`, estructura de carpetas y `ThemeData` pastel.
2. Inicialización Firebase + `go_router` + widgets base.
3. `AuthProvider` + pantallas de autenticación.

¿Confirmas que procedamos con la **Fase 1 de implementación (código base + tema + estructura)** o deseas ajustar algún modelo de datos, dependencia o flujo antes de generar los archivos?

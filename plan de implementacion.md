# 📱 Plan de Implementación - Aplicación "PChop" (Tienda de Electrónicos)

> **Objetivo:** Desarrollar una aplicación multiplataforma (Android, iOS, Web) tipo e-commerce para la venta de computadoras, teléfonos, periféricos y accesorios, con autenticación, catálogo dinámico, carrito de compras y gestión de pedidos.  
> **Stack principal:** Flutter + Dart, Firebase (Auth, Firestore, Storage), `provider` como gestor de estado, VS Code como IDE.  
> **Nota:** *Antigravity* no es un IDE reconocido para desarrollo Flutter. Se recomienda **VS Code** o **Android Studio** con las extensiones oficiales de Flutter/Dart.

---

## 🛠️ 1. Herramientas y Entorno de Desarrollo

| Categoría | Herramienta / Recurso |
|-----------|------------------------|
| **IDE** | VS Code + extensiones: `Flutter`, `Dart`, `Firebase`, `Pubspec Assist`, `Error Lens` |
| **SDK** | Flutter (canal estable más reciente) + Dart SDK |
| **Control de versiones** | Git + GitHub/GitLab |
| **Diseño UI/UX** | Figma / Penpot / Adobe XD (prototipado y handoff) |
| **Backend / BaaS** | Firebase Console (Auth, Firestore, Storage, Crashlytics, Analytics) |
| **Pruebas** | Flutter Test Framework, Firebase Test Lab, dispositivos físicos/emuladores |
| **CI/CD (opcional)** | GitHub Actions / Codemagic / Fastlane |

---

## 📦 2. Arquitectura y Gestión de Estado

- **Patrón:** MVVM simplificado o Clean Architecture ligera
- **Estado:** `provider` (según requerimiento)
- **Navegación:** `go_router` (recomendado para deep links y web) o `Navigator 2.0` nativo
- **Estructura de carpetas sugerida:**
  ```
  lib/
  ├── main.dart
  ├── core/          # constantes, temas, utils, rutas
  ├── data/          # servicios, modelos, repositorios
  ├── providers/     # ChangeNotifier / ChangeNotifierProvider
  ├── screens/       # vistas principales
  ├── widgets/       # componentes reutilizables
  └── config/        # firebase init, environment, flavors
  ```

---

## 📋 3. Dependencias Principales (`pubspec.yaml`)

> *Solo se listan paquetes esenciales. Se evitarán versiones hardcodeadas en este plan.*

| Tipo | Paquetes |
|------|----------|
| **Core** | `provider`, `go_router`, `cached_network_image`, `intl`, `equatable` |
| **Firebase** | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_crashlytics`, `firebase_analytics` |
| **UI/UX** | `flutter_svg`, `google_fonts`, `shimmer`, `flutter_staggered_grid_view` |
| **Utilidades** | `shared_preferences`, `flutter_dotenv`, `uuid`, `validators` |
| **Dev/Testing** | `flutter_lints`, `mockito`, `flutter_test` |

---

## 🎨 4. Guías de UI/UX

- **Estilo visual:** Minimalista, profesional, orientado a conversión (e-commerce)
- **Paleta sugerida:** 
  - Primario: `#0A2463` (azul tecnológico)
  - Secundario: `#3E92CC` (acento)
  - Fondo: `#F8F9FA` / `#FFFFFF`
  - Éxito/Error: Verde `#2ECC71` / Rojo `#E74C3C`
- **Componentes clave:** 
  - Bottom Navigation / Rail (móvil/desktop)
  - SearchBar con autocompletado y filtros
  - Product Card (imagen, nombre, precio, rating, badge)
  - Cart Floating Action / Drawer
  - Skeleton loaders para estados de carga
- **Responsive:** Layouts adaptativos (`LayoutBuilder`, `MediaQuery`, breakpoints para tablet/web)
- **Accesibilidad:** Contraste WCAG AA, escalado de texto, etiquetas semánticas, feedback háptico/visual

---

## 🗺️ 5. Procedimiento Paso a Paso (Plan de Desarrollo)

### 🔹 Fase 1: Configuración Inicial
1. Instalar Flutter, VS Code y extensiones requeridas.
2. Crear proyecto: `flutter create pchop --org com.pchop.app`
3. Inicializar repositorio Git y configurar `.gitignore`.
4. Crear proyecto en Firebase Console.
5. Registrar apps (Android, iOS, Web) y descargar/configurar credenciales.
6. Añadir `firebase_core` y ejecutar `flutterfire configure`.
7. Crear estructura de carpetas base y archivo `pubspec.yaml` con dependencias iniciales.

### 🔹 Fase 2: UI Base y Navegación
1. Diseñar wireframes y mockups en Figma (Login, Home, Detalle, Carrito, Perfil).
2. Configurar `ThemeData` global (colores, tipografía, elevaciones, radios).
3. Crear componentes reutilizables: `PrimaryButton`, `CustomTextField`, `ProductCard`, `EmptyState`, `LoadingIndicator`.
4. Implementar estructura de rutas base con `go_router` o `Navigator`.
5. Crear pantallas placeholder y validar navegación fluida.

### 🔹 Fase 3: Autenticación (Email/Password)
1. Habilitar método Email/Password en Firebase Auth Console.
2. Crear modelo `AppUser` (id, email, displayName, photoURL, role, createdAt).
3. Implementar `AuthProvider` con `ChangeNotifier`:
   - `login(email, password)`
   - `register(email, password, displayName)`
   - `logout()`
   - `resetPassword(email)`
4. Conectar pantallas Login/Registro con el provider.
5. Manejar estados: loading, success, error, validaciones de formulario.
6. Implementar redirección post-auth y protección de rutas (`redirect` en router).
7. Configurar persistencia de sesión automática (manejada por Firebase).

### 🔹 Fase 4: Base de Datos Firestore y Catálogo
1. Diseñar colección Firestore:
   - `products`: `{ id, name, description, price, category, brand, specs[], images[], stock, rating, createdAt }`
   - `categories`: `{ id, name, icon, slug }`
   - `users`: `{ uid, email, displayName, addresses[], createdAt }`
2. Crear reglas de seguridad en Firestore (lectura pública de productos, escritura restringida).
3. Implementar `ProductService` con streams y queries paginadas.
4. Crear `ProductProvider` para estado del catálogo.
5. Desarrollar pantalla Home con grid/listado, filtros por categoría/precio, y búsqueda básica.
6. Implementar paginación/lazy loading con `FirestoreQueryBuilder` o cursor manual.
7. Crear pantalla `ProductDetail` con galería, especificaciones y botón "Agregar al carrito".

### 🔹 Fase 5: Carrito de Compras y Checkout
1. Implementar `CartProvider`:
   - Estado local sincronizado con Firestore (por usuario autenticado).
   - Métodos: `addItem`, `removeItem`, `updateQuantity`, `clearCart`, `total`.
2. Crear modelo `CartItem` con referencia a `Product`.
3. Desarrollar pantalla `CartScreen` (lista editable, resumen, botón checkout).
4. Implementar flujo de checkout simulado inicialmente:
   - Validar stock
   - Generar `Order` con estado `pending`
   - Guardar en colección `orders`
5. Preparar hooks para integración futura con pasarela de pago (MercadoPago, Stripe, etc.).

### 🔹 Fase 6: Perfil de Usuario y Gestión
1. Crear `ProfileProvider` para datos de usuario y direcciones.
2. Pantalla `ProfileScreen`: editar perfil, ver historial de pedidos, cerrar sesión.
3. Listado de órdenes con estados: `pending`, `paid`, `shipped`, `delivered`, `cancelled`.
4. Implementar funcionalidad de "Eliminar cuenta" (cumplimiento GDPR/LOPD).
5. Sincronizar cambios locales con Firestore.

### 🔹 Fase 7: Optimización, Pruebas y Despliegue
1. **Testing:**
   - Unit tests para providers y servicios
   - Widget tests para componentes críticos
   - Manual QA en Android, iOS y Web
2. **Optimización:**
   - Cacheo de imágenes y datos estáticos
   - Reducir rebuilds innecesarios (`const`, `Selector`, `Consumer` selectivo)
   - Indexar campos de Firestore usados en queries/filtros
3. **Calidad de código:**
   - `flutter analyze`, `dart format`
   - Revisión de reglas de seguridad Firebase
   - Configurar `firebase_crashlytics` y `firebase_analytics`
4. **Build y Publicación:**
   - `flutter build apk` / `appbundle` / `ipa` / `web`
   - Configurar signing keys, assets, permisos
   - Publicar en Google Play Console y App Store Connect
   - Desplegar versión web en Firebase Hosting o Vercel
5. **Mantenimiento:**
   - Versionado semántico
   - Pipeline CI/CD (opcional)
   - Backups automatizados de Firestore
   - Canal de feedback y monitoreo de crashes

---

## ✅ Checklist de Validación Pre-Código

- [ ] Entorno Flutter + VS Code listo y actualizado
- [ ] Proyecto Firebase creado y apps registradas
- [ ] Estructura de carpetas definida
- [ ] `pubspec.yaml` con dependencias necesarias
- [ ] Prototipos UI/UX aprobados
- [ ] Reglas de seguridad Firestore redactadas
- [ ] Plan de navegación y estado documentado
- [ ] Estrategia de testing definida

---

## 📌 Notas y Buenas Prácticas

- **No hardcodear** claves o rutas sensibles; usar variables de entorno si es necesario.
- Separar **lógica de negocio** de la capa de UI.
- Usar `const` y `final` para optimizar rendimiento.
- Manejar errores de red y Firebase con estados claros (`loading`, `error`, `retry`).
- Validar datos antes de enviarlos a Firestore.
- Documentar flujos críticos y decisiones de arquitectura.
- Cumplir normativas de privacidad y tratamiento de datos personales.

---

✅ **Siguiente paso:** Una vez aprobado este plan, puedo proceder a generar el código por fases (estructura base → autenticación → catálogo → carrito → despliegue), con explicaciones detalladas y snippets listos para VS Code.  
¿Deseas que comencemos con la **Fase 1 y 2** (configuración + UI base) o ajustar algún punto del plan antes?

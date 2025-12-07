# Mapeo: Documentación APIs ↔ Documento de Requerimientos

Este documento relaciona cada parte de la documentación oficial de las APIs con las secciones correspondientes del documento `analisis-requerimientos.md`.

---

## 📑 Tabla de Contenidos

1. [Google OAuth 2.0 API](#1-google-oauth-20-api)
2. [Google Drive API](#2-google-drive-api)
3. [MercadoLibre API](#3-mercadolibre-api)
4. [MercadoPago API](#4-mercadopago-api)

---

## 1. Google OAuth 2.0 API

### 🎯 Propósito en el proyecto
Autenticación de usuarios (clientes y administradores) mediante cuentas de Google.

### 📖 Documentación Oficial

#### Recurso Principal
- **[Using OAuth 2.0 to Access Google APIs](https://developers.google.com/identity/protocols/oauth2)**
  - Overview general del protocolo OAuth 2.0

#### Recurso Específico para Web
- **[Using OAuth 2.0 for Web Server Applications](https://developers.google.com/identity/protocols/oauth2/web-server)**
  - Flujo completo de autenticación para aplicaciones web server-side
  - Manejo de tokens (access token, refresh token)
  - Implementaciones en Java, Python, Node.js, etc.

#### OpenID Connect
- **[OpenID Connect](https://developers.google.com/identity/openid-connect/openid-connect)**
  - Obtención de datos del usuario (email, nombre, foto)

#### Configuración
- **[Setting up OAuth 2.0](https://support.google.com/googleapi/answer/6158849?hl=en)**
  - Cómo crear credenciales en Google Cloud Console
  - Configurar Consent Screen
  - Redirect URIs

---

### 🔗 Relación con Requerimientos

| Sección en `analisis-requerimientos.md` | Documentación API Correspondiente |
|------------------------------------------|-----------------------------------|
| **RF-07: Autenticación con Google OAuth** (líneas 154-176) | [OAuth 2.0 for Web Server Applications](https://developers.google.com/identity/protocols/oauth2/web-server) - **Pasos 1-6** del flujo OAuth |
| **Flujo de Autenticación** (líneas 166-176) | [OAuth 2.0 Web Server](https://developers.google.com/identity/protocols/oauth2/web-server) - Secciones: <br>• **Step 1**: Set authorization parameters<br>• **Step 2**: Redirect to Google OAuth<br>• **Step 4**: Handle server response<br>• **Step 5**: Exchange code for tokens |
| **Datos obtenidos de Google** (líneas 699-703) | [OpenID Connect](https://developers.google.com/identity/openid-connect/openid-connect) - **id_token** decodification |
| **Tabla: users** (líneas 258-270) | [OpenID Connect](https://developers.google.com/identity/openid-connect/openid-connect) - Claims: `sub` (google_id), `email`, `name`, `picture` |
| **8.1 Google OAuth 2.0 (Autenticación)** (líneas 660-703) | [OAuth 2.0 Web Server](https://developers.google.com/identity/protocols/oauth2/web-server) - Todo el flujo completo |
| **Configuración necesaria** (líneas 662-667) | [Setting up OAuth 2.0](https://support.google.com/googleapi/answer/6158849) |
| **Flujo de autenticación - Paso 2** (líneas 670-678) | [OAuth 2.0 Web Server - Authorization endpoint](https://developers.google.com/identity/protocols/oauth2/web-server#httprest) - URL: `https://accounts.google.com/o/oauth2/v2/auth` |
| **Flujo de autenticación - Paso 5** (líneas 681-691) | [OAuth 2.0 Web Server - Token endpoint](https://developers.google.com/identity/protocols/oauth2/web-server#exchange-authorization-code) - URL: `https://oauth2.googleapis.com/token` |
| **Variables de entorno** (líneas 1015-1018) | [OAuth 2.0 Credentials](https://developers.google.com/identity/protocols/oauth2/web-server#prerequisites) |
| **Endpoints API - Autenticación** (líneas 962-968) | [OAuth 2.0 Web Server](https://developers.google.com/identity/protocols/oauth2/web-server) - Implementación completa |
| **CU-02: Compra en Página Web - Pasos 6-11** (líneas 447-457) | [OAuth 2.0 Web Server - Steps 1-6](https://developers.google.com/identity/protocols/oauth2/web-server#creatingclient) |
| **Interfaz: Pantalla Login/Registro** (líneas 530-538) | [OpenID Connect - User Info](https://developers.google.com/identity/openid-connect/openid-connect) |

---

## 2. Google Drive API

### 🎯 Propósito en el proyecto
- Almacenar archivos de modelos 3D (.stl, .obj, .fbx)
- Compartir archivos automáticamente con clientes tras compra

### 📖 Documentación Oficial

#### Recurso Principal
- **[Google Drive API Overview](https://developers.google.com/workspace/drive/api/guides/about-sdk)**
  - Introducción general a la API

#### Gestión de Permisos y Compartir
- **[Share files, folders, and drives](https://developers.google.com/workspace/drive/api/guides/manage-sharing)**
  - Cómo compartir archivos con usuarios específicos
  - Tipos de permisos: `reader`, `writer`, `owner`
  - Endpoint: `POST /drive/v3/files/{fileId}/permissions`

#### Referencia de Permisos
- **[REST Resource: permissions](https://developers.google.com/workspace/drive/api/reference/rest/v3/permissions)**
  - Campos: `type`, `role`, `emailAddress`
  - Métodos: `create`, `list`, `update`, `delete`

- **[Roles and permissions](https://developers.google.com/workspace/drive/api/guides/ref-roles)**
  - Definición de roles disponibles

#### Subir Archivos
- **[Upload file data](https://developers.google.com/workspace/drive/api/guides/manage-uploads)**
  - Métodos: simple upload, multipart upload, resumable upload

---

### 🔗 Relación con Requerimientos

| Sección en `analisis-requerimientos.md` | Documentación API Correspondiente |
|------------------------------------------|-----------------------------------|
| **RF-01: Gestión de Modelos 3D - Paso 4** (línea 51) | [Upload file data](https://developers.google.com/workspace/drive/api/guides/manage-uploads) - **Resumable upload** para archivos grandes |
| **RF-01: Paso 5** (línea 52) | [Files: create](https://developers.google.com/workspace/drive/api/reference/rest/v3/files/create) - Response contiene `id` del archivo |
| **RF-05: Entrega Automática vía Google Drive** (líneas 114-138) | [Share files](https://developers.google.com/workspace/drive/api/guides/manage-sharing) - **Creating permissions** |
| **RF-05: Paso 3** (líneas 124-127) | [permissions.create](https://developers.google.com/workspace/drive/api/reference/rest/v3/permissions/create) - Parámetros: `type="user"`, `role="reader"`, `emailAddress` |
| **Tabla: products - Campo google_drive_file_id** (línea 217) | [Files resource](https://developers.google.com/workspace/drive/api/reference/rest/v3/files) - Campo `id` en response |
| **8.2 Google Drive API** (líneas 706-749) | [Drive API Overview](https://developers.google.com/workspace/drive/api/guides/about-sdk) |
| **Configuración necesaria** (líneas 708-712) | [Enable the Drive API](https://developers.google.com/workspace/drive/api/quickstart) |
| **2. Subir archivo del modelo 3D** (líneas 718-734) | [Files: create](https://developers.google.com/workspace/drive/api/reference/rest/v3/files/create) - Multipart upload |
| **3. Compartir archivo** (líneas 736-749) | [permissions.create](https://developers.google.com/workspace/drive/api/reference/rest/v3/permissions/create) - Ejemplo exacto |
| **Variables de entorno** (líneas 1020-1024) | [Drive API - Authentication](https://developers.google.com/workspace/drive/api/guides/about-auth) |
| **CU-02: Compra en Página Web - Pasos 19-20** (líneas 475-479) | [Share files - Create permission](https://developers.google.com/workspace/drive/api/guides/manage-sharing#create_a_permission) |
| **Diagrama 2: Compra en Página Web - Paso 11** (líneas 939-943) | [permissions.create API](https://developers.google.com/workspace/drive/api/reference/rest/v3/permissions/create) |

---

## 3. MercadoLibre API

### 🎯 Propósito en el proyecto
- Publicar productos automáticamente en MercadoLibre
- Recibir notificaciones de ventas vía webhooks

### 📖 Documentación Oficial

#### Recursos Principales
- **[Items & Searches](https://developers.mercadolibre.com.ar/en_us/items-and-searches)**
  - Búsqueda de items
  - Obtener información de productos
  - Multiget function

- **[Publicar productos](https://developers.mercadolibre.cl/es_ar/publica-productos)**
  - Cómo crear publicaciones
  - Estructura de datos
  - Categorías y atributos

- **[Publicación en catálogo](https://developers.mercadolibre.com.ar/es_ar/publicacion-en-catalogo)**
  - Métodos de publicación: directa, opt-in, auto-optin
  - Nuevo método: User Products

#### Autenticación
- **[Authentication and authorization](https://developers.mercadolibre.com.ar/en_us/authentication-and-authorization)**
  - OAuth 2.0 flow
  - Access tokens y refresh tokens

#### Notificaciones
- **[Notifications](https://developers.mercadolibre.com.ar/en_us/notifications)**
  - Webhooks para ventas, preguntas, mensajes
  - Estructura de payloads

#### API Reference
- **[API Docs](https://developers.mercadolibre.com.ar/en_us/api-docs)**
  - Endpoints completos
  - Métodos HTTP
  - Ejemplos de requests/responses

---

### 🔗 Relación con Requerimientos

| Sección en `analisis-requerimientos.md` | Documentación API Correspondiente |
|------------------------------------------|-----------------------------------|
| **RF-03: Publicación en MercadoLibre** (líneas 70-86) | [Publicar productos](https://developers.mercadolibre.cl/es_ar/publica-productos) - Overview completo |
| **RF-03: Datos a sincronizar** (líneas 75-81) | [Items API - POST /items](https://developers.mercadolibre.com.ar/en_us/items-and-searches) - Request body structure |
| **RF-03: Consideraciones** (líneas 83-86) | [Authentication OAuth](https://developers.mercadolibre.com.ar/en_us/authentication-and-authorization) + [Notifications](https://developers.mercadolibre.com.ar/en_us/notifications) |
| **RF-04: Flujo de Compra (MercadoLibre)** (líneas 107-112) | [Notifications - Webhooks](https://developers.mercadolibre.com.ar/en_us/notifications) - Order notifications |
| **8.2 MercadoLibre API** (líneas 751-795) | [API Docs](https://developers.mercadolibre.com.ar/en_us/api-docs) |
| **Configuración necesaria** (líneas 753-757) | [Create your app](https://developers.mercadolibre.com.ar/en_us/register-your-app) |
| **1. Autenticación OAuth** (líneas 760-764) | [Authentication OAuth 2.0](https://developers.mercadolibre.com.ar/en_us/authentication-and-authorization) |
| **2. Publicar producto** (líneas 766-783) | [Items API - POST /items](https://developers.mercadolibre.com.ar/en_us/items-and-searches) - Ejemplo de creación |
| **2. Publicar producto - Estructura JSON** (líneas 767-783) | [Items API Reference](https://developers.mercadolibre.com.ar/en_us/api-docs) - Campos: `title`, `category_id`, `price`, `currency_id`, `available_quantity`, `buying_mode`, `listing_type_id`, `condition`, `description`, `pictures` |
| **3. Webhook de notificaciones** (líneas 785-791) | [Notifications](https://developers.mercadolibre.com.ar/en_us/notifications) - Configurar URL webhook |
| **Variables de entorno** (líneas 1026-1031) | [Authentication](https://developers.mercadolibre.com.ar/en_us/authentication-and-authorization) |
| **Endpoints API - POST /api/webhooks/mercadolibre** (línea 993) | [Notifications - Webhook structure](https://developers.mercadolibre.com.ar/en_us/notifications) |
| **CU-01: Publicar Producto - Paso 8** (líneas 414-417) | [Items API - POST /items](https://developers.mercadolibre.com.ar/en_us/items-and-searches) |
| **CU-03: Compra en MercadoLibre** (líneas 491-522) | [Notifications - Orders](https://developers.mercadolibre.com.ar/en_us/notifications) |
| **Diagrama 1: Publicar Producto - Pasos 5-7** (líneas 866-879) | [Items API - POST /items](https://developers.mercadolibre.com.ar/en_us/items-and-searches) |

---

## 4. MercadoPago API

### 🎯 Propósito en el proyecto
Procesar pagos de productos en la página web propia.

### 📖 Documentación Oficial

#### Recurso Principal
- **[Checkout API Overview](https://www.mercadopago.com.ar/developers/en/docs/checkout-api/overview)**
  - Flujo de integración
  - Métodos de pago soportados
  - Customización del checkout

#### Checkout API v2
- **[Checkout API v2](https://www.mercadopago.com.ar/developers/en/docs/checkout-api-v2/overview)**
  - Nueva versión de la API

#### Nueva API: Orders (2025)
- **[Orders API](https://www.mercadopago.com.mx/developers/en/news/2025/10/10/The-API-that-will-transform-the-way-you-process-payments-with-Checkout-API-has-arrived)**
  - API moderna que simplifica múltiples integraciones
  - Reemplaza necesidad de múltiples APIs

#### Preferencias de Pago
- **[Payment Preferences](https://www.mercadopago.com.ar/developers/en/docs/checkout-api/payment-methods)**
  - Crear preferencias
  - Configurar items, payer, URLs de retorno

#### Notificaciones
- **[Webhooks & IPN](https://www.mercadopago.com.ar/developers/en/docs/checkout-api/additional-content/your-integrations/notifications/webhooks)**
  - Configurar webhooks
  - Recibir notificaciones de pagos

#### API Reference
- **[Postman Documentation](https://documenter.getpostman.com/view/15366798/2sAXjKasp4)**
  - Endpoints completos
  - Ejemplos de requests

---

### 🔗 Relación con Requerimientos

| Sección en `analisis-requerimientos.md` | Documentación API Correspondiente |
|------------------------------------------|-----------------------------------|
| **RF-04: Procesamiento de Compras - Flujo Web** (líneas 91-106) | [Checkout API Overview](https://www.mercadopago.com.ar/developers/en/docs/checkout-api/overview) - Integration flow |
| **RF-04: Paso 4** (línea 102) | [Checkout API - Preferences](https://www.mercadopago.com.ar/developers/en/docs/checkout-api/payment-methods) - Crear preferencia de pago |
| **RF-04: Paso 6** (línea 104) | [Webhooks](https://www.mercadopago.com.ar/developers/en/docs/checkout-api/additional-content/your-integrations/notifications/webhooks) - Recibir notificación de pago |
| **8.3 Pasarela de Pagos (MercadoPago)** (líneas 797-835) | [Checkout API Overview](https://www.mercadopago.com.ar/developers/en/docs/checkout-api/overview) |
| **Configuración** (líneas 799-802) | [Your Integrations](https://www.mercadopago.com.ar/developers/panel) - Crear aplicación |
| **Flujo de pago - Paso 4** (líneas 808-829) | [Preferences API](https://www.mercadopago.com.ar/developers/en/reference/preferences/_checkout_preferences/post) - POST /checkout/preferences |
| **Flujo de pago - Estructura JSON** (líneas 810-828) | [Preferences API Reference](https://www.mercadopago.com.ar/developers/en/reference/preferences/_checkout_preferences/post) - Campos: `items`, `payer`, `back_urls`, `notification_url` |
| **Flujo de pago - Paso 6** (línea 833) | [Webhooks](https://www.mercadopago.com.ar/developers/en/docs/checkout-api/additional-content/your-integrations/notifications/webhooks) |
| **Variables de entorno** (líneas 1033-1035) | [Credentials](https://www.mercadopago.com.ar/developers/panel/app) |
| **Endpoints API - POST /api/checkout** (línea 984) | [Preferences API](https://www.mercadopago.com.ar/developers/en/reference/preferences/_checkout_preferences/post) |
| **Endpoints API - POST /api/webhooks/mercadopago** (línea 992) | [Webhooks](https://www.mercadopago.com.ar/developers/en/docs/checkout-api/additional-content/your-integrations/notifications/webhooks) |
| **CU-02: Compra en Página Web - Pasos 14-16** (líneas 460-466) | [Preferences API + Webhooks](https://www.mercadopago.com.ar/developers/en/docs/checkout-api/overview) |
| **Diagrama 2: Compra en Página Web - Pasos 4-9** (líneas 909-931) | [Checkout API Flow](https://www.mercadopago.com.ar/developers/en/docs/checkout-api/overview) |

---

## 📊 Resumen de URLs Principales por API

### Google OAuth 2.0
| Documentación | URL |
|---------------|-----|
| Overview | https://developers.google.com/identity/protocols/oauth2 |
| Web Server Apps | https://developers.google.com/identity/protocols/oauth2/web-server |
| OpenID Connect | https://developers.google.com/identity/openid-connect/openid-connect |
| Setup | https://support.google.com/googleapi/answer/6158849 |

### Google Drive
| Documentación | URL |
|---------------|-----|
| Overview | https://developers.google.com/workspace/drive/api/guides/about-sdk |
| Share files | https://developers.google.com/workspace/drive/api/guides/manage-sharing |
| Permissions API | https://developers.google.com/workspace/drive/api/reference/rest/v3/permissions |
| Roles | https://developers.google.com/workspace/drive/api/guides/ref-roles |

### MercadoLibre
| Documentación | URL |
|---------------|-----|
| Items & Searches | https://developers.mercadolibre.com.ar/en_us/items-and-searches |
| Publicar productos | https://developers.mercadolibre.cl/es_ar/publica-productos |
| Authentication | https://developers.mercadolibre.com.ar/en_us/authentication-and-authorization |
| Notifications | https://developers.mercadolibre.com.ar/en_us/notifications |
| API Docs | https://developers.mercadolibre.com.ar/en_us/api-docs |

### MercadoPago
| Documentación | URL |
|---------------|-----|
| Checkout API | https://www.mercadopago.com.ar/developers/en/docs/checkout-api/overview |
| Checkout API v2 | https://www.mercadopago.com.ar/developers/en/docs/checkout-api-v2/overview |
| Preferences API | https://www.mercadopago.com.ar/developers/en/reference/preferences/_checkout_preferences/post |
| Webhooks | https://www.mercadopago.com.ar/developers/en/docs/checkout-api/additional-content/your-integrations/notifications/webhooks |
| Postman Docs | https://documenter.getpostman.com/view/15366798/2sAXjKasp4 |

---

## 🎓 Guía de Lectura Recomendada

### Para implementar autenticación (RF-07):
1. Lee [OAuth 2.0 for Web Server Applications](https://developers.google.com/identity/protocols/oauth2/web-server)
2. Sigue el paso a paso de los 6 pasos del flujo OAuth
3. Implementa según el ejemplo de Java/Spring Boot
4. Consulta [OpenID Connect](https://developers.google.com/identity/openid-connect/openid-connect) para obtener datos del usuario

### Para implementar carga y compartir archivos (RF-01, RF-05):
1. Lee [Google Drive API Overview](https://developers.google.com/workspace/drive/api/guides/about-sdk)
2. Implementa upload con [Upload file data](https://developers.google.com/workspace/drive/api/guides/manage-uploads)
3. Implementa sharing con [Share files](https://developers.google.com/workspace/drive/api/guides/manage-sharing)
4. Usa [permissions.create](https://developers.google.com/workspace/drive/api/reference/rest/v3/permissions/create)

### Para publicar en MercadoLibre (RF-03):
1. Lee [Publicar productos](https://developers.mercadolibre.cl/es_ar/publica-productos)
2. Implementa OAuth según [Authentication](https://developers.mercadolibre.com.ar/en_us/authentication-and-authorization)
3. Usa [Items API](https://developers.mercadolibre.com.ar/en_us/items-and-searches) para POST /items
4. Configura [Webhooks](https://developers.mercadolibre.com.ar/en_us/notifications)

### Para procesar pagos (RF-04):
1. Lee [Checkout API Overview](https://www.mercadopago.com.ar/developers/en/docs/checkout-api/overview)
2. Implementa creación de preferencias con [Preferences API](https://www.mercadopago.com.ar/developers/en/reference/preferences/_checkout_preferences/post)
3. Configura [Webhooks](https://www.mercadopago.com.ar/developers/en/docs/checkout-api/additional-content/your-integrations/notifications/webhooks)

---

**Última actualización:** 2025-12-05
**Generado automáticamente** a partir del análisis de las APIs oficiales

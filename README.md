# Factura

El ecosistema envía recordatorios de pago por correo y avanza el estado de cada factura solo cuando el correo sale bien. Lo forman tres aplicaciones conectadas: una Web API en .NET 8, una aplicación web en React y una app móvil en Flutter. Todo se levanta con un solo comando de Docker Compose.

Repositorio: https://github.com/CamiloArias12/bill

## Requisito resuelto

1. Conectarse a MongoDB y leer las facturas de cada cliente.
2. Para cada factura en `primerrecordatorio` o `segundorecordatorio`, enviar un correo al cliente:
   - `primerrecordatorio` → se le informa que la factura pasó a segundo recordatorio.
   - `segundorecordatorio` → se le informa que la factura va a ser desactivada.
3. Solo si el correo se envió, actualizar el estado a `segundorecordatorio` o `desactivado`.
4. El proceso funciona para 3 clientes, que se crean automáticamente al iniciar, y la web muestra un resumen de todas las facturas.

## Tecnologías

| Proyecto | Tecnología | Función |
|---|---|---|
| `api/BillApi` | .NET 8, MongoDB, MailKit | Lógica de negocio, persistencia y envío de correos |
| `api/BillApi.Tests` | xUnit, Moq | Pruebas unitarias |
| `web` | React, TypeScript, Vite, Tailwind | Resumen de facturas y ejecución del proceso |
| `bill_app` | Flutter, BLoC, GetIt, Dio | App móvil: resumen, detalle y envío de recordatorios |

## Estructura y arquitectura

El repositorio es un monorepo con tres carpetas: `api`, `web` y `bill_app`, más un `compose.yml` en la raíz que levanta todo. La API usa una arquitectura por capas: cada capa depende de interfaces y las dependencias apuntan hacia el dominio.

```mermaid
flowchart LR
    Web["Web (React)"]
    App["App (Flutter)"]
    Ctrl["Api/Controllers"]
    Appl["Application (Services, Interfaces)"]
    Dom["Domain (Bill, Client, BillStatus)"]
    Persist["Persistence (Repositorios)"]
    Infra["Infrastructure (EmailService)"]
    Mongo[("MongoDB")]
    SMTP["SMTP"]
    Web --> Ctrl
    App --> Ctrl
    Ctrl --> Appl
    Appl --> Dom
    Appl --> Persist
    Appl --> Infra
    Persist --> Mongo
    Infra --> SMTP
```

La capa Application define las interfaces (puertos); Persistence e Infrastructure las implementan y se registran en `Extensions/DependencyInjection.cs` con `AddPersistence`, `AddInfrastructure` y `AddApplication`. La configuración (`MongoSettings`, `SmtpConfig`) se inyecta con `IOptions<T>`.

**Decisiones de diseño**

- **Transiciones en el dominio**: `BillStatus` conoce su valor en base de datos y su siguiente estado. Agregar un estado no obliga a cambiar el servicio.
- **Estados sin distinguir mayúsculas**: se acepta `primerrecordatorio` y `primerRecordatorio`; al actualizar se guarda en minúsculas, como pide el requisito.
- **Responsabilidad única**: `BillReminderService` orquesta, `ReminderEmailBuilder` arma el mensaje y `EmailService` solo envía por SMTP.
- **Genéricos**: `Repository<T>` y `Service<T>` concentran las operaciones comunes de Client y Bill.

## Web API: endpoints

La API expone cinco endpoints. Swagger está en la raíz: `http://localhost:5080`.

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/client` | Lista de clientes |
| GET | `/api/bill` | Lista de todas las facturas |
| GET | `/api/bill/client/{clientId}` | Facturas de un cliente |
| POST | `/api/bill/status` | Ejecuta el proceso de recordatorios para todos los clientes |
| POST | `/api/bill/status/{clientId}` | Ejecuta el proceso para un cliente; 404 si el cliente no existe |

Ejemplo de una factura en `GET /api/bill`:

```json
{
  "billCode": "P-00001",
  "billTotal": 11650,
  "subtotal": 10000,
  "vat": 1900,
  "withholding": 250,
  "creationDate": "2026-10-19T13:24:56.853Z",
  "status": "primerrecordatorio",
  "city": "Bogota",
  "isPaid": false,
  "paymentDate": null,
  "clientId": "6ada0ea85822be0249b61b55",
  "id": "6ada0ea85822be0249b61b56"
}
```

Ejemplo de respuesta de `POST /api/bill/status/{clientId}`. Antes la API devolvía solo `true`; ahora informa qué facturas cambiaron y cuáles fallaron:

```json
{
  "clientId": "6ada0ea85822be0249b61b55",
  "clientName": "Prueba desarrollo 1",
  "updated": [
    { "billCode": "P-00001", "previousStatus": "primerrecordatorio", "newStatus": "segundorecordatorio" },
    { "billCode": "P-00002", "previousStatus": "segundorecordatorio", "newStatus": "desactivado" }
  ],
  "failedBillCodes": []
}
```

`POST /api/bill/status` devuelve una lista con un objeto así por cada cliente.

## Proceso de recordatorios

Cada vez que se ejecuta el proceso, una factura avanza un solo paso y solo si el correo al cliente se envió. Si el envío falla, la factura queda igual y el proceso sigue con las demás.

```mermaid
flowchart LR
    A["primerrecordatorio"] -->|correo enviado| B["segundorecordatorio"]
    B["segundorecordatorio"] -->|correo enviado| C["desactivado"]
```

1. La web o la app llaman a `POST /api/bill/status` (todos los clientes) o a `POST /api/bill/status/{clientId}`.
2. `BillReminderService` lee las facturas de cada cliente en MongoDB.
3. Para cada factura en recordatorio, `BillStatus` calcula el siguiente estado y `ReminderEmailBuilder` arma el correo.
4. `EmailService` lo envía por SMTP. Si sale bien, se actualiza el estado; si no, se agrega a `failedBillCodes`.
5. La respuesta lista, por cliente, las facturas actualizadas y las fallidas.

| Estado actual | Correo al cliente | Nuevo estado |
|---|---|---|
| `primerrecordatorio` | "Su factura P-00001 ha pasado a segundo recordatorio. Le invitamos a realizar el pago lo antes posible." | `segundorecordatorio` |
| `segundorecordatorio` | "Su factura P-00002 se encontraba en segundo recordatorio y va a ser desactivada." | `desactivado` |

El asunto del correo es `Factura <código>: <nuevo estado>` y el saludo usa el nombre del cliente.

## Aplicaciones web y móvil

Las dos aplicaciones muestran el mismo resumen y pueden lanzar el proceso de recordatorios.

| Funcionalidad | Web (React) | Móvil (Flutter) |
|---|---|---|
| Resumen | Tarjetas con total de facturas, valor total y cantidad por estado | Tarjetas por estado; al tocarlas filtran la lista |
| Filtro | Por cliente | Por cliente y búsqueda por código o ciudad |
| Detalle | Tabla con todas las columnas de la factura | Una tarjeta por factura y hoja inferior con el detalle |
| Estado | Etiqueta de color por estado | Etiqueta de color por estado |
| Enviar recordatorios | Botón para el cliente seleccionado o para todos; muestra facturas actualizadas y fallidas | Igual, con el resultado en una hoja inferior |

**Web.** React 19 con TypeScript, Vite y Tailwind. Componentes principales: `BillSummary`, `BillTable`, `StatusBadge` y `ReminderResults`. En Docker se compila y se sirve con Nginx.

**Móvil.** Flutter con clean architecture y estas librerías:

- **flutter_bloc**: maneja estados y eventos de la pantalla de facturas y clientes.
- **get_it**: inyección de dependencias para servicios y blocs.
- **dio**: cliente HTTP hacia la API.

Widgets principales: `BillSummary`, `BillCard`, `BillDetailSheet`, `StatusBadge` y `ReminderResultsSheet`. La app incluye 4 pruebas (1 del modelo y 3 de widget) en `test/bill_page_test.dart`.

## Cómo ejecutar

Con Docker basta un comando; no hace falta instalar .NET, Node ni MongoDB.

### Opción recomendada: Docker Compose

```bash
docker compose up -d --build
```

| Servicio | URL |
|---|---|
| Web | http://localhost:5173 |
| API (Swagger) | http://localhost:5080 |
| MongoDB | `mongodb://bill:123456@localhost:27017` |

- Al iniciar, la API crea 3 clientes con 3 facturas cada uno (2 en `primerrecordatorio` y 1 en `segundorecordatorio`) si la base está vacía.
- Los correos se envían por el SMTP real configurado en el `.env` de la raíz.
- Para usar un SMTP real, crear un `.env` en la raíz con `SMTP_HOST`, `SMTP_PORT`, `SMTP_USERNAME` y `SMTP_PASSWORD` (hay un ejemplo en `.env.example`).
- Si la API se publica en otra URL, definir `VITE_API_URL` y reconstruir la imagen web.
- Apagar: `docker compose down`. Borrar también los datos: `docker compose down -v`.

### Sin Docker

1. **Base de datos**: `docker compose up -d db`, o cualquier MongoDB.
2. **Correo**: configurar `EmailConfiguration` en `api/BillApi/appsettings.json` o, mejor, con user-secrets para no versionar credenciales:

```bash
cd api/BillApi
dotnet user-secrets set "EmailConfiguration:Host" "smtp.gmail.com"
dotnet user-secrets set "EmailConfiguration:Port" "465"
dotnet user-secrets set "EmailConfiguration:Username" "correo@gmail.com"
dotnet user-secrets set "EmailConfiguration:Password" "<app password>"
```

3. **API**: abrir `api/BillApi.sln` en Visual Studio, o `cd api/BillApi && dotnet run --launch-profile http`.
4. **Web**: `cd web && yarn install && yarn dev`, con `VITE_API_URL` en `web/.env`.
5. **Móvil**: la URL de la API se configura en `bill_app/lib/config/.env`.

```bash
cd bill_app
flutter pub get
# La URL de la API se configura en lib/config/.env (API_URL)
# Emulador Android: 10.0.2.2 es el localhost del computador; dispositivo físico: la IP en la red local
flutter run
```

### Pruebas

| Proyecto | Comando | Resultado | Qué cubre |
|---|---|---|---|
| API | `cd api && dotnet test` | 28 pruebas, todas pasan | Transiciones de estado, correo correcto según el estado, que el estado no cambie si el correo falla, proceso de los 3 clientes y controladores |
| Móvil | `cd bill_app && flutter test` | 4 pruebas, todas pasan; `flutter analyze` sin problemas | Lectura del modelo `Bill` (enteros, nulos y estados en camelCase), resumen y lista, envío de recordatorios con su resultado y filtro por cliente |
| Web | `cd web && yarn build && yarn lint` | Compila sin errores de TypeScript ni ESLint | Tipos y estilo del código |

Sin .NET instalado, las pruebas de la API corren con Docker: `docker run --rm -v "$PWD/api":/src -w /src mcr.microsoft.com/dotnet/sdk:8.0 dotnet test`.

### Validación de punta a punta

Todo se verificó el 22 de octubre de 2026 sobre el stack de Docker Compose:

- Los servicios (Mongo, API y web) arrancan; Swagger y la web responden 200, y la API permite CORS para la web.
- `POST /api/bill/status/{clientId}` avanzó las 3 facturas del cliente y se enviaron 3 correos por SMTP real (Zoho) con el asunto y el texto esperados.
- `POST /api/bill/status` procesó los 3 clientes, y un cliente inexistente devuelve 404.
- Con el SMTP apagado, las facturas quedaron en `failedBillCodes` y su estado no cambió; las desactivadas no se procesan.
- La app móvil corrió en el emulador Pixel 8 (Android, API 36) leyendo `API_URL` desde su `.env` (flutter_dotenv) y cargó las 9 facturas.

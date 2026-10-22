# Factura

Ecosistema de aplicaciones para la gestión de clientes, facturas y recordatorios de pago.

## Requisito resuelto

1. Conectarse a MongoDB y leer las facturas de cada cliente.
2. Para cada factura en estado `primerrecordatorio` o `segundorecordatorio`, enviar un correo al cliente:
   - `primerrecordatorio` → se le informa que la factura **pasó a segundo recordatorio**.
   - `segundorecordatorio` → se le informa que la factura **va a ser desactivada**.
3. Solo si el correo se envió correctamente, actualizar el estado a `segundorecordatorio` o `desactivado`.
4. El proceso funciona para 3 clientes (se crean automáticamente al iniciar) y la interfaz web muestra un resumen de todas las facturas.

## Tecnologías

| Proyecto | Tecnología | Descripción |
|---|---|---|
| `api/` | .NET 8 Web API (C#), MongoDB, MailKit | Lógica de negocio, persistencia y envío de correos |
| `api/BillApi.Tests` | xUnit + Moq | Pruebas unitarias |
| `web/` | React + TypeScript + Vite + Tailwind | Resumen de facturas y ejecución del proceso |
| `bill_app/` | Flutter (BLoC + GetIt) | App móvil: resumen, detalle y envío de recordatorios |

## Arquitectura

La API sigue una arquitectura por capas. Las dependencias apuntan hacia el dominio y cada capa depende de interfaces, no de implementaciones.

```
api/BillApi
├── Api/Controllers        → Endpoints HTTP (BillController, ClientController)
├── Application            → Casos de uso
│   ├── Services           → BillReminderService (proceso de recordatorios), BillService, ClientService
│   ├── Interfaces         → Puertos: IEmailService, IReminderEmailBuilder
│   └── Common/Dto         → EmailMessageDto, ReminderResultDto
├── Domain                 → Entidades (Bill, Client) y BillStatus con sus transiciones
├── Infrastructure/Email   → EmailService (SMTP con MailKit)
├── Persistence            → Repositorios MongoDB y DatabaseSeeder
└── Extensions             → DependencyInjection: registro de servicios por capa
```

### Flujo del proceso de recordatorios

```mermaid
sequenceDiagram
    participant UI as Web (React)
    participant C as BillController
    participant S as BillReminderService
    participant R as Repositorios (MongoDB)
    participant E as EmailService (SMTP)

    UI->>C: POST /api/bill/status[/{clientId}]
    C->>S: ProcessAllClients() / ProcessClient(id)
    S->>R: Clientes y facturas del cliente
    loop Cada factura en recordatorio
        S->>S: BillStatus.NextReminderStatus()
        S->>E: Enviar correo según el nuevo estado
        alt correo enviado
            S->>R: UpdateStatus(nuevo estado)
        else falla el envío
            S->>S: Se reporta en failedBillCodes (el estado no cambia)
        end
    end
    S-->>UI: Resultado por cliente (actualizadas / fallidas)
```

### Decisiones de diseño

- **Transiciones en el dominio** (`Domain/Enums/BillStatus.cs`): el enum `BillStatus` conoce su valor en base de datos y su siguiente estado. Agregar un estado nuevo no obliga a cambiar el servicio (abierto/cerrado).
- **Estados sin distinguir mayúsculas**: se acepta `primerrecordatorio` y `primerRecordatorio`. Al actualizar se guarda en minúsculas, como indica el requisito.
- **Responsabilidad única**: `BillReminderService` orquesta el proceso, `ReminderEmailBuilder` arma el mensaje y `EmailService` solo envía por SMTP.
- **Inversión de dependencias**: la capa de aplicación define `IEmailService`, la infraestructura la implementa. Los repositorios se exponen como `IBillRepository` / `IClientRepository`.
- **Inyección de dependencias**: `Extensions/DependencyInjection.cs` agrupa el registro en `AddPersistence`, `AddInfrastructure` y `AddApplication`. La configuración (`MongoSettings`, `SmtpConfig`) se inyecta con `IOptions<T>`.
- **Consistencia**: el estado se actualiza solo después de enviar el correo. Si un envío falla, las demás facturas se siguen procesando y la falla se informa en la respuesta.

## Endpoints

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/client` | Lista de clientes |
| GET | `/api/bill` | Lista de todas las facturas |
| GET | `/api/bill/client/{clientId}` | Facturas de un cliente |
| POST | `/api/bill/status` | Ejecuta el proceso de recordatorios para todos los clientes |
| POST | `/api/bill/status/{clientId}` | Ejecuta el proceso para un cliente (404 si no existe) |

Swagger está disponible en la raíz de la API (`http://localhost:5080`).

Ejemplo de respuesta de `POST /api/bill/status/{clientId}`:

```json
{
  "clientId": "6ad9e2d55b22340a71045397",
  "clientName": "Prueba desarrollo 1",
  "updated": [
    { "billCode": "P-00001", "previousStatus": "primerrecordatorio", "newStatus": "segundorecordatorio" },
    { "billCode": "P-00002", "previousStatus": "segundorecordatorio", "newStatus": "desactivado" }
  ],
  "failedBillCodes": []
}
```

## Cómo ejecutar

### Con Docker (todo el ecosistema)

```bash
docker compose up -d --build
```

| Servicio | URL |
|---|---|
| Web | http://localhost:5173 |
| API (Swagger) | http://localhost:5080 |
| MongoDB | `mongodb://bill:123456@localhost:27017` |
| Mailpit (correos de prueba) | http://localhost:8025 |

Por defecto la API envía los correos a Mailpit. Para usar un SMTP real, cree un archivo `.env` en la raíz (no se versiona) con `SMTP_HOST`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD` y `SMTP_FROM` (remitente verificado en el proveedor); hay un ejemplo en `.env.example`. Si la API se publica en otra URL, defina `VITE_API_URL` y reconstruya la imagen web (Vite la incrusta al compilar).

Para borrar los datos de MongoDB: `docker compose down -v`.

### Sin Docker

### 1. Base de datos

```bash
docker compose up -d db
```

Al iniciar, la API crea 3 clientes con 3 facturas cada uno (2 en `primerrecordatorio`, 1 en `segundorecordatorio`) si la base está vacía.

### 2. Correo (SMTP)

Configure `EmailConfiguration` en `api/BillApi/appsettings.json`, o mejor con user-secrets para no versionar credenciales:

```bash
cd api/BillApi
dotnet user-secrets init
dotnet user-secrets set "EmailConfiguration:Host" "smtp.gmail.com"
dotnet user-secrets set "EmailConfiguration:Port" "465"
dotnet user-secrets set "EmailConfiguration:Username" "correo@gmail.com"
dotnet user-secrets set "EmailConfiguration:Password" "<app password>"
```

Para pruebas locales sin enviar correos reales se puede usar [Mailpit](https://mailpit.axllent.org/):

```bash
docker run -d -p 1025:1025 -p 8025:8025 -e MP_SMTP_AUTH_ACCEPT_ANY=1 -e MP_SMTP_AUTH_ALLOW_INSECURE=1 axllent/mailpit
# Host=localhost, Port=1025, Username=facturas@test.local; los correos se ven en http://localhost:8025
```

### 3. API

Abra `api/BillApi.sln` en Visual Studio y ejecute el perfil `http`, o desde la terminal:

```bash
cd api/BillApi
dotnet run --launch-profile http   # http://localhost:5080
```

### 4. Pruebas

```bash
cd api
dotnet test
```

Las pruebas cubren las transiciones de estado, el envío del correo correcto según el estado, que no se actualice el estado si el correo falla, el procesamiento de los 3 clientes y los controladores.

### 5. Web

```bash
cd web
yarn install
yarn dev
```

La URL de la API se configura en `web/.env` (`VITE_API_URL`). La interfaz muestra:

- Tarjetas de resumen: total de facturas, valor total y cantidad por estado.
- Filtro por cliente.
- Botón **Enviar recordatorios**, que ejecuta el proceso para el cliente seleccionado o para todos, y muestra el resultado.
- Tabla con el detalle de las facturas.

### 6. App móvil (Flutter)

```bash
cd bill_app
flutter pub get
flutter test

# Emulador Android: 10.0.2.2 es el localhost del computador
flutter emulators --launch Pixel_8_API_36
flutter run --dart-define=API_URL=http://10.0.2.2:5080

# Dispositivo físico: usar la IP del computador en la red local
flutter run --dart-define=API_URL=http://192.168.x.x:5080
```

La app muestra lo mismo que la web adaptado a móvil: filtro por cliente, tarjetas de resumen por estado (al tocarlas filtran), búsqueda, una tarjeta por factura con su detalle en una hoja inferior y el botón **Enviar recordatorios** con el resultado del proceso. En builds de depuración Android se permite HTTP para poder usar la API local.

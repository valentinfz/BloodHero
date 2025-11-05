# Firestore Data Model

> Última actualización: 5 de noviembre de 2025

La aplicación BloodHero utiliza Firebase Authentication para gestionar usuarios y Cloud Firestore como base de datos principal. A continuación se documenta la estructura esperada para todas las colecciones y documentos que los repositorios Firebase consumen.

## 1. Colección `users`

```
users/{userId}
```

Cada documento representa un usuario de la aplicación y se crea inmediatamente después del registro.

Campos obligatorios:

| Campo                     | Tipo          | Descripción                                                                                       |
|---------------------------|---------------|---------------------------------------------------------------------------------------------------|
| `name`                    | `string`      | Nombre y apellido del usuario.                                                                    |
| `email`                   | `string`      | Dirección de correo del usuario.                                                                  |
| `phone`                   | `string`      | Número de teléfono de contacto.                                                                   |
| `bloodType`               | `string`      | Tipo de sangre en formato `A+`, `O-`, etc.                                                        |
| `city`                    | `string`      | Ciudad de residencia.                                                                             |
| `ranking`                 | `string`      | Descripción del ranking actual (por ejemplo: `Nuevo Donador`, `Héroe`).                           |
| `createdAt`               | `Timestamp`   | Fecha de alta.                                                                                    |
| `livesHelped`             | `number`      | (Opcional) Total de vidas ayudadas; si no existe se calcula a partir de las donaciones completadas|
| `totalDonations`          | `number`      | (Opcional) Cantidad total de donaciones realizadas.                                               |

### Subcolección `appointments`

```
users/{userId}/appointments/{appointmentId}
```

Cada documento representa una cita de donación.

| Campo                      | Tipo          | Descripción                                                                                            |
|----------------------------|---------------|--------------------------------------------------------------------------------------------------------|
| `centerId`                 | `string`      | ID del centro (de la colección `centers`).                                                             |
| `centerName`               | `string`      | Nombre legible del centro.                                                                             |
| `scheduledAt`              | `Timestamp`   | Fecha y hora confirmadas.                                                                              |
| `status`                   | `string`      | Estado de la cita: `scheduled`, `completed`, `cancelled`.                                              |
| `donationType`             | `string`      | Modalidad de donación (ej. `Sangre total`, `Plaquetas`).                                               |
| `requiresVerificationCode` | `bool`        | Indica si la cita requiere código de verificación posterior.                                           |
| `verificationCode`         | `string`      | Código entregado por el centro (puede ser vacío si no aplica).                                        |
| `verificationCompleted`    | `bool`        | Marca si el código se registró correctamente.                                                          |
| `pointsAwarded`            | `number`      | Puntos acreditados al verificar una donación.                                                         |
| `reminders`                | `array<string>` | Lista de recordatorios personalizados.                                                                |
| `createdAt`                | `Timestamp`   | Fecha de creación de la cita.                                                                          |
| `updatedAt`                | `Timestamp`   | Última actualización de la cita.                                                                       |

> **Reglas:**
> - Las citas canceladas deberían mantener `verificationCompleted = false` y `pointsAwarded = 0`.
> - Al completar la verificación, además de actualizar el estado a `completed`, se deben sumar los puntos.

### Subcolección `achievements`

```
users/{userId}/achievements/{achievementId}
```

Registro de logros desbloqueados por cada usuario.

| Campo         | Tipo        | Descripción                                                         |
|---------------|-------------|---------------------------------------------------------------------|
| `sourceId`    | `string`    | ID de referencia al catálogo global (`achievementCatalog`).         |
| `title`       | `string`    | Título mostrado al usuario.                                         |
| `description` | `string`    | Descripción del logro.                                              |
| `iconName`    | `string`    | Nombre del icono de Material Icons a mostrar.                       |
| `unlocked`    | `bool`      | Indica si el logro fue desbloqueado.                                |
| `unlockedAt`  | `Timestamp` | Fecha en la que se desbloqueó (opcional).                           |

## 2. Colección `centers`

```
centers/{centerId}
```

Información de cada centro de donación.

| Campo        | Tipo            | Descripción                                                                     |
|--------------|-----------------|---------------------------------------------------------------------------------|
| `name`       | `string`        | Nombre del centro.                                                              |
| `address`    | `string`        | Dirección.                                                                      |
| `latitude`   | `number`        | Latitud geográfica.                                                             |
| `longitude`  | `number`        | Longitud geográfica.                                                            |
| `imageUrl`   | `string`        | URL a la imagen representativa.                                                 |
| `schedule`   | `string`        | Horario de atención formateado.                                                 |
| `services`   | `array<string>` | Lista de servicios ofrecidos.                                                   |
| `contact`    | `map`           | Información de contacto (`phone`, `email`).                                     |

## 3. Colección `alerts`

```
alerts/{alertId}
```

Alertas activas ligadas a un centro específico.

| Campo           | Tipo       | Descripción                                                           |
|-----------------|------------|------------------------------------------------------------------------|
| `centerId`      | `string`   | Referencia al centro (`centers/{centerId}`).                           |
| `bloodType`     | `string`   | Tipo de sangre requerido.                                             |
| `expiresAt`     | `Timestamp`| Fecha de caducidad de la alerta.                                      |
| `quantityNeeded`| `number`   | Cantidad de donaciones necesarias.                                    |
| `description`   | `string`   | Mensaje completo de la alerta.                                        |
| `urgencyHours`  | `number`   | Horas restantes (aproximadas) para la urgencia.                       |
| `contactPhone`  | `string`   | Teléfono del centro para coordinar.                                   |
| `contactEmail`  | `string`   | Email del centro.                                                     |

## 4. Colección `achievementCatalog`

```
achievementCatalog/{achievementId}
```

Catálogo global de logros.

| Campo         | Tipo        | Descripción                                      |
|---------------|-------------|--------------------------------------------------|
| `title`       | `string`    | Nombre del logro.                               |
| `description` | `string`    | Texto descriptivo.                              |
| `iconName`    | `string`    | Icono sugerido para visualizarlo.               |

## 5. Colección `impactSummaries` *(opcional)*

```
impactSummaries/{userId}
```

Si se requiere persistir métricas precalculadas, se puede usar esta colección espejo con los campos:

| Campo             | Tipo      | Descripción                                      |
|-------------------|-----------|--------------------------------------------------|
| `livesHelped`     | `number`  | Vidas ayudadas acumuladas.                       |
| `totalDonations`  | `number`  | Donaciones completadas.                          |
| `ranking`         | `string`  | Ranking textual del usuario.                     |
| `updatedAt`       | `Timestamp` | Última actualización.                          |

---

## Reglas y buenas prácticas

1. **Estados de cita**: utilizar siempre los literales `scheduled`, `completed`, `cancelled` para mantener compatibilidad con `_parseStatus`.
2. **Seeding reproducible**: el script `tools/firestore_seed/seed.js` carga centros, alertas y logros mínimos. Ejecutalo con `node seed.js` (luego de `npm install firebase-admin`) para que la app tenga datos iniciales.
3. **Validación en reglas**: asegurate de que las reglas de Firestore verifiquen campos obligatorios al crear usuarios y citas. Un punto de partida rápido:

    ```
    match /users/{userId} {
       allow create: if request.auth.uid == userId
          && request.resource.data.keys().hasAll([
             'name', 'email', 'phone', 'bloodType', 'city'
          ]);

       match /appointments/{appointmentId} {
          allow create: if request.auth.uid == userId
             && request.resource.data.keys().hasAll([
                'centerId', 'centerName', 'scheduledAt', 'status'
             ]);
       }
    }
    ```

4. **Indices recomendados**:
   - `users/{userId}/appointments` ordenado por `scheduledAt` descendente.
   - `alerts` ordenado por `expiresAt` descendente.
   - `alerts` filtrado por `centerId`.
5. **Seguridad**: las reglas de Firestore deben validar que cada usuario sólo acceda a sus citas, impacto y logros mediante `request.auth.uid`.
6. **Consistencia**: cualquier lógica que actualice `verificationCompleted` debe ajustar también `pointsAwarded` y, de ser necesario, incrementar `users/{userId}.totalDonations`.

### Seed rápido

1. Posicionate en `tools/firestore_seed`.
2. Instalá dependencias: `npm install`.
3. Exportá `GOOGLE_APPLICATION_CREDENTIALS` apuntando al service account.
4. Ejecutá `node seed.js`.

El script valida que cada alerta apunte a un centro real, exactamente como espera `FirebaseCentersRepository`.

Esta documentación sirve como contrato para las implementaciones de `FirebaseCentersRepository` y `FirebaseAuthRepository`. Cualquier ajuste futuro debe reflejarse aquí para mantener sincronizados los repositorios y las funciones administrativas.

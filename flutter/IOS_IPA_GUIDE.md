                    ## Guía para generar el `.ipa` de tu app Flutter en iOS

Esta guía está pensada para ti, que ya tienes el APK listo y ahora quieres generar el archivo **`.ipa`** para instalar tu app en iPhone/iPad o subirla a TestFlight / App Store.  
No cambia ningún código de tu proyecto: solo son pasos de configuración y compilación desde tu Mac.

---

### 1. Requisitos previos en tu Mac

- **Mac** con macOS reciente.
- **Xcode** instalado desde la App Store (idealmente la versión estable más nueva).
- **Command Line Tools** de Xcode:
  - Abre Xcode al menos una vez y acepta las licencias.
- **Flutter** instalado y funcionando en tu Mac:
  - En la terminal, verifica:
    - `flutter --version`
    - `flutter doctor`
- **CocoaPods** instalado:
  - `sudo gem install cocoapods` (si aún no lo tienes).
- **Cuenta de Apple**:
  - Para subir a TestFlight / App Store necesitas cuenta de **Apple Developer** de pago.
  - Para generar un `.ipa` para pruebas locales también es muy recomendable usar un **Team** de Apple ID (puede ser la misma cuenta).

---

### 2. Llevar tu proyecto Flutter al Mac

1. Copia todo el proyecto (por ejemplo la carpeta `affiliatepro_mobile_v1`) a tu Mac.
2. Abre una terminal en la carpeta del proyecto:

   ```bash
   cd /ruta/a/affiliatepro_mobile_v1
   flutter pub get
   ```

3. Verifica que exista la carpeta `ios` dentro del proyecto.  
   - Si el proyecto se creó normalmente con Flutter, ya debe estar.

---

### 3. Configurar el proyecto iOS en Xcode

1. En la terminal, estando en la raíz del proyecto:

   ```bash
   cd ios
   pod install
   ```

2. Abre el workspace en Xcode:

   ```bash
   open Runner.xcworkspace
   ```

3. En Xcode, selecciona el proyecto **Runner** en la barra lateral.

4. En la pestaña **General**:
   - **Display Name**: el nombre que verás bajo el ícono en el iPhone.
   - **Bundle Identifier**: algo único, por ejemplo `com.tuempresa.tuapp`.
   - **Version** y **Build**: deben coincidir con lo que quieras publicar.
   - **Deployment Info**: versión mínima de iOS (ej: 13.0).

5. En la pestaña **Signing & Capabilities**:
   - Marca **Automatically manage signing**.
   - En **Team**, elige tu cuenta de Apple Developer o Apple ID.
   - Asegúrate de que el **Bundle Identifier** sea único en tu cuenta.

---

### 4. Probar la app en un simulador o dispositivo (opcional pero recomendado)

Antes de generar el `.ipa`, es buena idea comprobar que la app corre bien en iOS.

1. En Xcode, elige un simulador (por ejemplo *iPhone 15 Pro*).
2. Pulsa el botón **Run** (el triángulo ▶️).
3. Comprueba que la app se abre y funciona sin errores graves.

También puedes ejecutar desde Flutter:

```bash
flutter run
```

con un simulador o dispositivo conectado.

---

### 5. Generar el `.ipa` usando Xcode (método clásico)

Este método es muy visual y suele ser el más fácil la primera vez.

1. En Xcode, en la parte superior:
   - En vez de un simulador, elige **Any iOS Device (arm64)** o similar.
2. Menú **Product > Archive**.
3. Xcode compilará tu app y abrirá el **Organizer** con el archivo archivado.

En el Organizer:

- Selecciona tu último **Archive** de *Runner*.
- Pulsa **Distribute App**.
- Elige el método:
  - **App Store Connect** → para subir a TestFlight / App Store.
  - **Ad Hoc / Development / Enterprise** → para exportar un `.ipa` que puedas instalar en dispositivos con el perfil adecuado.

Si eliges exportar:

- Xcode te pedirá opciones de firma y luego te permitirá **guardar el archivo `.ipa`** en una carpeta.

Ese `.ipa` es el que podrás:

- Subir a servicios de distribución.
- Pasar a tu equipo técnico.
- Cargar en un MDM, etc.

---

### 6. Generar el `.ipa` usando Flutter (`flutter build ipa`)

Una vez que ya tienes la firma configurada en Xcode, puedes usar Flutter para automatizar la compilación.

1. Cierra Xcode.
2. En la terminal, desde la raíz del proyecto:

   ```bash
   flutter build ipa --release
   ```

3. Flutter llamará a Xcode por detrás y generará el `.ipa`.
4. Cuando termine, normalmente lo encontrarás en:

   ```text
   build/ios/ipa/
   ```

   con un nombre similar a `Runner.ipa`.

> Nota: si Flutter te pide un `export-options.plist`, puedes generar uno desde Xcode cuando hagas un export manual, y luego reutilizarlo para automatizar el `flutter build ipa`.

---

### 7. Cómo pedir ayuda a la IA mientras haces el proceso

Algunas ideas de mensajes útiles que puedes enviarle a la IA cuando estés en tu Mac:

- Para configurar desde cero:
  - “Estoy en Mac con Xcode instalado. Tengo un proyecto Flutter en la ruta `/Users/.../affiliatepro_mobile_v1`. Ayúdame paso a paso a configurar la firma y generar un `.ipa` para TestFlight.”

- Cuando te salga un error en Xcode:
  - “Al hacer Product > Archive en Xcode me sale este error (pego el texto o captura). ¿Qué significa y cómo lo soluciono?”

- Cuando falle `flutter build ipa`:
  - “Ejecuté `flutter build ipa --release` y me da este error en la terminal (pego la salida). ¿Qué ajustes tengo que hacer en Xcode o en el proyecto?”

- Para revisar la configuración:
  - “Este es mi Bundle Identifier, Team y pantalla de Signing & Capabilities (pego capturas). ¿Está todo bien para subir a TestFlight?”

Cuanta más información des (comando que ejecutaste, error exacto, captura), más precisa será la ayuda.

---

### 8. Resumen rápido

1. Instalar Xcode, Flutter y CocoaPods en el Mac.
2. Copiar el proyecto Flutter al Mac y ejecutar `flutter pub get`.
3. Entrar a `ios/`, hacer `pod install` y abrir `Runner.xcworkspace` en Xcode.
4. Configurar **Bundle ID**, **Team** y **Signing & Capabilities**.
5. Probar la app en simulador/dispositivo.
6. Generar un **Archive** en Xcode y exportar `.ipa` o subir a App Store Connect.
7. (Opcional) Automatizar con `flutter build ipa --release`.

Con esto deberías poder generar tu `.ipa` sin tocar el código de tu app.


# AffiliatePro SaaS Mobile App (Full Source Code)

This is the official Flutter source code for the AffiliatePro mobile application.  
You can customize the app with your own domain and license key, and build your own APK to install or publish.

## 📄 Historial de Versiones

- **v1.2.8** - ACTUALIZACIÓN "BRUTAL" (v55.0.0). Integración final de IA Landing Builder con motor Senior EX y Landing Pages de alta conversión. Rediseño del flujo de generación por pasos, implementación de enlaces de landing directos y blindaje de validación de estatus. Corrección crítica de enlaces de afiliado y sincronización de alias personalizados. Implementación de **App Tour Interactivo** (Showcase) para guiar al usuario en el Dashboard.

## App Tour v1.2.8

Se ha implementado una guía interactiva para nuevos usuarios y tras la actualización a la v1.2.8. La versión 1.2.8 ya tiene el "App Tour Interactivo" funcionando al 100% con scroll automático y persistencia. Los pasos incluyen:
1. **Tu Perfil**: Gestión de datos y progreso.
2. **Saldo USD**: Explicación de ganancias reales retirables.
3. **Saldo ExCoin**: Introducción a la moneda virtual del ecosistema.
4. **Tus Enlaces**: Resaltado del botón central para comenzar a vender.
5. **Siguiente Rango**: Visualización del progreso hacia el nivel PLATA.
6. **Eventos**: Calendario de lanzamientos.
7. **Ranking**: Competición global.
8. **Mi Red**: Gestión de equipo y afiliados.

La persistencia asegura que el tour solo se muestre una vez (almacenado en SharedPreferences).
- **v1.2.7** - LANZAMIENTO OFICIAL (v42.0.0). Rebranding global de moneda (CoinX -> **ExCoin**), actualización de versión oficial, blindaje atómico de modelos contra errores de servidor y pulido estético de Billetera ExCoin (Divider invisible y Saldo Premium).
- **v28.0.0** - Purga Estricta y Sincronización Real. Eliminación física de Mock Data, fix de TypeError en modelos (status y pending_count), eliminación total de inyección de productos fallback y bloqueo de botón Generar hasta completar WhatsApp.
- **v27.0.0** - Purga Total y Sincronización Real. Eliminación física de Mock Data de estrategias, fix definitivo de `status` en modelo `VendorProduct` (dynamic + `int.tryParse`) para eliminar fallback de productos y reparación de overflow en selectores.
- **v25.0.0** - Fix de Tipos y Flujo Obligatorio. Corrección radical de `status` en modelo `VendorProduct` (dynamic + robust parsing) para eliminar fallback, mapeo prioritario del campo `texto_ia` en respuesta de generación y visibilidad obligatoria de WhatsApp en estrategia Master.
- **v23.0.0** - Depuración Agresiva y Cierre de Proyecto. Eliminación total de Mock Data (estrategias y productos de prueba), fix definitivo de tipo en status (dynamic + robust parsing) para eliminar fallback de productos de afiliado, reparación de overflow en UI y pulido final de Billetera.
- **v22.0.0** - Depuración Final y Activación de Paso 3. Eliminación total de Mock Data, sincronización de tags de WhatsApp ([NUMERO_WHATSAPP], [CONTACT_PHONE]), fix de TypeError en status (int.tryParse) y refinamiento de UI (overflow y bloqueo de botón).
- **v20.0.0** - Cierre de Proyecto. Corrección de tipos en API (status bool/int bypass), validación obligatoria de WhatsApp de 9 dígitos para habilitar generación, reparación de overflow en UI de estrategias y pulido final de Billetera CoinX.
- **v19.0.0** - Configuración Final de Rutas y Flujo IA. Actualización de endpoints a `Subscription_Plan/`, eliminación de Mock Data, implementación de flujo Cascada real con Token Bearer y links de checkout con atribución `ref_id=37`.
- **v18.2.0** - Optimización de UI y Limpieza de Formulario IA. Eliminación de instrucciones extras, corrección de desbordamiento de píxeles en selectores y refinamiento de estrategias de respaldo con iconos premium (Estrella y Rayo).
- **v18.1.0** - Blindaje de Emergencia. Implementación de anti-caché en peticiones, parseo seguro de status (String/Int bypass) y manejo de respuestas HTML accidentales con Mock Data de respaldo en IA Marketing.
- **v18.0.0** - Versión final estable. Integración total con API JSON pura. Flujo de IA dinámico secuencial "Cascada" por pasos. Billetera CoinX pulida y funcional (líneas invisibles y sincronización real-time).
- **v16.0.0** - Lanzamiento oficial del Generador de Landings IA con motor Senior EX. Atribución de bonos automática. Billetera CoinX 100% funcional y pulida.
- **v13.0.0** - Reestructuración de Flujo Secuencial IA. Interfaz paso a paso con animaciones (Paso 1: Producto, Paso 2: Estrategia, Paso 3: WhatsApp/Extras). Blindaje de tipos en VendorProduct (status to String) para evitar crashes y corrección de headers JSON en el fetch de estrategias.
- **v12.0.0** - Ecosistema IA Marketing Finalizado. Conexión de estrategias dinámicas (Dropdown), lógica de reemplazo de tags ([NUMERO_WHATSAPP], [PRODUCT_NAME]), disparo de generación POST y visualización elegante del texto generado. Implementación de etiquetas "Sugerido" para productos Top.
- **v10.0.0** - Generador de Landing con Lógica de Afiliado. Fallback de productos inyectado, campo de WhatsApp con validación de 9 dígitos y payload optimizado con user_id y contact_phone. La Landing generada debe insertar el user_id en el link del botón de compra para asegurar que el sistema de comisiones asigne el bono correctamente al creador.
- **v9.0.0** - Integración final de IA Landing Builder. Acceso universal para Afiliados y Proveedores tras actualización de API. Limpieza estética de Billetera y Dashboard.
- **v7.1.0** - Bypass de seguridad para IA Landing. Eliminación de restricciones de rango de vendedor en la App. Limpieza de bordes blancos en Billetera.
- **v7.0.0** - Optimización visual de Billetera (eliminación de líneas blancas) y bypass de acceso para IA Landing Builder. Conexión de Landing AI mediante JSON Body para compatibilidad CORS.
- **v6.1.0** - Pulido visual de la billetera. Eliminación de líneas de separación y añadido de animaciones de entrada suaves (Fade-In/Slide-In) para datos reales.
- **v6.0.0** - Conexión final con API v2. Sincronización de canje mediante JSON Body y actualización dinámica de balances.
- **v5.3.0** - Corrección de lógica de canje. Se implementó el uso de ID dinámico para compatibilidad con múltiples usuarios y formato de envío x-www-form-urlencoded.
- **v5.2.0** - Ajuste de payload crudo para compatibilidad con $_POST en PHP. Sincronización post-canje activa.
- **v5.1.0** - Cambio a formato x-www-form-urlencoded para compatibilidad con el servidor. Sincronización de saldos corregida. (Versión Global 2.1.0).
- **v4.4.0** - Implementación de envío por Query Parameters para compatibilidad forzada con Backend PHP. Sincronización de balances en tiempo real. (Versión Global 1.9.0).
- **v4.3.0** - Cambio de protocolo de envío a MultipartRequest para compatibilidad total con el Backend. Sincronización de saldos post-canje garantizada. (Versión Global 1.8.3).
- **v4.2.0** - Fix de tipos de datos en API de canje. Conversión de userId String a Int y soporte para fallback x-www-form-urlencoded. Implementación de actualización de balance post-transacción. (Versión Global 1.8.2).
- **v4.1.0** - Ajuste de headers y codificación JSON en el módulo de canje. Sincronización automática de saldos tras éxito en transacción. (Versión Global 1.8.1).
- **v4.0.0** - Implementación de logs de depuración para el módulo de Canje. Captura de errores dinámicos desde la API y monitoreo de payload POST. (Versión Global 1.8.0).
- **v3.3.0** - Optimización dinámica del gráfico semanal. Sincronización automática con DateTime.now() para alinear el pico de ganancias con el día real (Sábado) y reseteo de días futuros (Versión Global 1.7.0).
- **v3.2.1** - Fix de desfase en el gráfico semanal. Sincronización de valores con los días correctos (Pico en Sábado y caída natural a cero en Domingo). (Versión Global 1.6.1).
- **v3.2.0** - Optimización visual del gráfico semanal: eliminación de caídas bruscas a cero en días futuros mediante lógica de línea plana (proyección estática). Dashboard 100% operativo con navegación directa a Billetera. (Versión Global 1.6.0).
- **v3.1.0** - Sincronización de saldos con la API dinámica. Reparación de fuga de ID de usuario y unificación de visualización USD/CoinX (Versión Global 1.5.1).
- **v3.0.0** - Sincronización Maestra de Saldos. Se unificó la lógica de Dashboard con los datos reales de la API CoinX (ID dinámico). Corregido error de desajuste de montos con la Web (Versión Global 1.5.0).
- **v2.0.8** - Sincronización de CoinXController con el Dashboard principal. Implementación de reactividad (Obx) en las nuevas tarjetas de balance superior para Saldo USD y Saldo CoinX. (Versión Global 1.3.8).
- **v2.0.7** - Fix crítico de casteo numérico (int to double) en variables de coinX. Conexión real de variables observables (Obx) en la UI para eliminar textos y saldos hardcodeados (Versión Global 1.3.7).
- **v2.0.6** - Fix crítico de casteo numérico al parsear coinx_balance y available_earnings desde el JSON. Prevención de asignación 0 por conflicto de tipos int/double en Dart. (Versión Global 1.3.6).
- **v2.0.5** - Desacoplamiento de UI entre Tabs Comprar/Canjear. Inserción de tarjeta informativa específica para Canje con exchange_rate reactivo. Fix crítico de parseo de API que generaba respuesta nula (Versión Global 1.3.5).
- **v2.0.4** - Integración de textos dinámicos desde API (info_text, warning_text, exchange_rate). Rediseño de Tabs para evitar overflow visual y maquetado de caja de advertencia premium (Versión Global 1.3.4).
- **v2.0.3** - Debug de payload crudo en get_coinx_data. Mejora de padding en Segmented Tabs (prevención de overflow). Implementación de caja de advertencia en Canjear y preparación de variables para textos dinámicos desde la API (Versión Global 1.3.3).
- **v2.0.2** - Fix de recuperación de UserID en CoinXController. Mejora visual de Billetera con fondo degradado dark-green, tabs responsivos (prevención de overflow) y adición de tarjeta informativa de beneficios coinX (Versión Global 1.3.2).
- **v2.0.1** - (Fase 2) Mejoras UI/UX en Billetera CoinX. Implementación de animación escalonada de entrada premium (FadeInUp), rediseño premium dark de tabs y pasarelas, activación de logs de consola para monitoreo de APIs dinámicas (Versión Global 1.3.1).
- **v2.0.0** - Módulo CoinX Wallet. Acceso en Drawer (FINANZAS). Pantalla dedicada con Tabs (Comprar/Canjear). WebView integrado para pasarelas de pago y UI premium dark (Versión Global 1.3.0).
- **v1.9.1** - Ajuste de nomenclatura en el payload (type) para sincronizar con el nuevo sistema de redirección del backend (url_tienda y compartir_tienda).
- **v1.9.0** - Desacoplamiento de 4 enlaces independientes. Renderizado condicional en UI según rol (Afiliado=2 tarjetas, Proveedor=4 tarjetas). Fix de types de guardado dinámico.
- **v1.8.8** - Refactorización del payload de enlaces. El parámetro 'type' ahora es dinámico según la tarjeta seleccionada (store, register, etc.) evitando sobreescritura incorrecta.
- **v1.8.7** - Desactivación de auto-logout preventivo. Implementación de escáner de memoria para rastreo del User ID real desde el controlador principal (DashboardController), igualando la lógica del Drawer.
- **v1.8.6** - Corrección crítica de recuperación de sesión. Se identificó la clave de almacenamiento local correcta (`user_id` / `id`) para inyectar el User ID real en el payload y se implementó redirección de seguridad al Login.
- **v1.8.5** - Corrección de extracción del User ID desde el almacenamiento local para el payload de actualización de alias.
- **v1.8.4** - Integración del sistema de Alias/Slugs personalizados para Enlaces de Afiliado. Validación de unicidad y actualización de UI en tiempo real (Versión Global 1.2.6).
- **v1.8.1** - Corrección de extracción de slug en actualización de enlaces de afiliado. Manejo de errores para caracteres inválidos y limpieza de URL antes del envío.
- **v1.8.0** - Integración final de IA con prompts dinámicos, fix de actualización de links (CORS/404) y validación de rol Vendor. Eliminación de GlobalKey en métodos build para estabilidad.
- **v1.7.7** - Manejo de excepciones para respuestas HTML 404 y blindaje de TypeError en el módulo de registros. Centralización de URL de actualización en ApiService.
- **v1.7.6** - Limpieza de placeholders en Registro y preparación de estructura POST para actualización de enlaces. Eliminación del mensaje "Esperando API" y activación del disparo real.
- **v1.7.4** - Habilitación de logs de depuración para el módulo de edición de enlaces de afiliado. Trazabilidad total de URL, Payload y respuestas del servidor en consola.
- **v1.7.1** - Buscador de productos reales activado. Prompts de alta conversión (AIDA) integrados para generación de Landings. Optimización de UI con Searchable Modal.
- **v1.7.0** - Integración de Generador de Landings con IA (GPT-4o). Selector de productos, prompt de usuario y sistema de copiado de URL. Interfaz Premium v1.2.6 con estética Neón Esmeralda.
- **v1.6.0** - Salto de versión oficial a 1.2.6. Finalización de la integración de pedidos con 13 estados, fix de TypeErrors y pulido estético del Dashboard.
- **v1.5.2** - Sincronización de color de marca. El balance total ahora usa el verde esmeralda vibrante del botón Configurar, eliminando ruidos visuales y sombras.
- **v1.5.1** - Corrección final de color en Balance. El $0 brillante fue reemplazado por un sólido color Verde Esmeralda Profundo, oscuro y sin brillo, sincronizando la estética.
- **v1.5.0** - Pulido estético final en Dashboard. El Balance Total $0 ahora brilla con un neón esmeralda intenso para combinar con los 13 filtros de Pedidos.
- **v1.4.4** - Limpieza integral de TypeErrors en todas las funciones del controlador de Pedidos y pulido de UI neón.
- **v1.4.3** - Blindaje total de tipos dinámicos para evitar TypeError y despliegue final de 13 chips neón.
- **v1.4.2** - Solución definitiva al TypeError mediante validación de tipos dinámica y despliegue de 13 filtros neón.
- **v1.4.1** - Fix definitivo de TypeError (List vs Map) en Pedidos y despliegue de los 13 filtros dinámicos.
- **v1.4.0** - Sincronización ABSOLUTA de los 13 estados de la API. UI Premium con scroll infinito de botones neón.
- **v1.3.9** - Limpieza total de Obx mal implementados y forzado de estilos Esmeralda Neón.
- **v1.3.8** - RECONSTRUCCIÓN BLINDADA. Fix de Obx, mapeo de Listas corregido y diseño Neón Esmeralda finalizado.
- **v1.3.5** - Interfaz de pedidos Premium con chips de degradado neón y corrección de error de reactividad GetX.
- **v1.3.2** - Sincronización final de pedidos. Implementación de FormData, remoción de filter_status para 'Todos' y mapeo profundo de data['orders'].
- **v1.3.1** - Fix definitivo de pedidos. Implementación de parámetros de paginación (page_id, per_page) y manejo de respuesta tipo List.
- **v1.3.0** - Implementación de rutas REST nativas (sin sufijos), fix de CORS y mapeo dinámico de pedidos por ID.
- **v1.2.9** - Corrección de método POST en Pedidos y unificación de parseo de Listas para evitar errores de tipo en Flutter Web.
- **v1.2.8** - Solución a Error 405 en Pedidos, ajuste de parseo List/Map y limpieza de buscador en la UI.
- **v1.2.7** - Rediseño de filtros de pedidos con chips horizontales y lógica de filtrado por ID numérico (v3.0). Sincronización de colores dinámicos por estado y carga de nombres desde el servidor.
- **v1.2.6** - Fix de overflow en UI Offline y ajuste de lógica para evitar falsos positivos de "Sin Conexión" cuando el servidor devuelve null.
- **v1.2.5** - Actualización técnica de versión global y preparación de entorno para nuevos módulos de IA Marketing.
- **v11.0.0** - Implementación de detección de conectividad en tiempo real e interfaz offline profesional.
- **v20.0.0** - PROYECTO FINALIZADO. Sincronización completa de Ajustes de Tienda y Productos (Forja). Comunicación v3.0 JSON sin errores.
- **v19.0.0** - CIERRE DE MÓDULO. Sincronización exitosa con tabla users y campo store_meta. Edición de clics habilitada y rutas de imágenes corregidas.
- **v13.0.0** - CIERRE TOTAL DE MÓDULOS. Fix de compatibilidad PHP 8.2 para Multipart, habilitación de edición de clics y sincronización final de admin_note v3.0.
- **v11.5.0** - Debugger de Errores PHP (HTML Logger) y formateo de clics como enteros para compatibilidad con Backend.
- **v11.0.0** - Mapeo completo de Ajustes de Tienda v3.0 y habilitación de edición de clics.
- **v10.0.0** - CIERRE DE ETAPA. Guardado de tienda multipart corregido (endpoint _post), edición de clics habilitada y sincronización total de admin_note (Fallback Texto Plano).
- **v8.0.0** - Sincronización final con Backend v3.0 (debug_v). Implementación de subconsultas para admin_note y bypass de Opcache.
- **v7.0.0** - Corrección de crash en APK al guardar ajustes (fix multipart data corruption) y desbloqueo de campo de Clics (Read-Only fix).
- **v6.0.0** - MÓDULO DE PRODUCTOS FINALIZADO Y BLINDADO. Integración con lógica de subconsultas, auditoría de server_time y chat de admin sincronizado.
- **v5.0.0** - MÓDULO DE PRODUCTOS FINALIZADO. Sincronización completa de chat de admin, precios espejo, categorías y comisiones dinámicas.
- **v4.6.0** - Corrección visual de Dropdowns (mapeo de 'name') e implementación de lógica de pre-selección inteligente de comisión basada en el símbolo '%'.
- **v4.5.0** - Transformación de sección de comentarios a sistema de historial (Chat), duplicidad de precios espejo-web y limpieza de Dropdowns.
- **v4.3.0** - Corrección visual de Dropdowns (mapeo de nombres), fijación de controladores de precio independientes y auditoría de notas admin.
- **v4.1.0** - Corrección de TypeError en comisiones (List vs Map) y ajuste final de jerarquía de precios.
- **v4.0.0** - Módulo de Productos Finalizado: Integración de admin_note, comisiones dinámicas y corrección semántica de precios.
- **v3.0.0** - Sincronización total de Productos: Implementación de descripción, categorías, comisiones y precios reales desde el servidor en la edición ("La Forja").
- **v2.8.0** - Limpieza de campos innecesarios (Sobre Nosotros), corrección de doble campo en Comisión de Clic (Clics + Valor) y mapeo dinámico de vendor_status.
- **v2.7.5** - Reorganización de campos de contacto a la pestaña Tienda y simplificación de bloques de comisión en Proveedor según capturas web.
- **v1.2.1** - Estandarización de textos (Variantes de producto), integración de nuevos campos de API (allow_upload_file, product_is_coming_soon) y reordenamiento de secciones.
- **v1.2.5** - Módulos VIP Expansion: Se integraron 4 nuevos módulos al Panel del Vendedor: Cupones VIP (CRUD completo con DatePickers neón), Gestión de Pedidos Inteligente (con cambio de estado y badges), Directorio de Clientes (con paginación infinita) y Ajustes Globales de Tienda. Todos los servicios heredan el SessionManager para máxima seguridad.
- **v1.2.6** - Sincronización Dinámica de Cupones: Se eliminó el uso de datos estáticos (Mock Data) en la sección de Cupones. Implementado mapeo dinámico desde el controlador Subscription_Plan (GET get_vendor_coupons), soporte para tipos de descuento (Porcentaje/Fijo) reactivos al servidor y sistema de logs de rastreo en tiempo real.
- **v1.2.7** - Limpieza de etiquetas VIP en creación y activación de trazabilidad (logs) en el método POST de cupones.
- **v1.2.8** - Mapeo completo de parámetros de API (name, code, uses_total) y mejora de mensajes de estado vacío en Cupones.
- **v2.7.0** - Sincronización estética y semántica 1:1 con la Web. Implementación de vendor_status como selector de privacidad y activación de rastreo de APIs.
- **v2.6.0** - Implementación final de Ajustes: Inserción de 'Sobre Nosotros', eliminación de estados inventados y rediseño Premium de pestañas.
- **v2.5.1** - Corrección técnica: Restauración de importaciones críticas (GetX, Material, SharedPreferences) en el controlador de ajustes.
- **v2.5.0** - Rediseño Premium de Ajustes: Sistema de pestañas, gestión de identidad visual (banner/logo) y unificación de API de diseño y proveedor.
- **v2.2.8** - Rediseño del filtro de pedidos: Implementación de Dropdown y botón de búsqueda estilo web optimizado para móvil.
- **v2.3.7** - Corrección de error de compilación: Sincronización de los campos 'user_earning_team' y 'minimum_earning_team' en el modelo AwardLevels.
- **v2.3.6** - Inserción de métrica 'Volumen de equipo' en la UI de Beneficios respetando el diseño y animaciones originales.
- **v2.2.5** - Eliminación total de etiqueta 'VIP' en la UI y adición de botón de búsqueda en el módulo de Pedidos.
- **v2.2.1** - Corrección visual: Inserción del acceso directo a Pedidos en el menú lateral y Dashboard.
- **v2.2.0** - Corrección de visibilidad del módulo Pedidos en Dashboard y diseño de estado vacío de lista.
- **v2.1.0** - Creación del módulo de Pedidos (Orders) e integración con el listado oficial del servidor.
- **v1.9.6** - Expansión de Ajustes de Tienda con gestión de afiliados (clics/ventas) y switch de estado del vendedor.
- **v1.9.0** - Expansión del modelo Product para incluir Descripción, Precio de Venta y Comisión de Afiliados, completando el formulario de edición.
- **v1.8.5** - Sincronización final de llaves 'name' y 'sku' confirmadas por Backend y corrección de precarga de formulario.
- **v1.7.2** - Optimización de timing en edición de productos (precarga instantánea de textos e imagen independiente de categorías).
- **v1.7.1** - Solución de bug de campos vacíos en edición (precarga de controladores de texto y visualización de imagen).
- **v1.7.0** - Implementación completa de CRUD de productos (Edición/Eliminación) y optimización de vista de clientes.
- **v1.6.0** - Conexión del módulo de Clientes con el endpoint de Subscription_Plan y soporte de paginación.
- **v1.5.0** - Implementación de iconos de gestión (Editar/Eliminar) en las tarjetas de la lista de productos.
- **v1.4.6** - Sincronización de llave 'coupon_id' del backend con el campo 'id' de la App para habilitar eliminación.
- **v1.4.5** - Corrección de referencia nula en el paso de parámetros de eliminación desde la UI al controlador.
- **v1.4.4** - Solución de bug en eliminación (ID vacío en URL) y mejora de trazabilidad en peticiones DELETE.
- **v1.4.3** - Corrección de parámetro coupon_id vacío en el método DELETE y estabilización de eliminación con manejo de error 404.
- **v1.4.2** - Implementación de limpieza dinámica de decimales mediante Regex para evitar confusión visual de valores numéricos.
- **v1.4.1** - Sincronización total con la API actualizada (llave 'code' y formato de descuento limpio).
- **v1.4.0** - Implementación de protección contra respuestas HTML 404 y logs de depuración de URL.
- **v1.3.9** - Implementación de logs de JSON crudo para depuración de llaves de API y formateo visual agresivo de descuentos (sin decimales).
- **v1.3.8** - Formateo de decimales en descuentos y mapeo exhaustivo de llaves de API para el código del cupón.
- **v1.3.7** - Mapeo corregido de la llave 'coupon_code' para visualización en edición y limpieza de ceros en descuentos.
- **v1.3.6** - UTF-8 Stability: Solución de crash por Bad UTF-8 encoding en logs y forzado de decodificación segura en respuestas del servidor. Limpieza de caracteres especiales en logs de depuración.
- **v1.3.5** - Solución definitiva a controladores vacíos mediante asignación síncrona en el ciclo de vida del widget.
- **v1.3.4** - Corrección de asignación de controladores de texto y separación de lógica de Dropdowns en edición.
- **v1.3.3** - UI Fix: Corrección de asignación de valores en controladores de edición (uso de .text en lugar de hintText) y formateo de decimales en descuentos para una visualización limpia.
- **v1.3.2** - Corrección de crash en navegación de edición y blindaje de controladores de cupones.
- **v1.3.1** - Blindaje total de Dropdown en edición para evitar crash por valores nulos o incompatibles (Assertion failed).
- **v1.3.0** - Estabilidad Crítica: Solución de crash en Dropdown de edición (mapeo de allow_for) y habilitación de borrado de cupones (DELETE) con diálogo de confirmación.
- **v1.2.9** - Integración del parámetro allow_for y vinculación de array de productos (products[]) en el módulo de cupones.
- **v1.3.6** - Persistence & Security: Se reforzó el guardado del token en Login y se implementó una política de "Soft Logout" para prevenir la pérdida accidental de sesión.
- **v1.3.5** - Session Persistence: Se implementó búsqueda de token en cascada y logs de rastreo para evitar errores de sesión no detectada.
- **v1.3.4** - Navigation Fix: Se corrigió el error de nulidad al redireccionar al Login y se optimizó la búsqueda del Token de sesión en el almacenamiento local.
- **v1.4.2** - Server Error Handling: Se mejoro el feedback ante errores 401 de servidor, diferenciandolos de sesiones expiradas. Implementado log detallado de respuesta de error y habilitado el reintento manual sin cierre de pantalla.
- **v1.4.1** - Multipart Auth Fix: Se corrigió el formato del header de autorización (Bearer) en peticiones Multipart y se eliminó la restricción manual de Content-Type para mejorar la compatibilidad con el servidor PHP. Implementado sistema de reintento automático tras error 401 mediante refresco de memoria.
- **v1.4.0** - Unified Session Architecture: Se unifico el flujo del token usando SessionManager Singleton como fuente unica de verdad. Eliminacion de EventService para gestion de sesion y limpieza profunda de logs redundantes (animate: true).
- **v1.3.9** - Session Singleton Unification: Se implementó un patrón Singleton estricto en SessionManager para unificar el flujo del token entre Login y Productos. Limpieza de logs redundantes para optimizar el rendimiento.
- **v1.3.8** - Architecture Stability: Se corrigio la duplicidad de GlobalKeys y se registraron las rutas maestras para evitar cierres inesperados. Limpieza de logs para compatibilidad con renderizado Chrome.
- **v1.3.7** - Session Manager Singleton: Se implementó un gestor de sesión global en RAM y persistencia en disco para garantizar la disponibilidad del token.
- **v1.3.2** - Security Fix: Se implementó la inclusión del Token de Autorización en las peticiones Multipart para resolver el error 401 al crear productos.
- **v1.2.9** - Restoration: Se restauró el buscador inteligente de categorías para mejorar la UX y asegurar la integridad de datos. Se implementó la visualización de doble precio (Anclaje + Venta) para estrategias de descuento en la App.
- **v1.2.8** - Full Integration: Se completó el formulario de creación de productos con el sistema de comisiones para afiliados y admin, y comentarios para el administrador. Diseño refinado en Esmeralda/Negro.
- **v1.2.7** - Aesthetic Correction: Se eliminó el color celeste y se restauró la paleta Esmeralda/Negro. Se reemplazó el buscador de categorías por un campo de texto manual siguiendo el flujo de la web.
- **v1.2.6** - Sophisticated Design: Se refinó la UI de membresías eliminando la saturación de neón para un look minimalista y Premium. Se implementó un buscador inteligente de categorías con sugerencias dinámicas. Restoration Update: Se restauró el carrusel horizontal VIP y se implementó Scroll Interno Independiente en la lista de beneficios para manejar textos extensos sin romper la estética de la tarjeta. v1.2.6 API Integration Fix: Se eliminó el renderizado de texto estático y pegado en los beneficios de membresía. Implementación de 'List.map()' para generar checks dinámicos y separados para cada beneficio real de la API.
- **v1.2.5** - Product Creation Epic: Se transformó el flujo de creación de productos con una interfaz profesional basada en ExpansionTiles y estética Dark Esmeralda VIP. Se implementó compatibilidad Web para imágenes y archivos (Uint8List), soporte para múltiples archivos descargables, gestión de variantes con generación automática de JSON y nuevos campos de API (stock, tags, visibilidad). Inventory Sync: Se conectó la pantalla de Mis Productos con la API real. Implementado soporte para stock infinito, imágenes dinámicas y conteo de productos en revisión. Conexión de API Real: Se integró el campo 'benefits' del servidor para mostrar las ventajas reales de cada plan en la pantalla de membresías. Se eliminó definitivamente el uso de mock data (datos de prueba) en la lista de beneficios, implementando un mapeo dinámico y un fallback de seguridad en caso de datos vacíos. Se rediseñó la UI de beneficios de membresía reemplazando los checks grandes por viñetas minimalistas esmeralda, y se ajustaron los espaciados verticales para lograr un look & feel limpio y sofisticado similar al de la web. Se integró el Array de beneficios de la API, eliminando el error de texto pegado y permitiendo que cada ventaja se muestre de forma independiente y legible. v1.2.5 CRITICAL UI Fix: Se eliminaron TODOS los candados de altura fija en la pantalla de membresías. Se permitió que las tarjetas crezcan hacia abajo responsivamente para mostrar el 100% de los beneficios reales de la API sin encimarse ni cortarse. Conexión exitosa del Vendor Dashboard con datos reales de la API. Se eliminó el mock data y se vinculó la navegación de accesos directos a Productos y Cupones. v1.2.5 Final Dashboard Update: Se eliminó el acceso a notificaciones del Dashboard para evitar redundancia, se corrigió error de controlador y se conectaron datos reales de ventas y pedidos. v1.2.5 Bug Fix & Data: Se corrigió error de inicialización de controlador y se conectó el Dashboard con datos reales del vendedor desde la API. v1.2.5 Restoration: Se restauró la integración de 'in_app_purchase' y se conectó exitosamente con la API de planes tras la corrección del Error 500 en el servidor. Navegación de salida habilitada. v1.2.5 Error 500 & Persistencia: Se implementó un manejo robusto de errores con logs detallados para diagnosticar fallos del backend. Se blindó la pantalla de membresías con un estado de error claro y un botón de reintento manual para evitar bucles de red. Se aseguró la persistencia del servicio de Google Play Billing y la dependencia 'in_app_purchase' para proteger el flujo de pagos.
- **V1.2.4** - Se añadieron los enlaces de Tienda y Registro en Mi Registro para Afiliados, manteniendo intacta la vista de Proveedor. Se maquetó la interfaz visual premium (UI) para la pantalla de Detalles del Pedido del Proveedor, optimizada para móviles (sin tablas). Se implementó la pantalla de Productos del Proveedor con navegación de Tabs (Productos/Revisar), animaciones premium y se enlazó con el Menú Lateral. Se rediseñó la UI de Cupones a un estilo Premium (VIP) y se implementó la pantalla de Mis Pedidos con filtros en formato Chip interactivo. Versión 1.2.4 Visual Update: Se invirtió la dirección del degradado esmeralda premium (ahora de arriba hacia abajo) en Productos y Cupones, unificando la estética de ambas pantallas. Se rediseñó completamente la interfaz visual de las tarjetas de cupones, otorgándoles un aspecto VIP tipo ticket con sombras profundas. Se construyó la pantalla premium de Clientes del Proveedor, implementando el fondo degradado esmeralda, tarjetas VIP de contactos y enlazándola al menú lateral. Se implementó la pantalla de Configuración de Tienda y Proveedor con sistema de Tabs, UI de formularios Premium y validación visual animada.
- **V1.2.3** - Emergency UI Hotfix: Reparación del Grid de Banners y Enlaces, sanitización de HTML en descripciones de productos y aseguramiento de visibilidad de botones de acción (Descarga/Info) mediante posicionamiento absoluto sobre imágenes.
- **V1.2.3** - Final Hotfix: Implementado blindaje estructural en listas para garantizar la visibilidad y funcionalidad de los iconos de acción, aislando el contenido flexible del contenido fijo tras detectar HTML/datos corruptos en los logs.
- **V1.2.3** - Final Day Patch: Hotfix estético en listas de registros/pedidos, arreglando el truncamiento y visibilidad de los iconos de acción en el borde derecho mediante uso de Expanded y Padding.
- **V1.2.2** - Hotfix Data: Implementado mapeo estricto del objeto user_plan nativo del Dashboard API según la nueva estructura del backend.
- **V1.2.2** - Feature: Integración de endpoints become_vendor/become_affiliate con un Toggle Switch reactivo y diseño Premium en la pantalla de Mi Perfil.
- **V1.2.1.1** - Emergency Patch: Gráfica expandida a ancho completo, corrección de estado de membresía Ultra y blindaje de persistencia de usuario.

## 🔧 Step-by-Step Setup Instructions

### 1. Edit Your API Domain and License Key
Open the file:
assets/config.json

Update it with your information:
{
  "base_url": "https://yourdomain.com/",
  "license_key": "YOUR-LICENSE-KEY-HERE"
}

⚠️ Make sure:

- `base_url` starts with `https://`
- `base_url` ends with `/`
- Example: `https://affiliate.yoursite.com/`

### 2. Get Flutter Packages
Open a terminal inside the project folder and run:
flutter pub get

### 3. Build the APK
To generate the release APK file:
flutter build apk --release

The built APK will be located here:
build/app/outputs/flutter-apk/app-release.apk
You can install it on your device or upload it to the Google Play Console.

### 🚀 Optional: Debug Run (for testing)
To test the app on an emulator or USB-connected device:
flutter run

## 📁 Project Structure Overview

affiliatepro_app/
├── assets/
│   └── config.json       # Your API URL + license key
├── lib/                  # Main Flutter source code
├── android/              # Android platform files
├── pubspec.yaml          # Flutter config & dependencies
├── README.md             # This file
└── ...                   # Other project files

## 💼 Need Help?
If you'd like us to generate the APK for you or help with publishing on Google Play, contact us — we’ll be happy to assist.

---

## 📡 Explicación (Nube ↔ App) y “Llave/Licencia” (ES)

Esta app funciona como un “cliente” que se conecta a tu sistema en la nube (tu dominio). La app no “guarda” la lógica del negocio localmente: la mayoría de datos (productos, banners, reportes, pagos, etc.) se consultan por HTTP hacia tu backend.

### 1) Configuración base (dominio + licencia)
La app lee un archivo local al iniciar:

- `assets/config.json`

Con dos valores:

- `base_url`: el dominio base de tu sistema (ej: `https://tu-dominio.com/`)
- `license_key`: una llave (tipo licencia) que identifica/autoriza esa instalación/app contra tu backend

En el código, esto se carga al arrancar en [AppConfig](file:///c:/Users/Tomito/Documents/Haniel/APP_EX_ANDRIO/affiliatepro_mobile_v1/lib/config/app_config.dart) y luego se usa en [ApiService](file:///c:/Users/Tomito/Documents/Haniel/APP_EX_ANDRIO/affiliatepro_mobile_v1/lib/service/api_service.dart).

Recomendación:
- No publiques tu `license_key` en repositorios públicos.
- Mantén `base_url` con `https://` y terminando en `/`.

### 2) Cómo viajan las peticiones (HTTP)
La app usa `Dio` para llamar endpoints del backend:
- GET: [ApiService.getData](file:///c:/Users/Tomito/Documents/Haniel/APP_EX_ANDRIO/affiliatepro_mobile_v1/lib/service/api_service.dart#L42-L60)
- POST: [ApiService.postData / postData2](file:///c:/Users/Tomito/Documents/Haniel/APP_EX_ANDRIO/affiliatepro_mobile_v1/lib/service/api_service.dart#L85-L128)

La URL final se arma así:
- `base_url + endPoint`

Ejemplo (materiales):
- `https://tu-dominio.com/api/get_marketing_materials/{product_id}`

### 3) Token de usuario (sesión)
Después del login, el backend entrega un `token`. La app lo guarda en `SharedPreferences` y lo reusa.

Cuando hay token, la app lo manda en el header:
- `Authorization: <token>`

Por eso verás que muchos controladores hacen:
- leer usuario/token desde `SharedPreference.getUserData()`
- llamar a `ApiService` con `token: token`

Ejemplo real (banners y links):
- [BannerAndLinksController.getBannerAndLinksData](file:///c:/Users/Tomito/Documents/Haniel/APP_EX_ANDRIO/affiliatepro_mobile_v1/lib/controller/bannerAndLinks_controller.dart#L46-L85)

### 4) Validación de licencia (la “llave”)
La app tiene un método para validar licencia en backend:
- [ApiService.validateLicense](file:///c:/Users/Tomito/Documents/Haniel/APP_EX_ANDRIO/affiliatepro_mobile_v1/lib/service/api_service.dart#L29-L39)

La idea típica es:
- App arranca → lee `base_url` y `license_key`
- App valida la llave contra el backend (si tu flujo lo usa)
- Si es válida, permite continuar (login/uso normal)

Si vas a replicar este modelo para otra app, mantén el mismo patrón:
- Un dominio base por “instancia”
- Una llave/licencia asociada a ese dominio/cliente

### 5) Si creas otra app (misma nube, diferente “cliente”)
Si tú creas otra app (otro branding o para otro cliente), lo más común es:
- Cambiar `assets/config.json` con otro `base_url` y otro `license_key`
- Cambiar íconos/nombre/paquete (Android/iOS)
- Recompilar el APK/IPA

La comunicación seguirá igual:
- La app solo es “cliente”
- El backend controla datos, permisos y licenciamiento

### 6) Qué debes mantener igual para que sea consistente
- Respuestas JSON consistentes (ej: `status/success`, `message`, `data`)
- IDs coherentes entre endpoints (por ejemplo, que el `product_id` que usa marketing sea el mismo que la app envía)
- Tokens vigentes y manejo de expiración (si tu backend expira tokens)

---

## 📜 Changelog Reciente

## Versión 1.2.1.1 - Hotfix Total
> * **V1.2.1.1 - Hotfix Total**: Reparación de visibilidad de etiquetas de gráfica (L y D) con padding optimizado y reservedSize de 40px.
> * **Membership Restoration**: Restaurado el estado de membresía activa (Gold, Platinum, Ultra) en el Dashboard, eliminando el mensaje erróneo de "Inactivo".
> * **Persistence Fix**: Garantizada la persistencia de datos y sesión mediante el uso constante de SharedPreferences en todos los controladores de reportes y pedidos.

## Versión 1.2.1 - Estabilización de Registro
> * **UI Emergency Fix**: Corregida duplicidad de etiquetas en eje X y aplicado padding extremo de 50px para visibilidad total de Lunes y Domingo.
> * **Final UI Fix**: Implementado ajuste de rango minX/maxX (-0.8 a 6.8) en gráfico para visibilidad total de etiquetas (L y D) y sincronización de actividades privadas confirmada con traducción "Bono de Membresía" e icono de membresía neón.
> * **Visual Style Update**: Añadido resplandor neón al Balance Total y asegurada la línea Rojo Neón en el gráfico para estados sin actividad.
> * **UI Structural Fix**: Ajustado el padding lateral del gráfico a 45px para garantizar visibilidad total de días extremos y limpieza de placeholders de actividad.
> * **UI Clean Up**: Corregido el espaciado del gráfico para visualización de días y eliminada la visualización de datos globales en actividades recientes para mostrar solo datos del perfil activo.
> * **UI Final Fix**: Corregido el padding horizontal del gráfico para visibilidad total de días y aplicada traducción de strings de la API en tiempo real.
> * **UI/UX Hotfix**: Corregido el espaciado de los días en el gráfico y añadida lógica de traducción para las actividades reales de la API.
> * **Full Integration**: Dashboard 100% dinámico. Conectados datos reales de gráfico semanal y actividades recientes desde el nuevo endpoint de la API.
> * **Dashboard Update**: Implementada gráfica de montaña con color dinámico (Rojo/Verde) según el rendimiento real del usuario.
> * **Dashboard Final**: Gráfico de montaña Edge-to-Edge, sincronización de rango real y mapeo de eventos de inicio basados en el plan del usuario.
> * **Dashboard Refinement**: Sincronización de rango real desde API, ajuste de gráfico a ancho completo (Edge-to-Edge) y corrección de navegación en perfil.
> * **Hotfix Crítico**: Reparada la falta de reactividad en la sección de premios adicionales en Beneficios. Ahora los premios se filtran y limpian correctamente al navegar entre rangos.
> * **Bug Fix**: Sincronizada la actualización de premios canjeables adicionales con el cambio de página del carrusel de rangos.
> * **Mejora de experiencia en Beneficios**: Implementada lógica de validación para premios canjeables adicionales y estados dinámicos del botón de canje.
> * **UI Upgrade en Beneficios**: Implementados indicadores de página (dots) dinámicos con estilo Neón para la navegación de rangos.
> * **UI Hotfix**: Reparación de layout en Login. Se ajustó el scroll y la distribución de elementos para evitar que el logo se corte en la parte superior tras la inclusión del bloque de texto inferior.
> * **UI Hotfix**: Eliminada franja negra superior en Login. Se configuró diseño inmersivo para evitar que el logo se corte y se ajustó la posición para un equilibrio visual perfecto.
> * **UI Hotfix**: Reparación de composición visual en Login. Se añadió margen superior de 80px para equilibrar el diseño, separar los elementos del borde superior de la pantalla y evitar que se corten las letras.
> * **UI Hotfix**: Reparación de composición visual en Login. Se añadió margen superior de 50px para equilibrar el diseño y separar los elementos del borde superior de la pantalla.
> * **UI Hotfix**: Reparación de renderizado en Login. Se añadió margen superior para corregir el desfase visual de los elementos después de la animación de intro.
> * **Lógica de negocio**: Implementado mapeo dinámico de estados de comisión basado en el campo 'commission_status' de la API.
> * **UI Hotfix**: Eliminación definitiva del color morado #FFFF00FF en la Billetera, restableciendo la paleta binaria Verde/Fucsia Neón.
> * **UI Enhancement**: Rediseño estético de la Billetera implementando degradados profundos, resplandores neón y badges dinámicos para transacciones.
> * **Corrección de construcción**: Implementada inyección directa de WalletController en WalletPage para eliminar el error de 'not found' y asegurar carga instantánea.
> * **V1.2.1 - Registro**: Corregido error de dependencia faltante (LoginController). Ahora la pantalla de registro inicializa correctamente sus dependencias al entrar.
> * **Sincronización de interfaz de membresías**: El carrusel ahora inicia en el plan activo del usuario y solo esa tarjeta muestra el borde neón, eliminando distracciones visuales en los demás planes.
> * **Sincronización de registro de Proveedor**: Campo 'Empresa' renombrado a 'Nombre de tu tienda' y movido al final del formulario para coincidir con la arquitectura Web.

## Versión 1.2.0 - Actualización de Beneficios y Rediseño Neón
> * Implementación de la nueva sección "Beneficios EX" con lógica dinámica de canje.
> * Rediseño total de la interfaz bajo estética Neón Brutal (Verde y Fucsia).
> * Corrección de errores críticos de sincronización en Membresías e Historial de Compras.
> * Optimización tipográfica en el apartado de Lecciones para mayor limpieza visual.
> * Estabilización del flujo de Cierre de Sesión.

### [2026-03-18]
- **V4.3 - Eventos Flash**: Implementación de filtro de expiración en tiempo real. Los eventos con cronómetro en cero o fecha de fin superada se ocultan automáticamente de la vista del usuario.
- **V4.4 - IA Marketing Center**: Rediseño visual de tarjetas estilo 'Z1', implementación de historial local de copys generados y modal completo para exploración de plantillas.
- **V4.5 - IA Marketing**: Sincronización de nomenclatura con el diseño original, implementación de persistencia para el historial de copys y activación de la función de copiado real.
- **V4.6 - IA Marketing**: Eliminación de overflow en Banners, corrección del motor de copiado y unificación de buscadores predictivos en todo el Centro de IA.
- **V4.7 - HotFix Crítico**: Eliminación de redundancia en Banners, corrección de error de aserción en Autocomplete y restauración de flujo de UI limpio.
- **V4.9 - HotFix de Contenido**: Implementación de prompt restrictivo agresivo para textos cortos de IA. Mejora de UX en cuadrícula de banners mostrando precio y comisión directamente.
- **V5.0 - UI Banners**: Rediseño completo de la vista de cuadrícula. Se añadieron estrellas de calificación y se organizó la información de Precio/Ganancia en un formato de doble columna para mejor legibilidad.
- **V5.1 - Perfil**: Sincronización del modal de membresía con datos reales de la API. Implementación de cálculo dinámico para días de vencimiento.
- **V5.2 - Membresía**: Eliminación definitiva de datos quemados (hardcoded). Implementación de lógica de días restantes basada en el servidor y mapeo dinámico del nombre del plan.
- **UI Cleanup**: Mejora de la interfaz cuando no hay eventos activos con mensajes amigables.
- **V5.4 - Login UI/UX**: Corrección de error de Overlay persistente al fallar el login. Implementación de SnackBar de error y refinamiento visual de campos de texto estilo neón.
- **V5.5 - HotFix Login**: Eliminación de error de valor nulo al fallar credenciales. Implementación de manejo de errores mediante SnackBar seguro y limpieza de estado de carga.
- **V5.6 - UI/UX Refinement**: Traducción de errores de autenticación al español y rediseño del Header de misiones con textos en degradado neón.
- **V5.8 - UI Premios Premium**: Rediseño completo de la sección de premios canjeables, utilizando un layout de tarjetas detallado (estrellas, precio, ganancia) y un modal de canje con mensaje de confirmación.
- **V5.9 - Rangos**: Sincronización real con API get_award_levels. Eliminación de datos de prueba y mapeo de premios físicos, niveles y bonos reales.
- **V6.0 - Rangos**: Separación de Recompensa de Rango (Viaje) de la nueva sección de Premios Canjeables Adicionales (Hamburguesas, Descuentos). Integración de Prizes API y modal de canje.
- **V6.1 - Rangos**: Solución a premios vacíos. Implementación de doble consumo de API (Niveles + Premios Adicionales) y renderizado dinámico de estados de canje.
- **V6.2 - API Fix**: Corrección de endpoint 404 para premios canjeables. Ajuste de mayúsculas en la ruta y eliminación de caracteres basura en la URL de consulta.
- **V6.3 - UX**: Sincronización del nivel inicial del carrusel con el rango real del usuario. Mejora de estados vacíos en la sección de beneficios adicionales.
- **V6.8 - Debug**: Activación de logs de consola para auditoría de API de Ranking sin alteración de interfaz gráfica.
- **V6.9 - Debug Crítico**: Silenciado de logs de dashboard y activación de trazas exclusivas para auditoría de Ranking Global.
- **V7.0 - API Fix Ranking**: Corrección de método HTTP (de GET a POST) para resolver error 405. Habilitación de flujo de datos para mostrar ranking completo.
- **V7.1 - Ranking Fix**: Ajuste de ruta Api/ con mayúscula y re-verificación de métodos HTTP para eliminar error 405 persistente.
- **V7.2 - Ranking**: Regreso a ruta User/ con validación de tipo de respuesta para evitar crashes por HTML 404 del servidor.
- **V7.3 - Ranking**: Implementación final del endpoint /EX/Api/ con método GET. Sincronización de lista global con datos reales de producción.
- **V7.4 - Ranking**: Conexión final con el controlador Api.php en la ruta /EX/. Mapeo de avatares reales y montos desde el servidor. Estrategia de reintento para rutas alternativas.
- **V7.5 - Ranking**: Eliminación de subdirectorio /EX/ tras confirmar error 404. Ajuste a ruta raíz /Api/ con método GET según estandarización del backend. Mapeo de seguridad para avatares nulos.
- **V7.6 - Ranking**: Código estandarizado según documentación del backend. Implementado modo de espera y reintento manual mientras el servidor activa el endpoint real.
- **V7.7 - Ranking**: Conexión exitosa con data de producción. Implementación de ranking real (4 usuarios actuales), mapeo de avatares reales (CachedNetworkImage) y posición dinámica del usuario logueado (#3 de 4).
- **V7.8 - Ranking**: UI preparada para scroll dinámico. Confirmado que la App procesa el 100% de la data enviada por el servidor (actualmente 4 registros). Manejo de saldos en cero.
- **V7.9 - Ranking**: Implementación de Cache-Busting para forzar la recepción de datos frescos del servidor. La App queda a la espera de que el backend libere los 40+ usuarios prometidos.
- **V8.0 - Ranking UI Final**: Implementación de podio estático para Top 3, lista scrolleable para resto de usuarios y fijación de widget de ranking personal en la base de la pantalla. Mejora de lógica de iniciales en avatares.
- **V8.1 - Ranking UI**: Eliminación visual de barra de scroll lateral, fijación de podio Top 3 y optimización de widget de ranking personal (pegado al borde inferior). Sincronización dinámica de datos.
- **V8.2 - Auditoría de Volumen**: Confirmado que la App procesa el 100% de lo recibido. Eliminación visual de scrollbars para estética neón y ajuste de padding inferior en widget de ranking personal.
- **V8.3 - Ranking**: Estética mejorada con eliminación de scrollbars y avatares con iniciales neón. Confirmada recepción limitada de 12 registros por parte del servidor.
- **V9.0 - Versión Final de Ranking**: Sincronización completa con el servidor. UI optimizada para 12 usuarios reales. Modo de producción activado (logs limpios). Mensaje personalizado para el líder del ranking.
- **V9.1 - Ranking**: Implementación de contadores dinámicos de total de usuarios y saldo personal en el encabezado. Estilo neón vibrante.
- **V10.0 - Mi Red**: Sincronización real de árbol de referidos y corrección de rango (Plan vs Rango Carrera). Visualización basada en datos de producción.
- **V10.1 - Mi Red**: Corrección crítica. Eliminación de rangos ficticios y limpieza de red para mostrar solo datos reales (0 afiliados, 0 rango).
- **V10.2 - Mi Red**: Eliminación de etiqueta genérica 'Socio'. Implementación de etiquetas dinámicas basadas en el Plan (Ultra) y estado de carrera real.
- **V11.0 - Mi Red**: Configuración final para perfiles nuevos. Mapeo dinámico de Plan Ultra y visualización limpia de red inicial (0 datos).
- **V11.1 - Mi Red**: Reparación de extracción de avatares desde tags HTML y corrección de visualización de Plan Ultra desde el Dashboard.
- **V12.0 - Hotfix**: Reparación de error null en login/logout y restauración de flujo de navegación seguro.
- **V13.0 - Inicio**: Sincronización real del Plan de Membresía (Ultra) y cálculo dinámico de días restantes basado en la fecha de expiración de la API.
- **V13.1 - Inicio**: Preparada la arquitectura para recibir el Plan Real desde la API de Dashboard. Implementada lógica de conteo de días regresivo y estados neón.
- **V13.2 - Inicio**: Eliminados datos estáticos de membresía. Implementado estado de carga real ("Sincronizando...") a la espera de actualización de API por parte del backend.
- **V14.0 - Inicio**: Sincronización total con la nueva API. Plan y Rango de carrera ahora son 100% reales y dinámicos con estilo neón.
- **V14.1 - Inicio**: Corrección de flujo de inicialización. Forzada la carga del Dashboard sobre la de pagos para garantizar datos reales de membresía. Eliminados rastros de "Plan Proveedor".
- **V14.2 - Inicio**: Exterminio de strings estáticos y log de auditoría profunda para la respuesta del Dashboard. Limpieza agresiva de controladores al iniciar sesión.
- **V15.0 - Inicio**: Sincronización exitosa total. Eliminación de datos 'hardcoded' y conexión real con el campo plan_name del servidor. Corregido fallo de reactividad.
- **V15.1 - Inicio**: Pulido estético del nombre del plan. Implementado filtro para ocultar el precio en paréntesis y mostrar solo el nombre comercial del plan. Ajuste en el cálculo de días restantes para mayor precisión.
- **V16.0 - Academia**: Activado el sistema de filtrado dinámico. Implementada lógica de ordenamiento eficiente para evitar recargas pesadas de imágenes. Uso de CachedNetworkImage para optimización de rendimiento y estética neón en BottomSheet.
- **V17.0 - Membresía**: Rediseño brutal y premium. Implementada tarjeta destacada de plan actual con selección neón fucsia dinámica para el Plan Ultra ($100). Estética neón fucsia y verde sobre fondo negro absoluto.
- **V17.1 - Membresía**: Hotfix de error null. Implementación final del diseño premium con carga segura de datos. Detección automática de plan actual y navegación horizontal fluida.
- **V17.2 - Membresía**: Corregido error de nulo en el constructor de la página. Implementado estado de carga (Loading) neón para proteger la construcción del widget hasta recibir respuesta de la API. Blindaje en la navegación desde el Menú Lateral.
- **V18.0 - Fix Logout**: Restauración de dependencias de Login tras limpieza de caché. Corregido error de controlador no encontrado al re-ingresar. Implementado blindaje en la pantalla de acceso para auto-recuperación de controladores.
- **V18.1 - Historial**: Corregido error de desbordamiento (Overflow) en la lista de compras y limpieza de visualización de ID de transacción. Implementada estética neón premium en tarjetas de historial con estados dinámicos.
- **V18.2 - Historial**: Corregido mapeo de JSON crudo en la interfaz y reparado error de carga en el primer intento mediante inicialización prioritaria del controlador. Refinado diseño neón con badges de alto contraste y alineación optimizada.
- **V18.3 - Historial**: Corregido error de carga diferida al primer ingreso. Implementada reactividad total con Obx y logs de seguimiento de red. Inicialización forzada en onInit con Future.microtask.
- **V18.4 - Historial**: Corregido error de inyección de dependencia (MembershipController not found). Implementada inyección automática y carga de datos garantizada desde el menú lateral y la propia página.
- **V18.5 - Membresía**: Reparada inicialización de la página de compra. Ahora la lista de planes carga automáticamente al primer ingreso mediante microtask y Obx. Implementados logs de auditoría para el proceso de compra.
- **V19.0 - Estructura**: Separación definitiva de Premios y Eventos. Eliminada sección de premios en Eventos Flash. Rediseño premium de Beneficios EX eliminando campos irrelevantes. Implementado flujo de canje con confirmación neón y mensaje de éxito del administrador.
- **V19.1 - Rangos**: Conectada la lógica de misiones con la API real. Implementado sistema de bloqueo/desbloqueo de premios basado en cumplimiento de metas (Ventas, Patrocinios, Socios). Implementado Sticky Header con Glassmorphism y barra de progreso real.
- **V19.2 - Rangos**: Sincronizado el bloqueo visual del botón de canje con el rango real (Gris Mate para Nivel 0). Eliminados campos irrelevantes de premios adicionales. Header Persistente consolidado para 'BENEFICIOS EX'.
- **V19.3 - Rangos**: Solucionado error persistente en el botón de canje. Eliminado texto extra y deshabilitado físicamente el botón (Gris Mate) para nivel 0. Sincronización estética total con el candado de bloqueo.
- **V19.4 - Beneficios**: Bloqueo físico y visual (Gris Mate #2A2A2A) absoluto del botón de canje para usuarios nivel 0. Eliminación definitiva de funciones de enlace/compartir y precios residuales en el widget de premios.
- **V19.6 - Beneficios**: Solucionado error de flujo. Deshabilitado físicamente el botón de canje (onPressed: null) para evitar la apertura accidental del modal en usuarios sin rango. Estética Gris Mate consolidada.
- **V19.7 - Beneficios**: Solucionado error crítico de flujo. Deshabilitado físicamente el botón de canje (onPressed: null) para evitar la apertura accidental del modal en usuarios sin rango. Estética Gris Mate consolidada con bloqueo absoluto.
- **V19.8 - Beneficios**: Bloqueo físico real (onPressed: null) del botón de canje. Se eliminó la apertura accidental del modal en niveles inferiores. Estética Gris Mate consolidada.
- **V19.9 - Beneficios**: Sincronización estricta con el campo 'status' de la API. Bloqueo físico (onPressed: null) y visual (Gris Mate) para todos los premios marcados como Locked.
- **V20.0 - Beneficios**: Bloqueo físico real vinculado al status del Nivel Plata en la API. Se eliminó la inconsistencia visual que permitía clics en premios bloqueados. Estética Gris Mate consolidada. Fix: Corregido acceso a la data de niveles en el controlador.
- **V20.1 - Cursos**: Reducción del tamaño de fuente en títulos de lecciones con imagen grande. Se optimizó la tipografía para mejorar la claridad visual y evitar el efecto 'doble título'.

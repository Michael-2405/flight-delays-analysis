# Hoja de Ruta — Proyectos de Datos

Guía de referencia para proyectos de **análisis de datos** e **ingeniería de datos**.
Cada etapa incluye una checklist y una explicación corta de qué hacer y por qué.

---

## Cómo usar esta guía

Los dos caminos comparten las primeras etapas. A partir de la etapa 4 se separan:

```
Etapa 1 → Etapa 2 → Etapa 3
                           ↓               ↓
                    Análisis        Ingeniería
                   (Etapa 4A)      (Etapa 4B)
                       ↓               ↓
                   Etapa 5A        Etapa 5B
                       ↓               ↓
                   Etapa 6A        Etapa 6B
```

---

## Etapa 1 — Entender el problema

Antes de tocar cualquier dato, entender qué pregunta se está respondiendo o qué sistema se está construyendo.

**Checklist:**
- [ ] ¿Cuál es la pregunta de negocio o el objetivo del pipeline?
- [ ] ¿Quién va a consumir el resultado? (analista, dashboard, otro sistema)
- [ ] ¿Cuál es el output esperado? (reporte, tabla, API, visualización)
- [ ] ¿Cuál es el nivel de granularidad necesario? (por día, por cliente, por transacción)
- [ ] ¿Hay restricciones de tiempo, volumen o privacidad?
- [ ] Documentar todo esto en el README del proyecto

**Por qué importa:** sin una pregunta clara, el proyecto no tiene dirección y es fácil perderse en los datos.

---

## Etapa 2 — Conocer las fuentes de datos

Entender de dónde vienen los datos antes de procesarlos.

**Checklist:**
- [ ] ¿Cuáles son las fuentes? (CSV, Excel, API, base de datos, JSON)
- [ ] ¿Con qué frecuencia se actualizan? (batch diario, tiempo real, histórico)
- [ ] ¿Quién es el dueño de los datos?
- [ ] ¿Hay documentación del schema o diccionario de datos?
- [ ] ¿Hay restricciones de acceso o datos sensibles (PII)?
- [ ] Descargar o conectar a una muestra pequeña primero

**Por qué importa:** conocer la fuente evita sorpresas al escalar y define la estrategia de ingesta.

---

## Etapa 3 — Exploración inicial (EDA)

Primera mirada a los datos para entender su estructura, calidad y contenido.
Esta etapa se hace en un Jupyter Notebook, nunca directamente sobre producción.

**Checklist:**

**Estructura:**
- [ ] ¿Cuántas filas y columnas tiene el dataset?
- [ ] ¿Cuáles son los tipos de datos de cada columna?
- [ ] ¿El schema coincide con lo esperado?

**Calidad:**
- [ ] ¿Cuántos valores nulos hay por columna? (`df.isnull().sum()`)
- [ ] ¿Hay duplicados? (`df.duplicated().sum()`)
- [ ] ¿Hay valores fuera de rango o imposibles? (edades negativas, fechas futuras)
- [ ] ¿Los tipos de datos son correctos? (fechas como strings, números como texto)

**Contenido:**
- [ ] ¿Cuáles son los valores únicos en columnas categóricas?
- [ ] ¿Cuál es la distribución de las columnas numéricas? (min, max, media, percentiles)
- [ ] ¿Hay outliers evidentes?
- [ ] ¿Cuál es el rango de fechas del dataset?

**Relaciones:**
- [ ] ¿Qué columna es la llave primaria o identificador único?
- [ ] ¿Hay columnas que deberían relacionarse entre sí?
- [ ] ¿Hay columnas correlacionadas?

**Por qué importa:** el EDA define todas las decisiones de limpieza y transformación que vienen después.

---

## Camino A — Análisis de Datos

### Etapa 4A — Limpieza y preparación

Transformar los datos crudos en un dataset limpio y confiable para el análisis.

**Checklist:**
- [ ] Decidir estrategia para nulos (eliminar fila, imputar con media/moda, dejar como null)
- [ ] Eliminar o marcar duplicados
- [ ] Corregir tipos de datos (parsear fechas, convertir strings a números)
- [ ] Normalizar texto (mayúsculas, espacios, caracteres especiales)
- [ ] Crear columnas derivadas si son necesarias (año, mes, categoría calculada)
- [ ] Filtrar registros irrelevantes para el análisis
- [ ] Documentar cada decisión de limpieza y por qué

**Por qué importa:** análisis sobre datos sucios produce conclusiones incorrectas.

---

### Etapa 5A — Análisis y métricas

Responder las preguntas definidas en la Etapa 1 con los datos limpios.

**Checklist:**
- [ ] Calcular las métricas clave del negocio
- [ ] Segmentar por las dimensiones relevantes (tiempo, región, categoría)
- [ ] Identificar tendencias, patrones y anomalías
- [ ] Comparar períodos o grupos si aplica
- [ ] Documentar hallazgos importantes en el notebook
- [ ] Separar correlación de causalidad en las conclusiones

**Herramientas:** Polars/Pandas para agregaciones, SQL para consultas sobre bases de datos.

---

### Etapa 6A — Visualización y comunicación

Comunicar los hallazgos de forma clara para la audiencia objetivo.

**Checklist:**
- [ ] Elegir el tipo de gráfico correcto según lo que se quiere mostrar:
  - Tendencia en el tiempo → líneas
  - Comparación entre categorías → barras
  - Distribución → histograma o boxplot
  - Relación entre variables → scatter
  - Proporción → pie o treemap (con cuidado)
- [ ] Usar títulos descriptivos en cada gráfico
- [ ] Incluir unidades y contexto en los ejes
- [ ] Evitar gráficos que distorsionen la percepción
- [ ] Construir dashboard en Power BI, Metabase o Superset
- [ ] Escribir un resumen ejecutivo con los hallazgos principales
- [ ] Revisar que las conclusiones responden la pregunta original

---

## Camino B — Ingeniería de Datos

### Etapa 4B — Diseño del pipeline y modelo de datos

Definir la arquitectura antes de escribir código.

**Checklist:**

**Arquitectura Medallón:**
- [ ] Definir qué va en Bronze (datos crudos, sin transformar)
- [ ] Definir qué va en Silver (datos limpios, tipados, sin duplicados)
- [ ] Definir qué va en Gold (modelo dimensional listo para consumo)

**Modelo dimensional (si aplica):**
- [ ] Identificar el proceso de negocio que se va a modelar
- [ ] Definir la tabla de hechos (qué se mide) y su granularidad
- [ ] Definir las tablas de dimensiones (quién, qué, cuándo, dónde)
- [ ] Diseñar el modelo estrella en papel o herramienta de diagramas
- [ ] Definir las llaves surrogadas (surrogate keys)
- [ ] Definir las columnas de auditoría (`created_at`, `updated_at`, `source`)

**Pipeline:**
- [ ] Definir el flujo: fuente → Bronze → Silver → Gold
- [ ] Definir la estrategia de carga (full load vs incremental)
- [ ] Definir la frecuencia de ejecución

**Por qué importa:** un buen diseño previo evita refactorizaciones costosas después.

---

### Etapa 5B — Construcción del pipeline

Implementar el pipeline ETL/ELT siguiendo el diseño.

**Checklist:**

**Bronze — Ingesta:**
- [ ] Extraer datos de la fuente sin transformar
- [ ] Guardar en formato raw (parquet, CSV, tabla de staging)
- [ ] Agregar columnas de auditoría (`ingested_at`, `source_file`)
- [ ] Validar que la ingesta fue completa (conteo de registros)

**Silver — Limpieza:**
- [ ] Aplicar las mismas correcciones identificadas en el EDA
- [ ] Tipar correctamente todas las columnas
- [ ] Eliminar o manejar nulos según la regla de negocio
- [ ] Eliminar duplicados con criterio claro
- [ ] Validar schema con Pandera o Great Expectations

**Gold — Modelo dimensional:**
- [ ] Crear o actualizar tablas de dimensiones (SCD si aplica)
- [ ] Crear o actualizar tabla de hechos
- [ ] Aplicar joins y agregaciones definidas en el diseño
- [ ] Validar integridad referencial

**Por qué importa:** separar en capas permite debuggear por etapa y reprocesar sin perder datos.

---

### Etapa 6B — Orquestación, calidad y entrega

Hacer el pipeline confiable, observable y reproducible.

**Checklist:**

**Calidad de datos:**
- [ ] Definir expectativas (rangos válidos, no nulos críticos, unicidad)
- [ ] Implementar tests con Pandera o dbt tests
- [ ] Agregar alertas si la calidad falla

**Orquestación con Prefect:**
- [ ] Definir el flow principal con sus tasks
- [ ] Configurar reintentos en caso de fallo
- [ ] Agregar logging en cada paso
- [ ] Configurar schedule si es periódico

**DevOps del pipeline:**
- [ ] Dockerfile o docker-compose para el entorno
- [ ] Variables de entorno en `.env` (nunca credenciales en el código)
- [ ] CI con GitHub Actions: lint, tests, validación de schema
- [ ] README con instrucciones para correr el pipeline localmente

**Documentación:**
- [ ] Diccionario de datos de las tablas Gold
- [ ] Diagrama del modelo de datos
- [ ] Descripción del flujo de datos end-to-end

---

## Reglas generales para cualquier proyecto de datos

Estas aplican sin importar el camino:

1. **Nunca modificar datos crudos.** Bronze es de solo lectura una vez ingestado.
2. **Todo cambio en el schema va a control de versiones.** No alterar tablas directamente en producción.
3. **Documentar las decisiones, no solo el código.** ¿Por qué se descartó esa columna? ¿Por qué se eligió esa granularidad?
4. **Empezar con un subconjunto pequeño.** Validar el pipeline con 1000 filas antes de correr millones.
5. **Los tests van desde el inicio, no al final.**
6. **Un notebook es para explorar, no para producción.** El código de producción va en scripts `.py`.
7. **Versionar el schema de la base de datos** igual que se versiona el código.

---

## Plantilla de README para proyectos de datos

```markdown
# Nombre del Proyecto

## Objetivo
¿Qué pregunta responde o qué pipeline construye?

## Arquitectura
Diagrama o descripción del flujo de datos.

## Fuentes de datos
| Fuente | Formato | Frecuencia |
|--------|---------|------------|
|        |         |            |

## Modelo de datos
Descripción de tablas principales y relaciones.

## Cómo correr el proyecto
\`\`\`bash
# Instrucciones paso a paso
\`\`\`

## Stack
- Python 3.12
- Polars
- dbt-postgres
- Prefect
- PostgreSQL
- Docker

## Decisiones de diseño
Registrar aquí las decisiones importantes y por qué se tomaron.
```

---

*Última actualización: mayo 2026*

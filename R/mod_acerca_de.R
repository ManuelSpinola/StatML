# ============================================================
# mod_acerca_de.R — Acerca de StatML
# StatML · StatSuite
# Manuel Spínola · ICOMVIS · UNA · Costa Rica
# ============================================================

#' @noRd
mod_acerca_de_ui <- function(id) {
  ns <- NS(id)

  div(class = "p-4",
    fluidRow(
      column(8,
        # ── Descripción ───────────────────────────────────
        h3(tagList(bsicons::bs_icon("cpu", class = "me-2"), "StatML")),
        p(class = "lead",
          "Plataforma interactiva de ", strong("machine learning supervisado"),
          " para ecología, ciencias de la biodiversidad y ciencia de datos.
           Parte del ecosistema ", strong("StatSuite"), "."),
        hr(),

        # ── Módulos ───────────────────────────────────────
        h5("Módulos disponibles"),
        fluidRow(
          column(6,
            div(class = "card mb-3",
              div(class = "card-header",
                  tagList(bsicons::bs_icon("graph-up"), " Regresión")),
              div(class = "card-body",
                tags$ul(class = "small mb-0",
                  tags$li(strong("Regresión lineal (LM)"),
                    " — Predicción de variables continuas con mínimos cuadrados.
                      Enfoque predictivo con train/test y validación cruzada."),
                  tags$li(strong("Random Forest Regresión"),
                    " — Ensemble de árboles para regresión. Captura relaciones
                      no lineales e interacciones. Tuning de hiperparámetros con grid search.")
                )
              )
            )
          ),
          column(6,
            div(class = "card mb-3",
              div(class = "card-header",
                  tagList(bsicons::bs_icon("diagram-3"), " Clasificación")),
              div(class = "card-body",
                tags$ul(class = "small mb-0",
                  tags$li(strong("Clasificación GLM"),
                    " — Regresión logística para variables binarias.
                      Curva ROC, umbral ajustable, Hosmer-Lemeshow."),
                  tags$li(strong("Random Forest Clasificación"),
                    " — Ensemble de árboles para clasificación. AUC, matriz
                      de confusión y métricas extendidas.")
                )
              )
            )
          )
        ),
        hr(),

        # ── StatSuite ─────────────────────────────────────
        h5("El ecosistema StatSuite"),
        p(class = "small",
          "StatML forma parte de ", strong("StatSuite"),
          ", un conjunto de aplicaciones Shiny para análisis de datos ecológicos:"),
        fluidRow(
          column(4,
            tags$ul(class = "small",
              tags$li(strong("StatFlow"), " — Primeros pasos en análisis de datos"),
              tags$li(strong("StatDesign"), " — Diseño de estudios y muestreo"),
              tags$li(strong("StatModels"), " — Modelación estadística inferencial")
            )
          ),
          column(4,
            tags$ul(class = "small",
              tags$li(strong("StatML"), " — Machine learning ← esta app"),
              tags$li(strong("StatGeo"), " — Análisis espacial y SIG"),
              tags$li(strong("StatOccu"), " — Modelos de ocupación"),
              tags$li(strong("StatMonitor"), " — Monitoreo de biodiversidad")
            )
          )
        ),
        hr(),

        # ── Paquetes ──────────────────────────────────────
        h5("Principales paquetes utilizados"),
        fluidRow(
          column(4,
            tags$ul(class = "small",
              tags$li(strong("tidymodels"), " — Framework ML"),
              tags$li(strong("ranger"), " — Random Forest"),
              tags$li(strong("parsnip"), " — Especificación de modelos"),
              tags$li(strong("recipes"), " — Preprocesamiento")
            )
          ),
          column(4,
            tags$ul(class = "small",
              tags$li(strong("tune"), " — Tuning de hiperparámetros"),
              tags$li(strong("yardstick"), " — Métricas"),
              tags$li(strong("vip"), " — Importancia de variables"),
              tags$li(strong("pROC"), " — Curvas ROC")
            )
          ),
          column(4,
            tags$ul(class = "small",
              tags$li(strong("shiny"), " — Aplicación web"),
              tags$li(strong("bslib"), " — Interfaz Bootstrap 5"),
              tags$li(strong("plotly"), " — Gráficos interactivos"),
              tags$li(strong("DT"), " — Tablas interactivas")
            )
          )
        )
      ),

      column(4,
        # ── Autor ─────────────────────────────────────────
        div(class = "card mb-3",
          div(class = "card-header",
              tagList(bsicons::bs_icon("person-circle"), " Autor")),
          div(class = "card-body",
            h6("Manuel Spínola, PhD"),
            p(class = "small mb-1",
              bsicons::bs_icon("building", class = "me-1"),
              "Instituto Internacional en Conservación y Manejo de Vida Silvestre (ICOMVIS)"),
            p(class = "small mb-1",
              bsicons::bs_icon("geo-alt", class = "me-1"),
              "Universidad Nacional, Costa Rica"),
            p(class = "small mb-3",
              bsicons::bs_icon("envelope", class = "me-1"),
              tags$a(href = "mailto:manuel.spinola@una.cr",
                     "manuel.spinola@una.cr")),
            tags$a(href = "https://github.com/ManuelSpinola",
              target = "_blank",
              class = "btn btn-outline-secondary btn-sm w-100",
              tagList(bsicons::bs_icon("github", class = "me-1"), "ManuelSpinola")
            )
          )
        ),

        # ── Versión ───────────────────────────────────────
        div(class = "card mb-3",
          div(class = "card-header",
              tagList(bsicons::bs_icon("info-circle"), " Versión")),
          div(class = "card-body",
            tags$dl(class = "small mb-0",
              tags$dt("StatML"), tags$dd("v0.0.1"),
              tags$dt("Repositorio"),
              tags$dd(tags$a(href = "https://github.com/ManuelSpinola/StatML",
                             target = "_blank", "github.com/ManuelSpinola/StatML")),
              tags$dt("Licencia"), tags$dd("MIT")
            )
          )
        ),

        # ── Cita ──────────────────────────────────────────
        div(class = "card",
          div(class = "card-header",
              tagList(bsicons::bs_icon("quote"), " Citar como")),
          div(class = "card-body",
            p(class = "small mb-0",
              "Spínola, M. (2025). ",
              em("StatML: Plataforma interactiva de machine learning"),
              ". ICOMVIS, Universidad Nacional, Costa Rica. ",
              tags$a(href = "https://github.com/ManuelSpinola/StatML",
                     target = "_blank",
                     "https://github.com/ManuelSpinola/StatML"))
          )
        )
      )
    )
  )
}

#' @noRd
mod_acerca_de_server <- function(id) {
  moduleServer(id, function(input, output, session) {})
}

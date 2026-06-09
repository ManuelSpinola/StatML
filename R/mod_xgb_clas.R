# mod_xgb_clas.R — XGBoost Clasificación (StatML)

# UI -------------------------------------------------------------------------
mod_xgb_clas_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bslib::navset_card_tab(
      title = "XGBoost — Clasificación",

      # ── 1. ¿Qué es? ──────────────────────────────────────────────────────
      bslib::nav_panel(
        "¿Qué es?",
        icon = bsicons::bs_icon("info-circle"),
        br(),
        h4("XGBoost para clasificación"),
        p("XGBoost para clasificación predice la probabilidad de pertenencia a
          una clase usando gradient boosting. En clasificación binaria, minimiza
          la pérdida logística (log-loss) secuencialmente construyendo árboles
          que mejoran la discriminación entre clases."),
        p("Es uno de los algoritmos más competitivos en benchmarks de clasificación
          tabular, especialmente cuando los datos presentan patrones no lineales
          o interacciones complejas entre variables."),
        hr(),
        h5("Características clave"),
        tags$ul(
          tags$li(strong("Salida probabilística:"), " produce P(Y=1|X) que luego se umbraliza (por defecto 0.5)."),
          tags$li(strong("Boosting secuencial:"), " cada árbol corrige los errores de clasificación anteriores."),
          tags$li(strong("Regularización L1/L2:"), " controla la complejidad para evitar sobreajuste."),
          tags$li(strong("Manejo de desbalance:"), " el parámetro scale_pos_weight puede compensar clases desbalanceadas.")
        ),
        hr(),
        h5("¿Cuándo usar XGBoost para clasificación?"),
        tags$ul(
          tags$li("Clasificación binaria o multiclase con datos tabulares."),
          tags$li("Cuando Random Forest no alcanza el AUC deseado."),
          tags$li("Datos con muchas variables y posibles interacciones complejas."),
          tags$li("Cuando se necesita calibración fina de hiperparámetros.")
        )
      ),

      # ── 2. Fundamentos ───────────────────────────────────────────────────
      bslib::nav_panel(
        "Fundamentos",
        icon = bsicons::bs_icon("book"),
        br(),
        h4("Gradient Boosting para clasificación"),
        p("Para clasificación binaria, XGBoost optimiza la pérdida logística:"),
        p(em("L = -Σ [ y·log(p) + (1-y)·log(1-p) ]")),
        p("donde ", em("p = σ(F(x))"), " es la probabilidad predicha tras aplicar
          la función sigmoide sobre el score del ensemble."),
        hr(),
        h5("Del score a la probabilidad"),
        tags$ol(
          tags$li("XGBoost produce un ", strong("score continuo"), " F(x)."),
          tags$li("Se aplica la sigmoide: ", em("p = 1 / (1 + exp(-F(x)))"), "."),
          tags$li("Se aplica un umbral (por defecto 0.5) para obtener la clase predicha.")
        ),
        hr(),
        h5("Hiperparámetros clave"),
        tags$dl(
          tags$dt("trees"), tags$dd("Número de rondas de boosting."),
          tags$dt("tree_depth"), tags$dd("Profundidad máxima de cada árbol."),
          tags$dt("learn_rate"), tags$dd("Tasa de aprendizaje (shrinkage). Valores típicos: 0.01–0.3."),
          tags$dt("min_n"), tags$dd("Mínimo de observaciones por hoja."),
          tags$dt("sample_size"), tags$dd("Submuestreo de filas por árbol."),
          tags$dt("mtry"), tags$dd("Submuestreo de columnas por árbol.")
        ),
        hr(),
        h5("Métricas de evaluación"),
        tags$ul(
          tags$li(strong("AUC-ROC:"), " área bajo la curva ROC; mide discriminación entre clases (1 = perfecto)."),
          tags$li(strong("Accuracy:"), " proporción de predicciones correctas."),
          tags$li(strong("Sensibilidad (Recall):"), " proporción de positivos correctamente identificados."),
          tags$li(strong("Especificidad:"), " proporción de negativos correctamente identificados.")
        )
      ),

      # ── 3. Los datos ─────────────────────────────────────────────────────
      bslib::nav_panel(
        "Los datos",
        icon = bsicons::bs_icon("table"),
        br(),
        fluidRow(
          column(4,
            selectInput(ns("dataset"), "Dataset",
              choices = c(
                "Presencia/ausencia de aves (paisaje)" = "aves_pa_paisaje",
                "Frogs (rana)" = "frogs",
                "Sacramento (vivienda)" = "sacramento",
                "Titanic" = "titanic_ml",
                "Wine Quality (red)" = "winequality_red"
              )
            )
          )
        ),
        hr(),
        h5("Vista previa"),
        DT::DTOutput(ns("tabla_datos")),
        hr(),
        h5("Resumen"),
        verbatimTextOutput(ns("resumen_datos"))
      ),

      # ── 4. Explorar ──────────────────────────────────────────────────────
      bslib::nav_panel(
        "Explorar",
        icon = bsicons::bs_icon("bar-chart"),
        br(),
        fluidRow(
          column(4,
            uiOutput(ns("sel_y_exp")),
            uiOutput(ns("sel_x_exp"))
          )
        ),
        plotOutput(ns("plot_exp"), height = "400px"),
        hr(),
        h5("Distribución de clases"),
        plotOutput(ns("plot_clases"), height = "250px")
      ),

      # ── 5. Preprocesamiento ──────────────────────────────────────────────
      bslib::nav_panel(
        "Preprocesamiento",
        icon = bsicons::bs_icon("sliders"),
        br(),
        fluidRow(
          column(4,
            uiOutput(ns("sel_y_pre")),
            uiOutput(ns("sel_x_pre")),
            hr(),
            sliderInput(ns("prop_train"), "Proporción entrenamiento",
              min = 0.5, max = 0.9, value = 0.75, step = 0.05),
            numericInput(ns("semilla"), "Semilla", value = 123, step = 1),
            hr(),
            checkboxInput(ns("normalizar"), "Normalizar predictores (step_normalize)", value = TRUE),
            checkboxInput(ns("dummies"), "Crear dummies para variables categóricas (step_dummy)", value = TRUE)
          ),
          column(8,
            h5("División estratificada"),
            uiOutput(ns("info_split")),
            hr(),
            h5("Balance de clases"),
            tableOutput(ns("tabla_balance")),
            hr(),
            h5("Receta de preprocesamiento"),
            verbatimTextOutput(ns("info_receta"))
          )
        )
      ),

      # ── 6. Ajustar modelo ────────────────────────────────────────────────
      bslib::nav_panel(
        "Ajustar modelo",
        icon = bsicons::bs_icon("gear"),
        br(),
        fluidRow(
          column(4,
            h5("Tuning de hiperparámetros"),
            p(em("Búsqueda en grilla Latin Hypercube")),
            numericInput(ns("n_grid"), "Combinaciones en la grilla", value = 20, min = 10, max = 50),
            numericInput(ns("cv_folds"), "Folds para validación cruzada", value = 5, min = 3, max = 10),
            hr(),
            p(strong("Parámetros a optimizar:")),
            tags$ul(
              tags$li("trees: 100–2000"),
              tags$li("tree_depth: 1–15"),
              tags$li("learn_rate: 10⁻¹⁰ – 10⁻¹"),
              tags$li("min_n: 2–40"),
              tags$li("sample_size: 0.5–1.0")
            ),
            hr(),
            actionButton(ns("ajustar"), "Ajustar modelo",
              class = "btn-primary btn-lg", width = "100%",
              icon = shiny::icon("play"))
          ),
          column(8,
            h5("Resultado del tuning (AUC)"),
            plotOutput(ns("plot_tuning"), height = "350px"),
            hr(),
            h5("Mejores hiperparámetros"),
            tableOutput(ns("tabla_best"))
          )
        )
      ),

      # ── 7. Diagnóstico ───────────────────────────────────────────────────
      bslib::nav_panel(
        "Diagnóstico",
        icon = bsicons::bs_icon("heart-pulse"),
        br(),
        fluidRow(
          column(6,
            h5("Matriz de confusión — prueba"),
            plotOutput(ns("plot_confusion"), height = "350px")
          ),
          column(6,
            h5("Curva ROC — prueba"),
            plotOutput(ns("plot_roc"), height = "350px")
          )
        )
      ),

      # ── 8. Performance ───────────────────────────────────────────────────
      bslib::nav_panel(
        "Performance",
        icon = bsicons::bs_icon("speedometer2"),
        br(),
        h5("Métricas de entrenamiento vs. prueba"),
        fluidRow(
          column(6, uiOutput(ns("card_train"))),
          column(6, uiOutput(ns("card_test")))
        ),
        hr(),
        uiOutput(ns("interpretacion_overfitting")),
        hr(),
        h5("Validación cruzada — Top 5 combinaciones (AUC)"),
        tableOutput(ns("tabla_cv"))
      ),

      # ── 9. Predicciones ──────────────────────────────────────────────────
      bslib::nav_panel(
        "Predicciones",
        icon = bsicons::bs_icon("bullseye"),
        br(),
        h5("Predicciones en el conjunto de prueba"),
        DT::DTOutput(ns("tabla_pred")),
        hr(),
        downloadButton(ns("descargar_pred"), "Descargar predicciones (CSV)")
      ),

      # ── 10. Importancia ──────────────────────────────────────────────────
      bslib::nav_panel(
        "Importancia",
        icon = bsicons::bs_icon("star"),
        br(),
        h5("Importancia de variables (permutación, AUC)"),
        p(em("Mide cuánto disminuye el AUC al permutar aleatoriamente cada variable.")),
        plotOutput(ns("plot_importancia"), height = "400px"),
        hr(),
        tableOutput(ns("tabla_importancia"))
      ),

      # ── 11. PDP ──────────────────────────────────────────────────────────
      bslib::nav_panel(
        "PDP",
        icon = bsicons::bs_icon("graph-up"),
        br(),
        fluidRow(
          column(4,
            uiOutput(ns("sel_pdp_var")),
            numericInput(ns("pdp_grid"), "Puntos en la grilla", value = 30, min = 10, max = 100)
          )
        ),
        plotOutput(ns("plot_pdp"), height = "400px"),
        p(em("PDP: probabilidad predicha promedio de la clase positiva en función
              de la variable seleccionada, manteniendo el resto en sus valores observados."))
      ),

      # ── 12. Código R ─────────────────────────────────────────────────────
      bslib::nav_panel(
        "Código R",
        icon = bsicons::bs_icon("code-slash"),
        br(),
        p("Código reproducible para ajustar XGBoost de clasificación con tidymodels:"),
        verbatimTextOutput(ns("codigo_r"))
      )
    ) # end navset_card_tab
  )
}


# Server ---------------------------------------------------------------------
mod_xgb_clas_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # ── Datos ───────────────────────────────────────────────────────────────
    datos_raw <- reactive({
      req(input$dataset)
      path <- system.file("app/data", paste0(input$dataset, ".rda"),
                          package = "StatML")
      env <- new.env()
      load(path, envir = env)
      get(ls(env)[1], envir = env)
    })

    # ── Tab 3: Los datos ────────────────────────────────────────────────────
    output$tabla_datos <- DT::renderDT({
      DT::datatable(datos_raw(), options = list(pageLength = 8, scrollX = TRUE))
    })
    output$resumen_datos <- renderPrint({ summary(datos_raw()) })

    # ── Tab 4: Explorar ─────────────────────────────────────────────────────
    vars_factor <- reactive({
      df <- datos_raw()
      names(df)[sapply(df, function(x) is.factor(x) || is.character(x))]
    })
    vars_todas <- reactive({ names(datos_raw()) })

    output$sel_y_exp <- renderUI({
      selectInput(ns("y_exp"), "Variable respuesta (clase)",
        choices = vars_factor())
    })
    output$sel_x_exp <- renderUI({
      req(input$y_exp)
      vars_num <- names(dplyr::select(datos_raw(), where(is.numeric)))
      selectInput(ns("x_exp"), "Variable predictora (X)", choices = vars_num)
    })
    output$plot_exp <- renderPlot({
      req(input$y_exp, input$x_exp)
      df <- datos_raw()
      ggplot2::ggplot(df, ggplot2::aes(x = .data[[input$y_exp]],
                                        y = .data[[input$x_exp]],
                                        fill = .data[[input$y_exp]])) +
        ggplot2::geom_boxplot(alpha = 0.7) +
        ggplot2::geom_jitter(width = 0.2, alpha = 0.3, size = 1) +
        ggplot2::scale_fill_manual(values = stat_palette()) +
        stat_theme() +
        ggplot2::theme(legend.position = "none") +
        ggplot2::labs(x = input$y_exp, y = input$x_exp)
    })
    output$plot_clases <- renderPlot({
      req(input$y_exp)
      df <- datos_raw()
      ggplot2::ggplot(df, ggplot2::aes(x = .data[[input$y_exp]],
                                        fill = .data[[input$y_exp]])) +
        ggplot2::geom_bar() +
        ggplot2::scale_fill_manual(values = stat_palette()) +
        stat_theme() +
        ggplot2::theme(legend.position = "none") +
        ggplot2::labs(x = input$y_exp, y = "Frecuencia",
                      title = "Distribución de clases")
    })

    # ── Tab 5: Preprocesamiento ─────────────────────────────────────────────
    output$sel_y_pre <- renderUI({
      selectInput(ns("y_pre"), "Variable respuesta (clase)",
        choices = vars_factor())
    })
    output$sel_x_pre <- renderUI({
      req(input$y_pre)
      selectInput(ns("x_pre"), "Variables predictoras (X)",
        choices  = setdiff(names(datos_raw()), input$y_pre),
        selected = setdiff(names(datos_raw()), input$y_pre),
        multiple = TRUE)
    })

    split_obj <- reactive({
      req(input$y_pre, input$x_pre)
      df <- datos_raw()[, c(input$y_pre, input$x_pre), drop = FALSE]
      df[[input$y_pre]] <- factor(df[[input$y_pre]])
      set.seed(input$semilla)
      rsample::initial_split(df, prop = input$prop_train,
                             strata = !!rlang::sym(input$y_pre))
    })
    train_data <- reactive({ rsample::training(split_obj()) })
    test_data  <- reactive({ rsample::testing(split_obj()) })

    output$info_split <- renderUI({
      req(split_obj())
      n_total <- nrow(datos_raw())
      n_train <- nrow(train_data())
      n_test  <- nrow(test_data())
      tagList(
        bslib::value_box("Entrenamiento",
          paste0(n_train, " obs (", round(n_train/n_total*100), "%)"),
          showcase = bsicons::bs_icon("train-front"), theme = "primary"),
        bslib::value_box("Prueba",
          paste0(n_test, " obs (", round(n_test/n_total*100), "%)"),
          showcase = bsicons::bs_icon("check2-circle"), theme = "secondary")
      )
    })
    output$tabla_balance <- renderTable({
      req(input$y_pre, train_data(), test_data())
      tab_train <- table(train_data()[[input$y_pre]])
      tab_test  <- table(test_data()[[input$y_pre]])
      data.frame(
        Clase        = names(tab_train),
        Entrenamiento = as.integer(tab_train),
        Prueba        = as.integer(tab_test)
      )
    })

    receta <- reactive({
      req(input$y_pre, input$x_pre)
      formula_obj <- stats::as.formula(paste(input$y_pre, "~ ."))
      rec <- recipes::recipe(formula_obj, data = train_data())
      if (input$dummies)    rec <- recipes::step_dummy(rec, recipes::all_nominal_predictors())
      if (input$normalizar) rec <- recipes::step_normalize(rec, recipes::all_numeric_predictors())
      rec <- recipes::step_zv(rec, recipes::all_predictors())
      rec
    })
    output$info_receta <- renderPrint({ receta() })

    # ── Tab 6: Ajustar modelo ───────────────────────────────────────────────
    modelo_final <- reactiveVal(NULL)
    best_params  <- reactiveVal(NULL)
    tune_results <- reactiveVal(NULL)
    wf_final_obj_rv <- reactiveVal(NULL)

    observeEvent(input$ajustar, {
      req(receta(), train_data())
      withProgress(message = "Ajustando XGBoost (clasificación)...", {

        spec_tune <- parsnip::boost_tree(
          trees       = tune::tune(),
          tree_depth  = tune::tune(),
          learn_rate  = tune::tune(),
          min_n       = tune::tune(),
          sample_size = tune::tune()
        ) |>
          parsnip::set_engine("xgboost") |>
          parsnip::set_mode("classification")

        wf_tune <- workflows::workflow() |>
          workflows::add_recipe(receta()) |>
          workflows::add_model(spec_tune)

        set.seed(input$semilla)
        cv_folds <- rsample::vfold_cv(train_data(), v = input$cv_folds,
                                      strata = !!rlang::sym(input$y_pre))
        grilla <- dials::grid_latin_hypercube(
          dials::trees(), dials::tree_depth(), dials::learn_rate(),
          dials::min_n(), dials::sample_size(range = c(0.5, 1.0)),
          size = input$n_grid
        )

        incProgress(0.3, detail = "Buscando hiperparámetros...")
        res <- tune::tune_grid(wf_tune, resamples = cv_folds, grid = grilla,
          metrics = yardstick::metric_set(yardstick::roc_auc, yardstick::accuracy))

        tune_results(res)
        best <- tune::select_best(res, metric = "roc_auc")
        best_params(best)

        incProgress(0.6, detail = "Ajustando modelo final...")
        wf_fin <- tune::finalize_workflow(wf_tune, best)
        fit_fin <- parsnip::fit(wf_fin, data = train_data())
        wf_final_obj_rv(wf_fin)
        modelo_final(fit_fin)
      })
    })

    output$plot_tuning <- renderPlot({
      req(tune_results())
      tune::autoplot(tune_results(), metric = "roc_auc") +
        stat_theme() +
        ggplot2::labs(title = "AUC-ROC por combinación de hiperparámetros")
    })
    output$tabla_best <- renderTable({
      req(best_params())
      best_params() |> dplyr::select(-.config)
    }, digits = 5)

    # ── Predicciones ────────────────────────────────────────────────────────
    preds_test_class <- reactive({
      req(modelo_final(), input$y_pre)
      stats::predict(modelo_final(), new_data = test_data()) |>
        dplyr::bind_cols(
          stats::predict(modelo_final(), new_data = test_data(), type = "prob")
        ) |>
        dplyr::bind_cols(test_data())
    })
    preds_train_class <- reactive({
      req(modelo_final(), input$y_pre)
      stats::predict(modelo_final(), new_data = train_data()) |>
        dplyr::bind_cols(
          stats::predict(modelo_final(), new_data = train_data(), type = "prob")
        ) |>
        dplyr::bind_cols(train_data())
    })

    # ── Tab 7: Diagnóstico ──────────────────────────────────────────────────
    output$plot_confusion <- renderPlot({
      req(preds_test_class(), input$y_pre)
      preds_test_class() |>
        yardstick::conf_mat(truth = !!rlang::sym(input$y_pre),
                            estimate = .pred_class) |>
        ggplot2::autoplot(type = "heatmap") +
        ggplot2::scale_fill_gradient(low = "white", high = stat_palette()[1]) +
        stat_theme() +
        ggplot2::labs(title = "Matriz de confusión — prueba")
    })
    output$plot_roc <- renderPlot({
      req(preds_test_class(), input$y_pre)
      lvls <- levels(factor(train_data()[[input$y_pre]]))
      prob_col <- paste0(".pred_", lvls[2])
      if (!prob_col %in% names(preds_test_class())) {
        prob_col <- names(dplyr::select(preds_test_class(),
                                        dplyr::starts_with(".pred_")))[2]
      }
      preds_test_class() |>
        yardstick::roc_curve(truth = !!rlang::sym(input$y_pre),
                             !!rlang::sym(prob_col)) |>
        ggplot2::autoplot() +
        ggplot2::geom_abline(slope = 1, intercept = 0, linetype = "dashed",
                             color = "gray50") +
        ggplot2::scale_color_manual(values = stat_palette()[1]) +
        stat_theme() +
        ggplot2::labs(title = "Curva ROC — prueba")
    })

    # ── Tab 8: Performance ──────────────────────────────────────────────────
    metricas_cls <- function(df, y_var) {
      lvls    <- levels(factor(train_data()[[y_var]]))
      prob_col <- paste0(".pred_", lvls[2])
      if (!prob_col %in% names(df)) {
        prob_col <- names(dplyr::select(df, dplyr::starts_with(".pred_")))[2]
      }
      auc <- yardstick::roc_auc(df,
        truth    = !!rlang::sym(y_var),
        !!rlang::sym(prob_col))$.estimate
      acc <- yardstick::accuracy(df,
        truth    = !!rlang::sym(y_var),
        estimate = .pred_class)$.estimate
      list(auc = round(auc, 4), acc = round(acc, 4))
    }

    output$card_train <- renderUI({
      req(preds_train_class(), input$y_pre)
      m <- metricas_cls(preds_train_class(), input$y_pre)
      bslib::card(
        bslib::card_header("🔵 Entrenamiento (optimista)", class = "bg-primary text-white"),
        bslib::card_body(
          p(strong("AUC: "), m$auc),
          p(strong("Accuracy: "), scales::percent(m$acc, accuracy = 0.1))
        )
      )
    })
    output$card_test <- renderUI({
      req(preds_test_class(), input$y_pre)
      m <- metricas_cls(preds_test_class(), input$y_pre)
      bslib::card(
        bslib::card_header("🔴 Prueba (real)", class = "bg-danger text-white"),
        bslib::card_body(
          p(strong("AUC: "), m$auc),
          p(strong("Accuracy: "), scales::percent(m$acc, accuracy = 0.1))
        )
      )
    })
    output$interpretacion_overfitting <- renderUI({
      req(preds_train_class(), preds_test_class(), input$y_pre)
      m_train <- metricas_cls(preds_train_class(), input$y_pre)
      m_test  <- metricas_cls(preds_test_class(),  input$y_pre)
      diff_rel <- abs(m_train$auc - m_test$auc)
      nivel <- if (diff_rel < 0.05) {
        list(color = "success", texto = "Excelente",
             desc  = "Diferencia AUC < 0.05: el modelo generaliza muy bien.")
      } else if (diff_rel < 0.10) {
        list(color = "warning", texto = "Aceptable",
             desc  = "Diferencia AUC 0.05–0.10: generalización razonable.")
      } else {
        list(color = "danger", texto = "Posible sobreajuste",
             desc  = "Diferencia AUC > 0.10: considerar mayor regularización o reducir árboles.")
      }
      bslib::card(
        bslib::card_header(paste("Diagnóstico de generalización:", nivel$texto),
          class = paste0("bg-", nivel$color, " text-white")),
        bslib::card_body(
          p(nivel$desc),
          p(strong("AUC entrenamiento: "), m_train$auc, " | ",
            strong("AUC prueba: "), m_test$auc, " | ",
            strong("Diferencia: "), round(diff_rel, 4))
        )
      )
    })
    output$tabla_cv <- renderTable({
      req(tune_results())
      tune::collect_metrics(tune_results()) |>
        dplyr::filter(.metric == "roc_auc") |>
        dplyr::arrange(dplyr::desc(mean)) |>
        dplyr::slice_head(n = 5) |>
        dplyr::select(trees, tree_depth, learn_rate, min_n, mean, std_err) |>
        dplyr::rename("AUC (CV)" = mean, "SE" = std_err)
    }, digits = 4)

    # ── Tab 9: Predicciones ─────────────────────────────────────────────────
    output$tabla_pred <- DT::renderDT({
      req(preds_test_class())
      df <- preds_test_class() |>
        dplyr::select(.pred_class, dplyr::starts_with(".pred_"),
                      dplyr::everything())
      DT::datatable(df, options = list(pageLength = 10, scrollX = TRUE))
    })
    output$descargar_pred <- downloadHandler(
      filename = function() paste0("xgb_clas_predicciones_", Sys.Date(), ".csv"),
      content  = function(file) utils::write.csv(preds_test_class(), file, row.names = FALSE)
    )

    # ── Tab 10: Importancia ─────────────────────────────────────────────────
    importancia <- reactive({
      req(modelo_final(), train_data(), input$y_pre)
      lvls     <- levels(factor(train_data()[[input$y_pre]]))
      prob_col <- paste0(".pred_", lvls[2])
      vip::vi(modelo_final(), method = "permute",
        train  = train_data(),
        target = input$y_pre,
        metric = "roc_auc",
        pred_wrapper = function(object, newdata) {
          p <- stats::predict(object, new_data = newdata, type = "prob")
          p[[prob_col]]
        },
        smaller_is_better = FALSE
      )
    })
    output$plot_importancia <- renderPlot({
      req(importancia())
      importancia() |>
        dplyr::slice_max(Importance, n = 15) |>
        ggplot2::ggplot(ggplot2::aes(x = Importance,
                                      y = reorder(Variable, Importance))) +
        ggplot2::geom_col(fill = stat_palette()[1]) +
        stat_theme() +
        ggplot2::labs(x = "Importancia (AUC)", y = NULL,
                      title = "Importancia de variables — permutación")
    })
    output$tabla_importancia <- renderTable({
      req(importancia())
      importancia() |> dplyr::arrange(dplyr::desc(Importance))
    }, digits = 4)

    # ── Tab 11: PDP ─────────────────────────────────────────────────────────
    output$sel_pdp_var <- renderUI({
      req(importancia())
      top_var <- importancia() |>
        dplyr::slice_max(Importance, n = 1) |>
        dplyr::pull(Variable)
      selectInput(ns("pdp_var"), "Variable para PDP",
        choices  = importancia()$Variable,
        selected = top_var)
    })
    output$plot_pdp <- renderPlot({
      req(modelo_final(), train_data(), input$pdp_var, input$y_pre)
      df <- train_data()
      var <- input$pdp_var
      lvls     <- levels(factor(df[[input$y_pre]]))
      prob_col <- paste0(".pred_", lvls[2])
      x_seq <- if (is.numeric(df[[var]])) {
        seq(min(df[[var]], na.rm = TRUE), max(df[[var]], na.rm = TRUE),
            length.out = input$pdp_grid)
      } else {
        unique(df[[var]])
      }
      pd_df <- purrr::map_dfr(x_seq, function(val) {
        df_tmp <- df
        df_tmp[[var]] <- val
        preds <- stats::predict(modelo_final(), new_data = df_tmp,
                                type = "prob")[[prob_col]]
        tibble::tibble(x = val, yhat = mean(preds, na.rm = TRUE))
      })
      p <- ggplot2::ggplot(pd_df, ggplot2::aes(x = x, y = yhat))
      if (is.numeric(df[[var]])) {
        p <- p + ggplot2::geom_line(color = stat_palette()[1], linewidth = 1.2) +
                 ggplot2::geom_rug(data = df, ggplot2::aes(x = .data[[var]]),
                                   sides = "b", alpha = 0.3, inherit.aes = FALSE)
      } else {
        p <- p + ggplot2::geom_col(fill = stat_palette()[1])
      }
      p + stat_theme() +
        ggplot2::scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
        ggplot2::labs(x = var,
                      y = paste0("P(", lvls[2], ") promedio"),
                      title = paste("PDP —", var))
    })

    # ── Tab 12: Código R ────────────────────────────────────────────────────
    output$codigo_r <- renderText({
      req(input$y_pre, input$x_pre)
      vars_str <- paste0('c("', paste(input$x_pre, collapse = '", "'), '")')
      glue::glue('
library(tidymodels)
library(xgboost)
library(vip)

# Datos
data("your_dataset")
df <- your_dataset[, c("{input$y_pre}", {vars_str})]
df${input$y_pre} <- factor(df${input$y_pre})

# División estratificada
set.seed({input$semilla})
split <- initial_split(df, prop = {input$prop_train}, strata = {input$y_pre})
train <- training(split)
test  <- testing(split)

# Receta
rec <- recipe({input$y_pre} ~ ., data = train) |>
  step_dummy(all_nominal_predictors()) |>
  step_normalize(all_numeric_predictors()) |>
  step_zv(all_predictors())

# Especificación con tuning
spec <- boost_tree(
  trees       = tune(),
  tree_depth  = tune(),
  learn_rate  = tune(),
  min_n       = tune(),
  sample_size = tune()
) |>
  set_engine("xgboost") |>
  set_mode("classification")

# Workflow
wf <- workflow() |>
  add_recipe(rec) |>
  add_model(spec)

# Grilla y CV estratificada
set.seed({input$semilla})
folds  <- vfold_cv(train, v = {input$cv_folds}, strata = {input$y_pre})
grilla <- grid_latin_hypercube(
  trees(), tree_depth(), learn_rate(),
  min_n(), sample_size(range = c(0.5, 1.0)),
  size = {input$n_grid}
)

# Tuning
res  <- tune_grid(wf, resamples = folds, grid = grilla,
                  metrics = metric_set(roc_auc, accuracy))
best <- select_best(res, metric = "roc_auc")

# Modelo final
wf_final <- finalize_workflow(wf, best)
fit      <- fit(wf_final, data = train)

# Predicciones y métricas
preds <- predict(fit, new_data = test) |>
  bind_cols(predict(fit, new_data = test, type = "prob")) |>
  bind_cols(test)

roc_auc(preds, truth = {input$y_pre}, .pred_{lvls[2]})
accuracy(preds, truth = {input$y_pre}, estimate = .pred_class)
conf_mat(preds, truth = {input$y_pre}, estimate = .pred_class)
      ')
    })

  }) # end moduleServer
}

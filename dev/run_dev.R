# ============================================================
# dev/run_dev.R — Correr StatML en modo desarrollo
# ============================================================

# Detach package if loaded
if ("StatML" %in% (.packages())) {
  pkgload::unload("StatML")
}

# Load all
pkgload::load_all(export_all = FALSE, helpers = FALSE, attach_testthat = FALSE)

# Run the application
run_app()

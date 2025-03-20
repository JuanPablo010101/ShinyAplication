library(shiny)


# Importar ui.R e server.R
source("ui.R")
source("server.R")

# Iniciar o aplicativo Shiny
shinyApp(ui = ui, server = server)

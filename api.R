library(plumber)

# Executar o servidor
api <- plumb("predict_model.R")  # Caminho do arquivo correto
message("API Plumber está rodando na porta 8000")

# Iniciar a API com Swagger desabilitado
api$run(port = 8000, host = "0.0.0.0", swagger = FALSE)
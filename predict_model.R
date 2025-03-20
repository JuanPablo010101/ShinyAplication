#* @post /predict
function(req, res) {
  # Verifica se o corpo da requisição existe e contém os campos necessários
  if (is.null(req$body) ||
      is.null(req$body$`Sepal.Length`) ||
      is.null(req$body$`Sepal.Width`) ||
      is.null(req$body$`Petal.Length`) ||
      is.null(req$body$`Petal.Width`)) {
    
    res$status <- 400  # Bad Request
    return(list(message = "Erro: Dados incompletos na requisição"))
  } else {
    # Converte os dados para numérico
    Sepal_Length <- as.numeric(req$body$`Sepal.Length`)
    Sepal_Width  <- as.numeric(req$body$`Sepal.Width`)
    Petal_Length <- as.numeric(req$body$`Petal.Length`)
    Petal_Width  <- as.numeric(req$body$`Petal.Width`)
    
    # Verifica se a conversão gerou NAs (dados inválidos)
    if (any(is.na(c(Sepal_Length, Sepal_Width, Petal_Length, Petal_Width)))) {
      res$status <- 400  # Bad Request
      return(list(message = "Erro: Dados inválidos. Certifique-se de enviar números válidos."))
    }
    
    # Verifica se os valores são positivos (opcional)
    if (any(c(Sepal_Length, Sepal_Width, Petal_Length, Petal_Width) <= 0)) {
      res$status <- 400  # Bad Request
      return(list(message = "Erro: Valores devem ser positivos."))
    }
    
    # Carregar os modelos salvos da pasta "data"
    rf_model  <- readRDS("data/rf_model.rds")
    mlp_model <- readRDS("data/mlp_model.rds")
    knn_model <- readRDS("data/knn_model.rds")
    
    # Preparar os dados para previsão
    new_data <- data.frame(
      Sepal.Length = Sepal_Length,
      Sepal.Width  = Sepal_Width,
      Petal.Length = Petal_Length,
      Petal.Width  = Petal_Width
    )
    
    # Realizar as predições com cada modelo
    prediction_rf  <- predict(rf_model, new_data)
    prediction_mlp <- predict(mlp_model, new_data)
    prediction_knn <- predict(knn_model, new_data)
    
    # Retornar as previsões
    res$status <- 200  # OK
    return(list(
      message = "Sucesso",
      pred_rf  = as.character(prediction_rf),
      pred_mlp = as.character(prediction_mlp),
      pred_knn = as.character(prediction_knn)
    ))
  }
}
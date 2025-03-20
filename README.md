# Classificação de Espécies de Flores com API em R

Este projeto consiste em uma API desenvolvida em R para a classificação de espécies de flores com base no conjunto de dados Iris. A API utiliza três modelos de aprendizado de máquina: Random Forest, MLP (Rede Neural) e KNN.

## Instalação
Certifique-se de ter o R instalado e execute o seguinte comando para instalar os pacotes necessários:
```r
install.packages(c("shiny", "plumber", "randomForest", "caret", "nnet", "httr"))
```

## Executando a Aplicação

### 1. Iniciar a API Plumber
Abra o terminal ou RStudio e execute os seguintes comandos para iniciar a API:
```r
library(plumber)
api <- plumb("predict_model.R")
api$run(port = 8000, host = "0.0.0.0", swagger = TRUE)
```
A API estará disponível em: [http://localhost:8000](http://localhost:8000)

### 2. Executar o Aplicativo Shiny
Em outra sessão do R ou RStudio, execute o seguinte comando para iniciar o aplicativo Shiny:
```r
library(shiny)
runApp("app.R")
```
O aplicativo Shiny estará acessível em `http://localhost:PORT` (o número da porta será exibido no console).

## Estrutura do Projeto
```
├── app.R              # Arquivo principal do aplicativo Shiny
├── api.R              # Arquivo da API Plumber
├── predict_model.R    # Lógica da API para previsões
├── server.R           # Lógica do servidor Shiny
├── ui.R               # Interface do usuário Shiny
├── data/              # Pasta contendo os modelos treinados
│   ├── rf_model.rds
│   ├── mlp_model.rds
│   ├── knn_model.rds

    
```

## API Endpoints
### `POST /predict`
**Descrição:** Realiza previsões de classificação de espécies de flores com base nos modelos treinados.

**Parâmetros de entrada (JSON):**
```json
{
  "Sepal.Length": 5.1,
  "Sepal.Width": 3.5,
  "Petal.Length": 1.4,
  "Petal.Width": 0.2
}
```

**Resposta (JSON):**
```json
{
  "message": "Sucesso",
  "pred_rf": "setosa",
  "pred_mlp": "setosa",
  "pred_knn": "setosa"
}
```

## Solução de Problemas
- **Erro de conexão:** Verifique se a API está rodando na porta correta.
- **Pacotes ausentes:** Reinstale os pacotes com `install.packages(...)`.
- **Erro ao carregar modelos:** Certifique-se de que os arquivos `.rds` estão na pasta `data/`.





library(shiny)        # Carrega a biblioteca do Shiny para criar a interface interativa
library(ggplot2)      # Carrega a biblioteca ggplot2 para gráficos
library(randomForest) # Carrega a biblioteca para Random Forest
library(jsonlite)     # Carrega a biblioteca para manipulação de dados JSON
library(httr)         # Carrega a biblioteca para requisições HTTP
library(dplyr)        # Carrega a biblioteca para manipulação de dados

server <- function(input, output, session) {
  
  # Cria um valor reativo vazio para armazenar os dados
  dados <- reactiveVal(NULL)
  
  # Observa o evento de inicialização para carregar os dados de um arquivo CSV
  observe({
    dados(read.csv("data/iris_data.csv"))  # Carrega os dados de um arquivo CSV
  })
  
  # Cria um valor reativo para armazenar as previsões dos modelos (RF, RNA, KNN)
  previsao_reactive <- reactiveVal(list(rf = NULL, rna = NULL, knn = NULL))
  
  # Observa os inputs do usuário, envia a requisição e atualiza as previsões
  observe({
    # Cria um lista de entrada a partir dos inputs fornecidos pelo usuário
    dados_input <- list(
      Sepal.Length = input$SEPAL_LENGTH,
      Sepal.Width = input$SEPAL_WIDTH,
      Petal.Length = input$PETAL_LENGTH,
      Petal.Width = input$PETAL_WIDTH
    )
    
    # Converte os dados de entrada para o formato JSON
    dados_json <- toJSON(dados_input, auto_unbox = TRUE)
    
    # Envia a requisição POST para o servidor de previsão
    res <- POST(
      url = "http://localhost:8000/predict", 
      body = dados_json,
      encode = "json",
      content_type_json()
    )
    
    # Processa a resposta recebida do servidor
    resposta <- content(res, as = "parsed")
    
    # Atualiza o valor reativo das previsões com as respostas do modelo
    previsao_reactive(list(
      rf = ifelse(!is.na(resposta$pred_rf), resposta$pred_rf, NA),
      rna = ifelse(!is.na(resposta$pred_mlp), resposta$pred_mlp, NA),
      knn = ifelse(!is.na(resposta$pred_knn), resposta$pred_knn, NA)
    ))
  })
  
  #----------------------------------------------------------------------#
  # SEÇÃO: Renderizando Boxes de Previsões
  #----------------------------------------------------------------------#
  
  # Renderiza o box para a previsão do modelo Random Forest
  output$RF <- renderValueBox({
    previsao <- previsao_reactive()  # Obtém as previsões
    valueBox(
      value = as.character(previsao$rf),  # Exibe o valor da previsão
      subtitle = "Previsão Random Forest",  # Título explicativo
      icon = icon("line-chart")  # Ícone para a previsão
    )
  })
  
  # Renderiza o box para a previsão do modelo Rede Neural Artificial
  output$RNA <- renderValueBox({
    previsao <- previsao_reactive()  # Obtém as previsões
    valueBox(
      value = as.character(previsao$rna),  # Exibe o valor da previsão
      subtitle = "Previsão com Rede Neural Artificial",  # Título explicativo
      icon = icon("line-chart"),  # Ícone para a previsão
      color = "orange"  # Cor personalizada para a caixa
    )
  })
  
  # Renderiza o box para a previsão do modelo KNN
  output$CNN <- renderValueBox({
    previsao <- previsao_reactive()  # Obtém as previsões
    valueBox(
      value = as.character(previsao$knn),  # Exibe o valor da previsão
      subtitle = "Previsão com KNN",  # Título explicativo
      icon = icon("line-chart"),  # Ícone para a previsão
      color = "purple"  # Cor personalizada para a caixa
    )
  })
  
  #----------------------------------------------------------------------#
  # SEÇÃO: UI de Exploração dos Dados
  #----------------------------------------------------------------------#
  
  # Renderiza a interface para exploração dos dados (entrada de parâmetros)
  output$features <- renderUI({
    req(dados())  # Garante que os dados estão carregados
    df <- dados()  # Obtém os dados
    
    box(
      title = "Features",  # Título da caixa
      status = "primary",  # Cor da caixa (azul)
      solidHeader = TRUE,  # Cabeçalho sólido
      width = 12,  # Largura total
      height = "auto",  # Altura automática
      
      # SelectInput para escolher uma espécie
      selectInput("specie", 
                  label = "Escolha uma espécie:", 
                  choices = c(unique(df$Species), "N/a"), 
                  selected =  "N/a"),  # Obtém as espécies únicas
      
      # Sliders para interação do usuário com os dados
      sliderInput("SEPAL_LENGTH", 
                  label = "Escolha um valor de Comprimento da sépala:", 
                  min = min(df$Sepal.Length, na.rm = TRUE),
                  max = max(df$Sepal.Length, na.rm = TRUE),
                  value = max(df$Sepal.Length, na.rm = TRUE)),
      
      sliderInput("SEPAL_WIDTH", 
                  label = "Escolha um valor de Largura da sépala:", 
                  min = min(df$Sepal.Width, na.rm = TRUE),
                  max = max(df$Sepal.Width, na.rm = TRUE),
                  value = max(df$Sepal.Width, na.rm = TRUE)),
      
      sliderInput("PETAL_LENGTH", 
                  label = "Escolha um valor de Comprimento da pétala:", 
                  min = min(df$Petal.Length, na.rm = TRUE),
                  max = max(df$Petal.Length, na.rm = TRUE),
                  value = max(df$Petal.Length, na.rm = TRUE)),
      
      sliderInput("PETAL_WIDTH",
                  label = "Escolha um valor de Largura da pétala:",
                  min = min(df$Petal.Width, na.rm = TRUE),
                  max = max(df$Petal.Width, na.rm = TRUE),
                  value = max(df$Petal.Width, na.rm = TRUE))
    )
    
  })
  
  # Renderiza a caixa para o gráfico de dispersão
  output$Exploracao <- renderUI({
    box(
      title = "Gráfico Dispersão",  # Título da caixa
      status = "primary",  # Cor da caixa (azul)
      solidHeader = TRUE,  # Cabeçalho sólido
      width = 12,  # Largura total
      height = "auto",  # Altura automática
      plotOutput("grafico_exploracao")  # Exibe o gráfico de dispersão
    )
  })
  
  #----------------------------------------------------------------------#
  # SEÇÃO: Gráfico de Exploração de Dados
  #----------------------------------------------------------------------#
  
  # Renderiza o gráfico de dispersão com base nas entradas do usuário
  output$grafico_exploracao <- renderPlot({
    req(dados())  # Garante que os dados estão carregados
    df <- dados()  # Obtém os dados
    
    # Aplica o filtro de espécie, caso a espécie seja diferente de "N/a"
    if(input$specie != "N/a") {
      df <- df %>%
        filter(Species == input$specie)
    }
    
    # Filtra os dados com base nos valores dos sliders
    df <- df %>%
      filter(Sepal.Length <= input$SEPAL_LENGTH,  
             Sepal.Width <= input$SEPAL_WIDTH,    
             Petal.Length <= input$PETAL_LENGTH,  
             Petal.Width <= input$PETAL_WIDTH)
    
    # Se não houver dados após o filtro, exibe uma mensagem ou gráfico vazio
    if (nrow(df) == 0) {
      ggplot() + 
        labs(title = "Nenhum dado encontrado para os parâmetros selecionados",
             x = "Comprimento da Sépala",
             y = "Largura da Sépala") +
        theme_minimal()
    } else {
      ggplot(df, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
        geom_point(size = 3) +  
        theme_minimal() +  
        labs(title = paste("Gráfico de Dispersão para a Espécie -", input$specie, 
                           "Quantidade de Flores: ", nrow(df)),
             x = "Comprimento da Sépala",
             y = "Largura da Sépala") +
        scale_color_manual(values = c("red", "blue", "green"))
    }
  })
  
  output$Info_Sepal_length <- renderInfoBox({
    infoBox(
      title = "Sepal Length",  # Título do infoBox
      subtitle = "Valor Médio",
      value = round(mean(iris$Sepal.Length), 2),  # Valor da média de Sepal Length
      icon = icon("leaf"),  # Ícone do infoBox
      color = "aqua"  # Cor do infoBox
    )
  })
  
  output$Info_Sepal_width <- renderInfoBox({
    infoBox(
      title = "Sepal Width",  # Título do infoBox
      subtitle = "Valor Médio",
      value = round(mean(iris$Sepal.Width), 2),  # Valor da média de Sepal Width
      icon = icon("leaf"),  # Ícone do infoBox
      color = "orange"  # Cor do infoBox
    )
  })
  
  output$Info_Petal_length <- renderInfoBox({
    infoBox(
      title = "Petal Length",  # Título do infoBox
      subtitle = "Valor Médio",
      value = round(mean(iris$Petal.Length), 2),  # Valor da média de Petal Length
      icon = icon("leaf"),  # Ícone do infoBox
      color = "purple"  # Cor do infoBox
    )
  })
  
  output$Info_Petal_width <- renderInfoBox({
    infoBox(
      title = "Petal Width",  # Título do infoBox
      subtitle = "Valor Médio",
      value = round(mean(iris$Petal.Width), 2),  # Valor da média de Petal Width
      icon = icon("leaf"),  # Ícone do infoBox
      color = "green"  # Cor do infoBox
    )
  })
  
  
  # Renderiza o gráfico de barras para distribuição das espécies
  output$grafico_barras <- renderUI({
    box(
      title =  tags$strong("Distribuição das Espécies no Conjunto de Dados"),  # Título da caixa
      status = "primary",  # Cor da caixa (azul)
      solidHeader = TRUE,  # Cabeçalho sólido
      width = 12,  # Largura total
      height = "auto",  # Altura automática
      plotOutput("grafico_barra")  # Exibe o gráfico de barras
    )
  })
  
  # Gráfico de barras para a distribuição das espécies
  output$grafico_barra <- renderPlot({
    req(dados())  # Garante que os dados estão carregados
    df <- dados()  # Obtém os dados
    ggplot(df, aes(x = Species, fill = Species)) +
      geom_bar() +
      labs(title = "Distribuição de Espécies", x = "Espécie", y = "Contagem") +
      theme_minimal()+
      theme(
        plot.title = element_text(face = "bold"),  # Título em negrito
        axis.title = element_text(face = "bold")   # Títulos dos eixos em negrito
      )
  })
  output$grafico_distribui <- renderUI({
    box(
      title = tags$strong("Distribuição das Espécies no Conjunto de Dados"),  # Título da caixa
      status = "primary",  # Cor da caixa (azul)
      solidHeader = TRUE,  # Cabeçalho sólido
      width = 12,  # Largura total
      height = "auto",  # Altura automática
      plotOutput("grafico_dis")  # Exibe o gráfico de barras
    )
  })
  
  # Renderiza o gráfico de distribuição de comprimento da sépala
  output$grafico_dis <- renderPlot({
    req(dados())  # Garante que os dados estão carregados
    df <- dados()  # Obtém os dados
    
    ggplot(df, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
      geom_point(size = 3) +
      labs(title = "Distribuição das Espécies", x = "Comprimento da Sépala", y = "Largura da Sépala") +
      scale_color_manual(values = c("red", "green", "blue"))
  })
  
  output$dados <- renderDT({
    req(dados)  # Garante que os dados foram carregados antes de renderizar
    datatable(
      dados(),
      class = "table table-dark"  # Adiciona bordas à tabela
    )
  })
  
  
  
  # Função de download para os dados
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("dados_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(dados(), file, row.names = FALSE)  # Exporta os dados carregados como CSV
    }
  )
  
}

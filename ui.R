library(shiny)
library(shinydashboard)
library(DT)  # Carregando o pacote DT

ui <- dashboardPage(
  
  #----------------------------------------------------------------------#
  # HEADER: Definição do Cabeçalho da Página
  #----------------------------------------------------------------------#
  dashboardHeader(
    title = "Predição Iris"  # Título exibido na barra de navegação superior
  ),
  
  #----------------------------------------------------------------------#
  # SIDEBAR: Definição do Menu Lateral
  #----------------------------------------------------------------------#
  dashboardSidebar(
    sidebarMenu(
      # Menu com as opções que o usuário pode escolher
      menuItem(tags$h4(tags$strong("Início")), tabName = "inicio"),  # Página inicial
      
      menuItem(tags$h4(tags$strong("Descrição")), tabName = "descricao"),  # Página de descrição do conjunto de dados
    
      menuItem(tags$h4(tags$strong("Dados")), tabName = "Dados")  # Página de gráficos e visualizações
    )
  ),
  
  #----------------------------------------------------------------------#
  # BODY: Definição do Corpo da Página
  #----------------------------------------------------------------------#
  dashboardBody(
    tags$style(HTML("
    /* Estilo global para centralizar o conteúdo */
    .content-wrapper {
      text-align: center;
      background-color: #FFFFFF;
    }
     h2 {
      color: #3498db;      /* Cor do texto */
      font-size: 30px;     /* Tamanho da fonte */
      text-align: center;  /* Alinhar o texto ao centro */
      font-family: 'Arial', sans-serif; /* Fonte */
    }
    h1 {
      color: #3498db;      /* Cor do texto */
      font-size: 36px;     /* Tamanho da fonte */
      text-align: center;  /* Alinhar o texto ao centro */
      font-family: 'Arial', sans-serif; /* Fonte */
    }
    .break-row {
      margin-bottom: 20px;  /* Espaçamento de 20px abaixo do fluidRow */
      color: #000000;
    }
    .fluidRow{
      background-color: #000000;
    }
    .box{
      border-radius: 4px;
    }
    /* Estilo personalizado para os valueBoxes */
    .value-box {
      background-color: #f7f7f7;  /* Cor de fundo */
      color: #FFFFFF;  /* Cor do texto */
      border-radius: 1px;
    }
    
    /* Estilo para o título da caixa */
    .box-title {
      color: #FFFFFF;  /* Cor do título da caixa */
    }
    
    /* Estilo para a área do gráfico */
    .grafico-area {
      background-color: #e9ecef;
      padding: 15px;
      border-radius: 8px;
      margin-top: 20px;
    }
    /* Rodapé fixo na parte inferior */
    .fixed-footer {
      position: fixed;
      bottom: 0;
      width: 100%;
      background-color: #f1f1f1;
      text-align: center;
      padding: 10px 0;
    }
    ")),
    
    # Definição dos diferentes "tabs" que serão apresentados no corpo da página
    tabItems(
      
      # Tab de "Início" (ou página inicial)
      tabItem(tabName = "inicio",
              # Título da página
              h1("Bem-vindo ao Aplicativo de Predição"),
              tags$hr(),
              # Primeira linha com 3 boxes de valor para exibição das previsões
              fluidRow(
                valueBoxOutput("RF", width = 4),  # Box para previsão usando Random Forest
                valueBoxOutput("RNA", width = 4),  # Box para previsão usando Rede Neural Artificial
                valueBoxOutput("CNN", width = 4)  # Box para previsão usando Rede Neural Convolucional
              ),
              tags$hr(),
              
              # Linha com boxes para exploração dos dados (gráfico + sliders)
              fluidRow(
                column(width = 4, uiOutput("features")),  # Box de inputs para exploração de dados
                column(width = 8, uiOutput("Exploracao"))  # Box de gráfico para exploração visual
              ),
              
      ), 
      
      # Tab de "Descrição" que descreve o conjunto de dados
      tabItem(tabName = "descricao", 
              h1("Descrição do Conjunto de Dados Iris"),  # Título da seção de descrição
              tags$hr(),
              tags$strong(tags$h2("Média das Variáveis: Sepala e Pétala")),
              
              fluidRow(
                # Colunas com os InfoBoxes para as variáveis, ajustadas para o mesmo tamanho
                column(width = 3, infoBoxOutput("Info_Sepal_length", width = 12)),
                column(width = 3, infoBoxOutput("Info_Sepal_width", width = 12)),
                column(width = 3, infoBoxOutput("Info_Petal_length", width = 12)),
                column(width = 3, infoBoxOutput("Info_Petal_width", width = 12))
              ),
              tags$hr(),
              fluidRow(
                column(width = 6, uiOutput("grafico_barras")),  # Box de inputs para exploração de dados
                column(width = 6, uiOutput("grafico_distribui"))  # Box de gráfico para exploração visual
              ),
             
      ),
      
      # Tab de "Gráfico" para visualizações gráficas
      tabItem(tabName = "Dados", 
              h1("Visualizações dos Dados"),  # Título da seção de gráficos
              tags$hr(),
              fluidRow(
                DTOutput("dados"),  # Usando DT::DTOutput para a tabela interativa
                tags$hr(),
                downloadButton("downloadData", "Baixar Dados", class = "btn btn-primary")
                
              )
      )
    )  # Fim do tabItems
  )  # Fim do dashboardBody
)  # Fim do dashboardPage

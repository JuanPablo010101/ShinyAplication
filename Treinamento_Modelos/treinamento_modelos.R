# Carregar as bibliotecas necessárias
library(randomForest)
library(caret)
library(nnet)

# Carregar os dados
dados <- read.csv("data/iris_data.csv")
dados$Species <- as.factor(dados$Species)

# Dividir os dados em treino e teste (80% treino, 20% teste)
set.seed(123)
trainIndex <- createDataPartition(dados$Species, p = 0.8, list = FALSE)
trainData <- dados[trainIndex, ]
testData  <- dados[-trainIndex, ]

# Verificar a distribuição das classes
table(trainData$Species)
table(testData$Species)

# Treinando o modelo Random Forest para classificação
rf_model <- randomForest(Species ~ ., data = trainData, ntree = 500, mtry = 2)

# Treinando o modelo MLP (usando caret com método "nnet")
control <- trainControl(method = "cv", number = 5)
set.seed(123)
mlp_model <- train(Species ~ ., data = trainData, method = "nnet",
                   trControl = control, trace = FALSE,
                   tuneGrid = expand.grid(size = c(5, 10), decay = c(0.1, 0.01)))

# Treinando o modelo KNN (usando caret com método "knn")
set.seed(123)
knn_model <- train(Species ~ ., data = trainData, method = "knn",
                   trControl = control, tuneGrid = expand.grid(k = c(3, 5, 7)))

# Salvar os modelos na pasta "data"
saveRDS(rf_model,  file = "data/rf_model.rds")
saveRDS(mlp_model, file = "data/mlp_model.rds")
saveRDS(knn_model, file = "data/knn_model.rds")

# Previsões no conjunto de teste
rf_predictions  <- predict(rf_model, testData)
mlp_predictions <- predict(mlp_model, testData)
knn_predictions <- predict(knn_model, testData)

# Matriz de confusão
confusionMatrix(rf_predictions, testData$Species)
confusionMatrix(mlp_predictions, testData$Species)
confusionMatrix(knn_predictions, testData$Species)
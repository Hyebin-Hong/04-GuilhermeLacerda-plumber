# Packages ----
library(palmerpenguins) ## data frame for exercise
library(dplyr) ## for data wrangling

library(randomForest) ## for creating a prediction model
library(parsnip) ## for creating a prediction model
library(ranger) ## for creating a prediction model

if (!require("pacman")) install.packages("pacman")
pacman::p_load(faux, dplyr, stats) ## for simulating a new data frame (penguin observations)

library(jsonlite) ## for converting and reading JSON files

# Setting up a (random forest) model ----
penguins <- penguins

set.seed(67)
subset.imputed <- rfImpute(species ~ ., data = penguins, iter=6)

## Model option 1 (Reference: StatQuest)
## model <- randomForest(species ~ ., data=subset.imputed, proximity=TRUE)
## model
## saveRDS(model, "model.rds") 
## For later retrieval of the model: my_model <- readRDS("model.rds")

model <- rand_forest() %>%
  set_engine("ranger") %>%
  set_mode("classification") %>%
  fit(species ~ bill_length_mm + bill_depth_mm + flipper_length_mm + body_mass_g, data = subset.imputed)
model
saveRDS(model, "model.rds")

# Creating a new, theoretical data frame ----
## Checking mean values for each variable of interest
subset.imputed %>%
  summarise_at(vars(bill_length_mm, bill_depth_mm, flipper_length_mm, body_mass_g), list(name = mean))

## Checking the correlation between these variables
cor(subset.imputed[, c("bill_length_mm", "bill_depth_mm", "flipper_length_mm", "body_mass_g")])

## Checking the standard deviation for them
sapply(subset.imputed[, c("bill_length_mm", "bill_depth_mm", "flipper_length_mm", "body_mass_g")], sd)

## Creating a hypothetical data frame of new penguin research (taking the above info in consideration)
set.seed(99)
simulated <- rnorm_multi(n = 10,
                         mu = c(44, 17, 201, 4199),
                         sd = c(8, 5, 20, 1000),
                         r = c(1, -0.2, 0.6, 0.6,
                               -0.2, 1.0, -0.6, -0.5,
                               0.7, -0.6, 1.0, 0.9,
                               0.6, -0.5,  0.9, 1.0),
                         varnames = c("bill_length_mm", "bill_depth_mm", "flipper_length_mm", "body_mass_g"),
                         empirical = FALSE)

## Converting this data frame to json in order to simulate the web API
simulated_json <- jsonlite::toJSON(simulated)
cat(simulated_json)
save(simulated_json, file="simulated.JSON")

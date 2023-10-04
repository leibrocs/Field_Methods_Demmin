setwd('path/to/your/directory')

# install and load required packages
library(sf)
library(sp)
library(terra)
library(caTools) # for logistic regression
library(randomForest) # for generating random forest model
library(caret) # for classification and regression training (to make prediction)
library(ggplot2)
library(ggspatial)
library(ggpubr)



########## Data Import and Inspection #########

# import data
fields <- st_read('Data/fields.gpkg')
esus <- st_read('Data/esus.shp')
biomass_samples <- read.csv('Data/Field_Data.csv')
sentinel_large <- rast('Data/Sentinel2_Demmin_large.tif')

# crop the sentinel 2 scene to the extent of the fields
sentinel <- crop(sentinel_large, fields)

# mask the sentinel 2 scene to the exact extent of the fields
sentinel_fields <- mask(sentinel_large, fields)

# define crs
crs <- crs(sentinel)

# inspect imported bands of the Sentinel-2 image
summary(sentinel)
plot(sentinel)

# create RGB raster stack for plotting
sentinel_rgb <- c(sentinel[["B4"]], sentinel[["B3"]], sentinel[["B2"]])

# inspect imported Biomass data
print(biomass_samples)
summary(biomass_samples)

# transform the dataframe to a sptial points dataframe
biomass_spatvec <- vect(biomass_samples, geom = c("Longitude", "Latitude"), crs = crs)

# create data frame only containing point coordinates for later extraction of the vegetation indices for the plots
plots_spatvec <- biomass_spatvec[, c(1, 2)]
plots_coord <- biomass_samples[, c(1, 2)]

# plot the satellite image, the fields and plots for a first overview
ggplot() +
  layer_spatial(sentinel_rgb, alpha = .9) + 
  geom_sf(data = fields, size = 10, aes(fill = desc, alpha = .1)) +
  scale_fill_discrete(type = c('lightgreen', 'darkgreen'), name = 'Fields') +
  geom_sf(data = esus, color = 'darkred') +
  ggtitle("Study Area with Plots") +
  theme(plot.title = element_text(hjust = 0.5)) +
  guides(alpha = 'none')
  


########## Calculation of VI's ##########

# NDVI
ndvi <- (sentinel$B8 - sentinel$B4) / (sentinel$B8 + sentinel$B4)
ndvi_plots <- extract(ndvi, plots_coord, ID = FALSE)
names(ndvi_plots) <- 'ndvi'
biomass_vi <- cbind(biomass_samples, ndvi_plots)

# NDRE (normalized difference nir/ red-edge index)
ndre <- (sentinel$B8 - sentinel$B12) / (sentinel$B8 + sentinel$B12)
ndre_plots <- extract(ndre, plots_coord, ID = FALSE)
names(ndre_plots) <- 'ndre'
biomass_vi <- cbind(biomass_vi, ndre_plots)

# SAVI (soil adjusted vegetation index)
savi <- (sentinel$B8 - sentinel$B4) / (sentinel$B8 + sentinel$B4 + 0.428) * 1.428
savi_plots <- extract(savi, plots_coord, ID = FALSE)
names(savi_plots) <- 'savi'
biomass_vi <- cbind(biomass_vi, savi_plots)

# GNDVI (green normalized difference vegetation index)
gndvi <- (sentinel$B8 - sentinel$B3) / (sentinel$B8 + sentinel$B3)
gndvi_plots <- extract(gndvi, plots_coord, ID = FALSE)
names(gndvi_plots) <- 'gndvi'
biomass_vi <- cbind(biomass_vi, gndvi_plots)

# EVI (enhanced vegetation index)
evi <- 2.5 * ((sentinel$B8 - sentinel$B4) / (sentinel$B8 + 6 * sentinel$B4 - 7.5 * sentinel$B2 + 1))
evi_plots <- extract(evi, plots_coord, ID = FALSE)
names(evi_plots) <- 'evi'
biomass_vi <- cbind(biomass_vi, evi_plots)

# CI (coloration index) 
ci <- (sentinel$B7 / sentinel$B5) - 1
ci_plots <- extract(ci, plots_coord, ID = FALSE)
names(ci_plots) <- 'ci'
biomass_vi <- cbind(biomass_vi, ci_plots)



######### Analysis of the Relation between the Variables ########

# remove rows with NA values
biomass_samples <- na.omit(biomass_samples)
biomass_vi <- na.omit(biomass_vi)

# AGB of all plots
ggplot(data = biomass_samples, aes(x = Name, y = Weight_Wet)) +
  geom_line(color = "darkgreen", aes(group = 1), linewidth = 1.5) +
  geom_point(color = "darkred", size = 3) +
  ggtitle("Aboveground Biomass (AGB) at all Plots") +
  ylab("Weight Wet [g]") +
  xlab("Plot") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5),
        plot.title = element_text(hjust = 0.5))

# plot the relation of the predictor variables and the wet weight (AGB)
WetWeight_evi <- ggplot(data = biomass_vi, aes(x = Weight_Wet, y = evi)) +
  geom_point(color = "darkgreen") +
  geom_smooth(method = "lm", se = T, color = "darkred") +
  ggtitle("AGB - EVI") +
  xlab("Wet Weight [g]") +
  ylab("EVI") +
  theme(plot.title = element_text(hjust = 0.5))

WetWeight_ci <- ggplot(data = biomass_vi, aes(x = Weight_Wet, y = ci)) +
  geom_point(color = "darkgreen") +
  geom_smooth(method = "lm", se = T, color = "darkred") +
  ggtitle("AGB - CI") +
  xlab("Wet Weight [g]") +
  ylab("CI") +
  theme(plot.title = element_text(hjust = 0.5))

WetWeight_ndre <- ggplot(data = biomass_vi, aes(x = Weight_Wet, y = ndre)) +
  geom_point(color = "darkgreen") +
  geom_smooth(method = "lm", se = T, color = "darkred") +
  ggtitle("AGB - NDRE") +
  xlab("Wet Weight [g]") +
  ylab("NDRE") +
  theme(plot.title = element_text(hjust = 0.5))

WetWeight_savi <- ggplot(data = biomass_vi, aes(x = Weight_Wet, y = savi)) +
  geom_point(color = "darkgreen") +
  geom_smooth(method = "lm", se = T, color = "darkred") +
  ggtitle("AGB - SAVI") +
  xlab("Wet Weight [g]") +
  ylab("SAVI") +
  theme(plot.title = element_text(hjust = 0.5))

WetWeight_ndvi <- ggplot(data = biomass_vi, aes(x = Weight_Wet, y = ndvi)) +
  geom_point(color = "darkgreen") +
  geom_smooth(method = "lm", se = T, color = "darkred") +
  ggtitle("AGB - NDVI") +
  xlab("Wet Weight [g]") +
  ylab("NDVI") +
  theme(plot.title = element_text(hjust = 0.5))

WetWeight_gndvi <- ggplot(data = biomass_vi, aes(x = Weight_Wet, y = gndvi)) +
  geom_point(color = "darkgreen") +
  geom_smooth(method = "lm", se = T, color = "darkred") +
  ggtitle("AGB - GNDVI") +
  xlab("Wet Weight [g]") +
  ylab("GNDVI") +
  theme(plot.title = element_text(hjust = 0.5))

WetWeight_CanopyHeight <- ggplot(data = biomass_vi, aes(x = Weight_Wet, y = Canopy_Height)) +
  geom_point(color = "darkgreen") +
  geom_smooth(method = "lm", se = T, color = "darkred") +
  ggtitle("AGB - Canopy Height") +
  xlab("Wet Weight [g]") +
  ylab("Canopy Height [cm]") +
  theme(plot.title = element_text(hjust = 0.5))

WetWeight_AverageChlorophyll <- ggplot(data = biomass_vi, aes(x = Weight_Wet, y = Chlorophyll_Content)) +
  geom_point(color = "darkgreen") +
  geom_smooth(method = "lm", se = T, color = "darkred") +
  ggtitle("AGB - Chlorophyll Content") +
  xlab("Wet Weight [g]") +
  ylab("Average Chlorophyll") +
  theme(plot.title = element_text(hjust = 0.5, size = 11))

WetWeight_AverageChlorophyllTop <- ggplot(data = biomass_vi, aes(x = Weight_Wet, y = Average_Chlorophyll_Top)) +
  geom_point(color = "darkgreen") +
  geom_smooth(method = "lm", se = T, color = "darkred") +
  ggtitle("AGB - Average Chlorophyll Content") +
  xlab("Wet Weight [g]") +
  ylab("Average Chlorophyll") +
  theme(plot.title = element_text(hjust = 0.5, size = 9))

ggarrange(WetWeight_evi, WetWeight_ci, WetWeight_ndre, WetWeight_savi, WetWeight_ndvi, WetWeight_gndvi,
          WetWeight_CanopyHeight, WetWeight_AverageChlorophyll, WetWeight_AverageChlorophyllTop)



########## Bootstrapping ##########

# remove unimportant rows for modelling
biomass_vi_rf <- biomass_vi[,c(8:17)]

# get number of sample points
nrow(biomass_vi_rf)

# add random data via bootstrapping to achieve 100 sample points
additional_indices <- sample(nrow(biomass_vi_rf), size = 53, replace = TRUE)
synthetic_data <- biomass_vi_rf[,1:10][additional_indices, ]
randomness_factor <- 0.05

for (col in c("Weight_Wet", "Canopy_Height", "Chlorophyll_Content", "Average_Chlorophyll_Top", 
              "ndvi", "ndre", "savi", "gndvi", "evi", "ci")) {
  synthetic_data[[col]] <- synthetic_data[[col]] * (1 + randomness_factor * runif(53, min = -1, max = 1))
}

# add names from fields and "synthetic" for synthetic data
biomass_vi_rf['Name'] <- biomass_vi$Name
synthetic_data['Name'] <- 'synthetic'

# combine synthetic data with the sample points and remove the rownames 
biomass_vi_random <- rbind(biomass_vi_rf, synthetic_data)
rownames(biomass_vi_random) <- NULL



########## Modelling ##########

set.seed(123)

# split the data into testing and training
split <- sample.split(biomass_vi_random, SplitRatio = 0.8)

data_train <- subset(biomass_vi_random, split == "TRUE")
data_test <- subset(biomass_vi_random, split == "FALSE")


### Random Forest Model ###

# names of input features for the model (remove column 'Weight_Wet' and 'Name')
features <- setdiff(names(data_train), c("Weight_Wet", "Name"))
features_RF <- setdiff(names(data_train), "Name")
features_RF_fields <- setdiff(names(data_train), c("Name", "Canopy_Height", 
                                                   "Chlorophyll_Content", 
                                                   "Average_Chlorophyll_Top"))

# finding the optimized value of 'm' (random variables)
bestmtry <- tuneRF(
  x = data_train[features], 
  y = data_train$Weight_Wet,
  ntreeTry = 50, #500
  mtryStart = 3,
  stepFactor = 1.5, 
  improve = 0.01, 
  trace = T, # show real time process
  plot = T
  )

# create a random forest model with the mtry values returned from tuneRF (3)
model_RF <- randomForest(
  Weight_Wet~., 
  data = data_train[features_RF],
  ntree = 100,
  mtry = 3,
  importance = TRUE
  )

# second random forest model without field data to predict AGB for entire two fields
model_RF_fields <- randomForest(
  Weight_Wet~., 
  data = data_train[features_RF_fields],
  ntree = 100,
  mtry = 3,
  importance = TRUE
)

model_RF
model_RF_fields

# save the models
saveRDS(model_RF, file = paste0(getwd(), "/RF_model_44.rds"))
saveRDS(model_RF_fields, file = paste0(getwd(), "/RF_model_fields_55.rds"))

# check variable importance of the first model
varImpPlot(model_RF)

# visualize the variable importance
ImpData <- as.data.frame(importance(model_RF))
ImpData$Var.Names <- row.names(ImpData)

ggplot(ImpData, aes(x=Var.Names, y=`%IncMSE`)) +
  geom_segment( aes(x=Var.Names, xend=Var.Names, y=0, yend=`%IncMSE`), color="skyblue") +
  geom_point(aes(size = IncNodePurity), color="blue", alpha=0.6) +
  theme_light() +
  coord_flip() +
  labs(title = 'Variable Importance', x = 'Decrease in Mean Square Error (MSE)', y = 'Variables') +
  theme(legend.position="bottom", panel.grid.major.y = element_blank(),
        panel.border = element_blank(),axis.ticks.y = element_blank())

# check model performance

# number of trees with lowest MSE
which.min(model_RF$mse)

# RMSE
sqrt(model_RF$mse[which.min(model_RF$mse)])



########## Prediction of the first Model ##########

# predict on the test data
agb_pred <- predict(model_RF, data_test)

# calculate the (mean) deviation of the predicted values from the actual data
mean_pred <- mean(data_test$Weight_Wet - agb_pred)
valid <- data_test$Weight_Wet - agb_pred

# visualize the accuracy
agb_pred_vis <- cbind(data_test, agb_pred)

# remove rows with synthetic data
agb_pred_vis <- agb_pred_vis[agb_pred_vis$Name != 'synthetic', ]

agb_pred_vis$seq <- seq_along(agb_pred_vis$Weight_Wet)  
agb_pred_vis_long <- tidyr::pivot_longer(agb_pred_vis, cols = c(Weight_Wet, agb_pred))
agb_pred_vis_long$name <- factor(agb_pred_vis_long$name, levels = c("agb_pred", 'Weight_Wet'))
agb_pred_vis_long$name <- replace(agb_pred_vis_long$name, is.na(agb_pred_vis_long$name), 'Weight_Wet')

# plot the actual and predicted biomass
ggplot(agb_pred_vis_long, aes(as.factor(seq), y = value, fill = name)) +
  geom_bar(stat = 'identity', position = 'dodge', width = 0.5) +
  scale_fill_manual(values = c('darkgreen', 'lightgreen'),
                    labels = c('Actual AGB', 'Predicted AGB'), name = '') +
  scale_x_discrete(breaks = seq_along(agb_pred_vis$Name), labels = agb_pred_vis$Name) +
  labs(title = 'Actual vs. Predicted AGB', x = 'Plots', y = 'AGB [g/ 5 stems]') +
  coord_flip()

# visualize the prediction error
agb_pred_vis$difference <- agb_pred_vis$Weight_Wet - agb_pred_vis$agb_pred

ggplot(agb_pred_vis, aes(x = Name, y = difference, 
                         fill = ifelse(difference >= 0, 'Positive', 'Negative'))) +
  geom_bar(stat = 'identity', position = 'dodge', width = 0.5) +
  scale_fill_manual(values = c('Positive' = 'darkblue', 'Negative' = 'darkred'), name = '') +
  labs(title = 'Comparison of the actual vs. the predicted AGB', x = 'Plots', y = 'Prediction Error') +
  coord_flip()



########## Prediction of the second Model ##########

# extract coordinates from all the cells
sentinel_fields_coord <- as.data.frame(terra::xyFromCell(sentinel_fields, 1:ncell(sentinel_fields)))

# data frame with the extracted features from the two fields
sentinel_fields_df <- extract(sentinel_fields, sentinel_fields_coord, ID = FALSE)
sentinel_fields_df <- cbind(sentinel_fields_coord, sentinel_fields_df)
sentinel_fields_df <- na.omit(sentinel_fields_df)

# check if the extracted points match with the fields
plot(sentinel_fields$B2)
points(sentinel_fields_df$x, sentinel_fields_df$y, col = 'red')

# compute VIs and add them as features
sentinel_fields_df$ci <- (sentinel_fields_df$B7 / sentinel_fields_df$B5) - 1
sentinel_fields_df$ndvi <- (sentinel_fields_df$B8 - sentinel_fields_df$B4) / 
  (sentinel_fields_df$B8 + sentinel_fields_df$B4)
sentinel_fields_df$ndre <- (sentinel_fields_df$B8 - sentinel_fields_df$B12) / 
  (sentinel_fields_df$B8 + sentinel_fields_df$B12)
sentinel_fields_df$evi <- (sentinel_fields_df$B8 - sentinel_fields_df$B12) / 
  (sentinel_fields_df$B8 + sentinel_fields_df$B12)
sentinel_fields_df$savi <- (sentinel_fields_df$B8 - sentinel_fields_df$B4) / 
  (sentinel_fields_df$B8 + sentinel_fields_df$B4 + 0.428) * 1.428
sentinel_fields_df$gndvi <- (sentinel_fields_df$B8 - sentinel_fields_df$B3) / 
  (sentinel_fields_df$B8 + sentinel_fields_df$B3)

# predict the biomass for the two experimental fields
agb_pred_fields <- predict(model_RF_fields, sentinel_fields_df[, 13:18])

# add the prediction to the data frame
sentinel_fields_df$agb_pred <- agb_pred_fields

# transform the data frame to a spatial vector for plotting
sentinel_fields_spatvec <- vect(sentinel_fields_df, geom = c("x", "y"), crs = crs)

# visualize the prediction
ggplot() +
  layer_spatial(sentinel_fields_spatvec, aes(color = agb_pred)) +
  scale_color_continuous(type = 'viridis', name = 'AGB [g/ 5 Stems]') +
  labs(title = 'Predicted AGB Winterwheat') +
  theme(plot.title = element_text(hjust = 0.5)) +
  guides(alpha = 'none')
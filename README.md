# Estimation of Winterwheat Aboveground Biomass using Sentinel-2 Imagery and Random Forest Algorithm

## 1. Introduction
Crop biomass is a globally important climate-relevant terrestrial carbon pool and its monitoring important for weed, pest and soil erosion control, as well as for nutrient cycling, overall soil health and crop productivity improvement. Crop yield is the marketable fraction of above ground biomass accumulated over a growing season, which varies widely over space and time, because of differences in cultivars, environmental conditions, and agronomic practices. In the agricultural sector there is a growing interest in using remotely sensed imagery to estimate crop biomass. Satellite data delivers consistent and frequent information for crop yield estimations over large areas. Crop models typically account for the cummulative effect of these three factors and other geospatial information. Satellite image data are an important input to the models because the capture eco-physical conditions on the ground consistently and frequently and they offer the possibility to do so over large areas. Machine learning methods liek random forest are increasingly employed for crop modelling because of the challenges of process-based methods to account for the complex interactions governing crop biomass

## 2. Material and Methods

### 2.1 Study Area

![Demmin_Overview](https://github.com/leibrocs/Field_Methods_Demmin/assets/116877154/c631228c-b2f0-41a3-b92f-fed03abc1b6a)


The study area consisted of two winterwheat fields within the larger DEMMIN (Durable Environmental Multidisciplinary Monitoring Information Network) experimental area located about 180km north of Berlin in the state of Mecklenburg-Vorpommern in the northeast German lowlands. Todays young moraine landscape with its numerous lakes and bogs is characterized by typical periglacial landscape elements such as extensive flat sandy areas, hills, and depressions. DEMMIN has been operated for about 20 years as a calibration and validation test site for remote sensing data by the German Aerospace Center (DLR). 

### 2.2 Data
#### 2.2.1 Field Data Acquisition
The field data was collected over the course of one week from 29th of May to 3nd of June 2023. In the first field, there were three different study areas, each compromising  nine individual one-square-meter plots. In the second field, data was sampled at two different sites, each consisting of nine plots as well. 
At each of the individual plots, the canopy height, wet weight, and chlorophyll content was measured. The canopy height was determined by averaging measurements taken from a total of four plants within each plot. For chlorophyll content, four plants were sampled as well, taking three measurements per plant: one at the top of the canopy, one in the middle, and one on the lowest leaf. Regarding wet weight, three plants were randomly selected from each plot and weighted in the laboratory.

#### 2.2.2 Satellite Data
For the analysis, a single Sentinel-2 scene that covered the entire study area was utilized. This scene was acquired on 3rd of June 2023, which coincided with the final day of the field data collection. To calculate the vegetation indices, the red, green, and near infrared band were used. The spatial resolution for all three of these bands was 20 meters. The images were composited and retrieved from the Sentinel Hub EO Browser. 

### 2.3 Biomass Estimation
The estimation of biomass was conducted using the R programming language and a Random Forest regression algorithm. Initially, the models input data was imported. In addition to field data such as canopy height and chlorophyll content, a total of six different vegetation indices (VIs), specifically NDVI, NDRE, SAVI, GNDVI, EVI, and CI, were incorporated as predictors for estimating above-ground biomass of winterwheat. These VIs were computed from a Sentinel-2 multispectral image covering the sturdy area. The image was clipped to the extent of the two experimental fields and the VI values were extracted for the point coordinates of the different plots. Subsequently, these values were merged with the field data, and any rows containing NA values were removed. After this data cleansing step, we were left with 47 data points, which is a relatively limited amount of data for a random forest regression. 
To address this issue and expand the sample size to 100 data points, we employed bootstrapping. This involved randomly resampling our existing data to create new training datasets. This process effectively augmented the sample size, allowing the random forest model to learn from a broader range of data variations, resulting in more robust and generalizable outcomes.
Following the pre-processing, the data was split into training data for constructing and fitting the model and testing data for making predictions on unseen data. The split ratio was set to 80% for training and 20% for testing. Subsequently, the model was fitted using the 'randomForest' function from the 'randomForest' R package, employing 100 trees for growing the random forest and randomly sampling three variables at each split. The determination of the number of variables was accomplished using the 'tuneRF' function to identify the optimal mtry parameter. 
After running the initial random forest model, we plotted the variable importance was plotted. Predictions were then performed on the testing data and subsequently extented to cover the entire two experimental fields to estimate the above-ground biomass. Finally, the results were visualized. 

## 3. Results
Prior to executing the  Random Forest model, the above-ground biomass was visually examined across all 47 plots.

![AGB_Plots](https://github.com/leibrocs/Field_Methods_Demmin/assets/116877154/e8b333da-a2de-49f6-9c62-696cca48352a)

It was observed, that the wet weight exhibited significant fluctuations not only between the different plots but also between the two experimental fields. On the first field, weights ranged from approximately 48g to  around 66g, while on the second field values ranging from approximately 57g to around 93g were observable.
Furthermore, scatterplots to visualize the relationship between the different predictors and the wet weight (above-ground biomass) were generated.

![ABG_Predictors](https://github.com/leibrocs/Field_Methods_Demmin/assets/116877154/76224405-7b9a-41c7-82b3-2c456aefa2d8)

The results of these scatterplots indicate, that all predictors exhibited a positive relationship with the wet weight. However, for most variables, the positive correlation appeared to be relatively low. Based on the linear models depicted in the plots, it was assumed that CI as well as NDRE would hold the highest importance for predicting the wet weight.
Subsequent to running the initial random forest model, analysis of the variable importance of the predictors was conducted.

![VariableImportance_2](https://github.com/leibrocs/Field_Methods_Demmin/assets/116877154/b5fd09de-e2c5-47c4-a081-5894cf3964da)

The results indicate that CI and NDVI had by far the greatest impact on the model's prediction. Additionally, NDRE, EVI, and SAVI were also identified as important variables contributing to the model's performance. Interestingly, the field data collected, such as canopy height and chlorophyll content, were found to be the least important parameters for predicting the wet weight.

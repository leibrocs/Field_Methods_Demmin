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
The estimation of biomass was conducted using the R programming language and a Random Forest regression algorithm. Initially, the input data for the model was imported. In addition to field data such as canopy height and chlorophyll content, a total of six different vegetation indices (VIs), specifically NDVI, NDRE, SAVI, GNDVI, EVI, and CI, were incorporated as predictors for estimating above-ground biomass of winterwheat. These VIs were computed from a Sentinel-2 multispectral image covering the study area. The image was clipped to the extent of the two experimental fields and the VI values were extracted for the point coordinates of the different plots. Subsequently, these values were merged with the field data, and any rows containing NA values were removed. After this data cleansing step, we were left with 47 data points. Then, a first data inspection using ggplot was carried out. For this, we plotted the wet weight and established linear models for each of the nine predictors against the wet weight to investigate the correlation between the variables.
Given that 47 data points represent a relatively limited dataset for a random forest regression, we implemeted bootstrapping techniques to augment the sample size to 100 data points. This involved randomly resampling our existing data to create new training datasets. This process effectively augmented the sample size, allowing the random forest model to learn from a broader range of data variations, resulting in more robust and generalizable outcomes.
Following the pre-processing, the data was split into training data for constructing and fitting the model and testing data for making predictions on unseen data. The split ratio was set to 80% for training and 20% for testing. Subsequently, the model was fitted using the 'randomForest' function from the 'randomForest' R package, employing 100 trees for growing the random forest and randomly sampling three variables at each split. The determination of the number of variables was accomplished using the 'tuneRF' function, which helped to identify the optimal 'mtry' parameter. Once the model was configured, we generated plots to evaluate variable importance and perform predictions on the unseen test data. These prediction were then used to assess the model's performance by comparing them to the actual input data. 
After running the initial random forest model, a second model with identical settings was established. However, this time, it included only the six VIs as predictors. This model setup was necessary for making predictions across the entire expanse of the two experimental fields, as we lacked field data for every pixel within those fields. This model was trained accordingly and employed to predict the above-ground biomass over the entirety of the two experimental fields. Finally, the results were visualized. 

## 3. Results
To start the analysis, the Sentinel-2 scene, the two experimental fields as well as the six different study sites were plotted for a first overview.

![Overview_Plot](https://github.com/leibrocs/Field_Methods_Demmin/assets/116877154/4cb93baa-167a-45d3-9baf-ccbaa17ae6aa)

Prior to executing the  Random Forest model, the above-ground biomass was visually examined across all 47 plots.

![AGB_Plots](https://github.com/leibrocs/Field_Methods_Demmin/assets/116877154/e8b333da-a2de-49f6-9c62-696cca48352a)

It was observed, that the wet weight exhibited significant fluctuations not only between the different plots but also between the two experimental fields. On the first field, weights ranged from approximately 48g to  around 66g, while on the second field values ranging from approximately 57g to around 93g were observable.
Furthermore, scatterplots to visualize the relationship between the different predictors and the wet weight (above-ground biomass) were generated.

![ABG_Predictors](https://github.com/leibrocs/Field_Methods_Demmin/assets/116877154/76224405-7b9a-41c7-82b3-2c456aefa2d8)

The results of these scatterplots indicate, that all predictors exhibited a positive relationship with the wet weight. However, for most variables, the positive correlation appeared to be relatively low. Based on the linear models depicted in the plots, it was assumed that CI as well as NDRE would hold the highest importance for predicting the wet weight.
Subsequent to running the initial random forest model, analysis of the variable importance of the predictors was conducted.

![variable_importance_44_visualized](https://github.com/leibrocs/Field_Methods_Demmin/assets/116877154/e28df21a-4bba-4ca7-aea9-13d4cbb4681a)

The results indicate that NDRE, CI and SAVI had the greatest impact on the model's prediction, which is in agreement with the results from the linear models. Additionally, chlorophyll content as well as canopy height, were also identified as important variables contributing to the model's performance. Interestingly, regularly used indices for biomass prediction, such as the NDVI and EVI, were found to be the least important parameters for predicting the wet weight.
The analysis of the accuracy of the fitted random forest returned, that the initial model had a mean of squared residuals of 44.94 and a variance of 55.92%. Additionally, a RMSE of 6.70 was computed. 

<img width="850" alt="RF_Model_Evaluation_44" src="https://github.com/leibrocs/Field_Methods_Demmin/assets/116877154/2290852f-0e40-4878-8a97-db6058bc1cfa">

The comparison between the predicted and actual wet weight from the test data revealed a rather irregular outcome. In some instances, the predicted values closely approximated the actual values, deviating only slightly above or below them. However, in other cases, there were substantial discrepancies between predictions and the field data. The prediction errors spanned from minor over- and under-predictions to errors exceeding 10g or more.
The second RF model, which exclusively employed the six different VIs as predictors, exhibited an even poorer performance. It achieved only a mean of squared residuals of 55.34 and a variance of 45.73%. Nevertheless, due to the inability to enhance the accuracy, this model was still utilized to estimate the wet weight of the entire expanse of the two experimental fields. Subsequently, the estimated values were visualized using ggplot2. In the plot, areas with nearly zero biomass were discernable, alongside regions, where the biomass appeared to significantly exceed 70g. Notably, these high biomass areas were located in the lower-left corner of the first field as well as the upper half of the second field. The areas on the fields where no winterwheat was cultivated correspond with the parts of the prediction displaying low biomass values. Moreover, upon visual inspection of the original Sentinel-2 scene, it became apparent that the lower part of the second field exhibited a different growth stage, aligning with the outcomes of the random forest model. This obervation reinforces the model's results, suggesting varying above-ground biomass in different sections of the second field.

![PredictedAGB_Fields](https://github.com/leibrocs/Field_Methods_Demmin/assets/116877154/86930e34-862c-4c9c-90de-ce69d4ad3e38)

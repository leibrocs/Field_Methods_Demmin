# Estimation of Winterwheat Aboveground Biomass using Sentinel-2 Imagery and Random Forest Algorithm

## 1. Introduction
Crop biomass is a globally important climate-relevant terrestrial carbon pool and its monitoring important for weed, pest and soil erosion control, as well as for nutrient cycling, overall soil health and crop productivity improvement. Crop yield is the marketable fraction of above ground biomass accumulated over a growing season, which varies widely over space and time, because of differences in cultivars, environmental conditions, and agronomic practices. In the agricultural sector there is a growing interest in using remotely sensed imagery to estimate crop biomass. Satellite data delivers consistent and frequent information for crop yield estimations over large areas. Crop models typically account for the cummulative effect of these three factors and other geospatial information. Satellite image data are an important input to the models because the capture eco-physical conditions on the ground consistently and frequently and they offer the possibility to do so over large areas. Machine learning methods liek random forest are increasingly employed for crop modelling because of the challenges of process-based methods to account for the complex interactions governing crop biomass

## 2. Material and Methods

### 2.1 Study Area
The study area consisted of two winterwheat fields within the larger DEMMIN (Durable Environmental Multidisciplinary Monitoring Information Network) experimental area located about 180km north of Berlin in the state of Mecklenburg-Vorpommern in the northeast German lowlands. Todays young moraine landscape with its numerous lakes and bogs is characterized by typical periglacial landscape elements such as extensive flat sandy areas, hills, and depressions. DEMMIN has been operated for about 20 years as a calibration and validation test site for remote sensing data by the German Aerospace Center (DLR). 

### 2.2 Data
#### 2.2.1 Field Data Acquisition
The field data was collected over the course of one week from 29th of May to 3nd of June 2023. In the first field, there were three different study areas, each compromising  nine individual one-square-meter plots. In the second field, data was sampled at two different sites, each consisting of nine plots as well. 
At each of the individual plots, the canopy height, wet weight, and chlorophyll content was measured. The canopy height was determined by averaging measurements taken from a total of four plants within each plot. For chlorophyll content, four plants were sampled as well, taking three measurements per plant: one at the top of the canopy, one in the middle, and one on the lowest leaf. Regarding wet weight, three plants were randomly selected from each plot and weighted in the laboratory.

#### 2.2.2 Satellite Data
For the analysis, a single Sentinel-2 scene that covered the entire study area was utilized. This scene was acquired on 3rd of June 2023, which coincided with the final day of the field data collection. To calculate the vegetation indices, the red, green, and near infrared band were used. The spatial resolution for all three of these bands was 20 meters. The images were composited and retrieved from the Sentinel Hub EO Browser. 

### 2.3 Biomass Estimation



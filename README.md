# Data from the study: "Vegetation-rainfall coupling as a large-scale indicator of ecosystem distributions in a heterogeneous landscape"

Marcio Baldissera Cure¹*, Bernardo M. Flores¹, Caio R. C. Mattos², Rafael Silva Oliveira³, Marina Hirota¹, ³, 4

¹ Graduate Program in Ecology, Universidade Federal de Santa Catarina (UFSC) (Brazil)

² Department of Earth and Planetary Sciences, Rutgers University, New Brunswick (USA)

³ Instituto de Biologia, Universidade Estadual de Campinas (UNICAMP) (Brazil)

4 Department of Physics, Universidade Federal de Santa Catarina (UFSC) (Brazil)

* Correspondence author: marciobcure@gmail.com

## Interactive leaflet map
#### [Fire frequency for the _Chapada dos Veadeiros National Park_](https://mauritia-flexuosa.github.io/fire_frequency_pncv/)

## Dados_1.txt contains:

- Coup_lag_max - Maximum coupling between precipitation and greenness
- Lag - The lag in months in which occurs the maximum coupling
- max_evi2 - Maximum EVI2
- mean_evi2 - Mean EVI2
- sd_evi2 - Standard deviation of EVI2
- tree_cover_wet - Measured tree cover in the wet season
- tree_cover_dry - Measured tree cover in the dry season
- tree_cover_hansen - Tree cover from Hansen et al., (2013)
- phenology - difference in tree cover between wet and dry seasons
- twi - topographic wetness index
- freq_fire - Fire frequency from Mapbiomas dataset
- Vegetation_type - Vegetation types studied (savanna, gallery forest and dry forest)

## fis_quim_solo.txt contains:

- Soil variables used in this study to characterize environmental conditions

## traits.txt contains tree traits measured in the field:

- Bark_thickness - Bark thickness
- Tree_height - tree height
- basal_area_total - total basal area per hectare
- cwm_basal_area - mean basal area
- Vegetation_type - Vegetation type
- Bark_thickness_relative - Bark thickess relative to basal area

## script_coupling.R contains:

- The R script used to calculate the coupling between EVI2 and precipitation.

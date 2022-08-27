# Cure-et-al-pncv-data

This repository stores data used in the study "The role of vegetation function in differentiating ecosystem states in the Brazilian Cerrado" by Cure et al.

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
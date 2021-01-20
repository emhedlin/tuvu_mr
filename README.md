# TUVU Mark Recap

The dataset summarizes ~20 years of Turkey Vulture wing-tagging efforts led by Stuart Houston. Tagging was mostly done with hatch-years, but there was some success trapping adults by waiting until they entered the nest site (usually an abandoned farm house), blocking off all exists, and then sending in some poor soul (me) to tackle them. Work was mostly completed in Saskatchewan with some tagging in Alberta. Resighting locations are dispersed throughout AB and SK, and all the way down to wintering grounds in South America. Tagged individuals are rarely observed in the second year, current thinking is that they stay south of the border. 

### 
*note:* I know a fair number of satellite transmitters were fit to adults, but I need to find the data. If I can, we can integrate known-fate estimations of adult survival with mark-recapture estimates.

<p float="center">
  <img src="documents/tuvu.jpg" width="900" />
  <img src="documents/n_individuals.png" width="900" />
</p>




```
├── /data
│    ├── resight.csv                             <- merged tagging and resights datasets
│    ├── resight_balanced.csv                    <- produced with clean.R, closer to MR data
│    ├── sighting_data.xlsx                      <- reference only 
│    ├── Natal Dispersal TUVU20Mar2019ZJz.xlsx   <- reference only        
│    ├── banded.csv                              <- reference only 
│    ├── 12.Dec.2019_TUVU_Distance_Bearing_KG.xlsx <- reference only           
│    └── 12.Dec.2019_TUVU_All_Sighting_Data.xlsx   <- reference only           
│
├── /scripts 				
│    └── clean.R       <- produces data/resight_balanced.csv
│
├── /documents 				
│    └── tuvu.jpg      <- basic tagging location map displayed on readme
│
```

### Authors
* Erik Hedlin
* Stuart Houston
* Marten Stoffel
* Ryan Fisher
* Tom Perry
* Jean-Francois Therrien

Data was initially entered from raw data sheets and cleaned by Kyron G. Project currently includes Erik Hedlin, Tom Perry, Ryan Fisher, and Jean-.

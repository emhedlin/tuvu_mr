# TUVU Mark Recap

The dataset summarizes ~20 years of Turkey Vulture wing-tagging efforts led by Stuart Houston. Tagging was primarily conducted on hatch-year individuals, but some adults were trapped by blocking all exits in the nesting location (usually an abandoned farm house). Work was mostly completed in Saskatchewan with some observations from Alberta. Resighting locations are dispersed throughout AB and SK, and all the way down to wintering grounds in South America. Tagged individuals are rarely observed in the second year, current thinking is that they stay relatively far south. 

### 
*note:* I know satellite transmitter data exists, but I need to find it. If I can, we can integrate known-fate estimations of survival with mark-recapture estimates.

<p float="center">
  <img src="documents/tuvu.jpg" width="900" />
</p>



```
├── /data
│   ├── resight.csv                             <- merged tagging and resights datasets
│   ├── resight_balanced.csv                    <- produced with clean.R, closer to MR data
│   ├── sighting_data.xlsx                      <- reference only 
│   ├── Natal Dispersal TUVU20Mar2019ZJz.xlsx   <- reference only        
│   ├── banded.csv                              <- reference only 
│   ├── 12.Dec.2019_TUVU_Distance_Bearing_KG.xlsx <- reference only           
│   └── 12.Dec.2019_TUVU_All_Sighting_Data.xlsx   <- reference only           
│
├── /scripts 				
│   └── clean.R       <- produces data/resight_balanced.csv
│
├── /documents 				
│   └── tuvu.jpg      <- basic tagging location map displayed on readme
│
```


Data was initially entered from raw data sheets and cleaned by Kyron G. Project currently includes Erik Hedlin, Tom Perry, and Ryan Fisher.

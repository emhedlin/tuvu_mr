# TUVU Mark Recap

The dataset summarizes ~20 years of Turkey Vulture wing-tagging efforts led by Stuart Houston. Tagging was primarily conducted on hatch-year individuals, but some adults were trapped by blocking all exits in the nesting location (usually an abandoned farm house). Work was mostly completed in Saskatchewan with some observations from Alberta. Resighting locations are dispersed throughout AB and SK, and all the way down to wintering grounds in South America. Tagged individuals are rarely observed in the second year, current thinking is that they stay relatively far south. 

### 
*note:* I know satellite transmitter data exists, but I need to find it. If I can, we can integrate known-fate estimations of survival with mark-recapture estimates.

<p float="center">
  <img src="documents/tuvu.jpg" width="900" />
</p>



```
├── /Accessory files         <- legacy files - probably not useful
|
├── /Tutorial_files
│   ├── AN_obj.names              <- classes for the adult/nestling work
│   ├── Evaluate.md               <- instructions on how to run the models after training 
│   ├── Training_model.md         <- instructions on how to train the model
│   ├── band_obj.names            <- classes for band detection 
│   ├── cropimages.py             <- remove the Reconyx info in each image
│   ├── egg_obj.names             <- classes for egg detection
│   ├── my_object_detection.py    <- python script to run your model across all images (produces a csv output)
│   ├── object_detection_yolo.py  <- runs the model on one image as a test, produces an image with bounding box
│   ├── od_functions.oy           <- functions called from my_object_detection.py
│   └── splitTrainAndTest.py      <- 
│
├── /manuscript 			<- TeX files for manuscript development	             
```


Data was initially entered from raw data sheets and cleaned by Kyron G. Project currently includes Erik Hedlin, Tom Perry, and Ryan Fisher.

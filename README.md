# TUVU Mark Recap

The dataset summarizes ~ 20 years of wing-tagging efforts of Turkey Vultures. Tagging effort was primarily in Saskatchewan, with some observations in AB. Resighting locations are dispersed throughout AB and SK, and all the way down to wintering grounds in South America. 

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



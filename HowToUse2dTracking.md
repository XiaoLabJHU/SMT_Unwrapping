## A step-by-step tutorial for 2d single tracking, unwarpping, segmentation, and post data-processing
The purpose of the process is to flatten (unwrap) the rod-shape (cylinder part) cell envelope and register the coordinates from 2d-projection to the real position. Or covert the X<sub>detect</sub> to X<sub>real</sub> :

![figure1](docs/CylinderUnwrapping.jpg).
    
### Step 0: Localize single molecule spots and prepare coordiantes in right format
We recommend using [ThunderSTORM](https://github.com/zitmen/thunderstorm) that saves the results in the '.csv' format.
An exmple of ThunderSTORM batch processing ImageJ macro script is included [here](/TrackingMainscript/FtsW-RFP-singleMoleculeLoc-Macro.txt).  Parameters for single molecule detection and localization in our paper are included in the same file. Users can use their own app or parameters to localize the spots as long as with the format as comma separeted CSV files:





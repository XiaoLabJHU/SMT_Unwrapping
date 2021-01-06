## Scripts for single molecule localization, linking, and trajectory unwrapping
  ### This README file describes the function of important scripts in this folder

1. ***FtsW-RFP-singleMoleculeLoc-Macro.txt*** : An ImageJ macro for batch processing of multiple single molecule tracking movies in [ThunderSTORM](https://zitmen.github.io/thunderstorm/).
2. ***spotsLinking.m*** and ***spotsLinking.fig***: The GUI for single-molecule spot-linking using nearest neighbour algorithm. This script will use following functions:
   - ***gmtOptimize***: Link localizations from different frames in the ThunderSTORM result files. This function calls following functions:
   - ***costMat***:  Calculate the cost matrix of distance between two paricular frames
   - ***costPairwise.m***: Calculate the pairwise cost value of two individule spots
   - ***costMatThresh***: Threshold the cost matrix by a given distance threshold
   - ***initialGmat***: Initiate association matrix of each spot in two frames
   - ***redCost***: Update the association matrix based on switched linkage of spots
   - ***closeLink***: Close gaps between short linkages to produce trajectories
   - ***trackConv***: Convert the format of the trajectory data tstructure for further processing
3. ***TraceRefine.m*** and ***TraceRefine.fig***: The GUI for refining trajectories generated from the ***spotsLinking.m*** based on spot intensity and bright field image. 
4. ***RegionCrop_unwrap.m*** and ***RegionCrop_unwrap.fig***: The GUI for rotating bacteria cells (rod-shaped) and estimate the diameter of the cells. Then unwrap the trajectories (supposed to be on the cell envelope) on a flat plane (real 1d). 
5. ***RegionCrop_unwrap3D.m*** and ***RegionCrop_unwrap3D.fig***:The 3d version of ***RegionCrop_unwrap.m*** and ***RegionCrop_unwrap.fig***. The results from ThunderSTORM should have a third column with Z position. 
   - ***TraceRotate.m*** and ***TraceRotate.fig*** The GUI used in the ***RegionCrop_unwrap3D.fig*** to rotate cell manually.
6. ***TrackingMainscript.m***： The old m-file version of ***spotsLinking.m***. 

    
    

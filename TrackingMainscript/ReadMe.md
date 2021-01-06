## Scripts for single molecule localization, linking, and trajectory unwrapping
  ### This README file describes the function of important scripts in this folder

1. ***FtsW-RFP-singleMoleculeLoc-Macro.txt*** : An ImageJ macro for batch processing of multiple single molecule tracking movies in [ThunderSTORM](https://zitmen.github.io/thunderstorm/).
2. ***spotsLinking.m*** and ***spotsLinking.fig***: The GUI for single-molecule spot-linking using nearest neighbour algorithm. This script will use following functions:
   - ***gmtOptimize***: Link localizations from different frames in the ThunderSTORM result files. This function calls following functions:
   - ***costMat***:  Calculate the cost matrix of distance between two paricular frames
      ***costPairwise.m***: Calculate the pairwise cost value of two individule spots
   - ***costMatThresh***: Threshold the cost matrix by a given distance threshold
   - ***initialGmat***: Initiate association matrix of each spot in two frames
   - ***redCost***: Update the association matrix based on switched linkage of spots
    
    

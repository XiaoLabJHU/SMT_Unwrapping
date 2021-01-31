# **SMT_Unwrapping**
SMT_unwrapping contains the Matlab scripts for single-molecule tracking in bacteria cells considering the curvature of the cell envelope.
- **TrackingMainscript** links single particals/molecules/spots from 2D or 3D result with correct format using nearest neighbour algorithm.
  - it also filters bad spots or trajectories by user defined intensity threshold and ROI based on bright field or fluorescence image
- **UnwrappingMainscript** helps rotate individual cells and unwrap the cell envelope (it only applys to the rod shape cells now).
- **State_Segementation** helps segment indivudual reajectoies to different states (it only distinguishs directional movement from confined diffusion ones now).
- **FtsW2dPostprocess** does simple statistics of the results with some plotting functions.

## Request
  1. Require Matlab 2020a or newer for some functions in the GUI.
  2. Molecules are identified and localized using imageJ plugin [ThunderSTROM:](https://github.com/zitmen/thunderstorm).
  3. Bright field (or PhaseContrast) images of bacteria cells are required for estimation of the cell diameter.
  
## How to use
  1. To process data from 2d single-molecule tracking, please find the step-by-step manual in [HowToUse2dTracking](HowToUse2dTracking.md).
  2. To process data from 2d single-molecule tracking in nanopilars, please find the the step-by-step manual in [Alink]().
  3. To process data from 3d single-molecule tracking, please find the the step-by-step manual in [Alink]().
## Reference 
Please cite this paper [Yang, Xinxing, et al. "A two-track model for the spatiotemporal coordination of bacterial septal cell wall synthesis revealed by single-molecule imaging of FtsW." Nature Microbiology (2021): 1-10.](https://www.nature.com/articles/s41564-020-00853-0)



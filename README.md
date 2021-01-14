# **SMT_Unwrapping**
SMT_unwrapping contains the Matlab scripts for single-molecule tracking in bacteria cells considering the curvature of the cell envelope.
- **TrackingMainscript** links single particals/molecules/spots from 2D or 3D result with correct format using nearest neighbour algorithm.
  - it also filters bad spots or trajectories by user defined intensity threshold and ROI based on bright field or fluorescence image
- **UnwrappingMainscript** helps rotate individual cells and unwrap the cell envelope (it only applys to the rod shape cells now).
- **State_Segementation** helps segment indivudual reajectoies to different states (it only distinguishs directional movement from confined diffusion ones now).
- **FtsW2dPostprocess** does simple statistics of the results with some plotting functions.
## Request
  1. Require Matlab 2020a or newer for some functions in the GUI
  2. Molecules are identified and localized using imageJ plugin ThunderSTROM: https://github.com/zitmen/thunderstorm
  3. Bright field (or PhaseContrast) images of bacteria cells are required for estimation of the cell diameter.
## Reference 
Please cite the paper[Yang X, McQuillen R, Lyv Z, et al. FtsW exhibits distinct processive movements driven by either septal cell wall synthesis or FtsZ treadmilling in E. coli[J]. bioRxiv, 2019: 850073.] (https://www.biorxiv.org/content/10.1101/850073v2)



# **SMT_Unwrapping**
SMT_unwrapping contains the Matlab scripts for single-molecule tracking in bacteria cells considering the curvature of the cell envelope.
- The **tracking block** links single particals/molecules/spots from 2D or 3D result with correct format using nearest neighbour algorithm.
- The **post processing block** filters bad spots or trajectories by user defined intensity threshold and ROI based on bright field or fluorescence image
- The **cell rotation and unwrapping block** helps rotate individual cells and unwrap the cell envelope (it only applys to the rod shape cells now).
- The **trajectory segmentation block** helps segment indivudual reajectoies to different states (it only distinguishs directional movement from confined diffusion ones now).
- The **statisic calulation block** does simple statistics of the results with some plotting functions.

#### Method has been used in: https://www.biorxiv.org/content/10.1101/850073v2, https://www.biorxiv.org/content/10.1101/857813v2

  1. Require Matlab 2020a or newer for some functions in the GUI
  2. Molecules are identified and localized using imageJ plugin ThunderSTROM: https://github.com/zitmen/thunderstorm
  3. Bright field (or PhaseContrast) images of bacteria cells are required for estimation of the cell diameter.

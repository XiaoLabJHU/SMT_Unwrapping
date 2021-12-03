#@ File (label = "Input directory (BF)", style = "directory") BF_inputFolder
#@ File (label = "Input directory (Movies)", style = "directory") FL_inputFolder
//#@ Integer (label = "Starting position", value = 0) i

i = 0;

BF_list = getFileList(BF_inputFolder); //read filenames of input folder
BF_list = Array.sort(BF_list); //alphabetically sort the names (nicety)
	
FL_list = getFileList(FL_inputFolder); //read filenames of input folder
FL_list = Array.sort(FL_list); //alphabetically sort the names (nicety)

//Dialog for interactive mode

Dialog.create("I want to:");
//Dialog.addString("Title:", title);
Dialog.addNumber("Start viewing at image:", i);
Dialog.addCheckbox("Run ThunderSTORM for 3D tracking", false);
Dialog.addCheckbox("Make a max intensity Z-projection", false);
Dialog.addCheckbox("Correct for cell drift", false);
Dialog.addCheckbox("Crop out movies", false);
Dialog.addCheckbox("Run on all images", false);
Dialog.show();

i = Dialog.getNumber();
do_TS = Dialog.getCheckbox();
do_ZP = Dialog.getCheckbox();
do_DFT = Dialog.getCheckbox();
do_movies = Dialog.getCheckbox();
do_batch = Dialog.getCheckbox();

if(do_TS){
	TS_Folder = getDirectory("Choose the directory for the ThunderSTORM output");
	//calibration_file = File.openDialog("Choose the 3D calibration file");
	calibration_file = "E:\\Xiao Lab Dropbox\\Lab Members\\Yepes_Martin\\Projects\\FtsA\\20211117-FtsA_FastTracking\\cylindrical calibration\\bead_2.yaml";
}


if(do_ZP){
	ZP_Folder = getDirectory("Choose the directory for the Z-projections");
	ZP_Tag = "_ZP";
}

if(do_DFT){
	BF2_Folder = getDirectory("Cell Drift- Choose the 'after' input folder!");
	DFT_Folder = getDirectory("Choose the directory for DFT images");
	DFT_Tag = "_DFT";

	BF2_list = getFileList(BF2_Folder); //read filenames of input folder
	BF2_list = Array.sort(BF2_list); //alphabetically sort the names (nicety)
}

if(do_movies){
	MOV_Folder = getDirectory("Choose the directory for the movies");
	
}

if (do_batch) {
	//setBatchMode(true);
	setBatchMode(true);

}
else {
	setBatchMode(false);
}

loop_exit = false;
while(loop_exit == false && i < FL_list.length){
	close("*");
	roiManager("reset");
	open(BF_inputFolder + File.separator + BF_list[i]); //open a file
	BF_id = getImageID();
	print("BF: " + BF_id);
	print("Opened: " + BF_inputFolder + File.separator + BF_list[i]); //optional feedback; can comment to suppress
	run("In [+]");
	run("In [+]");
	run("In [+]");
			
	open(FL_inputFolder + File.separator + FL_list[i]); //open a file
	//save_path = ZP_outputFolder + File.separator + File.nameWithoutExtension + fileTag + ".tif";
	FL_id = getImageID();
	//RFP_name = getTitle();
	print("FL Movie: " + FL_id);
	print("Opened: " + FL_inputFolder + File.separator + FL_list[i]);
	run("In [+]");
	run("In [+]");
	run("In [+]");


	if(do_ZP){
		selectImage(FL_id);
		ZP_path = ZP_Folder + File.separator + File.nameWithoutExtension + ZP_Tag + ".tif";
		run("Z Project...", "projection=[Max Intensity]");
		ZP_id = getImageID();
		print("Z Projection: " + ZP_id);
		run("In [+]");
		run("In [+]");
		run("In [+]");
		run("Fire");
		//run("Copy to System");
		//run("System Clipboard");
		saveAs("Tiff", ZP_path);
	}

	if(do_TS){
		selectImage(FL_id);
		TS_path = TS_Folder + File.separator + File.nameWithoutExtension + ".csv";
		wait(1000);
   		run("Camera setup", "offset=38.0 isemgain=true photons2adu=4.93 gainem=300.0 pixelsize=100.0");
   		wait(1000);
   		
		//run("Run analysis", 
		//"filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Local maximum] connectivity=8-neighbourhood threshold=1.5*std(Wave.F1) estimator=[PSF: Gaussian] sigma=1.6 fitradius=5 method=[Least squares] full_image_fitting=false mfaenabled=false renderer=[No Renderer]");

		//Parameters for 3D tracking of FtsA, 2021-11-17 dataset
		run("Run analysis", 
		"filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Local maximum] connectivity=8-neighbourhood threshold=1.5*std(Wave.F1) estimator=[PSF: Elliptical Gaussian (3D astigmatism)] sigma=1.6 fitradius=5 method=[Least squares] calibrationpath=["+calibration_file+"] full_image_fitting=false mfaenabled=false renderer=[No Renderer]");

   		if (do_batch){
   			wait(5000);
	   		run("Export results", "filepath=["+TS_path+"] fileformat=[CSV (comma separated)] sigma=true intensity=true chi2=true offset=true saveprotocol=false x=true y=true bkgstd=true id=true uncertainty=true frame=true");
   		}
   		else{
	   		wait(10000);
	   		run("Export results", "filepath=["+TS_path+"] fileformat=[CSV (comma separated)] sigma=true intensity=true chi2=true offset=true saveprotocol=true x=true y=true bkgstd=true id=true uncertainty=true frame=true");
   		}

	}

	if (do_DFT) {
		selectImage(BF_id);
		DFT_path = DFT_Folder + File.separator + File.nameWithoutExtension + DFT_Tag + ".tif";
		BF_name = getTitle();
		
		open(BF2_Folder + File.separator + BF2_list[i]); //open a file
		BF2_id = getImageID();
		BF2_name = getTitle();
		
		imageCalculator("Subtract create 32-bit", BF_id, BF2_id);
		DFT_id = getImageID();
		
		setAutoThreshold("Default");
	    run("Threshold...");
	    call("ij.plugin.frame.ThresholdAdjuster.setMode", "Over/Under");
	    //selectWindow("Result of " + sn1);
	    selectImage(DFT_id);    
	    run("Set Measurements...", "area mean standard min redirect=None decimal=3");
	    run("Measure");
	    avg = getResult('Mean');
	    std_dev = getResult('StdDev');
	    
	    cutoff = 3*std_dev;
	    selectImage(DFT_id); 
	    setThreshold(avg-cutoff, avg + cutoff);
	    wait(200);
	    run("Copy to System");
	    run("System Clipboard");
	    saveAs("Tiff", DFT_path);
	}

	if(do_batch){
		i++;
	}
	else {
		if(do_movies){
			if(i+1 < 10){
				i_tag = "0"+(i+1);
			}
			else{
				i_tag = ""+(i+1);
			}
			cell_Folder = MOV_Folder + File.separator + i_tag;
			ROI_path = cell_Folder + File.separator + "ROI_" + i_tag + ".zip";
			if (!File.exists(cell_Folder)){
				File.makeDirectory(cell_Folder);
				if(File.exists(ROI_path)){
					roiManager("Open", ROI_path);
				}
			}
			waitForUser("Choose ROIs and then hit OK");
			numROIs = roiManager("count");
			if (numROIs > 0){
				for(j=0; j<numROIs;j++) { 
					if(j+1 < 10){
						j_tag = "0"+(j+1);
					}
					else{
						j_tag = ""+(j+1);
					}
					ROI_name = "cell_" + i_tag + "_" + j_tag;
					
					roiManager("Select", j);
					roiManager("Rename", ROI_name);
			
					selectImage(BF_id);
					//waitForUser("tst");
					roiManager("Select", j);
					BF_title = ROI_name + "_BF";
					//run("Duplicate...", "title=&BF_title duplicate channels=2");
					run("Duplicate...", "title=&BF_title");
					//imagewidth = getWidth;
					//imageheight = getHeight;
					//imagewidth = imagewidth*4;
					//imageheight = imageheight*4;
					
					//run("Copy");
					//run("Internal Clipboard");
					run("Copy to System");
					run("System Clipboard");
					//saveAs("Tiff", "/Users/myepes/Desktop/Clipboard.tif");
					saveAs("Tiff", cell_Folder + File.separator + BF_title + ".tif"); //might change file type and matching file suffix
					//print("Saved to: " + img_path + File.separator + BF_title + ".tif"); //optional feedback; can comment to suppress
					wait(200);
					
					selectImage(FL_id);
					roiManager("Select", j);
					mov_title = ROI_name + "_mov";
					run("Duplicate...", "title=&mov_title duplicate");
					//imagewidth = getWidth;
					//imageheight = getHeight;
					//imagewidth = imagewidth*4;
					//imageheight = imageheight*4;
					//saveAs("Tiff", img_path + File.separator + mov_title + ".tif"); //might change file type and matching file suffix

					mov_path = cell_Folder + File.separator + mov_title + ".gif";
					run("8-bit");
					saveAs("Gif", mov_path);
					//run("AVI... ", "compression=JPEG frame=10 save=[&avi_name]");
					//print("Saved to: " + img_path + File.separator + mov_title + ".tif"); //optional feedback; can comment to suppress

					if(do_ZP){
						selectImage(ZP_id);
						roiManager("Select", j);
						ZP_title = ROI_name + "_ZP";
						run("Duplicate...", "title=&ZP_title");
						run("Copy to System");
						run("System Clipboard");
						saveAs("Tiff", cell_Folder + File.separator + ZP_title + ".tif"); 
					}
				}//roi manager loop
				roiManager("save", cell_Folder + File.separator + "ROI_" + i_tag + ".zip");
			}
		//roiManager("select");
		}
		else{
			waitForUser("Done viewing image");
		}
		Dialog.create("Go to next image?");
		//Dialog.addString("Title:", title);
		Dialog.addNumber("Open image", i+1);
		Dialog.addCheckbox("Exit loop", false);
		Dialog.show();
	
		i = Dialog.getNumber();
		loop_exit = Dialog.getCheckbox();
	}
}

print("DONE!");
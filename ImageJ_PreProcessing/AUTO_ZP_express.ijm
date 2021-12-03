/*Iteration Template for FCM class
	>Iterates across all files of a directory
	>Saves images, so potentially DANGEROUS.  If you don't need to save images,
		use 'Template_IterateFolderFiles.ijm' instead
	>Only run macro on COPIES of image files, keeping the originals elsewhere.
	>Ideally, keep output directory separate from input directory; the
		process tag changes the output filename as extra insurance.
*/

//#@ File (label = "Input directory (BF)", style = "directory") BF_inputFolder
#@ File (label = "Input directory (Movies)", style = "directory") RFP_inputFolder
#@ File (label = "Output directory (Z Projections)", style = "directory") ZP_outputFolder
// #@ File (label = "Output directory", style = "directory") ZP_outputFolder
#@ String (label = "File suffix (input)", value = ".tif") fileSuffix
#@ String (label = "Filename process tag (output)", value = "_ZP") fileTag

//BF_list = getFileList(BF_inputFolder); //read filenames of input folder
//BF_list = Array.sort(BF_list); //alphabetically sort the names (nicety)

RFP_list = getFileList(RFP_inputFolder); //read filenames of input folder
RFP_list = Array.sort(RFP_list); //alphabetically sort the names (nicety)

//Prompt user to input directories again if list lengths don't match

setBatchMode(true); //don't update display with each action; much faster execution
close("*"); //close all image windows
for (i = 0; i < BF_list.length; i++) { //loop
	if(endsWith(BF_list[i], fileSuffix) && endsWith(RFP_list[i], fileSuffix)) { //only process files with fileSuffix
		
		open(BF_inputFolder + File.separator + BF_list[i]); //open a file
		BF_id = getImageID();
		print("BF: " + BF_id);
		print("Opened: " + BF_inputFolder + File.separator + BF_list[i]); //optional feedback; can comment to suppress
		
		open(RFP_inputFolder + File.separator + RFP_list[i]); //open a file
		save_path = ZP_outputFolder + File.separator + File.nameWithoutExtension + fileTag + ".tif";
		RFP_id = getImageID();
		//RFP_name = getTitle();
		print("RFP: " + RFP_id);
		print("Opened: " + RFP_inputFolder + File.separator + RFP_list[i]);

//	if(endsWith(RFP_list[i], fileSuffix)) { //only process files with fileSuffix
//		open(RFP_inputFolder + File.separator + RFP_list[i]); //open a file
//		RFP_id = getImageID();
//		//RFP_name = getTitle();
//		save_path = ZP_outputFolder + File.separator + File.nameWithoutExtension + fileTag + ".tif";
//		print("RFP: " + RFP_id);
//		print("Opened: " + RFP_inputFolder + File.separator + RFP_list[i]); //optional feedback; can comment to suppress
		
			
//*****insert below actions to repeat for each file opened*****

		selectImage(RFP_id);
		run("Z Project...", "projection=[Max Intensity]");
		RFP_max_name = getTitle();
		//FL_temp = "MAX_" + FL;
		
		//x_len = lengthOf(FL);
		//strain = substring(FL,0,4);
		//number = substring(FL,x_len-6,x_len-4);
		// new_name = strain + "-ZP-" + number
		//new_name = ;
		
		selectImage(BF_id);
		run("Z Project...", "projection=[Average Intensity]");
		BF_avg_name = getTitle();
		//BF_temp = "AVG_" + BF;
		//close(BF);
		
		run("Merge Channels...", "c1=&RFP_max_name c4=&BF_avg_name create");
		//run("Brightness/Contrast...");
		//run("In [+]");


// code below will save the top-most window

//************keep code below for most circumstances************
		saveAs("Tiff", save_path); //might change file type and matching file suffix
		print("Saved to: " +  save_path); //optional feedback; can comment to suppress
		close("*"); //close all image windows before loading next file
	} //end-of-correct-fileSuffix
} //end-of-loop
setBatchMode(false);  //restore updating the display

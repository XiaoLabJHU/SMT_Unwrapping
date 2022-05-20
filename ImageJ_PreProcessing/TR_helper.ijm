#@ File (label = "Input directory (BF)", style = "directory") BF_inputFolder
#@ File (label = "Input directory (FL)", style = "directory") FL_inputFolder
#@ File (label = "Output directory (Movies)", style = "directory") MOV_Folder

i = 0;

x = 0.90*screenHeight; // main window size
y = 0.25*x; // popup window size

BF_list = getFileList(BF_inputFolder); //read filenames of input folder
BF_list = Array.sort(BF_list); //alphabetically sort the names (nicety)
	
FL_list = getFileList(FL_inputFolder); //read filenames of input folder
FL_list = Array.sort(FL_list); //alphabetically sort the names (nicety)

Dialog.create("I want to:");
//Dialog.addString("Title:", title);
Dialog.addNumber("Start viewing at image:", i);
Dialog.show();

i = Dialog.getNumber();

loop_exit = false;
while(loop_exit == false && i < FL_list.length){
	close("*");
	roiManager("reset");
	open(BF_inputFolder + File.separator + BF_list[i]); //open a file
	BF_id = getImageID();
	print("BF: " + BF_id);
	print("Opened: " + BF_inputFolder + File.separator + BF_list[i]); //optional feedback; can comment to suppress
	setLocation(0, 0, x, x);
			
	open(FL_inputFolder + File.separator + FL_list[i]); //open a file
	//save_path = ZP_outputFolder + File.separator + File.nameWithoutExtension + fileTag + ".tif";
	FL_id = getImageID();
	//RFP_name = getTitle();
	print("FL Movie: " + FL_id);
	print("Opened: " + FL_inputFolder + File.separator + FL_list[i]);
	setLocation(0, 0, x, x);
	getMinAndMax(min, max);
	setMinAndMax(min, 1500);
	
	run("Tile");

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
			BF_title = ROI_name + "_mBF";
			//run("Duplicate...", "title=&BF_title duplicate channels=2");
			//run("Duplicate...", "title=&BF_title");
			//fijosetLocation(0, 0, y, y);
			//imagewidth = getWidth;
			//imageheight = getHeight;
			//imagewidth = imagewidth*4;
			//imageheight = imageheight*4;
			
			//run("Copy");
			//run("Internal Clipboard");
			//run("Copy to System");
			//run("System Clipboard");
			//saveAs("Tiff", "/Users/myepes/Desktop/Clipboard.tif");
			//saveAs("Tiff", cell_Folder + File.separator + BF_title + ".tif"); //might change file type and matching file suffix
			//print("Saved to: " + img_path + File.separator + BF_title + ".tif"); //optional feedback; can comment to suppress
			wait(200);
			
			selectImage(FL_id);
			roiManager("Select", j);
			mov_title = ROI_name + "_mov";
			//run("Duplicate...", "title=&mov_title duplicate");
			//setLocation(0, 0, y, y);
			//getMinAndMax(min, max);
			//setMinAndMax(min, 1500);
			//mov_path = cell_Folder + File.separator + mov_title + ".gif";
			
			run("Tile");
			waitForUser("Review movie");
			//run("8-bit");
			//saveAs("Gif", mov_path);
			//imagewidth = getWidth;
			//imageheight = getHeight;
			//imagewidth = imagewidth*4;
			//imageheight = imageheight*4;
			//saveAs("Tiff", img_path + File.separator + mov_title + ".tif"); //might change file type and matching file suffix


			//run("AVI... ", "compression=JPEG frame=10 save=[&avi_name]");
			//print("Saved to: " + img_path + File.separator + mov_title + ".tif"); //optional feedback; can comment to suppress

			close("*_m*");
			
			
		}//roi manager loop
		roiManager("save", cell_Folder + File.separator + "ROI_" + i_tag + ".zip");
		//run("Tile");
		
		//new addition
		//waitForUser("Review movies");
	}
//roiManager("select");
else{
	waitForUser("Done viewing image");
	run("Tile");
}
Dialog.create("Go to next image?");
//Dialog.addString("Title:", title);
Dialog.addNumber("Open image", i+1);
Dialog.addCheckbox("Exit loop", false);
Dialog.show();

i = Dialog.getNumber();
loop_exit = Dialog.getCheckbox();
}
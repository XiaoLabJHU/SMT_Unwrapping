
// #@ File (label = "Input directory (BF)", style = "directory") BF_inputFolder
// #@ File (label = "Input directory (FL)", style = "directory") FL_inputFolder
// #@ File (label = "Output directory (Movies)", style = "directory") MOV_Folder

//#@ File (label = "Main Data Folder", style = "directory") mainFolder

mainFolder =  "/Users/myepes/Xiao Lab Dropbox/Lab Members/Yepes_Martin/Projects/FtsA/20220512-JM220/"

BF_inputFolder = mainFolder + File.separator + "BF";
FL_inputFolder = mainFolder + File.separator + "JF646";
MOV_Folder = mainFolder + File.separator + "mov";

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
Dialog.addCheckbox("tst", false);
Dialog.show();

i = Dialog.getNumber();

tst_mode =  Dialog.getCheckbox();

if (tst_mode){
	MOV_Folder = mainFolder + File.separator + "tst";
}


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
		ROI_filter = newArray;
		//Array.fill(ROI_filter, 0)
		for(j=0; j<numROIs;j++) { 
			if(j+1 < 10){
				j_tag = "0"+(j+1);
			}
			else{
				j_tag = ""+(j+1);
			}
			
			
			//ROI_name = "cell_" + i_tag + "_" + j_tag;
			
			roiManager("Select", j);
			//roiManager("Rename", ROI_name);
				
			selectImage(BF_id);
			roiManager("Select", j);
			wait(100);
			
			selectImage(FL_id);
			roiManager("Select", j);
			wait(100);
			
			run("Tile");
			waitForUser("Review movie");
			//ask user if cell will be kept or not
//			wait(200);
//			Dialog.create("Keep?");
//			Dialog.addCheckbox("Yes", false);
//			Dialog.show();
//			
//			keep_mov =  Dialog.getCheckbox();
			
//			if (keep_mov == true){
//				//ROI_filter[j] = 1;
//				ROI_name = "cell_" + i_tag + "_" + j_tag;
//				roiManager("Rename", ROI_name);
//			}
//			else{
//				//ROI_filter [j] = j
//				ROI_filter = Array.concat(ROI_filter, j);
//			}
		}
			
	}//roi manager loop
		
//		for (f = 0; f < ROI_filter.length ; f++) {
//			roiManager("Select", ROI_filter[f]);
//			roiManager("delete");
//		}
		if (numROIs > 0){
		roiManager("save", cell_Folder + File.separator + "ROI_" + i_tag + ".zip");
		}
//roiManager("select");
else{
	//waitForUser("Done viewing image");
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
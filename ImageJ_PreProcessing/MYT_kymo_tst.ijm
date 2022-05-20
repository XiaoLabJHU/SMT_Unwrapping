//Assume that correct denoised image is already selected
GFP_id = getImageID();

i = 11;

if(i+1 < 10){
	i_tag = "0"+(i+1);
}
else{
	i_tag = ""+(i+1);
}
//cell_Folder = MOV_Folder + File.separator + i_tag;
//ROI_path = cell_Folder + File.separator + "ROI_" + i_tag + ".zip";
//if (!File.exists(cell_Folder)){
//	File.makeDirectory(cell_Folder);
//	if(File.exists(ROI_path)){
//		roiManager("Open", ROI_path);
//	}
//}
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

		selectImage(GFP_id);
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
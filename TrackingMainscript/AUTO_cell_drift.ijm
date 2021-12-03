
cutoff = 100;
avg = 0;

prefix = "DFT-";
ext = ".tif";


inputFolder1 = getDirectory("Cell Drift- Choose the 'before' input folder!");
inputFolder2 = getDirectory("Cell Drift- Choose the 'after' input folder!");


images1 = getFileList(inputFolder1);
images2 = getFileList(inputFolder2);


outputFolder = getDirectory("Cell Drift- Choose the output folder!");

close("*");

for (i=0; i<images1.length; i++) {
    name_pre = images1[i];
   	pre_path = inputFolder1 + name_pre;
   	
    lofname = lengthOf(name_pre);
    corename = substring(name_pre,0,lofname-4);
    DFT_path = outputFolder + prefix + corename + ext;

	if(inputFolder1 == inputFolder2){
		sn1 = corename + "-0001";
		sn2 = corename + "-0002";
		open(pre_path);
    	selectWindow(name_pre);
    	run("Stack to Images");
	} else{
		name_post = images2[i];
   		post_path = inputFolder2 + name_post;
   		sn1 = name_pre;
    	sn2 = name_post;
    	open(pre_path);
    	open(post_path);
	}
   	

    DFT_name = "Result of " + sn1;
    
    run("Images to Stack", "name=Stack title=[] use keep");
    imageCalculator("Subtract create 32-bit", sn1, sn2);
    selectWindow(DFT_name);
    //waitForUser("Image OK?");
    setAutoThreshold("Default");
    run("Threshold...");
    call("ij.plugin.frame.ThresholdAdjuster.setMode", "Over/Under");
    //selectWindow("Result of " + sn1);
    selectWindow(DFT_name);    
    run("Set Measurements...", "area mean standard min redirect=None decimal=3");
    run("Measure");
    avg = getResult('Mean');
    std_dev = getResult('StdDev');
    cutoff = 3*std_dev;
    //selectWindow("Result of " + sn1);
    selectWindow(DFT_name); 
    setThreshold(avg-cutoff, avg + cutoff);
    wait(200);
    run("Copy to System");
    run("System Clipboard");
    saveAs("Tiff", DFT_path);
    close();
    // close("Result of " + sn1);
    close(sn1);
    close(sn2);
    selectWindow("Stack"); 
    // waitForUser("Image OK?");
    close("Stack");
    close(DFT_name);

}


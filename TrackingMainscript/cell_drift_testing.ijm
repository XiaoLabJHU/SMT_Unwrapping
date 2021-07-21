
cutoff = 100;
avg = 0;

inputFolder1 = getDirectory("Cell Drift- Choose the 'before' input folder!");
inputFolder2 = getDirectory("Cell Drift- Choose the 'after' input folder!");


images1 = getFileList(inputFolder1);
images2 = getFileList(inputFolder2);


outputFolder = getDirectory("Cell Drift- Choose the output folder!");

for (i=1; i<images1.length; i++) {
    name_pre = images1[i];
   	pre_path = inputFolder1 + name_pre;
   	name_post = images2[i];
   	post_path = inputFolder2 + name_post;


    lofname = lengthOf(name_pre);
    corename = substring(name_pre,0,lofname-4);
    prefix = "DFT-";
    ext = ".tif";
    DFT_path = outputFolder + prefix + corename + ext;

    // sn1 = corename + "-0001";
    sn1 = name_pre;
    // sn2 = corename + "-0002";
    sn2 = name_post;

    DFT_name = "Result of " + sn1;

    open(pre_path);
    open(post_path);
    // selectWindow(name);
    // run("Stack to Images");
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
    // waitForUser("Image OK?");
    run("Copy to System");
    run("System Clipboard");
    saveAs("Tiff", DFT_path);
    close();
    // close("Result of " + sn1);
    close(sn1);
    close(sn2);
    selectWindow("Stack"); 
    waitForUser("Image OK?");
    close("Stack");
    close(DFT_name);

}


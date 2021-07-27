
cutoff = 400;
avg = 0;

inputFolder = getDirectory("Cell Drift- Choose the input folder!");

images = getFileList(inputFolder);

outputFolder = getDirectory("Cell Drift- Choose the output folder!");

for (i=1; i<images.length; i++) {
    name = images[i];
    BF_path = inputFolder + name;

    lofname = lengthOf(name);
    corename = substring(name,0,lofname-4);
    prefix = "DFT-";
    ext = ".tif";
    DFT_path =outputFolder + prefix + corename + ext;

    sn1 = corename + "-0001";
    sn2 = corename + "-0002";

    open(BF_path);
    selectWindow(name);
    run("Stack to Images");
    imageCalculator("Subtract create 32-bit", sn1, sn2);
    selectWindow("Result of " + sn1);
    waitForUser("Image OK?");
    setAutoThreshold("Default");
    run("Threshold...");
    call("ij.plugin.frame.ThresholdAdjuster.setMode", "Over/Under");
    selectWindow("Result of " + sn1);
    run("Measure");
    avg = getResult('Mean');
    selectWindow("Result of " + sn1);
    setThreshold(avg-cutoff, avg + cutoff);
    waitForUser("Image OK?");
    wait(200);
    run("Copy to System");
    run("System Clipboard");
    saveAs("Tiff", DFT_path);
    close();
    close("Result of " + sn1);
    close(sn1);
    close(sn2);

}


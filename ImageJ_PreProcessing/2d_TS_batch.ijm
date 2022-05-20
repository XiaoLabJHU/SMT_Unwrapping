// modified from Kelsey's batch blinking macro
//Ask user to choose the input directoy
directory = getDirectory("Choose input directory");
fileList = getFileList(directory);
setBatchMode(true);

//Define the image identifier
FtsIident = "JF646" //can be "STORM" or "647-streaming" or whatever is unique to the actual image
idx = 0;
for(m = 0; m<fileList.length; m++) {
		if (fileList.length>0){
				file = fileList[m];
				test = indexOf(file, FtsIident);
				if(test >= 0) {
					idx = idx + 1;
					open(file);
					//selectWindow(file);
					run("Select All");
					run("Camera setup", "isemgain=true pixelsize=100.0 gainem=300.0 offset=54.0 photons2adu=4.93");
					run("Run analysis", "filter=[Wavelet filter (B-Spline)]" +
						"scale=2.0 order=3 detector=[Local maximum] connectivity=8-neighbourhood" +
						"threshold=1.5*std(Wave.F1) estimator=[PSF: Gaussian] sigma=1.0 method=[Least squares]" +
						"full_image_fitting=false fitradius=5 mfaenabled=false renderer=[No Renderer]");
					if(idx == 1){
					run("Export results", "filepath=[" +directory+ "TS_results-0"+idx+".csv]"+
						"fileformat=[CSV (comma separated)] id=true frame=true sigma=true chi2=true"+
						"bkgstd=true intensity=true saveprotocol=true offset=true uncertainty=true y=true x=true");						
					}else if(idx < 10){
					run("Export results", "filepath=[" +directory+ "TS_results-0"+idx+".csv]"+
						"fileformat=[CSV (comma separated)] id=true frame=true sigma=true chi2=true"+
						"bkgstd=true intensity=true saveprotocol=false offset=true uncertainty=true y=true x=true");	
					}else{
					run("Export results", "filepath=[" +directory+ "TS_results-"+idx+".csv]"+
						"fileformat=[CSV (comma separated)] id=true frame=true sigma=true chi2=true"+
						"bkgstd=true intensity=true saveprotocol=false offset=true uncertainty=true y=true x=true");	
					}
					}
					run("Close All");
					close("Log");
				}
			}
setBatchMode("exit and display");// modified from Kelsey's batch blinking macro
//Ask user to choose the input directoy
directory = getDirectory("Choose input directory");
fileList = getFileList(directory);
setBatchMode(true);

//Define the image identifier
FtsIident = "JF646" //can be "STORM" or "647-streaming" or whatever is unique to the actual image
idx = 0;
for(m = 0; m<fileList.length; m++) {
		if (fileList.length>0){
				file = fileList[m];
				test = indexOf(file, FtsIident);
				if(test >= 0) {
					idx = idx + 1;
					open(file);
					//selectWindow(file);
					run("Select All");
					run("Camera setup", "isemgain=true pixelsize=100.0 gainem=300.0 offset=54.0 photons2adu=4.93");
					run("Run analysis", "filter=[Wavelet filter (B-Spline)]" +
						"scale=2.0 order=3 detector=[Local maximum] connectivity=8-neighbourhood" +
						"threshold=1.5*std(Wave.F1) estimator=[PSF: Gaussian] sigma=1.0 method=[Least squares]" +
						"full_image_fitting=false fitradius=5 mfaenabled=false renderer=[No Renderer]");
					if(idx == 1){
					run("Export results", "filepath=[" +directory+ "TS_results-0"+idx+".csv]"+
						"fileformat=[CSV (comma separated)] id=true frame=true sigma=true chi2=true"+
						"bkgstd=true intensity=true saveprotocol=true offset=true uncertainty=true y=true x=true");						
					}else if(idx < 10){
					run("Export results", "filepath=[" +directory+ "TS_results-0"+idx+".csv]"+
						"fileformat=[CSV (comma separated)] id=true frame=true sigma=true chi2=true"+
						"bkgstd=true intensity=true saveprotocol=false offset=true uncertainty=true y=true x=true");	
					}else{
					run("Export results", "filepath=[" +directory+ "TS_results-"+idx+".csv]"+
						"fileformat=[CSV (comma separated)] id=true frame=true sigma=true chi2=true"+
						"bkgstd=true intensity=true saveprotocol=false offset=true uncertainty=true y=true x=true");	
					}
					}
					run("Close All");
					close("Log");
				}
			}
setBatchMode("exit and display");
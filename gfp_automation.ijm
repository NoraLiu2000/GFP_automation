////////////////////////
// DEFINING FUNCTIONS //
////////////////////////

// Function to close all open image windows
function closeAllImages() {
    list = getList("image.titles");
    for (i = 0; i < list.length; i++) {
        selectWindow(list[i]);
        close();
    }
}

//########## STEP 0.1: NAVIGATING TO THE CORRECT FILE PATH VIA LOOP #######//
//#########################################################################//
					
// Bring up prompt to pick directory - pick the directory with all folders of raw data in
mainDir = getDirectory("select directory");


// Create list of all subdirectories in main directory
subDir = getFileList(mainDir);

for (i = 0; i < subDir.length; i++) {

	// Skip if not a directory
    if (!File.isDirectory(mainDir + subDir[i])) continue;

    current_subDir = mainDir + subDir[i] + "/";  // Ensure trailing slash
    print("Processing folder: " + current_subDir);
        
    // List all files in current subdirectory
    imageList = getFileList(current_subDir);


	
	//initialise variable
	//total_results = 0;
	
	//############## STEP 0.2: CREATING NEW SAVE DIRECTORIES ##################//
	//#########################################################################//
			
	// looping through images in each folder
	for (k = 0; k < imageList.length; k++) {
		
		// skip folders
		if (File.isDirectory(current_subDir + imageList[k])) {
   	 	continue; // skip folders like 'measurements'
		}		
		// Selecting images that DO NOT start with V_ (brightfield images start with V_, lux images don't)
		if (!startsWith(imageList[k], "V_")) {
										
			// Making path for current image
			imagePath = current_subDir + imageList[k];
			print("Processing image: " + imageList[k]);
			
			// Open the image
			closeAllImages();
			open(imagePath);
					
			//############################ANALYSIS PHASE##################################
					
			//######## STEP 1: MAKE SURE THE IMAGE IS THE RIGHT FORMAT (8 BIT) ########//
			//#########################################################################//				// Get the name of the active image
			originalImage = getTitle();
				
					
			// Get the bit depth of the current image
			if (bitDepth() != 8) {
				// Convert the image to 8-bit
				run("8-bit");
			}
				
					
			//################ STEP 2: SUBTRACT BACKGROUND NOISE #####################//
			//########################################################################//
			// Get the histogram of the current image
			getHistogram(values, counts, 256);
					
			// Find the value of the highest peak
			maxCount = 0;
			peakValue = 0;
			for (l = 0; l < 256; l++) {
				if (counts[l] > maxCount) {
					maxCount = counts[l];
					peakValue = l;
				}
			}
					
			// Subtract the peak value from the entire image
			run("Subtract...", "value=" + peakValue);
					
					
			//######################### STEP 3: MEASUREMENT ##########################//
			//########################################################################//
			// Duplicate image
			run("Duplicate...", "title=whole_leaf");
					
			// run("Brightness/Contrast...");
			run("Enhance Contrast", "saturated=0.55");
			run("Apply LUT");
			
			//#########USER DESIGNATION############
			// Increase value to smooth out selections. Decrease value to enhance precision of selection.
			run("Gaussian Blur...", "sigma=2");
					
			//#########USER DESIGNATION############
			// Trial and error may be necessary to determine correct threshold algorithm
			run("Auto Threshold", "method=Triangle");
			run("Convert to Mask");
					
			//#########USER DESIGNATION############
			// Removing small objects. Use radius and threshold to determine the size threshold of objects removed.
			run("Remove Outliers...", "radius=35 threshold=50 which=Dark");
					
			// Surprisingly this fills holes in objects
			run("Fill Holes");
					
			//#########USER DESIGNATION############
			// Splits touching objects. Turn on and off as needed.
			// run("Watershed");
					
			// Finding leaf disk outer area
			run("Analyze Particles...", "size=200-Infinity pixel circularity=0.2-1.00 show=Overlay add");
					
			// Reselecting original image
			selectImage(originalImage);
			roiManager("Show None");
			roiManager("Show All");
					
			// Saving original image with nuclei outlines
			run("Capture Image");
					
			// Find the position of the final underscore
			lastUnderscorePos = lastIndexOf(originalImage, "_");
					
			// Find the position of ".tif"
			tifPos = lastIndexOf(originalImage, ".tif");
			
			// Extract the substring between the final underscore and ".tif"
			if (lastUnderscorePos > -1 && tifPos > -1) {
                treatment = substring(originalImage, lastUnderscorePos + 1, tifPos);
            } else {
                treatment = originalImage; // Just in case you forgot to put the _treatment in the name...
            }
									
			// Make save directory
			saveDir = current_subDir + "measurements/";
            File.makeDirectory(saveDir);
            
            // Save image with ROI overlay
            saveAs("PNG", saveDir + treatment + ".png");
					
			// Measuring circle intensity
			selectImage(originalImage);
			roiManager("Measure");				
					
			// Saving results
			selectWindow("Results");
            saveAs("Text", saveDir + treatment + "_results.txt");					
					
			// Clearing ROI manager only if it contains values
			if (roiManager("count") > 0) {
						roiManager("reset");
			}		
					
			// Clearing results only if it contains values
			if (nResults > 0) {
				run("Clear Results");
			}
		
			closeAllImages();			
		}
	}
}

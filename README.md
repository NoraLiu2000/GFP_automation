# GFP_automation
This macro is designed to iteratively process leaf scans containing dark circular regions and measure their intensity. Background signal is automatically removed. Useful for automated quantification of GFP and luciferase scans.
The final output includes a .png image with each region of interest (ROI) labeled by ID, and a .txt file containing the corresponding 8-bit greyscale intensity measurements. Please watch the test run video to see how the macro runs.

### Sample data:
<img src="https://github.com/user-attachments/assets/d828ed32-5f05-415e-bce6-6892644f9ae1" width="500" height="400">

### Sample output:
<img width="500" height="400" alt="image" src="https://github.com/user-attachments/assets/7324fbd7-c471-4a19-b3bc-fe763057cc70" />

## User guide
### Before you start, prepare your data for analysis by organising it as follows:
1. Create a main folder to hold your datasets.
2. Place each set of images in its own subfolder within this main directory.
3. Within each subfolder, make sure every image filename includes a unique identifier preceded by an underscore (e.g., XXXXXX_GFP1.tif). The text following the last underscore will become the name of then corresponding measurement output.

### To start analysis:
1. Download FIJI at https://imagej.net/software/fiji/downloads
2. Download gfp_automation.ijm
3. Run FIJI and drag gfp.automation.ijm into the FIJI window to open the macro file
4. Click "RUN" at the bottom of the terminal. When the pop-up file explorer window appears, select the main directory containing your data
5. Measurements will be saved in a folder named "measurements" in each subfolder.

# HRTEM Fringe Mapping Algorithm

_Maria L. Botero_

**When you use this code or a modified version of it, please cite the following articles:**

M. L. Botero, D. Chen, S. González-Calera, D. Jefferson, and M. Kraft. _HRTEM evaluation of soot particles produced by the non-premixed combustion of liquid fuels_. Carbon, 96:459–473, 2016.
[doi:10.1016/j.carbon.2015.09.077](https://doi.org/10.1016/j.carbon.2015.09.077).

M. L. Botero, Y. Sheng, J. Akroyd, J. Martin, J. A. H. Dreyer, W. Yang and M. Kraft. _Internal structure of soot particles in a diffusion flame_. Carbon, 141:635–642, 2019. [doi:10.1016/j.carbon.2018.09.063](https://doi.org/10.1016/j.carbon.2018.09.063)

## ABOUT THE CODE

The program is developed for the automatic mapping of fringes in high resolution transmission electron microscopy (HRTEM) images of soot. It applies a series of image transformations to the original TEM image to map the fringes. Fringes length, tortuosity, curvature and inter-fringe spacing are measured by this code.

Details on the code can be found in the publication mentioned above and the following technical reports:
[https://como.ceb.cam.ac.uk/preprints/155/](https://como.ceb.cam.ac.uk/preprints/155/)
[https://como.ceb.cam.ac.uk/preprints/209/](https://como.ceb.cam.ac.uk/preprints/209/)

The mapping algorithm is based on the method of _Yehliu et al (2011)_. Recently, _Gaddam et al (2016)_ discussed the influence of processing parameters on the final fringe mapping. The curvature algorithm is based on the method of _Wang et al. (2016)_.

## HOW TO USE THE CODE

This algorithm is developed in MATLAB and is compatible with version of this software 2016 onwards. The Image Toolbox is required.

### Before you run the code (explanation of each section)

1. **FOLDER and IMAGE definitions:**
- “fileLoc”: Type the path of the directory where the Image is located
- “filename”: Type the name of the image file
- “fileExt”: type image extension. Supported extensions are tif, png, jpeg, bmp, pbm, gif (see imread function in Matlab)

2. **INPUT parameters:**
- “bw_fac”: factor applied to the threshold value calculated by the Otsu’s method.
- “sigma”: standard deviation of  Gaussian filter.
- “hsize”: Gaussian filter size.There is default function, but this value can be modified by the used if desired.
- “bothat”: Pixel size of disk structuring element in Bottom-hat image transformation.
- “min_len”: minimum fringe size. Fringes smaller than this value will be eliminated. Default value 0.483.
- “min_spa”: minimum inter-fringe spacing. Fringes with average distances smaller than this value will not be considered stacked. Default value 0.3354.
- “max_spa”: minimum inter-fringe spacing. Fringes with average distances larger than this value will not be considered stacked. Default value 0.6.
- “n_seg”: number of pixels of each segment. For the curvature calculations according to _Wang et al (2016)_ method.
- “minAngle”: minimum angle accepted between segments. For the curvature calculations according to _Wang et al (2016)_ method.
- “maxAngle”: maximum angle accepted between segments. For the curvature calculations according to _Wang et al (2016)_ method.
- “minsize”: minimum accepted segment size, takes values from 0 to 1. For the curvature calculations according to _Wang et al (2016)_ method.

3. **LOAD FILE:**
The program will check if the image exists in the defined directory with the name and extension provided. If it cannot find it and Warning will appear in the Command Window and the program will stop. Common errors are a missing backslash (\) at the end of the “fileLoc” or the wrong file extension.
If the file is found, the Image will be displayed.

4. **PIXEL to nm DEFINITION:**
There are three options to obtain the px_nm ratio in the images. To select one of the options, uncomment it and comment the other two (using % at the beginning of the line).
*a.* Get the value from a text file (sometimes given as an output from the microscope). Make sure the .txt file is in the same folder as the Image and has the same name.
*b.* Get the value from the image scale bar: The image is opened, click once on the left of the scale bar and then on the right side of the scale bar (only the first to points selected are used to calculate the length of the bar in pixels). Click enter once the two point are selected. Then type the bar length in nanometers in the dialog box.
The calculated px_nm value will be saved in the same folder where the image is located.
*c.* If you know the px_nm value, input it in “px_nm”. If the px_nm value has been calculated and saved in the same folder as the Image, then you can load it.

5. **ROI: (region of interest)**
You must select a region of interest in the image. A help message will appear requesting the user to select the ROI. Click around the region desired creating a mask. If you want to change the mask created, right click on the vortex you want to delete, it is also possible to drag the mask and shift it by a sustaining click and moving the mouse. Once the ROI created is satisfactory, right click and select “Create Mask”. The ROI will be saved.
It is possible to create more than one ROI to analyze separately different regions in the image. If a ROI already exists, the program will ask if a new ROI is to be created, or if the user wants to load a previously selected ROI. The program automatically saves each ROI and enumerates them progressively as they are created. All the output files will be saved using the number of the ROI.
*Notes:* The ROI should be as close as possible to the sample to avoid interferences of the background or other areas in the image. You should select ONLY the regions of the sample that are well-focused. It is very common to have areas of the particle in focus and other areas out of focus. You should also avoid selecting regions where particles are superimposed or densely sintered because of interferences of fringes from different particles.

6. **IMAGE TRANSFORMATIONS AND BRANCH ELIMINATION:**
The program will now automatically apply the transformations to the Image and map the fringes. All branching will be eliminated and fringes shorter than the “min_len” will be eliminated (using the branch_cleaning.m algorithm).
An image will be displayed showing the result (Figure 1). The image can be exported. To do so, uncomment the corresponding line in this section.

7. **FRINGE LENGTH and TORTUOSITY Calculation:**
The mapped fringes will be then analyzed automatically:
- The coordinates of each fringe will be defined (using the fringe_sorting.m algorithm).
- The fringes length and tortuosity will be calculated (using the fringe_length_tortuosity.m algorithm).

8. **Overlaid IMAGES of fringes:**
Two images will appear showing the mapped fringes, one with the fringes overlaid to the original image (Figure 2) and another with the fringes in a white background (Figure 3). The images can be exported to the folder where the original image is. Uncomment the corresponding lines in the section starting with “export_fig”.

9. **CURVATURE Calculation:**
There are three methods for the curvature calculation. Uncomment the one desired and comment the other two. Uncomment all if curvature calculation is not required. A more detail description of each method can be found at the end of the document:
- Angle curvature: returns number and size of segments and angle between them for each fringe (angle_curvature.m algorithm).
- Menger curvature: returns the average Menger curvature, average radius of curvature and number of inflection points of each fringe (menger_curvature.m algorithm).
- Total curvature: returns the radius and curvature of a fitted circle for each fringe (tot_curvature.m algorithm).
An image will appear showing the segmentation on each fringe (Figure 4). The image can be exported. To do so, uncomment the corresponding line in this section.

10. **INTERFRINGE SPACING Calculation:**
The code will run the interfringe_spacing.m algorithm. Fringes with same orientation that comply with the spacing input specifications (“min_spa and “max_spa) it considers the fringes as stacked. The algorithm returns a matrix (ij) of inter-fringe spacing, that tells the spacing between the stacked fringe i and fringe j. If the fringes were not considered stacked the value will be a 0.

11. **MEAN and MEDIAN:**
Mean, median and standard deviation of the fringes length, tortuosity and inter-fringe spacing are calculated. The number of stacked fringes and percentage of non-stacked fringes are calculated. The percentage of highly tortuous fringes (FT>1.5) is also calculated. These values will be printed in the Command Window and kept in the workspace.

12. **Fringes distance to particle CENTRE:**
If you want to calculate the position of each fringe with respect to a point in the image (tailored for spherical-like particles). The algorithm fringes_position.m is used. A message box will appear asking if the user wants to calculate the distance of the fringes with respect to the particle centre. If you click OK then the Image will appear and you need to use the cursor to select a reference point (as the particle centre) and a circle to enclose the image.
The algorithm returns the distance of each fringe with respect to the reference point, the coordinates of the point and the radius of the circle drawn by the user (particle radius).

13. **SAVE DATA:**
You can save all the fringes data in the folder where the original Image is located, the output file will take the form “filename_ROI_fringes.mat”, where ROI is the number of the ROI you are currently analyzing.
You can also save selected data in the form “filename_ROI_Data.mat”. You need to edit the code in this section to type the specific data you want to export.

### How to run the code

1. Open the file **HRTEMFringeMapping.m** in Matlab Editor.

2. Input the directory of the image, name and file extension in the section FOLDER and IMAGE definitions.

3. Input the image transformation parameters the threshold fringe size and spacing and the curvature parameters in the section INPUT parameters.

4. Select the method you want to use to define the pixel to nanometer ratio in the section PIXEL to nm DEFINITION. Uncomment the method you want to use.

5. If you want the images of the mapped fringes to be exported and saved in the folder where the original image is, then browse in the following sections and make sure the lines starting with “export_fig” are uncommented: BRANCHES ELIMINATION (for mapped fringes in black background), Overlaid IMAGES of fringes (for superimposed fringes to the original image and fringes in a white background), INTERFRINGE SPACING Calculation (stacked fringes superimposed to the original image).

6. To save all the calculated data, browse in the section SAVE DATA and make sure the line to save all fringes structure data is uncommented. This data will be saved in the output file “fileName_ROI#_fringes.mat”. If you want to save selected data then edit the corresponding lines in that section and make sure the line to save selected results is uncommented. These selected results will be saved in the output file “fileName_ROI#_Data.mat”.

7. **_Now you are ready to run the program. Press “Run” button on the Editor._**

8. The program will ask if you create a ROI:
- If you don’t have previously saved ROIs, a message box will appear asking you to create a nee ROI, click OK. The TEM image will appear and you need to click around the region desired creating a mask (make sure to close the loop). Once the ROI created is satisfactory, right click and select “Create Mask”. The ROI will be saved.
- If you have other ROIs saved, the program will ask if you want to create a new ROI or load an existing one. If you click YES, follow the same procedure as the previous bullet point. If you click NO, then the program will ask you which ROI (previously saved) you want to load. Input the number of the ROI you want to load.

9. It will take some time while the program does the fringe mapping, branch elimination, calculates fringes length and tortuosity, curvature, chooses stack fringes and calculates inter-fringe spacing. After each step is finished, images with the results will appear.

10. The program will ask if you want to calculate the fringes distance with respect to the particle centre. If the you click OK:
- Position the cursor at the point you want to define as the centre of the particle and click there.
- An adjustable circle will appear, adjust using the mouse to define the particle outline/diameter.
If you are not satisfied with the outcome, you can select a centre and outline as many times as required.
- Once you are satisfied with the particle centre and diameter definition, press the right click. The values will be saved and the position of each fringe with respect to the centre point will be calculated.
If you click NO, then the program will finish.

11. If you uncommented the Histograms or Scatter plots of the results, they will appear now.

12. All the images and output data should be saved (if this was uncommented).

13. Statistical values and other important results are printed in the Command Window: mean, median, standard deviation of the fringe length, tortuosity and spacing, number and percentage of stacked fringes and highly tortuous fringes (FT>1.5).

### About some of the code features and subroutines

**Image transformations**

To select the type of structural elements and sizes in morphological operations please refer to _Gonzales et al_. 2009.

_Contrast enhancement_: this function improves the contrast between the object and the background. Histrogram equalization is used to enhance the image contrast (see _Yehliu et al._ 2011). The intensity histogram of the image is transformed into a uniform probability density function. This function tends to introduce noise in the background. An adaptative value depending on each image quality is calculates as the square root of the image histogram.

_Gaussian low-pass filtering:_ high frequencies are eliminated. A Gaussian mask is applied to smooth the edges between the image and filters. A rotationally symmetric Gaussian filter of size “hsize” and standard deviation “sigma” is applied to the image.

_Bottom hat transformation:_ is used to highlight the darker pixels of the image (the actual fringes). This process is used to correct uneven illumination or to remove very bright features (those smaller than the structuring element). The image is first dilated with a structuring element and the eroded by the same element. The size of the element is selected by the used “bothat”. This operation is equivalent to the Negative Transformation of the image + Top hat transformation.

_Thresholding:_ The grayscale image is converted into binary by the Otsu’s method. However the user can adjust the threshold level by using the “bw_fac” factor. This factor is applied to the calculated gray threshold level by the Otsu’s method. For bright images a factor lower than 1 can be applied, for dark images a factor higher than 1 can be applied. This helps to take into account the difference in illumination in the images, which is a common issue even when using the same microscope and takin multiple images during the same session.

_Skeletonization:_  For further fringe characterization, skeletons of each fringe are extracted via a thinning (skeletonizing) process. In this study, a parallel thinning algorithm was implemented by using a built-in function in Matlab.

**Fringe length and tortuosity calculation**

Fringe length is calculated as the number of adjacent pixels and diagonal pixels (sqrt(2)*pixel) and converted to nm using the pixel to nanometer relationship.

The fringe tortuosity is calculated as the fringe length divided by the end point distance (Euclidean distance between the first and last pixel of the fringe). To ensure there are no artifacts, the fringes cannot contain any branching and the pixels within each fringe are sorted to make sure their connectivity is consequent.

**Curvature Calculation**

There are three methods for the curvature calculation. Uncomment the one desired and comment the other two. Uncomment all if curvature calculation is not required:
- Angle curvature: this is a segmentation approach based on the publication of Wang et al 2016 ([http://pubs.acs.org/doi/abs/10.1021/acs.energyfuels.5b02907](http://pubs.acs.org/doi/abs/10.1021/acs.energyfuels.5b02907)).
The code segmentates the fringe every nth pixel (“n_seg”) and then calculates the angle between consecutive segments. If the angle between the segments and segments size does not comply with the input criteria (“minAngle”, “maxAngle”, “minsize) then the segments are merged until the criteria is met. The output is the number of segments, segment sizes and angles between them that represent each fringe.
- Menger curvature: is curvature of 3 points calculated as the inverse of the radius of the unique Euclidean circus that passes through the 3 points. The radius of such circle is ¼ of the product of the three sides divided by its area.
The code moves through the fringe pixel by pixel and calculates the radius of curvature and Menger curvature at each 3-pixels and then makes an average of each. It can also detect a change of curvature in the fringe (inflection point). For each fringe the code will store the average Menger curvature, average radius of curvature and number inflection points.
- Total curvature: fits a circle to the fringe and uses that circle radius to estimate curvature. The code returns the curvature and radius of the fitted circle for each fringe.

**Inter-fringe distance calculation**

The code will run the interfringe_spacing.m algorithm. In this algorithm the code will go through each fringe and find all other fringes that have the same orientation: tending to horizontal (between -45° and 45°) or tending to vertical (outside 45°). For all fringes with the same orientation the distance to the all other fringes (as the average Euclidean distance of each pixel with respect to all pixels in the other fringe) is calculated. If the distance is within the input criteria (“max_spa” and “min_spa”), the fringes are considered as stacked.

In the algorithm, while each pair of fringes is being analyzed, they are trimmed to the parallel portions only, and the spacing is calculated only on those portions.

**Fringes distance to a reference point**

This is tailored for particles with spherical-like shape because you can select a point in the image corresponding to the particle centre and subsequently select a circle that outlines the particle. This function calculates the distance of each fringe with respect to the centre point (reference point) the user selects. Given that the coordinates of each fringe are known, the distance is calculated as the average of the Euclidean distance of each pixel in the fringe with respect to the reference point.

The algorithm returns the distance of each fringe with respect to the reference point, the coordinates of the point and the radius of the circle drawn by the user (particle radius). You can then use this in a post-processing step to calculate the fringe parameters distribution at different distances with respect to the particle centre. You can also use the particle radius to normalize the fringes distance with respect to the particle centre.

However, if you have a different purpose, you can still select the point that you want to use as your reference point and the distance of each fringe with respect to that point will be calculated. In this case you will also have to select a circle and the diameter of that circle will be saved in your data, but you can ignore it.

## REFERENCES

C. K. Gaddam, C.-H. Huang, and R. L. Vander Wal. _Quantification of nano-scale carbon structure by HRTEM and lattice fringe analysis_. Pattern Recognition Letters, 76:90 – 97, 2016. [doi:10.1016/j.patrec.2015.08.028](https://doi.org/10.1016/j.patrec.2015.08.028). Special Issue on Skeletonization and its Application.

R.C. Gonzales, R. E. Woods, S. L. Eddins. _Digital Image Processing Using Matlab_. 2nd Edition. 2009. Gatesmark Publishing.

C. Wang, T. Huddle, C.-H. Huang, W. Zhu, R. L. Vander Wal, E. H. Lester, and J. P. Mathews. _Improved quantification of curvature in high-resolution transmission electron microscopy lattice fringe micrographs of soots_. Carbon, 117:174 – 181, 2017. [doi:10.1016/j.carbon.2017.02.059](https://doi.org/10.1016/j.carbon.2017.02.059).

K. Yehliu, R. L. Vander Wal, and A. L. Boehman. _Development of an HRTEM image analysis method to quantify carbon nanostructure_. Combustion and Flame, 158(9):1837 – 1851, 2011. [doi:10.1016/j.combustflame.2011.01.009](https://doi.org/10.1016/j.combustflame.2011.01.009).

## Version history

### v_1_3_1

- Gaussian filter function was changed to _imgaussfilt_ as recommender in Matlab R2018a version.

- The contrast function was also changed using an automatically calculated value. The function _histeq_ is still used but now the contras in not user input bust calculates with _hgram_ that is the square root of the histogram of the image. This change was made after evaluating and comparing results with ImageJ image processing that provides a cleaner (less branched) fringe detection.

### v_1_3

- Clean up code to have all required inputs at the beginning.

- Added optional morphological transformations to the image. Closing and opening transformations that are usually performed to break T and Y connections and then repair the broken fringes. This is not necessary as we have a branch cleaning algorithm, but it could help reduce the branching and improve the results. If the user does not want to use it, just input a value of 1 in the parameters “cl” and “op” (the pixel size of the closing and opening elements).

### v_1_2

- Added a parameter “bw_fac” to modify the threshold value calculated by the Otsu’s method.

- Added function to select particle centre and radius

- Added function to locate fringes with respect to particle centre: fringes_position.m

- Added functions for radial distribution of fringes

### v_1_1

- Added function for branch cleaning (branch_cleaning.m) to eliminate T, Y and H branch points. It tries to retain the larger branch and eliminate the shorter branches (when they are smaller than the minimum pixel size)

- Added different functions to calculate curvature: 1- Total curvature (tot_curvature.m), 2- Menger curvature (menger_curvature.m) and 3- Angle curvature (angle_curvature.m) following _Mathews et al. 2017_ [doi:10.1016/j.carbon.2017.02.059](https://doi.org/10.1016/j.carbon.2017.02.059)
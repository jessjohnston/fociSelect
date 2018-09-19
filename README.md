# fociSelect
Play movie and record x,y positions of selected foci.

Hand-pick fluorescent loci from a .dv movie and save each focus x,y position and an image with all selected foci. For most efficient use, this function should be used in two separate instances of MATLAB, situated side by side--play the continuous movie on the left (task 1) and pick foci positions on the right (task 2).
    
What the function does:
  1) Loads .dv movie to Workspace.
  2) Plays movie (task 1) and shows first frame of movie next to it (task 2).
  3) Allow for cursor selection of foci to include:
    a) Click on spot.
    b) Generate list of x,y positions.
    c) Generate .png image of numbered loci.
    
Inputs:
  filepart = unique identifier for data set, e.g., 'mis4-242'.
  movieNum = number of movies to analyze, e.g., ['O1';'02']; else assign as 'all' to analyze all movies of filepart type.
  task = 1 to only view movie; 2 to only pick foci positions.
    
Outputs:
  foci_positions = structure array of all x,y positions of selected 
  foci from one or more .dv movies. Saved in folder './foci'.
  .png image of all selected foci saved in new folder './foci/foci_images'.
    
Created by Jessica Williams, September 17, 2018.

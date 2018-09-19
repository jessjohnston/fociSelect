function [foci_positions] = fociSelect(filepart,movieNum,task) 

    % Hand-pick fluorescent loci from a .dv movie and save each focus x,y
    % position and an image with all selected foci. For most efficient use,
    % this function should be used in two separate instances of MATLAB,
    % situated side by side--play the continuous movie on the left (task
    % 1) and pick foci positions on the right (task 2).
    
    % What the function does:
    % 1) Loads .dv movie to Workspace.
    % 2) Plays movie (task 1) and shows first frame of movie next to it 
    % (task 2).
    % 3) Allow for cursor selection of foci to include:
    %   a) Click on spot.
    %   b) Generate list of x,y positions.
    %   c) Generate .png image of numbered loci.
    
    % Inputs:
    %   filepart = unique identifier for data set, e.g., 'mis4-242'.
    %   movieNum = number of movies to analyze, e.g., ['O1';'02']; else
    %       assign as 'all' to analyze all movies of filepart type.
    %   task = 1 to only view movie; 2 to only pick foci positions.
    
    % Outputs:
    %   foci_positions = structure array of all x,y positions of selected 
    %   foci from one or more .dv movies. Saved in folder './foci'.
    %   .png image of all selected foci saved in new folder
    %   './foci/foci_images'.
    
    % Created by Jessica Williams, September 17, 2018.


    % Designate image/movie type (e.g. '.dv').
    image_type = '.dv';

    % Select parent directory of movie file sets.
    filepath = dir(fullfile('./')); % Current Folder

    % Find indices of non-cached .dv file names and store as list 'fileidx'.
    fileidx = [];
    for i = 1:length(filepath)
        if strncmp(filepath(i).name,'.',1) == 0 && ...
                endsWith(filepath(i).name,image_type) == 1 && ... % Ends 
                    % with '.dv'.
                contains(filepath(i).name,filepart) == 1 % Contains 
                    % designated descriptor 'filepart'.
            fileidxtmp = i; 
        else
            fileidxtmp = [];
        end
        fileidx = [fileidx;fileidxtmp];
    end
           
    % If movieNum is a numerical input (e.g., [01,02,03], etc.), then edit
    % fileidx list to only a subset of file names.
    if strcmp(movieNum,'all') == 0
        fileidxsub = [];
        s = cellstr(strcat(movieNum,'_R3D.dv'));
        for ii = 1:length(fileidx)
            if endsWith(filepath(fileidx(ii)).name,s) == 1
                fileidxsub(ii,1) = fileidx(ii);
            end
        end
        fileidx = fileidxsub;
    end
    
    % Go through each .dv movie and pick loci to be included for
    % 2DParticleTracking.

    for j = 1:length(fileidx)

        % Designate .dv file locations.
        dvpath = char(fullfile('./',filepath(fileidx(j)).name));

        % Read .dv file.
        data = bfopen(dvpath);
        
        % Read image size in pixels.
        pixelNum = length(data{1,1}{1,1});

        % Select images.
        images = data{1, 1};

        % Compile each frame from movie to 3D array 'frames'.
        frames = zeros(pixelNum,pixelNum,length(images));
        for k = 1:length(images)
            frames(:,:,k) = images{k,1};
        end
        
        % Grab name of .dv file without extension to name stuff.
        filename = filepath(fileidx(j)).name;
        filename = filename(1:end-7);
        
        % Add file name to structure array to organize data.
        foci_positions(j).name = filename;

        % If desired task is to simply show movie, use '1'. If you want to
        % show both the movie and pick the loci positions, use '3'.
        if task == 1
            
            % Position movie on left-hand side of screen.
            figure('Position',[0 150 800 600],'Units','inches');

            % Construct infinite for-loop to play movie continuously.
            % Play movie continuously.
            l = 1;
            colormap(gray)
            while l > 0
                for l = 1:length(images)
                    f1 = imagesc(frames(:,:,l));
                    pause(0.005) % Frame interval = 0.005 sec.
                    % If figure window is closed, stop for-loop.
                    if ishandle(f1) == 0
                        break
                    end
                end
                % If figure window is closed, stop for-loop.
                if ishandle(f1) == 0
                    break
                end
            end
            
        % If desired task is to simply pick loci positions, use '2'. If you
        % want to show both the movie and pick the loci positions, use '3'.
        elseif task == 2
            
            % Show first frame of movie.
            f2 = figure('Position',[650 150 800 600],'Units','inches');
            colormap(gray)
            imagesc(frames(:,:,1));
            % Use getpts to choose positions of selected foci and record 
            % into array 'fociPos'.
            [fociPosX,fociPosY] = getpts;
            
            % Put foci positions into structure array with movie.
            foci_positions(j).x = fociPosX;
            foci_positions(j).y = fociPosY;
            
            % If foci folders do not already exist, make them.
            if ~exist('./foci/foci_images')
                mkdir('./','foci/foci_images')
            end
                
            % Save x,y position values as .mat file in 'foci' folder.
            save(sprintf('./foci/foci_positions_%s',filepart),...
                'foci_positions')

            % If figure window is clicked once with mouse, display image 
            % with all selected and recorded foci.
            w = waitforbuttonpress;
            if (w == 0)
                close(f2)
                figure('Position',[650 150 800 600],'Units','inches');
                colormap(gray)
                imagesc(frames(:,:,1));
                hold on
                
                % Plot red circle of foci position on all subsequent 
                    % images.
                plot(fociPosX,fociPosY,'Marker','o','Color','r',...
                    'LineWidth',2,'LineStyle','none')
                txt = num2str(find(fociPosX));
                text(fociPosX+5,fociPosY+5,txt,'Color','r','LineWidth',2)
                
                % Save image of selected foci in 'foci_images' folder.
                saveas(gcf,sprintf('./foci/foci_images/foci_%s',...
                    filename),'png')
            end
        end
    end 
end

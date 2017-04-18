classdef LaserAlignment
    properties(GetAccess=public,SetAccess=protected)
        Rows
        Cols
        Angle
        VScale
        XOffset
        YOffset
        GridCoordinates % in top view imaging space
        GridParameters
        AlignmentTransform % from map co-ordinates to top view image coordinates
    end
    
    methods
        function result = isnan(~)
            result = false;
        end
    end
    
    methods(Access=protected)
        function self = LaserAlignment(rows,cols,angle,vScale,xOffset,yOffset,gridCoordinates,gridParameters,alignmentTransform)
            self.Rows = rows;
            self.Cols = cols;
            self.Angle = angle;
            self.VScale = vScale;
            self.XOffset = xOffset;
            self.YOffset = yOffset;
            self.GridCoordinates = gridCoordinates;
            self.GridParameters = gridParameters;
            self.AlignmentTransform = alignmentTransform;
        end
    end
    
    methods(Static=true)
        function la = fromLaserImages(rows,cols,imageFolder,blankImageIndex,angle,vScale,xOffset,yOffset,varargin)
            if nargin < 5 || ischar(angle)
                angle = NaN;
                vScale = NaN;
                xOffset = NaN;
                yOffset = NaN;
            end
            
            if ischar(angle)
                varargin = [{angle vScale xOffset yOffset} varargin]; % TODO : this means you either specify all the laser parameters or none, might be better to detect the first character argument and assume all the ones preceding are valid paramters
            end
            
            if nargin < 2
                error('MotorMapping:LaserAlignment:InsufficientParameters','Must provide number of rows & columns to align laser grid');
            end
            
            if nargin < 4 || ischar(blankImageIndex)
                blankImageIndex = 2;
            end
            
            if ischar(blankImageIndex)
                varargin = [{blankImageIndex angle vScale xOffset yOffset} varargin]; % TODO : see above
            end

            firstImageIndex = 3-blankImageIndex;

            if nargin < 3 || isempty(imageFolder) || all(isnan(imageFolder(:)))
                imageFolder = uigetdir(pwd,'Choose image folder...');
            end

            cd(imageFolder);
            laserImages = dir('*.bmp');

            [~,si] = sort(cellfun(@(A) str2double(A{1}{1}),cellfun(@(s) regexp(s,'tt([0-9])+','tokens'),{laserImages.name},'UniformOutput',false))); % TODO : introduced method, also specify regex

            laserImages = laserImages(si);
            laserImages = laserImages(firstImageIndex:2:(2*rows*cols));

            [grid,beta] = fitGridToSpots(laserImages,rows,cols,varargin{:});
            
            blankImage = imread(laserImages(blankImageIndex).name);
            
            figure; % TODO : supress figures?

            imagesc(blankImage);
            colormap(gray);

            hold on;

            scatter(cellfun(@mean,CX),cellfun(@mean,CY));
            scatter(grid(:,1),grid(:,2));

            [~,lastDir] = fileparts(pwd);

            saveFile = [lastDir '_laser_grid']; % TODO : more control over saving

            save(saveFile,'grid','beta','CX','CY','rows','cols');
            saveas(gcf,saveFile,'fig');

            tf = createAlignmentTransformation(rows,cols,beta);
            
            la = mm.LaserAlignment(rows,cols,angle,vScale,xOffset,yOffset,grid,beta,tf); % TODO : supress figures?
        end
    
        function la = fromMATFile(matFile)
            load(matFile,'grid','beta','rows','cols','tf');
            
            assert(logical(exist('grid','var')),'MotorMapping:LaserAlignment:GridCoordsNotFound','File %s does not contain grid co-ordinates\n',matFile);
            assert(logical(exist('beta','var')),'MotorMapping:LaserAlignment:GridParamsNotFound','File %s does not contain grid parameters\n',matFile);
            assert(logical(exist('rows','var')),'MotorMapping:LaserAlignment:RowsNotFound','File %s does not contain a number of rows\n',matFile);
            assert(logical(exist('cols','var')),'MotorMapping:LaserAlignment:ColsNotFound','File %s does not contain a number of columns\n',matFile);
            
            if ~exist('tf','var')
                tf = mm.LaserAlignment.createAlignmentTransformation(rows,cols,beta); % fuck's sake matlab lern2scope
            end
            
            la = mm.LaserAlignment(rows,cols,NaN,NaN,NaN,NaN,grid,beta,tf); % TODO : fill in NaNs if possible
        end
        
        function tf = createAlignmentTransformation(rows,cols,gridParams) % TODO : can a method be both static and non-static?
            movingPoints = [0 0; 0 rows+1; cols+1 0; cols+1 rows+1];
            fixedPoints = [1 -1 cols+2; 1 rows cols+2; 1 -1 1; 1 rows 1]*gridParams;
            tf = fitgeotrans(movingPoints,fixedPoints,'affine');
        end
    end
end
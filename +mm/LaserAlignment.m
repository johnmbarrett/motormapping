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
        function la = fromLaserImages(imageFolder,blankImageIndex,rows,cols,angle,vScale,xOffset,yOffset)
            if nargin < 5
                angle = NaN;
                vScale = NaN;
                xOffset = NaN;
                yOffset = NaN;
            end
            
            if nargin < 4
                error('MotorMapping:LaserAlignment:InsufficientParameters','Must provide laser images, blank image index, and number of rows & columns to align laser grid');
            end
            
            [grid,beta] = fitGridToSpots(rows,cols,imageFolder,blankImageIndex,false); % TODO : pass params?
            
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
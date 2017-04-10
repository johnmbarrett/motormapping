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
    
            % TODO : refactor introduce method
            movingPoints = [0 0; 0 rows+1; cols+1 0; cols+1 rows+1];
            fixedPoints = [1 -1 cols+2; 1 rows cols+2; 1 -1 1; 1 rows 1]*beta;
            tf = fitgeotrans(movingPoints,fixedPoints,'affine');
            
            la = LaserAlignment(rows,cols,angle,vScale,xOffset,yOffset,grid,beta,tf); % TODO : supress figures?
        end
    end
end
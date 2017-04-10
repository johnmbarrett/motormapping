classdef MotorMappingResult
    properties(Access=public)
        AlignmentInfo
    end
    
    properties(GetAccess=public,SetAccess=protected)
        Map
        MotionTubes
        PathLengths
        ROIs
        Trajectories
    end
    
    methods
        function la = get.AlignmentInfo(self)
            la = self.AlignmentInfo;
        end
        
        function self = set.AlignmentInfo(self,la)
            assert(isa(la,'mm.LaserAlignment') || (isnumeric(la) && isscalar(la) && isnan(la)),'MotorMapping:MotorMappingResult:IllegalLaserAlignment','Alignment info must be of class mm.LaserAlignment or a scalar NaN');
            self.AlignmentInfo = la;
        end
        
        [figs,tf,warpedMaps,refs] = alignHeatmapToBrainImage(map,brainImage,gridParams)
    end
    
    methods(Access=protected)
        function self = MotorMappingResult(map,motionTubes,pathLengths,roiPositions,trajectories)
            self.Map = map;
            self.MotionTubes = motionTubes;
            self.PathLengths = pathLengths;
            self.ROIs = roiPositions;
            self.Trajectories = trajectories;
            self.AlignmentInfo = NaN;
        end
    end
    
    methods(Static=true)
        function mmr = fromMATFile(matFile)
            load(matFile,'map','motionTubes','pathLengths','roiPositions','trajectories');
            
            assert(logical(exist('map','var')),'MotorMapping:MotorMappingResult:MapNotFound','File %s does not contain a motor map\n',matFile); % TODO : generate if missing
            assert(logical(exist('motionTubes','var')),'MotorMapping:MotorMappingResult:MotionTubesNotFound','File %s does not contain any motion tubes\n',matFile);
            assert(logical(exist('pathLengths','var')),'MotorMapping:MotorMappingResult:PathLengthsNotFound','File %s does not contain any path lengths\n',matFile);
            assert(logical(exist('roiPositions','var')),'MotorMapping:MotorMappingResult:ROIsNotFound','File %s does not contain any ROI coordinates\n',matFile);
            assert(logical(exist('trajectories','var')),'MotorMapping:MotorMappingResult:TrajectoriesNotFound','File %s does not contain any trajectories\n',matFile);
            
            mmr = mm.MotorMappingResult(map,motionTubes,pathLengths,roiPositions,trajectories);
        end
        
        function mmr = fromVideoFiles(videoFiles) % TODO : other parameters
            [map,trajectories,pathLengths,motionTubes,roiPositions] = motorTrackingMap(videoFiles);
            
            mmr = mm.MotorMappingResult(map,motionTubes,pathLengths,roiPositions,trajectories);
        end
    end
end

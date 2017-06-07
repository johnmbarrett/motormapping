classdef MATFileMotorMappingResult < mm.MotorMappingResult
    properties(Access=protected)
        FileName
    end
    
    methods(Access=protected)
        function map = getMap(self)
            map = load(self.FileName,'map');
            map = map.map;
        end
        
        function setMap(self,map) %#ok<INUSD>
            save(self.NameName,'-append','map');
        end
        
        function mt = getMotionTubes(self)
            mt = load(self.FileName,'motionTubes');
            mt = mt.motionTubes;
        end
        
        function setMotionTubes(self,motionTubes) %#ok<INUSD>
            save(self.NameName,'-append','motionTubes');
        end
        
        function pl = getPathLengths(self)
            pl = load(self.FileName,'pathLengths');
            pl = pl.pathLengths;
        end
       
        function setPathLengths(self,pathLengths) %#ok<INUSD>
            save(self.NameName,'-append','pathLengths');
        end
        
        function rois = getROIs(self)
            rois = load(self.FileName,'roiPositions');
            rois = rois.roiPositions;
        end
        
        function setROIs(self,roiPositions) %#ok<INUSD>
            save(self.NameName,'-append','roiPositions');
        end
        
        function trajectories = getTrajectories(self)
            trajectories = load(self.FileName,'trajectories');
            trajectories = trajectories.trajectories;
        end
        
        function setTrajectories(self,trajectories) %#ok<INUSD>
            save(self.NameName,'-append','trajectories');
        end
    end
    
    methods
        function self = MATFileMotorMappingResult(matFile)
            vars = who('-file',matFile);
            
            assert(ismember('map',vars),'MotorMapping:MotorMappingResult:MapNotFound','File %s does not contain a motor map\n',matFile); % TODO : generate if missing
            assert(ismember('motionTubes',vars),'MotorMapping:MotorMappingResult:MotionTubesNotFound','File %s does not contain any motion tubes\n',matFile);
            assert(ismember('pathLengths',vars),'MotorMapping:MotorMappingResult:PathLengthsNotFound','File %s does not contain any path lengths\n',matFile);
            assert(ismember('roiPositions',vars),'MotorMapping:MotorMappingResult:ROIsNotFound','File %s does not contain any ROI coordinates\n',matFile);
            assert(ismember('trajectories',vars),'MotorMapping:MotorMappingResult:TrajectoriesNotFound','File %s does not contain any trajectories\n',matFile);
            
            self.FileName = matFile;
            self.AlignmentInfo = NaN; % TODO : should there be a subclass of AlignmentInfo to represent this instead?
        end
    end
end
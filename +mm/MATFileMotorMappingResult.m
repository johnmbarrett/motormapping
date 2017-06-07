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
end